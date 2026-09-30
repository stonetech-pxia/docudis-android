# NER benchmark (desktop, Python onnxruntime)

- Model: xlm-roberta-base-ner-docudis
- Platform: windows "Windows 11 Famille" 10.0 (Build 26200), CPU, onnxruntime via bench_server.py
- Cases: 48, expected entities: 168
- Overall: recall 89%, precision 98%, F1 94% → reliability **A**; 164 ms per 1000 chars → speed **A**

Grades: reliability by F1 (A ≥ 90%, B ≥ 75%, C ≥ 50%, D below); speed by ms per 1000 characters on this platform (A < 300, B < 1000, C < 3000, D above).

## By language

| Language | Cases | Expected | Found | False pos. | Recall | Precision | F1 | Reliability | ms/1000 chars | Speed |
|---|---|---|---|---|---|---|---|---|---|---|
| zh | 11 | 41 | 36 | 1 | 88% | 98% | 93% | A | 275 | A |
| zh-Hant | 1 | 3 | 2 | 0 | 67% | 100% | 80% | B | 514 | B |
| en | 15 | 66 | 60 | 2 | 91% | 97% | 94% | A | 110 | A |
| fr | 7 | 20 | 18 | 0 | 90% | 100% | 95% | A | 168 | A |
| es | 6 | 15 | 14 | 0 | 93% | 100% | 97% | A | 170 | A |
| hi | 5 | 9 | 7 | 0 | 78% | 100% | 88% | B | 237 | A |
| de | 1 | 3 | 3 | 0 | 100% | 100% | 100% | A | 273 | A |
| ja | 1 | 3 | 2 | 0 | 67% | 100% | 80% | B | 457 | B |
| multi | 1 | 8 | 8 | 0 | 100% | 100% | 100% | A | 224 | A |

## By category

| Category | Cases | Expected | Found | False pos. | Recall | Precision | F1 | Reliability | ms/1000 chars | Speed |
|---|---|---|---|---|---|---|---|---|---|---|
| names | 12 | 27 | 23 | 0 | 85% | 100% | 92% | A | 345 | B |
| organizations | 5 | 10 | 5 | 0 | 50% | 100% | 67% | C | 238 | A |
| locations | 5 | 14 | 14 | 0 | 100% | 100% | 100% | A | 272 | A |
| addresses | 2 | 5 | 3 | 1 | 60% | 75% | 67% | C | 315 | B |
| contacts | 5 | 14 | 14 | 0 | 100% | 100% | 100% | A | 215 | A |
| identifiers | 2 | 5 | 5 | 0 | 100% | 100% | 100% | A | 343 | B |
| mixed | 5 | 31 | 30 | 0 | 97% | 100% | 98% | A | 137 | A |
| negatives | 6 | 0 | 0 | 0 | 100% | 100% | 100% | A | 205 | A |
| dates | 1 | 2 | 2 | 0 | 100% | 100% | 100% | A | 186 | A |
| noisy | 1 | 5 | 4 | 1 | 80% | 80% | 80% | B | 165 | A |
| business | 2 | 8 | 7 | 0 | 88% | 100% | 93% | A | 110 | A |
| long | 2 | 47 | 43 | 1 | 91% | 98% | 95% | A | 75 | A |

## Per case

