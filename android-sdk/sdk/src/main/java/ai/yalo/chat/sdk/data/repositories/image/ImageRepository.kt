// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.data.repositories.image

import ai.yalo.chat.sdk.domain.models.ImageAttachment
import android.net.Uri

/**
 * The pictures a person sends, on their way from the gallery into the
 * conversation.
 *
 * Nothing that picks a picture has to know where the copy the chat shows is
 * kept, or that the gallery may stop answering for the one that was picked.
 */
internal interface ImageRepository {

    /**
     * Takes a copy of what [uri] points at and describes it, ready to be stored
     * and sent. A picture the device will not hand over comes back as a failed
     * [Result], and nothing is left on disk.
     */
    suspend fun store(uri: Uri): Result<ImageAttachment>
}
