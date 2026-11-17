// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.domain.models

/**
 * The video a video message carries, which is an address to download from.
 *
 * [durationMillis] is how long the channel says it is, or 0 when it did not say.
 */
internal data class VideoAttachment(
    val mediaUrl: String = "",
    val mediaType: String = "",
    val fileName: String = "",
    val byteCount: Long = 0,
    val durationMillis: Long = 0,
)
