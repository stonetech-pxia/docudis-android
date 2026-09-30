# Leak report: xlm-roberta-base-ner-hrl

Dataset: `C:/Users/Xia/projects/docudis/benchmark/regression_cases.json`, 48 documents.

An entity is *hidden* when every alphanumeric character of every occurrence is covered by some detection, of any type. *Wrong type* is hidden under another placeholder type (no leak). *Partial* and *leaked* both expose text.

| | Entities | Hidden | of which wrong type | Partial | Leaked | Leak rate |
|---|---|---|---|---|---|---|
| **All** | 651 | 509 | 18 | 74 | 68 | 21.8% |

## By language

| | Entities | Hidden | of which wrong type | Partial | Leaked | Leak rate |
|---|---|---|---|---|---|---|
| en | 239 | 190 | 9 | 23 | 26 | 20.5% |
| es | 198 | 153 | 3 | 26 | 19 | 22.7% |
| fr | 214 | 166 | 6 | 25 | 23 | 22.4% |

## By document type

| | Entities | Hidden | of which wrong type | Partial | Leaked | Leak rate |
|---|---|---|---|---|---|---|
| bank | 68 | 57 | 2 | 5 | 6 | 16.2% |
| catalogue | 30 | 21 | 2 | 2 | 7 | 30.0% |
| chat | 28 | 16 | 1 | 3 | 9 | 42.9% |
| cv | 79 | 65 | 1 | 11 | 3 | 17.7% |
| insurance | 58 | 45 | 1 | 8 | 5 | 22.4% |
| invoice | 54 | 40 | 1 | 8 | 6 | 25.9% |
| jobad | 17 | 16 | 0 | 1 | 0 | 5.9% |
| lease | 43 | 34 | 1 | 5 | 4 | 20.9% |
| letter | 47 | 36 | 2 | 8 | 3 | 23.4% |
| manual | 9 | 7 | 0 | 2 | 0 | 22.2% |
| medical | 52 | 42 | 0 | 4 | 6 | 19.2% |
| notice | 15 | 14 | 2 | 1 | 0 | 6.7% |
| payslip | 50 | 38 | 3 | 4 | 8 | 24.0% |
| policy | 25 | 21 | 1 | 4 | 0 | 16.0% |
| support | 55 | 42 | 0 | 5 | 8 | 23.6% |
| terms | 21 | 15 | 1 | 3 | 3 | 28.6% |

## By entity type

| | Entities | Hidden | of which wrong type | Partial | Leaked | Leak rate |
|---|---|---|---|---|---|---|
| ADDRESS | 209 | 140 | 7 | 52 | 17 | 33.0% |
| BIRTH_DATE | 16 | 14 | 0 | 0 | 2 | 12.5% |
| CARD | 8 | 5 | 0 | 0 | 3 | 37.5% |
| COMPANY | 101 | 84 | 2 | 8 | 9 | 16.8% |
| EMAIL | 34 | 34 | 0 | 0 | 0 | 0.0% |
| IBAN | 16 | 15 | 0 | 1 | 0 | 6.2% |
| ID | 107 | 71 | 1 | 7 | 29 | 33.6% |
| PERSON | 109 | 95 | 6 | 6 | 8 | 12.8% |
| PHONE | 50 | 50 | 2 | 0 | 0 | 0.0% |
| URL | 1 | 1 | 0 | 0 | 0 | 0.0% |

## Documents with no leak at all

| Language | Documents | Fully clean | Share | No identifying leak | Share |
|---|---|---|---|---|---|
| en | 16 | 2 | 12% | 5 | 31% |
| es | 16 | 1 | 6% | 2 | 12% |
| fr | 16 | 2 | 12% | 5 | 31% |
| **All** | 48 | 5 | 10% | 12 | 25% |

## Identifying leaks and residue

Residue: what stays visible is only short numbers, unit designators, single initials, state codes and unit or legal-form words.

| Language | Entities | Identifying | Residue | Identifying leak rate |
|---|---|---|---|---|
| en | 239 | 29 | 20 | 12.1% |
| es | 198 | 26 | 19 | 13.1% |
| fr | 214 | 29 | 19 | 13.6% |

