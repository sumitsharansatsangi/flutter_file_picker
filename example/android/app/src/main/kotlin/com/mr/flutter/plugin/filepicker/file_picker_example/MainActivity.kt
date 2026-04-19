package com.mr.flutter.plugin.filepicker.file_picker_example

import android.os.Build
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
	override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
		super.configureFlutterEngine(flutterEngine)

		MethodChannel(
			flutterEngine.dartExecutor.binaryMessenger,
			"com.mr.flutter.plugins.filepicker/android_saf_support",
		).setMethodCallHandler { call, result ->
			when (call.method) {
				"getSdkInt" -> result.success(Build.VERSION.SDK_INT)
				else -> result.notImplemented()
			}
		}
	}
}
