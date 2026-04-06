# Flutter ProGuard rules

# Keep Flutter wrapper
-keep class io.flutter.** { *; }
-dontwarn io.flutter.**

# Firebase
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

# just_audio / audio_service
-keep class com.ryanheise.** { *; }
-dontwarn com.ryanheise.**

# Dio / OkHttp
-dontwarn okhttp3.**
-dontwarn okio.**

# flutter_local_notifications
-keep class com.dexterous.** { *; }

# General Android
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes EnclosingMethod
