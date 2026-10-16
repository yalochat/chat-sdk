# Copyright (c) Yalochat, Inc. All rights reserved.
#
# Rules applied to any app that uses this SDK.
#
# The chat speaks proto3 JSON, and Wire's JSON adapter reads the generated
# messages through reflection: their fields, the @WireField annotations on them,
# their constructors and their ADAPTER. R8 cannot see any of that, so without
# these rules it renames or removes them and every message turns into an empty
# one at runtime, with nothing logged and no exception to follow.
-keep class ai.yalo.chat.sdk.internal.proto.v2.** { *; }
-keepattributes Signature, RuntimeVisibleAnnotations, AnnotationDefault

# Wire's runtime also reflects on itself, for example reading each field's
# @WireField annotation, so it is kept whole as Wire's own docs recommend.
-keep class com.squareup.wire.** { *; }
