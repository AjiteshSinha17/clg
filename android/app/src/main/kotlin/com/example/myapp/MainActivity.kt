package com.example.myapp

import android.net.Uri
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "content_uri_reader"
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "readBytes" -> {
                    val uriString = call.argument<String>("uri")
                    if (uriString.isNullOrBlank()) {
                        result.error("ARG_ERROR", "Missing 'uri' argument", null)
                        return@setMethodCallHandler
                    }

                    try {
                        val uri = Uri.parse(uriString)
                        val input = contentResolver.openInputStream(uri)
                        if (input == null) {
                            result.error("OPEN_FAILED", "Could not open input stream", null)
                            return@setMethodCallHandler
                        }
                        val bytes = input.use { it.readBytes() }
                        result.success(bytes)
                    } catch (e: Exception) {
                        result.error("READ_FAILED", e.message, null)
                    }
                }

                else -> result.notImplemented()
            }
        }
    }
}
