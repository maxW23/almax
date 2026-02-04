import java.io.File
import java.util.Properties
val keystoreProperties = Properties().apply {
  rootProject.file("key.properties").takeIf { it.exists() }?.inputStream()?.use { load(it) }
}

plugins {
  id("com.android.application")
  id("org.jetbrains.kotlin.android")
  id("dev.flutter.flutter-gradle-plugin")
}

// Produce a universal APK only for Debug variants so Flutter can locate a single APK
val isDebugBuild = gradle.startParameter.taskNames.any { it.contains("Debug") }
android {
  namespace = "com.bwmatbw.lklklivechatapp"
  compileSdk = 34
  compileOptions {
    isCoreLibraryDesugaringEnabled = true
    sourceCompatibility = JavaVersion.VERSION_17
    targetCompatibility = JavaVersion.VERSION_17
  }
  kotlinOptions { jvmTarget = JavaVersion.VERSION_17.toString() }

  defaultConfig {
    applicationId = "com.bwmatbw.lklklivechatapp"
    minSdk = flutter.minSdkVersion
    targetSdk = 34
    versionCode = flutter.versionCode
    versionName = flutter.versionName
    multiDexEnabled = true
  }

  signingConfigs {
    getByName("debug") {
      val ks = file("adib.jks")
      if (ks.exists()) {
        keyAlias = "androiddebugkey"
        keyPassword = "mat18mat"
        storeFile = ks
        storePassword = "mat18mat"
      }
    }
    create("release") {
      val ks = file("adib.jks")
      if (ks.exists()) {
        keyAlias = "androiddebugkey"
        keyPassword = "mat18mat"
        storeFile = ks
        storePassword = "mat18mat"
      } else {
        signingConfig = signingConfigs.getByName("debug")
      }
    }
  }

  // Define one flavor dimension and three product flavors
  flavorDimensions += listOf("env")
  productFlavors {
    create("dev") {
      dimension = "env"
      applicationIdSuffix = ".dev.new"
      versionNameSuffix = "-dev"
      resValue("string", "app_name", "Lklk (Dev)")
      // Dev uses debug keystore for both debug and release
      signingConfig = signingConfigs.getByName("debug")
    }
    create("staging") {
      dimension = "env"
      applicationIdSuffix = ".staging.new"
      versionNameSuffix = "-stg"
      resValue("string", "app_name", "Lklk (Staging)")
      // Staging uses debug keystore for both debug and release
      signingConfig = signingConfigs.getByName("debug")
    }
    create("prod") {
      dimension = "env"
      // No suffixes for production
      resValue("string", "app_name", "Lklk")
      // Prod will use buildType signing (debug keystore for debug, release keystore for release)
    }
  }

  buildTypes {
    getByName("debug") {
      signingConfig = signingConfigs.getByName("debug")
    }
    getByName("release") {
      signingConfig = signingConfigs.getByName("release")
      isMinifyEnabled = true
      isShrinkResources = true
      proguardFiles(
        getDefaultProguardFile("proguard-android-optimize.txt"),
        "proguard-rules.pro"
      )
    }
  }

  packaging {
    resources {
      excludes.add("lib/x86/**")
      excludes.add("lib/x86_64/**")
    }
  }

  // Removed abi splits to avoid conflict with ndk.abiFilters possibly set by plugins


}

flutter { source = "../.." }

dependencies {
  implementation("androidx.multidex:multidex:2.0.1")
  coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