## Reference numbers (counted separately)

59 invoice, contract, policy and file numbers: 9 hidden, 17 partial, 33 leaked.

## Left visible by default (counted separately)

Amounts and dates other than dates of birth are detected but switched off. *Detected* means the user can switch them on.

| | Entities | Detected | Partly detected | Not detected |
|---|---|---|---|---|
| AMOUNT | 176 | 170 | 0 | 6 |
| DATE | 190 | 174 | 0 | 16 |

## NUMBER placeholders: 86

Digit strings matched by a loose rule, hidden under the generic type instead of a guessed one.

- 41× regex:universal:long_number
- 13× regex:universal:labeled_id
- 9× regex:ie:phone
- 7× regex:fr:siret
- 4× regex:gb:sort_code
- 4× propagated
- 4× regex:es:nuss
- 1× regex:gb:bank_account
- 1× regex:us:passport
- 1× regex:gb:vat
- 1× regex:fr:vat

## Over-redaction: 161 detections that touch no expected entity

- 5× `Marsden Row` as ADDRESS (ner:xlm-roberta-base-ner-hrl)
- 3× `England` as ADDRESS (ner:xlm-roberta-base-ner-hrl)
- 3× `Wales` as ADDRESS (ner:xlm-roberta-base-ner-hrl)
- 3× `Hollowgate Lane` as ADDRESS (ner:xlm-roberta-base-ner-hrl)
- 3× `IT Service Desk` as COMPANY (ner:xlm-roberta-base-ner-hrl)
- 3× `avenida de los Olmares` as ADDRESS (ner:xlm-roberta-base-ner-hrl)
- 3× `SIRET` as COMPANY (ner:xlm-roberta-base-ner-hrl)
- 3× `IBAN` as COMPANY (ner:xlm-roberta-base-ner-hrl)
- 3× `rue des Tanneurs` as ADDRESS (ner:xlm-roberta-base-ner-hrl)
- 2× `Ireland` as ADDRESS (ner:xlm-roberta-base-ner-hrl)
- 2× `Department of Veterans Affairs` as COMPANY (ner:xlm-roberta-base-ner-hrl)
- 2× `United Kingdom` as ADDRESS (ner:xlm-roberta-base-ner-hrl)
- 2× `88-4401` as NUMBER (propagated)
- 2× `60335-2-51` as NUMBER (regex:universal:long_number)
- 2× `Carlow Street` as ADDRESS (ner:xlm-roberta-base-ner-hrl)
- 2× `Dunmoor Avenue` as ADDRESS (ner:xlm-roberta-base-ner-hrl)
- 2× `Procurement` as COMPANY (ner:xlm-roberta-base-ner-hrl)
- 2× `Information Security` as COMPANY (ner:xlm-roberta-base-ner-hrl)
- 2× `Dirección de Recursos Humanos` as COMPANY (ner:xlm-roberta-base-ner-hrl)
- 2× `Departamento de Administración` as COMPANY (ner:xlm-roberta-base-ner-hrl)
- 2× `SIRET` as ADDRESS (ner:xlm-roberta-base-ner-hrl)
- 2× `Collègue` as PERSON (ner:xlm-roberta-base-ner-hrl)
- 2× `Direction des ressources humaines` as COMPANY (ner:xlm-roberta-base-ner-hrl)
- 1× `Lending` as COMPANY (ner:xlm-roberta-base-ner-hrl)

## Leaked (68)

