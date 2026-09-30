import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'anonymize/process_text.dart';
import 'anonymize/providers.dart';
import 'app.dart';
import 'preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Every region's date formats, not only the interface languages', so
  // History can write dates the way the phone's region does.
  await initializeDateFormatting();

  final preferences = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(preferences)],
      child: const DocudisApp(),
    ),
  );
}

/// Headless entry point for the text-selection menu (ProcessText.kt), used
/// when the app itself is not running: no UI, just the anonymization service
/// on its channel.
@pragma('vm:entry-point')
Future<void> processTextMain() async {
  WidgetsFlutterBinding.ensureInitialized();
  final container = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(
        await SharedPreferences.getInstance(),
      ),
    ],
  );
  ProcessTextHandler.register(container.read(anonymizeServiceProvider));
}
