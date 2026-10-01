import 'dart:io';

import 'package:docudis_ffi/docudis_ffi.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Android loads and repeatedly calls the real Core library', (
    tester,
  ) async {
    expect(Platform.isAndroid, isTrue);
    final core = DocudisNative.open();
    expect(core.abiVersion, 1);

    const text = '😀 张三\u00a0e\u0301 alice@example.com';
    final personStart = text.indexOf('张三');
    final request = <String, Object?>{
      'schema_version': 1,
      'text': text,
      'regions': <String>[],
      'dictionary': <String>[],
      'never_hide': <String>[],
      'include_bundled_lists': false,
      'detections': [
        {
          'type': 'PERSON',
          'value': '张三',
          'start': personStart,
          'end': personStart + 2,
          'confidence': 1.0,
          'detector': 'integration',
          'source': 'manual',
          'enabled': true,
        },
      ],
    };

    // Rule detection alone: the email span must come back in Dart UTF-16
    // offsets despite the emoji, CJK, NBSP and combining mark before it.
    final detected = core.detect({...request, 'detections': <Object?>[]});
    final email = (detected['detections']! as List<Object?>)
        .cast<Map<Object?, Object?>>()
        .singleWhere((d) => d['type'] == 'EMAIL');
    expect(email['value'], 'alice@example.com');
    expect(email['start'], text.indexOf('alice@'));
    expect(email['end'], text.length);

    Map<String, Object?>? processed;
    for (var i = 0; i < 50; i++) {
      processed = core.process(request);
      expect(processed['text'], '😀 [PERSON_1]\u00a0e\u0301 [EMAIL_1]');
      final person = (processed['detections']! as List<Object?>)
          .cast<Map<Object?, Object?>>()
          .singleWhere((d) => d['type'] == 'PERSON');
      expect(person['start'], personStart);
      expect(person['end'], personStart + 2);
    }

    final restored = core.restore({
      'schema_version': 1,
      'text': processed!['text'],
      'mappings': processed['mappings'],
    });
    expect(restored['text'], text);

    final invalidSchema = throwsA(
      isA<DocudisException>().having(
        (e) => e.status,
        'status',
        DocudisStatus.invalidArgument,
      ),
    );
    expect(
      () => core.process({...request, 'schema_version': 99}),
      invalidSchema,
    );
    expect(
      () => core.restore({
        'schema_version': 99,
        'text': 'x',
        'mappings': <Object?>[],
      }),
      invalidSchema,
    );
  });
}
