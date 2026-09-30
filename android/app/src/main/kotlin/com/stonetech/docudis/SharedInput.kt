package com.stonetech.docudis

import android.app.Activity
import android.content.ContentResolver
import android.content.Intent
import android.net.Uri
import android.os.Handler
import android.provider.OpenableColumns
import android.util.Log
import android.webkit.MimeTypeMap
import androidx.core.content.IntentCompat
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.util.concurrent.ExecutorService

/**
 * What other apps share to Docudis (ACTION_SEND) or open with it
 * (ACTION_VIEW), see the manifest: a document, an image or, shared only,
 * plain text. A shared file is copied into the cache
 * straight away, while the sender's read grant lasts. The latest item waits
 * here until Dart takes it with `consume`; `available` tells Dart one came.
 * One per MainActivity (and so per Flutter engine).
 */
class SharedInput {
    private companion object {
        const val CHANNEL = "com.stonetech.docudis/shared_input"
        const val TAG = "SharedInput"
    }

    private var channel: MethodChannel? = null
    private var pending: Map<String, String>? = null

    fun attach(engine: FlutterEngine) {
        channel = MethodChannel(engine.dartExecutor.binaryMessenger, CHANNEL).apply {
            setMethodCallHandler { call, result ->
                when (call.method) {
                    "consume" -> {
                        result.success(pending)
                        pending = null
                    }
                    else -> result.notImplemented()
                }
            }
        }
    }

    fun detach() {
        channel?.setMethodCallHandler(null)
        channel = null
    }

    /** Takes in [intent] when it is a share or an "Open with"; anything else is ignored. */
    fun handle(activity: Activity, intent: Intent?, executor: ExecutorService, mainHandler: Handler) {
        if (intent == null) return
        val stream = when (intent.action) {
            Intent.ACTION_SEND -> IntentCompat.getParcelableExtra(intent, Intent.EXTRA_STREAM, Uri::class.java)
            // "Open with" names the file in the data, never text.
            Intent.ACTION_VIEW -> intent.data ?: return
            else -> return
        }
        // Handled once: a recreated activity gets the same intent again.
        intent.action = null
        if (stream != null) {
            if (!isReadable(activity, stream)) return
            val type = intent.type
            executor.execute {
                val item = try {
                    copy(activity, stream, type)
                } catch (e: Exception) {
                    Log.w(TAG, "shared file could not be read", e)
                    null
                }
                if (item != null) mainHandler.post { deliver(item) }
            }
            return
        }
        val text = intent.getCharSequenceExtra(Intent.EXTRA_TEXT)?.toString()
        if (!text.isNullOrBlank()) deliver(mapOf("text" to text))
    }

    /**
     * Only content from other apps: a `file:` URI or one of our own
     * providers would let a sender make us read our private files (records)
     * and stage them for sharing.
     */
    private fun isReadable(activity: Activity, uri: Uri): Boolean {
        if (uri.scheme != ContentResolver.SCHEME_CONTENT) return false
        val authority = uri.authority ?: return false
        return authority != activity.packageName && !authority.startsWith("${activity.packageName}.")
    }

    private fun copy(activity: Activity, uri: Uri, type: String?): Map<String, String> {
        val name = displayName(activity, uri, type)
        val dir = File(activity.cacheDir, "shared/${System.currentTimeMillis()}")
        dir.mkdirs()
        val target = File(dir, name)
        activity.contentResolver.openInputStream(uri).use { input ->
            requireNotNull(input) { "no stream for $uri" }
            target.outputStream().use { input.copyTo(it) }
        }
        return mapOf("path" to target.path, "name" to name)
    }

    /** The sender's file name, with an extension from [type] when it has none. */
    private fun displayName(activity: Activity, uri: Uri, type: String?): String {
        var name = activity.contentResolver
            .query(uri, arrayOf(OpenableColumns.DISPLAY_NAME), null, null, null)
            ?.use { c -> if (c.moveToFirst()) c.getString(0) else null }
            ?: uri.lastPathSegment
            ?: "shared"
        name = name.substringAfterLast('/').replace(Regex("[\\\\:*?\"<>|]"), "_").ifBlank { "shared" }
        if (!name.contains('.')) {
            val ext = type?.let { MimeTypeMap.getSingleton().getExtensionFromMimeType(it) }
            if (ext != null) name = "$name.$ext"
        }
        return name
    }

    private fun deliver(item: Map<String, String>) {
        pending = item
        channel?.invokeMethod("available", null)
    }
}
