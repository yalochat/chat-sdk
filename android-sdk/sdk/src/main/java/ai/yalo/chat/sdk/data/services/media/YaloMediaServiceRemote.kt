// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.data.services.media

import ai.yalo.chat.sdk.LogLevel
import ai.yalo.chat.sdk.domain.models.MessageType
import ai.yalo.chat.sdk.log.YaloLog
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.job
import kotlinx.coroutines.withContext
import okhttp3.HttpUrl
import okhttp3.HttpUrl.Companion.toHttpUrlOrNull
import okhttp3.MediaType
import okhttp3.MediaType.Companion.toMediaTypeOrNull
import okhttp3.MultipartBody
import okhttp3.OkHttpClient
import okhttp3.Request
import okhttp3.RequestBody
import okhttp3.Response
import okio.BufferedSink
import okio.BufferedSource
import okio.ByteString.Companion.encodeUtf8
import okio.buffer
import okio.sink
import okio.source
import org.json.JSONException
import org.json.JSONObject
import java.io.File
import java.io.IOException

/**
 * Uploads to the backend and downloads from wherever it keeps what it was
 * given.
 *
 * No state machine behind this one: an upload is one request and one answer.
 * Downloads are cached as files so a video never has to fit in memory.
 */
internal class YaloMediaServiceRemote(
    baseUrl: HttpUrl,
    private val cacheDir: File,
    private val client: OkHttpClient = OkHttpClient(),
    logLevel: LogLevel = LogLevel.Warn,
) : YaloMediaService {

    private val log = YaloLog(LOG_NAME, logLevel)
    private val mediaUrl: HttpUrl = baseUrl.newBuilder().addPathSegments(MEDIA_PATH).build()

    override suspend fun upload(content: MediaContent, token: String): Result<Media> {
        log.info { "uploading ${content.sizeBytes} bytes of ${content.mimeType}" }
        val body = MultipartBody.Builder()
            .setType(MultipartBody.FORM)
            .addFormDataPart(PART_FILE, content.fileName, MediaRequestBody(content))
            .build()
        return post(body, token)
    }

    private suspend fun post(body: RequestBody, token: String): Result<Media> {
        val request = Request.Builder()
            .url(mediaUrl)
            .header(HEADER_AUTHORIZATION, "$BEARER $token")
            .post(body)
            .build()

        return try {
            execute(request) { response ->
                when (response.code) {
                    HTTP_CREATED -> {
                        log.info { "uploaded" }
                        Result.success(media(response.body.string()))
                    }
                    HTTP_UNAUTHORIZED -> Result.failure(TokenRefusedException())
                    else -> {
                        log.warn { "$UPLOAD_FAILED: ${response.code}" }
                        Result.failure(IOException("$UPLOAD_FAILED: ${response.code}"))
                    }
                }
            }
        } catch (error: IOException) {
            log.warn(error) { UPLOAD_FAILED }
            Result.failure(error)
        } catch (error: JSONException) {
            log.warn(error) { "$UPLOAD_FAILED: the answer cannot be read" }
            Result.failure(error)
        }
    }

    override suspend fun download(url: String): Result<File> {
        val address = url.toHttpUrlOrNull()
            ?: return Result.failure(IOException("$DOWNLOAD_FAILED: $url is not an address"))
        val target = File(cacheDir, key(address))
        if (target.exists()) {
            log.debug { "serving ${target.name} from the cache" }
            return Result.success(target)
        }
        log.info { "downloading from ${address.host}" }

        // No authorization: the address is already signed, and the token has no
        // business reaching whoever stores the file.
        val request = Request.Builder().url(address).build()
        return try {
            execute(request) { response ->
                when {
                    response.isSuccessful -> {
                        val file = store(response.body.source(), target)
                        log.info { "downloaded ${file.length()} bytes" }
                        Result.success(file)
                    }
                    else -> {
                        log.warn { "$DOWNLOAD_FAILED: ${response.code}" }
                        Result.failure(IOException("$DOWNLOAD_FAILED: ${response.code}"))
                    }
                }
            }
        } catch (error: IOException) {
            log.warn(error) { DOWNLOAD_FAILED }
            Result.failure(error)
        }
    }

    // Without this an abandoned upload keeps pushing a video at the network
    // long after whoever asked for it has gone.
    private suspend fun <T> execute(request: Request, read: (Response) -> T): T =
        withContext(Dispatchers.IO) {
            val call = client.newCall(request)
            coroutineContext.job.invokeOnCompletion { call.cancel() }
            call.execute().use(read)
        }

    // The file appears under its real name only once it is whole, so a download
    // that stops halfway cannot leave a truncated file later reads would trust.
    private fun store(source: BufferedSource, target: File): File {
        cacheDir.mkdirs()
        val partial = File.createTempFile(target.name, PARTIAL_SUFFIX, cacheDir)
        try {
            partial.sink().buffer().use { sink -> sink.writeAll(source) }
            if (!partial.renameTo(target)) {
                throw IOException("$DOWNLOAD_FAILED: cannot store ${target.name}")
            }
        } catch (error: Throwable) {
            partial.delete()
            throw error
        }
        return target
    }

    // The signature and its expiry differ every time the backend describes the
    // same media, so keying on the whole address would store a copy per read.
    private fun key(url: HttpUrl): String =
        "${url.host}${url.encodedPath}".encodeUtf8().sha256().hex()

    // Snake case from the endpoint, camel case from a serialised protobuf.
    private fun media(json: String): Media {
        val fields = JSONObject(json)
        return Media(
            id = fields.optString(FIELD_ID),
            signedUrl = fields.text(FIELD_SIGNED_URL, "signedUrl"),
            originalName = fields.text(FIELD_ORIGINAL_NAME, "originalName"),
            type = MessageType.of(fields.optString(FIELD_TYPE)),
        )
    }

    private fun JSONObject.text(snakeCase: String, camelCase: String): String =
        optString(snakeCase).ifEmpty { optString(camelCase) }

    private companion object {

        private const val LOG_NAME = "Media"

        private const val MEDIA_PATH = "v1/channels/all/media"
        private const val PART_FILE = "file"
        private const val PARTIAL_SUFFIX = ".part"

        private const val HEADER_AUTHORIZATION = "Authorization"
        private const val BEARER = "Bearer"

        private const val HTTP_CREATED = 201
        private const val HTTP_UNAUTHORIZED = 401

        private const val UPLOAD_FAILED = "Upload failed"
        private const val DOWNLOAD_FAILED = "Download failed"

        private const val FIELD_ID = "id"
        private const val FIELD_SIGNED_URL = "signed_url"
        private const val FIELD_ORIGINAL_NAME = "original_name"
        private const val FIELD_TYPE = "type"
    }
}

/**
 * Writes a [MediaContent] to the network without holding it in memory.
 *
 * [isOneShot] is left at its default, which says the body can be sent more than
 * once. That holds because the content opens a new stream each time, and it is
 * what lets an upload be retried after a stale token.
 */
private class MediaRequestBody(private val content: MediaContent) : RequestBody() {

    // A file is still worth sending when nobody can say what is in it.
    override fun contentType(): MediaType? = content.mimeType.toMediaTypeOrNull()

    override fun contentLength(): Long = content.sizeBytes

    override fun writeTo(sink: BufferedSink) {
        // The sink belongs to the caller: closing it here would cut the request
        // off before the closing boundary is written.
        content.openStream().source().use { source -> sink.writeAll(source) }
    }
}
