import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Release signing material lives in `android/key.properties`, which is
// git-ignored together with the keystore it points at. Without it (a fresh
// clone, CI) the release build falls back to the debug key so it still
// assembles — a real store upload must use the properties file.
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    FileInputStream(keystorePropertiesFile).use { keystoreProperties.load(it) }
}

android {
    namespace = "com.example.hqooq"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.hqooq"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (keystorePropertiesFile.exists()) {
            create("release") {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                // `storeFile` in key.properties is relative to `android/`, not
                // to this module — `file()` here would resolve it to
                // `android/app/`.
                storeFile = rootProject.file(
                    keystoreProperties["storeFile"] as String,
                )
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }

    buildTypes {
        release {
            signingConfig = if (keystorePropertiesFile.exists()) {
                signingConfigs.getByName("release")
            } else {
                // Debug keys keep `flutter run --release` working on a clone
                // without the signing material; never ship such an artifact.
                signingConfigs.getByName("debug")
            }
        }
    }
}

flutter {
    source = "../.."
}

// No manual `dependencies {}` block here on purpose. Adding
// `io.flutter:flutter_embedding_debug` by hand made `assembleRelease` fail with
// Duplicate class errors (`flutter_embedding_debug` vs `flutter_embedding_release`),
// because the Flutter Gradle plugin already injects the correct embedding for
// the build type. `flutter build apk --release` is the check that catches this;
// the Dart-only checks (`analyze`, `test`) never touch Gradle.
