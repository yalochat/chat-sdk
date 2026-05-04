// Copyright (c) Yalochat, Inc. All rights reserved.

import SwiftUI
import ChatSdk

struct ChatView: View {

    @StateObject private var observable = MessagesObservable()
    @StateObject private var imageObservable = ImageObservable()
    @StateObject private var audioObservable = AudioObservable()

    @Environment(\.scenePhase) private var scenePhase
    // Guards against the double-fire of .onAppear + scenePhase(.active) on initial launch.
    @State private var hasStarted = false

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                MessageList(observable: observable, audioObservable: audioObservable)
                Divider()
                QuickRepliesView(
                    quickReplies: observable.quickReplies,
                    onChipTap: { label in observable.sendTextMessage(text: label) }
                )
                ChatInput(
                    messagesObservable: observable,
                    imageObservable: imageObservable,
                    audioObservable: audioObservable
                )
            }
            .navigationTitle(YaloChatSdk.shared.config?.channelName ?? "Chat")
            .navigationBarTitleDisplayMode(.inline)
        }
        .navigationViewStyle(.stack)
        .onAppear {
            guard !hasStarted else { return }
            hasStarted = true
            observable.onAppear()
        }
        .onDisappear {
            hasStarted = false
            observable.onDisappear()
        }
        .onChange(of: scenePhase) { phase in
            switch phase {
            case .background:
                observable.onDisappear()
                // hasStarted intentionally stays true so .active can restart on foreground resume.
                // (.onAppear does not re-fire for views already in the hierarchy.)
            case .active:
                // .onAppear handles the very first start; this handles foreground resume.
                if hasStarted {
                    observable.onAppear()
                }
            default:
                break
            }
        }
    }
}
