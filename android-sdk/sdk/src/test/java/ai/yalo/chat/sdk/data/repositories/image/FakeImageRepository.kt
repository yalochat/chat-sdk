// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.data.repositories.image

import ai.yalo.chat.sdk.domain.models.ImageAttachment
import android.net.Uri

/**
 * Stands in for the gallery so a test can say what it does without a picker.
 *
 * Set [failure] to make every pick come back failed, which is how a test asks
 * what the chat does when the device will not hand the picture over. Set
 * [picture] to null for the same thing said as nothing picked.
 */
internal class FakeImageRepository(
    var failure: Throwable? = null,
) : ImageRepository {

    /** Every address a picture was asked for, in order. */
    val stored: MutableList<Uri> = mutableListOf()

    /** What a pick hands back. */
    var picture: ImageAttachment? = ImageAttachment(
        mediaType = "image/jpeg",
        fileName = "holiday.jpg",
        byteCount = 4_096,
    )

    override suspend fun store(uri: Uri): Result<ImageAttachment> {
        failure?.let { error -> return Result.failure(error) }
        stored.add(uri)
        val picked = picture ?: return Result.failure(IllegalStateException("Nothing was picked"))
        return Result.success(picked)
    }
}
