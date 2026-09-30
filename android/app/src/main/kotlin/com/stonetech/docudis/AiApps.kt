package com.stonetech.docudis

import android.content.ActivityNotFoundException
import android.content.Intent
import android.content.pm.PackageManager
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

/**
 * Detects installed AI apps (ChatGPT, Claude, ...) by package name and hands
 * them a file or text with a targeted ACTION_SEND. Packages must be listed in
 * the manifest `<queries>` block or the OS hides them (Android 11+).
 */
object AiApps {
    private const val CHANNEL = "com.stonetech.docudis/ai_apps"

    fun register(activity: FlutterActivity, engine: FlutterEngine) {
        MethodChannel(engine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            val pkg = call.argument<String>("package")
            if (pkg == null) {
                result.error("bad_args", "package is required", null)
                return@setMethodCallHandler
            }
            when (call.method) {
                "isInstalled" -> result.success(isInstalled(activity, pkg))
                "open" -> {
                    val intent = activity.packageManager.getLaunchIntentForPackage(pkg)
                    result.success(intent != null && start(activity, intent))
                }
                "sendText" -> {
                    val text = call.argument<String>("text")
                    if (text == null) {
                        result.error("bad_args", "text is required", null)
                        return@setMethodCallHandler
                    }
                    val intent = Intent(Intent.ACTION_SEND)
                        .setType("text/plain")
                        .putExtra(Intent.EXTRA_TEXT, text)
                        .setPackage(pkg)
                    result.success(start(activity, intent))
                }
                "sendFile" -> {
                    val path = call.argument<String>("path")
                    val mimeType = call.argument<String>("mimeType") ?: "text/plain"
                    if (path == null) {
                        result.error("bad_args", "path is required", null)
                        return@setMethodCallHandler
                    }
                    val uri = try {
                        FileProvider.getUriForFile(activity, "${activity.packageName}.ai_apps", File(path))
                    } catch (e: IllegalArgumentException) {
                        result.error("bad_path", "path is outside the shared directories: $path", null)
                        return@setMethodCallHandler
                    }
                    val intent = Intent(Intent.ACTION_SEND)
                        .setType(mimeType)
                        .putExtra(Intent.EXTRA_STREAM, uri)
                        .setPackage(pkg)
                        .addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                    result.success(start(activity, intent))
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun isInstalled(activity: FlutterActivity, pkg: String): Boolean = try {
        activity.packageManager.getPackageInfo(pkg, 0)
        true
    } catch (e: PackageManager.NameNotFoundException) {
        false
    }

    /** False when the target package has no activity for this intent. */
    private fun start(activity: FlutterActivity, intent: Intent): Boolean = try {
        activity.startActivity(intent)
        true
    } catch (e: ActivityNotFoundException) {
        false
    }
}
