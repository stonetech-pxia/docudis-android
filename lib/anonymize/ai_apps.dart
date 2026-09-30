import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'share_service.dart';

/// Third-party AI assistants the anonymized output can be handed to.
///
/// To add one: append it here, drop its logo in `assets/ai_logos/<name>.svg`,
/// declare its package in the Android manifest `<queries>` block and its URL
/// scheme in the iOS `LSApplicationQueriesSchemes` list. Without those
/// declarations the OS reports the app as not installed.
///
/// The iOS schemes of the non-featured apps are best guesses; they only
/// affect [AiAppService.isInstalled], sending on iOS always goes through the
/// share sheet.
enum AiApp {
  chatgpt(
    'ChatGPT',
    androidPackage: 'com.openai.chatgpt',
    iosScheme: 'chatgpt',
    featured: true,
    monoLogo: true,
  ),
  claude(
    'Claude',
    androidPackage: 'com.anthropic.claude',
    iosScheme: 'claude',
    featured: true,
  ),
  gemini(
    'Gemini',
    androidPackage: 'com.google.android.apps.bard',
    iosScheme: 'googlegemini',
  ),
  grok('Grok', androidPackage: 'ai.x.grok', iosScheme: 'grok', monoLogo: true),
  perplexity(
    'Perplexity',
    androidPackage: 'ai.perplexity.app.android',
    iosScheme: 'perplexity',
  ),
  deepseek(
    'DeepSeek',
    androidPackage: 'com.deepseek.chat',
    iosScheme: 'deepseek',
  ),
  copilot(
    'Copilot',
    androidPackage: 'com.microsoft.copilot',
    iosScheme: 'copilot',
  ),
  kimi(
    'Kimi',
    androidPackage: 'com.moonshot.kimichat',
    iosScheme: 'kimi',
    monoLogo: true,
  ),
  doubao('Doubao', androidPackage: 'com.larus.nova', iosScheme: 'doubao'),
  qwen('Qwen', androidPackage: 'com.aliyun.tongyi', iosScheme: 'tongyi'),
  mistral('Le Chat', androidPackage: 'ai.mistral.chat', iosScheme: 'mistral');

  const AiApp(
    this.label, {
    required this.androidPackage,
    required this.iosScheme,
    this.featured = false,
    this.monoLogo = false,
  });

  /// Brand name, shown as-is on buttons (not localized).
  final String label;
  final String androidPackage;
  final String iosScheme;

  /// Gets its own logo button on the result page; the rest sit in the
  /// "Other" list.
  final bool featured;

  /// The logo is a single-colour glyph and takes the current text colour.
  final bool monoLogo;

  String get logoAsset => 'assets/ai_logos/$name.svg';
}

/// Detects installed AI apps and hands files or text straight to them.
///
/// Android resolves the app by package and delivers with a targeted
/// `ACTION_SEND` intent. iOS can only probe URL schemes and cannot target a
/// specific app with content, so `send*` there falls back to the system share
/// sheet. Other platforms report nothing installed.
class AiAppService {
  AiAppService({this._share = const ShareService()});

  static const channel = MethodChannel('com.stonetech.docudis/ai_apps');

  final ShareService _share;

  bool get _isAndroid => defaultTargetPlatform == TargetPlatform.android;
  bool get _isIOS => defaultTargetPlatform == TargetPlatform.iOS;

  Map<String, String> _target(AiApp app) =>
      _isAndroid ? {'package': app.androidPackage} : {'scheme': app.iosScheme};

  Future<bool> isInstalled(AiApp app) async {
    if (!_isAndroid && !_isIOS) return false;
    return await channel.invokeMethod<bool>('isInstalled', _target(app)) ??
        false;
  }

  /// Installed apps in [AiApp] declaration order; one direct-send button each.
  Future<List<AiApp>> installed() async {
    final result = <AiApp>[];
    for (final app in AiApp.values) {
      if (await isInstalled(app)) result.add(app);
    }
    return result;
  }

  /// Brings the app to the foreground. False when it is not installed.
  Future<bool> open(AiApp app) async {
    if (!_isAndroid && !_isIOS) return false;
    return await channel.invokeMethod<bool>('open', _target(app)) ?? false;
  }

  /// Hands the file (`.txt`, or a redacted PDF, Word file or image) to
  /// [app]. Returns true when it went directly to the app; false when the
  /// system share sheet was shown instead.
  Future<bool> sendFile(
    AiApp app,
    String path,
    String fileName, {
    String mimeType = 'text/plain',
  }) async {
    if (_isAndroid) {
      final direct = await channel.invokeMethod<bool>('sendFile', {
        'package': app.androidPackage,
        'path': path,
        'mimeType': mimeType,
      });
      if (direct ?? false) return true;
    }
    await _share.shareFile(path, fileName, mimeType: mimeType);
    return false;
  }

  /// Same as [sendFile] for plain text.
  Future<bool> sendText(AiApp app, String text) async {
    if (_isAndroid) {
      final direct = await channel.invokeMethod<bool>('sendText', {
        'package': app.androidPackage,
        'text': text,
      });
      if (direct ?? false) return true;
    }
    await _share.shareText(text);
    return false;
  }
}
