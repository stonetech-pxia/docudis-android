# Leak report: xlm-roberta-base-ner-docudis

Dataset: `benchmark/public_cases.json`, 45 documents.

An entity is *hidden* when every alphanumeric character of every occurrence is covered by some detection, of any type. *Wrong type* is hidden under another placeholder type (no leak). *Partial* and *leaked* both expose text.

| | Entities | Hidden | of which wrong type | Partial | Leaked | Leak rate |
|---|---|---|---|---|---|---|
| **All** | 703 | 672 | 20 | 15 | 16 | 4.4% |

## By language

| | Entities | Hidden | of which wrong type | Partial | Leaked | Leak rate |
|---|---|---|---|---|---|---|
| en | 298 | 274 | 4 | 11 | 13 | 8.1% |
| es | 296 | 291 | 3 | 4 | 1 | 1.7% |
| fr | 109 | 107 | 13 | 0 | 2 | 1.8% |

## By document type

| | Entities | Hidden | of which wrong type | Partial | Leaked | Leak rate |
|---|---|---|---|---|---|---|
| email | 198 | 193 | 3 | 2 | 3 | 2.5% |
| notice | 100 | 81 | 1 | 9 | 10 | 19.0% |
| registry | 405 | 398 | 16 | 4 | 3 | 1.7% |

## By entity type

| | Entities | Hidden | of which wrong type | Partial | Leaked | Leak rate |
|---|---|---|---|---|---|---|
| ADDRESS | 105 | 91 | 13 | 13 | 1 | 13.3% |
| COMPANY | 145 | 141 | 4 | 1 | 3 | 2.8% |
| EMAIL | 80 | 79 | 0 | 1 | 0 | 1.2% |
| ID | 117 | 106 | 0 | 0 | 11 | 9.4% |
| PERSON | 243 | 242 | 3 | 0 | 1 | 0.4% |
| PHONE | 13 | 13 | 0 | 0 | 0 | 0.0% |

## Documents with no leak at all

| Language | Documents | Fully clean | Share | No identifying leak | Share |
|---|---|---|---|---|---|
| en | 16 | 5 | 31% | 5 | 31% |
| es | 14 | 11 | 79% | 11 | 79% |
| fr | 15 | 13 | 87% | 13 | 87% |
| **All** | 45 | 29 | 64% | 29 | 64% |

## Identifying leaks and residue

Residue: what stays visible is only short numbers, unit designators, single initials, state codes and unit or legal-form words.

| Language | Entities | Identifying | Residue | Identifying leak rate |
|---|---|---|---|---|
| en | 298 | 24 | 0 | 8.1% |
| es | 296 | 5 | 0 | 1.7% |
| fr | 109 | 2 | 0 | 1.8% |

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

## Over-redaction: 52 detections that touch no expected entity

- 8× `UNICO` as PERSON (propagated)
- 6× `Jueves` as ADDRESS (ner:xlm-roberta-base-ner-docudis)
- 3× `Dimisiones` as COMPANY (propagated)
- 2× `Jueves` as ADDRESS (propagated)
- 2× `NOMBRE` as PERSON (propagated)
- 2× `Trading Track A&A` as COMPANY (ner:xlm-roberta-base-ner-docudis)
- 2× `Desert Southwest` as ADDRESS (ner:xlm-roberta-base-ner-docudis)
- 2× `Gas` as COMPANY (propagated)
- 2× `SQL_MAIL` as PERSON (ner:xlm-roberta-base-ner-docudis)
- 1× `SIE` as COMPANY (ner:xlm-roberta-base-ner-docudis)
- 1× `Opération` as COMPANY (propagated)
- 1× `SIE` as COMPANY (propagated)
- 1× `Opération` as COMPANY (ner:xlm-roberta-base-ner-docudis)
- 1× `Flash Infos` as COMPANY (ner:xlm-roberta-base-ner-docudis)
- 1× `Dauphiné` as ADDRESS (ner:xlm-roberta-base-ner-docudis)
- 1× `Dimisiones` as COMPANY (ner:xlm-roberta-base-ner-docudis)
- 1× `CNAE` as ADDRESS (ner:xlm-roberta-base-ner-docudis)
- 1× `CNAE 9609` as ID (regex:universal:labeled_id)
- 1× `Jueves` as PERSON (ner:xlm-roberta-base-ner-docudis)
- 1× `88506 DONDE SE LEE COMO PRIMER APELLIDO DEL ADMINISTRADOR UNICO` as ADDRESS (regex:es:postal)
- 1× `DEL APODERADO` as PERSON (ner:xlm-roberta-base-ner-docudis)
- 1× `Rules` as COMPANY (list:company)
- 1× `N/A` as ADDRESS (ner:xlm-roberta-base-ner-docudis)
- 1× `Track` as COMPANY (ner:xlm-roberta-base-ner-docudis)

## Leaked (16)

- ID `31850` (en-gazette-01, en-gazette-04)
- ID `32230` (en-gazette-01, en-gazette-04)
- COMPANY `AIR DU TEMPS` (fr-bodacc-vente-02)
- ADDRESS `Grenoble` (fr-bodacc-vente-04)
- ID `Z21406076C` (es-borme-04-1)
- ID `29010` (en-gazette-02)
- ID `11110` (en-gazette-03)
- ID `18032` (en-gazette-03)
- ID `22930` (en-gazette-05)
- ID `020730` (en-gazette-05)
- ID `13890` (en-gazette-06)
- COMPANY `Global Products` (en-enron-03)
- PERSON `Kath` (en-enron-04)
- COMPANY `UBS` (en-enron-04)

## Partially visible (15)

- ADDRESS `Calle Galeón, edificio 1, 3ºA, 04711 ALMERIMAR, EL EJIDO, ALMERIA` → `Calle Galeón, edificio 1, 3ºA, ███████████████, EL EJIDO, ALMERIA` (es-borme-02-3)
- ADDRESS `C/ GALEON 3º A EDIFICIO 1. ALMERIMAR. (EJIDO (EL))` → `██████████████ ██████████████████████ (EJIDO (EL))` (es-borme-02-3)
- ADDRESS `CTRA DE ENTRERRIOS, S/N-FABRICA DE TRANSA 06700 (VILLANUEVA DE LA SERENA)` → `CTRA DE ENTRERRIOS, S/N-FABRICA DE TRANSA ███████████████████████████████` (es-borme-03-2)
- ADDRESS `C/ FAISAN, 10-LOCAL 2, NUESTRA SEÑORA DE JESUS 078 (SANTA EULALIA DEL RIO)` → `█████████████-LOCAL 2, NUESTRA SEÑORA DE JESUS 078 (SANTA EULALIA DEL RIO)` (es-borme-04-1)
- ADDRESS `New North Road, Heckmondwike, West Yorkshire, WF16 9DH` → `New North Road, Heckmondwike, West Yorkshire, ████████` (en-gazette-02)
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
