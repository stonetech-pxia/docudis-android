# Leak report: xlm-roberta-base-ner-hrl

Dataset: `benchmark/public_cases.json`, 45 documents.

An entity is *hidden* when every alphanumeric character of every occurrence is covered by some detection, of any type. *Wrong type* is hidden under another placeholder type (no leak). *Partial* and *leaked* both expose text.

| | Entities | Hidden | of which wrong type | Partial | Leaked | Leak rate |
|---|---|---|---|---|---|---|
| **All** | 703 | 652 | 23 | 24 | 27 | 7.3% |

## By language

| | Entities | Hidden | of which wrong type | Partial | Leaked | Leak rate |
|---|---|---|---|---|---|---|
| en | 298 | 274 | 6 | 5 | 19 | 8.1% |
| es | 296 | 279 | 4 | 14 | 3 | 5.7% |
| fr | 109 | 99 | 13 | 5 | 5 | 9.2% |

## By document type

| | Entities | Hidden | of which wrong type | Partial | Leaked | Leak rate |
|---|---|---|---|---|---|---|
| email | 198 | 188 | 5 | 2 | 8 | 5.1% |
| notice | 100 | 86 | 1 | 3 | 11 | 14.0% |
| registry | 405 | 378 | 17 | 19 | 8 | 6.7% |

## By entity type

| | Entities | Hidden | of which wrong type | Partial | Leaked | Leak rate |
|---|---|---|---|---|---|---|
| ADDRESS | 105 | 87 | 14 | 15 | 3 | 17.1% |
| COMPANY | 145 | 133 | 3 | 4 | 8 | 8.3% |
| EMAIL | 80 | 80 | 0 | 0 | 0 | 0.0% |
| ID | 117 | 106 | 0 | 0 | 11 | 9.4% |
| PERSON | 243 | 233 | 6 | 5 | 5 | 4.1% |
| PHONE | 13 | 13 | 0 | 0 | 0 | 0.0% |

## Documents with no leak at all

| Language | Documents | Fully clean | Share | No identifying leak | Share |
|---|---|---|---|---|---|
| en | 16 | 4 | 25% | 4 | 25% |
| es | 14 | 8 | 57% | 8 | 57% |
| fr | 15 | 8 | 53% | 10 | 67% |
| **All** | 45 | 20 | 44% | 22 | 49% |

## Identifying leaks and residue

Residue: what stays visible is only short numbers, unit designators, single initials, state codes and unit or legal-form words.

| Language | Entities | Identifying | Residue | Identifying leak rate |
|---|---|---|---|---|
| en | 298 | 22 | 2 | 7.4% |
| es | 296 | 17 | 0 | 5.7% |
| fr | 109 | 8 | 2 | 7.3% |

## Reference numbers (counted separately)

5 invoice, contract, policy and file numbers: 1 hidden, 2 partial, 2 leaked.

## Left visible by default (counted separately)

Amounts and dates other than dates of birth are detected but switched off. *Detected* means the user can switch them on.

| | Entities | Detected | Partly detected | Not detected |
|---|---|---|---|---|
| AMOUNT | 49 | 35 | 0 | 14 |
| DATE | 133 | 131 | 0 | 2 |

## NUMBER placeholders: 8

Digit strings matched by a loose rule, hidden under the generic type instead of a guessed one.

- 6× regex:us:passport
- 1× regex:ie:phone
- 1× regex:universal:labeled_id

## Over-redaction: 45 detections that touch no expected entity

