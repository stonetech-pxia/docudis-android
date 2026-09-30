// Renders every Clay screen with the real fonts and sample data and writes
// PNGs to test/goldens/. Run with `flutter test --update-goldens
// test/clay_screens_test.dart` to refresh them; without the flag it checks
// the screens still match.
import 'dart:io';

import 'package:docudis/anonymize/ai_apps.dart';
import 'package:docudis/anonymize/anonymize_service.dart';
import 'package:docudis/anonymize/input/text_extractor.dart';
import 'package:docudis/anonymize/manual_blocks.dart';
import 'package:docudis/anonymize/model/model_locator.dart';
import 'package:docudis/anonymize/providers.dart';
import 'package:docudis/anonymize/shared_input.dart';
import 'package:docudis/anonymize/storage/anonymization_record.dart';
import 'package:docudis/anonymize/storage/record_store.dart';
import 'package:docudis/anonymize/ui/history_page.dart';
import 'package:docudis/anonymize/input/input_source.dart';
import 'package:docudis/anonymize/ui/protect_page.dart';
import 'package:docudis/anonymize/ui/restore_page.dart';
import 'package:docudis/anonymize/ui/result_page.dart';
import 'package:docudis/anonymize/ui/review_page.dart';
import 'package:docudis/home/account_page.dart';
import 'package:docudis/home/app_locale.dart';
import 'package:docudis/home/dictionary_page.dart';
import 'package:docudis/home/home_page.dart';
import 'package:docudis/l10n/app_localizations.dart';
import 'package:docudis/preferences.dart';
import 'package:docudis/anonymize/output/document_redaction.dart';
import 'package:docudis/anonymize/share_service.dart';
import 'package:docudis/theme/clay_theme.dart';
import 'package:docudis/theme/clay_widgets.dart';
import 'package:docudis_engine/docudis_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' hide TextInput;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _original =
    'Hi Sarah Meyer, following our call on 12 March 2026, please find '
    'the invoice for €4,200. You can reach me at s.meyer@acme.com or '
    '+33 6 12 34 56 78. Payment to FR76 3000 6000 0112 3456 7890 189.\n\n'
    'Best regards,\nJonas Weber · Acme GmbH\n14 Rue de Rivoli, 75001 Paris';

Detection _d(
  String value,
  EntityType type,
  double confidence, {
  bool enabled = true,
}) {
  final start = _original.indexOf(value);
  return Detection(
    type: type,
    value: value,
    start: start,
    end: start + value.length,
    confidence: confidence,
    detector: 'test',
    source: DetectionSource.model,
    enabled: enabled,
  );
}

final _detections = [
  _d('Sarah Meyer', EntityType.person, 0.97),
  _d('12 March 2026', EntityType.date, 0.9),
  _d('€4,200', EntityType.amount, 0.88),
  _d('s.meyer@acme.com', EntityType.email, 1),
  _d('+33 6 12 34 56 78', EntityType.phone, 0.95),
  _d('FR76 3000 6000 0112 3456 7890 189', EntityType.iban, 1),
  _d('Jonas Weber', EntityType.person, 0.96),
  _d('Acme GmbH', EntityType.company, 0.8, enabled: false),
  _d('14 Rue de Rivoli, 75001 Paris', EntityType.address, 0.85),
];

RecordDetail _detail({
  String outputPath = 'unused',
  RecordDocument? document,
  bool listOnly = false,
}) {
  final result = anonymize(_original, _detections);
  final enabled = _detections.where((d) => d.enabled).length;
  final record = AnonymizationRecord(
    id: 'r1',
    createdAt: DateTime(2026, 9, 16, 14, 20),
    updatedAt: DateTime(2026, 9, 16, 14, 20),
    kind: InputKind.file,
    sourceName: 'Contract_Meyer.docx',
    outputFileName: 'Contract_Meyer-anonymized.txt',
    detectionCount: enabled,
    preview: result.text.replaceAll('\n', ' '),
    listOnly: listOnly,
  );
  return RecordDetail(
    record: record,
    original: _original,
    output: result.text,
    detections: _detections,
    map: result.map,
    outputPath: outputPath,
    document: document,
  );
}

