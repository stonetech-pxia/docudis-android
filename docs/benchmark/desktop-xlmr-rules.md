# NER benchmark (desktop, Python onnxruntime)

- Model: xlm-roberta-base-ner-docudis
- Platform: windows "Windows 11 Famille" 10.0 (Build 26200), CPU, onnxruntime via bench_server.py
- Cases: 48, expected entities: 168
- Overall: recall 93%, precision 98%, F1 96% → reliability **A**; 140 ms per 1000 chars → speed **A**

Grades: reliability by F1 (A ≥ 90%, B ≥ 75%, C ≥ 50%, D below); speed by ms per 1000 characters on this platform (A < 300, B < 1000, C < 3000, D above).

## By language

| Language | Cases | Expected | Found | False pos. | Recall | Precision | F1 | Reliability | ms/1000 chars | Speed |
|---|---|---|---|---|---|---|---|---|---|---|
| zh | 11 | 41 | 39 | 0 | 95% | 100% | 98% | A | 234 | A |
| zh-Hant | 1 | 3 | 3 | 0 | 100% | 100% | 100% | A | 405 | B |
| en | 15 | 66 | 60 | 3 | 91% | 96% | 93% | A | 94 | A |
| fr | 7 | 20 | 19 | 1 | 95% | 95% | 95% | A | 140 | A |
| es | 6 | 15 | 14 | 0 | 93% | 100% | 97% | A | 153 | A |
| hi | 5 | 9 | 8 | 0 | 89% | 100% | 94% | A | 236 | A |
| de | 1 | 3 | 3 | 0 | 100% | 100% | 100% | A | 244 | A |
| ja | 1 | 3 | 3 | 0 | 100% | 100% | 100% | A | 438 | B |
| multi | 1 | 8 | 8 | 0 | 100% | 100% | 100% | A | 143 | A |

## By category

| Category | Cases | Expected | Found | False pos. | Recall | Precision | F1 | Reliability | ms/1000 chars | Speed |
|---|---|---|---|---|---|---|---|---|---|---|
| names | 12 | 27 | 26 | 0 | 96% | 100% | 98% | A | 289 | A |
| organizations | 5 | 10 | 8 | 0 | 80% | 100% | 89% | B | 198 | A |
| locations | 5 | 14 | 14 | 0 | 100% | 100% | 100% | A | 232 | A |
| addresses | 2 | 5 | 3 | 1 | 60% | 75% | 67% | C | 294 | A |
| contacts | 5 | 14 | 14 | 1 | 100% | 93% | 97% | A | 178 | A |
| identifiers | 2 | 5 | 5 | 0 | 100% | 100% | 100% | A | 205 | A |
| mixed | 5 | 31 | 30 | 0 | 97% | 100% | 98% | A | 112 | A |
| negatives | 6 | 0 | 0 | 0 | 100% | 100% | 100% | A | 191 | A |
| dates | 1 | 2 | 2 | 0 | 100% | 100% | 100% | A | 183 | A |
| noisy | 1 | 5 | 4 | 1 | 80% | 80% | 80% | B | 120 | A |
| business | 2 | 8 | 7 | 1 | 88% | 88% | 88% | B | 103 | A |
| long | 2 | 47 | 44 | 0 | 94% | 100% | 97% | A | 69 | A |

## Per case

