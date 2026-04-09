// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk.ui.chat

import com.yalo.chat.sdk.domain.model.ChatMessage

sealed class AudioEvent {
    // Subscribe to the playback-completion stream (called once on screen entry).
    data object SubscribeToPlaybackCompletion : AudioEvent()
    // Start recording a voice message.
    data object StartRecording : AudioEvent()
    // Stop recording and save the resulting AudioData via state (triggers SendVoiceMessage).
    data object StopRecording : AudioEvent()
    // Discard the current recording without saving — stops the recorder and deletes the temp file.
    data object CancelRecording : AudioEvent()
    // Play the voice message; stops any currently playing message first.
    data class Play(val message: ChatMessage) : AudioEvent()
    // Stop / pause the currently playing message.
    data object Stop : AudioEvent()
}
