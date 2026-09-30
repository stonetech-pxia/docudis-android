# Leak report: xlm-roberta-base-ner-docudis

Dataset: `benchmark/synthetic_cases.json`, 45 documents.

An entity is *hidden* when every alphanumeric character of every occurrence is covered by some detection, of any type. *Wrong type* is hidden under another placeholder type (no leak). *Partial* and *leaked* both expose text.

| | Entities | Hidden | of which wrong type | Partial | Leaked | Leak rate |
|---|---|---|---|---|---|---|
| **All** | 664 | 664 | 0 | 0 | 0 | 0.0% |

## By language

| | Entities | Hidden | of which wrong type | Partial | Leaked | Leak rate |
|---|---|---|---|---|---|---|
| en | 230 | 230 | 0 | 0 | 0 | 0.0% |
| es | 218 | 218 | 0 | 0 | 0 | 0.0% |
| fr | 216 | 216 | 0 | 0 | 0 | 0.0% |

## By document type

| | Entities | Hidden | of which wrong type | Partial | Leaked | Leak rate |
|---|---|---|---|---|---|---|
| cv | 144 | 144 | 0 | 0 | 0 | 0.0% |
| invoice | 114 | 114 | 0 | 0 | 0 | 0.0% |
| lease | 160 | 160 | 0 | 0 | 0 | 0.0% |
| medical | 135 | 135 | 0 | 0 | 0 | 0.0% |
| payslip | 111 | 111 | 0 | 0 | 0 | 0.0% |

## By entity type

| | Entities | Hidden | of which wrong type | Partial | Leaked | Leak rate |
|---|---|---|---|---|---|---|
| ADDRESS | 217 | 217 | 0 | 0 | 0 | 0.0% |
| BIRTH_DATE | 36 | 36 | 0 | 0 | 0 | 0.0% |
| COMPANY | 72 | 72 | 0 | 0 | 0 | 0.0% |
| EMAIL | 54 | 54 | 0 | 0 | 0 | 0.0% |
| IBAN | 33 | 33 | 0 | 0 | 0 | 0.0% |
| ID | 45 | 45 | 0 | 0 | 0 | 0.0% |
| PERSON | 117 | 117 | 0 | 0 | 0 | 0.0% |
| PHONE | 81 | 81 | 0 | 0 | 0 | 0.0% |
| URL | 9 | 9 | 0 | 0 | 0 | 0.0% |

## Documents with no leak at all

| Language | Documents | Fully clean | Share | No identifying leak | Share |
|---|---|---|---|---|---|
| en | 15 | 15 | 100% | 15 | 100% |
| es | 15 | 15 | 100% | 15 | 100% |
| fr | 15 | 15 | 100% | 15 | 100% |
| **All** | 45 | 45 | 100% | 45 | 100% |

## Identifying leaks and residue

Residue: what stays visible is only short numbers, unit designators, single initials, state codes and unit or legal-form words.

| Language | Entities | Identifying | Residue | Identifying leak rate |
|---|---|---|---|---|
| en | 230 | 0 | 0 | 0.0% |
| es | 218 | 0 | 0 | 0.0% |
| fr | 216 | 0 | 0 | 0.0% |

## Reference numbers (counted separately)

51 invoice, contract, policy and file numbers: 9 hidden, 9 partial, 33 leaked.

## Left visible by default (counted separately)

Amounts and dates other than dates of birth are detected but switched off. *Detected* means the user can switch them on.

| | Entities | Detected | Partly detected | Not detected |
|---|---|---|---|---|
| AMOUNT | 117 | 117 | 0 | 0 |
| DATE | 96 | 96 | 0 | 0 |

## NUMBER placeholders: 15

Digit strings matched by a loose rule, hidden under the generic type instead of a guessed one.

- 6× regex:universal:long_number
- 6× regex:fr:siret
- 3× regex:us:passport

## Over-redaction: 3 detections that touch no expected entity

- 1× `Lindqvist` as PERSON (ner:xlm-roberta-base-ner-docudis)
- 1× `Whitaker` as PERSON (ner:xlm-roberta-base-ner-docudis)
- 1× `Adebayo` as PERSON (ner:xlm-roberta-base-ner-docudis)

## Leaked (0)


## Partially visible (0)

