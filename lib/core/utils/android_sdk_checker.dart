import 'package:flutter/services.dart';
import 'dart:io' show Platform;

class AndroidSDKChecker {
  static const MethodChannel _channel = MethodChannel('android_sdk_checker');
  static int? _cachedSdkVersion;

  /// Returns the Android SDK version, or null if not on Android
  static Future<int?> getAndroidSDKVersion() async {
    if (!Platform.isAndroid) {
      return null;
    }

    if (_cachedSdkVersion != null) {
      return _cachedSdkVersion;
    }

    try {
      final int version = await _channel.invokeMethod('getSDKVersion');
      _cachedSdkVersion = version;
      return version;
    } on PlatformException catch (e) {
      print("Failed to get Android SDK version: '${e.message}'.");
      return null;
    }
  }

  /// Returns true if running on Android SDK 36 (API level 36) or higher
  static Future<bool> isAndroidSDK36OrHigher() async {
    final sdkVersion = await getAndroidSDKVersion();
    return sdkVersion != null && sdkVersion >= 36;
  }
}

/* 
ANDROID SETUP REQUIRED:

1. Create file: android/app/src/main/kotlin/com/yourcompany/yourapp/MainActivity.kt
   (or modify existing MainActivity)

2. Add this code:

package com.yourcompany.yourapp

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.os.Build

class MainActivity: FlutterActivity() {
    private val CHANNEL = "android_sdk_checker"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
            call, result ->
            if (call.method == "getSDKVersion") {
                result.success(Build.VERSION.SDK_INT)
            } else {
                result.notImplemented()
            }
        }
    }
}

3. Make sure your MainActivity.kt is referenced in AndroidManifest.xml:
   <activity android:name=".MainActivity" ...>
*/
