# ------------------------------------------------------------
# Flutter core
# ------------------------------------------------------------
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.embedding.** { *; }
-dontwarn io.flutter.embedding.**

# ------------------------------------------------------------
# flutter_pdfview
# ------------------------------------------------------------
-keep class com.shockwave.** { *; }
-dontwarn com.shockwave.**

# ------------------------------------------------------------
# just_audio / audio_session
# ------------------------------------------------------------
-keep class com.ryanheise.** { *; }
-dontwarn com.ryanheise.**

# ------------------------------------------------------------
# AndroidX
# ------------------------------------------------------------
-keep class androidx.** { *; }
-dontwarn androidx.**

# ------------------------------------------------------------
# Google Play Core
# ------------------------------------------------------------
-dontwarn com.google.android.play.core.**
-dontwarn com.google.android.play.core.splitcompat.**
-dontwarn com.google.android.play.core.splitinstall.**
-dontwarn com.google.android.play.core.tasks.**

# ------------------------------------------------------------
# Kotlin
# ------------------------------------------------------------
-dontwarn kotlin.**
-keep class kotlin.** { *; }
-keep class kotlin.Metadata { *; }

# ------------------------------------------------------------
# Regras padrão recomendadas pelo Flutter
# ------------------------------------------------------------
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.plugins.GeneratedPluginRegistrant { *; }
