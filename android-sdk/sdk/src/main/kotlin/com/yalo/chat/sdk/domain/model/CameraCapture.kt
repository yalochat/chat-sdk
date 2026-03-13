// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk.domain.model

import java.io.File

// Carries the FileProvider URI string for the camera intent and the backing File for the image path.
// Lives in the domain layer so ImagePickerRepository (domain interface) can reference it without
// importing from data.local — required for correct clean-architecture dependency direction.
// URI as String keeps this class free of android.net.Uri (KMP / JVM safe).
internal data class CameraCapture(val uriString: String, val file: File)
