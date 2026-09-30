# Leak report: xlm-roberta-base-ner-docudis

Dataset: `benchmark/consumer_cases.json`, 60 documents.

An entity is *hidden* when every alphanumeric character of every occurrence is covered by some detection, of any type. *Wrong type* is hidden under another placeholder type (no leak). *Partial* and *leaked* both expose text.

| | Entities | Hidden | of which wrong type | Partial | Leaked | Leak rate |
|---|---|---|---|---|---|---|
| **All** | 1612 | 1513 | 20 | 45 | 54 | 6.1% |

## By language

| | Entities | Hidden | of which wrong type | Partial | Leaked | Leak rate |
|---|---|---|---|---|---|---|
| en | 544 | 503 | 4 | 14 | 27 | 7.5% |
| es | 497 | 478 | 2 | 8 | 11 | 3.8% |
| fr | 571 | 532 | 14 | 23 | 16 | 6.8% |

## By document type

| | Entities | Hidden | of which wrong type | Partial | Leaked | Leak rate |
|---|---|---|---|---|---|---|
| bank | 134 | 124 | 1 | 3 | 7 | 7.5% |
| chat | 69 | 54 | 0 | 10 | 5 | 21.7% |
| cv | 240 | 228 | 9 | 8 | 4 | 5.0% |
| insurance | 217 | 201 | 0 | 7 | 9 | 7.4% |
| invoice | 186 | 173 | 1 | 9 | 4 | 7.0% |
| lease | 173 | 163 | 2 | 5 | 5 | 5.8% |
| letter | 141 | 138 | 2 | 0 | 3 | 2.1% |
| medical | 191 | 187 | 3 | 1 | 3 | 2.1% |
| payslip | 142 | 133 | 1 | 1 | 8 | 6.3% |
| support | 119 | 112 | 1 | 1 | 6 | 5.9% |

## By entity type

| | Entities | Hidden | of which wrong type | Partial | Leaked | Leak rate |
|---|---|---|---|---|---|---|
| ADDRESS | 393 | 361 | 10 | 16 | 16 | 8.1% |
| BIRTH_DATE | 24 | 23 | 0 | 0 | 1 | 4.2% |
| CARD | 6 | 0 | 0 | 0 | 6 | 100.0% |
| COMPANY | 229 | 204 | 5 | 12 | 13 | 10.9% |
| EMAIL | 104 | 104 | 0 | 0 | 0 | 0.0% |
| IBAN | 31 | 30 | 0 | 1 | 0 | 3.2% |
| ID | 206 | 184 | 0 | 8 | 14 | 10.7% |
| PERSON | 436 | 427 | 5 | 7 | 2 | 2.1% |
| PHONE | 169 | 167 | 0 | 1 | 1 | 1.2% |
| URL | 14 | 13 | 0 | 0 | 1 | 7.1% |

## Documents with no leak at all

| Language | Documents | Fully clean | Share | No identifying leak | Share |
|---|---|---|---|---|---|
| en | 20 | 3 | 15% | 5 | 25% |
| es | 20 | 6 | 30% | 10 | 50% |
| fr | 20 | 7 | 35% | 9 | 45% |
| **All** | 60 | 16 | 27% | 24 | 40% |

## Identifying leaks and residue

Residue: what stays visible is only short numbers, unit designators, single initials, state codes and unit or legal-form words.

| Language | Entities | Identifying | Residue | Identifying leak rate |
|---|---|---|---|---|
| en | 544 | 28 | 13 | 5.1% |
| es | 497 | 10 | 9 | 2.0% |
| fr | 571 | 18 | 21 | 3.2% |

## Reference numbers (counted separately)

68 invoice, contract, policy and file numbers: 50 hidden, 9 partial, 9 leaked.

## Left visible by default (counted separately)

Amounts and dates other than dates of birth are detected but switched off. *Detected* means the user can switch them on.

| | Entities | Detected | Partly detected | Not detected |
|---|---|---|---|---|
| AMOUNT | 194 | 175 | 8 | 11 |
| DATE | 264 | 262 | 2 | 0 |

## NUMBER placeholders: 150

Digit strings matched by a loose rule, hidden under the generic type instead of a guessed one.

- 41× regex:universal:long_number
- 36× regex:universal:labeled_id_no
- 21× regex:universal:labeled_id
- 11× regex:es:nuss
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

## Leaked (54)

