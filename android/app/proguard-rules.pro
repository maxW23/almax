# Please add these rules to your existing keep rules in order to suppress warnings.
# This is generated automatically by the Android Gradle plugin.
-dontwarn com.itgsa.opensdk.mediaunit.KaraokeMediaHelper
# Keep classes from com.itgsa.opensdk
-keep class com.itgsa.opensdk.** { *; }
-keepclassmembers class com.itgsa.opensdk.** { *; }
# Add this at the top of your proguard-rules.pro
-keep class com.itgsa.opensdk.mediaunit.KaraokeMediaHelper { *; }
-keepclassmembers class com.itgsa.opensdk.mediaunit.KaraokeMediaHelper { *; }

# Enhance ZEGO rules
-keep class **.zego.**{*;}
-keep class im.zego.** { *; }
-keep class im.zego.zim.** { *; }
-keep class org.webrtc.** { *; }
-keep class com.zego.** { *; }

# Add for ExoPlayer
-keep class com.google.android.exoplayer2.** { *; }
-dontwarn com.google.android.exoplayer2.**

# Update flutter-foreground-task rules
-keep class com.ryanheise.foreground.** { *; }
-dontwarn com.ryanheise.foreground.**
# ZEGO Keep Rules
-keep class com.itgsa.opensdk.** { *; }
-keep class im.zego.** { *; }
-keep class org.webrtc.** { *; }

# General Flutter rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
# Keep Flutter-related classes and resources
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Retain R class (to prevent resource obfuscation issues)
-keep class **.R$* { *; }

# For Zego SDK (example)
-keep class **.zego.** { *; }

# For Gson (if used)
-keepattributes Signature
-keepattributes *Annotation*
-keep class com.google.gson.** { *; }
-dontwarn com.google.gson.**

# For OkHttp and Okio (used by Dio and others)
-dontwarn okhttp3.**
-dontwarn okio.**
-keep class okhttp3.** { *; }
-keep class okio.** { *; }

# For Retrofit (if you use Dio or HTTP libraries with Retrofit-like behavior)
-dontwarn retrofit2.**
-keep class retrofit2.** { *; }

# For Flutter Downloader
-keep class com.baseflow.permissionhandler.** { *; }
-dontwarn com.baseflow.permissionhandler.**

# For Hive
-keep class io.objectbox.** { *; }
-dontwarn io.objectbox.**

# For SharedPreferences
-keep class android.content.SharedPreferences { *; }

# For Just Audio
-keep class com.google.android.exoplayer2.** { *; }
-dontwarn com.google.android.exoplayer2.**

# For Image Picker
-keep class com.yalantis.ucrop.** { *; }
-dontwarn com.yalantis.ucrop.**

# For Glide or Cached Network Image (if Glide is used under the hood)
-keep class com.bumptech.glide.** { *; }
-dontwarn com.bumptech.glide.**

# General Flutter Recommendations
-keepattributes *Annotation*
-keepattributes EnclosingMethod
-keepattributes InnerClasses
-keepattributes SourceFile,LineNumberTable
-dontwarn android.arch.**
-dontwarn androidx.**

# For Encryption Libraries
-keep class javax.crypto.** { *; }
-dontwarn javax.crypto.**

# Disable obfuscation for classes that you don’t want to obfuscate (specific models or classes)
-keep class com.bwmatbw.lklklivechatapp.** { *; }
-keep class com.google.android.play.** { *; }
-keep public class * extends android.app.Application
-keepclassmembers class * {
    public <init>(android.content.Context, android.content.pm.ApplicationInfo);
}
-dontwarn com.google.android.play.**
