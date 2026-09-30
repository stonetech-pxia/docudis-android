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
    expect(core.abiVersion, DocudisNative.expectedAbiVersion);

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

    Map<String, Object?>? processed;
    for (var i = 0; i < 50; i++) {
      processed = core.process(request);
      expect(processed['text'], contains('[PERSON_1]'));
      expect(processed['text'], contains('[EMAIL_1]'));
    }

    final restored = core.restore({
      'schema_version': 1,
      'text': processed!['text'],
      'mappings': processed['mappings'],
    });
    expect(restored['text'], text);

    expect(
      () => core.restore({
        'schema_version': 99,
        'text': 'x',
        'mappings': <Object?>[],
      }),
      throwsA(isA<DocudisException>()),
    );
  });
}
