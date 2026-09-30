# NER benchmark (desktop, Python onnxruntime)

- Model: distilbert-base-multilingual-cased-ner-hrl
- Platform: windows "Windows 11 Famille" 10.0 (Build 26200), CPU, onnxruntime via bench_server.py
- Cases: 49, expected entities: 6707
- Overall: recall 87%, precision 90%, F1 88% → reliability **B**; 61 ms per 1000 chars → speed **A**

Grades: reliability by F1 (A ≥ 90%, B ≥ 75%, C ≥ 50%, D below); speed by ms per 1000 characters on this platform (A < 300, B < 1000, C < 3000, D above).

## By language

| Language | Cases | Expected | Found | False pos. | Recall | Precision | F1 | Reliability | ms/1000 chars | Speed |
|---|---|---|---|---|---|---|---|---|---|---|
| zh | 11 | 40 | 37 | 2 | 93% | 96% | 94% | A | 140 | A |
| zh-Hant | 1 | 3 | 3 | 0 | 100% | 100% | 100% | A | 271 | A |
| en | 14 | 60 | 51 | 7 | 85% | 90% | 87% | B | 72 | A |
| fr | 6 | 16 | 14 | 0 | 88% | 100% | 93% | A | 67 | A |
| es | 6 | 15 | 13 | 1 | 87% | 93% | 90% | B | 65 | A |
| hi | 5 | 9 | 6 | 0 | 67% | 100% | 80% | B | 83 | A |
| de | 1 | 3 | 3 | 0 | 100% | 100% | 100% | A | 92 | A |
| ja | 1 | 3 | 3 | 0 | 100% | 100% | 100% | A | 186 | A |
| multi | 4 | 6558 | 5677 | 816 | 87% | 90% | 88% | B | 61 | A |

## By category

| Category | Cases | Expected | Found | False pos. | Recall | Precision | F1 | Reliability | ms/1000 chars | Speed |
|---|---|---|---|---|---|---|---|---|---|---|
| names | 12 | 27 | 24 | 0 | 89% | 100% | 94% | A | 149 | A |
| organizations | 5 | 10 | 9 | 0 | 90% | 100% | 95% | A | 96 | A |
| locations | 5 | 14 | 13 | 0 | 93% | 100% | 96% | A | 100 | A |
| addresses | 2 | 4 | 4 | 1 | 100% | 80% | 89% | B | 152 | A |
| contacts | 5 | 14 | 14 | 0 | 100% | 100% | 100% | A | 91 | A |
| identifiers | 2 | 5 | 5 | 0 | 100% | 100% | 100% | A | 127 | A |
| mixed | 5 | 31 | 25 | 2 | 81% | 93% | 86% | B | 57 | A |
| negatives | 6 | 0 | 0 | 0 | 100% | 100% | 100% | A | 91 | A |
| dates | 1 | 2 | 2 | 0 | 100% | 100% | 100% | A | 107 | A |
| noisy | 1 | 4 | 2 | 3 | 50% | 40% | 44% | D | 73 | A |
| long | 2 | 46 | 40 | 4 | 87% | 94% | 90% | A | 65 | A |
| stress | 3 | 6550 | 5669 | 816 | 87% | 90% | 88% | B | 61 | A |

## Per case