List<AnonymizationRecord> _records(RecordDetail d) => [
  d.record,
  AnonymizationRecord(
    id: 'r2',
    createdAt: DateTime(2026, 9, 15, 9, 5),
    updatedAt: DateTime(2026, 9, 15, 9, 5),
    kind: InputKind.text,
    sourceName: null,
    outputFileName: 'docudis-20260915-0905.txt',
    detectionCount: 3,
    preview:
        'Dear [PERSON_1], your order [ID_1] ships to [ADDRESS_1] on Monday.',
  ),
  AnonymizationRecord(
    id: 'r3',
    createdAt: DateTime(2026, 9, 12, 18, 40),
    updatedAt: DateTime(2026, 9, 12, 18, 40),
    kind: InputKind.image,
    sourceName: null,
    outputFileName: 'docudis-20260912-1840.txt',
    detectionCount: 6,
    preview: '[COMPANY_1] · Invoice [ID_1] · Total [AMOUNT_1]',
  ),
];

/// No model, no disk: restore works from the in-memory map, and every input
/// becomes [detail]'s record.
class _FakeService extends AnonymizeService {
  _FakeService(this.detail)
    : super(
        store: RecordStore(),
        extractor: TextExtractor(),
        modelLocator: ModelLocator(),
        dictionaryTerms: () async => const [],
        neverHideTerms: () async => const [],
        listOnly: () => false,
      );

  final RecordDetail detail;

  /// What was run, oldest first.
  final processed = <InputSource>[];

  @override
  Future<void> warmUp() async {}

  @override
  Future<AnonymizationRecord> process(InputSource source) async {
    processed.add(source);
    return detail.record;
  }

  @override
  Future<String> restore(String id, String text) async =>
      detail.map.restore(text);
}

/// A file its extractor cannot read.
class _UnreadableService extends _FakeService {
  _UnreadableService(super.detail);

  @override
  Future<AnonymizationRecord> process(InputSource source) async {
    processed.add(source);
    throw const UnsupportedInputException('empty');
  }
}

class _Dictionary extends DictionaryNotifier {
  @override
  Future<List<String>> read() async => const ['Sarah Meyer', 'Acme GmbH'];
}

class _NeverHide extends NeverHideNotifier {
  @override
  Future<List<String>> read() async => const ['Leeds City Council'];
}

/// Records what the result page hands to the share sheet.
class _Share extends ShareService {
  final shared = <({String name, String mimeType})>[];

  @override
  Future<void> shareFile(
    String path,
    String fileName, {
    String mimeType = 'text/plain',
  }) async => shared.add((name: fileName, mimeType: mimeType));
}

/// Records what the result page hands to an AI app.
class _Ai extends AiAppService {
  final sent = <({String app, String name, String mimeType})>[];

  @override
  Future<bool> sendFile(
    AiApp app,
    String path,
    String fileName, {
    String mimeType = 'text/plain',
  }) async {
    sent.add((app: app.label, name: fileName, mimeType: mimeType));
    return true;
  }
}

Future<void> _loadFonts() async {
  Future<void> load(String family, List<String> assets) async {
    final loader = FontLoader(family);
    for (final a in assets) {
      loader.addFont(rootBundle.load(a));
    }
    await loader.load();
  }

  await load('Sora', ['assets/fonts/Sora[wght].ttf']);
  await load('Karla', [
    'assets/fonts/Karla[wght].ttf',
    'assets/fonts/Karla-Italic[wght].ttf',
  ]);
  final flutterRoot = Platform.environment['FLUTTER_ROOT'];
  if (flutterRoot != null) {
    final icons = File(
      '$flutterRoot/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
    );
    if (icons.existsSync()) {
      final loader = FontLoader('MaterialIcons')
        ..addFont(icons.readAsBytes().then((b) => ByteData.view(b.buffer)));
      await loader.load();
    }
  }
}