- ADDRESS `Leeds` (en-invoice-01, en-letter-02, en-medical-01)
- ADDRESS `Bristol` (en-bank-01)
- ID `7702` (en-bank-02)
- COMPANY `halvorsen` (en-chat-02)
- PERSON `reggie` (en-chat-02)
- COMPANY `AACN` (en-cv-01)
- ADDRESS `Co. Galway` (en-insurance-01)
- BIRTH_DATE `02/11/1985` (en-insurance-01)
- CARD `3308` (en-insurance-01)
- ID `6120` (en-insurance-01)
- ADDRESS `Ecclesall` (en-insurance-02)
- ID `4402` (en-insurance-02)
- ADDRESS `Dallas` (en-invoice-02)
- CARD `1554` (en-invoice-02)
- COMPANY `Oncor` (en-invoice-02)
- URL `pay.hallgrenpm.com` (en-lease-01)
- ADDRESS `Columbus, OH 43215` (en-lease-01)
- PHONE `80-2214` (en-medical-01)
- COMPANY `Alliant Credit Union` (en-payslip-01)
- COMPANY `HARCASTLE JOINERY` (en-payslip-02)
- ADDRESS `Loughborough` (en-payslip-02)
- ID `20-49` (en-payslip-02)
- CARD `9901` (en-support-01)
- COMPANY `AIB` (en-support-02)
- ID `4471` (en-support-02)
- CARD `4410` (es-bank-01)
- ADDRESS `Vallès Occidental` (es-bank-01)
- COMPANY `grupo alcor` (es-chat-02)
- COMPANY `Aula de Cata Ribera Alta` (es-cv-02)
- ID `MU-80.417` (es-insurance-01)
- ID `31.877` (es-lease-01)
- ID `3.412` (es-letter-01)
- COMPANY `LABORATORIO IBARZ` (es-medical-02)
- ID `PO-31.906` (es-payslip-01)
- COMPANY `EMBUTIDOS Y SALAZONES` (es-payslip-02)
- CARD `8036` (es-support-01)
- ID `30857` (fr-bank-01)
- ID `70037` (fr-bank-01)
- ID `77` (fr-bank-01)
- PERSON `jo` (fr-chat-01)
- ADDRESS `3e etage` (fr-chat-01)
- ADDRESS `Nord vaudois` (fr-cv-02)
- ADDRESS `Suisse` (fr-cv-02)
- COMPANY `MMA` (fr-insurance-01)
- ADDRESS `appt 42` (fr-insurance-02)
- ID `204` (fr-lease-01)
- ADDRESS `Bâtiment : B     Étage : 2e     Porte : 204` (fr-lease-01)
- ID `0417-B32` (fr-letter-01)

## Partially visible (45)

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
- ADDRESS `17 Cnoc na Cathrach, Knocknacarra, Galway, H91 T2RV` → `17 Cnoc na Cathrach, Knocknacarra, Galway, ████████` (en-lease-02)
- ADDRESS `Unit 7 Meadow Lane Ind Est` → `██████████████████ Ind Est` (en-payslip-02)
- ADDRESS `Apartment 12, Millrace Court, Old Kilmainham, Dublin 8, D08 X4K7` → `Apartment 12, Millrace Court, Old Kilmainham, Dublin ███████████` (en-support-02)
- COMPANY `Mercedes-Benz Vitoria` → `█████████████ Vitoria` (es-cv-01)
- COMPANY `GENERALI ESPAÑA, S.A. DE SEGUROS Y REASEGUROS` → `████████████████████████████████ Y REASEGUROS` (es-insurance-01)
- COMPANY `Sanchis, Beltrán y Asociados, S.L.P.` → `Sanchis, ███████████████████████████` (es-insurance-02)
- ID `48/IF-02917` → `48/IF-█████` (es-invoice-01)
- ID `ES0031 4065 8821 3007 KX` → `██████ ██████████████ KX` (es-invoice-02)
- ADDRESS `Apartado de Correos 4127, 50080 Zaragoza` → `Apartado de ███████ ████, ██████████████` (es-invoice-02)
- COMPANY `Tetuán Gestión Inmobiliaria` → `██████ Gestión Inmobiliaria` (es-lease-01)
- PERSON `QUISPE MAMANI, Wilson F.` → `█████████████████████ F.` (es-medical-02)
- ADDRESS `Résidence Les Hauts de Mousserolles` → `███████████████████ de Mousserolles` (fr-bank-01)
- COMPANY `Caisse Régionale de Crédit Agricole Mutuel Pyrénées Gascogne` → `Caisse Régionale de ████████████████████████████████████████` (fr-bank-01)
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
- ID `HAB 4 417 902 66` → `HAB ████████████` (fr-insurance-02)
- ID `129 445 872 K` → `███████████ K` (fr-invoice-01)
- ADDRESS `Libre réponse n° 59252, 75443 Paris Cedex 09` → `Libre réponse n° █████, ████████████████████` (fr-invoice-02)
- ID `FR 79 619326754` → `FR ████████████` (fr-invoice-02)
- COMPANY `CHU de Montpellier` → `CHU de ███████████` (fr-lease-01)
