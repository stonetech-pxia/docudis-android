# NER benchmark (device)

- Model: xlm-roberta-base-ner-hrl
- Platform: android BP4A.251205.006.S948BXXS4AZHL, ONNX Runtime CPU via flutter_onnxruntime
- Cases: 49, expected entities: 6707
- Overall: recall 90%, precision 93%, F1 92% → reliability **A**; 146 ms per 1000 chars → speed **A**

Grades: reliability by F1 (A ≥ 90%, B ≥ 75%, C ≥ 50%, D below); speed by ms per 1000 characters on this platform (A < 300, B < 1000, C < 3000, D above).

## By language

| Language | Cases | Expected | Found | False pos. | Recall | Precision | F1 | Reliability | ms/1000 chars | Speed |
|---|---|---|---|---|---|---|---|---|---|---|
| zh | 11 | 40 | 38 | 4 | 95% | 92% | 94% | A | 242 | A |
| zh-Hant | 1 | 3 | 3 | 0 | 100% | 100% | 100% | A | 439 | B |
| en | 14 | 60 | 54 | 6 | 90% | 91% | 91% | A | 114 | A |
| fr | 6 | 16 | 14 | 0 | 88% | 100% | 93% | A | 140 | A |
| es | 6 | 15 | 13 | 1 | 87% | 93% | 90% | B | 127 | A |
| hi | 5 | 9 | 9 | 0 | 100% | 100% | 100% | A | 165 | A |
| de | 1 | 3 | 3 | 0 | 100% | 100% | 100% | A | 175 | A |
| ja | 1 | 3 | 3 | 0 | 100% | 100% | 100% | A | 337 | B |
| multi | 4 | 6558 | 5877 | 522 | 90% | 93% | 92% | A | 146 | A |

## By category

| Category | Cases | Expected | Found | False pos. | Recall | Precision | F1 | Reliability | ms/1000 chars | Speed |
|---|---|---|---|---|---|---|---|---|---|---|
| names | 12 | 27 | 27 | 1 | 100% | 97% | 98% | A | 263 | A |
| organizations | 5 | 10 | 10 | 0 | 100% | 100% | 100% | A | 146 | A |
| locations | 5 | 14 | 14 | 0 | 100% | 100% | 100% | A | 161 | A |
| addresses | 2 | 4 | 4 | 1 | 100% | 80% | 89% | B | 218 | A |
| contacts | 5 | 14 | 14 | 0 | 100% | 100% | 100% | A | 177 | A |
| identifiers | 2 | 5 | 5 | 1 | 100% | 83% | 91% | A | 194 | A |
| mixed | 5 | 31 | 25 | 2 | 81% | 93% | 87% | B | 120 | A |
| negatives | 6 | 0 | 0 | 0 | 100% | 100% | 100% | A | 154 | A |
| dates | 1 | 2 | 2 | 0 | 100% | 100% | 100% | A | 146 | A |
| noisy | 1 | 4 | 2 | 3 | 50% | 40% | 44% | D | 121 | A |
| long | 2 | 46 | 42 | 3 | 91% | 95% | 93% | A | 110 | A |
| stress | 3 | 6550 | 5869 | 522 | 90% | 93% | 91% | A | 146 | A |

## Per case

