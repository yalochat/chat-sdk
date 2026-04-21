// Copyright (c) Yalochat, Inc. All rights reserved.

import SwiftUI

// Mirrors Flutter ChatInput (text-only, M3 scope — no attachment or mic button).
// Send button is disabled while the text field is blank or whitespace-only.
struct ChatInput: View {

    @ObservedObject var observable: MessagesObservable

    private var isBlank: Bool {
        observable.userMessage.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        HStack(spacing: 8) {
            TextField("Type a message…", text: $observable.userMessage)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Color(.systemGray6))
                .cornerRadius(25)
                .onSubmit { observable.sendMessage() }

            Button(action: observable.sendMessage) {
                Image(systemName: "paperplane.fill")
                    .foregroundColor(.white)
                    .padding(10)
                    .background(isBlank ? Color.gray : Color.accentColor)
                    .clipShape(Circle())
            }
            .disabled(isBlank)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
}