- ADDRESS `bajo C` (es-insurance-01, es-letter-01)
- ADDRESS `PO Box 4402` (en-bank-01)
- ID `929027` (en-bank-01)
- ADDRESS `Cork` (en-catalogue-01)
- ID `419776` (en-catalogue-01)
- ID `IE 4197763T` (en-catalogue-01)
- PERSON `aoife` (en-chat-01)
- PERSON `tomek` (en-chat-01)
- PERSON `sinead` (en-chat-01)
- ADDRESS `rathgar` (en-chat-01)
- ID `IE3847291GH` (en-invoice-01)
- ID `612884` (en-invoice-01)
- ID `FERR-014` (en-invoice-01)
- ADDRESS `Walk` (en-invoice-01)
- ID `AIBKIE2D` (en-invoice-01)
- COMPANY `Tenancy Deposit Scheme` (en-lease-01)
- ADDRESS `PO Box 227` (en-letter-01)
- ID `YRH8820416` (en-medical-01)
- ID `004791` (en-medical-01)
- ID `083/HR4419` (en-payslip-01)
- COMPANY `Nest` (en-payslip-01)
- COMPANY `Unite` (en-payslip-01)
- CARD `1651` (en-support-01)
- BIRTH_DATE `09/02/1984` (en-support-01)
- ID `641208` (en-support-01)
- ID `IE 4412097T` (en-support-01)
- ID `WEE/JB3392AC` (en-terms-01)
- CARD `6046` (es-bank-01)
- COMPANY `Ferretería Baldosa` (es-bank-01)
- ID `A-28455091` (es-catalogue-01)
- ID `M-431.778` (es-catalogue-01)
- PERSON `marta` (es-chat-01)
- PERSON `yusuf` (es-chat-01)
- COMPANY `Aula Bética` (es-cv-01)
- ADDRESS `Zaragoza` (es-insurance-01)
- ID `7382901YJ2778S0012KP` (es-lease-01)
- ID `41.228` (es-lease-01)
- ADDRESS `Carretera de Toledo, km 12,500` (es-medical-01)
- ID `28/4419788` (es-medical-01)
- ID `B-87421903` (es-payslip-01)
- ID `04127` (es-payslip-01)
- ID `208877` (es-support-01)
- ID `B-97684512` (es-terms-01)
- ID `V-152.334` (es-terms-01)
- ADDRESS `bâtiment C, appartement 42` (fr-bank-01)
- ADDRESS `Vincennes` (fr-bank-01)
- ID `40712` (fr-catalogue-01)
- COMPANY `Geodis` (fr-catalogue-01)

## Partially visible (74)

