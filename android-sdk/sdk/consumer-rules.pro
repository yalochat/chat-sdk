# Copyright (c) Yalochat, Inc. All rights reserved.
#
# Rules applied to any app that uses this SDK.
#
# The chat speaks proto3 JSON, and the codec that reads and writes it works
# through descriptors: it finds every field by reflecting on the generated
# getter, setter and hasser. R8 cannot see any of that, so without these rules
# it renames or removes the accessors and every message turns into an empty one
# at runtime, with nothing logged and no exception to follow.
-keep class * extends com.google.protobuf.GeneratedMessage { *; }
-keep class * extends com.google.protobuf.GeneratedMessage$Builder { *; }
-keepclassmembers class ai.yalo.chat.sdk.internal.proto.v2.** { *; }

# The protobuf runtime looks for a faster memory path and for java.time before
# falling back, and neither is on the classpath R8 checks against.
-dontwarn sun.misc.Unsafe
-dontwarn java.time.**

# Annotations that arrive on the runtime classpath only.
-dontwarn javax.annotation.**
-dontwarn com.google.errorprone.annotations.**
