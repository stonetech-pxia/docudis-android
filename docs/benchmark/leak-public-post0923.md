# Leak report: xlm-roberta-base-ner-docudis

Dataset: `benchmark/public_cases.json`, 45 documents.

An entity is *hidden* when every alphanumeric character of every occurrence is covered by some detection, of any type. *Wrong type* is hidden under another placeholder type (no leak). *Partial* and *leaked* both expose text.

| | Entities | Hidden | of which wrong type | Partial | Leaked | Leak rate |
|---|---|---|---|---|---|---|
| **All** | 703 | 688 | 22 | 9 | 6 | 2.1% |

## By language

| | Entities | Hidden | of which wrong type | Partial | Leaked | Leak rate |
|---|---|---|---|---|---|---|
| en | 298 | 289 | 4 | 5 | 4 | 3.0% |
| es | 296 | 291 | 3 | 4 | 1 | 1.7% |
| fr | 109 | 108 | 15 | 0 | 1 | 0.9% |

## By document type

| | Entities | Hidden | of which wrong type | Partial | Leaked | Leak rate |
|---|---|---|---|---|---|---|
| email | 198 | 192 | 3 | 2 | 4 | 3.0% |
| notice | 100 | 97 | 1 | 3 | 0 | 3.0% |
| registry | 405 | 399 | 18 | 4 | 2 | 1.5% |

## By entity type

| | Entities | Hidden | of which wrong type | Partial | Leaked | Leak rate |
|---|---|---|---|---|---|---|
| ADDRESS | 105 | 97 | 14 | 7 | 1 | 7.6% |
| COMPANY | 145 | 143 | 4 | 0 | 2 | 1.4% |
| EMAIL | 80 | 79 | 0 | 1 | 0 | 1.2% |
| ID | 117 | 116 | 0 | 0 | 1 | 0.9% |
| PERSON | 243 | 240 | 4 | 1 | 2 | 1.2% |
| PHONE | 13 | 13 | 0 | 0 | 0 | 0.0% |

## Documents with no leak at all

| Language | Documents | Fully clean | Share | No identifying leak | Share |
|---|---|---|---|---|---|
| en | 16 | 7 | 44% | 10 | 62% |
| es | 14 | 11 | 79% | 11 | 79% |
| fr | 15 | 14 | 93% | 14 | 93% |
| **All** | 45 | 32 | 71% | 35 | 78% |

## Identifying leaks and residue

Residue: what stays visible is only short numbers, unit designators, single initials, state codes and unit or legal-form words.

| Language | Entities | Identifying | Residue | Identifying leak rate |
|---|---|---|---|---|
| en | 298 | 6 | 3 | 2.0% |
| es | 296 | 5 | 0 | 1.7% |
| fr | 109 | 1 | 0 | 0.9% |

## Reference numbers (counted separately)

5 invoice, contract, policy and file numbers: 4 hidden, 1 partial, 0 leaked.

## Left visible by default (counted separately)

Amounts and dates other than dates of birth are detected but switched off. *Detected* means the user can switch them on.

| | Entities | Detected | Partly detected | Not detected |
|---|---|---|---|---|
| AMOUNT | 49 | 35 | 0 | 14 |
| DATE | 133 | 133 | 0 | 0 |

## NUMBER placeholders: 18

Digit strings matched by a loose rule, hidden under the generic type instead of a guessed one.

- 10× regex:universal:labeled_id_no
- 6× regex:us:passport
- 1× regex:ie:phone
- 1× regex:universal:labeled_id

## Over-redaction: 28 detections that touch no expected entity

