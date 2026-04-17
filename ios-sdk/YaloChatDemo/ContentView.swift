// Copyright (c) Yalochat, Inc. All rights reserved.

import SwiftUI

// Placeholder chat view — replaced in iOS M5 (Core SwiftUI UI Layer).
// M1 goal: confirm the XCFramework imports and that YaloChat.initialize() wires
// the Darwin HTTP engine + NativeSqliteDriver without crashing.
// Polling starts in M5 when the ViewModel calls MessageSyncService.start(scope:).
struct ContentView: View {

    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Image(systemName: "message.fill")
                    .font(.system(size: 64))
                    .foregroundColor(.accentColor)

                Text("Yalo Chat")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("SDK connected.\nChat UI coming in M5.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding()
            .navigationTitle("Yalo Chat Demo")
        }
    }
}

#Preview {
    ContentView()
}
