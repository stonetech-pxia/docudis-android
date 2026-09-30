# Leak report: xlm-roberta-base-ner-docudis

Dataset: `benchmark/consumer_cases.json`, 60 documents.

An entity is *hidden* when every alphanumeric character of every occurrence is covered by some detection, of any type. *Wrong type* is hidden under another placeholder type (no leak). *Partial* and *leaked* both expose text.

| | Entities | Hidden | of which wrong type | Partial | Leaked | Leak rate |
|---|---|---|---|---|---|---|
| **All** | 1612 | 1456 | 20 | 54 | 102 | 9.7% |

## By language

| | Entities | Hidden | of which wrong type | Partial | Leaked | Leak rate |
|---|---|---|---|---|---|---|
| en | 544 | 481 | 4 | 16 | 47 | 11.6% |
| es | 497 | 456 | 2 | 13 | 28 | 8.2% |
| fr | 571 | 519 | 14 | 25 | 27 | 9.1% |

## By document type

| | Entities | Hidden | of which wrong type | Partial | Leaked | Leak rate |
|---|---|---|---|---|---|---|
| bank | 134 | 116 | 1 | 6 | 12 | 13.4% |
| chat | 69 | 54 | 0 | 10 | 5 | 21.7% |
| cv | 240 | 226 | 9 | 8 | 6 | 5.8% |
| insurance | 217 | 188 | 0 | 8 | 21 | 13.4% |
| invoice | 186 | 165 | 1 | 11 | 10 | 11.3% |
| lease | 173 | 156 | 2 | 7 | 10 | 9.8% |
| letter | 141 | 137 | 2 | 0 | 4 | 2.8% |
| medical | 191 | 182 | 3 | 1 | 8 | 4.7% |
| payslip | 142 | 122 | 1 | 1 | 19 | 14.1% |
| support | 119 | 110 | 1 | 2 | 7 | 7.6% |

## By entity type

| | Entities | Hidden | of which wrong type | Partial | Leaked | Leak rate |
|---|---|---|---|---|---|---|
| ADDRESS | 393 | 361 | 10 | 16 | 16 | 8.1% |
| BIRTH_DATE | 24 | 23 | 0 | 0 | 1 | 4.2% |
| CARD | 6 | 0 | 0 | 0 | 6 | 100.0% |
| COMPANY | 229 | 204 | 5 | 12 | 13 | 10.9% |
| EMAIL | 104 | 104 | 0 | 0 | 0 | 0.0% |
| IBAN | 31 | 24 | 0 | 6 | 1 | 22.6% |
| ID | 206 | 133 | 0 | 12 | 61 | 35.4% |
| PERSON | 436 | 427 | 5 | 7 | 2 | 2.1% |
| PHONE | 169 | 167 | 0 | 1 | 1 | 1.2% |
| URL | 14 | 13 | 0 | 0 | 1 | 7.1% |

## Documents with no leak at all

| Language | Documents | Fully clean | Share | No identifying leak | Share |
|---|---|---|---|---|---|
| en | 20 | 2 | 10% | 3 | 15% |
| es | 20 | 3 | 15% | 7 | 35% |
| fr | 20 | 6 | 30% | 7 | 35% |
| **All** | 60 | 11 | 18% | 17 | 28% |

## Identifying leaks and residue

Residue: what stays visible is only short numbers, unit designators, single initials, state codes and unit or legal-form words.

| Language | Entities | Identifying | Residue | Identifying leak rate |
|---|---|---|---|---|
| en | 544 | 47 | 16 | 8.6% |
| es | 497 | 25 | 16 | 5.0% |
| fr | 571 | 28 | 24 | 4.9% |

## Reference numbers (counted separately)

68 invoice, contract, policy and file numbers: 22 hidden, 20 partial, 26 leaked.

## Left visible by default (counted separately)

Amounts and dates other than dates of birth are detected but switched off. *Detected* means the user can switch them on.

| | Entities | Detected | Partly detected | Not detected |
|---|---|---|---|---|
| AMOUNT | 194 | 175 | 8 | 11 |
| DATE | 264 | 262 | 2 | 0 |

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

## Over-redaction: 86 detections that touch no expected entity

- 5× `Mastercard` as COMPANY (list:company)
- 3× `BA1393` as ID (propagated)
- 2× `rose` as PERSON (propagated)
- 2× `SEPA` as PERSON (ner:xlm-roberta-base-ner-docudis)
- 2× `SIRET` as ADDRESS (ner:xlm-roberta-base-ner-docudis)
- 1× `Wales` as ADDRESS (ner:xlm-roberta-base-ner-docudis)
- 1× `Wire Services` as COMPANY (ner:xlm-roberta-base-ner-docudis)
- 1× `Airstream` as COMPANY (list:company)
- 1× `FDIC` as COMPANY (list:company)
- 1× `van` as PERSON (ner:xlm-roberta-base-ner-docudis)
- 1× `van` as PERSON (propagated)
- 1× `van mans` as PERSON (ner:xlm-roberta-base-ner-docudis)
- 1× `ACLS` as COMPANY (ner:xlm-roberta-base-ner-docudis)
- 1× `BLS` as COMPANY (ner:xlm-roberta-base-ner-docudis)
- 1× `CLABSI` as COMPANY (ner:xlm-roberta-base-ner-docudis)
- 1× `Philips IntelliVue` as COMPANY (ner:xlm-roberta-base-ner-docudis)
- 1× `Alaris` as ADDRESS (ner:xlm-roberta-base-ner-docudis)
- 1× `Worcester` as COMPANY (ner:xlm-roberta-base-ner-docudis)
- 1× `Section` as ADDRESS (ner:xlm-roberta-base-ner-docudis)
- 1× `Section` as ADDRESS (propagated)
- 1× `Rules` as COMPANY (list:company)
- 1× `FIRST CLASS POST` as COMPANY (ner:xlm-roberta-base-ner-docudis)
- 1× `Clinic C` as COMPANY (ner:xlm-roberta-base-ner-docudis)
- 1× `00378-1805` as ADDRESS (regex:us:zip_plus4)

