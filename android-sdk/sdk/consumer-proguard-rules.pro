# Phase 2 M1 — Ktor + kotlinx.serialization rules (FDE-53).
# SQLDelight rules will be added in Phase 2 M2.

# ── Ktor ──────────────────────────────────────────────────────────────────────
-keep class io.ktor.** { *; }
-keepclassmembers class io.ktor.** { *; }
-dontwarn io.ktor.**
# Ktor CIO engine uses Netty internally on Android
-dontwarn io.netty.**

# ── kotlinx.serialization ─────────────────────────────────────────────────────
-keepattributes *Annotation*, InnerClasses
-dontnote kotlinx.serialization.AnnotationsKt
-keepclassmembers class kotlinx.serialization.json.** {
    *** Companion;
}
# Keep generated serializers ($$serializer companion objects)
-keepclasseswithmembers class **$$serializer { *; }
# Keep all @Serializable classes and their companions
-keep @kotlinx.serialization.Serializable class * { *; }
-keepclassmembers @kotlinx.serialization.Serializable class * {
    *** Companion;
    *** INSTANCE;
    kotlinx.serialization.KSerializer serializer(...);
}
