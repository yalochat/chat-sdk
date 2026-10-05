// Copyright (c) Yalochat, Inc. All rights reserved.

import SwiftUI

@MainActor
func renders(_ view: some View) -> Bool {
    let controller: UIHostingController = UIHostingController(rootView: view)
    let window: UIWindow = UIWindow(frame: CGRect(x: 0, y: 0, width: 390, height: 844))
    window.rootViewController = controller
    window.makeKeyAndVisible()
    controller.view.layoutIfNeeded()
    return controller.view.bounds.height > 0
}
