// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk

/** Where the pictures a person sends may come from. */
public enum class ImageSource {

    /** Anywhere, through the system photo picker. */
    All,

    /**
     * Only the device's Screenshots folder. The system file picker opens in
     * that folder, and a picture picked from anywhere else is turned away with
     * a short notice.
     */
    Screenshots,
}
