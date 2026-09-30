# Leak report: xlm-roberta-base-ner-docudis

Dataset: `benchmark/public_cases.json`, 45 documents.

An entity is *hidden* when every alphanumeric character of every occurrence is covered by some detection, of any type. *Wrong type* is hidden under another placeholder type (no leak). *Partial* and *leaked* both expose text.

| | Entities | Hidden | of which wrong type | Partial | Leaked | Leak rate |
|---|---|---|---|---|---|---|
| **All** | 703 | 681 | 21 | 15 | 7 | 3.1% |

## By language

| | Entities | Hidden | of which wrong type | Partial | Leaked | Leak rate |
|---|---|---|---|---|---|---|
| en | 298 | 283 | 4 | 11 | 4 | 5.0% |
| es | 296 | 291 | 3 | 4 | 1 | 1.7% |
| fr | 109 | 107 | 14 | 0 | 2 | 1.8% |

## By document type

| | Entities | Hidden | of which wrong type | Partial | Leaked | Leak rate |
|---|---|---|---|---|---|---|
| email | 198 | 192 | 3 | 2 | 4 | 3.0% |
| notice | 100 | 91 | 1 | 9 | 0 | 9.0% |
| registry | 405 | 398 | 17 | 4 | 3 | 1.7% |

## By entity type

| | Entities | Hidden | of which wrong type | Partial | Leaked | Leak rate |
|---|---|---|---|---|---|---|
| ADDRESS | 105 | 90 | 13 | 13 | 2 | 14.3% |
| COMPANY | 145 | 143 | 4 | 0 | 2 | 1.4% |
| EMAIL | 80 | 79 | 0 | 1 | 0 | 1.2% |
| ID | 117 | 116 | 0 | 0 | 1 | 0.9% |
| PERSON | 243 | 240 | 4 | 1 | 2 | 1.2% |
| PHONE | 13 | 13 | 0 | 0 | 0 | 0.0% |

## Documents with no leak at all

| Language | Documents | Fully clean | Share | No identifying leak | Share |
|---|---|---|---|---|---|
| en | 16 | 3 | 19% | 5 | 31% |
| es | 14 | 11 | 79% | 11 | 79% |
| fr | 15 | 13 | 87% | 13 | 87% |
| **All** | 45 | 27 | 60% | 29 | 64% |

## Identifying leaks and residue

Residue: what stays visible is only short numbers, unit designators, single initials, state codes and unit or legal-form words.

| Language | Entities | Identifying | Residue | Identifying leak rate |
|---|---|---|---|---|
| en | 298 | 13 | 2 | 4.4% |
| es | 296 | 5 | 0 | 1.7% |
| fr | 109 | 2 | 0 | 1.8% |

## Reference numbers (counted separately)

5 invoice, contract, policy and file numbers: 3 hidden, 2 partial, 0 leaked.

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

## Over-redaction: 30 detections that touch no expected entity

- 2× `NOMBRE` as PERSON (propagated)
- 2× `Desert Southwest` as ADDRESS (ner:xlm-roberta-base-ner-docudis)
- 2× `SQL_MAIL` as PERSON (ner:xlm-roberta-base-ner-docudis)
- 1× `SIE` as ADDRESS (propagated)
- 1× `SIE` as ADDRESS (ner:xlm-roberta-base-ner-docudis)
- 1× `Flash Infos` as COMPANY (ner:xlm-roberta-base-ner-docudis)
- 1× `SDE` as COMPANY (ner:xlm-roberta-base-ner-docudis)
- 1× `Les Affiches de` as COMPANY (ner:xlm-roberta-base-ner-docudis)
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
- 1× `WTC` as COMPANY (ner:xlm-roberta-base-ner-docudis)
- 1× `WTC Parking` as COMPANY (ner:xlm-roberta-base-ner-docudis)
- 1× `will` as PERSON (propagated)
- 1× `Enpower` as COMPANY (ner:xlm-roberta-base-ner-docudis)

## Leaked (7)

- COMPANY `AIR DU TEMPS` (fr-bodacc-vente-02)
- ADDRESS `Grenoble` (fr-bodacc-vente-04)
- ID `Z21406076C` (es-borme-04-1)
- PERSON `Ina` (en-enron-01)
- ADDRESS `Suite 165` (en-enron-02)
- COMPANY `EnronOnline` (en-enron-03)
- PERSON `Kath` (en-enron-04)

## Partially visible (15)

- ADDRESS `Calle Galeón, edificio 1, 3ºA, 04711 ALMERIMAR, EL EJIDO, ALMERIA` → `Calle Galeón, edificio 1, 3ºA, ███████████████, EL EJIDO, ALMERIA` (es-borme-02-3)
- ADDRESS `C/ GALEON 3º A EDIFICIO 1. ALMERIMAR. (EJIDO (EL))` → `██████████████ ██████████████████████ (EJIDO (EL))` (es-borme-02-3)
- ADDRESS `CTRA DE ENTRERRIOS, S/N-FABRICA DE TRANSA 06700 (VILLANUEVA DE LA SERENA)` → `CTRA DE ENTRERRIOS, S/N-FABRICA █████████ ███████████████████████████████` (es-borme-03-2)
- ADDRESS `C/ FAISAN, 10-LOCAL 2, NUESTRA SEÑORA DE JESUS 078 (SANTA EULALIA DEL RIO)` → `█████████████-LOCAL 2, NUESTRA SEÑORA DE JESUS 078 (SANTA EULALIA DEL RIO)` (es-borme-04-1)
- ADDRESS `New North Road, Heckmondwike, West Yorkshire, WF16 9DH` → `New North Road, Heckmondwike, West Yorkshire, ████████` (en-gazette-02)
- ADDRESS `Suite B, Blackdown House, Blackbrook Park Avenue, Taunton, Somerset, TA1 2PX` → `Suite B, Blackdown House, Blackbrook Park Avenue, Taunton, Somerset, ███████` (en-gazette-03)
- ADDRESS `The Mill House Court Farm, Church Lane, Norton, Worcester, WR5 2PS` → `████████ House Court Farm, Church Lane, ██████, ██████████████████` (en-gazette-04)
- ADDRESS `Unit 14C Hartlebury Trading Estate, Hartlebury, Kidderminste, DY104JB` → `Unit 14C Hartlebury Trading Estate, Hartlebury, Kidderminste, ███████` (en-gazette-04)
- ADDRESS `Azzurri House, Walsall Business Park, Walsall Road, Walsall, West Midlands, WS9 0RB` → `█████████████, ██████████████████████ Walsall Road, Walsall, West Midlands, ███████` (en-gazette-05)
- ADDRESS `The Union Building 51-59 Rose Lane, Norwich, NR1 1BY, United Kingdom` → `████████████████████████████████████████████████████████████ Kingdom` (en-gazette-06)
- ADDRESS `2 Lakeside, Calder Island Way, Wakefield, WF2 7AW` → `2 Lakeside, Calder Island Way, Wakefield, ███████` (en-gazette-07)
- ADDRESS `Caledon Community Centre, Caledon Road, London Colney, St Albans, Hertfordshire AL2 1PU` → `Caledon Community Centre, Caledon Road, London Colney, St Albans, Hertfordshire ███████` (en-gazette-08)
- ADDRESS `15 Horizon Business Village, 1 Brooklands Road, Weybridge, Surrey, KT13 0TJ` → `15 Horizon Business Village, ██████████████████████████████████████████████` (en-gazette-08)
- PERSON `Vince J Kaminski` → `█████ J ████████` (en-enron-05)
- EMAIL `terry'.'ed@enron.com` → `terry'.'████████████` (en-enron-07)
