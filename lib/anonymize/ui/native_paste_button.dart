import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// iOS's system paste button (UIPasteControl, ios/Runner/PasteControl.swift).
///
/// Clipboard.getData makes iOS ask "Allow Paste?" on every tap; a paste
/// through this control needs no prompt because the user tapped a system
/// button. The label ("Paste", in the phone's language) and its font are
/// the system's, only colours and corners can be set, and the control greys
/// itself out while the clipboard holds no text. Other platforms keep
/// reading the clipboard directly, so callers check [isSupported] first.
///
/// The control fills its parent: iOS draws it out of process and reports no
/// size, so the parent must give it one.
class NativePasteButton extends StatefulWidget {
  const NativePasteButton({
    super.key,
    required this.onText,
    required this.foreground,
    required this.background,
    this.cornerRadius,
  });

  static const viewType = 'com.stonetech.docudis/paste_control';

  static bool get isSupported =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

  /// Called with the pasted text.
  final ValueChanged<String> onText;
  final Color foreground;
  final Color background;

  /// Fixed corner radius; null for a capsule.
  final double? cornerRadius;

  @override
  State<NativePasteButton> createState() => _NativePasteButtonState();
}

class _NativePasteButtonState extends State<NativePasteButton> {
  MethodChannel? _channel;

  void _created(int id) {
    final channel = MethodChannel('${NativePasteButton.viewType}/$id');
    _channel = channel;
    channel.setMethodCallHandler((call) async {
      if (call.method == 'paste' && call.arguments is String) {
        widget.onText(call.arguments as String);
      }
    });
  }

  @override
  void dispose() {
    _channel?.setMethodCallHandler(null);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => UiKitView(
    viewType: NativePasteButton.viewType,
    creationParams: {
      'foreground': widget.foreground.toARGB32(),
      'background': widget.background.toARGB32(),
      'cornerRadius': widget.cornerRadius,
    },
    creationParamsCodec: const StandardMessageCodec(),
    onPlatformViewCreated: _created,
    // The control must see the whole tap itself, with nothing in Flutter
    // competing for it: iOS only pastes for a genuine tap on the control.
    gestureRecognizers: {
      Factory<OneSequenceGestureRecognizer>(EagerGestureRecognizer.new),
    },
  );
}
