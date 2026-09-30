# NER benchmark (device)

Device: Samsung Galaxy S26 Ultra (SM-S948B, Snapdragon SM8850), Android 16, debug build, onnxruntime-android 1.30.0 forced (see docs/anonymization-design.md).

- Model: distilbert-base-multilingual-cased-ner-hrl
- Platform: android BP4A.251205.006.S948BXXS4AZHL, ONNX Runtime CPU via flutter_onnxruntime
- Cases: 46, expected entities: 157
- Overall: recall 90%, precision 94%, F1 92% → reliability **A**; 92 ms per 1000 chars → speed **A**

Grades: reliability by F1 (A ≥ 90%, B ≥ 75%, C ≥ 50%, D below); speed by ms per 1000 characters on this platform (A < 300, B < 1000, C < 3000, D above).

## By language

| Language | Cases | Expected | Found | False pos. | Recall | Precision | F1 | Reliability | ms/1000 chars | Speed |
|---|---|---|---|---|---|---|---|---|---|---|
| zh | 11 | 40 | 37 | 2 | 93% | 96% | 94% | A | 163 | A |
| zh-Hant | 1 | 3 | 3 | 0 | 100% | 100% | 100% | A | 241 | A |
| en | 14 | 60 | 52 | 7 | 87% | 90% | 88% | B | 66 | A |
| fr | 6 | 16 | 14 | 0 | 88% | 100% | 93% | A | 80 | A |
| es | 6 | 15 | 14 | 1 | 93% | 93% | 93% | A | 79 | A |
| hi | 5 | 9 | 7 | 1 | 78% | 88% | 82% | B | 135 | A |
| de | 1 | 3 | 3 | 0 | 100% | 100% | 100% | A | 135 | A |
| ja | 1 | 3 | 3 | 0 | 100% | 100% | 100% | A | 227 | A |
| multi | 1 | 8 | 8 | 0 | 100% | 100% | 100% | A | 88 | A |

## By category

| Category | Cases | Expected | Found | False pos. | Recall | Precision | F1 | Reliability | ms/1000 chars | Speed |
|---|---|---|---|---|---|---|---|---|---|---|
| names | 12 | 27 | 25 | 0 | 93% | 100% | 96% | A | 152 | A |
| organizations | 5 | 10 | 9 | 0 | 90% | 100% | 95% | A | 97 | A |
| locations | 5 | 14 | 13 | 0 | 93% | 100% | 96% | A | 98 | A |
| addresses | 2 | 4 | 4 | 1 | 100% | 80% | 89% | B | 111 | A |
| contacts | 5 | 14 | 14 | 1 | 100% | 93% | 97% | A | 102 | A |
| identifiers | 2 | 5 | 5 | 0 | 100% | 100% | 100% | A | 116 | A |
| mixed | 5 | 31 | 26 | 2 | 84% | 93% | 88% | B | 73 | A |
| negatives | 6 | 0 | 0 | 0 | 100% | 100% | 100% | A | 106 | A |
| dates | 1 | 2 | 2 | 0 | 100% | 100% | 100% | A | 78 | A |
| noisy | 1 | 4 | 2 | 3 | 50% | 40% | 44% | D | 61 | A |
| long | 2 | 46 | 41 | 4 | 89% | 94% | 91% | A | 77 | A |

## Per case

