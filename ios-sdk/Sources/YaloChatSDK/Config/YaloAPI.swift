// Copyright (c) Yalochat, Inc. All rights reserved.

import Foundation

/// The Yalo backend the SDK talks to.
enum YaloAPI {
    static let productionHost: String = "api2-ww-us-001.yalochat.com/public-api-gateway"

    /// Production, unless `YALO_API_BASE_URL` is set, for example in an Xcode scheme.
    static var baseURL: URL {
        baseURL(environment: ProcessInfo.processInfo.environment)
    }

    static func baseURL(environment: [String: String]) -> URL {
        if let host = environment["YALO_API_BASE_URL"], !host.isEmpty, let url = URL(string: "https://\(host)") {
            return url
        }
        return URL(string: "https://\(productionHost)")!
    }
}
