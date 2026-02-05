pluginManagement {
    val flutterSdkPath = run {
        val properties = java.util.Properties()
        val localProps = file("local.properties")
        val fromLocal = try {
            if (localProps.exists()) {
                localProps.inputStream().use { properties.load(it) }
                properties.getProperty("flutter.sdk")
            } else null
        } catch (e: Exception) {
            null
        }
        val fromEnv = System.getenv("FLUTTER_HOME") ?: System.getenv("FLUTTER_ROOT")
        val path = fromLocal ?: fromEnv
        require(path != null) { "flutter.sdk not set in local.properties and FLUTTER_HOME/FLUTTER_ROOT not found" }
        path
    }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "8.7.3" apply false
    id("org.jetbrains.kotlin.android") version "2.1.0" apply false
}

include(":app")
