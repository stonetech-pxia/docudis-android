# NER benchmark (device) — candidate: XLM-R

Device: Samsung Galaxy S26 Ultra (SM-S948B, Snapdragon SM8850), Android 16, debug build, onnxruntime-android 1.30.0. Compare with docs/ner-benchmark-device.md (distilbert).

- Model: xlm-roberta-base-ner-hrl
- Platform: android BP4A.251205.006.S948BXXS4AZHL, ONNX Runtime CPU via flutter_onnxruntime
- Cases: 46, expected entities: 157
- Overall: recall 92%, precision 94%, F1 93% → reliability **A**; 180 ms per 1000 chars → speed **A**

Grades: reliability by F1 (A ≥ 90%, B ≥ 75%, C ≥ 50%, D below); speed by ms per 1000 characters on this platform (A < 300, B < 1000, C < 3000, D above).

## By language

| Language | Cases | Expected | Found | False pos. | Recall | Precision | F1 | Reliability | ms/1000 chars | Speed |
|---|---|---|---|---|---|---|---|---|---|---|
| zh | 11 | 40 | 38 | 4 | 95% | 92% | 94% | A | 342 | B |
| zh-Hant | 1 | 3 | 3 | 0 | 100% | 100% | 100% | A | 371 | B |
| en | 14 | 60 | 54 | 6 | 90% | 91% | 91% | A | 138 | A |
| fr | 6 | 16 | 14 | 0 | 88% | 100% | 93% | A | 152 | A |
| es | 6 | 15 | 13 | 1 | 87% | 93% | 90% | B | 136 | A |
| hi | 5 | 9 | 9 | 0 | 100% | 100% | 100% | A | 184 | A |
| de | 1 | 3 | 3 | 0 | 100% | 100% | 100% | A | 198 | A |
| ja | 1 | 3 | 3 | 0 | 100% | 100% | 100% | A | 363 | B |
| multi | 1 | 8 | 8 | 0 | 100% | 100% | 100% | A | 148 | A |

## By category

| Category | Cases | Expected | Found | False pos. | Recall | Precision | F1 | Reliability | ms/1000 chars | Speed |
|---|---|---|---|---|---|---|---|---|---|---|
| names | 12 | 27 | 27 | 1 | 100% | 97% | 98% | A | 377 | B |
| organizations | 5 | 10 | 10 | 0 | 100% | 100% | 100% | A | 170 | A |
| locations | 5 | 14 | 14 | 0 | 100% | 100% | 100% | A | 212 | A |
| addresses | 2 | 4 | 4 | 1 | 100% | 80% | 89% | B | 499 | B |
| contacts | 5 | 14 | 14 | 0 | 100% | 100% | 100% | A | 194 | A |
| identifiers | 2 | 5 | 5 | 1 | 100% | 83% | 91% | A | 196 | A |
| mixed | 5 | 31 | 25 | 2 | 81% | 93% | 87% | B | 146 | A |
| negatives | 6 | 0 | 0 | 0 | 100% | 100% | 100% | A | 172 | A |
| dates | 1 | 2 | 2 | 0 | 100% | 100% | 100% | A | 148 | A |
| noisy | 1 | 4 | 2 | 3 | 50% | 40% | 44% | D | 148 | A |
| long | 2 | 46 | 42 | 3 | 91% | 95% | 93% | A | 119 | A |

## Per case

