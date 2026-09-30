# NER benchmark (device)

- Model: distilbert-base-multilingual-cased-ner-hrl
- Platform: android BP4A.251205.006.S948BXXS4AZHL, ONNX Runtime CPU via flutter_onnxruntime
- Cases: 49, expected entities: 6707
- Overall: recall 87%, precision 90%, F1 88% → reliability **B**; 92 ms per 1000 chars → speed **A**

Grades: reliability by F1 (A ≥ 90%, B ≥ 75%, C ≥ 50%, D below); speed by ms per 1000 characters on this platform (A < 300, B < 1000, C < 3000, D above).

## By language

| Language | Cases | Expected | Found | False pos. | Recall | Precision | F1 | Reliability | ms/1000 chars | Speed |
|---|---|---|---|---|---|---|---|---|---|---|
| zh | 11 | 40 | 37 | 2 | 93% | 96% | 94% | A | 181 | A |
| zh-Hant | 1 | 3 | 3 | 0 | 100% | 100% | 100% | A | 221 | A |
| en | 14 | 60 | 52 | 7 | 87% | 90% | 88% | B | 64 | A |
| fr | 6 | 16 | 14 | 0 | 88% | 100% | 93% | A | 86 | A |
| es | 6 | 15 | 14 | 1 | 93% | 93% | 93% | A | 75 | A |
| hi | 5 | 9 | 7 | 1 | 78% | 88% | 82% | B | 143 | A |
| de | 1 | 3 | 3 | 0 | 100% | 100% | 100% | A | 136 | A |
| ja | 1 | 3 | 3 | 0 | 100% | 100% | 100% | A | 241 | A |
| multi | 4 | 6558 | 5682 | 829 | 87% | 90% | 88% | B | 92 | A |

## By category

| Category | Cases | Expected | Found | False pos. | Recall | Precision | F1 | Reliability | ms/1000 chars | Speed |
|---|---|---|---|---|---|---|---|---|---|---|
| names | 12 | 27 | 25 | 0 | 93% | 100% | 96% | A | 154 | A |
| organizations | 5 | 10 | 9 | 0 | 90% | 100% | 95% | A | 100 | A |
| locations | 5 | 14 | 13 | 0 | 93% | 100% | 96% | A | 102 | A |
| addresses | 2 | 4 | 4 | 1 | 100% | 80% | 89% | B | 133 | A |
| contacts | 5 | 14 | 14 | 1 | 100% | 93% | 97% | A | 106 | A |
| identifiers | 2 | 5 | 5 | 0 | 100% | 100% | 100% | A | 111 | A |
| mixed | 5 | 31 | 26 | 2 | 84% | 93% | 88% | B | 74 | A |
| negatives | 6 | 0 | 0 | 0 | 100% | 100% | 100% | A | 107 | A |
| dates | 1 | 2 | 2 | 0 | 100% | 100% | 100% | A | 79 | A |
| noisy | 1 | 4 | 2 | 3 | 50% | 40% | 44% | D | 67 | A |
| long | 2 | 46 | 41 | 4 | 89% | 94% | 91% | A | 79 | A |
| stress | 3 | 6550 | 5674 | 829 | 87% | 90% | 88% | B | 92 | A |

## Per case

