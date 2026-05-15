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

<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
                    TextField(Translate.inputPlaceholder, text: $messagesObservable.userMessage)
=======
                    TextField(NSLocalizedString("chat.input_placeholder", comment: ""), text: $messagesObservable.userMessage)
>>>>>>> a9a5724 (feat(kmp/ios): M9 close — action callbacks, error callback, Localizable.strings)
=======
                    TextField(L10n.inputPlaceholder, text: $messagesObservable.userMessage)
>>>>>>> ed97e13 (refactor(ios): introduce L10n enum — centralize localized strings, wrap NSLocalizedString)
=======
                    TextField(Translate.inputPlaceholder, text: $messagesObservable.userMessage)
>>>>>>> 8a4d48f (refactor(ios): rename L10n → Translate to match Flutter's naming convention)
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
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
        .confirmationDialog(Translate.attachImageTitle, isPresented: $imageObservable.showSourceSheet) {
            Button(Translate.photoLibrary) { imageObservable.showGallery = true }
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                Button(Translate.camera) { imageObservable.showCamera = true }
            }
            Button(Translate.cancel, role: .cancel) {}
=======
        .confirmationDialog(NSLocalizedString("chat.attach_image_title", comment: ""), isPresented: $imageObservable.showSourceSheet) {
            Button(NSLocalizedString("chat.photo_library", comment: "")) { imageObservable.showGallery = true }
=======
        .confirmationDialog(L10n.attachImageTitle, isPresented: $imageObservable.showSourceSheet) {
            Button(L10n.photoLibrary) { imageObservable.showGallery = true }
>>>>>>> ed97e13 (refactor(ios): introduce L10n enum — centralize localized strings, wrap NSLocalizedString)
=======
        .confirmationDialog(Translate.attachImageTitle, isPresented: $imageObservable.showSourceSheet) {
            Button(Translate.photoLibrary) { imageObservable.showGallery = true }
>>>>>>> 8a4d48f (refactor(ios): rename L10n → Translate to match Flutter's naming convention)
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                Button(Translate.camera) { imageObservable.showCamera = true }
            }
<<<<<<< HEAD
<<<<<<< HEAD
            Button(NSLocalizedString("chat.cancel", comment: ""), role: .cancel) {}
>>>>>>> a9a5724 (feat(kmp/ios): M9 close — action callbacks, error callback, Localizable.strings)
=======
            Button(L10n.cancel, role: .cancel) {}
>>>>>>> ed97e13 (refactor(ios): introduce L10n enum — centralize localized strings, wrap NSLocalizedString)
=======
            Button(Translate.cancel, role: .cancel) {}
>>>>>>> 8a4d48f (refactor(ios): rename L10n → Translate to match Flutter's naming convention)
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
