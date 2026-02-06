plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.track_me"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        // FIXED: Kotlin requires 'is' prefix and '=' for boolean flags
        isCoreLibraryDesugaringEnabled = true

        // FIXED: Using VERSION_11 is generally safer for desugaring unless you specifically need 17
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        // FIXED: Use JavaVersion.VERSION_11
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // FIXED: Added '=' for Kotlin assignment
        multiDexEnabled = true

        applicationId = "com.example.track_me"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

dependencies {
    // FIXED: Kotlin requires parentheses and double quotes
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.3")
}

flutter {
    source = "../.."
}
