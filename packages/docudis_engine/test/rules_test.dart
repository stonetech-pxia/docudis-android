import 'dart:convert';
import 'dart:io';

import 'package:docudis_engine/docudis_engine.dart';
import 'package:test/test.dart';

/// Packs whose `examples` must all match; the rest only need to compile.
const fullyTested = {'universal', 'cn', 'us', 'gb', 'fr', 'es'};

void main() {
  group('rule packs', () {
    test('every bundled pack compiles', () {
      for (final entry in bundledRulePackSources.entries) {
        final rules = parseRulePack(entry.value);
        expect(rules, isNotEmpty, reason: entry.key);
      }
    });

    test('an old or unknown rule schema is rejected explicitly', () {
      expect(() => parseRulePack('{"schemaVersion":1}'), throwsFormatException);
    });


    test('classification metadata is complete and internally consistent', () {
      final ids = <String>{};
      for (final entry in bundledRulePackSources.entries) {
        final rules = parseRulePack(entry.value);
        for (final rule in rules) {
          expect(ids.add(rule.id), isTrue, reason: 'duplicate ${rule.id}');
          expect(rule.id, startsWith('regex:${entry.key}:'), reason: rule.id);
          expect(rule.classification.subtype, matches(RegExp(r'^[a-z][a-z0-9_]*$')), reason: rule.id);
          if (rule.classification.applicability == RuleApplicability.specialized) {
            expect(rule.classification.verticals, isNotEmpty, reason: rule.id);
          }
        }
      }
      expect(ids, hasLength(207));
    });

    test('pack scope keeps jurisdiction separate from language', () {
      final universal = parseRulePack(bundledRulePackSources['universal']!).first.scope;
      expect(universal.jurisdictions, isEmpty);
      expect(universal.languages, isEmpty);

      final french = parseRulePack(bundledRulePackSources['fr']!).first.scope;
      expect(french.jurisdictions, {'FR'});
      expect(french.languages, {'fr'});

      final swiss = parseRulePack(bundledRulePackSources['ch']!).first.scope;
      expect(swiss.jurisdictions, {'CH'});
      expect(swiss.languages, {'de', 'fr', 'it'});
    });

    test('profile selection keeps baseline rules and filters specialized ones', () {
      final healthcare = RegexDetector.bundled(
        selection: const RuleSelection(
          jurisdictions: {'FR'},
          verticals: {RuleVertical.healthcare},
        ),
      ).rules.map((rule) => rule.id).toSet();

      expect(healthcare, contains('regex:universal:email'));
      expect(healthcare, contains('regex:universal:iban'));
      expect(healthcare, contains('regex:fr:nir'));
      expect(healthcare, contains('regex:fr:carte_vitale'));
      expect(healthcare, isNot(contains('regex:fr:siret')));
      expect(healthcare, isNot(contains('regex:universal:currency_symbol_suffix')));
      expect(healthcare, isNot(contains('regex:universal:url')));
    });

    test('explicit rule overrides win over profile and category defaults', () {
      final selected = RegexDetector.bundled(
        selection: const RuleSelection(
          jurisdictions: {'FR'},
          verticals: {RuleVertical.healthcare},
          categories: {RuleCategory.contact},
          enabledRuleIds: {'regex:fr:siret'},
          disabledRuleIds: {'regex:universal:email'},
        ),
      ).rules.map((rule) => rule.id).toSet();

      expect(selected, contains('regex:fr:siret'));
      expect(selected, isNot(contains('regex:universal:email')));
      expect(selected, contains('regex:fr:phone'));
      expect(selected.every((id) => id == 'regex:fr:siret' || id.contains('phone')), isTrue);
    });

    test('an explicit jurisdiction loads its pack plus global rules', () {
      final ids = RegexDetector.bundled(
        selection: const RuleSelection(
          jurisdictions: {'CH'},
          includeAllSpecialized: true,
        ),
      ).rules.map((rule) => rule.id);

      expect(ids, contains('regex:universal:email'));
      expect(ids, contains('regex:ch:ahv-avs-number'));
      expect(ids, isNot(contains('regex:fr:nir')));
    });

    test('omitting a profile preserves the complete legacy rule set', () {
      expect(RegexDetector.bundled().rules, hasLength(207));
    });

    for (final region in fullyTested) {
      group(region, () {
        final rules = parseRulePack(bundledRulePackSources[region]!);
        for (final rule in rules) {
          for (final example in rule.examples) {
            test('${rule.id} matches "$example"', () {
              final detector = RegexDetector([rule]);
              final hits = detector.detectSync(example);
              expect(hits, isNotEmpty);
              expect(hits.first.type, RegexDetector.typeFor(rule, hits.first.value));
              expect(hits.first.source, RegexDetector.sourceFor(rule));
            });
          }
        }
      });
    }

    test('regions follow the detected languages', () {
      const latin = 'plain text';
      expect(RegexDetector.regionsForLanguages(['en-US'], latin), {'us', 'gb', 'ie'});
      expect(RegexDetector.regionsForLanguages(['fr', 'zh'], latin), {'cn', 'fr', 'be', 'ch'});
      expect(RegexDetector.regionsForLanguages(['hi'], latin), <String>{});
      expect(RegexDetector.regionsForLanguages(['und'], latin), RegexDetector.defaultRegions);
      expect(RegexDetector.regionsForLanguages([], latin), RegexDetector.defaultRegions);
    });

    test('Chinese packs follow Chinese characters, not a fixed home market', () {
      // Language id often reports only the main language of a mixed text.
      expect(RegexDetector.regionsForLanguages(['en'], 'Met 王芳 in Shenzhen'), {'cn', 'us', 'gb', 'ie'});
      expect(RegexDetector.regionsForLanguages([], '王芳'), {...RegexDetector.defaultRegions, 'cn'});
      // Kanji are Han too, but Japanese text is not Chinese.
      expect(RegexDetector.regionsForLanguages(['ja'], '東京都港区'), {'jp'});
    });

    test('Chinese "6 digits = postal code" stays off English and French prose', () {
      const en = 'Invoice for order 450012 is attached.';
      const fr = 'La commande 450012 est expédiée.';
      for (final (tags, text) in [(['en'], en), (['fr'], fr)]) {
        final hits = RegexDetector.bundled(
          regions: RegexDetector.regionsForLanguages(tags, text),
        ).detectSync(text);
        expect(hits.map((d) => d.detector), isNot(contains('regex:cn:postal')), reason: text);
      }
    });

    test('region gating keeps foreign postal rules off English prose', () {
      const text = 'The contract was signed on 12 March 2024 and expires soon.';
      final all = DetectionPipeline.merge(text, RegexDetector.bundled().detectSync(text));
      final gated = DetectionPipeline.merge(
        text,
        RegexDetector.bundled(
          regions: RegexDetector.regionsForLanguages(['en'], text),
        ).detectSync(text),
      );
      // With every pack on, an Austrian "4-digit postal code + city" rule
      // swallows the date; gated to English regions the date survives.
      expect(all.map((d) => d.value), isNot(contains('12 March 2024')));
      expect(gated.map((d) => d.value), ['12 March 2024']);
    });

    test('the universal postal rule needs a postal code and a city name', () {
      final detector = RegexDetector.bundled(regions: {});
      Iterable<String> addresses(String text) => detector
          .detectSync(text)
          .where((d) => d.type == EntityType.address)
          .map((d) => d.value);

      // Real "postal code + city" pairs the rule exists for.
      expect(addresses('Ship to 75008 Paris, France'), contains('75008 Paris'));
      expect(addresses('ul. Nowy Świat, 00-950 Warszawa'), contains('00-950 Warszawa'));
      expect(addresses('Box 12, 111 22 Stockholm'), contains('111 22 Stockholm'));
      // Numbers in ordinary English and French prose are not addresses.
      for (final text in [
        'Invoice 482913 for order 450012 is attached.',
        'Q3 revenue reached 350000 units across 120 stores.',
        'Le ticket 845210 est clos et 125000 unités sont vendues.',
        'En 2024 en Espagne, les ventes ont doublé.',
      ]) {
        expect(addresses(text), isEmpty, reason: text);
      }
    });

    test('amounts with a trailing euro sign are detected', () {
      final detector = RegexDetector.bundled(regions: {'fr'});
      Iterable<String> amounts(String text) => detector
          .detectSync(text)
          .where((d) => d.type == EntityType.amount)
          .map((d) => d.value);

      // How French, German and Spanish documents write money.
      expect(amounts('montant total 12 450,00 €'), contains('12 450,00 €'));
      expect(amounts('la facture de 4 200 €'), contains('4 200 €'));
      expect(amounts('un acompte de 1.234,56 €'), contains('1.234,56 €'));
      // A non-breaking space is what word processors insert.
      expect(amounts('montant : 12 450,00 €'), contains('12 450,00 €'));
    });

    test('validated rule rejects a bad checksum', () {
      final detector = RegexDetector.bundled(regions: {});
      // Valid Luhn (test Visa) vs same digits with the last one changed.
      expect(
        detector.detectSync('card 4111 1111 1111 1111').map((d) => d.type),
        contains(EntityType.card),
      );
      expect(
        detector.detectSync('card 4111 1111 1111 1112').where(
          (d) => d.type == EntityType.card,
        ),
        isEmpty,
      );
    });
  });

  group('gaps found by the NER benchmark', () {
    List<Detection> run(List<String> langs, String text) {
      final regions = RegexDetector.regionsForLanguages(langs, text);
      return DetectionPipeline.merge(
          text, RegexDetector.bundled(regions: regions).detectSync(text));
    }

    test('a year before "à + city" is a date, not a Belgian or Swiss postal address', () {
      const text = 'née le 3 avril 1987 à Bordeaux, employée depuis le 1er septembre 2015.';
      final found = run(['fr'], text);
      expect(found.map((d) => d.value), containsAll(['3 avril 1987', '1er septembre 2015']));
      expect(found.where((d) => d.type == EntityType.address), isEmpty);
    });

    test('Belgian and Swiss postal codes still match a capitalised city', () {
      expect(run(['fr'], 'Adresse : 1000 Bruxelles').map((d) => d.value), ['1000 Bruxelles']);
      expect(run(['fr'], 'Adresse : 8001 Zürich').map((d) => d.value), ['8001 Zürich']);
    });

    test('Spanish dates written with a month name', () {
      final found = run(['es'], 'entregado el 20 de mayo de 2024 y el 1 de enero del 2023.');
      expect(found.where((d) => d.type == EntityType.date).map((d) => d.value),
          ['20 de mayo de 2024', '1 de enero del 2023']);
    });

    test('UK landlines in their usual spacings are phones, not ids', () {
      final found = run(['en'], 'call 0161 276 1234 or 020 7946 0958 today');
      expect(found.map((d) => (d.type, d.value)), [
        (EntityType.phone, '0161 276 1234'),
        (EntityType.phone, '020 7946 0958'),
      ]);
    });

    test('currency code before the amount, with a scale word', () {
      final found = run(['en'], 'revenue reached NZD 4.2 million and costs USD 1,250.50.');
      expect(found.where((d) => d.type == EntityType.amount).map((d) => d.value),
          ['NZD 4.2 million', 'USD 1,250.50']);
    });

    test('name rules stop at a line break (OCR puts every field on its own line)', () {
      const text = 'Bill to : Robert Johnson\nAcme Corp\n12 High Street, Bristol';
      expect(run(['en'], text).map((d) => d.value), ['Acme Corp', '12 High Street']);
    });

    test('a Chinese address ends at the house number, not at the next entity', () {
      // The prefix is greedy over Han characters, so the second address is
      // preceded by punctuation here; "改为上海市…" would keep the two prose characters.
      const text = '地点：杭州市余杭区文一西路969号阿里巴巴西溪园区三号楼会议室。新地点：上海市静安区南京西路1266号恒隆广场办公室。';
      expect(run(['zh'], text).map((d) => d.value),
          ['杭州市余杭区文一西路969号', '上海市静安区南京西路1266号']);
      expect(run(['zh'], '收货地址：广东省深圳市南山区科技园南路88号3栋502室。').map((d) => d.value),
          ['广东省深圳市南山区科技园南路88号3栋502室']);
      // The prefix is bounded, so at most two prose characters before the city leak in.
      final trad = run(['zh'], '陳大文先生與林美玲小姐將於臺北市信義區出席會議。').map((d) => d.value).single;
      expect(trad, endsWith('臺北市信義區'));
      expect(trad.length, lessThanOrEqualTo('臺北市信義區'.length + 2));
    });

    test('an English institution named after a place is a company', () {
      final found = run(['en'], 'Dr. Alan Turing at Manchester Royal Infirmary is confirmed.');
      expect(found.map((d) => (d.type, d.value)),
          [(EntityType.company, 'Manchester Royal Infirmary')]);
    });
  });
  group('real-document rule fixes (2026-09-18)', () {
    List<Detection> run(List<String> langs, String text) {
      final regions = RegexDetector.regionsForLanguages(langs, text);
      return DetectionPipeline.merge(
          text, RegexDetector.bundled(regions: regions).detectSync(text));
    }

    Iterable<String> values(List<Detection> found, EntityType type) =>
        found.where((d) => d.type == type).map((d) => d.value);

    test('a French date keeps its year: the Swiss 4-digit postcode rule no longer grabs "2025 Échéance"', () {
      final found = run(['fr'], 'Date de facturation : 8 juillet 2025        Échéance : 09/09/2026        Paiement : comptant');
      expect(values(found, EntityType.date), ['8 juillet 2025', '09/09/2026']);
      expect(values(found, EntityType.address), isEmpty);
    });

    test('Belgian and Swiss postcodes still match after a comma or at the start of a line', () {
      expect(values(run(['fr'], 'Rue de la Loi 16, 1000 Bruxelles'), EntityType.address), contains('1000 Bruxelles'));
      expect(values(run(['fr'], 'Case postale\n1211 Genève'), EntityType.address), contains('1211 Genève'));
    });

    test('a SIRET is one identifier: its last block is not a postcode', () {
      final found = run(['fr'], 'SIRET : 491 151 474 00098    Code NAF : 4332A');
      expect(values(found, EntityType.address), isEmpty);
      expect(values(found, EntityType.number), ['491 151 474 00098']);
    });

    test('French street, house number and postcode are all covered', () {
      final found = run(['fr'], 'Adresse : 100 Boulevard Halidi Selemani 97600 Mamoudzou');
      expect(values(found, EntityType.address).map((v) => v.trim()), ['100 Boulevard Halidi Selemani', '97600 Mamoudzou']);
      expect(values(run(['fr'], 'Siège social : 7b Rue de Fruges, 62560 Fauquembergues'), EntityType.address).map((v) => v.trim()),
          ['7b Rue de Fruges', '62560 Fauquembergues']);
    });

    test('Spanish postcode beats the model and may follow a house number', () {
      final found = run(['es'], 'Calle de Alcalá 142, 28009 Madrid. Domicilio: AVDA DE VALENCIA, 8 02660 (CAUDETE).');
      expect(values(found, EntityType.address), containsAll(['Calle de Alcalá 142', '28009 Madrid', '02660 (CAUDETE)']));
      expect(found.firstWhere((d) => d.value == '28009 Madrid').source, DetectionSource.strongRule);
    });

    test('Spanish streets: C/, Carrer, Gran Vía, floor and door', () {
      for (final street in ['C/ PONTEVEDRA, 1 4º D', 'Carrer de Mallorca 275', 'Gran Vía 45', 'Paseo de Pereda 22']) {
        expect(values(run(['es'], 'Domicilio: $street.'), EntityType.address), [street], reason: street);
      }
      expect(run(['es'], 'C. Domicilio no consta en el expediente y queda una plaza 3 días.'), isEmpty);
    });

    test('amounts without a thousands separator or with the currency as a word', () {
      expect(values(run(['fr'], 'au prix stipulé de 125000.00 euros, capital : 1000.00 EUR, soit 445000 EUR'), EntityType.amount),
          ['125000.00 euros', '1000.00 EUR', '445000 EUR']);
      expect(values(run(['es'], 'Capital: 60.000,00 Euros. Resultante Suscrito: 63.000,00 Euros.'), EntityType.amount),
          ['60.000,00 Euros', '63.000,00 Euros']);
    });

    test('two-digit-year dates, but not version or section numbers', () {
      expect(values(run(['es'], 'Datos registrales. S 8 , H AB 23576, I/A 5 ( 4.09.24).'), EntityType.date), ['4.09.24']);
      expect(run(['en'], 'Version 4.09.24 fixes section 3.2.1; build 1.12.22 and clause 12.3.19 are unchanged.'), isEmpty);
    });

    test('year and page ranges are not identifiers', () {
      expect(run(['en'], 'Analyst (2017 - 2021), trainee (2016 - 2017), pages 120 - 135, rows 1000 - 2000.'), isEmpty);
    });

    test('companies: capitalised run plus legal form, not the sentence before it', () {
      expect(values(run(['es'], 'La empresa contrató a Transportes Guadalquivir S.A. en marzo.'), EntityType.company),
          ['Transportes Guadalquivir S.A.']);
      expect(values(run(['es'], '393333 - GASOLEOS HERMANOS RODRIGUEZ SOCIEDAD LIMITADA. Nombramientos.'), EntityType.company),
          ['GASOLEOS HERMANOS RODRIGUEZ SOCIEDAD LIMITADA']);
      expect(values(run(['en'], 'Name of Company: ALPHA KILO CREATIVE LIMITED'), EntityType.company), ['ALPHA KILO CREATIVE LIMITED']);
      expect(values(run(['fr'], 'désignant liquidateur Selarl Amandine Riquelme, et la SAS BLENET-CHUL'), EntityType.company),
          ['Selarl Amandine Riquelme', 'SAS BLENET-CHUL']);
      expect(run(['en'], 'Name of Company: to be completed\nEmployer: pending'), isEmpty);
    });

    test('company after a form label, and business names that start with a trade noun', () {
      expect(values(run(['fr'], 'Sigle : MECADISTRIB\nEmployeur : Menuiserie Berthelot'), EntityType.company),
          ['MECADISTRIB', 'Menuiserie Berthelot']);
      expect(values(run(['fr'], 'pris en charge par Mutuelle Horizon Santé, puis par la mutuelle.'), EntityType.company),
          ['Mutuelle Horizon Santé']);
      expect(run(['fr'], 'Dénomination : à compléter. La clinique et le cabinet sont fermés.'), isEmpty);
    });

    test('French trade register and court lines hide the town', () {
      final found = run(['fr'], 'Greffe du Tribunal de Commerce de Reims\nRCS Reims 838 805 653');
      expect(found.map((d) => d.value), ['Greffe du Tribunal de Commerce de Reims', 'RCS Reims 838 805 653']);
    });

    test('web addresses: scheme, www, or a bare domain with a path', () {
      expect(values(run(['en'], 'See linkedin.com/in/thomas-gallagher, https://example.com/p?id=7. and www.example.org.'), EntityType.url),
          ['linkedin.com/in/thomas-gallagher', 'https://example.com/p?id=7', 'www.example.org']);
      expect(run(['en'], 'Read manual.pdf, then the notice in lesechos.fr or readme.txt.'), isEmpty);
    });

    test('hard negatives: no rule and no bundled name fires on look-alike text', () {
      final doc = jsonDecode(File('../../benchmark/hard_negatives.json').readAsStringSync()) as Map<String, dynamic>;
      final lists = BundledListDetector.bundled();
      for (final c in (doc['cases'] as List).cast<Map<String, dynamic>>()) {
        final text = c['text'] as String;
        final found = [...run([c['lang'] as String], text), ...lists.detectSync(text)];
        expect(found.map((d) => '${d.detector}: ${d.value}'), isEmpty, reason: c['id'] as String);
      }
    });
  });

  group('rule audit fixes (2026-09-18)', () {
    List<Detection> run(List<String> langs, String text) {
      final regions = RegexDetector.regionsForLanguages(langs, text);
      return DetectionPipeline.merge(
          text, RegexDetector.bundled(regions: regions).detectSync(text));
    }

    Iterable<String> values(List<Detection> found, EntityType type) =>
        found.where((d) => d.type == type).map((d) => d.value);

    test('a French phone number written with dots or hyphens is one phone, not an IP address', () {
      final found = run(['fr'], 'Tél. 01.23.45.67.89 / 06-12-34-56-78, serveur 192.168.1.1.');
      expect(values(found, EntityType.phone), ['01.23.45.67.89', '06-12-34-56-78']);
      expect(values(found, EntityType.ip), ['192.168.1.1']);
      expect(values(run(['fr'], 'Reçu le 01.02.2024 12:30'), EntityType.phone), isEmpty);
    });

    test('an international phone number ends with its line', () {
      final fr = run(['fr'], 'Contact : +33 6 12 34 56 78\n75008 Paris');
      expect(values(fr, EntityType.phone), ['+33 6 12 34 56 78']);
      expect(values(fr, EntityType.address), ['75008 Paris']);
      final en = run(['en'], 'Phone +44 20 7946 0958\n2024 Annual Report');
      expect(values(en, EntityType.phone), ['+44 20 7946 0958']);
    });

    test('a SIRET passes the Luhn check by design: after its label it is a number, not a card', () {
      final found = run(['fr'], 'SIRET : 73282932000074, Siret n° 44306184100047. Carte 4532 0151 1283 0366.');
      expect(values(found, EntityType.number), ['73282932000074', '44306184100047']);
      expect(values(found, EntityType.card), ['4532 0151 1283 0366']);
    });

    test('an Eircode needs the Eircode alphabet: road numbers and order numbers are not addresses', () {
      final found = run(['en'],
          'Take vitamin B12 with food. The M25 near Heathrow, the A40 into London. G20 will meet. E10 fuel. '
          'Order P604512, ticket T123456, part A12 3456. HEADING: THE N17 ROAD. Eircode D08 YX4T or A65F4E2.');
      expect(values(found, EntityType.address), ['D08 YX4T', 'A65F4E2']);
    });

    test('English streets are capitalised: "10 minute drive" is prose', () {
      final prose = run(['en'],
          'It is a 10 minute drive or a 5 minute walk. We saw a 15 percent rise and 3 people took place. '
          'After 2 years close to 20 percent way above. Top 10 car park. In 30 days court will decide.');
      expect(values(prose, EntityType.address), isEmpty);
      final real = run(['en'], 'She lives at 221B Baker Street, he at 350 5th Avenue, New York. Registered office: 12 HIGH STREET, LEEDS.');
      expect(values(real, EntityType.address), ['221B Baker Street', '350 5th Avenue', '12 HIGH STREET']);
    });
  });

  group('OCR output from the phone (2026-09-19)', () {
    List<Detection> run(List<String> langs, String text) {
      final regions = RegexDetector.regionsForLanguages(langs, text);
      return DetectionPipeline.merge(
          text, RegexDetector.bundled(regions: regions).detectSync(text));
    }

    Iterable<String> values(List<Detection> found, EntityType type) =>
        found.where((d) => d.type == type).map((d) => d.value);

    test('an e-mail address with a stray space next to the @ is still one e-mail', () {
      final found = run(['es'], 'Tel. 954 21 07 63 · citas@ sonrisasur-ejemplo.es\nCorreo: lucia.fernandez @ejemplo.es');
      expect(values(found, EntityType.email), ['citas@ sonrisasur-ejemplo.es', 'lucia.fernandez @ejemplo.es']);
    });

    test('an e-mail address with a space after a dot is still one e-mail (2026-09-23, both phones)', () {
      final found = run(['en'], 'Please contact Priya Raman at priya. raman@example. com for details.\n'
          'eleanor.whitcombe@example. org\t+44 7700 900123');
      expect(values(found, EntityType.email), ['priya. raman@example. com', 'eleanor.whitcombe@example. org']);
    });

    test('the space after a dot does not pull in the next sentence', () {
      final found = run(['en'], 'Write to anna@example.com. then call. Or bob@example. The end. '
          'Reach me now. dana.whitfield@example.com');
      expect(values(found, EntityType.email), ['anna@example.com', 'dana.whitfield@example.com']);
    });

    test('an international number whose + was read as "t" is still a phone (2026-09-23, iOS)', () {
      final found = run(['en'], 'eleanor. whitcombe@example. org\tt447700 900123\nFlat 12, 4467 at 2024-01-05');
      expect(values(found, EntityType.phone), ['t447700 900123']);
    });

    test('Spanish landlines are written 3-2-2-2 or 2-3-2-2', () {
      final found = run(['es'], 'Tel. 954 21 07 63, fax 91 234 56 78, móvil 612 345 678.');
      expect(values(found, EntityType.phone), ['954 21 07 63', '91 234 56 78', '612 345 678']);
    });

    test('a phone number wrapped onto the next line is one phone', () {
      expect(values(run(['es'], 'contacte con Javier Molina, en el 954 21\n07 65.\nAtentamente,'), EntityType.phone),
          ['954 21\n07 65']);
      expect(values(run(['fr'], 'Vous pouvez me joindre au 06 12 34\n56 78 ou par e-mail.'), EntityType.phone),
          ['06 12 34\n56 78']);
      expect(values(run(['fr'], 'Standard : 01\n23 45 67 89'), EntityType.phone), ['01\n23 45 67 89']);
    });

    test('a dotted date followed by an hour on the next line is still not a French phone', () {
      expect(values(run(['fr'], 'Reçu le 01.02.2024\n12:30'), EntityType.phone), isEmpty);
      expect(values(run(['fr'], 'Reçu le 01.02.20\n12.30'), EntityType.phone), isEmpty);
    });
  });

  group('OCR output from the phone (2026-09-23)', () {
    List<Detection> run(List<String> langs, String text) {
      final regions = RegexDetector.regionsForLanguages(langs, text);
      return DetectionPipeline.merge(
          text, RegexDetector.bundled(regions: regions).detectSync(text));
    }

    Iterable<String> values(List<Detection> found, EntityType type) =>
        found.where((d) => d.type == type).map((d) => d.value);

    test('a zero read as the letter o still makes a phone, kept as written', () {
      // Old-style figures (Georgia): ML Kit read 0113 496 0721 and 06 … as o.
      final gb = run(['en'], 'Phone: o113 496 o721');
      expect(values(gb, EntityType.phone), ['o113 496 o721']);
      expect((gb.single.start, gb.single.end), (7, 20));
      expect(values(run(['fr'], 'Je reste joignable au o6 42 18 73 95 pour toute question.'), EntityType.phone),
          ['o6 42 18 73 95']);
    });

    test('words with an o are left alone', () {
      expect(run(['en'], 'Good morning, No 12 is open. Oo 45 67 89.'), isEmpty);
    });

    test('a match stays inside its cell: OCR joins the cells of a row with tabs', () {
      final fr = run(['fr'], '27 rue des Tanneurs\tCabinet Vallerand & Associés');
      expect(values(fr, EntityType.address), ['27 rue des Tanneurs']);
      final en = run(['en'], '28 Aug\tDirect debit Yorkshire Water 7730215\t41.60\t3,815.55');
      expect(en.where((d) => d.value.contains('\t')), isEmpty);
      expect(en.where((d) => d.value.contains('41.60')), isEmpty);
    });

    test('a label may still sit one cell before its value', () {
      expect(values(run(['fr'], 'IBAN FR35 3000 4028 3700 0104 5791 382\tBIC\tBNPAFRPPXXX'), EntityType.iban),
          ['FR35 3000 4028 3700 0104 5791 382']);
      expect(run(['fr'], 'BIC\tBNPAFRPPXXX').map((d) => d.value), ['BNPAFRPPXXX']);
    });
  });

  group('phone walkthrough (2026-09-23)', () {
    List<Detection> run(List<String> langs, String text) {
      final regions = RegexDetector.regionsForLanguages(langs, text);
      return DetectionPipeline.merge(
          text, RegexDetector.bundled(regions: regions).detectSync(text));
    }

    List<(EntityType, String)> found(List<String> langs, String text) =>
        [for (final d in run(langs, text)) (d.type, d.value)];

    test('a labelled ID that fails its checksum is still hidden, as a NUMBER', () {
      expect(found(['es'], 'Me llamo Lucía, DNI 48291736K, vivo en Madrid.'),
          [(EntityType.number, '48291736K')]);
      expect(found(['es'], 'DNI 48291736Q'), [(EntityType.id, '48291736Q')]);
      expect(found(['es'], 'NIE X1234567L'), [(EntityType.id, 'X1234567L')]);
      expect(found(['en'], 'NHS number 485 777 3456.'), [(EntityType.number, '485 777 3456')]);
      expect(found(['en'], 'NHS number 943 476 5919.'), [(EntityType.id, '943 476 5919')]);
      expect(found(['fr'], 'N° de sécurité sociale : 1 84 07 31 555 042 17'),
          [(EntityType.number, '1 84 07 31 555 042 17')]);
    });

    test('the value stops where the sentence goes on', () {
      expect(found(['es'], 'DNI 48291736K y NIE X1234567L.').map((f) => f.$2), ['48291736K', 'X1234567L']);
      expect(found(['es'], 'El DNI es obligatorio.'), isEmpty);
    });

    test('a CUPS is a NUMBER when its control letters hold, and when a label names it', () {
      expect(found(['es'], 'el CUPS ES0021000012345678LB. Me han cobrado'),
          [(EntityType.number, 'ES0021000012345678LB')]);
      expect(found(['es'], 'suministro ES 0021 0000 1234 5678 LB'),
          [(EntityType.number, 'ES 0021 0000 1234 5678 LB')]);
      expect(found(['es'], 'CUPS ES0021000012345678AB'), [(EntityType.number, 'ES0021000012345678AB')]);
      expect(found(['es'], 'suministro ES0021000012345678AB'), isEmpty);
    });
  });

  group('files compared with StripPii (2026-09-26)', () {
    List<Detection> run(List<String> langs, String text) {
      final regions = RegexDetector.regionsForLanguages(langs, text);
      return DetectionPipeline.merge(
          text, RegexDetector.bundled(regions: regions).detectSync(text));
    }

    Iterable<String> values(List<Detection> found) => found.map((d) => d.value);

    test('a short or letters-only value after an identifier label is hidden', () {
      // A medical form and a bank statement photographed: both values stayed visible.
      expect(values(run(['en'], 'Group #: LN59C\tSocial Security #: 811476374')), contains('LN59C'));
      expect(values(run(['en'], 'Your Financial Consultant: Dr. Gregory Frami\nID: jUefATevv')),
          contains('jUefATevv'));
      expect(values(run(['en'], 'Member ID: 1QOSXUUS6G')), contains('1QOSXUUS6G'));
    });

    test('a phone number broken over two lines at a space is still one phone', () {
      for (final (langs, text, phone) in [
        (['fr'], 'Secrétariat : 03 27 55\n41 86 – Fax : 03 27 55 41 90', '03 27 55\n41 86'),
        (['es'], 'CIF A36284917 - Tel. 986 50\n71 00 - www.illadecortegada.es', '986 50\n71 00'),
        (['en'], 'call us on 0117 496\n0153 or 03457 888 444', '0117 496\n0153'),
      ]) {
        expect(values(run(langs, text)), contains(phone), reason: text);
      }
    });

    test('numbers on consecutive lines that make no phone stay apart', () {
      expect(values(run(['en'], 'Page 2\n14 Harbour Lane, Bristol')).where((v) => v.contains('\n')), isEmpty);
      expect(values(run(['fr'], 'Total 12\n34 articles')).where((v) => v.contains('\n')), isEmpty);
    });

    test('an ordinary word after the same labels is not an identifier', () {
      for (final text in ['ID: Smith', 'Group: Equity', 'Member: John Smith', 'Policy: Standard',
                          'Login: required', 'ID: PASSPORT', 'Group #: A']) {
        expect(run(['en'], text), isEmpty, reason: text);
      }
    });
  });
}
