# NER benchmark (device)

- Model: xlm-roberta-base-ner-docudis
- Platform: android BP4A.251205.006.S948BXXS4AZHL, ONNX Runtime CPU via flutter_onnxruntime
- Cases: 48, expected entities: 168
- Overall: recall 94%, precision 99%, F1 96% → reliability **A**; 266 ms per 1000 chars → speed **A**

Grades: reliability by F1 (A ≥ 90%, B ≥ 75%, C ≥ 50%, D below); speed by ms per 1000 characters on this platform (A < 300, B < 1000, C < 3000, D above).

## By language

| Language | Cases | Expected | Found | False pos. | Recall | Precision | F1 | Reliability | ms/1000 chars | Speed |
|---|---|---|---|---|---|---|---|---|---|---|
| zh | 11 | 41 | 40 | 0 | 98% | 100% | 99% | A | 384 | B |
| zh-Hant | 1 | 3 | 3 | 0 | 100% | 100% | 100% | A | 514 | B |
| en | 15 | 66 | 60 | 2 | 91% | 97% | 94% | A | 199 | A |
| fr | 7 | 20 | 18 | 0 | 90% | 100% | 95% | A | 245 | A |
| es | 6 | 15 | 14 | 0 | 93% | 100% | 97% | A | 338 | B |
| hi | 5 | 9 | 9 | 0 | 100% | 100% | 100% | A | 290 | A |
| de | 1 | 3 | 3 | 0 | 100% | 100% | 100% | A | 253 | A |
| ja | 1 | 3 | 3 | 0 | 100% | 100% | 100% | A | 628 | B |
| multi | 1 | 8 | 8 | 0 | 100% | 100% | 100% | A | 595 | B |

## By category

| Category | Cases | Expected | Found | False pos. | Recall | Precision | F1 | Reliability | ms/1000 chars | Speed |
|---|---|---|---|---|---|---|---|---|---|---|
| names | 12 | 27 | 26 | 0 | 96% | 100% | 98% | A | 369 | B |
| organizations | 5 | 10 | 8 | 0 | 80% | 100% | 89% | B | 228 | A |
| locations | 5 | 14 | 14 | 0 | 100% | 100% | 100% | A | 317 | B |
| addresses | 2 | 5 | 3 | 1 | 60% | 75% | 67% | C | 319 | B |
| contacts | 5 | 14 | 14 | 0 | 100% | 100% | 100% | A | 357 | B |
| identifiers | 2 | 5 | 5 | 0 | 100% | 100% | 100% | A | 234 | A |
| mixed | 5 | 31 | 30 | 0 | 97% | 100% | 98% | A | 312 | B |
| negatives | 6 | 0 | 0 | 0 | 100% | 100% | 100% | A | 353 | B |
| dates | 1 | 2 | 2 | 0 | 100% | 100% | 100% | A | 259 | A |
| noisy | 1 | 5 | 4 | 1 | 80% | 80% | 80% | B | 135 | A |
| business | 2 | 8 | 7 | 0 | 88% | 100% | 93% | A | 340 | B |
| long | 2 | 47 | 45 | 0 | 96% | 100% | 98% | A | 170 | A |

## Per case