| Case | Chars | Expected | Hit | Partial | Missed | Wrong type | False pos. | F1 | ms | Notes |
|---|---|---|---|---|---|---|---|---|---|---|
| zh-name-01 | 16 | 3 | 1 | 0 | 2 | 0 | 0 | 50% | 22 | missed: 李四, 王五 |
| zh-name-02 | 17 | 1 | 1 | 0 | 0 | 0 | 0 | 100% | 11 |  |
| zh-name-03 | 21 | 2 | 2 | 0 | 0 | 0 | 0 | 100% | 13 |  |
| zh-org-01 | 21 | 2 | 1 | 0 | 1 | 0 | 0 | 67% | 14 | missed: 清华大学 |
| zh-loc-01 | 16 | 3 | 3 | 0 | 0 | 0 | 0 | 100% | 15 |  |
| zh-addr-01 | 29 | 1 | 1 | 0 | 0 | 0 | 0 | 100% | 13 |  |
| zh-contact-01 | 55 | 3 | 3 | 0 | 0 | 0 | 0 | 100% | 16 |  |
| zh-id-01 | 48 | 2 | 2 | 0 | 0 | 0 | 0 | 100% | 15 |  |
| zh-mixed-01 | 76 | 5 | 4 | 1 | 0 | 0 | 0 | 100% | 17 |  |
| zh-negative-01 | 22 | 0 | 0 | 0 | 0 | 0 | 0 | 100% | 12 |  |
| zh-trad-01 | 24 | 3 | 1 | 1 | 1 | 0 | 0 | 80% | 12 | missed: 陳大文 |
| en-name-01 | 60 | 2 | 2 | 0 | 0 | 0 | 0 | 100% | 17 |  |
| en-name-02 | 49 | 2 | 2 | 0 | 0 | 0 | 0 | 100% | 12 |  |
| en-name-03 | 60 | 2 | 2 | 0 | 0 | 0 | 0 | 100% | 12 |  |
| en-org-01 | 61 | 2 | 1 | 0 | 1 | 0 | 0 | 67% | 10 | missed: University of Oxford |
| en-loc-01 | 53 | 3 | 3 | 0 | 0 | 0 | 0 | 100% | 13 |  |
| en-addr-01 | 59 | 4 | 0 | 2 | 2 | 0 | 1 | 57% | 14 | missed: London, United Kingdom; extra: United(COMPANY) |
| en-contact-01 | 84 | 3 | 3 | 0 | 0 | 0 | 0 | 100% | 14 |  |
| en-id-01 | 63 | 3 | 3 | 0 | 0 | 0 | 0 | 100% | 22 |  |
| en-date-01 | 67 | 2 | 2 | 0 | 0 | 0 | 0 | 100% | 12 |  |
| en-mixed-01 | 205 | 6 | 6 | 0 | 0 | 0 | 0 | 100% | 17 |  |
| en-negative-01 | 70 | 0 | 0 | 0 | 0 | 0 | 0 | 100% | 12 |  |
| en-negative-02 | 85 | 0 | 0 | 0 | 0 | 0 | 0 | 100% | 12 |  |
| en-ocr-01 | 109 | 5 | 2 | 2 | 1 | 0 | 1 | 80% | 17 | missed: Johnson; extra: Rob ert   Johnson(PERSON) |
| fr-name-01 | 63 | 2 | 2 | 0 | 0 | 0 | 0 | 100% | 18 |  |
| fr-org-01 | 64 | 2 | 1 | 0 | 1 | 0 | 0 | 67% | 13 | missed: Université de Lyon |
| fr-loc-01 | 57 | 2 | 2 | 0 | 0 | 0 | 0 | 100% | 12 |  |
| fr-contact-01 | 89 | 3 | 3 | 0 | 0 | 0 | 0 | 100% | 16 |  |
| fr-mixed-01 | 151 | 7 | 6 | 1 | 0 | 0 | 0 | 100% | 15 |  |
| fr-negative-01 | 69 | 0 | 0 | 0 | 0 | 0 | 0 | 100% | 12 |  |
| fr-business-01 | 245 | 4 | 3 | 0 | 1 | 0 | 0 | 86% | 34 | missed: 845210 |
| es-name-01 | 66 | 2 | 2 | 0 | 0 | 0 | 0 | 100% | 14 |  |
| es-org-01 | 62 | 2 | 2 | 0 | 0 | 0 | 0 | 100% | 11 |  |
| es-loc-01 | 60 | 3 | 3 | 0 | 0 | 0 | 0 | 100% | 11 |  |
| es-contact-01 | 62 | 3 | 3 | 0 | 0 | 0 | 0 | 100% | 12 |  |
| es-mixed-01 | 124 | 5 | 3 | 1 | 1 | 0 | 0 | 89% | 13 | missed: Sevilla |
| es-negative-01 | 63 | 0 | 0 | 0 | 0 | 0 | 0 | 100% | 11 |  |
| hi-name-01 | 45 | 2 | 2 | 0 | 0 | 0 | 0 | 100% | 10 |  |
| hi-org-01 | 49 | 2 | 0 | 0 | 2 | 0 | 0 | 0% | 10 | missed: टाटा समूह, दिल्ली विश्वविद्यालय |
| hi-loc-01 | 45 | 3 | 3 | 0 | 0 | 0 | 0 | 100% | 10 |  |
| hi-contact-01 | 50 | 2 | 2 | 0 | 0 | 0 | 0 | 100% | 12 |  |
| hi-negative-01 | 41 | 0 | 0 | 0 | 0 | 0 | 0 | 100% | 10 |  |
| de-name-01 | 54 | 3 | 3 | 0 | 0 | 0 | 0 | 100% | 14 |  |
| ja-name-01 | 26 | 3 | 2 | 0 | 1 | 0 | 0 | 80% | 11 | missed: 東京 |
| multi-mixed-01 | 147 | 8 | 8 | 0 | 0 | 0 | 0 | 100% | 32 |  |
| en-long-01 | 1321 | 28 | 25 | 1 | 1 | 1 | 0 | 95% | 75 | missed: Auckland; wrong type: Russell McVeagh |
| en-business-01 | 241 | 4 | 4 | 0 | 0 | 0 | 0 | 100% | 19 |  |
| zh-long-01 | 444 | 19 | 15 | 2 | 2 | 0 | 1 | 93% | 57 | missed: 阿里巴巴, 苏州工业园区; extra: 阿里巴巴西溪园区三号楼会议室(ADDRESS) |
