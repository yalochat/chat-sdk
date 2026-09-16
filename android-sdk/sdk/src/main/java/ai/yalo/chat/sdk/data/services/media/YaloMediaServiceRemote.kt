// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.data.services.media

import ai.yalo.chat.sdk.data.services.auth.YaloMessageAuthService
import ai.yalo.chat.sdk.domain.models.MessageType
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
 * Uploads to the backend and downloads from wherever the backend keeps what it
 * was given.
 *
 * Unlike the auth service there is no state machine behind this. A token has a
 * lifecycle worth modelling, an upload does not: one request, one answer. The
 * only decision here is what to do about a token the backend will not accept,
 * and the answer is to get another one and send the same bytes again.
 *
 * Downloads are cached as files. The alternative, handing back bytes, means a
 * video has to fit in memory twice over, and it means every re-read of the same
 * image is another round trip.
 */
internal class YaloMediaServiceRemote(
    private val auth: YaloMessageAuthService,
    baseUrl: HttpUrl,
    private val cacheDir: File,
    private val client: OkHttpClient = OkHttpClient(),
) : YaloMediaService {

    private val mediaUrl: HttpUrl = baseUrl.newBuilder().addPathSegments(MEDIA_PATH).build()

    override suspend fun upload(content: MediaContent): Result<Media> {
        val body = MultipartBody.Builder()
            .setType(MultipartBody.FORM)
            .addFormDataPart(PART_FILE, content.fileName, MediaRequestBody(content))
            .build()

        // The body is built once and sent twice if it has to be. Nothing in it
        // is spent by a first attempt, because the content opens a new stream
        // every time it is read.
        post(body)?.let { answer -> return answer }
        auth.invalidateToken()
        return post(body) ?: Result.failure(IOException("$UPLOAD_FAILED: $HTTP_UNAUTHORIZED"))
    }

    /**
     * One attempt at sending [body].
     *
     * Null means the backend refused the token, which is the one outcome worth
     * trying again, so it is told apart from every other failure here rather
     * than by unwrapping an exception later.
     */
    private suspend fun post(body: RequestBody): Result<Media>? {
        val token = auth.token().getOrElse { cause -> return Result.failure(cause) }
        val request = Request.Builder()
            .url(mediaUrl)
            .header(HEADER_AUTHORIZATION, "$BEARER $token")
            .post(body)
            .build()

        return try {
            execute(request) { response ->
                when (response.code) {
                    HTTP_CREATED -> Result.success(media(response.body.string()))
                    HTTP_UNAUTHORIZED -> null
                    else -> Result.failure(IOException("$UPLOAD_FAILED: ${response.code}"))
                }
            }
        } catch (error: IOException) {
            Result.failure(error)
        } catch (error: JSONException) {
            Result.failure(error)
        }
    }

    override suspend fun download(url: String): Result<File> {
        val address = url.toHttpUrlOrNull()
            ?: return Result.failure(IOException("$DOWNLOAD_FAILED: $url is not an address"))
        val target = File(cacheDir, key(address))
        if (target.exists()) {
            return Result.success(target)
        }

        // No authorization goes on this one. The address is already signed, and
        // the token has no business reaching whoever stores the file.
        val request = Request.Builder().url(address).build()
        return try {
            execute(request) { response ->
                when {
                    response.isSuccessful -> Result.success(store(response.body.source(), target))
                    else -> Result.failure(IOException("$DOWNLOAD_FAILED: ${response.code}"))
                }
            }
        } catch (error: IOException) {
            Result.failure(error)
        }
    }

    // Cancelling the coroutine has to cancel the call. Without this an
    // abandoned upload keeps pushing a video at the network until it runs out
    // of bytes, long after whoever asked for it has gone.
    private suspend fun <T> execute(request: Request, read: (Response) -> T): T =
        withContext(Dispatchers.IO) {
            val call = client.newCall(request)
            coroutineContext.job.invokeOnCompletion { call.cancel() }
            call.execute().use(read)
        }

    // The file appears under its real name only once it is whole. A download
    // that stops halfway leaves a discarded partial rather than a truncated
    // file that every later read would trust.
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

    // Only the host and the path say which file this is. The rest of a signed
    // address is the signature and how long it lasts, and those are different
    // every time the backend describes the same media, so keying on the whole
    // address would store another copy on every read.
    private fun key(url: HttpUrl): String =
        "${url.host}${url.encodedPath}".encodeUtf8().sha256().hex()

    // The upload endpoint answers in snake case, the same way the refresh
    // endpoint does, but a serialised protobuf would spell it in camel case.
    // Both are looked for, as in the auth service.
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
 * [isOneShot] is left alone on purpose. The default says the body can be sent
 * more than once, which is what lets an upload be tried again after the backend
 * turns away a stale token, and it holds because the content opens a new stream
 * each time.
 */
private class MediaRequestBody(private val content: MediaContent) : RequestBody() {

    // A type the device made up would raise here if it had to be valid, and a
    // file is still worth sending when nobody can say what is in it.
    override fun contentType(): MediaType? = content.mimeType.toMediaTypeOrNull()

    override fun contentLength(): Long = content.sizeBytes

    override fun writeTo(sink: BufferedSink) {
        // The sink belongs to the caller. Closing it here would cut the request
        // off before the closing boundary is written.
        content.openStream().source().use { source -> sink.writeAll(source) }
    }
}
