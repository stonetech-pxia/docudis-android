# NER benchmark (device)

- Model: xlm-roberta-base-ner-docudis
- Platform: android BP4A.251205.006.S948BXXS4AZHL, ONNX Runtime CPU via flutter_onnxruntime
- Cases: 48, expected entities: 168
- Overall: recall 92%, precision 97%, F1 94% → reliability **A**; 333 ms per 1000 chars → speed **B**

Grades: reliability by F1 (A ≥ 90%, B ≥ 75%, C ≥ 50%, D below); speed by ms per 1000 characters on this platform (A < 300, B < 1000, C < 3000, D above).

## By language

| Language | Cases | Expected | Found | False pos. | Recall | Precision | F1 | Reliability | ms/1000 chars | Speed |
|---|---|---|---|---|---|---|---|---|---|---|
| zh | 11 | 41 | 37 | 1 | 90% | 98% | 94% | A | 509 | B |
| zh-Hant | 1 | 3 | 3 | 0 | 100% | 100% | 100% | A | 769 | B |
| en | 15 | 66 | 60 | 3 | 91% | 96% | 93% | A | 286 | A |
| fr | 7 | 20 | 19 | 1 | 95% | 95% | 95% | A | 294 | A |
| es | 6 | 15 | 13 | 1 | 87% | 93% | 90% | B | 177 | A |
| hi | 5 | 9 | 9 | 0 | 100% | 100% | 100% | A | 467 | B |
| de | 1 | 3 | 3 | 0 | 100% | 100% | 100% | A | 234 | A |
| ja | 1 | 3 | 3 | 0 | 100% | 100% | 100% | A | 591 | B |
| multi | 1 | 8 | 8 | 0 | 100% | 100% | 100% | A | 605 | B |

## By category

| Category | Cases | Expected | Found | False pos. | Recall | Precision | F1 | Reliability | ms/1000 chars | Speed |
|---|---|---|---|---|---|---|---|---|---|---|
| names | 12 | 27 | 24 | 0 | 89% | 100% | 94% | A | 496 | B |
| organizations | 5 | 10 | 9 | 0 | 90% | 100% | 95% | A | 261 | A |
| locations | 5 | 14 | 13 | 1 | 93% | 93% | 93% | A | 307 | B |
| addresses | 2 | 5 | 3 | 1 | 60% | 75% | 67% | C | 923 | B |
| contacts | 5 | 14 | 14 | 1 | 100% | 93% | 97% | A | 676 | B |
| identifiers | 2 | 5 | 5 | 0 | 100% | 100% | 100% | A | 1112 | C |
| mixed | 5 | 31 | 30 | 0 | 97% | 100% | 98% | A | 431 | B |
| negatives | 6 | 0 | 0 | 0 | 100% | 100% | 100% | A | 235 | A |
| dates | 1 | 2 | 2 | 0 | 100% | 100% | 100% | A | 1043 | C |
| noisy | 1 | 5 | 4 | 1 | 80% | 80% | 80% | B | 133 | A |
| business | 2 | 8 | 7 | 1 | 88% | 88% | 88% | B | 217 | A |
| long | 2 | 47 | 44 | 1 | 94% | 98% | 96% | A | 153 | A |

## Per case

