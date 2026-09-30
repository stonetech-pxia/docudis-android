# Leak report: xlm-roberta-base-ner-hrl

Dataset: `benchmark/consumer_cases.json`, 60 documents.

An entity is *hidden* when every alphanumeric character of every occurrence is covered by some detection, of any type. *Wrong type* is hidden under another placeholder type (no leak). *Partial* and *leaked* both expose text.

| | Entities | Hidden | of which wrong type | Partial | Leaked | Leak rate |
|---|---|---|---|---|---|---|
| **All** | 1612 | 1309 | 38 | 163 | 140 | 18.8% |

## By language

| | Entities | Hidden | of which wrong type | Partial | Leaked | Leak rate |
|---|---|---|---|---|---|---|
| en | 544 | 433 | 18 | 61 | 50 | 20.4% |
| es | 497 | 409 | 9 | 51 | 37 | 17.7% |
| fr | 571 | 467 | 11 | 51 | 53 | 18.2% |

## By document type

| | Entities | Hidden | of which wrong type | Partial | Leaked | Leak rate |
|---|---|---|---|---|---|---|
| bank | 134 | 107 | 4 | 11 | 16 | 20.1% |
| chat | 69 | 37 | 1 | 10 | 22 | 46.4% |
| cv | 240 | 210 | 9 | 22 | 8 | 12.5% |
| insurance | 217 | 167 | 5 | 24 | 26 | 23.0% |
| invoice | 186 | 143 | 4 | 29 | 14 | 23.1% |
| lease | 173 | 145 | 2 | 16 | 12 | 16.2% |
| letter | 141 | 130 | 4 | 5 | 6 | 7.8% |
| medical | 191 | 161 | 2 | 22 | 8 | 15.7% |
| payslip | 142 | 106 | 4 | 16 | 20 | 25.4% |
| support | 119 | 103 | 3 | 8 | 8 | 13.4% |

## By entity type

| | Entities | Hidden | of which wrong type | Partial | Leaked | Leak rate |
|---|---|---|---|---|---|---|
| ADDRESS | 393 | 276 | 12 | 89 | 28 | 29.8% |
| BIRTH_DATE | 24 | 23 | 0 | 0 | 1 | 4.2% |
| CARD | 6 | 0 | 0 | 0 | 6 | 100.0% |
| COMPANY | 229 | 184 | 11 | 25 | 20 | 19.7% |
| EMAIL | 104 | 104 | 0 | 0 | 0 | 0.0% |
| IBAN | 31 | 24 | 0 | 6 | 1 | 22.6% |
| ID | 206 | 133 | 0 | 12 | 61 | 35.4% |
| PERSON | 436 | 385 | 15 | 30 | 21 | 11.7% |
| PHONE | 169 | 167 | 0 | 1 | 1 | 1.2% |
| URL | 14 | 13 | 0 | 0 | 1 | 7.1% |

## Documents with no leak at all

| Language | Documents | Fully clean | Share | No identifying leak | Share |
|---|---|---|---|---|---|
| en | 20 | 2 | 10% | 4 | 20% |
| es | 20 | 1 | 5% | 5 | 25% |
| fr | 20 | 0 | 0% | 2 | 10% |
| **All** | 60 | 3 | 5% | 11 | 18% |

## Identifying leaks and residue

Residue: what stays visible is only short numbers, unit designators, single initials, state codes and unit or legal-form words.

| Language | Entities | Identifying | Residue | Identifying leak rate |
|---|---|---|---|---|
| en | 544 | 52 | 59 | 9.6% |
| es | 497 | 51 | 37 | 10.3% |
| fr | 571 | 68 | 36 | 11.9% |

## Reference numbers (counted separately)

68 invoice, contract, policy and file numbers: 20 hidden, 21 partial, 27 leaked.

## Left visible by default (counted separately)

Amounts and dates other than dates of birth are detected but switched off. *Detected* means the user can switch them on.

| | Entities | Detected | Partly detected | Not detected |
|---|---|---|---|---|
| AMOUNT | 194 | 175 | 8 | 11 |
| DATE | 264 | 198 | 1 | 65 |

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

## Over-redaction: 138 detections that touch no expected entity