| Case | Chars | Expected | Hit | Partial | Missed | Wrong type | False pos. | F1 | ms | Notes |
|---|---|---|---|---|---|---|---|---|---|---|
| zh-name-01 | 16 | 3 | 3 | 0 | 0 | 0 | 0 | 100% | 9 |  |
| zh-name-02 | 17 | 1 | 1 | 0 | 0 | 0 | 0 | 100% | 6 |  |
| zh-name-03 | 21 | 2 | 2 | 0 | 0 | 0 | 0 | 100% | 7 |  |
| zh-org-01 | 21 | 2 | 2 | 0 | 0 | 0 | 0 | 100% | 5 |  |
| zh-loc-01 | 16 | 3 | 3 | 0 | 0 | 0 | 0 | 100% | 5 |  |
| zh-addr-01 | 29 | 1 | 1 | 0 | 0 | 0 | 0 | 100% | 6 |  |
| zh-contact-01 | 55 | 3 | 3 | 0 | 0 | 0 | 0 | 100% | 6 |  |
| zh-id-01 | 48 | 2 | 2 | 0 | 0 | 0 | 0 | 100% | 6 |  |
| zh-mixed-01 | 76 | 5 | 3 | 1 | 1 | 0 | 0 | 89% | 11 | missed: 招商银行 |
| zh-negative-01 | 22 | 0 | 0 | 0 | 0 | 0 | 0 | 100% | 5 |  |
| zh-trad-01 | 24 | 3 | 2 | 1 | 0 | 0 | 0 | 100% | 5 |  |
| en-name-01 | 60 | 2 | 2 | 0 | 0 | 0 | 0 | 100% | 6 |  |
| en-name-02 | 49 | 2 | 2 | 0 | 0 | 0 | 0 | 100% | 5 |  |
| en-name-03 | 60 | 2 | 0 | 0 | 2 | 0 | 0 | 0% | 4 | missed: aisha khan, ben lee |
| en-org-01 | 61 | 2 | 2 | 0 | 0 | 0 | 0 | 100% | 4 |  |
| en-loc-01 | 53 | 3 | 3 | 0 | 0 | 0 | 0 | 100% | 3 |  |
| en-addr-01 | 59 | 3 | 3 | 0 | 0 | 0 | 1 | 86% | 4 | extra: NW1 6XE(ADDRESS) |
| en-contact-01 | 84 | 3 | 3 | 0 | 0 | 0 | 0 | 100% | 8 |  |
| en-id-01 | 63 | 3 | 3 | 0 | 0 | 0 | 0 | 100% | 6 |  |
| en-date-01 | 67 | 2 | 2 | 0 | 0 | 0 | 0 | 100% | 5 |  |
| en-mixed-01 | 205 | 6 | 4 | 1 | 0 | 1 | 1 | 77% | 10 | wrong type: 0161 276 1234; extra: Infirmary(ADDRESS) |
| en-negative-01 | 70 | 0 | 0 | 0 | 0 | 0 | 0 | 100% | 5 |  |
| en-negative-02 | 85 | 0 | 0 | 0 | 0 | 0 | 0 | 100% | 5 |  |
| en-ocr-01 | 109 | 4 | 2 | 0 | 2 | 0 | 3 | 44% | 7 | missed: Johnson, Acme Corp oration; extra: 4471
Bill(ADDRESS), Rob ert   Johnson
Acme Corp(COMPANY), 12  High  Street(ADDRESS) |
| fr-name-01 | 63 | 2 | 2 | 0 | 0 | 0 | 0 | 100% | 7 |  |
| fr-org-01 | 64 | 2 | 2 | 0 | 0 | 0 | 0 | 100% | 5 |  |
| fr-loc-01 | 57 | 2 | 2 | 0 | 0 | 0 | 0 | 100% | 4 |  |
| fr-contact-01 | 89 | 3 | 2 | 1 | 0 | 0 | 0 | 100% | 8 |  |
| fr-mixed-01 | 151 | 7 | 4 | 1 | 2 | 0 | 0 | 83% | 10 | missed: 3 avril 1987, 1er septembre 2015 |
| fr-negative-01 | 69 | 0 | 0 | 0 | 0 | 0 | 0 | 100% | 5 |  |
| es-name-01 | 66 | 2 | 2 | 0 | 0 | 0 | 0 | 100% | 4 |  |
| es-org-01 | 62 | 2 | 2 | 0 | 0 | 0 | 0 | 100% | 4 |  |
| es-loc-01 | 60 | 3 | 3 | 0 | 0 | 0 | 0 | 100% | 4 |  |
| es-contact-01 | 62 | 3 | 3 | 0 | 0 | 0 | 0 | 100% | 6 |  |
| es-mixed-01 | 124 | 5 | 4 | 0 | 1 | 0 | 1 | 80% | 7 | missed: 20 de mayo de 2024; extra: 2024 en(ADDRESS) |
| es-negative-01 | 63 | 0 | 0 | 0 | 0 | 0 | 0 | 100% | 5 |  |
| hi-name-01 | 45 | 2 | 1 | 1 | 0 | 0 | 0 | 100% | 6 |  |
| hi-org-01 | 49 | 2 | 1 | 0 | 1 | 0 | 0 | 67% | 5 | missed: टाटा समूह |
| hi-loc-01 | 45 | 3 | 2 | 0 | 1 | 0 | 0 | 80% | 5 | missed: बेंगलुरु |
| hi-contact-01 | 50 | 2 | 2 | 0 | 0 | 0 | 1 | 80% | 6 | extra: ईमेल(COMPANY) |
| hi-negative-01 | 41 | 0 | 0 | 0 | 0 | 0 | 0 | 100% | 9 |  |
| de-name-01 | 54 | 3 | 3 | 0 | 0 | 0 | 0 | 100% | 7 |  |
| ja-name-01 | 26 | 3 | 3 | 0 | 0 | 0 | 0 | 100% | 6 |  |
| multi-mixed-01 | 147 | 8 | 8 | 0 | 0 | 0 | 0 | 100% | 13 |  |
| en-long-01 | 1321 | 28 | 24 | 1 | 2 | 1 | 2 | 90% | 70 | missed: Callaghan Innovation, NZD 4.2 million; wrong type: Russell McVeagh; extra: CFO(COMPANY), NZD(ADDRESS) |
| zh-long-01 | 444 | 18 | 12 | 4 | 2 | 0 | 2 | 91% | 67 | missed: 阿里巴巴, 深圳; extra: 9月3日(DATE), 深圳总部法务部(COMPANY) |
| stress-10k | 10004 | 313 | 236 | 37 | 26 | 14 | 26 | 88% | 827 | RSS 667 MB; missed: 1er septembre 2015×4, 75002 Paris×4, 20 de mayo de 2024×4, NZD 4.2 million×4, 阿里巴巴×4, Callaghan Innovation×3, 深圳×3; wrong type: Manchester Royal Infirmary×4, 0161 276 1234×4, Russell McVeagh×4, 深圳, Fonterra; extra: 2024 en(ADDRESS)×4, CFO(COMPANY)×4, NZD(ADDRESS)×4, 9月3日(DATE)×4, 深圳总部法务部(COMPANY)×4, Madame(PERSON)×3, 宁波(ADDRESS), 恒远(ADDRESS), 以及来自宁波恒远塑业有限公司(COMPANY) |
| stress-50k | 50076 | 1558 | 1192 | 156 | 143 | 67 | 198 | 87% | 4199 | RSS 678 MB; missed: 1er septembre 2015×21, 75002 Paris×21, 20 de mayo de 2024×20, NZD 4.2 million×20, 阿里巴巴×20, 深圳×17, Callaghan Innovation×16, El Corte Inglés×7, Priya Nair; wrong type: 0161 276 1234×21, Russell McVeagh×20, Manchester Royal Infirmary×19, 深圳×3, Priya Nair×2, Fonterra×2; extra: 2024 en(ADDRESS)×20, CFO(COMPANY)×20, Operations(COMPANY)×20, 9月3日(DATE)×20, 深圳总部法务部(COMPANY)×20, Madame(PERSON)×19, NZD(ADDRESS)×19, 检测中心(ADDRESS)×19, 分公司(COMPANY)×19, 以及来自宁波恒远塑业有限公司(COMPANY)×7, 宁波(ADDRESS)×5, 恒远(ADDRESS)×4 … +5 more |
| stress-150k | 150954 | 4679 | 3627 | 426 | 438 | 188 | 605 | 87% | 14358 | RSS 681 MB; missed: 1er septembre 2015×61, 75002 Paris×61, 20 de mayo de 2024×61, NZD 4.2 million×61, 阿里巴巴×60, 深圳×54, Callaghan Innovation×50, El Corte Inglés×21, 苏州工业园区×3, Manchester Royal Infirmary×3, Priya Nair×2, 深圳华强科技; wrong type: 0161 276 1234×61, Russell McVeagh×61, Manchester Royal Infirmary×49, Priya Nair×9, 深圳×6, Fonterra×2; extra: 2024 en(ADDRESS)×61, CFO(COMPANY)×61, Operations(COMPANY)×61, 9月3日(DATE)×60, 深圳总部法务部(COMPANY)×60, NZD(ADDRESS)×59, 分公司(COMPANY)×58, Madame(PERSON)×57, 检测中心(ADDRESS)×56, 以及来自宁波恒远塑业有限公司(COMPANY)×21, 宁波(ADDRESS)×18, 恒远(ADDRESS)×7 … +11 more |
