plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    // مكوّن خدمات جوجل لقراءة ملف google-services.json
    id("com.google.gms.google-services")
}

android {
    namespace = "com.example.afietepatientapp"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion
    buildFeatures {
        buildConfig = false  // تعطيل BuildConfig غير المستخدم
    }
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // المعرّف الفريد الخاص بتطبيقك والذي قمت بتسجيله في كونسول Firebase
        applicationId = "com.example.afietepatientapp"
        
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // إعدادات التوقيع لنسخة الإنتاج
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
}