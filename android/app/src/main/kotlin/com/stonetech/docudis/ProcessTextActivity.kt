package com.stonetech.docudis

import android.app.Activity
import android.content.ClipData
import android.content.ClipboardManager
import android.content.Intent
import android.content.res.ColorStateList
import android.graphics.drawable.GradientDrawable
import android.os.Build
import android.os.Bundle
import android.util.Log
import android.view.Gravity
import android.view.ViewGroup.LayoutParams.WRAP_CONTENT
import android.view.WindowManager
import android.widget.FrameLayout
import android.widget.LinearLayout
import android.widget.ProgressBar
import android.widget.TextView
import android.widget.Toast

/**
 * Anonymizes text from outside the app behind a small progress card and acts
 * on it directly, no review. Two ways in:
 *
 * - "Anonymize" in the system text-selection toolbar (ACTION_PROCESS_TEXT):
 *   an editable selection is replaced in place (the caller gets the result
 *   back), a read-only one is copied to the clipboard.
 * - The "Anonymize clipboard" Quick Settings tile ([ACTION_CLIPBOARD]): the
 *   clipboard text is replaced by its anonymized version. Android 10+ only
 *   lets the focused app read the clipboard, so this waits for window focus.
 *
 * The record still goes to the app's history so an AI reply can be restored.
 */
class ProcessTextActivity : Activity() {
    companion object {
        const val ACTION_CLIPBOARD = "com.stonetech.docudis.action.ANONYMIZE_CLIPBOARD"
    }

    private var clipboardRead = false

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        if (intent.action == ACTION_CLIPBOARD) {
            showProgress()
            return // continues in onWindowFocusChanged
        }
        val text = intent.getCharSequenceExtra(Intent.EXTRA_PROCESS_TEXT)?.toString()
        if (text.isNullOrBlank()) {
            finish()
            return
        }
        val readOnly = intent.getBooleanExtra(Intent.EXTRA_PROCESS_TEXT_READONLY, false)
        showProgress()
        anonymize(text) { output -> if (readOnly) copy(output) else replaceSelection(output) }
    }

    override fun onWindowFocusChanged(hasFocus: Boolean) {
        super.onWindowFocusChanged(hasFocus)
        if (!hasFocus || clipboardRead || intent.action != ACTION_CLIPBOARD) return
        clipboardRead = true
        val clip = getSystemService(ClipboardManager::class.java).primaryClip
        val text = clip?.takeIf { it.itemCount > 0 }?.getItemAt(0)?.coerceToText(this)?.toString()
        if (text.isNullOrBlank()) {
            Toast.makeText(this, R.string.clipboard_no_text, Toast.LENGTH_SHORT).show()
            finish()
            return
        }
        anonymize(text, ::copy)
    }

    private fun anonymize(text: String, deliver: (String) -> Unit) {
        ProcessText.anonymize(
            this,
            text,
            onSuccess = { output ->
                if (!isFinishing) {
                    deliver(output)
                    finish()
                }
            },
            onError = { message ->
                Log.w("Docudis", "anonymize from outside the app failed: $message")
                if (!isFinishing) {
                    Toast.makeText(this, R.string.process_text_failed, Toast.LENGTH_SHORT).show()
                    finish()
                }
            },
        )
    }

    private fun replaceSelection(output: String) {
        setResult(RESULT_OK, Intent().putExtra(Intent.EXTRA_PROCESS_TEXT, output))
    }

    private fun copy(output: String) {
        getSystemService(ClipboardManager::class.java)
            .setPrimaryClip(ClipData.newPlainText("Docudis", output))
        // Android 13+ shows its own "Copied" chip.
        if (Build.VERSION.SDK_INT < 33) {
            Toast.makeText(this, R.string.process_text_copied, Toast.LENGTH_SHORT).show()
        }
    }

    /** Clay-styled "Anonymizing…" card, centred over the dimmed caller. */
    private fun showProgress() {
        window.addFlags(WindowManager.LayoutParams.FLAG_DIM_BEHIND)
        window.attributes = window.attributes.apply { dimAmount = 0.3f }
        val dp = resources.displayMetrics.density
        val card = LinearLayout(this).apply {
            orientation = LinearLayout.HORIZONTAL
            gravity = Gravity.CENTER_VERTICAL
            setPadding((24 * dp).toInt(), (20 * dp).toInt(), (24 * dp).toInt(), (20 * dp).toInt())
            background = GradientDrawable().apply {
                cornerRadius = 20 * dp
                setColor(0xFFFFFCF8.toInt()) // Clay.surface
            }
        }
        card.addView(
            ProgressBar(this).apply {
                indeterminateTintList = ColorStateList.valueOf(0xFFC8623A.toInt()) // Clay.primary
            },
            LinearLayout.LayoutParams((28 * dp).toInt(), (28 * dp).toInt()),
        )
        card.addView(
            TextView(this).apply {
                setText(R.string.process_text_working)
                setTextColor(0xFF2A2420.toInt()) // Clay.ink
                textSize = 16f
                setPadding((14 * dp).toInt(), 0, 0, 0)
            },
        )
        setContentView(
            FrameLayout(this).apply {
                addView(card, FrameLayout.LayoutParams(WRAP_CONTENT, WRAP_CONTENT, Gravity.CENTER))
            },
        )
    }
}