- 11× `BOLETÍN OFICIAL DEL REGISTRO MERCANTIL` as COMPANY (ner:xlm-roberta-base-ner-hrl)
- 4× `ECT` as COMPANY (ner:xlm-roberta-base-ner-hrl)
- 2× `.M.` as ADDRESS (ner:xlm-roberta-base-ner-hrl)
- 2× `R.M.` as ADDRESS (ner:xlm-roberta-base-ner-hrl)
- 2× `Desert Southwest` as ADDRESS (ner:xlm-roberta-base-ner-hrl)
- 2× `SQL_MAIL` as PERSON (ner:xlm-roberta-base-ner-hrl)
- 1× `Dauphiné` as ADDRESS (ner:xlm-roberta-base-ner-hrl)
- 1× `BODACC` as COMPANY (ner:xlm-roberta-base-ner-hrl)
- 1× `MERCANTIL` as COMPANY (ner:xlm-roberta-base-ner-hrl)
- 1× `Administración` as COMPANY (ner:xlm-roberta-base-ner-hrl)
- 1× `Sociedad` as COMPANY (ner:xlm-roberta-base-ner-hrl)
- 1× `CNAE` as COMPANY (ner:xlm-roberta-base-ner-hrl)
- 1× `CNAE 9609` as ID (regex:universal:labeled_id)
- 1× `DEL REGISTRO MERCANTIL` as COMPANY (ner:xlm-roberta-base-ner-hrl)
- 1× `88506 DONDE SE LEE COMO PRIMER APELLIDO DEL ADMINISTRADOR UNICO` as ADDRESS (regex:es:postal)
- 1× `High Court of Justice, Business and Property Courts` as COMPANY (ner:xlm-roberta-base-ner-hrl)
- 1× `High Court of Justice⏎Business and Property Courts` as COMPANY (ner:xlm-roberta-base-ner-hrl)
- 1× `Rules` as COMPANY (list:company)
- 1× `Board of Directors` as COMPANY (ner:xlm-roberta-base-ner-hrl)
- 1× `ENRON` as ADDRESS (ner:xlm-roberta-base-ner-hrl)
- 1× `Desert` as COMPANY (ner:xlm-roberta-base-ner-hrl)
- 1× `Southwest` as ADDRESS (ner:xlm-roberta-base-ner-hrl)
- 1× `HOU` as COMPANY (ner:xlm-roberta-base-ner-hrl)
- 1× `will` as PERSON (propagated)

## Leaked (27)

- ID `31850` (en-gazette-01, en-gazette-04)
- ID `32230` (en-gazette-01, en-gazette-04)
- COMPANY `LB INVEST` (fr-bodacc-creation-04)
- COMPANY `REST'OR` (fr-bodacc-vente-01)
- COMPANY `AIR DU TEMPS` (fr-bodacc-vente-02)
- COMPANY `HK-RS` (fr-bodacc-collective-03)
- COMPANY `Net'Pro 43` (fr-bodacc-collective-04)
- ID `Z21406076C` (es-borme-04-1)
- ADDRESS `CL PADRO NUM.87 P.0 (RIPOLLET)` (es-borme-05-3)
- PERSON `PINCHAS ROZEN` (es-borme-05-3)
- ID `29010` (en-gazette-02)
- ID `11110` (en-gazette-03)
- ID `18032` (en-gazette-03)
- ADDRESS `Birmingham` (en-gazette-05)
- ID `22930` (en-gazette-05)
- ID `020730` (en-gazette-05)
- ID `13890` (en-gazette-06)
- PERSON `Ina` (en-enron-01)
- PERSON `karen` (en-enron-01)
- PERSON `tom` (en-enron-02)
- ADDRESS `Suite 165` (en-enron-02)
- PERSON `Kath` (en-enron-04)
- COMPANY `EnronOnline` (en-enron-05)
- COMPANY `EPMI` (en-enron-06)
- COMPANY `ENA` (en-enron-07)

## Partially visible (24)

