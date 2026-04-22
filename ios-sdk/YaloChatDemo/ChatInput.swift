// Copyright (c) Yalochat, Inc. All rights reserved.

import SwiftUI

// Mirrors Flutter ChatInput. Action-button logic follows Flutter's switch:
//   recording → stop/send voice  |  has-image → send image
//   has-text → send text  |  else → mic (start recording)
struct ChatInput: View {

    @ObservedObject var messagesObservable: MessagesObservable
    @ObservedObject var imageObservable: ImageObservable
    @ObservedObject var audioObservable: AudioObservable

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
                        Image(systemName: "paperclip")
                            .foregroundColor(.secondary)
                            .padding(.leading, 4)
                    }

                    TextField("Type a message…", text: $messagesObservable.userMessage)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .background(Color(.systemGray6))
                        .cornerRadius(25)
                        .onSubmit { messagesObservable.sendMessage() }

                    actionButton
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
            }
        }
        .confirmationDialog("Attach Image", isPresented: $imageObservable.showSourceSheet) {
            Button("Photo Library") { imageObservable.showGallery = true }
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                Button("Camera") { imageObservable.showCamera = true }
            }
            Button("Cancel", role: .cancel) {}
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
                Image(systemName: "paperplane.fill")
                    .foregroundColor(.white)
                    .padding(10)
                    .background(Color.accentColor)
                    .clipShape(Circle())
            }
        } else {
            Button(action: audioObservable.startRecording) {
                Image(systemName: "mic.fill")
                    .foregroundColor(.white)
                    .padding(10)
                    .background(Color.accentColor)
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
