# Leak report: xlm-roberta-base-ner-hrl

Dataset: `benchmark/synthetic_cases.json`, 45 documents.

An entity is *hidden* when every alphanumeric character of every occurrence is covered by some detection, of any type. *Wrong type* is hidden under another placeholder type (no leak). *Partial* and *leaked* both expose text.

| | Entities | Hidden | of which wrong type | Partial | Leaked | Leak rate |
|---|---|---|---|---|---|---|
| **All** | 664 | 658 | 3 | 1 | 5 | 0.9% |

## By language

| | Entities | Hidden | of which wrong type | Partial | Leaked | Leak rate |
|---|---|---|---|---|---|---|
| en | 230 | 229 | 2 | 0 | 1 | 0.4% |
| es | 218 | 215 | 0 | 1 | 2 | 1.4% |
| fr | 216 | 214 | 1 | 0 | 2 | 0.9% |

## By document type

| | Entities | Hidden | of which wrong type | Partial | Leaked | Leak rate |
|---|---|---|---|---|---|---|
| cv | 144 | 143 | 0 | 0 | 1 | 0.7% |
| invoice | 114 | 112 | 0 | 0 | 2 | 1.8% |
| lease | 160 | 158 | 0 | 0 | 2 | 1.2% |
| medical | 135 | 134 | 2 | 1 | 0 | 0.7% |
| payslip | 111 | 111 | 1 | 0 | 0 | 0.0% |

## By entity type

| | Entities | Hidden | of which wrong type | Partial | Leaked | Leak rate |
|---|---|---|---|---|---|---|
| ADDRESS | 217 | 215 | 0 | 0 | 2 | 0.9% |
| BIRTH_DATE | 36 | 36 | 0 | 0 | 0 | 0.0% |
| COMPANY | 72 | 71 | 0 | 0 | 1 | 1.4% |
| EMAIL | 54 | 54 | 0 | 0 | 0 | 0.0% |
| IBAN | 33 | 33 | 0 | 0 | 0 | 0.0% |
| ID | 45 | 45 | 0 | 0 | 0 | 0.0% |
| PERSON | 117 | 114 | 3 | 1 | 2 | 2.6% |
| PHONE | 81 | 81 | 0 | 0 | 0 | 0.0% |
| URL | 9 | 9 | 0 | 0 | 0 | 0.0% |

## Documents with no leak at all

| Language | Documents | Fully clean | Share | No identifying leak | Share |
|---|---|---|---|---|---|
| en | 15 | 14 | 93% | 14 | 93% |
| es | 15 | 12 | 80% | 12 | 80% |
| fr | 15 | 13 | 87% | 13 | 87% |
| **All** | 45 | 39 | 87% | 39 | 87% |

## Identifying leaks and residue

Residue: what stays visible is only short numbers, unit designators, single initials, state codes and unit or legal-form words.

| Language | Entities | Identifying | Residue | Identifying leak rate |
|---|---|---|---|---|
| en | 230 | 1 | 0 | 0.4% |
| es | 218 | 3 | 0 | 1.4% |
| fr | 216 | 2 | 0 | 0.9% |

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

- 1× `Lindqvist` as PERSON (ner:xlm-roberta-base-ner-hrl)
- 1× `Whitaker` as PERSON (ner:xlm-roberta-base-ner-hrl)
- 1× `Adebayo` as PERSON (ner:xlm-roberta-base-ner-hrl)

## Leaked (5)

- ADDRESS `Paris` (fr-syn-lease-01, fr-syn-lease-02)
- COMPANY `Brightwater Dental Practice` (en-syn-cv-01)
- PERSON `Rocío Montenegro Díaz` (es-syn-invoice-01)
- PERSON `Andrés Quintana Marín` (es-syn-invoice-03)

## Partially visible (1)

- PERSON `Carmen Iglesias Soto` → `██████ ████████ Soto` (es-syn-medical-02)
