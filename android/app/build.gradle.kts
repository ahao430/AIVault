import java.util.Base64
import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

/**
 * 固定签名令牌（升级不丢数据的关键：所有版本必须用同一 keystore 签名）。
 *
 * 优先级：
 * 1. CI 环境变量（GitHub Secrets 注入）
 *    ANDROID_KEYSTORE_BASE64 / ANDROID_KEYSTORE_PASSWORD /
 *    ANDROID_KEY_ALIAS / ANDROID_KEY_PASSWORD
 * 2. 本地 android/keystore.properties（不提交仓库）
 *    storeFile / storePassword / keyAlias / keyPassword
 * 3. 都没有时退回 debug 签名（仅开发用）
 */
val keystoreEnv = System.getenv("ANDROID_KEYSTORE_BASE64")
val keystoreProps = Properties().apply {
    val f = rootProject.file("keystore.properties")
    if (f.exists()) f.inputStream().use { load(it) }
}
val hasReleaseSigning = keystoreEnv != null ||
    keystoreProps.getProperty("storeFile") != null

android {
    namespace = "com.aivault.aivault"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        // flutter_local_notifications 要求 core library desugaring
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.aivault.aivault"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (hasReleaseSigning) {
            create("release") {
                if (keystoreEnv != null) {
                    // CI：base64 解码到临时文件
                    val tmp = File(
                        rootProject.layout.buildDirectory.asFile.get(),
                        "ci-release.keystore",
                    )
                    tmp.writeBytes(Base64.getDecoder().decode(keystoreEnv))
                    storeFile = tmp
                    storePassword = System.getenv("ANDROID_KEYSTORE_PASSWORD")
                    keyAlias = System.getenv("ANDROID_KEY_ALIAS")
                    keyPassword = System.getenv("ANDROID_KEY_PASSWORD")
                } else {
                    storeFile = rootProject.file(keystoreProps.getProperty("storeFile"))
                    storePassword = keystoreProps.getProperty("storePassword")
                    keyAlias = keystoreProps.getProperty("keyAlias")
                    keyPassword = keystoreProps.getProperty("keyPassword")
                }
            }
        }
    }

    buildTypes {
        release {
            // 按 ABI 拆分由 `flutter build apk --split-per-abi` 驱动
            // （Flutter 插件据此配置 splits），此处不重复设置
            if (hasReleaseSigning) {
                signingConfig = signingConfigs.getByName("release")
            } else {
                // 本地未配置签名时退回 debug（覆盖安装仅限同一 debug key）
                signingConfig = signingConfigs.getByName("debug")
            }
        }
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")
}

flutter {
    source = "../.."
}