- 8× `Landlord` as COMPANY (propagated)
- 4× `England` as ADDRESS (ner:xlm-roberta-base-ner-hrl)
- 4× `Mastercard` as COMPANY (list:company)
- 3× `BA1393` as ID (propagated)
- 2× `Wales` as ADDRESS (ner:xlm-roberta-base-ner-hrl)
- 2× `Prudential Regulation Authority` as COMPANY (ner:xlm-roberta-base-ner-hrl)
- 2× `rose` as PERSON (propagated)
- 2× `Mastercard` as COMPANY (ner:xlm-roberta-base-ner-hrl)
- 2× `SIRET` as ADDRESS (ner:xlm-roberta-base-ner-hrl)
- 2× `basque` as COMPANY (propagated)
- 2× `URSSAF` as ADDRESS (ner:xlm-roberta-base-ner-hrl)
- 1× `Wire Services` as COMPANY (ner:xlm-roberta-base-ner-hrl)
- 1× `Airstream` as COMPANY (list:company)
- 1× `FDIC` as COMPANY (ner:xlm-roberta-base-ner-hrl)
- 1× `ACLS` as COMPANY (ner:xlm-roberta-base-ner-hrl)
- 1× `BLS` as COMPANY (ner:xlm-roberta-base-ner-hrl)
- 1× `CLABSI` as COMPANY (ner:xlm-roberta-base-ner-hrl)
- 1× `Rover` as COMPANY (ner:xlm-roberta-base-ner-hrl)
- 1× `BCMA` as COMPANY (ner:xlm-roberta-base-ner-hrl)
- 1× `Philips` as COMPANY (ner:xlm-roberta-base-ner-hrl)
- 1× `MHA` as COMPANY (ner:xlm-roberta-base-ner-hrl)
- 1× `distribution` as ADDRESS (propagated)
- 1× `Distribution` as ADDRESS (ner:xlm-roberta-base-ner-hrl)
- 1× `Distinction` as COMPANY (ner:xlm-roberta-base-ner-hrl)

## Leaked (140)

- ID `CMBRFR2BXXX` (fr-invoice-01, fr-payslip-02)
- ADDRESS `Bristol` (en-bank-01)
- ADDRESS `Flat 2` (en-bank-01)
- ID `NWBKGB2L` (en-bank-01)
- ID `929027` (en-bank-01)
- ID `7702` (en-bank-02)
- ID `CHASUS33` (en-bank-02)
- PERSON `will` (en-chat-01)
- PERSON `tom` (en-chat-01)
- ADDRESS `luton` (en-chat-01)
- PERSON `delroy` (en-chat-01)
- PERSON `dana` (en-chat-02)
- COMPANY `halvorsen` (en-chat-02)
- PERSON `reggie` (en-chat-02)
- PERSON `faith` (en-chat-02)
- ID `RN298417` (en-cv-01)
- COMPANY `AACN` (en-cv-01)
- BIRTH_DATE `02/11/1985` (en-insurance-01)
- ID `211-G-4827` (en-insurance-01)
- ID `408213` (en-insurance-01)
- COMPANY `Premium Credit` (en-insurance-01)
- CARD `3308` (en-insurance-01)
- ID `6120` (en-insurance-01)
- ID `C48213` (en-insurance-01)
- ID `318842` (en-insurance-01)
- ADDRESS `PO Box 3661` (en-insurance-02)
- ID `4402` (en-insurance-02)
- PERSON `Hannah Pickersgill` (en-insurance-02)
- ID `SC002116` (en-insurance-02)
- ID `612884` (en-invoice-01)
- ID `047731` (en-invoice-01)
- ID `10287` (en-invoice-02)
- ADDRESS `Dallas` (en-invoice-02)
- ID `148302771LG` (en-invoice-02)
- CARD `1554` (en-invoice-02)
- ADDRESS `Plano` (en-invoice-02)
- ADDRESS `P.O. BOX 660418` (en-invoice-02)
- ID `UT482913` (en-lease-01)
- ID `RK170652` (en-lease-01)
- URL `pay.hallgrenpm.com` (en-lease-01)
- PHONE `80-2214` (en-medical-01)
- COMPANY `Mylan` (en-medical-02)
- ID `14D2087315` (en-medical-02)
- ID `xxxxxx9026` (en-payslip-01)
- COMPANY `HARCASTLE JOINERY` (en-payslip-02)
- ID `567/HA41207` (en-payslip-02)
- ID `004417` (en-payslip-02)
- ID `20-49` (en-payslip-02)

## Partially visible (163)