void main() {
  final detail = _detail();

  late SharedPreferences prefs;
  setUpAll(_loadFonts);
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    PackageInfo.setMockInitialValues(
      appName: 'Docudis',
      packageName: 'com.stonetech.docudis',
      version: '1.0.0',
      buildNumber: '1',
      buildSignature: '',
    );
  });

  Widget app(
    Widget home, {
    RecordDetail? shown,
    ShareService? share,
    AiAppService? ai,
    AnonymizeService? service,
  }) => ProviderScope(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
      anonymizeServiceProvider.overrideWithValue(
        service ?? _FakeService(detail),
      ),
      recordsProvider.overrideWith((ref) async => _records(detail)),
      recordDetailProvider.overrideWith((ref, id) async => shown ?? detail),
      replyMatcherProvider.overrideWith(
        (ref) async => ReplyMatcher({
          'r1': ReplyCandidate(output: detail.output, map: detail.map),
        }),
      ),
      if (share != null) shareServiceProvider.overrideWithValue(share),
      if (ai != null) aiAppServiceProvider.overrideWithValue(ai),
      installedAiAppsProvider.overrideWith(
        (ref) async => [
          AiApp.chatgpt,
          AiApp.claude,
          AiApp.gemini,
          AiApp.perplexity,
          AiApp.deepseek,
        ],
      ),
      dictionaryProvider.overrideWith(_Dictionary.new),
      neverHideProvider.overrideWith(_NeverHide.new),
      revealedBlocksProvider.overrideWith(
        (ref) async => const [
          ManualBlock(value: 'Deposit Protection Service', documents: 2),
        ],
      ),
      manualBlocksProvider.overrideWith(
        (ref) async => const [
          ManualBlock(value: '14 Rue de Rivoli', documents: 2),
          ManualBlock(value: 'Jonas Weber', documents: 1),
          ManualBlock(value: 'Projet Atlas', documents: 1),
        ],
      ),
    ],
    child: Consumer(
      builder: (context, ref, _) => MaterialApp(
        theme: clayTheme(),
        locale: ref.watch(appLocaleProvider),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: home,
      ),
    ),
  );

  Future<void> shoot(WidgetTester tester, Widget home, String name) async {
    tester.view.physicalSize = const Size(780, 1688);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(app(home));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/$name.png'),
    );
  }

  Widget home(Widget page) => Scaffold(
    body: page,
    bottomNavigationBar: ClayNavBar(
      index: 0,
      onChanged: (_) {},
      items: const [
        (Icons.verified_user_outlined, 'Protect'),
        (Icons.history_rounded, 'History'),
        (Icons.person_outline_rounded, 'Account'),
      ],
    ),
  );

  testWidgets('home', (tester) async {
    await shoot(tester, home(const ProtectPage()), 'home');
  });

  testWidgets('"Scan a photo" offers the camera or the photo library', (
    tester,
  ) async {
    await tester.pumpWidget(app(home(const ProtectPage())));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Scan a photo'));
    await tester.pumpAndSettle();
    expect(find.text('Take a photo'), findsOneWidget);
    expect(find.text('Choose from library'), findsOneWidget);
  });

  testWidgets('home with pasted text staged', (tester) async {
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async =>
          call.method == 'Clipboard.getData' ? {'text': _original} : null,
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );
    tester.view.physicalSize = const Size(780, 1688);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(app(home(const ProtectPage())));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Paste text'));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/home_paste.png'),
    );
  });

  testWidgets('home with a file staged', (tester) async {
    await shoot(
      tester,
      home(
        const ProtectPage(
          initialStaged: FileInput(path: 'unused', name: 'Contract_Meyer.docx'),
        ),
      ),
      'home_file',
    );
  });

  /// Another app shares [item] once, as SharedInput.kt / SharedInbox.swift would.
  void share(WidgetTester tester, Map<String, String> item) {
    Map<String, String>? pending = item;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SharedInputNotifier.channel,
      (call) async {
        final out = pending;
        pending = null;
        return out;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SharedInputNotifier.channel,
        null,
      ),
    );
  }

  testWidgets('a document shared from another app is anonymized at once', (
    tester,
  ) async {
    final service = _FakeService(detail);
    share(tester, {'path': '/tmp/unused', 'name': 'Contract_Meyer.pdf'});
    await tester.pumpWidget(app(home(const ProtectPage()), service: service));
    await tester.pumpAndSettle();
    expect(
      service.processed.single,
      isA<FileInput>().having((f) => f.name, 'name', 'Contract_Meyer.pdf'),
    );
    expect(find.byType(ResultPage), findsOneWidget);
  });

  testWidgets(
    'a shared document that cannot be read stays on the page, with the reason',
    (tester) async {
      final service = _UnreadableService(detail);
      share(tester, {'path': '/tmp/unused', 'name': 'scan.pdf'});
      await tester.pumpWidget(app(home(const ProtectPage()), service: service));
      await tester.pumpAndSettle();
      expect(service.processed, hasLength(1));
      expect(find.byType(ResultPage), findsNothing);
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('scan.pdf'), findsOneWidget);
      expect(find.text('Anonymize'), findsOneWidget);
    },
  );

  testWidgets(
    'a document shared while another tab is open ends on its result, then on Protect',
    (tester) async {
      final service = _FakeService(detail);
      await tester.pumpWidget(app(const HomePage(), service: service));
      await tester.pumpAndSettle();
      await tester.tap(
        find.descendant(
          of: find.byType(ClayNavBar),
          matching: find.text('History'),
        ),
      );
      await tester.pumpAndSettle();

      share(tester, {'path': '/tmp/unused', 'name': 'Contract_Meyer.pdf'});
      await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
        SharedInputNotifier.channel.name,
        SharedInputNotifier.channel.codec.encodeMethodCall(
          const MethodCall('available'),
        ),
        (_) {},
      );
      await tester.pumpAndSettle();
      expect(service.processed, hasLength(1));
      expect(find.byType(ResultPage), findsOneWidget);

      tester.state<NavigatorState>(find.byType(Navigator)).pop();
      await tester.pumpAndSettle();
      expect(tester.widget<ClayNavBar>(find.byType(ClayNavBar)).index, 0);
      expect(find.text('Anonymize'), findsNothing);
    },
  );

  testWidgets('shared text is anonymized at once too', (tester) async {
    final service = _FakeService(detail);
    share(tester, {'text': 'Call Jonas Weber'});
    await tester.pumpWidget(app(home(const ProtectPage()), service: service));
    await tester.pumpAndSettle();
    expect(
      service.processed.single,
      isA<TextInput>().having((t) => t.text, 'text', 'Call Jonas Weber'),
    );
    expect(find.byType(ResultPage), findsOneWidget);
  });

  testWidgets('a shared file of another type is refused', (tester) async {
    share(tester, {'path': '/tmp/unused', 'name': 'budget.xlsx'});
    await tester.pumpWidget(app(home(const ProtectPage())));
    await tester.pumpAndSettle();
    expect(find.text('budget.xlsx'), findsNothing);
    expect(find.byType(SnackBar), findsOneWidget);
  });

  testWidgets('result anonymized', (tester) async {
    await shoot(tester, const ResultPage(recordId: 'r1'), 'result');
  });

  testWidgets('result, other AI apps sheet', (tester) async {
    tester.view.physicalSize = const Size(780, 1688);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(app(const ResultPage(recordId: 'r1')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Other'));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/result_other_apps.png'),
    );
  });

  testWidgets('result original', (tester) async {
    tester.view.physicalSize = const Size(780, 1688);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(app(const ResultPage(recordId: 'r1')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Original'));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/result_original.png'),
    );
  });

  testWidgets('a record made from the list alone says so, on both tabs', (
    tester,
  ) async {
    const note =
        'Only your Always hide list was applied. Nothing else was checked: '
        'read the text before you send it.';
    await tester.pumpWidget(app(const ResultPage(recordId: 'r1')));
    await tester.pumpAndSettle();
    expect(find.text(note), findsNothing);

    await tester.pumpWidget(const SizedBox()); // a fresh ProviderScope below
    await tester.pumpWidget(
      app(const ResultPage(recordId: 'r1'), shown: _detail(listOnly: true)),
    );
    await tester.pumpAndSettle();
    expect(find.text(note), findsOneWidget);
    await tester.tap(find.text('Original'));
    await tester.pumpAndSettle();
    expect(find.text(note), findsOneWidget);
  });

  testWidgets('review', (tester) async {
    await shoot(tester, const ReviewPage(recordId: 'r1'), 'review');
  });

  testWidgets('restore', (tester) async {
    tester.view.physicalSize = const Size(780, 1688);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(app(const RestorePage(recordId: 'r1')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byType(TextField),
      'Dear [PERSON_1], thank you for the invoice of [AMOUNT_1]. We will '
      'transfer the payment to [IBAN_1] within 14 days and confirm by email '
      'to [email_1]. Kind regards, [PERSON_2]',
    );
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/restore.png'),
    );
  });

  testWidgets('history', (tester) async {
    await shoot(tester, const HistoryPage(), 'history');
  });

  testWidgets('account: rows that say where things stand', (tester) async {
    await shoot(tester, home(const AccountPage()), 'account');
    expect(
      find.text(
        'Your latest 100 documents are kept on this device. This deletes them.',
      ),
      findsOneWidget,
    );
    expect(find.text('2 words · 3 suggestions'), findsOneWidget);
    expect(find.text('System default'), findsOneWidget);
  });

  testWidgets('account: "Always hide" says when only the list is hidden', (
    tester,
  ) async {
    await prefs.setBool('list_only', true);
    await tester.pumpWidget(app(home(const AccountPage())));
    await tester.pumpAndSettle();
    expect(find.text('2 words · only these are hidden'), findsOneWidget);
  });

  testWidgets('account: "Always hide" opens the custom dictionary', (
    tester,
  ) async {
    await tester.pumpWidget(app(home(const AccountPage())));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Always hide'));
    await tester.pumpAndSettle();
    expect(find.byType(DictionaryPage), findsOneWidget);
  });

  testWidgets(
    'account: picking a language switches the interface and is remembered',
    (tester) async {
      await tester.pumpWidget(app(home(const AccountPage())));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Language'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Français'));
      await tester.pumpAndSettle();
      expect(find.text('Langue'), findsOneWidget);
      expect(find.text('Français'), findsOneWidget);
      expect(prefs.getString('app_locale'), 'fr');

      await tester.tap(find.text('Langue'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Langue du système'));
      await tester.pumpAndSettle();
      expect(find.text('Language'), findsOneWidget);
      expect(prefs.getString('app_locale'), isNull);
    },
  );

  testWidgets('account: Español is offered', (tester) async {
    await tester.pumpWidget(app(home(const AccountPage())));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Language'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Español'));
    await tester.pumpAndSettle();
    expect(find.text('Idioma'), findsOneWidget);
    expect(find.text('Política de privacidad'), findsOneWidget);
    expect(prefs.getString('app_locale'), 'es');
  });

  testWidgets('custom dictionary', (tester) async {
    await shoot(tester, const DictionaryPage(), 'dictionary');
  });

  group('redacted files are free', () {
    late Directory dir;
    late RecordDetail docx;
    late _Share share;

    setUp(() async {
      dir = await Directory.systemTemp.createTemp('docudis_gate');
      final txt = File('${dir.path}/output.txt')..writeAsStringSync('text');
      final redacted = File('${dir.path}/redacted.docx')
        ..writeAsStringSync('docx');
      docx = _detail(
        outputPath: txt.path,
        document: RecordDocument(
          kind: DocumentKind.docx,
          sourcePath: 'unused',
          redactedPath: redacted.path,
        ),
      );
      share = _Share();
    });
    tearDown(() => dir.delete(recursive: true));

    Future<void> tapShare(WidgetTester tester) async {
      await tester.runAsync(() async {
        await tester.tap(find.text('Share file'));
        await Future<void>.delayed(const Duration(milliseconds: 200));
      });
      await tester.pumpAndSettle();
    }

    testWidgets('every record goes out as the file, including repeatedly', (
      tester,
    ) async {
      await tester.pumpWidget(
        app(
          const ResultPage(recordId: 'r1'),
          shown: docx,
          share: share,
        ),
      );
      await tester.pumpAndSettle();
      await tapShare(tester);
      await tapShare(tester);
      expect(share.shared.map((s) => s.name), [
        'Anonymized document.docx',
        'Anonymized document.docx',
      ]);
    });

    testWidgets('an AI app gets the redacted file', (tester) async {
      final ai = _Ai();
      await tester.pumpWidget(
        app(
          const ResultPage(recordId: 'r1'),
          shown: docx,
          ai: ai,
        ),
      );
      await tester.pumpAndSettle();

      await tester.runAsync(() async {
        await tester.tap(find.byTooltip('Send to ChatGPT'));
        await Future<void>.delayed(const Duration(milliseconds: 200));
      });
      await tester.pumpAndSettle();
      expect(ai.sent.single, (
        app: 'ChatGPT',
        name: 'Anonymized document.docx',
        mimeType: 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
      ));
    });
  });
}
