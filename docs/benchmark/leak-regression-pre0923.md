# Leak report: xlm-roberta-base-ner-docudis

Dataset: `benchmark/regression_cases.json`, 48 documents.

An entity is *hidden* when every alphanumeric character of every occurrence is covered by some detection, of any type. *Wrong type* is hidden under another placeholder type (no leak). *Partial* and *leaked* both expose text.

| | Entities | Hidden | of which wrong type | Partial | Leaked | Leak rate |
|---|---|---|---|---|---|---|
| **All** | 651 | 605 | 15 | 14 | 32 | 7.1% |

## By language

| | Entities | Hidden | of which wrong type | Partial | Leaked | Leak rate |
|---|---|---|---|---|---|---|
| en | 239 | 223 | 5 | 3 | 13 | 6.7% |
| es | 198 | 186 | 3 | 4 | 8 | 6.1% |
| fr | 214 | 196 | 7 | 7 | 11 | 8.4% |

## By document type

| | Entities | Hidden | of which wrong type | Partial | Leaked | Leak rate |
|---|---|---|---|---|---|---|
| bank | 68 | 64 | 2 | 1 | 3 | 5.9% |
| catalogue | 30 | 24 | 1 | 1 | 5 | 20.0% |
| chat | 28 | 27 | 1 | 0 | 1 | 3.6% |
| cv | 79 | 77 | 1 | 1 | 1 | 2.5% |
| insurance | 58 | 55 | 2 | 1 | 2 | 5.2% |
| invoice | 54 | 51 | 3 | 2 | 1 | 5.6% |
| jobad | 17 | 17 | 0 | 0 | 0 | 0.0% |
| lease | 43 | 38 | 0 | 1 | 4 | 11.6% |
| letter | 47 | 44 | 2 | 0 | 3 | 6.4% |
| manual | 9 | 8 | 0 | 1 | 0 | 11.1% |
| medical | 52 | 50 | 0 | 0 | 2 | 3.8% |
| notice | 15 | 14 | 0 | 1 | 0 | 6.7% |
| payslip | 50 | 47 | 1 | 0 | 3 | 6.0% |
| policy | 25 | 23 | 1 | 2 | 0 | 8.0% |
| support | 55 | 50 | 0 | 0 | 5 | 9.1% |
| terms | 21 | 16 | 1 | 3 | 2 | 23.8% |

## By entity type

| | Entities | Hidden | of which wrong type | Partial | Leaked | Leak rate |
|---|---|---|---|---|---|---|
| ADDRESS | 209 | 193 | 10 | 6 | 10 | 7.7% |
| BIRTH_DATE | 16 | 14 | 0 | 0 | 2 | 12.5% |
| CARD | 8 | 5 | 0 | 0 | 3 | 37.5% |
| COMPANY | 101 | 94 | 0 | 3 | 4 | 6.9% |
| EMAIL | 34 | 34 | 0 | 0 | 0 | 0.0% |
| IBAN | 16 | 16 | 0 | 0 | 0 | 0.0% |
| ID | 107 | 89 | 1 | 5 | 13 | 16.8% |
| PERSON | 109 | 109 | 2 | 0 | 0 | 0.0% |
| PHONE | 50 | 50 | 2 | 0 | 0 | 0.0% |
| URL | 1 | 1 | 0 | 0 | 0 | 0.0% |

## Documents with no leak at all

| Language | Documents | Fully clean | Share | No identifying leak | Share |
|---|---|---|---|---|---|
| en | 16 | 7 | 44% | 7 | 44% |
| es | 16 | 8 | 50% | 12 | 75% |
| fr | 16 | 5 | 31% | 9 | 56% |
| **All** | 48 | 20 | 42% | 28 | 58% |

## Identifying leaks and residue

Residue: what stays visible is only short numbers, unit designators, single initials, state codes and unit or legal-form words.

| Language | Entities | Identifying | Residue | Identifying leak rate |
|---|---|---|---|---|
| en | 239 | 13 | 3 | 5.4% |
| es | 198 | 7 | 5 | 3.5% |
| fr | 214 | 9 | 9 | 4.2% |

## Reference numbers (counted separately)

59 invoice, contract, policy and file numbers: 36 hidden, 7 partial, 16 leaked.

## Left visible by default (counted separately)

Amounts and dates other than dates of birth are detected but switched off. *Detected* means the user can switch them on.

| | Entities | Detected | Partly detected | Not detected |
|---|---|---|---|---|
| AMOUNT | 176 | 170 | 0 | 6 |
| DATE | 190 | 190 | 0 | 0 |

## NUMBER placeholders: 85

Digit strings matched by a loose rule, hidden under the generic type instead of a guessed one.

- 32× regex:universal:long_number
- 14× regex:universal:labeled_id_no
- 10× regex:universal:labeled_id
- 9× regex:ie:phone
- 7× regex:fr:siret
- 4× regex:es:nuss
- 2× regex:gb:sort_code
- 2× propagated
- 2× regex:es:hoja_registral
- 1× regex:us:passport
- 1× regex:gb:vat
- 1× regex:fr:vat

## Over-redaction: 100 detections that touch no expected entity

