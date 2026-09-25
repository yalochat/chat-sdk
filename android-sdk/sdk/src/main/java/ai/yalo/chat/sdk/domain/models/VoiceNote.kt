// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.domain.models

/**
 * The recording a voice message carries.
 *
 * [mediaUrl] is how the backend knows the audio. For a note the person has just
 * recorded it is the id the upload answered with, which is what the channel
 * expects to be told. For one the channel sent it is an address to download
 * from. [localPath] is the recording as it was made, which is what lets a note
 * the person recorded be played back without asking the network for it.
 *
 * [amplitudes] run from zero to one and span the whole recording however long
 * it ran, so the waveform drawn from them is the shape of the recording rather
 * than of its last few seconds.
 */
internal data class VoiceNote(
    val durationMillis: Long,
    val amplitudes: List<Float> = emptyList(),
    val mediaUrl: String = "",
    val mediaType: String = "",
    val fileName: String = "",
    val byteCount: Long = 0,
    val localPath: String? = null,
)
