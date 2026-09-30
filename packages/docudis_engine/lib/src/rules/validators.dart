// Post-match validators for the rule packs, ported from DocCloak.Core
// (src/regex/validators.ts, Apache-2.0). Behaviour is kept identical so the
// packs' `examples` remain valid across runtimes.

import 'dart:math' as math;

typedef RuleValidator = bool Function(String match);

final RegExp _digitsOnly = RegExp(r'^\d+$');

String _digits(String s) => s.replaceAll(RegExp(r'\D'), '');

/// Luhn checksum over the digits of the match (card numbers).
bool luhn(String match) {
  final digits = match.replaceAll(RegExp(r'[\s-]'), '');
  if (!_digitsOnly.hasMatch(digits)) return false;
  var sum = 0;
  var alternate = false;
  for (var i = digits.length - 1; i >= 0; i--) {
    var n = int.parse(digits[i]);
    if (alternate) {
      n *= 2;
      if (n > 9) n -= 9;
    }
    sum += n;
    alternate = !alternate;
  }
  return sum % 10 == 0;
}

/// IBAN mod-97 check (ISO 13616).
bool ibanMod97(String match) {
  final clean = match.replaceAll(RegExp(r'\s'), '').toUpperCase();
  if (clean.length < 5 || clean.length > 34) return false;
  final rearranged = clean.substring(4) + clean.substring(0, 4);
  final buf = StringBuffer();
  for (final unit in rearranged.codeUnits) {
    if (unit >= 48 && unit <= 57) {
      buf.writeCharCode(unit);
    } else {
      buf.write(unit - 55);
    }
  }
  final numStr = buf.toString();
  var remainder = 0;
  for (var i = 0; i < numStr.length; i++) {
    remainder = (remainder * 10 + int.parse(numStr[i])) % 97;
  }
  return remainder == 1;
}

/// Every dotted octet of an IPv4 address is in 0-255.
bool ipOctets(String ip) => ip.split('.').every((o) {
      final n = int.tryParse(o);
      return n != null && n >= 0 && n <= 255;
    });

/// UK National Insurance Number structural rules.
bool nino(String match) {
  final clean = match.replaceAll(RegExp(r'\s'), '').toUpperCase();
  if (RegExp(r'^[DFIQUV]').hasMatch(clean)) return false;
  if (RegExp(r'^.[DFIOQUV]').hasMatch(clean)) return false;
  if (RegExp(r'^(?:BG|GB|NK|KN|TN|NT|ZZ)').hasMatch(clean)) return false;
  return true;
}

/// UK NHS number mod-11 check digit.
bool nhs(String match) {
  final digits = _digits(match);
  if (digits.length != 10) return false;
  const weights = [10, 9, 8, 7, 6, 5, 4, 3, 2];
  var sum = 0;
  for (var i = 0; i < 9; i++) {
    sum += int.parse(digits[i]) * weights[i];
  }
  final check = 11 - (sum % 11);
  if (check == 11) return int.parse(digits[9]) == 0;
  if (check == 10) return false;
  return check == int.parse(digits[9]);
}

/// UK driving licence: only the encoded date-of-birth block is validated.
bool ukDrivingLicence(String match) {
  final clean = match.replaceAll(RegExp(r'\s'), '').toUpperCase();
  if (clean.length != 16) return false;
  final dob = clean.substring(5, 11);
  if (!RegExp(r'^\d{6}$').hasMatch(dob)) return false;
  final rawMonth = int.parse(dob.substring(1, 3));
  final month = rawMonth > 50 ? rawMonth - 50 : rawMonth;
  if (month < 1 || month > 12) return false;
  final day = int.parse(dob.substring(3, 5));
  if (day < 1 || day > 31) return false;
  return true;
}

/// Polish PESEL weighted checksum.
bool pesel(String match) {
  final digits = _digits(match);
  if (digits.length != 11) return false;
  const weights = [1, 3, 7, 9, 1, 3, 7, 9, 1, 3];
  var sum = 0;
  for (var i = 0; i < 10; i++) {
    sum += int.parse(digits[i]) * weights[i];
  }
  final check = (10 - (sum % 10)) % 10;
  return check == int.parse(digits[10]);
}

