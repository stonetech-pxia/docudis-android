# Leak report: xlm-roberta-base-ner-docudis

Dataset: `benchmark/public_cases.json`, 45 documents.

An entity is *hidden* when every alphanumeric character of every occurrence is covered by some detection, of any type. *Wrong type* is hidden under another placeholder type (no leak). *Partial* and *leaked* both expose text.

| | Entities | Hidden | of which wrong type | Partial | Leaked | Leak rate |
|---|---|---|---|---|---|---|
| **All** | 703 | 667 | 18 | 18 | 18 | 5.1% |

## By language

| | Entities | Hidden | of which wrong type | Partial | Leaked | Leak rate |
|---|---|---|---|---|---|---|
| en | 298 | 270 | 3 | 12 | 16 | 9.4% |
| es | 296 | 291 | 2 | 4 | 1 | 1.7% |
| fr | 109 | 106 | 13 | 2 | 1 | 2.8% |

## By document type

| | Entities | Hidden | of which wrong type | Partial | Leaked | Leak rate |
|---|---|---|---|---|---|---|
| email | 198 | 192 | 3 | 2 | 4 | 3.0% |
| notice | 100 | 78 | 0 | 10 | 12 | 22.0% |
| registry | 405 | 397 | 15 | 6 | 2 | 2.0% |

## By entity type

| | Entities | Hidden | of which wrong type | Partial | Leaked | Leak rate |
|---|---|---|---|---|---|---|
| ADDRESS | 105 | 89 | 13 | 14 | 2 | 15.2% |
| COMPANY | 145 | 138 | 2 | 3 | 4 | 4.8% |
| EMAIL | 80 | 79 | 0 | 1 | 0 | 1.2% |
| ID | 117 | 106 | 0 | 0 | 11 | 9.4% |
| PERSON | 243 | 242 | 3 | 0 | 1 | 0.4% |
| PHONE | 13 | 13 | 0 | 0 | 0 | 0.0% |

## Documents with no leak at all

| Language | Documents | Fully clean | Share | No identifying leak | Share |
|---|---|---|---|---|---|
| en | 16 | 4 | 25% | 5 | 31% |
| es | 14 | 11 | 79% | 11 | 79% |
| fr | 15 | 12 | 80% | 14 | 93% |
| **All** | 45 | 27 | 60% | 30 | 67% |

## Identifying leaks and residue

Residue: what stays visible is only short numbers, unit designators, single initials, state codes and unit or legal-form words.

| Language | Entities | Identifying | Residue | Identifying leak rate |
|---|---|---|---|---|
| en | 298 | 27 | 1 | 9.1% |
| es | 296 | 4 | 1 | 1.4% |
| fr | 109 | 1 | 2 | 0.9% |

## Reference numbers (counted separately)

5 invoice, contract, policy and file numbers: 1 hidden, 2 partial, 2 leaked.

## Left visible by default (counted separately)

Amounts and dates other than dates of birth are detected but switched off. *Detected* means the user can switch them on.

| | Entities | Detected | Partly detected | Not detected |
|---|---|---|---|---|
| AMOUNT | 49 | 35 | 0 | 14 |
| DATE | 133 | 133 | 0 | 0 |

## NUMBER placeholders: 8

Digit strings matched by a loose rule, hidden under the generic type instead of a guessed one.

- 6× regex:us:passport
- 1× regex:ie:phone
- 1× regex:universal:labeled_id

## Over-redaction: 20 detections that touch no expected entity

- 6× `UNICO` as PERSON (propagated)
- 2× `NOMBRE` as PERSON (propagated)
- 2× `Desert Southwest` as ADDRESS (ner:xlm-roberta-base-ner-docudis)
- 1× `SDE` as COMPANY (ner:xlm-roberta-base-ner-docudis)
- 1× `CNAE` as ADDRESS (ner:xlm-roberta-base-ner-docudis)
- 1× `CNAE 9609` as ID (regex:universal:labeled_id)
- 1× `88506 DONDE SE LEE COMO PRIMER APELLIDO DEL ADMINISTRADOR UNICO` as ADDRESS (regex:es:postal)
- 1× `Rules` as COMPANY (list:company)
- 1× `N/A` as ADDRESS (ner:xlm-roberta-base-ner-docudis)
- 1× `HOU` as PERSON (ner:xlm-roberta-base-ner-docudis)
- 1× `ECT` as PERSON (ner:xlm-roberta-base-ner-docudis)
- 1× `will` as PERSON (propagated)
- 1× `Gas Settlements` as COMPANY (ner:xlm-roberta-base-ner-docudis)

## Leaked (18)

