# NER benchmark (desktop, Python onnxruntime)

- Model: xlm-roberta-base-ner-docudis
- Platform: windows "Windows 11 Famille" 10.0 (Build 26200), CPU, onnxruntime via bench_server.py
- Cases: 48, expected entities: 168
- Overall: recall 92%, precision 97%, F1 95% → reliability **A**; 222 ms per 1000 chars → speed **A**

Grades: reliability by F1 (A ≥ 90%, B ≥ 75%, C ≥ 50%, D below); speed by ms per 1000 characters on this platform (A < 300, B < 1000, C < 3000, D above).

## By language

| Language | Cases | Expected | Found | False pos. | Recall | Precision | F1 | Reliability | ms/1000 chars | Speed |
|---|---|---|---|---|---|---|---|---|---|---|
| zh | 11 | 41 | 39 | 1 | 95% | 98% | 97% | A | 375 | B |
| zh-Hant | 1 | 3 | 3 | 0 | 100% | 100% | 100% | A | 596 | B |
| en | 15 | 66 | 60 | 2 | 91% | 97% | 94% | A | 148 | A |
| fr | 7 | 20 | 19 | 1 | 95% | 95% | 95% | A | 215 | A |
| es | 6 | 15 | 13 | 1 | 87% | 93% | 90% | B | 227 | A |
| hi | 5 | 9 | 7 | 0 | 78% | 100% | 88% | B | 384 | B |
| de | 1 | 3 | 3 | 0 | 100% | 100% | 100% | A | 331 | B |
| ja | 1 | 3 | 3 | 0 | 100% | 100% | 100% | A | 491 | B |
| multi | 1 | 8 | 8 | 0 | 100% | 100% | 100% | A | 344 | B |

## By category

| Category | Cases | Expected | Found | False pos. | Recall | Precision | F1 | Reliability | ms/1000 chars | Speed |
|---|---|---|---|---|---|---|---|---|---|---|
| names | 12 | 27 | 27 | 0 | 100% | 100% | 100% | A | 435 | B |
| organizations | 5 | 10 | 7 | 0 | 70% | 100% | 82% | B | 348 | B |
| locations | 5 | 14 | 13 | 1 | 93% | 93% | 93% | A | 373 | B |
| addresses | 2 | 5 | 2 | 1 | 40% | 67% | 50% | C | 489 | B |
| contacts | 5 | 14 | 14 | 0 | 100% | 100% | 100% | A | 247 | A |
| identifiers | 2 | 5 | 5 | 0 | 100% | 100% | 100% | A | 407 | B |
| mixed | 5 | 31 | 30 | 0 | 97% | 100% | 98% | A | 200 | A |
| negatives | 6 | 0 | 0 | 0 | 100% | 100% | 100% | A | 306 | B |
| dates | 1 | 2 | 2 | 0 | 100% | 100% | 100% | A | 213 | A |
| noisy | 1 | 5 | 4 | 1 | 80% | 80% | 80% | B | 173 | A |
| business | 2 | 8 | 7 | 1 | 88% | 88% | 88% | B | 162 | A |
| long | 2 | 47 | 44 | 1 | 94% | 98% | 96% | A | 106 | A |

## Per case

