# Leak report: xlm-roberta-base-ner-docudis

Dataset: `benchmark/consumer_cases.json`, 60 documents.

An entity is *hidden* when every alphanumeric character of every occurrence is covered by some detection, of any type. *Wrong type* is hidden under another placeholder type (no leak). *Partial* and *leaked* both expose text.

| | Entities | Hidden | of which wrong type | Partial | Leaked | Leak rate |
|---|---|---|---|---|---|---|
| **All** | 1612 | 1454 | 20 | 58 | 100 | 9.8% |

## By language

| | Entities | Hidden | of which wrong type | Partial | Leaked | Leak rate |
|---|---|---|---|---|---|---|
| en | 544 | 480 | 6 | 19 | 45 | 11.8% |
| es | 497 | 455 | 5 | 15 | 27 | 8.5% |
| fr | 571 | 519 | 9 | 24 | 28 | 9.1% |

## By document type

| | Entities | Hidden | of which wrong type | Partial | Leaked | Leak rate |
|---|---|---|---|---|---|---|
| bank | 134 | 116 | 3 | 6 | 12 | 13.4% |
| chat | 69 | 53 | 2 | 10 | 6 | 23.2% |
| cv | 240 | 225 | 5 | 9 | 6 | 6.2% |
| insurance | 217 | 190 | 2 | 7 | 20 | 12.4% |
| invoice | 186 | 164 | 1 | 12 | 10 | 11.8% |
| lease | 173 | 158 | 1 | 6 | 9 | 8.7% |
| letter | 141 | 137 | 2 | 0 | 4 | 2.8% |
| medical | 191 | 179 | 2 | 4 | 8 | 6.3% |
| payslip | 142 | 121 | 1 | 2 | 19 | 14.8% |
| support | 119 | 111 | 1 | 2 | 6 | 6.7% |

## By entity type

| | Entities | Hidden | of which wrong type | Partial | Leaked | Leak rate |
|---|---|---|---|---|---|---|
| ADDRESS | 393 | 364 | 8 | 16 | 13 | 7.4% |
| BIRTH_DATE | 24 | 23 | 0 | 0 | 1 | 4.2% |
| CARD | 6 | 0 | 0 | 0 | 6 | 100.0% |
| COMPANY | 229 | 201 | 5 | 15 | 13 | 12.2% |
| EMAIL | 104 | 104 | 0 | 0 | 0 | 0.0% |
| IBAN | 31 | 24 | 0 | 6 | 1 | 22.6% |
| ID | 206 | 133 | 0 | 12 | 61 | 35.4% |
| PERSON | 436 | 425 | 7 | 8 | 3 | 2.5% |
| PHONE | 169 | 167 | 0 | 1 | 1 | 1.2% |
| URL | 14 | 13 | 0 | 0 | 1 | 7.1% |

## Documents with no leak at all

| Language | Documents | Fully clean | Share | No identifying leak | Share |
|---|---|---|---|---|---|
| en | 20 | 1 | 5% | 2 | 10% |
| es | 20 | 3 | 15% | 7 | 35% |
| fr | 20 | 5 | 25% | 5 | 25% |
| **All** | 60 | 9 | 15% | 14 | 23% |

## Identifying leaks and residue

Residue: what stays visible is only short numbers, unit designators, single initials, state codes and unit or legal-form words.

| Language | Entities | Identifying | Residue | Identifying leak rate |
|---|---|---|---|---|
| en | 544 | 47 | 17 | 8.6% |
| es | 497 | 26 | 16 | 5.2% |
| fr | 571 | 28 | 24 | 4.9% |

## Reference numbers (counted separately)

68 invoice, contract, policy and file numbers: 21 hidden, 21 partial, 26 leaked.

## Left visible by default (counted separately)

Amounts and dates other than dates of birth are detected but switched off. *Detected* means the user can switch them on.

| | Entities | Detected | Partly detected | Not detected |
|---|---|---|---|---|
| AMOUNT | 194 | 175 | 8 | 11 |
| DATE | 264 | 263 | 1 | 0 |

## NUMBER placeholders: 147

Digit strings matched by a loose rule, hidden under the generic type instead of a guessed one.

- 62× regex:universal:long_number
- 26× regex:universal:labeled_id
- 11× regex:us:passport
- 10× regex:fr:siret
- 8× regex:ie:phone
- 7× regex:gb:bank_account
- 5× regex:gb:sort_code
- 5× regex:es:nuss
- 4× regex:gb:vat
- 4× regex:fr:vat
- 3× propagated
- 1× regex:us:phone
- 1× regex:universal:phone_intl

## Over-redaction: 98 detections that touch no expected entity