/// Polish ID card (3 letters + 6 digits) weighted checksum.
bool plIdCard(String match) {
  final clean = match.replaceAll(RegExp(r'\s'), '').toUpperCase();
  if (clean.length != 9) return false;
  const weights = [7, 3, 1, 0, 7, 3, 1, 7, 3];
  var sum = 0;
  for (var i = 0; i < 9; i++) {
    if (i == 3) continue;
    final unit = clean.codeUnitAt(i);
    final val =
        (unit >= 65 && unit <= 90) ? unit - 55 : int.tryParse(clean[i]);
    if (val == null) return false;
    sum += val * weights[i];
  }
  return sum % 10 == int.tryParse(clean[3]);
}

/// Polish NIP weighted mod-11 checksum.
bool nip(String match) {
  final digits = _digits(match);
  if (digits.length != 10) return false;
  const weights = [6, 5, 7, 2, 3, 4, 5, 6, 7];
  var sum = 0;
  for (var i = 0; i < 9; i++) {
    sum += int.parse(digits[i]) * weights[i];
  }
  return (sum % 11) == int.parse(digits[9]);
}

/// Polish REGON checksum (9- or 14-digit variant).
bool regon(String match) {
  final digits = _digits(match);
  if (digits.length == 9) {
    const weights = [8, 9, 2, 3, 4, 5, 6, 7];
    var sum = 0;
    for (var i = 0; i < 8; i++) {
      sum += int.parse(digits[i]) * weights[i];
    }
    final check = sum % 11 == 10 ? 0 : sum % 11;
    return check == int.parse(digits[8]);
  }
  if (digits.length == 14) {
    const weights = [2, 4, 8, 5, 0, 9, 7, 3, 6, 1, 2, 4, 8];
    var sum = 0;
    for (var i = 0; i < 13; i++) {
      sum += int.parse(digits[i]) * weights[i];
    }
    final check = sum % 11 == 10 ? 0 : sum % 11;
    return check == int.parse(digits[13]);
  }
  return false;
}

/// Swedish personnummer Luhn check (excludes samordningsnummer, day >= 61).
bool personnummer(String match) {
  final digits = match.replaceAll(RegExp(r'[\s-]'), '');
  if (digits.length < 10) return false;
  final cleanForDay = match.replaceAll(RegExp(r'[-+]'), '');
  if (cleanForDay.length < 6) return false;
  final day = int.tryParse(cleanForDay.substring(4, 6));
  if (day == null || day >= 61) return false;
  final last10 = digits.substring(digits.length - 10);
  var sum = 0;
  for (var i = 0; i < 9; i++) {
    var n = int.parse(last10[i]) * (i % 2 == 0 ? 2 : 1);
    if (n > 9) n -= 9;
    sum += n;
  }
  final check = (10 - (sum % 10)) % 10;
  return check == int.parse(last10[9]);
}

/// Swedish samordningsnummer: day portion is 61+.
bool samordningsnummer(String match) {
  final digits = match.replaceAll(RegExp(r'[-+]'), '');
  if (digits.length < 10) return false;
  final day = int.tryParse(digits.substring(4, 6));
  return day != null && day >= 61;
}

/// US DEA number checksum.
bool dea(String match) {
  final m = match.toUpperCase();
  if (!RegExp(r'^[ABCDEFGHJKLMPRSTUX][A-Z]\d{7}$').hasMatch(m)) return false;
  final d = m.substring(2).split('').map(int.parse).toList();
  final sum = d[0] + d[2] + d[4] + 2 * (d[1] + d[3] + d[5]);
  return sum % 10 == d[6];
}

/// US NPI Luhn check with the CMS-mandated 80840 prefix.
bool npi(String match) {
  final d = _digits(match);
  if (d.length != 10) return false;
  final payload = '80840${d.substring(0, 9)}';
  var sum = 0;
  var alt = true;
  for (var i = payload.length - 1; i >= 0; i--) {
    var n = int.parse(payload[i]);
    if (alt) {
      n *= 2;
      if (n > 9) n -= 9;
    }
    sum += n;
    alt = !alt;
  }
  final check = (10 - (sum % 10)) % 10;
  return check == int.parse(d[9]);
}

/// US ABA routing number checksum.
bool aba(String match) {
  final d = _digits(match);
  if (d.length != 9) return false;
  final n = d.split('').map(int.parse).toList();
  final sum = 3 * (n[0] + n[3] + n[6]) +
      7 * (n[1] + n[4] + n[7]) +
      (n[2] + n[5] + n[8]);
  return sum % 10 == 0;
}