| Case | Chars | Expected | Hit | Partial | Missed | Wrong type | False pos. | F1 | ms | Notes |
|---|---|---|---|---|---|---|---|---|---|---|
| zh-name-01 | 16 | 3 | 3 | 0 | 0 | 0 | 0 | 100% | 57 |  |
| zh-name-02 | 17 | 1 | 1 | 0 | 0 | 0 | 0 | 100% | 11 |  |
| zh-name-03 | 21 | 2 | 2 | 0 | 0 | 0 | 1 | 80% | 9 | extra: 销售部(COMPANY) |
| zh-org-01 | 21 | 2 | 2 | 0 | 0 | 0 | 0 | 100% | 8 |  |
| zh-loc-01 | 16 | 3 | 3 | 0 | 0 | 0 | 0 | 100% | 7 |  |
| zh-addr-01 | 29 | 1 | 1 | 0 | 0 | 0 | 0 | 100% | 16 |  |
| zh-contact-01 | 55 | 3 | 3 | 0 | 0 | 0 | 0 | 100% | 12 |  |
| zh-id-01 | 48 | 2 | 2 | 0 | 0 | 0 | 0 | 100% | 10 |  |
| zh-mixed-01 | 76 | 5 | 4 | 1 | 0 | 0 | 0 | 100% | 25 |  |
| zh-negative-01 | 22 | 0 | 0 | 0 | 0 | 0 | 0 | 100% | 7 |  |
| zh-trad-01 | 24 | 3 | 2 | 1 | 0 | 0 | 0 | 100% | 8 |  |
| en-name-01 | 60 | 2 | 2 | 0 | 0 | 0 | 0 | 100% | 12 |  |
| en-name-02 | 49 | 2 | 2 | 0 | 0 | 0 | 0 | 100% | 15 |  |
| en-name-03 | 60 | 2 | 2 | 0 | 0 | 0 | 0 | 100% | 21 |  |
| en-org-01 | 61 | 2 | 2 | 0 | 0 | 0 | 0 | 100% | 10 |  |
| en-loc-01 | 53 | 3 | 3 | 0 | 0 | 0 | 0 | 100% | 15 |  |
| en-addr-01 | 59 | 3 | 3 | 0 | 0 | 0 | 1 | 86% | 27 | extra: NW1 6XE(ADDRESS) |
| en-contact-01 | 84 | 3 | 3 | 0 | 0 | 0 | 0 | 100% | 16 |  |
| en-id-01 | 63 | 3 | 3 | 0 | 0 | 0 | 1 | 86% | 11 | extra: SSN(COMPANY) |
| en-date-01 | 67 | 2 | 2 | 0 | 0 | 0 | 0 | 100% | 9 |  |
| en-mixed-01 | 205 | 6 | 4 | 0 | 0 | 2 | 1 | 62% | 24 | wrong type: Manchester Royal Infirmary, 0161 276 1234; extra: NHS(COMPANY) |
| en-negative-01 | 70 | 0 | 0 | 0 | 0 | 0 | 0 | 100% | 13 |  |
| en-negative-02 | 85 | 0 | 0 | 0 | 0 | 0 | 0 | 100% | 11 |  |
| en-ocr-01 | 109 | 4 | 2 | 0 | 2 | 0 | 3 | 44% | 16 | missed: Johnson, Acme Corp oration; extra: 4471
Bill(ADDRESS), Rob ert   Johnson
Acme Corp(COMPANY), 12  High  Street(ADDRESS) |
| fr-name-01 | 63 | 2 | 2 | 0 | 0 | 0 | 0 | 100% | 14 |  |
| fr-org-01 | 64 | 2 | 2 | 0 | 0 | 0 | 0 | 100% | 9 |  |
| fr-loc-01 | 57 | 2 | 2 | 0 | 0 | 0 | 0 | 100% | 10 |  |
| fr-contact-01 | 89 | 3 | 2 | 1 | 0 | 0 | 0 | 100% | 15 |  |
| fr-mixed-01 | 151 | 7 | 4 | 1 | 2 | 0 | 0 | 83% | 15 | missed: 3 avril 1987, 1er septembre 2015 |
| fr-negative-01 | 69 | 0 | 0 | 0 | 0 | 0 | 0 | 100% | 9 |  |
| es-name-01 | 66 | 2 | 2 | 0 | 0 | 0 | 0 | 100% | 8 |  |
| es-org-01 | 62 | 2 | 2 | 0 | 0 | 0 | 0 | 100% | 7 |  |
| es-loc-01 | 60 | 3 | 3 | 0 | 0 | 0 | 0 | 100% | 7 |  |
| es-contact-01 | 62 | 3 | 3 | 0 | 0 | 0 | 0 | 100% | 11 |  |
| es-mixed-01 | 124 | 5 | 3 | 0 | 1 | 1 | 1 | 60% | 14 | missed: 20 de mayo de 2024; wrong type: El Corte Inglés; extra: 2024 en(ADDRESS) |
| es-negative-01 | 63 | 0 | 0 | 0 | 0 | 0 | 0 | 100% | 10 |  |
| hi-name-01 | 45 | 2 | 2 | 0 | 0 | 0 | 0 | 100% | 8 |  |
| hi-org-01 | 49 | 2 | 2 | 0 | 0 | 0 | 0 | 100% | 7 |  |
| hi-loc-01 | 45 | 3 | 3 | 0 | 0 | 0 | 0 | 100% | 8 |  |
| hi-contact-01 | 50 | 2 | 2 | 0 | 0 | 0 | 0 | 100% | 9 |  |
| hi-negative-01 | 41 | 0 | 0 | 0 | 0 | 0 | 0 | 100% | 8 |  |
| de-name-01 | 54 | 3 | 3 | 0 | 0 | 0 | 0 | 100% | 10 |  |
| ja-name-01 | 26 | 3 | 3 | 0 | 0 | 0 | 0 | 100% | 9 |  |
| multi-mixed-01 | 147 | 8 | 8 | 0 | 0 | 0 | 0 | 100% | 21 |  |
| en-long-01 | 1321 | 28 | 25 | 1 | 1 | 1 | 0 | 95% | 116 | missed: NZD 4.2 million; wrong type: Russell McVeagh |
| zh-long-01 | 444 | 18 | 13 | 3 | 2 | 0 | 3 | 89% | 93 | missed: 阿里巴巴, 深圳; extra: 9月3日(DATE), 深圳总部(COMPANY), 法务部(COMPANY) |

