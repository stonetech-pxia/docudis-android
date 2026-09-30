// The text-selection menu channel: `anonymize` runs the service on the
// selection and returns the anonymized text; `ready` is announced once.
import 'package:docudis/anonymize/anonymize_service.dart';
import 'package:docudis/anonymize/input/input_source.dart';
import 'package:docudis/anonymize/input/text_extractor.dart';
import 'package:docudis/anonymize/model/model_locator.dart';
import 'package:docudis/anonymize/process_text.dart';
import 'package:docudis/anonymize/storage/anonymization_record.dart';
import 'package:docudis/anonymize/storage/record_store.dart';
import 'package:docudis_engine/docudis_engine.dart';
import 'package:flutter/services.dart' hide TextInput;
import 'package:flutter_test/flutter_test.dart';

const _text = 'Hi Sarah Meyer, call me on +33 6 12 34 56 78.';
const _output = 'Hi [PERSON_1], call me on [PHONE_1].';

final _record = AnonymizationRecord(
  id: 'r1',
  createdAt: DateTime(2026, 9, 17),
  updatedAt: DateTime(2026, 9, 17),
  kind: InputKind.text,
  sourceName: null,
  outputFileName: 'docudis-20260917-1000.txt',
  detectionCount: 2,
  preview: _output,
);

class _FakeStore extends RecordStore {
  @override
  Future<RecordDetail> load(String id) async => RecordDetail(
        record: _record,
        original: _text,
        output: _output,
        detections: const [],
        map: PlaceholderMap(),
        outputPath: 'unused',
      );
}

class _FakeService extends AnonymizeService {
  _FakeService()
      : super(
          store: _FakeStore(),
          extractor: TextExtractor(),
          modelLocator: ModelLocator(),
          dictionaryTerms: () async => const [],
          neverHideTerms: () async => const [],
          listOnly: () => false,
        );

  final processed = <InputSource>[];

  @override
  Future<AnonymizationRecord> process(InputSource source) async {
    processed.add(source);
    return _record;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  final channel = ProcessTextHandler.channel;

  tearDown(() {
    messenger.setMockMethodCallHandler(channel, null);
    channel.setMethodCallHandler(null);
  });

  /// Sends [call] the way the Kotlin side does and decodes the reply.
  Future<Object?> fromNative(MethodCall call) async {
    ByteData? reply;
    await messenger.handlePlatformMessage(
      channel.name,
      channel.codec.encodeMethodCall(call),
      (data) => reply = data,
    );
    // A null reply is what the native side sees as "not implemented".
    return reply == null ? null : channel.codec.decodeEnvelope(reply!);
  }

  test('anonymize returns the anonymized text and reports done', () async {
    final service = _FakeService();
    final calls = <String>[];
    messenger.setMockMethodCallHandler(channel, (call) async {
      calls.add(call.method);
      return null;
    });
    var done = 0;
    ProcessTextHandler.register(service, onDone: () => done++);
    await Future<void>.delayed(Duration.zero);
    expect(calls, ['ready']);

    final result = await fromNative(const MethodCall('anonymize', _text));

    expect(result, _output);
    expect(service.processed, [
      isA<TextInput>().having((t) => t.text, 'text', _text),
    ]);
    expect(done, 1);
  });

  test('unknown methods are not implemented', () async {
    ProcessTextHandler.register(_FakeService());

    expect(await fromNative(const MethodCall('other')), isNull);
  });
}