- 5× `Mastercard` as COMPANY (list:company)
- 3× `England` as ADDRESS (ner:xlm-roberta-base-ner-docudis)
- 3× `BA1393` as ID (propagated)
- 2× `Wales` as ADDRESS (ner:xlm-roberta-base-ner-docudis)
- 2× `van` as PERSON (propagated)
- 2× `rose` as PERSON (propagated)
- 2× `SIRET` as ADDRESS (ner:xlm-roberta-base-ner-docudis)
- 2× `Confrère` as PERSON (ner:xlm-roberta-base-ner-docudis)
- 1× `Wire Services` as COMPANY (ner:xlm-roberta-base-ner-docudis)
- 1× `Airstream` as COMPANY (list:company)
- 1× `FDIC` as COMPANY (list:company)
- 1× `van` as PERSON (ner:xlm-roberta-base-ner-docudis)
- 1× `COVID` as ADDRESS (ner:xlm-roberta-base-ner-docudis)
- 1× `MSN` as COMPANY (ner:xlm-roberta-base-ner-docudis)
- 1× `Rover` as COMPANY (ner:xlm-roberta-base-ner-docudis)
- 1× `BCMA` as COMPANY (ner:xlm-roberta-base-ner-docudis)
- 1× `Philips IntelliVue` as COMPANY (ner:xlm-roberta-base-ner-docudis)
- 1× `Alaris` as ADDRESS (ner:xlm-roberta-base-ner-docudis)
- 1× `MSN` as COMPANY (propagated)
- 1× `Scotland` as ADDRESS (ner:xlm-roberta-base-ner-docudis)
- 1× `NICEIC` as COMPANY (ner:xlm-roberta-base-ner-docudis)
- 1× `Worcester Bosch` as COMPANY (ner:xlm-roberta-base-ner-docudis)
- 1× `AutoPay` as COMPANY (ner:xlm-roberta-base-ner-docudis)
- 1× `DOWNED LINES` as ADDRESS (ner:xlm-roberta-base-ner-docudis)

## Leaked (100)

- ADDRESS `Leeds` (en-invoice-01, en-letter-02, en-medical-01)
- ID `CMBRFR2BXXX` (fr-invoice-01, fr-payslip-02)
- ADDRESS `Bristol` (en-bank-01)
- ID `NWBKGB2L` (en-bank-01)
- ID `929027` (en-bank-01)
- ID `7702` (en-bank-02)
- ID `CHASUS33` (en-bank-02)
- PERSON `will` (en-chat-01)
- COMPANY `halvorsen` (en-chat-02)
- PERSON `reggie` (en-chat-02)
- ID `RN298417` (en-cv-01)
- COMPANY `AACN` (en-cv-01)
- ADDRESS `Co. Galway` (en-insurance-01)
- BIRTH_DATE `02/11/1985` (en-insurance-01)
- ID `211-G-4827` (en-insurance-01)
- ID `408213` (en-insurance-01)
- CARD `3308` (en-insurance-01)
- ID `6120` (en-insurance-01)
- ID `C48213` (en-insurance-01)
- ID `318842` (en-insurance-01)
- ID `4402` (en-insurance-02)
- ID `SC002116` (en-insurance-02)
- ID `612884` (en-invoice-01)
- ID `047731` (en-invoice-01)
- ID `10287` (en-invoice-02)
- ADDRESS `Dallas` (en-invoice-02)
- ID `148302771LG` (en-invoice-02)
- CARD `1554` (en-invoice-02)
- COMPANY `Oncor` (en-invoice-02)
- ID `UT482913` (en-lease-01)
- ID `RK170652` (en-lease-01)
- URL `pay.hallgrenpm.com` (en-lease-01)
- PHONE `80-2214` (en-medical-01)
- ID `14D2087315` (en-medical-02)
- COMPANY `Alliant Credit Union` (en-payslip-01)
- ID `xxxxxx9026` (en-payslip-01)
- COMPANY `HARCASTLE JOINERY` (en-payslip-02)
- ADDRESS `Loughborough` (en-payslip-02)
- ID `567/HA41207` (en-payslip-02)
- ID `004417` (en-payslip-02)
- ID `20-49` (en-payslip-02)
- ID `3817` (en-payslip-02)
- CARD `9901` (en-support-01)
- ID `4471` (en-support-02)
- CARD `4410` (es-bank-01)
- ID `A-156980` (es-bank-01)
- COMPANY `grupo alcor` (es-chat-02)
- ID `CS-48-02291` (es-cv-01)

## Partially visible (58)