## Leaked (102)

- ADDRESS `Leeds` (en-invoice-01, en-letter-02, en-medical-01)
- ID `CMBRFR2BXXX` (fr-invoice-01, fr-payslip-02)
- ADDRESS `Bristol` (en-bank-01)
- ID `NWBKGB2L` (en-bank-01)
- ID `929027` (en-bank-01)
- ID `7702` (en-bank-02)
- ID `CHASUS33` (en-bank-02)
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
- ADDRESS `Ecclesall` (en-insurance-02)
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
- ADDRESS `Columbus, OH 43215` (en-lease-01)
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
- COMPANY `AIB` (en-support-02)
- ID `4471` (en-support-02)
- CARD `4410` (es-bank-01)
- ADDRESS `Vallès Occidental` (es-bank-01)

## Partially visible (54)

- IBAN `GB88 NWBK 4321 7853 7536 63` → `GB88 NWBK █████████████████` (en-bank-01)
- ADDRESS `New York, NY` → `████████, NY` (en-bank-02)
- ADDRESS `Atlanta, GA` → `███████, GA` (en-cv-01)
- COMPANY `Byrdine F. Lewis College of Nursing` → `███████ F. █████████████ of Nursing` (en-cv-01)
- ADDRESS `Unit 9, Kings Weston Trade Park, Avonmouth, Bristol BS11 8AZ` → `Unit 9, Kings Weston Trade Park, █████████, ███████ ████████` (en-cv-02)
- ID `MPC/2291847/03` → `MPC/███████/03` (en-insurance-01)
- COMPANY `Premium Credit` → `Premium ██████` (en-insurance-01)
- ADDRESS `Leeds LS7 2BB` → `Leeds ███████` (en-invoice-01)
- ADDRESS `Unit 4, Sheepscar Court, Meanwood Road, Leeds LS7 2BB` → `██████████████████████████████████████, Leeds ███████` (en-invoice-01)
- ID `GB 483 7152 30` → `GB ███████████` (en-invoice-01)
- COMPANY `AEP Ohio` → `AEP ████` (en-lease-01)
- ADDRESS `Flat 3, 41 Harold's Cross Road, Dublin 6W, D6W XK72` → `██████████████████████████████, Dublin ████████████` (en-lease-02)
- ID `RT-0122-00486317` → `RT-█████████████` (en-lease-02)
- ADDRESS `17 Cnoc na Cathrach, Knocknacarra, Galway, H91 T2RV` → `17 Cnoc na Cathrach, Knocknacarra, Galway, ████████` (en-lease-02)
- ADDRESS `Unit 7 Meadow Lane Ind Est` → `██████████████████ Ind Est` (en-payslip-02)
- ADDRESS `Apartment 12, Millrace Court, Old Kilmainham, Dublin 8, D08 X4K7` → `Apartment 12, Millrace Court, Old Kilmainham, Dublin ███████████` (en-support-02)
- IBAN `ES62 5533 **** **** **** 0127` → `█████████ **** **** **** 0127` (es-bank-02)
- COMPANY `Mercedes-Benz Vitoria` → `█████████████ Vitoria` (es-cv-01)
- COMPANY `GENERALI ESPAÑA, S.A. DE SEGUROS Y REASEGUROS` → `████████████████████████████████ Y REASEGUROS` (es-insurance-01)
- ID `HG-46-00729518` → `HG-███████████` (es-insurance-02)
- COMPANY `Sanchis, Beltrán y Asociados, S.L.P.` → `Sanchis, ███████████████████████████` (es-insurance-02)
- ID `48/IF-02917` → `48/IF-█████` (es-invoice-01)
- ID `ES0031 4065 8821 3007 KX` → `█████████████████████ KX` (es-invoice-02)
- IBAN `ES60 2368 **** **** **** 4146` → `█████████ **** **** **** 4146` (es-invoice-02)
- ADDRESS `Apartado de Correos 4127, 50080 Zaragoza` → `Apartado de ███████ ████, ██████████████` (es-invoice-02)
- COMPANY `Tetuán Gestión Inmobiliaria` → `██████ Gestión Inmobiliaria` (es-lease-01)
- ID `0847612VK4704H0012RT` → `███████VK4704H0012RT` (es-lease-01)
- PERSON `QUISPE MAMANI, Wilson F.` → `█████████████████████ F.` (es-medical-02)
- ID `ES0021000014839276KX` → `██████████████████KX` (es-support-02)
- ADDRESS `Résidence Les Hauts de Mousserolles` → `███████████████████ de Mousserolles` (fr-bank-01)
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
- ADDRESS `Pays basque` → `████ basque` (fr-cv-01)
- COMPANY `IUT de Bordeaux` → `███ de ████████` (fr-cv-01)
- COMPANY `IUT de Bayonne et du Pays basque` → `███ de ███████ et du ████ basque` (fr-cv-01)
- ADDRESS `ZA Ametzondo, 64990 Mouguerre` → `ZA █████████, ███████████████` (fr-cv-01)
- ID `AU 7482913 C` → `██████████ C` (fr-insurance-01)
- ADDRESS `160 rue Henri Champion, 72030 Le Mans Cedex 9` → `███████████████████████████████████████████ 9` (fr-insurance-01)
