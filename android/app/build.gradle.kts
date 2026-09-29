import org.gradle.api.tasks.compile.JavaCompile
import java.util.Properties
import java.io.FileInputStream

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")

if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    // START: FlutterFire Configuration
    // END: FlutterFire Configuration
    id("org.jetbrains.kotlin.android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String?
            keyPassword = keystoreProperties["keyPassword"] as String?
            storeFile = keystoreProperties["storeFile"]?.let { file(it) }
            storePassword = keystoreProperties["storePassword"] as String?
        }
    }

    namespace = "com.fraudroko.fraudroko_app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlin {
        compilerOptions {
            jvmTarget.set(
                org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
            )
            languageVersion.set(
                org.jetbrains.kotlin.gradle.dsl.KotlinVersion.KOTLIN_2_3
            )
            apiVersion.set(
                org.jetbrains.kotlin.gradle.dsl.KotlinVersion.KOTLIN_2_3
            )
        }
    }

    defaultConfig {
        applicationId = "com.fraudroko.fraudroko_app"

        // Minimum Android 7.0 (API 24)
        minSdk = 24

        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        getByName("debug") {
            // Use Android's default debug keystore.
            // Release signing remains unchanged.
        }

        release {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}

dependencies {
    implementation("com.google.android.play:integrity:1.6.0")

    // Biometric Authentication
    implementation("androidx.biometric:biometric:1.1.0")

    // WorkManager (Background Security Monitoring)
    implementation("androidx.work:work-runtime-ktx:2.10.3")
}

tasks.withType<JavaCompile>().configureEach {
    options.compilerArgs.addAll(listOf("-Xlint:-unchecked", "-Xlint:-deprecation"))
}

flutter {
    source = "../.."
}