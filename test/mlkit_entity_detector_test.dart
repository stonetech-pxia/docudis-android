import 'package:docudis/anonymize/detectors/mlkit_entity_detector.dart';
import 'package:docudis_engine/docudis_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('a bare number ML Kit calls a phone is only a number', () {
    // Seen on the phone 2026-09-23: a staff number, a SIRET, an insurance policy, a DNI.
    for (final value in ['00457', '812 345 678 00027', '7781 2204 5519', '30567812W']) {
      expect(MlKitEntityDetector.numberUnlessDialable(EntityType.phone, value), EntityType.number, reason: value);
    }
  });

  test('a prefix or brackets still say phone, and other types are left alone', () {
    expect(MlKitEntityDetector.numberUnlessDialable(EntityType.phone, '+34 954 22 31 90'), EntityType.phone);
    expect(MlKitEntityDetector.numberUnlessDialable(EntityType.phone, '(415) 555-2671'), EntityType.phone);
    expect(MlKitEntityDetector.numberUnlessDialable(EntityType.address, '41003'), EntityType.address);
  });

  test('a statute ML Kit calls an address is not one', () {
    // Seen on the phone 2026-09-24 in a UK tenancy agreement.
    for (final value in [
      'Housing Act 1988, Section 19A',
      'Section 21',
      "l'article L. 1232-2 du Code du travail",
      'loi n° 89-462 du 6 juillet 1989',
      'Ley 29/1994, de Arrendamientos Urbanos',
      'artículo 36 de la Ley Orgánica 3/2018',
    ]) {
      expect(MlKitEntityDetector.isLegalCitation(value), isTrue, reason: value);
    }
    for (final value in [
      'Rue de la Loi 16, 1000 Bruxelles',
      '14 Harbour Lane, Manchester M4 1HN',
      'C/ Feria 47, 3º B, 41003 Sevilla',
      '221B Baker Street',
    ]) {
      expect(MlKitEntityDetector.isLegalCitation(value), isFalse, reason: value);
    }
  });
}
