// Renders the Play Store screenshots (1080×1920) and feature graphic
// (1024×500) for one store language to test/goldens/store/<lang>/.
// Each language has its own *_test.dart entry point because the zh run loads
// different fonts, and fonts cannot be unloaded within one test process.
// Refresh with `flutter test --update-goldens test/store`, then run
// design/store/export_play_assets.py for the upload-ready (no alpha) copies.
// The headline copy mirrors docs/store/listing.md.
//
// Fonts: placeholders use DejaVu Sans Mono from test/fonts/. The test engine
// has no system font fallback, so CJK glyphs never reach Sora / Karla the way
// they do on a phone; the zh run loads Noto Sans SC under both family names
// instead (from $NOTO_SANS_SC or C:/Windows/Fonts) and is skipped without it.
import 'dart:io';

import 'package:docudis/anonymize/ai_apps.dart';
import 'package:docudis/anonymize/anonymize_service.dart';
import 'package:docudis/anonymize/input/text_extractor.dart';
import 'package:docudis/anonymize/model/model_locator.dart';
import 'package:docudis/anonymize/providers.dart';
import 'package:docudis/anonymize/storage/anonymization_record.dart';
import 'package:docudis/anonymize/storage/record_store.dart';
import 'package:docudis/anonymize/ui/protect_page.dart';
import 'package:docudis/anonymize/ui/result_page.dart';
import 'package:docudis/l10n/app_localizations.dart';
import 'package:docudis/theme/clay_theme.dart';
import 'package:docudis/theme/clay_widgets.dart';
import 'package:docudis_engine/docudis_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// One sample document per store language, with what the app hides in it
/// by default: the date and the amount stay readable.
class _Sample {
  const _Sample(this.sourceName, this.text, this.detections);

  final String sourceName;
  final String text;
  final List<(String, EntityType)> detections;
}

const _samples = {
  'en': _Sample(
    'Invoice_Meyer.docx',
    'Hi Sarah Meyer, following our call on 12 March 2026, please find '
        'the invoice for €4,200. You can reach me at s.meyer@example.com or '
        '+33 6 12 34 56 78. Payment to FR76 3000 6000 0112 3456 7890 189.\n\n'
        'Best regards,\nJonas Weber · Acme GmbH\n14 Rue de Rivoli, 75001 Paris',
    [
      ('Sarah Meyer', EntityType.person),
      ('s.meyer@example.com', EntityType.email),
      ('+33 6 12 34 56 78', EntityType.phone),
      ('FR76 3000 6000 0112 3456 7890 189', EntityType.iban),
      ('Jonas Weber', EntityType.person),
      ('Acme GmbH', EntityType.company),
      ('14 Rue de Rivoli, 75001 Paris', EntityType.address),
    ],
  ),
  'fr': _Sample(
    'Facture_Meyer.docx',
    'Bonjour Sarah Meyer, suite à notre appel du 12 mars 2026, veuillez '
        'trouver la facture de 4 200 €. Vous pouvez me joindre à '
        's.meyer@example.com ou au 06 12 34 56 78. Paiement sur '
        'FR76 3000 6000 0112 3456 7890 189.\n\n'
        'Cordialement,\nJonas Weber · Acme SARL\n14 rue de Rivoli, 75001 Paris',
    [
      ('Sarah Meyer', EntityType.person),
      ('s.meyer@example.com', EntityType.email),
      ('06 12 34 56 78', EntityType.phone),
      ('FR76 3000 6000 0112 3456 7890 189', EntityType.iban),
      ('Jonas Weber', EntityType.person),
      ('Acme SARL', EntityType.company),
      ('14 rue de Rivoli, 75001 Paris', EntityType.address),
    ],
  ),
  'zh': _Sample(
    '发票_王丽华.pdf',
    '王丽华您好：根据 2026年3月12日 的电话沟通，附上金额 ¥42,000 的发票。'
        '有问题请发邮件到 lihua.wang@example.com 或致电 138 1234 5678。'
        '收款账户 6222 0212 3456 7890 123。\n\n'
        '此致\n陈建国 · 华岳咨询有限公司\n上海市静安区南京西路 1288 号',
    [
      ('王丽华', EntityType.person),
      ('lihua.wang@example.com', EntityType.email),
      ('138 1234 5678', EntityType.phone),
      ('6222 0212 3456 7890 123', EntityType.card),
      ('陈建国', EntityType.person),
      ('华岳咨询有限公司', EntityType.company),
      ('上海市静安区南京西路 1288 号', EntityType.address),
    ],
  ),
};