/// French NIR / INSEE number: gender digit + mod-97 key.
bool nir(String match) {
  final digits = _digits(match);
  if (digits.length != 15) return false;
  final gender = digits[0];
  if (gender != '1' && gender != '2') return false;
  final first13 = int.parse(digits.substring(0, 13));
  final key = int.parse(digits.substring(13, 15));
  return (97 - (first13 % 97)) == key;
}

/// Spanish DNI: number mod 23 selects the control letter.
bool dni(String match) {
  final clean = match.replaceAll(RegExp(r'[\s-]'), '').toUpperCase();
  const letters = 'TRWAGMYFPDXBNJZSQVHLCKE';
  if (clean.length < 2) return false;
  final num = int.tryParse(clean.substring(0, clean.length - 1));
  if (num == null) return false;
  return letters[num % 23] == clean[clean.length - 1];
}

/// Spanish CUPS: the 16 digits after "ES" mod 529 give the two control
/// letters, quotient and remainder by 23, from the DNI alphabet.
bool cups(String match) {
  final clean = match.replaceAll(RegExp(r'\s'), '').toUpperCase();
  if (clean.length < 20) return false;
  final num = int.tryParse(clean.substring(2, 18));
  if (num == null) return false;
  const letters = 'TRWAGMYFPDXBNJZSQVHLCKE';
  final r = num % 529;
  return clean.substring(18, 20) == '${letters[r ~/ 23]}${letters[r % 23]}';
}

const _cfOdd = <String, int>{
  '0': 1, '1': 0, '2': 5, '3': 7, '4': 9, '5': 13, '6': 15, '7': 17, //
  '8': 19, '9': 21, 'A': 1, 'B': 0, 'C': 5, 'D': 7, 'E': 9, 'F': 13, //
  'G': 15, 'H': 17, 'I': 19, 'J': 21, 'K': 2, 'L': 4, 'M': 18, 'N': 20, //
  'O': 11, 'P': 3, 'Q': 6, 'R': 8, 'S': 12, 'T': 14, 'U': 16, 'V': 10, //
  'W': 22, 'X': 25, 'Y': 24, 'Z': 23,
};
const _cfEven = <String, int>{
  '0': 0, '1': 1, '2': 2, '3': 3, '4': 4, '5': 5, '6': 6, '7': 7, //
  '8': 8, '9': 9, 'A': 0, 'B': 1, 'C': 2, 'D': 3, 'E': 4, 'F': 5, //
  'G': 6, 'H': 7, 'I': 8, 'J': 9, 'K': 10, 'L': 11, 'M': 12, 'N': 13, //
  'O': 14, 'P': 15, 'Q': 16, 'R': 17, 'S': 18, 'T': 19, 'U': 20, 'V': 21, //
  'W': 22, 'X': 23, 'Y': 24, 'Z': 25,
};

/// Italian Codice Fiscale odd/even character table checksum.
bool codiceFiscale(String match) {
  final code = match.toUpperCase();
  if (code.length != 16) return false;
  var sum = 0;
  for (var i = 0; i < 15; i++) {
    final v = (i % 2 == 0) ? _cfOdd[code[i]] : _cfEven[code[i]];
    if (v == null) return false;
    sum += v;
  }
  final expected = String.fromCharCode(65 + (sum % 26));
  return code[15] == expected;
}

/// Italian Partita IVA Luhn-style checksum over 11 digits.
bool partitaIva(String match) {
  final digits = match.toUpperCase().replaceFirst(RegExp(r'^IT'), '');
  if (digits.length != 11 || !_digitsOnly.hasMatch(digits)) return false;
  var sum = 0;
  for (var i = 0; i < 11; i++) {
    var n = int.parse(digits[i]);
    if (i % 2 == 1) {
      n *= 2;
      if (n > 9) n -= 9;
    }
    sum += n;
  }
  return sum % 10 == 0;
}

/// Dutch BSN elfproef with negative weight on the last digit.
bool bsn(String match) {
  if (match.length != 9 || !_digitsOnly.hasMatch(match)) return false;
  const weights = [9, 8, 7, 6, 5, 4, 3, 2, -1];
  var sum = 0;
  for (var i = 0; i < 9; i++) {
    sum += int.parse(match[i]) * weights[i];
  }
  return sum > 0 && sum % 11 == 0;
}

