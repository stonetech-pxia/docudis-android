import 'dart:async';

import 'package:flutter/services.dart' hide TextInput;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'input/input_source.dart';

/// What another app shared to Docudis ("Share" → Docudis): Android's
/// ACTION_SEND or "Open with" ACTION_VIEW (SharedInput.kt) or the iOS Share
/// Extension (ios/ShareExtension, handed over by SharedInbox.swift).
///
/// The platform keeps the latest item until `consume` takes it and calls
/// `available` when a new one arrives. The state is that item until the
/// home tab takes it and calls [taken].
class SharedInputNotifier extends Notifier<InputSource?> {
  static const channel = MethodChannel('com.stonetech.docudis/shared_input');

  @override
  InputSource? build() {
    channel.setMethodCallHandler((call) async {
      if (call.method == 'available') await _pull();
    });
    ref.onDispose(() => channel.setMethodCallHandler(null));
    // An app launched by a share has one waiting already.
    unawaited(_pull());
    return null;
  }

  Future<void> _pull() async {
    final Map<Object?, Object?>? item;
    try {
      item = await channel.invokeMapMethod<Object?, Object?>('consume');
    } on MissingPluginException {
      return; // tests, desktop
    }
    if (item == null) return;
    final text = item['text'] as String?;
    final path = item['path'] as String?;
    if (text != null) {
      state = TextInput(text);
    } else if (path != null) {
      state = FileInput(path: path, name: item['name'] as String? ?? 'shared');
    }
  }

  void taken() => state = null;
}

final sharedInputProvider = NotifierProvider<SharedInputNotifier, InputSource?>(
  SharedInputNotifier.new,
);
