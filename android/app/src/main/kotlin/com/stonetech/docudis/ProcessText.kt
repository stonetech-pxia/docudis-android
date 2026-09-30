package com.stonetech.docudis

import android.content.Context
import android.os.Handler
import android.os.Looper
import io.flutter.FlutterInjector
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.Executors

/**
 * Runs anonymization for ProcessTextActivity on whichever Flutter engine is
 * available: the app's own while MainActivity is alive, otherwise a headless
 * engine running `processTextMain` (lib/main.dart). The headless engine is
 * created on demand, kept for the next request (the NER model stays loaded)
 * and released as soon as the app itself starts, so the model is never held
 * twice. Calls wait until the Dart side has said `ready`.
 */
object ProcessText {
    private const val CHANNEL = "com.stonetech.docudis/process_text"

    private class Target(engine: FlutterEngine) {
        val channel = MethodChannel(engine.dartExecutor.binaryMessenger, CHANNEL)
        var ready = false
        val queued = mutableListOf<(MethodChannel) -> Unit>()

        init {
            channel.setMethodCallHandler { call, result ->
                if (call.method != "ready") {
                    result.notImplemented()
                    return@setMethodCallHandler
                }
                ready = true
                val jobs = queued.toList()
                queued.clear()
                jobs.forEach { it(channel) }
                result.success(null)
            }
        }

        fun run(job: (MethodChannel) -> Unit) {
            if (ready) job(channel) else queued.add(job)
        }
    }

    private var app: Target? = null
    private var headless: FlutterEngine? = null
    private var headlessTarget: Target? = null
    private val executor = Executors.newSingleThreadExecutor()
    private val mainHandler = Handler(Looper.getMainLooper())

    /** The app engine takes over; the headless one is released. */
    fun attachApp(engine: FlutterEngine) {
        val target = Target(engine)
        headlessTarget?.queued?.let { target.queued.addAll(it) }
        app = target
        headless?.destroy()
        headless = null
        headlessTarget = null
    }

    fun detachApp() {
        app = null
    }

    fun anonymize(
        context: Context,
        text: String,
        onSuccess: (String) -> Unit,
        onError: (String) -> Unit,
    ) {
        val handler = object : MethodChannel.Result {
            override fun success(result: Any?) = onSuccess(result as String)
            override fun error(code: String, message: String?, details: Any?) = onError(message ?: code)
            override fun notImplemented() = onError("anonymize is not implemented")
        }
        val target = app ?: headlessTarget ?: startHeadless(context)
        target.run { it.invokeMethod("anonymize", text, handler) }
    }

    private fun startHeadless(context: Context): Target {
        val engine = FlutterEngine(context.applicationContext)
        ModelAssets.register(context.applicationContext, engine, executor, mainHandler)
        val target = Target(engine)
        headless = engine
        headlessTarget = target
        engine.dartExecutor.executeDartEntrypoint(
            DartExecutor.DartEntrypoint(
                FlutterInjector.instance().flutterLoader().findAppBundlePath(),
                "processTextMain",
            ),
        )
        return target
    }
}
