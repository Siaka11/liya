package com.liya.ci

import android.content.Intent
import android.net.Uri
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "phone_call_service"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "makeCall" -> {
                    val number = call.argument<String>("number")
                    if (number != null) {
                        val success = makeCall(number)
                        result.success(success)
                    } else {
                        result.error("INVALID_ARGUMENT", "Numéro de téléphone manquant", null)
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun makeCall(number: String): Boolean {
        return try {
            // Méthode 1: Intent direct avec ACTION_CALL
            val callIntent = Intent(Intent.ACTION_CALL).apply {
                data = Uri.parse("tel:$number")
                flags = Intent.FLAG_ACTIVITY_NEW_TASK
            }
            
            if (callIntent.resolveActivity(packageManager) != null) {
                startActivity(callIntent)
                true
            } else {
                // Méthode 2: Fallback avec ACTION_DIAL
                val dialIntent = Intent(Intent.ACTION_DIAL).apply {
                    data = Uri.parse("tel:$number")
                    flags = Intent.FLAG_ACTIVITY_NEW_TASK
                }
                
                if (dialIntent.resolveActivity(packageManager) != null) {
                    startActivity(dialIntent)
                    true
                } else {
                    false
                }
            }
        } catch (e: Exception) {
            e.printStackTrace()
            false
        }
    }
}