- ID `31850` (en-gazette-01, en-gazette-04)
- ID `32230` (en-gazette-01, en-gazette-04)
- COMPANY `AIR DU TEMPS` (fr-bodacc-vente-02)
- ID `Z21406076C` (es-borme-04-1)
- COMPANY `Walter Dawson & Son` (en-gazette-02)
- ID `29010` (en-gazette-02)
- ID `11110` (en-gazette-03)
- ID `18032` (en-gazette-03)
- ADDRESS `Birmingham` (en-gazette-05)
- ID `22930` (en-gazette-05)
- ID `020730` (en-gazette-05)
- ID `13890` (en-gazette-06)
- ADDRESS `Suite 165` (en-enron-02)
- PERSON `Kath` (en-enron-04)
- COMPANY `UBS` (en-enron-04)
- COMPANY `ENA` (en-enron-07)

## Partially visible (18)

- ADDRESS `Zone Industrielle Kaweni BP 633 Route nationale 1 - 97600 MAMOUDZOU` → `████ ███████████████████ BP █████████████████████ - ███████████████` (fr-bodacc-vente-01)
- COMPANY `FF BONNEVEINE MENAGER` → `FF ██████████████████` (fr-bodacc-vente-03)
- ADDRESS `Calle Galeón, edificio 1, 3ºA, 04711 ALMERIMAR, EL EJIDO, ALMERIA` → `Calle Galeón, edificio 1, 3ºA, ███████████████, EL █████, ALMERIA` (es-borme-02-3)
- ADDRESS `C/ GALEON 3º A EDIFICIO 1. ALMERIMAR. (EJIDO (EL))` → `██████████████ ██████████████████████ (█████ (EL))` (es-borme-02-3)
- ADDRESS `CTRA DE ENTRERRIOS, S/N-FABRICA DE TRANSA 06700 (VILLANUEVA DE LA SERENA)` → `CTRA DE ENTRERRIOS, S/N-FABRICA DE TRANSA ███████████████████████████████` (es-borme-03-2)
- ADDRESS `C/ FAISAN, 10-LOCAL 2, NUESTRA SEÑORA DE JESUS 078 (SANTA EULALIA DEL RIO)` → `█████████████-LOCAL 2, NUESTRA SEÑORA DE JESUS 078 (SANTA EULALIA DEL RIO)` (es-borme-04-1)
- ADDRESS `New North Road, Heckmondwike, West Yorkshire, WF16 9DH` → `New North Road, Heckmondwike, West Yorkshire, ████████` (en-gazette-02)
- COMPANY `The Kings Arms` → `The ██████████` (en-gazette-03)
- ADDRESS `Suite B, Blackdown House, Blackbrook Park Avenue, Taunton, Somerset, TA1 2PX` → `Suite B, Blackdown House, Blackbrook Park Avenue, Taunton, Somerset, ███████` (en-gazette-03)
- ADDRESS `The Mill House Court Farm, Church Lane, Norton, Worcester, WR5 2PS` → `████████ House Court Farm, Church Lane, ██████, ██████████████████` (en-gazette-04)
- ADDRESS `Unit 14C Hartlebury Trading Estate, Hartlebury, Kidderminste, DY104JB` → `Unit 14C Hartlebury Trading Estate, Hartlebury, Kidderminste, ███████` (en-gazette-04)
- ADDRESS `Azzurri House, Walsall Business Park, Walsall Road, Walsall, West Midlands, WS9 0RB` → `█████████████, Walsall Business Park, Walsall Road, Walsall, West Midlands, ███████` (en-gazette-05)
- ADDRESS `The Union Building 51-59 Rose Lane, Norwich, NR1 1BY, United Kingdom` → `████████████████████████████████████████████████████████████ Kingdom` (en-gazette-06)
- ADDRESS `2 Lakeside, Calder Island Way, Wakefield, WF2 7AW` → `2 Lakeside, Calder Island Way, Wakefield, ███████` (en-gazette-07)
- ADDRESS `Caledon Community Centre, Caledon Road, London Colney, St Albans, Hertfordshire AL2 1PU` → `Caledon Community Centre, Caledon Road, London Colney, St Albans, Hertfordshire ███████` (en-gazette-08)
- ADDRESS `15 Horizon Business Village, 1 Brooklands Road, Weybridge, Surrey, KT13 0TJ` → `15 Horizon Business Village, ██████████████████████████████████████████████` (en-gazette-08)
- COMPANY `Enron North America` → `█████ North ███████` (en-enron-03)
- EMAIL `terry'.'ed@enron.com` → `terry'.'████████████` (en-enron-07)
