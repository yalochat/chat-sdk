// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.domain.models

/**
 * The picture an image message carries.
 *
 * [mediaUrl] is how the backend knows the picture. For one the person picked it
 * is the id the upload answered with, which is what the channel expects to be
 * told. For one the channel sent it is an address to download from.
 * [localPath] is the copy kept on the device, which is what lets a picture the
 * person sent be shown again without asking the network for it.
 */
internal data class ImageAttachment(
    val mediaUrl: String = "",
    val mediaType: String = "",
    val fileName: String = "",
    val byteCount: Long = 0,
    val localPath: String? = null,
)