- 2× `NOMBRE` as PERSON (propagated)
- 2× `Desert Southwest` as ADDRESS (ner:xlm-roberta-base-ner-docudis)
- 2× `WTC Parking` as COMPANY (ner:xlm-roberta-base-ner-docudis)
- 2× `SQL_MAIL` as PERSON (ner:xlm-roberta-base-ner-docudis)
- 1× `Enregistrement de SIE` as ADDRESS (ner:xlm-roberta-base-ner-docudis)
- 1× `Flash Infos` as COMPANY (ner:xlm-roberta-base-ner-docudis)
- 1× `SDE` as COMPANY (ner:xlm-roberta-base-ner-docudis)
- 1× `du Dauphiné` as COMPANY (ner:xlm-roberta-base-ner-docudis)
- 1× `Société par Actions Simplifiée` as COMPANY (ner:xlm-roberta-base-ner-docudis)
- 1× `CNAE 9609` as ID (regex:universal:labeled_id)
- 1× `88506 DONDE SE LEE COMO PRIMER APELLIDO DEL ADMINISTRADOR UNICO` as ADDRESS (regex:es:postal)
- 1× `DE LA APODERADA` as PERSON (ner:xlm-roberta-base-ner-docudis)
- 1× `DEL APODERADO` as PERSON (ner:xlm-roberta-base-ner-docudis)
- 1× `Rules` as COMPANY (list:company)
- 1× `N/A` as ADDRESS (ner:xlm-roberta-base-ner-docudis)
- 1× `HOU` as PERSON (propagated)
- 1× `ENRON` as PERSON (ner:xlm-roberta-base-ner-docudis)
- 1× `HOU` as PERSON (ner:xlm-roberta-base-ner-docudis)
- 1× `Desert Southwest` as ADDRESS (propagated)
- 1× `will` as PERSON (propagated)
- 1× `Enpower` as COMPANY (ner:xlm-roberta-base-ner-docudis)
- 1× `Gas Settlements` as COMPANY (ner:xlm-roberta-base-ner-docudis)
- 1× `DWR` as COMPANY (ner:xlm-roberta-base-ner-docudis)
- 1× `COB` as COMPANY (ner:xlm-roberta-base-ner-docudis)

## Leaked (6)

- COMPANY `AIR DU TEMPS` (fr-bodacc-vente-02)
- ID `Z21406076C` (es-borme-04-1)
- PERSON `Ina` (en-enron-01)
- ADDRESS `Suite 165` (en-enron-02)
- COMPANY `EnronOnline` (en-enron-03)
- PERSON `Kath` (en-enron-04)

## Partially visible (9)

- ADDRESS `Calle Galeón, edificio 1, 3ºA, 04711 ALMERIMAR, EL EJIDO, ALMERIA` → `Calle Galeón, edificio ██████████████████████████████████████████` (es-borme-02-3)
- ADDRESS `C/ GALEON 3º A EDIFICIO 1. ALMERIMAR. (EJIDO (EL))` → `██████████████ ██████████████████████ (EJIDO (EL))` (es-borme-02-3)
- ADDRESS `CTRA DE ENTRERRIOS, S/N-FABRICA DE TRANSA 06700 (VILLANUEVA DE LA SERENA)` → `CTRA DE ENTRERRIOS, S/███████████████████████████████████████████████████` (es-borme-03-2)
- ADDRESS `C/ FAISAN, 10-LOCAL 2, NUESTRA SEÑORA DE JESUS 078 (SANTA EULALIA DEL RIO)` → `█████████████-LOCAL 2, NUESTRA SEÑORA DE JESUS 078 (SANTA EULALIA DEL RIO)` (es-borme-04-1)
- ADDRESS `Suite B, Blackdown House, Blackbrook Park Avenue, Taunton, Somerset, TA1 2PX` → `Suite ██████████████████████████████████████████████████████████████████████` (en-gazette-03)
- ADDRESS `The Mill House Court Farm, Church Lane, Norton, Worcester, WR5 2PS` → `█████████████████████████, Church Lane, ██████, █████████, ███████` (en-gazette-04)
- ADDRESS `Caledon Community Centre, Caledon Road, London Colney, St Albans, Hertfordshire AL2 1PU` → `Caledon Community █████████████████████████████████████████████████████████████████████` (en-gazette-08)
- PERSON `Vince J Kaminski` → `█████ J ████████` (en-enron-05)
- EMAIL `terry'.'ed@enron.com` → `terry'.'████████████` (en-enron-07)