| Case | Chars | Expected | Hit | Partial | Missed | Wrong type | False pos. | F1 | ms | Notes |
|---|---|---|---|---|---|---|---|---|---|---|
| zh-name-01 | 16 | 3 | 3 | 0 | 0 | 0 | 0 | 100% | 16 |  |
| zh-name-02 | 17 | 1 | 1 | 0 | 0 | 0 | 0 | 100% | 10 |  |
| zh-name-03 | 21 | 2 | 2 | 0 | 0 | 0 | 0 | 100% | 11 |  |
| zh-org-01 | 21 | 2 | 1 | 0 | 1 | 0 | 0 | 67% | 10 | missed: 清华大学 |
| zh-loc-01 | 16 | 3 | 3 | 0 | 0 | 0 | 0 | 100% | 12 |  |
| zh-addr-01 | 29 | 1 | 1 | 0 | 0 | 0 | 0 | 100% | 14 |  |
| zh-contact-01 | 55 | 3 | 3 | 0 | 0 | 0 | 0 | 100% | 12 |  |
| zh-id-01 | 48 | 2 | 2 | 0 | 0 | 0 | 0 | 100% | 11 |  |
| zh-mixed-01 | 76 | 5 | 4 | 1 | 0 | 0 | 0 | 100% | 13 |  |
| zh-negative-01 | 22 | 0 | 0 | 0 | 0 | 0 | 0 | 100% | 9 |  |
| zh-trad-01 | 24 | 3 | 2 | 1 | 0 | 0 | 0 | 100% | 9 |  |
| en-name-01 | 60 | 2 | 2 | 0 | 0 | 0 | 0 | 100% | 14 |  |
| en-name-02 | 49 | 2 | 2 | 0 | 0 | 0 | 0 | 100% | 10 |  |
| en-name-03 | 60 | 2 | 0 | 1 | 1 | 0 | 0 | 67% | 10 | missed: ben lee |
| en-org-01 | 61 | 2 | 2 | 0 | 0 | 0 | 0 | 100% | 10 |  |
| en-loc-01 | 53 | 3 | 3 | 0 | 0 | 0 | 0 | 100% | 11 |  |
| en-addr-01 | 59 | 4 | 0 | 2 | 2 | 0 | 1 | 57% | 11 | missed: London, United Kingdom; extra: United(COMPANY) |
| en-contact-01 | 84 | 3 | 3 | 0 | 0 | 0 | 1 | 86% | 13 | extra: IBAN(PERSON) |
| en-id-01 | 63 | 3 | 3 | 0 | 0 | 0 | 0 | 100% | 11 |  |
| en-date-01 | 67 | 2 | 2 | 0 | 0 | 0 | 0 | 100% | 12 |  |
| en-mixed-01 | 205 | 6 | 6 | 0 | 0 | 0 | 0 | 100% | 15 |  |
| en-negative-01 | 70 | 0 | 0 | 0 | 0 | 0 | 0 | 100% | 10 |  |
| en-negative-02 | 85 | 0 | 0 | 0 | 0 | 0 | 0 | 100% | 12 |  |
| en-ocr-01 | 109 | 5 | 2 | 2 | 1 | 0 | 1 | 80% | 13 | missed: Johnson; extra: Rob ert   Johnson(PERSON) |
| fr-name-01 | 63 | 2 | 2 | 0 | 0 | 0 | 0 | 100% | 13 |  |
| fr-org-01 | 64 | 2 | 2 | 0 | 0 | 0 | 0 | 100% | 10 |  |
| fr-loc-01 | 57 | 2 | 2 | 0 | 0 | 0 | 0 | 100% | 10 |  |
| fr-contact-01 | 89 | 3 | 3 | 0 | 0 | 0 | 0 | 100% | 13 |  |
| fr-mixed-01 | 151 | 7 | 6 | 1 | 0 | 0 | 0 | 100% | 15 |  |
| fr-negative-01 | 69 | 0 | 0 | 0 | 0 | 0 | 0 | 100% | 11 |  |
| fr-business-01 | 245 | 4 | 3 | 0 | 1 | 0 | 1 | 75% | 29 | missed: 845210; extra: 202603(NUMBER) |
| es-name-01 | 66 | 2 | 2 | 0 | 0 | 0 | 0 | 100% | 11 |  |
| es-org-01 | 62 | 2 | 2 | 0 | 0 | 0 | 0 | 100% | 8 |  |
| es-loc-01 | 60 | 3 | 3 | 0 | 0 | 0 | 0 | 100% | 8 |  |
| es-contact-01 | 62 | 3 | 3 | 0 | 0 | 0 | 0 | 100% | 10 |  |
| es-mixed-01 | 124 | 5 | 3 | 1 | 1 | 0 | 0 | 89% | 14 | missed: Sevilla |
| es-negative-01 | 63 | 0 | 0 | 0 | 0 | 0 | 0 | 100% | 12 |  |
| hi-name-01 | 45 | 2 | 2 | 0 | 0 | 0 | 0 | 100% | 10 |  |
| hi-org-01 | 49 | 2 | 1 | 0 | 1 | 0 | 0 | 67% | 11 | missed: दिल्ली विश्वविद्यालय |
| hi-loc-01 | 45 | 3 | 3 | 0 | 0 | 0 | 0 | 100% | 10 |  |
| hi-contact-01 | 50 | 2 | 2 | 0 | 0 | 0 | 0 | 100% | 11 |  |
| hi-negative-01 | 41 | 0 | 0 | 0 | 0 | 0 | 0 | 100% | 10 |  |
| de-name-01 | 54 | 3 | 3 | 0 | 0 | 0 | 0 | 100% | 13 |  |
| ja-name-01 | 26 | 3 | 3 | 0 | 0 | 0 | 0 | 100% | 11 |  |
| multi-mixed-01 | 147 | 8 | 8 | 0 | 0 | 0 | 0 | 100% | 21 |  |
| en-long-01 | 1321 | 28 | 25 | 1 | 1 | 1 | 0 | 95% | 64 | missed: Auckland; wrong type: Russell McVeagh |
| en-business-01 | 241 | 4 | 4 | 0 | 0 | 0 | 0 | 100% | 20 |  |
| zh-long-01 | 444 | 19 | 16 | 2 | 1 | 0 | 0 | 97% | 57 | missed: 苏州工业园区 |
