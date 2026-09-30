# Leak report: xlm-roberta-base-ner-docudis

Dataset: `benchmark/consumer_cases.json`, 60 documents.

An entity is *hidden* when every alphanumeric character of every occurrence is covered by some detection, of any type. *Wrong type* is hidden under another placeholder type (no leak). *Partial* and *leaked* both expose text.

| | Entities | Hidden | of which wrong type | Partial | Leaked | Leak rate |
|---|---|---|---|---|---|---|
| **All** | 1612 | 1543 | 22 | 26 | 43 | 4.3% |

## By language

| | Entities | Hidden | of which wrong type | Partial | Leaked | Leak rate |
|---|---|---|---|---|---|---|
| en | 544 | 525 | 8 | 3 | 16 | 3.5% |
| es | 497 | 482 | 3 | 6 | 9 | 3.0% |
| fr | 571 | 536 | 11 | 17 | 18 | 6.1% |

## By document type

| | Entities | Hidden | of which wrong type | Partial | Leaked | Leak rate |
|---|---|---|---|---|---|---|
| bank | 134 | 128 | 1 | 0 | 6 | 4.5% |
| chat | 69 | 54 | 2 | 10 | 5 | 21.7% |
| cv | 240 | 233 | 6 | 2 | 5 | 2.9% |
| insurance | 217 | 204 | 3 | 5 | 8 | 6.0% |
| invoice | 186 | 179 | 1 | 5 | 2 | 3.8% |
| lease | 173 | 168 | 1 | 1 | 4 | 2.9% |
| letter | 141 | 138 | 2 | 0 | 3 | 2.1% |
| medical | 191 | 187 | 3 | 2 | 2 | 2.1% |
| payslip | 142 | 140 | 2 | 0 | 2 | 1.4% |
| support | 119 | 112 | 1 | 1 | 6 | 5.9% |

## By entity type

| | Entities | Hidden | of which wrong type | Partial | Leaked | Leak rate |
|---|---|---|---|---|---|---|
| ADDRESS | 393 | 377 | 9 | 4 | 12 | 4.1% |
| BIRTH_DATE | 24 | 23 | 0 | 0 | 1 | 4.2% |
| CARD | 6 | 0 | 0 | 0 | 6 | 100.0% |
| COMPANY | 229 | 219 | 5 | 4 | 6 | 4.4% |
| EMAIL | 104 | 104 | 0 | 0 | 0 | 0.0% |
| IBAN | 31 | 30 | 0 | 1 | 0 | 3.2% |
| ID | 206 | 185 | 1 | 7 | 14 | 10.2% |
| PERSON | 436 | 425 | 7 | 9 | 2 | 2.5% |
| PHONE | 169 | 167 | 0 | 1 | 1 | 1.2% |
| URL | 14 | 13 | 0 | 0 | 1 | 7.1% |

## Documents with no leak at all

| Language | Documents | Fully clean | Share | No identifying leak | Share |
|---|---|---|---|---|---|
| en | 20 | 7 | 35% | 13 | 65% |
| es | 20 | 10 | 50% | 15 | 75% |
| fr | 20 | 8 | 40% | 12 | 60% |
| **All** | 60 | 25 | 42% | 40 | 67% |

## Identifying leaks and residue

Residue: what stays visible is only short numbers, unit designators, single initials, state codes and unit or legal-form words.

| Language | Entities | Identifying | Residue | Identifying leak rate |
|---|---|---|---|---|
| en | 544 | 8 | 11 | 1.5% |
| es | 497 | 7 | 8 | 1.4% |
| fr | 571 | 16 | 19 | 2.8% |

## Reference numbers (counted separately)

68 invoice, contract, policy and file numbers: 50 hidden, 9 partial, 9 leaked.

## Left visible by default (counted separately)

Amounts and dates other than dates of birth are detected but switched off. *Detected* means the user can switch them on.

