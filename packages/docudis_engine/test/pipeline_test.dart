import 'package:docudis_engine/docudis_engine.dart';
import 'package:test/test.dart';

Detection d(
  EntityType type,
  String text,
  int start,
  int end, {
  DetectionSource source = DetectionSource.rule,
  double confidence = 0.5,
}) =>
    Detection(
      type: type,
      value: text.substring(start, end),
      start: start,
      end: end,
      confidence: confidence,
      detector: 'test',
      source: source,
    );

void main() {
  group('resolveOverlaps', () {
    test('dictionary > validated rule > strong rule > model > loose rule', () {
      const text = 'aaaaaaaaaa';
      final candidates = [
        d(EntityType.other, text, 0, 5, source: DetectionSource.rule),
        d(EntityType.person, text, 0, 5, source: DetectionSource.model),
        d(EntityType.email, text, 0, 5, source: DetectionSource.strongRule),
        d(EntityType.card, text, 0, 5, source: DetectionSource.validatedRule),
        d(EntityType.custom, text, 0, 5, source: DetectionSource.dictionary),
      ];
      final order = <EntityType>[];
      while (candidates.isNotEmpty) {
        final winner = DetectionPipeline.resolveOverlaps(candidates).single;
        order.add(winner.type);
        candidates.removeWhere((c) => c.type == winner.type);
      }
      expect(order, [
        EntityType.custom,
        EntityType.card,
        EntityType.email,
        EntityType.person,
        EntityType.other,
      ]);
    });

    test('a strong e-mail rule beats a longer junk model span', () async {
      const text = 'write to jane.doe@acme.co or call';
      final pipeline = DetectionPipeline([RegexDetector.bundled(regions: {})]);
      final found = await pipeline.run(text);
      final merged = DetectionPipeline.merge(text, [
        ...found,
        d(EntityType.address, text, 0, text.length, source: DetectionSource.model),
      ]);
      expect(merged.map((e) => e.type), contains(EntityType.email));
      expect(merged.map((e) => e.type), isNot(contains(EntityType.address)));
    });

    test('same priority: longer span wins, then confidence', () {
      const text = 'aaaaaaaaaa';
      final result = DetectionPipeline.resolveOverlaps([
        d(EntityType.phone, text, 0, 4, confidence: 0.9),
        d(EntityType.id, text, 0, 8, confidence: 0.4),
        d(EntityType.amount, text, 6, 10, confidence: 0.9),
      ]);
      expect(result.map((e) => e.type), [EntityType.id]);
    });

    test('non-overlapping spans are kept in reading order', () {
      const text = 'aaaaaaaaaa';
      final result = DetectionPipeline.resolveOverlaps([
        d(EntityType.phone, text, 6, 10),
        d(EntityType.email, text, 0, 3),
      ]);
      expect(result.map((e) => e.type), [EntityType.email, EntityType.phone]);
    });

    test('a dictionary term inside a longer hidden span gives way to it', () {
      const text = 'Jean Dupont a signé.';
      final result = DetectionPipeline.resolveOverlaps([
        d(EntityType.custom, text, 5, 11, source: DetectionSource.dictionary),
        d(EntityType.person, text, 0, 11, source: DetectionSource.model),
      ]);
      expect(result.map((e) => (e.type, e.value)), [(EntityType.person, 'Jean Dupont')]);
    });

    test('a dictionary term inside a span left visible is still hidden', () {
      const text = 'le 12 mai 2024';
      final result = DetectionPipeline.resolveOverlaps([
        d(EntityType.custom, text, 6, 9, source: DetectionSource.dictionary),
        d(EntityType.date, text, 3, 14, source: DetectionSource.strongRule)
            .copyWith(enabled: false),
      ]);
      expect(result.map((e) => (e.type, e.value)), [(EntityType.custom, 'mai')]);
    });

    test('a dictionary term does not give way to a span that loses its own overlap', () {
      // "Jean Dupont Martin" (model) would cover "Jean", but the dictionary
      // term "Martin & Co" takes its place: "Jean" must not be left showing.
      const text = 'Jean Dupont Martin & Co';
      final result = DetectionPipeline.resolveOverlaps([
        d(EntityType.custom, text, 0, 4, source: DetectionSource.dictionary),
        d(EntityType.custom, text, 12, 23, source: DetectionSource.dictionary),
        d(EntityType.person, text, 0, 18, source: DetectionSource.model),
      ]);
      expect(result.map((e) => e.value), ['Jean', 'Martin & Co']);
    });
  });

  group('DictionaryDetector', () {
    List<String> hits(List<String> terms, String text) =>
        DictionaryDetector(terms).detectSync(text).map((e) => e.value).toList();

    test('whole words only: "Li" is not inside "delivery" or "Lisa"', () {
      expect(hits(['Li'], 'Li asked Lisa about the delivery. LI agreed.'), ['Li', 'LI']);
    });

    test('accents and capitals do not matter', () {
      expect(
        hits(['Émilie'], 'Émilie, EMILIE, emilie et ÉMILIE ; pas Emilien.'),
        ['Émilie', 'EMILIE', 'emilie', 'ÉMILIE'],
      );
      expect(hits(['Munoz'], 'Sr. Muñoz'), ['Muñoz']);
    });

    test('a term with spaces matches across a line break or a double space', () {
      expect(
        hits(['12 rue de la Paix'], 'au 12 rue de\nla  Paix, Paris'),
        ['12 rue de\nla  Paix'],
      );
    });

    test('CJK terms match anywhere', () {
      expect(hits(['星辰'], '公司星辰科技'), ['星辰']);
    });
  });

  group('propagate', () {
    test('repeats of a detected value are found with word boundaries', () {
      const text = 'Call Alice. Alice said Alicent is not Alice.';
      final first = d(EntityType.person, text, 5, 10, source: DetectionSource.model);
      final extra = DetectionPipeline.propagate(text, [first]);
      expect(extra.map((e) => e.start), [12, 38]);
      expect(extra.every((e) => e.source == DetectionSource.propagated), isTrue);
    });

    test('only PERSON values propagate their individual words', () {
      const text = 'Baker Street is long. Baker sells bread on that Street.';
      final addr = d(EntityType.address, text, 0, 12, source: DetectionSource.model);
      expect(DetectionPipeline.merge(text, [addr]).map((e) => e.value), ['Baker Street']);
      final person = d(EntityType.person, text, 0, 12, source: DetectionSource.model);
      expect(
        DetectionPipeline.merge(text, [person]).map((e) => e.value),
        ['Baker Street', 'Baker', 'Street'],
      );
    });

    test('a name part keeps its capital: "Katie Price" does not hide every "price"', () {
      const text = 'Katie Price signed. The price is fixed. Mrs PRICE agreed, KATIE PRICE too.';
      final person = d(EntityType.person, text, 0, 11, source: DetectionSource.model);
      expect(
        DetectionPipeline.merge(text, [person]).map((e) => e.value),
        ['Katie Price', 'PRICE', 'KATIE PRICE'],
      );
    });

    test('accented values respect word boundaries too', () {
      const text = 'René Blanc a signé. Renée est absente, René aussi.';
      final person = d(EntityType.person, text, 0, 10, source: DetectionSource.model);
      expect(
        DetectionPipeline.merge(text, [person]).map((e) => '${e.start}:${e.value}'),
        ['0:René Blanc', '39:René'],
      );
    });

    test('two-character CJK names propagate without boundaries', () {
      const text = '张三来了，张三说张三丰不是他。';
      final first = d(EntityType.person, text, 0, 2, source: DetectionSource.model);
      final extra = DetectionPipeline.propagate(text, [first]);
      expect(extra.map((e) => e.start), [5, 8]);
    });
  });

  group('pipeline end to end', () {
    test('regex + dictionary on mixed Chinese text', () async {
      final pipeline = DetectionPipeline([
        DictionaryDetector(['星辰科技']),
        RegexDetector.bundled(),
      ]);
      const text = '联系人张三，手机13812345678，邮箱 zhang.san@example.com，'
          '公司星辰科技，身份证110101199003070003。';
      final found = await pipeline.run(text);
      final byType = {for (final f in found) f.type: f.value};
      expect(byType[EntityType.phone], '13812345678');
      expect(byType[EntityType.email], 'zhang.san@example.com');
      expect(byType[EntityType.custom], '星辰科技');
      expect(byType[EntityType.id], '110101199003070003');
    });
  });

  group('what a fresh run hides', () {
    Future<List<Detection>> run(String text, {Set<String> regions = const {'us', 'gb', 'fr', 'es'}}) =>
        DetectionPipeline([RegexDetector.bundled(regions: regions)]).run(text);

    Iterable<(EntityType, String, bool)> of(List<Detection> found, Set<EntityType> types) =>
        found.where((d) => types.contains(d.type)).map((d) => (d.type, d.value, d.enabled));

    test('amounts are detected but left visible', () async {
      final found = await run('Total due: €1,250.00 by card, i.e. 1 250,00 EUR.');
      expect(of(found, {EntityType.amount}), [
        (EntityType.amount, '€1,250.00', false),
        (EntityType.amount, '1 250,00 EUR', false),
      ]);
      expect(anonymize('Total due: €1,250.00', await run('Total due: €1,250.00')).text,
          'Total due: €1,250.00');
    });

    test('only a date after a birth label is hidden', () async {
      const dates = {EntityType.date, EntityType.birthDate};
      for (final (text, birth, other) in [
        ('Date of birth: 27/10/1974. Invoice date: 03/02/2026.', '27/10/1974', '03/02/2026'),
        ('Olivia Pemberton, born 7 May 1997, lease from 1 June 2026.', '7 May 1997', '1 June 2026'),
        ('DOB (DD/MM/YYYY): 09/01/1969, appointment on 12/03/2026', '09/01/1969', '12/03/2026'),
        ('Mme Morel, née le 12 mars 1985 à Lyon. Bail du 1er juin 2026.', '12 mars 1985', '1er juin 2026'),
        ('NE(E) LE 12/03/1985\nDate de délivrance : 04/05/2021', '12/03/1985', '04/05/2021'),
        ('Date de naissance\n12/03/1985\nDate d\'entrée : 01/02/2020', '12/03/1985', '01/02/2020'),
        ('D. Luis, nacido el 3 de abril de 1990, contrato de 1 de mayo de 2026.', '3 de abril de 1990', '1 de mayo de 2026'),
        ('Fecha de nacimiento: 03/04/1990    Fecha de alta: 01/05/2026', '03/04/1990', '01/05/2026'),
      ]) {
        expect(of(await run(text), dates),
            [(EntityType.birthDate, birth, true), (EntityType.date, other, false)], reason: text);
      }
    });

    test('a birth date is hidden wherever else it appears', () async {
      final found = await run('Date of birth: 27/10/1974\nSigned 03/02/2026.\nPatient (27/10/1974) attended.');
      expect(of(found, {EntityType.date, EntityType.birthDate}), [
        (EntityType.birthDate, '27/10/1974', true),
        (EntityType.date, '03/02/2026', false),
        (EntityType.birthDate, '27/10/1974', true),
      ]);
    });

    test('"ne le" in French prose is not a birth label', () async {
      final found = await run('Je ne le ferai pas avant le 12/03/2026.');
      expect(of(found, {EntityType.date, EntityType.birthDate}), [(EntityType.date, '12/03/2026', false)]);
    });

    test('merge keeps what the user switched on', () async {
      const text = 'Total due: €1,250.00';
      final on = [for (final d in await run(text)) d.copyWith(enabled: true)];
      expect(DetectionPipeline.merge(text, on).single.enabled, isTrue);
    });
  });

  group('NUMBER', () {
    List<(EntityType, String)> run(String text, Set<String> regions) => [
          for (final d in DetectionPipeline.merge(
              text, RegexDetector.bundled(regions: regions).detectSync(text)))
            (d.type, d.value),
        ];

    test('a loose digit rule reports a number, not a guessed kind', () {
      expect(run('Dossier 123456789012 transmis.', {'fr'}), [(EntityType.number, '123456789012')]);
      expect(run('Quote 123456789 when you call.', {'gb'}), [(EntityType.number, '123456789')]);
      expect(run('Sort code 12-34-56, account 12345678', {'gb'}),
          [(EntityType.number, '12-34-56'), (EntityType.number, '12345678')]);
    });

    test('a loose phone rule reports a number unless the match has a + prefix', () {
      expect(run('Company Number: 09583892', {'gb', 'ie'}), [(EntityType.number, '09583892')]);
      expect(run('Ring +353 1 234 5678', {'ie'}), [(EntityType.phone, '+353 1 234 5678')]);
      expect(run('Tel. 0161 276 1234 or 06 12 34 56 78', {'gb', 'fr'}),
          [(EntityType.phone, '0161 276 1234'), (EntityType.phone, '06 12 34 56 78')]);
    });

    test('checksums, confident formats and letter formats keep their type', () {
      expect(run('NIR 1 85 05 78 006 084 91', {'fr'}), [(EntityType.id, '1 85 05 78 006 084 91')]);
      expect(run('DNI 12345678Z', {'es'}), [(EntityType.id, '12345678Z')]);
      expect(run('SSN 123-45-6789', {'us'}), [(EntityType.id, '123-45-6789')]);
      expect(run('Passeport 12AB34567', {'fr'}), [(EntityType.id, '12AB34567')]);
      expect(run('card 4111 1111 1111 1111', {'us'}), [(EntityType.card, '4111 1111 1111 1111')]);
    });
  });

  test('a lower-case word in a person span does not spread', () {
    const text = 'Control por Dra. Pérez desayuno. Tomar en el desayuno y cena.';
    final start = text.indexOf('Pérez');
    final merged = DetectionPipeline.merge(text, [
      d(EntityType.person, text, start, start + 'Pérez desayuno'.length,
          source: DetectionSource.model, confidence: 0.9),
    ]);
    expect(merged.map((e) => e.value), ['Pérez desayuno']);
  });

  group('title stoplist', () {
    Detection model(EntityType type, String text, String value) {
      final start = text.indexOf(value);
      return d(type, text, start, start + value.length,
          source: DetectionSource.model, confidence: 0.9);
    }

    test('model spans that are only a title or department are dropped and never propagate', () {
      const text = 'Margaret Chen (Chair) and Daniel Okafor (CFO); Chen thanked the CFO. '
          '续约草案提交给法务部审核，法务部同意。';
      final merged = DetectionPipeline.merge(text, [
        model(EntityType.person, text, 'Margaret Chen'),
        model(EntityType.person, text, 'Chair'),
        model(EntityType.company, text, 'CFO'),
        model(EntityType.company, text, '法务部'),
      ]);
      expect(merged.map((e) => e.value), ['Margaret Chen', 'Chen']);
    });

    test('contract party roles are not names and never propagate', () {
      // A lease photo (2026-09-26): the model tagged "Lessor" and "Lessee" as
      // PERSON and every later mention of either was hidden.
      const text = 'between Mrs. Patti Fay MD, hereinafter referred to as "Lessor", and '
          'Weimann Inc, hereinafter referred to as &Lessee*. The Lessor agrees to lease '
          'to the Lessee. Le Bailleur et le Preneur ; el Arrendador y el Arrendatario.';
      final merged = DetectionPipeline.merge(text, [
        model(EntityType.person, text, 'Patti Fay'),
        model(EntityType.person, text, 'Lessor'),
        model(EntityType.person, text, '&Lessee*'),
        model(EntityType.company, text, 'Weimann Inc'),
        model(EntityType.person, text, 'Bailleur'),
        model(EntityType.person, text, 'Arrendatario'),
      ]);
      expect(merged.map((e) => e.value), ['Patti Fay', 'Weimann Inc']);
    });

    test('a role after an article is a role, and an article alone is never a name', () {
      // en-insurance-01: the model tagged "THE" in the heading "THE POLICYHOLDER";
      // once "policyholder" stopped the span from growing, "THE" alone was kept
      // and hid every "the" in the letter.
      const text = 'THE POLICYHOLDER\nName: Nora Kelly\nDriving: the policyholder and the named driver. '
          'Le Bailleur signe.';
      final merged = DetectionPipeline.merge(text, [
        model(EntityType.person, text, 'THE'),
        model(EntityType.person, text, 'THE POLICYHOLDER'),
        model(EntityType.person, text, 'Nora Kelly'),
        model(EntityType.person, text, 'Le Bailleur'),
      ]);
      expect(merged.map((e) => e.value), ['Nora Kelly']);
    });

    test('a title inside a person name does not propagate as a name part', () {
      const text = 'Director Smith met the Director of sales.';
      final merged = DetectionPipeline.merge(text, [
        model(EntityType.person, text, 'Director Smith'),
      ]);
      expect(merged.map((e) => e.value), ['Director Smith']);
    });

    test('dictionary terms are exempt', () {
      const text = 'the CFO signed';
      final merged = DetectionPipeline.merge(text, [
        d(EntityType.custom, text, 4, 7, source: DetectionSource.dictionary, confidence: 1),
      ]);
      expect(merged.map((e) => e.value), ['CFO']);
    });

    test('an identifier label before its number is not an entity', () {
      const text = 'Employeur : Morvan Plomberie – SIRET 812 345 676 00009 – Code NAF 4322A';
      final merged = DetectionPipeline.merge(text, [
        model(EntityType.company, text, 'Morvan Plomberie'),
        model(EntityType.address, text, 'SIRET'),
        model(EntityType.company, text, 'NAF'),
      ]);
      expect(merged.map((e) => e.value), ['Morvan Plomberie']);
    });

    test('matching ignores case and surrounding punctuation', () {
      expect(isTitleOrDepartment('(Chair)'), isTrue);
      expect(isTitleOrDepartment('Head of Operations,'), isTrue);
      expect(isTitleOrDepartment('法务部。'), isTrue);
      expect(isTitleOrDepartment('Chen'), isFalse);
      expect(isTitleOrDepartment('the Lessor'), isTrue);
      expect(isTitleOrDepartment('EL ARRENDATARIO'), isTrue);
      expect(isTitleOrDepartment("l'Assureur"), isTrue);
      expect(isTitleOrDepartment('The Smiths'), isFalse);
      expect(isTitleOrDepartment('深圳总部法务部'), isFalse);
    });
  });

  group('loose numbers in rows of figures (2026-09-26)', () {
    Future<List<Detection>> run(String text) =>
        DetectionPipeline([RegexDetector.bundled(regions: {'us', 'gb', 'ie'})]).run(text);

    Iterable<String> hidden(List<Detection> found) => found.where((d) => d.enabled).map((d) => d.value);

    test('a volume between prices and percentages is detected but left visible', () async {
      // A photographed portfolio statement: the "UK bank account" and "US passport"
      // rules hid every daily volume.
      const text = 'ETF\tTraded As\tEOD Price\tYTD Price Change\tAvg. Daily Volume\tOne Day Change\n'
          'Technology Select Sector SPDR Fund\tXLK\t234.47\t0.2265\t4015302\t-0.0127\tEquity\n'
          'SPDR S&P 500 ETF Trust\tSPY\t588.22\t0.2534\t46003064\t-0.0114\tEquity\n'
          'Vanguard Growth ETF\tVUG\t414.19\t0.339\t1145739\t-0.0126\tEquity\n'
          'Your Financial Consultant: Dr. Gregory Frami\n'
          'Business: 663 999-5583';
      final found = await run(text);
      expect(hidden(found), isNot(anyOf(contains('4015302'), contains('46003064'), contains('1145739'))));
      expect(found.where((d) => d.value == '4015302' && !d.enabled), isNotEmpty,
          reason: 'still listed, so the user can hide it');
      expect(hidden(found), contains('663 999-5583'));
    });

    test('a number ML Kit found in a row of figures is left visible too', () async {
      // ML Kit reports an undialled "phone" as NUMBER: every price and volume of the
      // statement photo came through that way.
      const text = 'Technology Select Sector SPDR Fund\t234.47\t0.2265\t4015302\t-0.0127\tEquity\n'
          'Vanguard Information Technology ETF\tVGT\t627.57\t0.305\t453405\t-0.0125\tEquity\n'
          'Vanguard Growth ETF\tVUG\t414.19\t0.339\t1145739\t-0.0126\tEquity\n';
      Detection mlkit(String value) {
        final start = text.indexOf(value);
        return Detection(type: EntityType.number, value: value, start: start, end: start + value.length,
            confidence: 0.8, detector: 'mlkit-entity', source: DetectionSource.model);
      }

      final found = await DetectionPipeline([_Fixed([mlkit('234.47'), mlkit('4015302'), mlkit('453405')])]).run(text);
      expect(hidden(found), isEmpty);
    });

    test('identifiers in a table of people stay hidden', () async {
      const text = 'Name\tPhone\tAccount\n'
          'Anna Meyer\t020 7946 0123\t12345678\n'
          'Tom Price\t020 7946 0456\t23456789\n'
          'Lea Brown\t020 7946 0789\t34567890';
      expect(hidden(await run(text)), containsAll(['12345678', '23456789', '34567890']));
    });

    test('one row of figures, or a row that names the number, keeps it hidden', () async {
      expect(hidden(await run('Total\t414.19\t0.339\t4015302\t-0.0126')), contains('4015302'));
      const labelled = 'Account 4015302\t234.47\t0.2265\t-0.0127\n'
          'Account 4015303\t588.22\t0.2534\t-0.0114\n'
          'Account 4015304\t414.19\t0.339\t-0.0126';
      expect(hidden(await run(labelled)), containsAll(['4015302', '4015303', '4015304']));
    });
  });

  group('tables and public products (2026-09-26)', () {
    Detection span(EntityType type, String text, String value,
        {DetectionSource source = DetectionSource.model}) {
      final start = text.indexOf(value);
      return d(type, text, start, start + value.length, source: source, confidence: 0.9);
    }

    Future<List<String>> hidden(String text, List<Detection> found) async =>
        (await DetectionPipeline([_Fixed(found)]).run(text)).where((x) => x.enabled).map((x) => x.value).toList();

    test('a model span over two table rows is cut, and a column value is dropped', () async {
      // The statement photo: "Equity" (the last cell of one row) and the fund name
      // on the next row came out as one COMPANY, boxed across both rows.
      const text = 'Acme Holdings\tAH\t12.50\tEquity\n'
          'Borealis Partners\tBP\t8.10\tEquity\n'
          'Cobalt Freight\tCF\t3.30\tEquity\n';
      expect(await hidden(text, [span(EntityType.company, text, 'Equity\nBorealis Partners')]),
          ['Borealis Partners']);
    });

    test('public investment products stay visible, a fund house alone is still a company', () async {
      const text = 'Vanguard Total Stock Market ETF\tVTI\t290.82\n'
          'iShares Core S&P 500 ETF\tIVV\t590.98\n'
          'Invesco QQQ Trust Series I\tQQQ\t515.61\n'
          'Your adviser at Northwind Wealth is Anna Meyer.';
      expect(
          await hidden(text, [
            span(EntityType.company, text, 'Vanguard Total Stock Market'),
            span(EntityType.company, text, 'iShares Core S&P'),
            span(EntityType.company, text, 'Invesco', source: DetectionSource.bundledList),
            span(EntityType.company, text, 'Northwind Wealth'),
            span(EntityType.person, text, 'Anna Meyer'),
          ]),
          ['Northwind Wealth', 'Anna Meyer']);
    });

    test('a product name is read to the end of the word the span stops in, whatever type it got', () async {
      // The statement photo: the model stopped at "Vanguard S" of "Vanguard S&P 500 ETF",
      // and ML Kit called "Invesco Q0Q Trust Series I" an address.
      const text = 'Vanguard S&P 500 ETF\tVOO\t540.99\n'
          'Invesco Q0Q Trust Series I\tQQQ\t515.61\n';
      expect(
          await hidden(text, [
            span(EntityType.company, text, 'Vanguard S'),
            span(EntityType.address, text, 'Invesco Q0Q Trust Series I'),
          ]),
          isEmpty);
    });

    test('a company that only mentions a product later in the sentence is still hidden', () async {
      const text = 'Vanguard sold me an ETF last year.';
      expect(await hidden(text, [span(EntityType.company, text, 'Vanguard')]), ['Vanguard']);
    });
  });
}

class _Fixed implements Detector {
  _Fixed(this.found);

  final List<Detection> found;

  @override
  String get name => 'fixed';

  @override
  Future<List<Detection>> detect(String text) async => found;
}