- 5× `Marsden Row` as ADDRESS (ner:xlm-roberta-base-ner-docudis)
- 5× `SIRET` as ADDRESS (ner:xlm-roberta-base-ner-docudis)
- 2× `Ireland` as ADDRESS (ner:xlm-roberta-base-ner-docudis)
- 2× `England` as ADDRESS (ner:xlm-roberta-base-ner-docudis)
- 2× `60335-2-51` as NUMBER (regex:universal:long_number)
- 2× `Hollowgate Lane` as ADDRESS (ner:xlm-roberta-base-ner-docudis)
- 2× `Collègue` as PERSON (ner:xlm-roberta-base-ner-docudis)
- 1× `7318 14 91` as NUMBER (regex:universal:long_number)
- 1× `7318 15 59` as NUMBER (regex:universal:long_number)
- 1× `Northern Ireland` as ADDRESS (ner:xlm-roberta-base-ner-docudis)
- 1× `26-11840298` as NUMBER (regex:universal:long_number)
- 1× `United States` as ADDRESS (ner:xlm-roberta-base-ner-docudis)
- 1× `5-point` as ID (regex:universal:labeled_id)
- 1× `2019-2022` as NUMBER (regex:universal:long_number)
- 1× `Central Texas Veterans Health Care System` as COMPANY (ner:xlm-roberta-base-ner-docudis)
- 1× `United States Army` as COMPANY (ner:xlm-roberta-base-ner-docudis)
- 1× `Texas` as ADDRESS (ner:xlm-roberta-base-ner-docudis)
- 1× `Wales No.` as ADDRESS (ner:xlm-roberta-base-ner-docudis)
- 1× `United` as COMPANY (list:company)
- 1× `Kingdom` as ADDRESS (ner:xlm-roberta-base-ner-docudis)
- 1× `the Thornlow Road` as ADDRESS (ner:xlm-roberta-base-ner-docudis)
- 1× `IBAN` as PERSON (ner:xlm-roberta-base-ner-docudis)
- 1× `HX-440-S` as ID (regex:universal:labeled_id)
- 1× `88-4401-S` as ID (regex:universal:labeled_id)

## Leaked (32)

- ADDRESS `bajo C` (es-insurance-01, es-letter-01)
- ID `929027` (en-bank-01)
- ID `419776` (en-catalogue-01)
- ID `IE 4197763T` (en-catalogue-01)
- COMPANY `Tenancy Deposit Scheme` (en-lease-01)
- ID `YRH8820416` (en-medical-01)
- ID `004791` (en-medical-01)
- COMPANY `Nest` (en-payslip-01)
- COMPANY `Unite` (en-payslip-01)
- CARD `1651` (en-support-01)
- BIRTH_DATE `09/02/1984` (en-support-01)
- ID `641208` (en-support-01)
- ID `IE 4412097T` (en-support-01)
- ID `WEE/JB3392AC` (en-terms-01)
- CARD `6046` (es-bank-01)
- ID `A-28455091` (es-catalogue-01)
- ADDRESS `Avinguda del` (es-lease-01)
- ID `7382901YJ2778S0012KP` (es-lease-01)
- ID `41.228` (es-lease-01)
- ID `B-97684512` (es-terms-01)
- ADDRESS `bâtiment C, appartement 42` (fr-bank-01)
- ID `40712` (fr-catalogue-01)
- COMPANY `Geodis` (fr-catalogue-01)
- BIRTH_DATE `04/11/1994` (fr-chat-01)
- ADDRESS `Italie` (fr-cv-01)
- ADDRESS `lieu-dit Le Bourdieu` (fr-insurance-01)
- ADDRESS `Résidence Les Hauts de Caudéran` (fr-invoice-01)
- ADDRESS `Résidence Les Coteaux, bâtiment B` (fr-letter-01)
- ADDRESS `appartement 214` (fr-letter-01)
- ADDRESS `bâtiment 4, 2e étage` (fr-payslip-01)
- CARD `3716` (fr-support-01)

## Partially visible (14)

- COMPANY `The University of Texas at Austin` → `███████████████████████ at ██████` (en-cv-01)
- ADDRESS `Main Street, Bray, Co. Wicklow` → `Main Street, █████████████████` (en-invoice-01)
- ID `GB 249 8831 07` → `GB ███████████` (en-terms-01)
- ADDRESS `izquierda, 46008 València (Valencia)` → `izquierda, ██████████████ (████████)` (es-lease-01)
- ADDRESS `Polígono Industrial Las Cañadas, nave 17, 50820 Villamayor (Zaragoza)` → `Polígono Industrial Las Cañadas, nave ████████████████████ (████████)` (es-manual-01)
- ADDRESS `plaza Mayor 1, planta baja` → `█████████████, planta ████` (es-notice-01)
- ADDRESS `Polígono Industrial Las Cañadas, calle Torrente Ballester 14, nave 7` → `████████████████████████████████████████████████████████████, nave 7` (es-terms-01)
- COMPANY `cabinet Lorquin & associés` → `cabinet ██████████████████` (fr-bank-01)
- ID `FR 62 524 108 663` → `FR ██████████████` (fr-catalogue-01)
- COMPANY `centre hospitalier d'Agen` → `centre hospitalier d'████` (fr-insurance-01)
- ID `D-771 4820 09` → `D-███████████` (fr-invoice-01)
- ADDRESS `Île-de-France` → `Île-de-██████` (fr-policy-01)
- ID `FR 21 379 615 244` → `FR ██████████████` (fr-policy-01)
- ID `FR 43 812 494 037` → `FR ██████████████` (fr-terms-01)