| Case | Chars | Expected | Hit | Partial | Missed | Wrong type | False pos. | F1 | ms | Notes |
|---|---|---|---|---|---|---|---|---|---|---|
| zh-name-01 | 16 | 3 | 3 | 0 | 0 | 0 | 0 | 100% | 10 |  |
| zh-name-02 | 17 | 1 | 1 | 0 | 0 | 0 | 0 | 100% | 7 |  |
| zh-name-03 | 21 | 2 | 2 | 0 | 0 | 0 | 1 | 80% | 10 | extra: 销售部(COMPANY) |
| zh-org-01 | 21 | 2 | 2 | 0 | 0 | 0 | 0 | 100% | 7 |  |
| zh-loc-01 | 16 | 3 | 3 | 0 | 0 | 0 | 0 | 100% | 7 |  |
| zh-addr-01 | 29 | 1 | 1 | 0 | 0 | 0 | 0 | 100% | 9 |  |
| zh-contact-01 | 55 | 3 | 3 | 0 | 0 | 0 | 0 | 100% | 11 |  |
| zh-id-01 | 48 | 2 | 2 | 0 | 0 | 0 | 0 | 100% | 10 |  |
| zh-mixed-01 | 76 | 5 | 4 | 1 | 0 | 0 | 0 | 100% | 17 |  |
| zh-negative-01 | 22 | 0 | 0 | 0 | 0 | 0 | 0 | 100% | 7 |  |
| zh-trad-01 | 24 | 3 | 2 | 1 | 0 | 0 | 0 | 100% | 10 |  |
| en-name-01 | 60 | 2 | 2 | 0 | 0 | 0 | 0 | 100% | 24 |  |
| en-name-02 | 49 | 2 | 2 | 0 | 0 | 0 | 0 | 100% | 8 |  |
| en-name-03 | 60 | 2 | 2 | 0 | 0 | 0 | 0 | 100% | 13 |  |
| en-org-01 | 61 | 2 | 2 | 0 | 0 | 0 | 0 | 100% | 7 |  |
| en-loc-01 | 53 | 3 | 3 | 0 | 0 | 0 | 0 | 100% | 6 |  |
| en-addr-01 | 59 | 3 | 3 | 0 | 0 | 0 | 1 | 86% | 9 | extra: NW1 6XE(ADDRESS) |
| en-contact-01 | 84 | 3 | 3 | 0 | 0 | 0 | 0 | 100% | 14 |  |
| en-id-01 | 63 | 3 | 3 | 0 | 0 | 0 | 1 | 86% | 10 | extra: SSN(COMPANY) |
| en-date-01 | 67 | 2 | 2 | 0 | 0 | 0 | 0 | 100% | 9 |  |
| en-mixed-01 | 205 | 6 | 4 | 0 | 0 | 2 | 1 | 62% | 20 | wrong type: Manchester Royal Infirmary, 0161 276 1234; extra: NHS(COMPANY) |
| en-negative-01 | 70 | 0 | 0 | 0 | 0 | 0 | 0 | 100% | 9 |  |
| en-negative-02 | 85 | 0 | 0 | 0 | 0 | 0 | 0 | 100% | 9 |  |
| en-ocr-01 | 109 | 4 | 2 | 0 | 2 | 0 | 3 | 44% | 13 | missed: Johnson, Acme Corp oration; extra: 4471
Bill(ADDRESS), Rob ert   Johnson
Acme Corp(COMPANY), 12  High  Street(ADDRESS) |
| fr-name-01 | 63 | 2 | 2 | 0 | 0 | 0 | 0 | 100% | 13 |  |
| fr-org-01 | 64 | 2 | 2 | 0 | 0 | 0 | 0 | 100% | 8 |  |
| fr-loc-01 | 57 | 2 | 2 | 0 | 0 | 0 | 0 | 100% | 9 |  |
| fr-contact-01 | 89 | 3 | 2 | 1 | 0 | 0 | 0 | 100% | 13 |  |
| fr-mixed-01 | 151 | 7 | 4 | 1 | 2 | 0 | 0 | 83% | 14 | missed: 3 avril 1987, 1er septembre 2015 |
| fr-negative-01 | 69 | 0 | 0 | 0 | 0 | 0 | 0 | 100% | 9 |  |
| es-name-01 | 66 | 2 | 2 | 0 | 0 | 0 | 0 | 100% | 8 |  |
| es-org-01 | 62 | 2 | 2 | 0 | 0 | 0 | 0 | 100% | 7 |  |
| es-loc-01 | 60 | 3 | 3 | 0 | 0 | 0 | 0 | 100% | 6 |  |
| es-contact-01 | 62 | 3 | 3 | 0 | 0 | 0 | 0 | 100% | 10 |  |
| es-mixed-01 | 124 | 5 | 3 | 0 | 1 | 1 | 1 | 60% | 13 | missed: 20 de mayo de 2024; wrong type: El Corte Inglés; extra: 2024 en(ADDRESS) |
| es-negative-01 | 63 | 0 | 0 | 0 | 0 | 0 | 0 | 100% | 9 |  |
| hi-name-01 | 45 | 2 | 2 | 0 | 0 | 0 | 0 | 100% | 7 |  |
| hi-org-01 | 49 | 2 | 2 | 0 | 0 | 0 | 0 | 100% | 6 |  |
| hi-loc-01 | 45 | 3 | 3 | 0 | 0 | 0 | 0 | 100% | 7 |  |
| hi-contact-01 | 50 | 2 | 2 | 0 | 0 | 0 | 0 | 100% | 9 |  |
| hi-negative-01 | 41 | 0 | 0 | 0 | 0 | 0 | 0 | 100% | 7 |  |
| de-name-01 | 54 | 3 | 3 | 0 | 0 | 0 | 0 | 100% | 9 |  |
| ja-name-01 | 26 | 3 | 3 | 0 | 0 | 0 | 0 | 100% | 8 |  |
| multi-mixed-01 | 147 | 8 | 8 | 0 | 0 | 0 | 0 | 100% | 19 |  |
| en-long-01 | 1321 | 28 | 25 | 1 | 1 | 1 | 0 | 95% | 108 | missed: NZD 4.2 million; wrong type: Russell McVeagh |
| zh-long-01 | 444 | 18 | 13 | 3 | 2 | 0 | 3 | 89% | 85 | missed: 阿里巴巴, 深圳; extra: 9月3日(DATE), 深圳总部(COMPANY), 法务部(COMPANY) |
| stress-10k | 10004 | 313 | 255 | 25 | 24 | 9 | 20 | 91% | 1204 | RSS 773 MB; missed: 1er septembre 2015×4, 75002 Paris×4, 20 de mayo de 2024×4, NZD 4.2 million×4, 阿里巴巴×4, 深圳×4; wrong type: 0161 276 1234×4, Russell McVeagh×4, Manchester Royal Infirmary; extra: NHS(COMPANY)×4, 2024 en(ADDRESS)×4, 9月3日(DATE)×4, 深圳总部法务部(COMPANY)×4, Manchester(ADDRESS)×2, 以及来自宁波恒远塑业有限公司(COMPANY)×2 |
| stress-50k | 50076 | 1558 | 1280 | 116 | 119 | 43 | 110 | 91% | 6606 | RSS 704 MB; missed: 1er septembre 2015×21, 75002 Paris×21, 20 de mayo de 2024×20, NZD 4.2 million×20, 阿里巴巴×20, 深圳×12, Manchester Royal Infirmary×5; wrong type: 0161 276 1234×21, Russell McVeagh×20, Manchester Royal Infirmary×2; extra: NHS(COMPANY)×21, 2024 en(ADDRESS)×20, 9月3日(DATE)×20, 深圳总部法务部(COMPANY)×11, 以及来自宁波恒远塑业有限公司(COMPANY)×10, 法务部(COMPANY)×9, 总部(COMPANY)×8, Manchester(ADDRESS)×5, Royal(ADDRESS)×3, Manchester Royal(ADDRESS)×2, 深圳总部(COMPANY) |
| stress-150k | 150954 | 4679 | 3850 | 343 | 355 | 131 | 392 | 90% | 22982 | RSS 731 MB; missed: 1er septembre 2015×61, 75002 Paris×61, 20 de mayo de 2024×61, NZD 4.2 million×61, 阿里巴巴×60, 深圳×33, Manchester Royal Infirmary×17, El Corte Inglés; wrong type: 0161 276 1234×61, Russell McVeagh×61, Manchester Royal Infirmary×8, 深圳; extra: NHS(COMPANY)×61, 2024 en(ADDRESS)×61, Operations(PERSON)×61, 9月3日(DATE)×60, 法务部(COMPANY)×33, 以及来自宁波恒远塑业有限公司(COMPANY)×30, 深圳总部法务部(COMPANY)×24, 总部(COMPANY)×24, Manchester Royal(ADDRESS)×11, 深圳总部(COMPANY)×9, Manchester(ADDRESS)×8, Royal(ADDRESS)×6 … +2 more |