- ADDRESS `Zone Industrielle Kaweni BP 633 Route nationale 1 - 97600 MAMOUDZOU` → `████ Industrielle Kaweni BP █████████████████████ - ███████████████` (fr-bodacc-vente-01)
- COMPANY `JERVIS BAY` → `██████ BAY` (fr-bodacc-vente-02)
- COMPANY `FF BONNEVEINE MENAGER` → `FF ██████████████████` (fr-bodacc-vente-03)
- ADDRESS `81 ZA de Chatimbarbe, 43200 Yssingeaux` → `81 ZA de ███████████, ████████████████` (fr-bodacc-collective-04)
- PERSON `Roche, Jean-François Jules` → `Roche, ███████████████████` (fr-bodacc-modification-02)
- COMPANY `PARQUE CIENTIFICO-TECNOLOGICO DE ALMERIA (PITA) SOCIEDAD ANONIMA` → `████████████████████████████████ ███████ (████) SOCIEDAD ANONIMA` (es-borme-02-2)
- ADDRESS `CTRA DE ENTRERRIOS, S/N-FABRICA DE TRANSA 06700 (VILLANUEVA DE LA SERENA)` → `CTRA DE ENTRERRIOS, S/N-FABRICA DE TRANSA ███████████████████████████████` (es-borme-03-2)
- ADDRESS `CTRA DE ENTRERRIOS S/N, FABRICA DE TRANSA, S/N-FAB (VILLANUEVA DE LA SERENA)` → `CTRA DE ENTRERRIOS S/N, FABRICA DE TRANSA, S/N-FAB (███████████████████████)` (es-borme-03-2)
- ADDRESS `POLIG 9-PARCELA 54 (SIRUELA)` → `POLIG 9-PARCELA 54 (███████)` (es-borme-03-2)
- COMPANY `FINANCIERE JL SAS` → `FINANCIERE ██████` (es-borme-04-2)
- ADDRESS `CL FLORIDABLANCA NUM.29 P.4 PTA.2 (BADALONA)` → `CL █████████████ NUM.29 P.4 PTA.2 (BADALONA)` (es-borme-05-2)
- ADDRESS `CL TARRAGONA NUM.4 P.3 PTA.4 (MONTGAT)` → `CL TARRAGONA NUM.4 P.3 PTA.4 (███████)` (es-borme-05-2)
- ADDRESS `CL LLIBERTAT NUM.105 (PARETS DEL VALLES)` → `CL LLIBERTAT NUM.105 (█████████████████)` (es-borme-05-3)
- ADDRESS `CL GRAN VIA CARLES III NUM.98 P.10 (BARCELONA)` → `CL GRAN ██████████████████.98 P.10 (█████████)` (es-borme-05-3)
- ADDRESS `CL SANTIGA NUM.116 (SABADELL)` → `CL SANTIGA NUM.116 (████████)` (es-borme-05-3)
- ADDRESS `CL PROVENZA NUM.541 (BARCELONA)` → `CL PROVENZA NUM.541 (█████████)` (es-borme-05-3)
- ADDRESS `CL LLEDONERS NUM.17 (CABRILS)` → `CL LLEDONERS NUM.17 (███████)` (es-borme-05-3)
- PERSON `QUINTANS OSeS ALEJANDRO` → `████████ OSeS ALEJANDRO` (es-borme-05-3)
- PERSON `ALEJANDRO QUINTANS OSeS` → `ALEJANDRO ████████ OSeS` (es-borme-05-3)
- ADDRESS `Unit 14C Hartlebury Trading Estate, Hartlebury, Kidderminste, DY104JB` → `Unit 14C █████████████████████████, ██████████, ████████████, ███████` (en-gazette-04)
- ADDRESS `The Union Building 51-59 Rose Lane, Norwich, NR1 1BY, United Kingdom` → `The Union Building 51-████████████, ███████, ███████, ██████████████` (en-gazette-06)
- ADDRESS `The Union Building 51-59 Rose Lane, Norwich, NR1 1BY` → `The Union Building 51-████████████, ███████, ███████` (en-gazette-06)
- PERSON `Elafandi, Mo` → `████████, Mo` (en-enron-04)
- PERSON `Hammond, Don` → `███████, Don` (en-enron-04)
