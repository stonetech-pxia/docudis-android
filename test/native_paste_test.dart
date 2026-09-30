// iOS path of the home page's paste entries: the system paste button
// (UIPasteControl, ios/Runner/PasteControl.swift) replaces Clipboard.getData,
// which makes iOS ask "Allow Paste?" on every tap. The native side is faked
// here: platform view creation is acknowledged and "paste" is sent the way
// PasteControl.swift sends it.
import 'package:docudis/anonymize/anonymize_service.dart';
import 'package:docudis/anonymize/input/input_source.dart';
import 'package:docudis/anonymize/input/text_extractor.dart';
import 'package:docudis/anonymize/model/model_locator.dart';
import 'package:docudis/anonymize/providers.dart';
import 'package:docudis/anonymize/storage/record_store.dart';
import 'package:docudis/anonymize/ui/native_paste_button.dart';
import 'package:docudis/anonymize/ui/protect_page.dart';
import 'package:docudis/l10n/app_localizations.dart';
import 'package:docudis/theme/clay_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _NoModel extends AnonymizeService {
  _NoModel()
    : super(
        store: RecordStore(),
        extractor: TextExtractor(),
        modelLocator: ModelLocator(),
        dictionaryTerms: () async => const [],
        neverHideTerms: () async => const [],
        listOnly: () => false,
      );

  @override
  Future<void> warmUp() async {}
}

void main() {
  late List<int> views;

  Widget app({InputSource? staged}) => ProviderScope(
    overrides: [
      anonymizeServiceProvider.overrideWithValue(_NoModel()),
    ],
    child: MaterialApp(
      theme: clayTheme(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: ProtectPage(initialStaged: staged),
    ),
  );

  /// What PasteControl.swift does after a tap on the control.
  Future<void> nativePaste(WidgetTester tester, int view, String text) async {
    await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
      '${NativePasteButton.viewType}/$view',
      const StandardMethodCodec().encodeMethodCall(MethodCall('paste', text)),
      (_) {},
    );
    await tester.pumpAndSettle();
  }

  final ios = TargetPlatformVariant.only(TargetPlatform.iOS);

  setUp(() => views = []);

  Future<void> start(WidgetTester tester, {InputSource? staged}) async {
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform_views,
      (call) async {
        if (call.method == 'create') {
          views.add((call.arguments as Map)['id'] as int);
        }
        return null;
      },
    );
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async => call.method == 'Clipboard.getData'
          ? fail('iOS must not read the clipboard directly')
          : null,
    );
    addTearDown(() {
      tester.binding.defaultBinaryMessenger
        ..setMockMethodCallHandler(SystemChannels.platform_views, null)
        ..setMockMethodCallHandler(SystemChannels.platform, null);
    });
    await tester.pumpWidget(app(staged: staged));
    await tester.pumpAndSettle();
  }

  testWidgets(
    'the paste card is the system paste button and stages what it pastes',
    (tester) async {
      await start(tester);
      expect(find.byType(NativePasteButton), findsOneWidget);
      expect(find.text('Paste text'), findsNothing);
      expect(views, hasLength(1));

      await nativePaste(
        tester,
        views.single,
        'Call Jonas Weber on 06 12 34 56 78',
      );
      expect(find.text('Call Jonas Weber on 06 12 34 56 78'), findsOneWidget);
      expect(find.text('Anonymize'), findsOneWidget);
      // Staged: the card is Flutter again (preview, cancel, Anonymize).
      expect(find.byType(NativePasteButton), findsNothing);
    },
    variant: ios,
  );

  testWidgets(
    'with a document staged, the paste chip is the system paste button',
    (tester) async {
      await start(
        tester,
        staged: const FileInput(path: 'unused', name: 'Contract_Meyer.docx'),
      );
      // The collapsed paste card keeps its (hidden) button so it can fade
      // back in; the chip is the one in the row of chips.
      final chip = find.descendant(
        of: find.byType(Wrap),
        matching: find.byType(NativePasteButton),
      );
      expect(chip, findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(Wrap),
          matching: find.text('Scan a photo'),
        ),
        findsOneWidget,
      );
      expect(views, hasLength(2));

      // Views are created in tree order: the card first, then the chip.
      await nativePaste(tester, views.last, 'Payment to FR76 3000 6000');
      expect(find.text('Contract_Meyer.docx').hitTestable(), findsNothing);
      expect(find.text('Payment to FR76 3000 6000'), findsOneWidget);
    },
    variant: ios,
  );

  testWidgets(
    'blank text from the control is refused like an empty clipboard',
    (tester) async {
      await start(tester);
      await nativePaste(tester, views.single, '  \n ');
      expect(find.text('Anonymize'), findsNothing);
      expect(find.byType(NativePasteButton), findsOneWidget);
    },
    variant: ios,
  );
}