- ADDRESS `PO Box 4418, Bristol BS1 9XQ` → `PO Box █████████████ ███████` (en-bank-01)
- PERSON `T H AL-MASRI` → `T H ████████` (en-bank-01)
- IBAN `GB88 NWBK 4321 7853 7536 63` → `GB88 NWBK █████████████████` (en-bank-01)
- ADDRESS `3905 NW 7th St Apt 12B, Miami, FL 33126` → `██████████████ ██████████████, FL 33126` (en-bank-02)
- ADDRESS `New York, NY` → `████████, NY` (en-bank-02)
- PERSON `S Chaudhry` → `S ████████` (en-chat-01)
- ADDRESS `2716 Glenwood Ave SE, Apt 3B` → `█████████████████ SE, Apt 3B` (en-cv-01)
- ADDRESS `Atlanta, GA 30317` → `███████, GA 30317` (en-cv-01)
- ADDRESS `Atlanta, GA` → `███████, GA` (en-cv-01)
- ADDRESS `Decatur, GA` → `███████, GA` (en-cv-01)
- ADDRESS `Marietta, GA` → `████████, GA` (en-cv-01)
- COMPANY `Sigma Theta Tau` → `Sigma █████████` (en-cv-01)
- ADDRESS `Clarkston, GA` → `█████████, GA` (en-cv-01)
- ADDRESS `1180 Peachtree Dunwoody Rd NE, Suite 640, Atlanta, GA 30342` → `█████████████████████████████████████████████████, GA 30342` (en-cv-01)
- COMPANY `City of Bristol College` → `City of ███████████████` (en-cv-02)
- ADDRESS `Ashley Down` → `██████ Down` (en-cv-02)
- ID `MPC/2291847/03` → `MPC/███████/03` (en-insurance-01)
- ADDRESS `Co. Galway` → `Co. ██████` (en-insurance-01)
- PERSON `A Siddiqui` → `A ████████` (en-insurance-02)
- ADDRESS `3rd Floor, Cutlers Court, 12 Leopold Street, Sheffield S1 2GY` → `3rd █████, █████████████, █████████████████, █████████ ██████` (en-insurance-02)
- PERSON `D. Okonkwo` → `D█████████` (en-invoice-01)
- ID `GB 483 7152 30` → `GB ███████████` (en-invoice-01)
- ADDRESS `P.O. Box 660418, Dallas, TX 75266-0418` → `P.O. Box 660418, █████████████████████` (en-invoice-02)
- PERSON `CHIDINMA A OKONKWO` → `████████ A ███████` (en-invoice-02)
- ADDRESS `1180 W CAMPBELL RD STE 210` → `██████████████████ STE 210` (en-invoice-02)
- ADDRESS `2217 LARKSPUR TRL APT 1406, PLANO TX 75074` → `█████████████████ ███████████████ TX 75074` (en-invoice-02)
- ADDRESS `2217 Larkspur Trl Apt 1406` → `█████████████████ Apt 1406` (en-invoice-02)
- ADDRESS `P.O. Box 13326, Austin, TX 78711-3326` → `P.O. Box 13326, █████████████████████` (en-invoice-02)
- ADDRESS `2217 LARKSPUR TRL APT 1406 PLANO TX 75074` → `█████████████████ APT 1406 PLANO TX 75074` (en-invoice-02)
- ADDRESS `3400 Ross Avenue, Suite 1850, Dallas, TX 75204` → `████████████████, ██████████████████, TX 75204` (en-invoice-02)
- ADDRESS `1184 Neil Avenue, Apt. 2C, Columbus, OH 43201` → `████████████████, ██████████████████ OH 43201` (en-lease-01)
- ADDRESS `250 E. Broad Street, Suite 1420` → `███████████████████, Suite 1420` (en-lease-01)
- ADDRESS `Columbus, OH 43215` → `█████████ OH 43215` (en-lease-01)
- ADDRESS `318 W. Las Tunas Drive, San Gabriel, CA 91776` → `██████████████████████, ███████████, CA 91776` (en-lease-01)
- ID `RT-0122-00486317` → `RT-█████████████` (en-lease-02)
- ADDRESS `17 Cnoc na Cathrach, Knocknacarra, Galway, H91 T2RV` → `17 Cnoc na ████████, ████████████, ██████, ████████` (en-lease-02)
- ADDRESS `Level 2, Gledhow Wing` → `Level ███████████████` (en-medical-01)
- PERSON `J. Pickersgill` → `J█████████████` (en-medical-01)
- COMPANY `Roundhay Road Medical Practice` → `█████████████ Medical Practice` (en-medical-01)
- PERSON `Adeyemi-Clarke` → `████████Clarke` (en-medical-01)
- COMPANY `Chapeltown Health Centre` → `█████████████████ Centre` (en-medical-01)
- PERSON `M. Thompson` → `M██████████` (en-medical-01)
- PERSON `Adeyemi-Clarke, Folasade` → `████████Clarke, ████████` (en-medical-01)
- ADDRESS `Chicago, IL 60614` → `███████, IL 60614` (en-medical-02)
- PERSON `RAMIREZ, LUZ M` → `███████, ███ M` (en-medical-02)
- ADDRESS `3317 N Kedzie Ave Apt 2R` → `█████████████████ Apt 2R` (en-medical-02)
- ADDRESS `Chicago IL 60618` → `███████ IL 60618` (en-medical-02)
- ADDRESS `2650 N Lincoln Ave Ste 210, Chicago, IL 60614` → `███████████████████████████████████, IL 60614` (en-medical-02)
