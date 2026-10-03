// Imported because the bare `java` accessor in a build script resolves to the
// Java plugin extension, not the package.
import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Release signing comes from android/key.properties (git-ignored, see SETUP.md).
// Without it the release build falls back to the debug keys so `flutter run
// --release` still works on a machine that has no keystore.
val keystoreProperties =
    Properties().apply {
        val file = rootProject.file("key.properties")
        if (file.exists()) file.inputStream().use { load(it) }
    }

android {
    namespace = "com.stonetech.docudis"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.stonetech.docudis"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        // ML Kit Entity Extraction requires 26.
        minSdk = 26
        targetSdk = flutter.targetSdkVersion
        // Uses the version code from pubspec.yaml. When using split APKs, 1000 * ABI_VERSION
        // is added automatically by Flutter. (https://developer.android.com/studio/build/configure-apk-splits#configure-APK-versions)
        // You can force using the value of versionCode by specifying the `-P force-version-code-ignoring-abi=true`
        // flag during build.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        ndk {
            abiFilters += listOf("arm64-v8a", "armeabi-v7a", "x86_64")
        }
    }

    // The NER model (278 MB) ships in the install-time asset pack so the base
    // APK stays under Play's 150 MB limit. `flutter build appbundle` is the
    // release path; a plain release APK has no model.
    assetPacks += listOf(":model_pack")

    androidResources {
        // Stored uncompressed so the native copy can stream it and report its length.
        noCompress += listOf("onnx")
    }

    sourceSets {
        // `flutter run` / debug APKs cannot carry asset packs, so the debug build
        // gets the same files as regular assets, synced from assets/models.
        getByName("debug") {
            assets.srcDir(layout.buildDirectory.get().asFile.resolve("debug-model-assets"))
            for (component in listOf("docudis-core", "docudis-ner")) {
                jniLibs.srcDir(
                    layout.buildDirectory.get().asFile.resolve("generated/$component/debug/jniLibs"),
                )
            }
        }
        getByName("release") {
            for (component in listOf("docudis-core", "docudis-ner")) {
                jniLibs.srcDir(
                    layout.buildDirectory.get().asFile.resolve("generated/$component/release/jniLibs"),
                )
            }
        }
    }

    signingConfigs {
        if (keystoreProperties.isNotEmpty()) {
            create("release") {
                storeFile = file(keystoreProperties.getProperty("storeFile"))
                storePassword = keystoreProperties.getProperty("storePassword")
                keyAlias = keystoreProperties.getProperty("keyAlias")
                keyPassword = keystoreProperties.getProperty("keyPassword")
            }
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.findByName("release") ?: signingConfigs.getByName("debug")
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro",
            )
        }
    }
}

// Builds a pinned Rust library (Core, or the NER inference library) for every
// app ABI from its versioned source; see tool/prepare_docudis_<name>.sh.
fun registerDocudisNativeTask(name: String, taskName: String, profile: String) =
    tasks.register<Exec>(taskName) {
        val output = layout.buildDirectory.dir("generated/docudis-$name/$profile/jniLibs")
        inputs.file(rootProject.file("../tool/docudis_${name}_version.json"))
        inputs.file(rootProject.file("../tool/prepare_docudis_$name.sh"))
        outputs.dir(output)
        // cargo-ndk only finds the NDK through the environment; hand it the one
        // this build resolved from ndkVersion so a bare shell works too.
        val ndkDirectory = androidComponents.sdkComponents.ndkDirectory
        doFirst { environment("ANDROID_NDK_HOME", ndkDirectory.get().asFile.absolutePath) }
        commandLine(
            "bash",
            rootProject.file("../tool/prepare_docudis_$name.sh").absolutePath,
            profile,
            output.get().asFile.absolutePath,
        )
    }

val prepareDocudisDebugNative = registerDocudisNativeTask("core", "prepareDocudisDebugNative", "debug")
val prepareDocudisReleaseNative = registerDocudisNativeTask("core", "prepareDocudisReleaseNative", "release")
val prepareDocudisNerDebugNative = registerDocudisNativeTask("ner", "prepareDocudisNerDebugNative", "debug")
val prepareDocudisNerReleaseNative = registerDocudisNativeTask("ner", "prepareDocudisNerReleaseNative", "release")

tasks.matching { it.name == "mergeDebugJniLibFolders" }.configureEach {
    dependsOn(prepareDocudisDebugNative, prepareDocudisNerDebugNative)
}
tasks.matching { it.name == "mergeReleaseJniLibFolders" }.configureEach {
    dependsOn(prepareDocudisReleaseNative, prepareDocudisNerReleaseNative)
}

val syncDebugModelAssets by tasks.registering(Sync::class) {
    from(rootProject.file("../assets/models/xlmr_ner_docudis")) {
        include("model.json", "tokenizer.json", "model_quantized.onnx")
    }
    into(layout.buildDirectory.dir("debug-model-assets/models/xlmr_ner_docudis"))
}
tasks.matching { it.name == "mergeDebugAssets" }.configureEach {
    dependsOn(syncDebugModelAssets)
}

// The benchmark files are Flutter assets only so the integration tests can read
// them through rootBundle; they include third-party photos of real documents.
// Release and profile builds leave them out.
tasks.withType<Copy>().matching {
    it.name == "copyFlutterAssetsRelease" || it.name == "copyFlutterAssetsProfile"
}.configureEach {
    exclude("flutter_assets/benchmark/**")
}

// flutter_onnxruntime pins onnxruntime-android 1.23.0, which crashes with SIGILL
// on SoCs that have SME but not SME2 (Snapdragon 8 Elite Gen 5 / SM8850, Android 16;
// microsoft/onnxruntime#26377). Fixed upstream in 1.28.0; force a fixed release.
configurations.all {
    resolutionStrategy.force("com.microsoft.onnxruntime:onnxruntime-android:1.30.0")
}

dependencies {
    // ML Kit text recognition ships only the Latin script by default;
    // the app OCRs Chinese (default) and Devanagari (Hindi) on-device.
    implementation("com.google.mlkit:text-recognition-chinese:16.0.1")
    implementation("com.google.mlkit:text-recognition-devanagari:16.0.1")
    // FileProvider for handing output files to AI apps (AiApps.kt).
    implementation("androidx.core:core-ktx:1.13.1")
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