/// Portuguese NIF: first-digit restriction + mod-11 check digit.
bool nif(String match) {
  final digits = _digits(match);
  if (digits.length != 9) return false;
  final first = int.parse(digits[0]);
  if (first == 0 || first == 3 || first == 4 || first == 7) return false;
  const weights = [9, 8, 7, 6, 5, 4, 3, 2];
  var sum = 0;
  for (var i = 0; i < 8; i++) {
    sum += int.parse(digits[i]) * weights[i];
  }
  final remainder = sum % 11;
  final check = remainder < 2 ? 0 : 11 - remainder;
  return check == int.parse(digits[8]);
}

/// Norwegian fodselsnummer: two mod-11 control digits, day 01-31.
bool fodselsnummer(String match) {
  final digits = _digits(match);
  if (digits.length != 11) return false;
  final day = int.parse(digits.substring(0, 2));
  if (day >= 41) return false;
  final d = digits.split('').map(int.parse).toList();
  final k1 = 11 -
      ((3 * d[0] +
              7 * d[1] +
              6 * d[2] +
              1 * d[3] +
              8 * d[4] +
              9 * d[5] +
              4 * d[6] +
              5 * d[7] +
              2 * d[8]) %
          11);
  final c1 = k1 == 11 ? 0 : k1;
  if (c1 == 10 || c1 != d[9]) return false;
  final k2 = 11 -
      ((5 * d[0] +
              4 * d[1] +
              3 * d[2] +
              2 * d[3] +
              7 * d[4] +
              6 * d[5] +
              5 * d[6] +
              4 * d[7] +
              3 * d[8] +
              2 * d[9]) %
          11);
  final c2 = k2 == 11 ? 0 : k2;
  if (c2 == 10 || c2 != d[10]) return false;
  return true;
}

/// Norwegian D-nummer: day portion shifted by +40 (41-71).
bool dNummer(String match) {
  final digits = _digits(match);
  if (digits.length != 11) return false;
  final day = int.parse(digits.substring(0, 2));
  return day >= 41 && day <= 71;
}

/// Belgian National Register Number mod-97 check.
bool belgianNrn(String match) {
  final digits = match.replaceAll(RegExp(r'[\s.-]'), '');
  if (digits.length != 11 || !_digitsOnly.hasMatch(digits)) return false;
  final first9 = int.parse(digits.substring(0, 9));
  final check = int.parse(digits.substring(9, 11));
  if ((97 - (first9 % 97)) == check) return true;
  final first9with2 = int.parse('2${digits.substring(0, 9)}');
  return (97 - (first9with2 % 97)) == check;
}

/// Austrian SVNR weighted mod-11 checksum.
bool svnr(String match) {
  final digits = match.replaceAll(RegExp(r'\s'), '');
  if (digits.length != 10 || !_digitsOnly.hasMatch(digits)) return false;
  final serial = int.parse(digits.substring(0, 3));
  if (serial < 100) return false;
  const weights = [3, 7, 9, 0, 5, 8, 4, 2, 1, 6];
  var sum = 0;
  for (var i = 0; i < 10; i++) {
    if (i == 3) continue;
    sum += int.parse(digits[i]) * weights[i];
  }
  final check = sum % 11;
  if (check == 10) return false;
  return check == int.parse(digits[3]);
}

/// Swiss AHV/AVS number EAN-13 checksum (756 prefix).
bool ahv(String match) {
  final digits = match.replaceAll(RegExp(r'[\s.]'), '');
  if (digits.length != 13 || !digits.startsWith('756')) return false;
  const weights = [1, 3, 1, 3, 1, 3, 1, 3, 1, 3, 1, 3];
  var sum = 0;
  for (var i = 0; i < 12; i++) {
    sum += int.parse(digits[i]) * weights[i];
  }
  final check = (10 - (sum % 10)) % 10;
  return check == int.parse(digits[12]);
}

/// German Steuer-ID check digit (ISO 7064 Mod 11,10).
bool steuerId(String match) {
  final digits = _digits(match);
  if (digits.length != 11) return false;
  if (digits[0] == '0') return false;
  var product = 10;
  for (var i = 0; i < 10; i++) {
    var sum = (int.parse(digits[i]) + product) % 10;
    if (sum == 0) sum = 10;
    product = (sum * 2) % 11;
  }
  final check = (11 - product) % 10;
  return check == int.parse(digits[10]);
}