| Case | Chars | Expected | Hit | Partial | Missed | Wrong type | False pos. | F1 | ms | Notes |
|---|---|---|---|---|---|---|---|---|---|---|
| zh-name-01 | 16 | 3 | 1 | 0 | 2 | 0 | 0 | 50% | 14 | missed: 李四, 王五 |
| zh-name-02 | 17 | 1 | 1 | 0 | 0 | 0 | 0 | 100% | 10 |  |
| zh-name-03 | 21 | 2 | 2 | 0 | 0 | 0 | 0 | 100% | 11 |  |
| zh-org-01 | 21 | 2 | 1 | 0 | 0 | 1 | 0 | 50% | 13 | wrong type: 清华大学 |
| zh-loc-01 | 16 | 3 | 3 | 0 | 0 | 0 | 0 | 100% | 13 |  |
| zh-addr-01 | 29 | 1 | 1 | 0 | 0 | 0 | 0 | 100% | 12 |  |
| zh-contact-01 | 55 | 3 | 3 | 0 | 0 | 0 | 0 | 100% | 61 |  |
| zh-id-01 | 48 | 2 | 2 | 0 | 0 | 0 | 0 | 100% | 53 |  |
| zh-mixed-01 | 76 | 5 | 4 | 1 | 0 | 0 | 0 | 100% | 70 |  |
| zh-negative-01 | 22 | 0 | 0 | 0 | 0 | 0 | 0 | 100% | 8 |  |
| zh-trad-01 | 24 | 3 | 2 | 1 | 0 | 0 | 0 | 100% | 18 |  |
| en-name-01 | 60 | 2 | 2 | 0 | 0 | 0 | 0 | 100% | 19 |  |
| en-name-02 | 49 | 2 | 2 | 0 | 0 | 0 | 0 | 100% | 50 |  |
| en-name-03 | 60 | 2 | 0 | 1 | 1 | 0 | 0 | 67% | 57 | missed: ben lee |
| en-org-01 | 61 | 2 | 2 | 0 | 0 | 0 | 0 | 100% | 19 |  |
| en-loc-01 | 53 | 3 | 3 | 0 | 0 | 0 | 0 | 100% | 22 |  |
| en-addr-01 | 59 | 4 | 0 | 2 | 2 | 0 | 1 | 57% | 69 | missed: London, United Kingdom; extra: United Kingdom.(COMPANY) |
| en-contact-01 | 84 | 3 | 3 | 0 | 0 | 0 | 1 | 86% | 74 | extra: IBAN(PERSON) |
| en-id-01 | 63 | 3 | 3 | 0 | 0 | 0 | 0 | 100% | 70 |  |
| en-date-01 | 67 | 2 | 2 | 0 | 0 | 0 | 0 | 100% | 69 |  |
| en-mixed-01 | 205 | 6 | 6 | 0 | 0 | 0 | 0 | 100% | 64 |  |
| en-negative-01 | 70 | 0 | 0 | 0 | 0 | 0 | 0 | 100% | 18 |  |
| en-negative-02 | 85 | 0 | 0 | 0 | 0 | 0 | 0 | 100% | 12 |  |
| en-ocr-01 | 109 | 5 | 2 | 2 | 1 | 0 | 1 | 80% | 14 | missed: Johnson; extra: Rob ert   Johnson(PERSON) |
| fr-name-01 | 63 | 2 | 2 | 0 | 0 | 0 | 0 | 100% | 16 |  |
| fr-org-01 | 64 | 2 | 2 | 0 | 0 | 0 | 0 | 100% | 14 |  |
| fr-loc-01 | 57 | 2 | 2 | 0 | 0 | 0 | 0 | 100% | 12 |  |
| fr-contact-01 | 89 | 3 | 3 | 0 | 0 | 0 | 0 | 100% | 18 |  |
| fr-mixed-01 | 151 | 7 | 6 | 1 | 0 | 0 | 0 | 100% | 64 |  |
| fr-negative-01 | 69 | 0 | 0 | 0 | 0 | 0 | 0 | 100% | 13 |  |
| fr-business-01 | 245 | 4 | 3 | 0 | 1 | 0 | 1 | 75% | 76 | missed: 845210; extra: 202603(NUMBER) |
| es-name-01 | 66 | 2 | 2 | 0 | 0 | 0 | 0 | 100% | 13 |  |
| es-org-01 | 62 | 2 | 2 | 0 | 0 | 0 | 0 | 100% | 10 |  |
| es-loc-01 | 60 | 3 | 2 | 0 | 1 | 0 | 1 | 67% | 8 | missed: Madrid; extra: Viajó de Madrid(ADDRESS) |
| es-contact-01 | 62 | 3 | 3 | 0 | 0 | 0 | 0 | 100% | 13 |  |
| es-mixed-01 | 124 | 5 | 3 | 1 | 1 | 0 | 0 | 89% | 15 | missed: Sevilla |
| es-negative-01 | 63 | 0 | 0 | 0 | 0 | 0 | 0 | 100% | 15 |  |
| hi-name-01 | 45 | 2 | 2 | 0 | 0 | 0 | 0 | 100% | 8 |  |
| hi-org-01 | 49 | 2 | 2 | 0 | 0 | 0 | 0 | 100% | 9 |  |
| hi-loc-01 | 45 | 3 | 3 | 0 | 0 | 0 | 0 | 100% | 12 |  |
| hi-contact-01 | 50 | 2 | 2 | 0 | 0 | 0 | 0 | 100% | 61 |  |
| hi-negative-01 | 41 | 0 | 0 | 0 | 0 | 0 | 0 | 100% | 14 |  |
| de-name-01 | 54 | 3 | 3 | 0 | 0 | 0 | 0 | 100% | 12 |  |
| ja-name-01 | 26 | 3 | 3 | 0 | 0 | 0 | 0 | 100% | 15 |  |
| multi-mixed-01 | 147 | 8 | 7 | 1 | 0 | 0 | 0 | 100% | 88 |  |
| en-long-01 | 1321 | 28 | 23 | 3 | 1 | 1 | 0 | 95% | 148 | missed: Auckland; wrong type: Russell McVeagh |
| en-business-01 | 241 | 4 | 4 | 0 | 0 | 0 | 0 | 100% | 28 |  |
| zh-long-01 | 444 | 19 | 16 | 2 | 1 | 0 | 1 | 96% | 121 | missed: 阿里巴巴; extra: 阿里巴巴西溪园区三号楼会议室(ADDRESS) |
