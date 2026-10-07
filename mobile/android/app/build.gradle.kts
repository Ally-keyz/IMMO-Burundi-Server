// Imported explicitly: inside a Gradle script `java` resolves to the Java
// plugin extension, so `java.util.Properties` is an unresolved reference.
import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Release signing credentials, kept out of version control.
//
// `android/key.properties` and the keystore beside it are both in
// `android/.gitignore`. Without this file the release build falls back to the
// debug keystore, which is fine for a local sideload but means the app can
// never be uploaded to Play - and, more visibly, Android App Links verification
// compares the SHA-256 of the signing certificate, so an `assetlinks.json`
// written for the real key will not match a debug-signed build.
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
val hasReleaseKeystore = keystorePropertiesFile.exists()
if (hasReleaseKeystore) {
    keystorePropertiesFile.inputStream().use { keystoreProperties.load(it) }
}

android {
    namespace = "bi.immoburundi.immoburundi"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "bi.immoburundi.immoburundi"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            if (hasReleaseKeystore) {
                signingConfig = signingConfigs.create("release") {
                    storeFile = file(keystoreProperties.getProperty("storeFile"))
                    storePassword = keystoreProperties.getProperty("storePassword")
                    keyAlias = keystoreProperties.getProperty("keyAlias")
                    keyPassword = keystoreProperties.getProperty("keyPassword")
                }
            } else {
                // A checkout without `key.properties` must still build, or a
                // fresh clone cannot run `flutter build apk` at all. The output
                // is debug-signed and is only useful for a local sideload.
                logger.warn(
                    "IMMO: android/key.properties not found - the release build " +
                        "is signed with the DEBUG key. App Links will not verify " +
                        "and this build cannot be uploaded to Play.",
                )
                signingConfig = signingConfigs.getByName("debug")
            }
        }
    }
}

flutter {
    source = "../.."
}
