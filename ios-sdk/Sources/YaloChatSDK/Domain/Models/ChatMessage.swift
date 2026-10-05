// Copyright (c) Yalochat, Inc. All rights reserved.

import Foundation

struct ChatMessage: Identifiable, Equatable, Sendable {
    enum Role: Equatable, Sendable {
        case user
        case agent
    }
    let id: String
    let role: Role
    let text: String
}