| Case | Chars | Expected | Hit | Partial | Missed | Wrong type | False pos. | F1 | ms | Notes |
|---|---|---|---|---|---|---|---|---|---|---|
| zh-name-01 | 16 | 3 | 3 | 0 | 0 | 0 | 0 | 100% | 7 |  |
| zh-name-02 | 17 | 1 | 1 | 0 | 0 | 0 | 0 | 100% | 4 |  |
| zh-name-03 | 21 | 2 | 2 | 0 | 0 | 0 | 0 | 100% | 5 |  |
| zh-org-01 | 21 | 2 | 2 | 0 | 0 | 0 | 0 | 100% | 5 |  |
| zh-loc-01 | 16 | 3 | 3 | 0 | 0 | 0 | 0 | 100% | 4 |  |
| zh-addr-01 | 29 | 1 | 1 | 0 | 0 | 0 | 0 | 100% | 5 |  |
| zh-contact-01 | 55 | 3 | 3 | 0 | 0 | 0 | 0 | 100% | 5 |  |
| zh-id-01 | 48 | 2 | 2 | 0 | 0 | 0 | 0 | 100% | 5 |  |
| zh-mixed-01 | 76 | 5 | 3 | 1 | 1 | 0 | 0 | 89% | 9 | missed: 招商银行 |
| zh-negative-01 | 22 | 0 | 0 | 0 | 0 | 0 | 0 | 100% | 5 |  |
| zh-trad-01 | 24 | 3 | 2 | 1 | 0 | 0 | 0 | 100% | 6 |  |
| en-name-01 | 60 | 2 | 2 | 0 | 0 | 0 | 0 | 100% | 8 |  |
| en-name-02 | 49 | 2 | 2 | 0 | 0 | 0 | 0 | 100% | 9 |  |
| en-name-03 | 60 | 2 | 0 | 0 | 2 | 0 | 0 | 0% | 6 | missed: aisha khan, ben lee |
| en-org-01 | 61 | 2 | 2 | 0 | 0 | 0 | 0 | 100% | 6 |  |
| en-loc-01 | 53 | 3 | 3 | 0 | 0 | 0 | 0 | 100% | 6 |  |
| en-addr-01 | 59 | 3 | 3 | 0 | 0 | 0 | 1 | 86% | 8 | extra: NW1 6XE(ADDRESS) |
| en-contact-01 | 84 | 3 | 3 | 0 | 0 | 0 | 0 | 100% | 11 |  |
| en-id-01 | 63 | 3 | 3 | 0 | 0 | 0 | 0 | 100% | 8 |  |
| en-date-01 | 67 | 2 | 2 | 0 | 0 | 0 | 0 | 100% | 7 |  |
| en-mixed-01 | 205 | 6 | 4 | 1 | 0 | 1 | 1 | 77% | 8 | wrong type: 0161 276 1234; extra: Infirmary(ADDRESS) |
| en-negative-01 | 70 | 0 | 0 | 0 | 0 | 0 | 0 | 100% | 6 |  |
| en-negative-02 | 85 | 0 | 0 | 0 | 0 | 0 | 0 | 100% | 6 |  |
| en-ocr-01 | 109 | 4 | 2 | 0 | 2 | 0 | 3 | 44% | 7 | missed: Johnson, Acme Corp oration; extra: 4471
Bill(ADDRESS), Rob ert   Johnson
Acme Corp(COMPANY), 12  High  Street(ADDRESS) |
| fr-name-01 | 63 | 2 | 2 | 0 | 0 | 0 | 0 | 100% | 7 |  |
| fr-org-01 | 64 | 2 | 2 | 0 | 0 | 0 | 0 | 100% | 4 |  |
| fr-loc-01 | 57 | 2 | 2 | 0 | 0 | 0 | 0 | 100% | 5 |  |
| fr-contact-01 | 89 | 3 | 2 | 1 | 0 | 0 | 0 | 100% | 5 |  |
| fr-mixed-01 | 151 | 7 | 4 | 1 | 2 | 0 | 0 | 83% | 5 | missed: 3 avril 1987, 1er septembre 2015 |
| fr-negative-01 | 69 | 0 | 0 | 0 | 0 | 0 | 0 | 100% | 4 |  |
| es-name-01 | 66 | 2 | 2 | 0 | 0 | 0 | 0 | 100% | 5 |  |
| es-org-01 | 62 | 2 | 2 | 0 | 0 | 0 | 0 | 100% | 3 |  |
| es-loc-01 | 60 | 3 | 3 | 0 | 0 | 0 | 0 | 100% | 4 |  |
| es-contact-01 | 62 | 3 | 3 | 0 | 0 | 0 | 0 | 100% | 5 |  |
| es-mixed-01 | 124 | 5 | 3 | 0 | 1 | 1 | 1 | 60% | 5 | missed: 20 de mayo de 2024; wrong type: El Corte Inglés; extra: 2024 en(ADDRESS) |
| es-negative-01 | 63 | 0 | 0 | 0 | 0 | 0 | 0 | 100% | 4 |  |
| hi-name-01 | 45 | 2 | 0 | 1 | 1 | 0 | 0 | 67% | 4 | missed: प्रिया वर्मा |
| hi-org-01 | 49 | 2 | 1 | 0 | 1 | 0 | 0 | 67% | 3 | missed: टाटा समूह |
| hi-loc-01 | 45 | 3 | 2 | 0 | 1 | 0 | 0 | 80% | 3 | missed: बेंगलुरु |
| hi-contact-01 | 50 | 2 | 2 | 0 | 0 | 0 | 0 | 100% | 3 |  |
| hi-negative-01 | 41 | 0 | 0 | 0 | 0 | 0 | 0 | 100% | 3 |  |
| de-name-01 | 54 | 3 | 3 | 0 | 0 | 0 | 0 | 100% | 4 |  |
| ja-name-01 | 26 | 3 | 3 | 0 | 0 | 0 | 0 | 100% | 4 |  |
| multi-mixed-01 | 147 | 8 | 7 | 1 | 0 | 0 | 0 | 100% | 10 |  |
| en-long-01 | 1321 | 28 | 23 | 1 | 2 | 2 | 2 | 87% | 65 | missed: Callaghan Innovation, NZD 4.2 million; wrong type: Priya Nair, Russell McVeagh; extra: CFO(COMPANY), NZD(ADDRESS) |
| zh-long-01 | 444 | 18 | 12 | 4 | 2 | 0 | 2 | 91% | 49 | missed: 阿里巴巴, 深圳; extra: 9月3日(DATE), 深圳总部法务部(COMPANY) |
| stress-10k | 10004 | 313 | 237 | 36 | 27 | 13 | 23 | 89% | 632 | RSS 321 MB; missed: 1er septembre 2015×4, 75002 Paris×4, 20 de mayo de 2024×4, NZD 4.2 million×4, 阿里巴巴×4, Callaghan Innovation×3, 深圳×3, 深圳华强科技; wrong type: Manchester Royal Infirmary×4, 0161 276 1234×4, Russell McVeagh×4, 深圳; extra: 2024 en(ADDRESS)×4, CFO(COMPANY)×4, NZD(ADDRESS)×4, 9月3日(DATE)×4, 深圳总部法务部(COMPANY)×4, 宁波(ADDRESS), 恒远(ADDRESS), 以及来自宁波恒远塑业有限公司(COMPANY) |
| stress-50k | 50076 | 1558 | 1180 | 166 | 143 | 69 | 183 | 87% | 3260 | RSS 337 MB; missed: 1er septembre 2015×21, 75002 Paris×21, 20 de mayo de 2024×20, NZD 4.2 million×20, 阿里巴巴×20, Callaghan Innovation×17, 深圳×15, El Corte Inglés×3, 深圳华强科技×3, Manchester Royal Infirmary×2, 苏州工业园区; wrong type: 0161 276 1234×21, Russell McVeagh×20, Manchester Royal Infirmary×17, 深圳×5, Priya Nair×4, Fonterra×2; extra: Madame(PERSON)×21, 2024 en(ADDRESS)×20, CFO(COMPANY)×20, Operations(COMPANY)×20, 9月3日(DATE)×20, 深圳总部法务部(COMPANY)×20, NZD(ADDRESS)×19, 检测中(ADDRESS)×19, 宁波(ADDRESS)×6, 以及来自宁波恒远塑业有限公司(COMPANY)×6, 恒远(ADDRESS)×3, Manchester(ADDRESS)×2 … +7 more |
| stress-150k | 150954 | 4679 | 3621 | 429 | 430 | 199 | 610 | 86% | 8970 | RSS 364 MB; missed: 1er septembre 2015×61, 20 de mayo de 2024×61, NZD 4.2 million×61, 阿里巴巴×60, 75002 Paris×60, 深圳×49, Callaghan Innovation×49, El Corte Inglés×17, 深圳华强科技×6, 苏州工业园区×4, Manchester Royal Infirmary×2; wrong type: 0161 276 1234×61, Russell McVeagh×61, Manchester Royal Infirmary×49, Priya Nair×12, 深圳×11, Fonterra×5; extra: 2024 en(ADDRESS)×61, CFO(COMPANY)×61, Operations(COMPANY)×61, 9月3日(DATE)×60, 深圳总部法务部(COMPANY)×60, Madame(PERSON)×59, NZD(ADDRESS)×59, 分公司(COMPANY)×59, 检测中心(ADDRESS)×56, 宁波(ADDRESS)×20, 以及来自宁波恒远塑业有限公司(COMPANY)×18, 恒远(ADDRESS)×11 … +9 more |
