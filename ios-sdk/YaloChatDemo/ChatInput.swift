// Copyright (c) Yalochat, Inc. All rights reserved.

import SwiftUI
import UIKit

// Action-button logic:
//   recording → stop/send voice  |  has-image → send image
//   has-text → send text  |  else → mic (start recording)
struct ChatInput: View {

    @ObservedObject var messagesObservable: MessagesObservable
    @ObservedObject var imageObservable: ImageObservable
    @ObservedObject var audioObservable: AudioObservable

    @Environment(\.chatTheme) private var theme

    private var isBlank: Bool {
        messagesObservable.userMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private var hasImage: Bool { imageObservable.pickedImagePath != nil }

    var body: some View {
        VStack(spacing: 0) {
            if let image = imageObservable.pickedRawImage {
                ImagePreview(image: image, onCancel: imageObservable.discardImage) {
                    sendImage()
                }
                Divider()
            }

            if audioObservable.isRecording {
                WaveformRecorder(audioObservable: audioObservable) { fileName, amplitudes, durationMs in
                    messagesObservable.sendVoiceMessage(
                        fileName: fileName,
                        amplitudes: amplitudes,
                        durationMs: durationMs
                    )
                }
            } else {
                HStack(spacing: 8) {
                    Button {
                        imageObservable.showSourceSheet = true
                    } label: {
                        Image(systemName: theme.attachIconName)
                            .foregroundColor(theme.attachIconColor)
                            .padding(.leading, 4)
                    }

                    TextField(NSLocalizedString("chat.input_placeholder", comment: ""), text: $messagesObservable.userMessage)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .background(theme.inputBackgroundColor)
                        .cornerRadius(25)
                        .overlay(
                            RoundedRectangle(cornerRadius: 25)
                                .stroke(theme.inputBorderColor, lineWidth: 1)
                        )
                        .onSubmit { messagesObservable.sendMessage() }

                    actionButton
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
            }
        }
        .confirmationDialog(NSLocalizedString("chat.attach_image_title", comment: ""), isPresented: $imageObservable.showSourceSheet) {
            Button(NSLocalizedString("chat.photo_library", comment: "")) { imageObservable.showGallery = true }
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                Button(NSLocalizedString("chat.camera", comment: "")) { imageObservable.showCamera = true }
            }
            Button(NSLocalizedString("chat.cancel", comment: ""), role: .cancel) {}
        }
        .sheet(isPresented: $imageObservable.showGallery) {
            PHPickerRepresentable(imageObservable: imageObservable)
        }
        .fullScreenCover(isPresented: $imageObservable.showCamera) {
            CameraPickerRepresentable(imageObservable: imageObservable)
                .ignoresSafeArea()
        }
    }

    @ViewBuilder
    private var actionButton: some View {
        if hasImage || !isBlank {
            Button(action: sendAction) {
                Image(systemName: theme.sendIconName)
                    .foregroundColor(theme.sendButtonIconColor)
                    .padding(10)
                    .background(theme.sendButtonColor)
                    .clipShape(Circle())
            }
        } else {
            Button(action: audioObservable.startRecording) {
                Image(systemName: theme.micIconName)
                    .foregroundColor(theme.sendButtonIconColor)
                    .padding(10)
                    .background(theme.sendButtonColor)
                    .clipShape(Circle())
            }
        }
    }

    private func sendAction() {
        if hasImage {
            sendImage()
        } else {
            messagesObservable.sendMessage()
        }
    }

    private func sendImage() {
        guard let path = imageObservable.pickedImagePath else { return }
        messagesObservable.sendImageMessage(fileName: path, mimeType: imageObservable.mimeType)
        imageObservable.clearImage()
    }
}