| | Entities | Detected | Partly detected | Not detected |
|---|---|---|---|---|
| AMOUNT | 194 | 175 | 8 | 11 |
| DATE | 264 | 262 | 1 | 1 |

## NUMBER placeholders: 159

Digit strings matched by a loose rule, hidden under the generic type instead of a guessed one.

- 40× regex:universal:long_number
- 35× regex:universal:labeled_id_no
- 21× regex:universal:labeled_id
- 12× regex:es:nuss
- 10× regex:universal:named_national_id
- 9× regex:fr:siret
- 7× regex:ie:phone
- 5× regex:us:passport
- 4× regex:gb:vat
- 4× regex:fr:vat
- 3× regex:gb:sort_code
- 3× regex:gb:bank_account
- 3× propagated
- 1× regex:us:phone
- 1× regex:universal:phone_intl
- 1× regex:es:hoja_registral

## Over-redaction: 90 detections that touch no expected entity

- 5× `Mastercard` as COMPANY (list:company)
- 2× `England` as ADDRESS (ner:xlm-roberta-base-ner-docudis)
- 2× `rose` as PERSON (propagated)
- 2× `BA1393` as ID (propagated)
- 2× `SIRET` as ADDRESS (ner:xlm-roberta-base-ner-docudis)
- 2× `EURL` as COMPANY (ner:xlm-roberta-base-ner-docudis)
- 1× `Wales No.` as ADDRESS (ner:xlm-roberta-base-ner-docudis)
- 1× `Wire Services` as COMPANY (ner:xlm-roberta-base-ner-docudis)
- 1× `Airstream` as COMPANY (list:company)
- 1× `FDIC` as COMPANY (list:company)
- 1× `van mans` as PERSON (ner:xlm-roberta-base-ner-docudis)
- 1× `ACLS` as COMPANY (ner:xlm-roberta-base-ner-docudis)
- 1× `BLS` as COMPANY (ner:xlm-roberta-base-ner-docudis)
- 1× `CLABSI` as COMPANY (ner:xlm-roberta-base-ner-docudis)
- 1× `COVID ICU` as COMPANY (ner:xlm-roberta-base-ner-docudis)
- 1× `MSN` as COMPANY (ner:xlm-roberta-base-ner-docudis)
- 1× `SKILLS⏎Epic` as COMPANY (ner:xlm-roberta-base-ner-docudis)
- 1× `BCMA` as COMPANY (ner:xlm-roberta-base-ner-docudis)
- 1× `MSN` as COMPANY (propagated)
- 1× `MHA` as COMPANY (ner:xlm-roberta-base-ner-docudis)
- 1× `BTEC Level` as COMPANY (ner:xlm-roberta-base-ner-docudis)
- 1× `Worcester Bosch Greenstar` as COMPANY (ner:xlm-roberta-base-ner-docudis)
- 1× `Rules and Regulations` as COMPANY (list:company)
- 1× `WZ  MD` as PERSON (ner:xlm-roberta-base-ner-docudis)

## Leaked (43)