| Case | Chars | Expected | Hit | Partial | Missed | Wrong type | False pos. | F1 | ms | Notes |
|---|---|---|---|---|---|---|---|---|---|---|
| zh-name-01 | 16 | 3 | 3 | 0 | 0 | 0 | 0 | 100% | 7 |  |
| zh-name-02 | 17 | 1 | 1 | 0 | 0 | 0 | 0 | 100% | 4 |  |
| zh-name-03 | 21 | 2 | 2 | 0 | 0 | 0 | 0 | 100% | 4 |  |
| zh-org-01 | 21 | 2 | 2 | 0 | 0 | 0 | 0 | 100% | 5 |  |
| zh-loc-01 | 16 | 3 | 3 | 0 | 0 | 0 | 0 | 100% | 4 |  |
| zh-addr-01 | 29 | 1 | 1 | 0 | 0 | 0 | 0 | 100% | 5 |  |
| zh-contact-01 | 55 | 3 | 3 | 0 | 0 | 0 | 0 | 100% | 5 |  |
| zh-id-01 | 48 | 2 | 2 | 0 | 0 | 0 | 0 | 100% | 6 |  |
| zh-mixed-01 | 76 | 5 | 3 | 1 | 1 | 0 | 0 | 89% | 11 | missed: 招商银行 |
| zh-negative-01 | 22 | 0 | 0 | 0 | 0 | 0 | 0 | 100% | 6 |  |
| zh-trad-01 | 24 | 3 | 2 | 1 | 0 | 0 | 0 | 100% | 5 |  |
| en-name-01 | 60 | 2 | 2 | 0 | 0 | 0 | 0 | 100% | 12 |  |
| en-name-02 | 49 | 2 | 2 | 0 | 0 | 0 | 0 | 100% | 5 |  |
| en-name-03 | 60 | 2 | 0 | 0 | 2 | 0 | 0 | 0% | 5 | missed: aisha khan, ben lee |
| en-org-01 | 61 | 2 | 2 | 0 | 0 | 0 | 0 | 100% | 4 |  |
| en-loc-01 | 53 | 3 | 3 | 0 | 0 | 0 | 0 | 100% | 3 |  |
| en-addr-01 | 59 | 3 | 3 | 0 | 0 | 0 | 1 | 86% | 4 | extra: NW1 6XE(ADDRESS) |
| en-contact-01 | 84 | 3 | 3 | 0 | 0 | 0 | 0 | 100% | 7 |  |
| en-id-01 | 63 | 3 | 3 | 0 | 0 | 0 | 0 | 100% | 6 |  |
| en-date-01 | 67 | 2 | 2 | 0 | 0 | 0 | 0 | 100% | 5 |  |
| en-mixed-01 | 205 | 6 | 4 | 1 | 0 | 1 | 1 | 77% | 10 | wrong type: 0161 276 1234; extra: Infirmary(ADDRESS) |
| en-negative-01 | 70 | 0 | 0 | 0 | 0 | 0 | 0 | 100% | 5 |  |
| en-negative-02 | 85 | 0 | 0 | 0 | 0 | 0 | 0 | 100% | 5 |  |
| en-ocr-01 | 109 | 4 | 2 | 0 | 2 | 0 | 3 | 44% | 6 | missed: Johnson, Acme Corp oration; extra: 4471
Bill(ADDRESS), Rob ert   Johnson
Acme Corp(COMPANY), 12  High  Street(ADDRESS) |
| fr-name-01 | 63 | 2 | 2 | 0 | 0 | 0 | 0 | 100% | 6 |  |
| fr-org-01 | 64 | 2 | 2 | 0 | 0 | 0 | 0 | 100% | 4 |  |
| fr-loc-01 | 57 | 2 | 2 | 0 | 0 | 0 | 0 | 100% | 4 |  |
| fr-contact-01 | 89 | 3 | 2 | 1 | 0 | 0 | 0 | 100% | 8 |  |
| fr-mixed-01 | 151 | 7 | 4 | 1 | 2 | 0 | 0 | 83% | 8 | missed: 3 avril 1987, 1er septembre 2015 |
| fr-negative-01 | 69 | 0 | 0 | 0 | 0 | 0 | 0 | 100% | 6 |  |
| es-name-01 | 66 | 2 | 2 | 0 | 0 | 0 | 0 | 100% | 5 |  |
| es-org-01 | 62 | 2 | 2 | 0 | 0 | 0 | 0 | 100% | 5 |  |
| es-loc-01 | 60 | 3 | 3 | 0 | 0 | 0 | 0 | 100% | 4 |  |
| es-contact-01 | 62 | 3 | 3 | 0 | 0 | 0 | 0 | 100% | 6 |  |
| es-mixed-01 | 124 | 5 | 4 | 0 | 1 | 0 | 1 | 80% | 7 | missed: 20 de mayo de 2024; extra: 2024 en(ADDRESS) |
| es-negative-01 | 63 | 0 | 0 | 0 | 0 | 0 | 0 | 100% | 4 |  |
| hi-name-01 | 45 | 2 | 1 | 1 | 0 | 0 | 0 | 100% | 5 |  |
| hi-org-01 | 49 | 2 | 1 | 0 | 1 | 0 | 0 | 67% | 5 | missed: टाटा समूह |
| hi-loc-01 | 45 | 3 | 2 | 0 | 1 | 0 | 0 | 80% | 5 | missed: बेंगलुरु |
| hi-contact-01 | 50 | 2 | 2 | 0 | 0 | 0 | 1 | 80% | 5 | extra: ईमेल(COMPANY) |
| hi-negative-01 | 41 | 0 | 0 | 0 | 0 | 0 | 0 | 100% | 8 |  |
| de-name-01 | 54 | 3 | 3 | 0 | 0 | 0 | 0 | 100% | 7 |  |
| ja-name-01 | 26 | 3 | 3 | 0 | 0 | 0 | 0 | 100% | 5 |  |
| multi-mixed-01 | 147 | 8 | 8 | 0 | 0 | 0 | 0 | 100% | 12 |  |
| en-long-01 | 1321 | 28 | 24 | 1 | 2 | 1 | 2 | 90% | 73 | missed: Callaghan Innovation, NZD 4.2 million; wrong type: Russell McVeagh; extra: CFO(COMPANY), NZD(ADDRESS) |
| zh-long-01 | 444 | 18 | 12 | 4 | 2 | 0 | 2 | 91% | 62 | missed: 阿里巴巴, 深圳; extra: 9月3日(DATE), 深圳总部法务部(COMPANY) |