/// Headline and subline above each screenshot, keyed by language.
const _captions = {
  'en': [
    ('Remove personal details before you ask AI', 'Names, emails, phone numbers, IBANs and addresses become labels like [PERSON_1].'),
    ('Paste text, upload a document or scan a photo', 'PDF, Word and text files, or a photo of a paper document.'),
    ('Send it straight to your AI app', 'Or copy the text, or share it as a file.'),
    ('Everything happens on your phone', 'Detection runs on this device. Only the anonymized copy you share leaves it.'),
  ],
  'fr': [
    ("Masquez vos données avant de parler à l'IA", 'Noms, e-mails, téléphones, IBAN et adresses deviennent des étiquettes comme [PERSON_1].'),
    ('Collez, importez ou scannez', 'Du texte copié, des fichiers PDF, Word et texte, ou la photo d’un document papier.'),
    ("Envoyez-le directement à votre app d'IA", 'Ou copiez le texte, ou partagez-le en fichier.'),
    ('Tout se passe sur votre téléphone', "L'analyse se fait sur l'appareil. Seule la copie anonymisée que vous partagez en sort."),
  ],
  'zh': [
    ('问 AI 之前，先把个人信息遮住', '姓名、邮箱、电话、银行账号和地址，替换成 [PERSON_1] 这样的标签'),
    ('粘贴文字、上传文档或拍照', '支持 PDF、Word 和文本文件，也能识别纸质文件的照片'),
    ('一键发送到常用的 AI 应用', '也可以复制文字，或作为文件分享'),
    ('全部在手机上完成', '识别在本机进行，离开手机的只有你分享出去的匿名副本'),
  ],
};

RecordDetail _detail(_Sample s) {
  final detections = [
    for (final (value, type) in s.detections)
      Detection(
        type: type,
        value: value,
        start: s.text.indexOf(value),
        end: s.text.indexOf(value) + value.length,
        confidence: 0.9,
        detector: 'test',
        source: DetectionSource.model,
      ),
  ];
  final result = anonymize(s.text, detections);
  final at = DateTime(2026, 9, 16, 14, 20);
  return RecordDetail(
    record: AnonymizationRecord(
      id: 'r1',
      createdAt: at,
      updatedAt: at,
      kind: InputKind.file,
      sourceName: s.sourceName,
      outputFileName: 'anonymized.txt',
      detectionCount: detections.length,
      preview: result.text,
    ),
    original: s.text,
    output: result.text,
    detections: detections,
    map: result.map,
    outputPath: 'unused',
  );
}