- PERSON `T H AL-MASRI` → `T ██████████` (en-bank-01)
- IBAN `GB88 NWBK 4321 7853 7536 63` → `GB88 NWBK █████████████████` (en-bank-01)
- ADDRESS `New York, NY` → `████████, NY` (en-bank-02)
- ADDRESS `Marietta, GA` → `████████, GA` (en-cv-01)
- COMPANY `Byrdine F. Lewis College of Nursing` → `████████████████████████ of Nursing` (en-cv-01)
- COMPANY `City of Bristol College` → `City of ███████████████` (en-cv-02)
- ADDRESS `Unit 9, Kings Weston Trade Park, Avonmouth, Bristol BS11 8AZ` → `Unit 9, Kings Weston Trade Park, █████████, ███████ ████████` (en-cv-02)
- ID `MPC/2291847/03` → `MPC/███████/03` (en-insurance-01)
- ADDRESS `Leeds LS7 2BB` → `Leeds ███████` (en-invoice-01)
- ADDRESS `Chapel Allerton` → `██████ Allerton` (en-invoice-01)
- ADDRESS `Unit 4, Sheepscar Court, Meanwood Road, Leeds LS7 2BB` → `██████████████████████████████████████, Leeds ███████` (en-invoice-01)
- ID `GB 483 7152 30` → `GB ███████████` (en-invoice-01)
- ADDRESS `Flat 3, 41 Harold's Cross Road, Dublin 6W, D6W XK72` → `██████████████████████████████, Dublin ████████████` (en-lease-02)
- ID `RT-0122-00486317` → `RT-█████████████` (en-lease-02)
- ADDRESS `17 Cnoc na Cathrach, Knocknacarra, Galway, H91 T2RV` → `17 Cnoc na Cathrach, Knocknacarra, Galway, ████████` (en-lease-02)
- ADDRESS `Level 2, Gledhow Wing` → `Level 2, ████████████` (en-medical-01)
- COMPANY `First Midwest Bank` → `First ████████████` (en-payslip-01)
- ADDRESS `Unit 7 Meadow Lane Ind Est` → `██████████████████ Ind Est` (en-payslip-02)
- ADDRESS `Apartment 12, Millrace Court, Old Kilmainham, Dublin 8, D08 X4K7` → `Apartment 12, Millrace Court, Old Kilmainham, Dublin ███████████` (en-support-02)
- IBAN `ES62 5533 **** **** **** 0127` → `█████████ **** **** **** 0127` (es-bank-02)
- COMPANY `Mercedes-Benz Vitoria` → `█████████████ Vitoria` (es-cv-01)
- COMPANY `Academia Torrero Formación` → `████████████████ Formación` (es-cv-02)
- COMPANY `GENERALI ESPAÑA, S.A. DE SEGUROS Y REASEGUROS` → `████████████████████████████████ Y REASEGUROS` (es-insurance-01)
- ID `HG-46-00729518` → `HG-███████████` (es-insurance-02)
- COMPANY `Sanchis, Beltrán y Asociados, S.L.P.` → `Sanchis, ███████████████████████████` (es-insurance-02)
- ID `48/IF-02917` → `48/IF-█████` (es-invoice-01)
- ID `ES0031 4065 8821 3007 KX` → `█████████████████████ KX` (es-invoice-02)
- IBAN `ES60 2368 **** **** **** 4146` → `█████████ **** **** **** 4146` (es-invoice-02)
- ADDRESS `Apartado de Correos 4127, 50080 Zaragoza` → `████████ de ███████ ████, ██████████████` (es-invoice-02)
- COMPANY `Tetuán Gestión Inmobiliaria` → `██████ Gestión Inmobiliaria` (es-lease-01)
- ID `0847612VK4704H0012RT` → `███████VK4704H0012RT` (es-lease-01)
- COMPANY `Centro de Saúde de Coia` → `███████████████ de ████` (es-medical-01)
- PERSON `QUISPE MAMANI, Wilson F.` → `█████████████████████ F.` (es-medical-02)
- ID `ES0021000014839276KX` → `██████████████████KX` (es-support-02)
- COMPANY `Caisse Régionale de Crédit Agricole Mutuel Pyrénées Gascogne` → `Caisse Régionale de ████████████████████████████████████████` (fr-bank-01)
- IBAN `FR76 8457 **** **** **** **31 349` → `█████████ **** **** **** **31 349` (fr-bank-02)
- PERSON `Nadia` → `N████` (fr-chat-01)
- PERSON `Momo` → `Mo██` (fr-chat-01)
- COMPANY `leclerc` → `l██████` (fr-chat-01)
- PERSON `karim` → `k████` (fr-chat-01)
- PERSON `pierre` → `p█████` (fr-chat-01)
- PERSON `Yasmine Belkacem` → `Y███████████████` (fr-chat-01)
- ADDRESS `14 rue des Tanneurs bat C, 69009 Lyon` → `1████████████████████████████████████` (fr-chat-01)
- PERSON `Vasseur` → `V██████` (fr-chat-01)
- IBAN `FR76 1079 3094 9303 5121 1859 458` → `F████████████████████████████████` (fr-chat-01)
- PHONE `06 41 27 93 05` → `06 ███████████` (fr-chat-01)
- COMPANY `IUT de Bordeaux` → `IUT de ████████` (fr-cv-01)
- COMPANY `IUT de Bayonne et du Pays basque` → `IUT de ███████ et du ███████████` (fr-cv-01)