- PERSON `P. Ravindran-Blake` → `P█████████████████` (en-bank-01)
- ADDRESS `2184 Cedarbrook Trail, Apt 3C` → `█████████████████████, Apt 3C` (en-cv-01)
- ADDRESS `Round Rock, TX 78664` → `██████████, TX 78664` (en-cv-01)
- ADDRESS `900 Loop Crossing Drive, Georgetown, TX 78626` → `███████████████████████, ██████████, TX 78626` (en-cv-01)
- ADDRESS `Temple, TX` → `██████, TX` (en-cv-01)
- ADDRESS `47 Rockwell Bend Road, Killeen, TX 76541` → `█████████████████████, ███████, TX 76541` (en-cv-01)
- COMPANY `The University of Texas at Austin` → `███████████████████████ at ██████` (en-cv-01)
- ADDRESS `Cedar Park, TX` → `██████████, TX` (en-cv-01)
- ADDRESS `15-19 Bloomsbury Way` → `15-█████████████████` (en-insurance-01)
- PERSON `A. Oyelaran-Hart` → `A███████████████` (en-insurance-01)
- ADDRESS `9 Roseberry Meadows, Saint Brigid's` → `███████████████████, Saint Brigid's` (en-invoice-01)
- ADDRESS `Naas, Co. Kildare` → `█████████ Kildare` (en-invoice-01)
- COMPANY `Calderwych Bay Health Partnership` → `██████████████ Health Partnership` (en-jobad-01)
- PERSON `Adeyemi, Folasade O.` → `███████, ████████ O.` (en-lease-01)
- ADDRESS `41 Lindley Croft` → `41 ███████ █████` (en-letter-01)
- ADDRESS `2180 Harnett Boulevard, Suite 410` → `██████████████████████, Suite 410` (en-medical-01)
- ADDRESS `Columbus, OH 43215` → `████████, OH 43215` (en-medical-01)
- ADDRESS `3117 Winnemac Avenue, Apt 2B` → `████████████████████, Apt 2B` (en-medical-01)
- ADDRESS `Unit 7, Parkfield Industrial Estate` → `████████████████████████████ Estate` (en-payslip-01)
- ADDRESS `2400 SW Halverson Loop, Beaverton, OR 97006` → `██████████████████████, █████████, OR 97006` (en-policy-01)
- ADDRESS `Unit 12, Cloverhill Retail Park` → `██████████████████████████ Park` (en-support-01)
- ADDRESS `Knocknacarra, Galway H91 R2VC` → `Knocknacarra, ██████ ████████` (en-support-01)
- ID `GB 249 8831 07` → `GB ███████████` (en-terms-01)
- ADDRESS `C/ Almendro de la Vega, 27, 3.º B` → `██████████████████████████, 3.º B` (es-bank-01)
- ADDRESS `Carretera de Burgos, km 12,400 — Parque Empresarial Valdehierro, nave 21` → `███████████████████, km 12,400 — ██████ ███████████████████████, nave 21` (es-catalogue-01)
- ADDRESS `Carrer del Molí Nou, 42, esc. B, 4t 2a` → `███████████████████████, ██████, 4t 2a` (es-chat-01)
- ADDRESS `Gran Via Ferran, 8` → `███████████████, 8` (es-chat-01)
- ADDRESS `C/ Cordeleros del Arenal, 118, 2.º izq.` → `█████████████████████████████, 2.º izq.` (es-cv-01)
- ADDRESS `Paseo de la Alameda Vieja, 9, planta 3` → `████████████████████████████, planta 3` (es-insurance-01)
- ADDRESS `Calle Mayor de Torrero, 231, bloque 4` → `███████████████████████████, bloque 4` (es-insurance-01)
- ADDRESS `Calle Mayor de Torrero, 231, bajo C, 50007 Zaragoza` → `███████████████████████████, bajo C, ██████████████` (es-insurance-01)
- ADDRESS `Barrio Ugarte, 7, lonja` → `█████████████, 7, lonja` (es-invoice-01)
- ADDRESS `C/ Zumalabe Kalea, 12, 5.º C` → `█████████████████████, 5.º C` (es-invoice-01)
- ID `ARR-2024/0318` → `████████/0318` (es-lease-01)
- ADDRESS `Carrer del Palleter, 47, 3º` → `███████████████████████, 3º` (es-lease-01)
- ADDRESS `izquierda, 46008 València (Valencia)` → `izquierda, ██████████████ (████████)` (es-lease-01)
- ADDRESS `Port, 112, escalera B, 5ª puerta C, 46023 València` → `█████████, escalera B, 5ª ████████████████████████` (es-lease-01)
- ADDRESS `Apartado de Correos 1128` → `Apartado de ███████ 1128` (es-letter-01)
- ADDRESS `Calle Doctor Fleming, 8, bloque 2` → `███████████████████████, bloque 2` (es-letter-01)
- ID `ES0021000010441563VL` → `██████████████████VL` (es-letter-01)
- ADDRESS `Calle Doctor Fleming, 8, bloque 2, bajo C, 50006 Zaragoza` → `███████████████████████, bloque 2, bajo C, ██████████████` (es-letter-01)
- ADDRESS `Polígono Industrial Las Cañadas, nave 17, 50820 Villamayor (Zaragoza)` → `████████████████████████████████ nave ████████████████████ (████████)` (es-manual-01)
- ADDRESS `plaza Mayor 1, planta baja` → `█████████████, planta baja` (es-notice-01)
- ADDRESS `Polígono Industrial Les Comes, nave 14` → `█████████████████████████████, nave 14` (es-payslip-01)
- PERSON `NKEMDIRIM OKAFOR, Chinaza` → `████████████████, Chinaza` (es-payslip-01)
- ADDRESS `Avinguda de la Riera, 88 — 4ª planta` → `████████████████████, 88 — 4ª planta` (es-policy-01)
- ADDRESS `Carrer de Sant Bartomeu, 23, 2º` → `███████████████████████████, 2º` (es-support-01)
- ADDRESS `2ª, 46701 Gandia (Valencia)` → `2ª, ████████████ (████████)` (es-support-01)