class _FakeService extends AnonymizeService {
  _FakeService()
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

File? _cjkFont() {
  final candidates = [
    Platform.environment['NOTO_SANS_SC'],
    'C:/Windows/Fonts/NotoSansSC-VF.ttf',
  ];
  for (final path in candidates.nonNulls) {
    if (File(path).existsSync()) return File(path);
  }
  return null;
}

Future<void> _loadFonts(String lang) async {
  Future<void> load(String family, List<Future<ByteData>> fonts) async {
    final loader = FontLoader(family);
    fonts.forEach(loader.addFont);
    await loader.load();
  }

  Future<ByteData> file(File f) => f.readAsBytes().then((b) => ByteData.view(b.buffer));

  if (lang == 'zh') {
    await load('Sora', [file(_cjkFont()!)]);
    await load('Karla', [file(_cjkFont()!)]);
  } else {
    await load('Sora', [rootBundle.load('assets/fonts/Sora[wght].ttf')]);
    await load('Karla', [
      rootBundle.load('assets/fonts/Karla[wght].ttf'),
      rootBundle.load('assets/fonts/Karla-Italic[wght].ttf'),
    ]);
  }
  await load('monospace', [file(File('test/fonts/DejaVuSansMono.ttf'))]);
  final flutterRoot = Platform.environment['FLUTTER_ROOT'];
  if (flutterRoot != null) {
    final icons = File('$flutterRoot/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf');
    if (icons.existsSync()) await load('MaterialIcons', [file(icons)]);
  }
}

/// The app screen is laid out as a 390×780 phone and scaled into a bezel
/// below the caption.
const _screen = Size(390, 780);
const _canvas = Size(1080, 1920);

class _StoreFrame extends StatelessWidget {
  const _StoreFrame({required this.title, required this.subtitle, required this.child});

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    const bezel = 14.0;
    const phoneHeight = 1400.0;
    final phoneWidth = (phoneHeight - 2 * bezel) / 2 + 2 * bezel;
    return Material(
      color: Clay.bg,
      child: Stack(
        children: [
          Positioned(
            right: -300,
            bottom: -260,
            child: Container(
              width: 1000,
              height: 1000,
              decoration: const BoxDecoration(color: Clay.blob, shape: BoxShape.circle),
            ),
          ),
          Positioned(
            left: 90,
            right: 90,
            top: 100,
            height: 330,
            child: Column(
              children: [
                Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  style: Clay.heading(56, letterSpacing: -1.1, height: 1.15),
                ),
                const SizedBox(height: 24),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  style: Clay.body(34, color: Clay.inkMuted, height: 1.35),
                ),
              ],
            ),
          ),
          Positioned(
            top: 440,
            left: (_canvas.width - phoneWidth) / 2,
            width: phoneWidth,
            height: phoneHeight,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Clay.ink,
                borderRadius: BorderRadius.circular(72),
                boxShadow: const [
                  BoxShadow(color: Color(0x33785A3C), blurRadius: 60, offset: Offset(0, 24)),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(bezel),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(58),
                  child: FittedBox(
                    child: SizedBox.fromSize(size: _screen, child: child),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Clay's app icon (design/logo/concept-a-page.svg) on its 1024 grid.
class _IconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 1024);
    canvas.drawRRect(
      RRect.fromLTRBR(0, 0, 1024, 1024, const Radius.circular(220)),
      Paint()..color = Clay.primary,
    );
    canvas.drawRRect(
      RRect.fromLTRBAndCorners(
        292, 232, 732, 792,
        topLeft: const Radius.circular(56),
        topRight: const Radius.circular(56),
        bottomRight: const Radius.circular(56),
        bottomLeft: const Radius.circular(20),
      ),
      Paint()..color = Clay.surface,
    );
    final line = Paint()
      ..color = const Color(0xFFE3D6C7)
      ..strokeWidth = 40
      ..strokeCap = StrokeCap.round;
    for (final (x1, y, x2) in [(372.0, 340.0, 652.0), (372.0, 444.0, 440.0), (372.0, 548.0, 652.0), (372.0, 652.0, 548.0)]) {
      canvas.drawLine(Offset(x1, y), Offset(x2, y), line);
    }
    canvas.drawRRect(
      RRect.fromLTRBR(480, 412, 652, 476, const Radius.circular(16)),
      Paint()..color = Clay.ink,
    );
  }

  @override
  bool shouldRepaint(_IconPainter oldDelegate) => false;
}

class _FeatureGraphic extends StatelessWidget {
  const _FeatureGraphic({required this.tagline});

  final String tagline;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Clay.bg,
      child: Stack(
        children: [
          Positioned(
            right: -120,
            bottom: -260,
            child: Container(
              width: 520,
              height: 520,
              decoration: const BoxDecoration(color: Clay.blob, shape: BoxShape.circle),
            ),
          ),
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 88),
              child: Row(
                children: [
                  SizedBox.square(dimension: 220, child: CustomPaint(painter: _IconPainter())),
                  const SizedBox(width: 56),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Docudis', style: Clay.heading(76, letterSpacing: -1.5)),
                        const SizedBox(height: 12),
                        Text(tagline, style: Clay.body(32, color: Clay.inkMuted, height: 1.3)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Registers the four screenshots and the feature graphic for [lang].
void storeScreenshots(String lang) {
  final skip = lang == 'zh' && _cjkFont() == null;
  final locale = Locale(lang);
  final l10n = lookupAppLocalizations(locale);
  final sample = _samples[lang]!;
  final detail = _detail(sample);
  final captions = _captions[lang]!;

  setUpAll(() async {
    if (!skip) await _loadFonts(lang);
  });

  Widget app(Widget home, int shot) => ProviderScope(
        overrides: [
          anonymizeServiceProvider.overrideWithValue(_FakeService()),
          recordDetailProvider.overrideWith((ref, id) async => detail),
          installedAiAppsProvider.overrideWith(
            (ref) async => [AiApp.chatgpt, AiApp.claude, AiApp.gemini, AiApp.perplexity, AiApp.deepseek],
          ),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: clayTheme(),
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          builder: (context, child) => _StoreFrame(
            title: captions[shot].$1,
            subtitle: captions[shot].$2,
            child: MediaQuery(
              data: MediaQuery.of(context).copyWith(
                size: _screen,
                devicePixelRatio: 3,
                padding: EdgeInsets.zero,
                viewPadding: EdgeInsets.zero,
              ),
              child: child!,
            ),
          ),
          home: home,
        ),
      );

  Widget home() => Scaffold(
        body: const ProtectPage(),
        bottomNavigationBar: ClayNavBar(
          index: 0,
          onChanged: (_) {},
          items: [
            (Icons.verified_user_outlined, l10n.anonymizeTitle),
            (Icons.history_rounded, l10n.historyTitle),
            (Icons.person_outline_rounded, l10n.navAccount),
          ],
        ),
      );

  Future<void> pump(WidgetTester tester, Widget widget, [Size size = _canvas]) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(widget);
    await tester.pumpAndSettle();
  }

  Future<void> expectShot(String name) => expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('../goldens/store/$lang/$name.png'),
      );

  testWidgets('1 result', skip: skip, (tester) async {
    await pump(tester, app(const ResultPage(recordId: 'r1'), 0));
    await expectShot('1-result');
  });

  testWidgets('2 pasted text', skip: skip, (tester) async {
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async => call.method == 'Clipboard.getData' ? {'text': sample.text} : null,
    );
    addTearDown(() => tester.binding.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null));
    await pump(tester, app(home(), 1));
    await tester.tap(find.text(l10n.inputPasteText));
    await tester.pumpAndSettle();
    await expectShot('2-paste');
  });

  testWidgets('3 send to AI apps', skip: skip, (tester) async {
    await pump(tester, app(const ResultPage(recordId: 'r1'), 2));
    await tester.tap(find.text(l10n.otherApps));
    await tester.pumpAndSettle();
    await expectShot('3-send');
  });

  testWidgets('4 home', skip: skip, (tester) async {
    await pump(tester, app(home(), 3));
    await expectShot('4-home');
  });

  testWidgets('feature graphic', skip: skip, (tester) async {
    await pump(
      tester,
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: clayTheme(),
        home: _FeatureGraphic(tagline: l10n.homeHeadline),
      ),
      const Size(1024, 500),
    );
    await expectShot('feature-graphic');
  });
}