- ID `7702` (en-bank-02)
- PERSON `reggie` (en-chat-02)
- COMPANY `AACN` (en-cv-01)
- BIRTH_DATE `02/11/1985` (en-insurance-01)
- COMPANY `Premium Credit` (en-insurance-01)
- CARD `3308` (en-insurance-01)
- ID `6120` (en-insurance-01)
- ID `4402` (en-insurance-02)
- ADDRESS `Dallas` (en-invoice-02)
- CARD `1554` (en-invoice-02)
- URL `pay.hallgrenpm.com` (en-lease-01)
- ADDRESS `Leeds` (en-letter-02)
- PHONE `80-2214` (en-medical-01)
- ID `20-49` (en-payslip-02)
- CARD `9901` (en-support-01)
- ID `4471` (en-support-02)
- CARD `4410` (es-bank-01)
- ADDRESS `Vallès Occidental` (es-bank-01)
- COMPANY `grupo alcor` (es-chat-02)
- ID `MU-80.417` (es-insurance-01)
- ID `31.877` (es-lease-01)
- ID `3.412` (es-letter-01)
- ID `PO-31.906` (es-payslip-01)
- ADDRESS `Sevilla` (es-support-01)
- CARD `8036` (es-support-01)
- ID `30857` (fr-bank-01)
- ID `70037` (fr-bank-01)
- ID `77` (fr-bank-01)
- COMPANY `leclerc` (fr-chat-01)
- PERSON `jo` (fr-chat-01)
- ADDRESS `3e etage` (fr-chat-01)
- ADDRESS `Pampelune` (fr-cv-01)
- ADDRESS `Nord vaudois` (fr-cv-02)
- ADDRESS `Suisse` (fr-cv-02)
- ADDRESS `Morat` (fr-cv-02)
- COMPANY `MASO Assurances` (fr-insurance-02)
- ADDRESS `appt 42` (fr-insurance-02)
- ID `204` (fr-lease-01)
- ADDRESS `Bâtiment : B     Étage : 2e     Porte : 204` (fr-lease-01)
- ID `0417-B32` (fr-letter-01)
- ADDRESS `Sin-le-Noble` (fr-medical-01)
- COMPANY `Chronopost` (fr-support-01)
- CARD `8538` (fr-support-01)

## Partially visible (26)

- ID `MPC/2291847/03` → `MPC/███████/03` (en-insurance-01)
- ID `GB 483 7152 30` → `GB ███████████` (en-invoice-01)
- ADDRESS `Level 2, Gledhow Wing` → `Level 2, ████████████` (en-medical-01)
- COMPANY `transportes beltran` → `transportes ███████` (es-chat-02)
- COMPANY `Sanchis, Beltrán y Asociados, S.L.P.` → `Sanchis, ███████████████████████████` (es-insurance-02)
- PERSON `Rosa Mª Chuliá Peris` → `██████████████ Peris` (es-insurance-02)
- ID `48/IF-02917` → `48/IF-█████` (es-invoice-01)
- COMPANY `Tetuán Gestión Inmobiliaria` → `██████ Gestión Inmobiliaria` (es-lease-01)
- PERSON `QUISPE MAMANI, Wilson F.` → `█████████████████████ F.` (es-medical-02)
- PERSON `Nadia` → `N████` (fr-chat-01)
- PERSON `Momo` → `Mo██` (fr-chat-01)
- PERSON `karim` → `k████` (fr-chat-01)
- PERSON `pierre` → `p█████` (fr-chat-01)
- PERSON `Yasmine Belkacem` → `Y███████████████` (fr-chat-01)
- ADDRESS `14 rue des Tanneurs bat C, 69009 Lyon` → `1█████████████████████████ 6█████████` (fr-chat-01)
- PERSON `Vasseur` → `V██████` (fr-chat-01)
- IBAN `FR76 1079 3094 9303 5121 1859 458` → `F████████████████████████████████` (fr-chat-01)
- PHONE `06 41 27 93 05` → `06 ███████████` (fr-chat-01)
- ADDRESS `Pays basque` → `████ basque` (fr-cv-01)
- COMPANY `IUT de Bayonne et du Pays basque` → `██████ ███████ et du ████ basque` (fr-cv-01)
- ID `AU 7482913 C` → `██████████ C` (fr-insurance-01)
- ID `HAB 4 417 902 66` → `HAB ████████████` (fr-insurance-02)
- ID `129 445 872 K` → `███████████ K` (fr-invoice-01)
- ADDRESS `Libre réponse n° 59252, 75443 Paris Cedex 09` → `Libre réponse n° █████, ████████████████████` (fr-invoice-02)
- ID `FR 79 619326754` → `FR ████████████` (fr-invoice-02)
- PERSON `Élodie M.` → `██████ M.` (fr-support-01)