| Case | Chars | Expected | Hit | Partial | Missed | Wrong type | False pos. | F1 | ms | Notes |
|---|---|---|---|---|---|---|---|---|---|---|
| zh-name-01 | 16 | 3 | 3 | 0 | 0 | 0 | 0 | 100% | 24 |  |
| zh-name-02 | 17 | 1 | 1 | 0 | 0 | 0 | 0 | 100% | 12 |  |
| zh-name-03 | 21 | 2 | 2 | 0 | 0 | 0 | 0 | 100% | 15 |  |
| zh-org-01 | 21 | 2 | 1 | 0 | 0 | 1 | 0 | 50% | 13 | wrong type: 清华大学 |
| zh-loc-01 | 16 | 3 | 3 | 0 | 0 | 0 | 0 | 100% | 12 |  |
| zh-addr-01 | 29 | 1 | 1 | 0 | 0 | 0 | 0 | 100% | 14 |  |
| zh-contact-01 | 55 | 3 | 3 | 0 | 0 | 0 | 0 | 100% | 14 |  |
| zh-id-01 | 48 | 2 | 2 | 0 | 0 | 0 | 0 | 100% | 12 |  |
| zh-mixed-01 | 76 | 5 | 4 | 1 | 0 | 0 | 0 | 100% | 24 |  |
| zh-negative-01 | 22 | 0 | 0 | 0 | 0 | 0 | 0 | 100% | 10 |  |
| zh-trad-01 | 24 | 3 | 2 | 1 | 0 | 0 | 0 | 100% | 12 |  |
| en-name-01 | 60 | 2 | 2 | 0 | 0 | 0 | 0 | 100% | 16 |  |
| en-name-02 | 49 | 2 | 2 | 0 | 0 | 0 | 0 | 100% | 11 |  |
| en-name-03 | 60 | 2 | 0 | 1 | 1 | 0 | 0 | 67% | 15 | missed: ben lee |
| en-org-01 | 61 | 2 | 2 | 0 | 0 | 0 | 0 | 100% | 11 |  |
| en-loc-01 | 53 | 3 | 3 | 0 | 0 | 0 | 0 | 100% | 11 |  |
| en-addr-01 | 59 | 4 | 0 | 2 | 2 | 0 | 1 | 57% | 13 | missed: London, United Kingdom; extra: United(COMPANY) |
| en-contact-01 | 84 | 3 | 3 | 0 | 0 | 0 | 0 | 100% | 60 |  |
| en-id-01 | 63 | 3 | 3 | 0 | 0 | 0 | 0 | 100% | 12 |  |
| en-date-01 | 67 | 2 | 2 | 0 | 0 | 0 | 0 | 100% | 17 |  |
| en-mixed-01 | 205 | 6 | 6 | 0 | 0 | 0 | 0 | 100% | 20 |  |
| en-negative-01 | 70 | 0 | 0 | 0 | 0 | 0 | 0 | 100% | 11 |  |
| en-negative-02 | 85 | 0 | 0 | 0 | 0 | 0 | 0 | 100% | 60 |  |
| en-ocr-01 | 109 | 5 | 2 | 2 | 1 | 0 | 1 | 80% | 14 | missed: Johnson; extra: Rob ert   Johnson(PERSON) |
| fr-name-01 | 63 | 2 | 2 | 0 | 0 | 0 | 0 | 100% | 20 |  |
| fr-org-01 | 64 | 2 | 1 | 0 | 1 | 0 | 0 | 67% | 13 | missed: Université de Lyon |
| fr-loc-01 | 57 | 2 | 2 | 0 | 0 | 0 | 0 | 100% | 11 |  |
| fr-contact-01 | 89 | 3 | 3 | 0 | 0 | 0 | 0 | 100% | 16 |  |
| fr-mixed-01 | 151 | 7 | 6 | 1 | 0 | 0 | 0 | 100% | 20 |  |
| fr-negative-01 | 69 | 0 | 0 | 0 | 0 | 0 | 0 | 100% | 9 |  |
| fr-business-01 | 245 | 4 | 3 | 0 | 1 | 0 | 0 | 86% | 89 | missed: 845210 |
| es-name-01 | 66 | 2 | 2 | 0 | 0 | 0 | 0 | 100% | 16 |  |
| es-org-01 | 62 | 2 | 2 | 0 | 0 | 0 | 0 | 100% | 10 |  |
| es-loc-01 | 60 | 3 | 3 | 0 | 0 | 0 | 0 | 100% | 15 |  |
| es-contact-01 | 62 | 3 | 3 | 0 | 0 | 0 | 0 | 100% | 17 |  |
| es-mixed-01 | 124 | 5 | 3 | 1 | 1 | 0 | 0 | 89% | 67 | missed: Sevilla |
| es-negative-01 | 63 | 0 | 0 | 0 | 0 | 0 | 0 | 100% | 19 |  |
| hi-name-01 | 45 | 2 | 2 | 0 | 0 | 0 | 0 | 100% | 9 |  |
| hi-org-01 | 49 | 2 | 2 | 0 | 0 | 0 | 0 | 100% | 9 |  |
| hi-loc-01 | 45 | 3 | 3 | 0 | 0 | 0 | 0 | 100% | 22 |  |
| hi-contact-01 | 50 | 2 | 2 | 0 | 0 | 0 | 0 | 100% | 13 |  |
| hi-negative-01 | 41 | 0 | 0 | 0 | 0 | 0 | 0 | 100% | 12 |  |
| de-name-01 | 54 | 3 | 3 | 0 | 0 | 0 | 0 | 100% | 13 |  |
| ja-name-01 | 26 | 3 | 3 | 0 | 0 | 0 | 0 | 100% | 16 |  |
| multi-mixed-01 | 147 | 8 | 8 | 0 | 0 | 0 | 0 | 100% | 87 |  |
| en-long-01 | 1321 | 28 | 25 | 1 | 1 | 1 | 0 | 95% | 161 | missed: Auckland; wrong type: Russell McVeagh |
| en-business-01 | 241 | 4 | 4 | 0 | 0 | 0 | 0 | 100% | 75 |  |
| zh-long-01 | 444 | 19 | 16 | 3 | 0 | 0 | 0 | 100% | 138 |  |
