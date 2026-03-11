# Phase 2 M1 — kotlinx.serialization rules (FDE-53).
# Ktor (ktor-client-android) ships its own consumer ProGuard rules via its AAR;
# no blanket -keep io.ktor.** needed here — that would prevent shrinking.
# SQLDelight rules will be added in Phase 2 M2.

# ── kotlinx.serialization ─────────────────────────────────────────────────────
-keepattributes *Annotation*, InnerClasses
-dontnote kotlinx.serialization.AnnotationsKt
-keepclassmembers class kotlinx.serialization.json.** {
    *** Companion;
}
# Keep generated serializers for SDK-owned @Serializable classes only.
# Scoped to com.yalo.chat.sdk.** to avoid keeping unrelated @Serializable classes
# in the consuming app's binary.
-keepclasseswithmembers class com.yalo.chat.sdk.**$$serializer { *; }
-keep @kotlinx.serialization.Serializable class com.yalo.chat.sdk.** { *; }
-keepclassmembers @kotlinx.serialization.Serializable class com.yalo.chat.sdk.** {
    *** Companion;
    *** INSTANCE;
    kotlinx.serialization.KSerializer serializer(...);
}
