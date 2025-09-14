plugins {
    id("com.android.application")
    id("kotlin-android")
    // ⚠️ Le plugin Flutter doit être appliqué en dernier
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "fr.yasemin.movem8" // ✅ ton vrai namespace
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
        applicationId = "fr.yasemin.movem8" // ✅ même chose que namespace
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // ⚠️ Mets ta vraie signature ici si tu veux publier
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
