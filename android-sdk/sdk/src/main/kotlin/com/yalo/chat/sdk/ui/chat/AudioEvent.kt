// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk.ui.chat

import com.yalo.chat.sdk.domain.model.ChatMessage

// Port of flutter-sdk/lib/src/ui/chat/view_models/audio/audio_event.dart
sealed class AudioEvent {
    // Subscribe to the playback-completion stream (called once on screen entry).
    data object SubscribeToPlaybackCompletion : AudioEvent()
    // Start recording a voice message.
    data object StartRecording : AudioEvent()
    // Stop recording and return the resulting AudioData via state.
    data object StopRecording : AudioEvent()
    // Play the voice message; stops any currently playing message first.
    data class Play(val message: ChatMessage) : AudioEvent()
    // Stop / pause the currently playing message.
    data object Stop : AudioEvent()
}
