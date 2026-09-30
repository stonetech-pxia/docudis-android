package com.stonetech.docudis

import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.util.concurrent.Executors

class MainActivity : FlutterActivity() {
    private val executor = Executors.newSingleThreadExecutor()
    private val mainHandler = Handler(Looper.getMainLooper())
    private val sharedInput = SharedInput()

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        ModelAssets.register(this, flutterEngine, executor, mainHandler)
        AiApps.register(this, flutterEngine)
        ProcessText.attachApp(flutterEngine)
        sharedInput.attach(flutterEngine)
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        sharedInput.handle(this, intent, executor, mainHandler)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        sharedInput.handle(this, intent, executor, mainHandler)
    }

    override fun onDestroy() {
        sharedInput.detach()
        ProcessText.detachApp()
        executor.shutdown()
        super.onDestroy()
    }
}

/**
 * Streams large Android assets (the NER model from the install-time asset
 * pack, or the debug source set) to files without loading them into memory.
 * Flutter's rootBundle cannot see asset-pack assets and reads whole files
 * into Dart memory, which is what this replaces.
 */
object ModelAssets {
    private const val CHANNEL = "com.stonetech.docudis/model_assets"

    fun register(
        context: Context,
        engine: FlutterEngine,
        executor: java.util.concurrent.ExecutorService,
        mainHandler: Handler,
    ) {
        val assets = context.assets
        MethodChannel(engine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            val asset = call.argument<String>("asset")
            if (asset == null) {
                result.error("bad_args", "asset is required", null)
                return@setMethodCallHandler
            }
            when (call.method) {
                // Uncompressed length, or -1 when the asset is stored compressed.
                "length" -> {
                    val length = try {
                        assets.openFd(asset).use { it.length }
                    } catch (e: Exception) {
                        -1L
                    }
                    result.success(length)
                }
                "readString" -> {
                    try {
                        assets.open(asset).bufferedReader().use { result.success(it.readText()) }
                    } catch (e: Exception) {
                        result.error("not_found", e.message, null)
                    }
                }
                // Copies asset -> dest through a 1 MB buffer on a worker thread,
                // writing to dest.part and renaming so a present file is complete.
                "copy" -> {
                    val dest = call.argument<String>("dest")
                    if (dest == null) {
                        result.error("bad_args", "dest is required", null)
                        return@setMethodCallHandler
                    }
                    executor.execute {
                        try {
                            val target = File(dest)
                            target.parentFile?.mkdirs()
                            val part = File("$dest.part")
                            var copied = 0L
                            assets.open(asset).use { input ->
                                part.outputStream().buffered(1 shl 20).use { output ->
                                    val buffer = ByteArray(1 shl 20)
                                    while (true) {
                                        val n = input.read(buffer)
                                        if (n < 0) break
                                        output.write(buffer, 0, n)
                                        copied += n
                                    }
                                }
                            }
                            if (target.exists()) target.delete()
                            if (!part.renameTo(target)) throw IllegalStateException("rename failed for $dest")
                            mainHandler.post { result.success(copied) }
                        } catch (e: Exception) {
                            mainHandler.post { result.error("copy_failed", e.message, null) }
                        }
                    }
                }
                else -> result.notImplemented()
            }
        }
    }
}