/// Finnish HETU: mod-31 check character.
bool hetu(String match) {
  final upper = match.toUpperCase();
  if (upper.length < 11) return false;
  final number = int.tryParse(upper.substring(0, 6) + upper.substring(7, 10));
  if (number == null) return false;
  const checkChars = '0123456789ABCDEFHJKLMNPRSTUVWXY';
  return checkChars[number % 31] == upper[10];
}

/// Irish PPS number: weighted mod-23 check character.
bool pps(String match) {
  final upper = match.toUpperCase();
  if (upper.length < 8) return false;
  final digits = upper.substring(0, 7);
  final checkChar = upper[7];
  final suffix = upper.length > 8 ? upper[8] : null;
  const weights = [8, 7, 6, 5, 4, 3, 2];
  var sum = 0;
  for (var i = 0; i < 7; i++) {
    final d = int.tryParse(digits[i]);
    if (d == null) return false;
    sum += d * weights[i];
  }
  if (suffix != null && suffix != 'W') {
    sum += (suffix.codeUnitAt(0) - 64) * 9;
  }
  final remainder = sum % 23;
  final expected = remainder == 0 ? 'W' : String.fromCharCode(64 + remainder);
  return checkChar == expected;
}

/// Shannon entropy in bits per character.
double shannonEntropy(String value) {
  if (value.isEmpty) return 0;
  final counts = <int, int>{};
  var n = 0;
  for (final r in value.runes) {
    counts[r] = (counts[r] ?? 0) + 1;
    n++;
  }
  var entropy = 0.0;
  for (final c in counts.values) {
    final p = c / n;
    entropy -= p * (math.log(p) / math.ln2);
  }
  return entropy;
}

final RegExp _leadingJunk = RegExp('^[>\\s"\']+');
final RegExp _trailingEquals = RegExp(r'=+$');
final RegExp _hexOnly = RegExp(r'^[0-9a-f]+$', caseSensitive: false);

/// Generic "keyword = value" secret assignment, gated on entropy.
bool secretAssignment(String match) {
  final sep = match.indexOf(RegExp(r'[:=]'));
  if (sep == -1) return false;
  final value = match
      .substring(sep + 1)
      .replaceFirst(_leadingJunk, '')
      .replaceFirst(_trailingEquals, '');
  if (value.length < 16) return false;
  if (_digitsOnly.hasMatch(value)) return false;
  if (_hexOnly.hasMatch(value)) return shannonEntropy(value) >= 3.0;
  return shannonEntropy(value) >= 4.0;
}

/// Bare high-entropy token gate for machine-generated key material.
bool highEntropyToken(String match) {
  final value = match.replaceFirst(_trailingEquals, '');
  if (value.length < 40 || value.length > 256) return false;
  if (!RegExp(r'[a-z]').hasMatch(value) ||
      !RegExp(r'[A-Z]').hasMatch(value) ||
      !RegExp(r'\d').hasMatch(value)) {
    return false;
  }
  return shannonEntropy(value) >= 4.5;
}

/// Names allowed in the `validate` field of `rules/*.json`.
const Map<String, RuleValidator> validators = {
  'aba': aba,
  'ahv': ahv,
  'belgianNrn': belgianNrn,
  'bsn': bsn,
  'codiceFiscale': codiceFiscale,
  'cups': cups,
  'dNummer': dNummer,
  'dea': dea,
  'dni': dni,
  'fodselsnummer': fodselsnummer,
  'hetu': hetu,
  'highEntropyToken': highEntropyToken,
  'ibanMod97': ibanMod97,
  'ipOctets': ipOctets,
  'luhn': luhn,
  'nhs': nhs,
  'nif': nif,
  'nino': nino,
  'nip': nip,
  'nir': nir,
  'npi': npi,
  'partitaIva': partitaIva,
  'personnummer': personnummer,
  'pesel': pesel,
  'plIdCard': plIdCard,
  'pps': pps,
  'regon': regon,
  'samordningsnummer': samordningsnummer,
  'secretAssignment': secretAssignment,
  'steuerId': steuerId,
  'svnr': svnr,
  'ukDrivingLicence': ukDrivingLicence,
};
