# NER benchmark (desktop, Python onnxruntime)

- Model: xlm-roberta-base-ner-hrl
- Platform: windows "Windows 11 Famille" 10.0 (Build 26200), CPU, onnxruntime via bench_server.py
- Cases: 48, expected entities: 168
- Overall: recall 96%, precision 98%, F1 97% → reliability **A**; 299 ms per 1000 chars → speed **A**

Grades: reliability by F1 (A ≥ 90%, B ≥ 75%, C ≥ 50%, D below); speed by ms per 1000 characters on this platform (A < 300, B < 1000, C < 3000, D above).

## By language

| Language | Cases | Expected | Found | False pos. | Recall | Precision | F1 | Reliability | ms/1000 chars | Speed |
|---|---|---|---|---|---|---|---|---|---|---|
| zh | 11 | 41 | 40 | 2 | 98% | 96% | 97% | A | 474 | B |
| zh-Hant | 1 | 3 | 3 | 0 | 100% | 100% | 100% | A | 915 | B |
| en | 15 | 66 | 62 | 1 | 94% | 99% | 96% | A | 212 | A |
| fr | 7 | 20 | 19 | 0 | 95% | 100% | 97% | A | 248 | A |
| es | 6 | 15 | 15 | 0 | 100% | 100% | 100% | A | 331 | B |
| hi | 5 | 9 | 8 | 0 | 89% | 100% | 94% | A | 546 | B |
| de | 1 | 3 | 3 | 0 | 100% | 100% | 100% | A | 602 | B |
| ja | 1 | 3 | 3 | 0 | 100% | 100% | 100% | A | 742 | B |
| multi | 1 | 8 | 8 | 0 | 100% | 100% | 100% | A | 412 | B |

## By category

| Category | Cases | Expected | Found | False pos. | Recall | Precision | F1 | Reliability | ms/1000 chars | Speed |
|---|---|---|---|---|---|---|---|---|---|---|
| names | 12 | 27 | 26 | 0 | 96% | 100% | 98% | A | 598 | B |
| organizations | 5 | 10 | 9 | 0 | 90% | 100% | 95% | A | 401 | B |
| locations | 5 | 14 | 14 | 0 | 100% | 100% | 100% | A | 489 | B |
| addresses | 2 | 5 | 5 | 0 | 100% | 100% | 100% | A | 455 | B |
| contacts | 5 | 14 | 14 | 0 | 100% | 100% | 100% | A | 363 | B |
| identifiers | 2 | 5 | 5 | 0 | 100% | 100% | 100% | A | 338 | B |
| mixed | 5 | 31 | 31 | 0 | 100% | 100% | 100% | A | 240 | A |
| negatives | 6 | 0 | 0 | 0 | 100% | 100% | 100% | A | 418 | B |
| dates | 1 | 2 | 2 | 0 | 100% | 100% | 100% | A | 374 | B |
| noisy | 1 | 5 | 3 | 0 | 60% | 100% | 75% | C | 264 | A |
| business | 2 | 8 | 7 | 0 | 88% | 100% | 93% | A | 173 | A |
| long | 2 | 47 | 45 | 3 | 96% | 95% | 96% | A | 187 | A |

## Per case