| Case | Chars | Expected | Hit | Partial | Missed | Wrong type | False pos. | F1 | ms | Notes |
|---|---|---|---|---|---|---|---|---|---|---|
| zh-name-01 | 16 | 3 | 3 | 0 | 0 | 0 | 0 | 100% | 35 |  |
| zh-name-02 | 17 | 1 | 1 | 0 | 0 | 0 | 0 | 100% | 15 |  |
| zh-name-03 | 21 | 2 | 2 | 0 | 0 | 0 | 0 | 100% | 12 |  |
| zh-org-01 | 21 | 2 | 1 | 0 | 1 | 0 | 0 | 67% | 21 | missed: 清华大学 |
| zh-loc-01 | 16 | 3 | 3 | 0 | 0 | 0 | 0 | 100% | 18 |  |
| zh-addr-01 | 29 | 1 | 1 | 0 | 0 | 0 | 0 | 100% | 20 |  |
| zh-contact-01 | 55 | 3 | 3 | 0 | 0 | 0 | 0 | 100% | 17 |  |
| zh-id-01 | 48 | 2 | 2 | 0 | 0 | 0 | 0 | 100% | 23 |  |
| zh-mixed-01 | 76 | 5 | 4 | 1 | 0 | 0 | 0 | 100% | 21 |  |
| zh-negative-01 | 22 | 0 | 0 | 0 | 0 | 0 | 0 | 100% | 19 |  |
| zh-trad-01 | 24 | 3 | 2 | 1 | 0 | 0 | 0 | 100% | 14 |  |
| en-name-01 | 60 | 2 | 2 | 0 | 0 | 0 | 0 | 100% | 26 |  |
| en-name-02 | 49 | 2 | 2 | 0 | 0 | 0 | 0 | 100% | 16 |  |
| en-name-03 | 60 | 2 | 2 | 0 | 0 | 0 | 0 | 100% | 17 |  |
| en-org-01 | 61 | 2 | 2 | 0 | 0 | 0 | 0 | 100% | 18 |  |
| en-loc-01 | 53 | 3 | 3 | 0 | 0 | 0 | 0 | 100% | 17 |  |
| en-addr-01 | 59 | 4 | 0 | 1 | 3 | 0 | 1 | 33% | 22 | missed: London, United Kingdom, NW1 6XE; extra: United Kingdom.(COMPANY) |
| en-contact-01 | 84 | 3 | 3 | 0 | 0 | 0 | 0 | 100% | 19 |  |
| en-id-01 | 63 | 3 | 3 | 0 | 0 | 0 | 0 | 100% | 21 |  |
| en-date-01 | 67 | 2 | 2 | 0 | 0 | 0 | 0 | 100% | 14 |  |
| en-mixed-01 | 205 | 6 | 6 | 0 | 0 | 0 | 0 | 100% | 25 |  |
| en-negative-01 | 70 | 0 | 0 | 0 | 0 | 0 | 0 | 100% | 17 |  |
| en-negative-02 | 85 | 0 | 0 | 0 | 0 | 0 | 0 | 100% | 15 |  |
| en-ocr-01 | 109 | 5 | 2 | 2 | 1 | 0 | 1 | 80% | 18 | missed: Johnson; extra: Rob ert   Johnson(PERSON) |
| fr-name-01 | 63 | 2 | 2 | 0 | 0 | 0 | 0 | 100% | 19 |  |
| fr-org-01 | 64 | 2 | 2 | 0 | 0 | 0 | 0 | 100% | 17 |  |
| fr-loc-01 | 57 | 2 | 2 | 0 | 0 | 0 | 0 | 100% | 17 |  |
| fr-contact-01 | 89 | 3 | 3 | 0 | 0 | 0 | 0 | 100% | 16 |  |
| fr-mixed-01 | 151 | 7 | 7 | 0 | 0 | 0 | 0 | 100% | 23 |  |
| fr-negative-01 | 69 | 0 | 0 | 0 | 0 | 0 | 0 | 100% | 13 |  |
| fr-business-01 | 245 | 4 | 3 | 0 | 1 | 0 | 1 | 75% | 50 | missed: 845210; extra: 202603(NUMBER) |
| es-name-01 | 66 | 2 | 2 | 0 | 0 | 0 | 0 | 100% | 17 |  |
| es-org-01 | 62 | 2 | 2 | 0 | 0 | 0 | 0 | 100% | 15 |  |
| es-loc-01 | 60 | 3 | 2 | 0 | 1 | 0 | 1 | 67% | 17 | missed: Madrid; extra: Viajó de Madrid(ADDRESS) |
| es-contact-01 | 62 | 3 | 3 | 0 | 0 | 0 | 0 | 100% | 13 |  |
| es-mixed-01 | 124 | 5 | 3 | 1 | 1 | 0 | 0 | 89% | 19 | missed: Sevilla |
| es-negative-01 | 63 | 0 | 0 | 0 | 0 | 0 | 0 | 100% | 15 |  |
| hi-name-01 | 45 | 2 | 2 | 0 | 0 | 0 | 0 | 100% | 12 |  |
| hi-org-01 | 49 | 2 | 0 | 0 | 2 | 0 | 0 | 0% | 16 | missed: टाटा समूह, दिल्ली विश्वविद्यालय |
| hi-loc-01 | 45 | 3 | 3 | 0 | 0 | 0 | 0 | 100% | 16 |  |
| hi-contact-01 | 50 | 2 | 2 | 0 | 0 | 0 | 0 | 100% | 16 |  |
| hi-negative-01 | 41 | 0 | 0 | 0 | 0 | 0 | 0 | 100% | 26 |  |
| de-name-01 | 54 | 3 | 3 | 0 | 0 | 0 | 0 | 100% | 17 |  |
| ja-name-01 | 26 | 3 | 3 | 0 | 0 | 0 | 0 | 100% | 12 |  |
| multi-mixed-01 | 147 | 8 | 8 | 0 | 0 | 0 | 0 | 100% | 50 |  |
| en-long-01 | 1321 | 28 | 25 | 1 | 1 | 1 | 0 | 95% | 104 | missed: Auckland; wrong type: Russell McVeagh |
| en-business-01 | 241 | 4 | 4 | 0 | 0 | 0 | 0 | 100% | 28 |  |
| zh-long-01 | 444 | 19 | 15 | 3 | 1 | 0 | 1 | 96% | 81 | missed: 阿里巴巴; extra: 阿里巴巴西溪园区三号楼会议室(ADDRESS) |
