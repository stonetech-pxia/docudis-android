// "Hide only this list": with the switch on and words on the Always hide
// list, a run hides the list and nothing else, and the record says so; an
// empty list or the switch off leaves the full detection in charge.
import 'dart:io';

import 'package:docudis/anonymize/anonymize_service.dart';
import 'package:docudis/anonymize/input/input_source.dart';
import 'package:docudis/anonymize/input/text_extractor.dart';
import 'package:docudis/anonymize/model/model_locator.dart';
import 'package:docudis/anonymize/providers.dart';
import 'package:docudis/anonymize/storage/record_store.dart';
import 'package:docudis/preferences.dart';
import 'package:docudis_engine/docudis_engine.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _text =
    'Dear Mr Al-Masri,\nTariq Al-Masri, 18 Cotham Brow, t.almasri@example.com';
const _email = 't.almasri@example.com';

/// Stands in for the model, the rules and ML Kit, which need the phone, and
/// counts how often they run. They find the e-mail address.
class _Service extends AnonymizeService {
  _Service({
    required super.store,
    required List<String> terms,
    required bool listOnly,
  }) : super(
         extractor: TextExtractor(),
         modelLocator: ModelLocator(),
         dictionaryTerms: () async => terms,
         neverHideTerms: () async => const [],
         listOnly: () => listOnly,
       );

  int fullRuns = 0;

  @override
  Future<List<Detection>> detect(String text) async {
    fullRuns++;
    final start = text.indexOf(_email);
    return [
      Detection(
        type: EntityType.email,
        value: _email,
        start: start,
        end: start + _email.length,
        confidence: 1,
        detector: 'test',
        source: DetectionSource.validatedRule,
      ),
    ];
  }
}

class _Dictionary extends DictionaryNotifier {
  @override
  Future<List<String>> read() async => const ['Tariq Al-Masri'];
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory root;
  late RecordStore store;

  setUp(() async {
    root = await Directory.systemTemp.createTemp('records');
    store = RecordStore(root: root);
  });

  tearDown(() => root.delete(recursive: true));

  test('hides the words on the list and nothing else', () async {
    final service = _Service(
      store: store,
      terms: ['Tariq Al-Masri'],
      listOnly: true,
    );
    final record = await service.process(const TextInput(_text));
    final saved = await store.load(record.id);

    expect(service.fullRuns, 0);
    expect(
      saved.output,
      'Dear Mr Al-Masri,\n[CUSTOM_1], 18 Cotham Brow, $_email',
    );
    expect(saved.record.listOnly, isTrue);
    expect(saved.record.detectionCount, 1);
  });

  test('an empty list never counts: everything is detected as usual', () async {
    final service = _Service(store: store, terms: const [], listOnly: true);
    final record = await service.process(const TextInput(_text));

    expect(service.fullRuns, 1);
    expect((await store.load(record.id)).output, isNot(contains(_email)));
    expect(record.listOnly, isFalse);
  });

  test('switched off, the list is one detector among the others', () async {
    final service = _Service(
      store: store,
      terms: ['Tariq Al-Masri'],
      listOnly: false,
    );
    final record = await service.process(const TextInput(_text));

    expect(service.fullRuns, 1);
    expect(record.listOnly, isFalse);
  });

  test('the app and the text-selection menu read the saved switch', () async {
    SharedPreferences.setMockInitialValues({'list_only': true});
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(
          await SharedPreferences.getInstance(),
        ),
        dictionaryProvider.overrideWith(_Dictionary.new),
        recordStoreProvider.overrideWithValue(store),
      ],
    );
    addTearDown(container.dispose);

    final record = await container
        .read(anonymizeServiceProvider)
        .process(const TextInput(_text));

    expect(record.listOnly, isTrue);
    expect((await store.load(record.id)).output, contains('[CUSTOM_1]'));
  });

  test('an edit on the review page keeps the mark', () async {
    final service = _Service(
      store: store,
      terms: ['Tariq Al-Masri'],
      listOnly: true,
    );
    final record = await service.process(const TextInput(_text));
    final detail = await store.load(record.id);
    final start = _text.indexOf(_email);

    final edited = await service.reapply(record.id, [
      ...detail.detections,
      service.manualDetection(
        _text,
        start,
        start + _email.length,
        EntityType.email,
      ),
    ]);

    expect(edited.output, isNot(contains(_email)));
    expect(edited.record.listOnly, isTrue);
  });
}