| Case | Chars | Expected | Hit | Partial | Missed | Wrong type | False pos. | F1 | ms | Notes |
|---|---|---|---|---|---|---|---|---|---|---|
| zh-name-01 | 16 | 3 | 3 | 0 | 0 | 0 | 0 | 100% | 33 |  |
| zh-name-02 | 17 | 1 | 1 | 0 | 0 | 0 | 0 | 100% | 19 |  |
| zh-name-03 | 21 | 2 | 2 | 0 | 0 | 0 | 0 | 100% | 23 |  |
| zh-org-01 | 21 | 2 | 2 | 0 | 0 | 0 | 0 | 100% | 17 |  |
| zh-loc-01 | 16 | 3 | 3 | 0 | 0 | 0 | 0 | 100% | 22 |  |
| zh-addr-01 | 29 | 1 | 1 | 0 | 0 | 0 | 0 | 100% | 23 |  |
| zh-contact-01 | 55 | 3 | 3 | 0 | 0 | 0 | 0 | 100% | 27 |  |
| zh-id-01 | 48 | 2 | 2 | 0 | 0 | 0 | 0 | 100% | 19 |  |
| zh-mixed-01 | 76 | 5 | 4 | 1 | 0 | 0 | 0 | 100% | 27 |  |
| zh-negative-01 | 22 | 0 | 0 | 0 | 0 | 0 | 0 | 100% | 24 |  |
| zh-trad-01 | 24 | 3 | 2 | 1 | 0 | 0 | 0 | 100% | 21 |  |
| en-name-01 | 60 | 2 | 2 | 0 | 0 | 0 | 0 | 100% | 33 |  |
| en-name-02 | 49 | 2 | 2 | 0 | 0 | 0 | 0 | 100% | 18 |  |
| en-name-03 | 60 | 2 | 0 | 1 | 1 | 0 | 0 | 67% | 19 | missed: ben lee |
| en-org-01 | 61 | 2 | 2 | 0 | 0 | 0 | 0 | 100% | 25 |  |
| en-loc-01 | 53 | 3 | 3 | 0 | 0 | 0 | 0 | 100% | 16 |  |
| en-addr-01 | 59 | 4 | 4 | 0 | 0 | 0 | 0 | 100% | 16 |  |
| en-contact-01 | 84 | 3 | 3 | 0 | 0 | 0 | 0 | 100% | 27 |  |
| en-id-01 | 63 | 3 | 3 | 0 | 0 | 0 | 0 | 100% | 17 |  |
| en-date-01 | 67 | 2 | 2 | 0 | 0 | 0 | 0 | 100% | 25 |  |
| en-mixed-01 | 205 | 6 | 6 | 0 | 0 | 0 | 0 | 100% | 23 |  |
| en-negative-01 | 70 | 0 | 0 | 0 | 0 | 0 | 0 | 100% | 19 |  |
| en-negative-02 | 85 | 0 | 0 | 0 | 0 | 0 | 0 | 100% | 30 |  |
| en-ocr-01 | 109 | 5 | 2 | 1 | 1 | 1 | 0 | 67% | 28 | missed: Bristol; wrong type: Johnson |
| fr-name-01 | 63 | 2 | 2 | 0 | 0 | 0 | 0 | 100% | 28 |  |
| fr-org-01 | 64 | 2 | 2 | 0 | 0 | 0 | 0 | 100% | 16 |  |
| fr-loc-01 | 57 | 2 | 2 | 0 | 0 | 0 | 0 | 100% | 19 |  |
| fr-contact-01 | 89 | 3 | 3 | 0 | 0 | 0 | 0 | 100% | 24 |  |
| fr-mixed-01 | 151 | 7 | 7 | 0 | 0 | 0 | 0 | 100% | 36 |  |
| fr-negative-01 | 69 | 0 | 0 | 0 | 0 | 0 | 0 | 100% | 16 |  |
| fr-business-01 | 245 | 4 | 3 | 0 | 1 | 0 | 0 | 86% | 41 | missed: 845210 |
| es-name-01 | 66 | 2 | 2 | 0 | 0 | 0 | 0 | 100% | 27 |  |
| es-org-01 | 62 | 2 | 2 | 0 | 0 | 0 | 0 | 100% | 17 |  |
| es-loc-01 | 60 | 3 | 3 | 0 | 0 | 0 | 0 | 100% | 30 |  |
| es-contact-01 | 62 | 3 | 3 | 0 | 0 | 0 | 0 | 100% | 20 |  |
| es-mixed-01 | 124 | 5 | 5 | 0 | 0 | 0 | 0 | 100% | 21 |  |
| es-negative-01 | 63 | 0 | 0 | 0 | 0 | 0 | 0 | 100% | 28 |  |
| hi-name-01 | 45 | 2 | 2 | 0 | 0 | 0 | 0 | 100% | 23 |  |
| hi-org-01 | 49 | 2 | 1 | 0 | 1 | 0 | 0 | 67% | 27 | missed: टाटा समूह |
| hi-loc-01 | 45 | 3 | 3 | 0 | 0 | 0 | 0 | 100% | 24 |  |
| hi-contact-01 | 50 | 2 | 2 | 0 | 0 | 0 | 0 | 100% | 22 |  |
| hi-negative-01 | 41 | 0 | 0 | 0 | 0 | 0 | 0 | 100% | 27 |  |
| de-name-01 | 54 | 3 | 3 | 0 | 0 | 0 | 0 | 100% | 32 |  |
| ja-name-01 | 26 | 3 | 3 | 0 | 0 | 0 | 0 | 100% | 19 |  |
| multi-mixed-01 | 147 | 8 | 8 | 0 | 0 | 0 | 0 | 100% | 60 |  |
| en-long-01 | 1321 | 28 | 27 | 0 | 1 | 0 | 1 | 97% | 204 | missed: Russell McVeagh; extra: Russell McVeagh.(PERSON) |
| en-business-01 | 241 | 4 | 4 | 0 | 0 | 0 | 0 | 100% | 42 |  |
| zh-long-01 | 444 | 19 | 16 | 2 | 1 | 0 | 2 | 94% | 124 | missed: 阿里巴巴; extra: 阿里巴巴西溪园区三号楼会议室(ADDRESS), 恒隆广场办公室(ADDRESS) |
