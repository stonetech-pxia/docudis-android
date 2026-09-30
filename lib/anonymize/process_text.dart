import 'dart:async';

import 'package:flutter/services.dart' hide TextInput;

import 'anonymize_service.dart';
import 'input/input_source.dart';

/// Serves the system text-selection menu ("Anonymize", ProcessTextActivity):
/// anonymizes the selection and hands the result straight back, no UI and
/// no review. The record still goes to history so an AI reply can be
/// restored later.
class ProcessTextHandler {
  static const channel = MethodChannel('com.stonetech.docudis/process_text');

  /// [onDone] runs after each job, e.g. to refresh the history list.
  static void register(AnonymizeService service, {void Function()? onDone}) {
    channel.setMethodCallHandler((call) async {
      if (call.method != 'anonymize') throw MissingPluginException();
      final record = await service.process(TextInput(call.arguments as String));
      onDone?.call();
      return (await service.store.load(record.id)).output;
    });
    // Nothing is listening on iOS, and nothing is waiting for the answer
    // anywhere: the native side only uses `ready` to release queued jobs.
    unawaited(
      channel
          .invokeMethod<void>('ready')
          .onError<MissingPluginException>((_, _) {}),
    );
  }
}
