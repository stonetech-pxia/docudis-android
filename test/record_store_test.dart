import 'dart:io';
import 'dart:typed_data';

import 'package:docudis/anonymize/output/document_redaction.dart';
import 'package:docudis/anonymize/storage/anonymization_record.dart';
import 'package:docudis/anonymize/storage/record_store.dart';
import 'package:docudis_engine/docudis_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory root;
  late RecordStore store;

  setUp(() async {
    root = await Directory.systemTemp.createTemp('records');
    store = RecordStore(root: root);
  });

  tearDown(() => root.delete(recursive: true));

  Future<void> save(int i) {
    final at = DateTime(2026, 9, 17).add(Duration(minutes: i));
    return store.save(
      record: AnonymizationRecord(
        id: 'r$i',
        createdAt: at,
        updatedAt: at,
        kind: InputKind.text,
        sourceName: null,
        outputFileName: 'r$i.txt',
        detectionCount: 0,
        preview: '',
      ),
      original: 'text $i',
      output: 'text $i',
      detections: const [],
      map: PlaceholderMap(),
    );
  }

  test('prune keeps the most recently updated records', () async {
    for (var i = 0; i < 5; i++) {
      await save(i);
    }
    await store.prune(3);
    expect((await store.list()).map((r) => r.id), ['r4', 'r3', 'r2']);
    expect(Directory('${root.path}/r0').existsSync(), isFalse);
  });

  test('prune under the limit deletes nothing', () async {
    await save(0);
    await store.prune(3);
    expect(await store.list(), hasLength(1));
  });

  test('a document keeps its source, page layout and redacted copy', () async {
    final source = File('${root.path}/picked.pdf')..writeAsStringSync('%PDF original');
    Future<RecordDetail> saveWith(Uint8List? redacted) async {
      await store.save(
        record: AnonymizationRecord(
          id: 'd',
          createdAt: DateTime(2026, 9, 23),
          updatedAt: DateTime(2026, 9, 23),
          kind: InputKind.file,
          sourceName: 'picked.pdf',
          outputFileName: 'picked-anonymized.txt',
          detectionCount: 0,
          preview: '',
        ),
        original: 'page one',
        output: 'page one',
        detections: const [],
        map: PlaceholderMap(),
        document: (
          sourcePath: source.path,
          kind: DocumentKind.pdf,
          pdf: const PdfLayout([PdfPageSpan(offset: 0, length: 8)]),
        ),
        redactedDocument: redacted,
      );
      return store.load('d');
    }

    final detail = await saveWith(Uint8List.fromList('%PDF redacted'.codeUnits));
    final document = detail.document!;
    expect(document.kind, DocumentKind.pdf);
    expect(File(document.sourcePath).readAsStringSync(), '%PDF original');
    expect(File(document.redactedPath!).readAsStringSync(), '%PDF redacted');
    expect(document.pdf!.pages.single.length, 8);

    // A later run that could not redact must not leave the old copy behind.
    expect((await saveWith(null)).document!.redactedPath, isNull);
  });

  test('rename sets the name History shows and keeps the rest, and the order', () async {
    for (var i = 0; i < 3; i++) {
      await save(i);
    }
    await store.rename('r0', 'Deposit dispute, flat 2');
    final records = await store.list();
    expect(records.map((r) => r.id), ['r2', 'r1', 'r0']);
    expect(records.last.displayName, 'Deposit dispute, flat 2');
    expect(records.last.outputFileName, 'r0.txt');
    expect((await store.load('r0')).output, 'text 0');
  });

  test('a record is called by its title, else its file, else its output name', () {
    AnonymizationRecord record({String? title, String? sourceName}) => AnonymizationRecord(
          id: 'r',
          createdAt: DateTime(2026),
          updatedAt: DateTime(2026),
          kind: InputKind.text,
          sourceName: sourceName,
          outputFileName: 'docudis-20260924-1201.txt',
          detectionCount: 0,
          preview: '',
          title: title,
        );
    expect(record(title: 'Re: Deposit', sourceName: 'x.pdf').displayName, 'Re: Deposit');
    expect(record(sourceName: 'quote.docx').displayName, 'quote.docx');
    expect(record().displayName, 'docudis-20260924-1201.txt');
  });

  group('titleFromText', () {
    test('takes the first line with a word in it, spaces folded', () {
      expect(titleFromText('  \n---\n  Re:  Deposit -\t14 Harbour Lane \nDear Donna,'),
          'Re: Deposit - 14 Harbour Lane');
    });

    test('cuts a long line at 60 characters', () {
      final title = titleFromText('${'Buenos días Lucía, para la renta de tu madre ' * 3}\nfin')!;
      expect(title.length, 61);
      expect(title, endsWith('…'));
    });

    test("prefers an e-mail's subject to its first header line", () {
      expect(
        titleFromText('From: Priya Nair <priya@example.com>\nSent: 22 September 2026\n'
            'Subject: Re: Deposit - 14 Harbour Lane\n\nDear Tom,'),
        'Re: Deposit - 14 Harbour Lane',
      );
      expect(titleFromText('De : AEAT\nAsunto: Requerimiento IVA 2025\nEstimado'), 'Requerimiento IVA 2025');
    });

    test('drops the time stamp in front of a chat message', () {
      expect(titleFromText('[09:12, 23/9/2026] Lucía Fabra: Buenos días'), 'Lucía Fabra: Buenos días');
      expect(titleFromText('[24/09/2026, 07:58:12] Kwame Mensah: Hi Tom'), 'Kwame Mensah: Hi Tom');
      expect(titleFromText('24/09/2026, 07:58 - Kwame Mensah: Hi Tom'), 'Kwame Mensah: Hi Tom');
      expect(titleFromText('12/09/2026 tenancy start'), '12/09/2026 tenancy start',
          reason: 'a date alone is not a chat stamp');
    });

    test('is null when there is no word at all', () {
      expect(titleFromText('--- \n *** \n'), isNull);
    });
  });
}
