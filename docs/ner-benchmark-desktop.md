# NER benchmark (desktop, Python onnxruntime)

- Model: distilbert-base-multilingual-cased-ner-hrl
- Platform: windows "Windows 11 Famille" 10.0 (Build 26200), CPU, onnxruntime via bench_server.py
- Cases: 46, expected entities: 157
- Overall: recall 88%, precision 94%, F1 91% → reliability **A**; 78 ms per 1000 chars → speed **A**

Grades: reliability by F1 (A ≥ 90%, B ≥ 75%, C ≥ 50%, D below); speed by ms per 1000 characters on this platform (A < 300, B < 1000, C < 3000, D above).

## By language

| Language | Cases | Expected | Found | False pos. | Recall | Precision | F1 | Reliability | ms/1000 chars | Speed |
|---|---|---|---|---|---|---|---|---|---|---|
| zh | 11 | 40 | 37 | 2 | 93% | 96% | 94% | A | 133 | A |
| zh-Hant | 1 | 3 | 3 | 0 | 100% | 100% | 100% | A | 204 | A |
| en | 14 | 60 | 51 | 7 | 85% | 90% | 87% | B | 60 | A |
| fr | 6 | 16 | 14 | 0 | 88% | 100% | 93% | A | 66 | A |
| es | 6 | 15 | 13 | 1 | 87% | 93% | 90% | B | 73 | A |
| hi | 5 | 9 | 6 | 0 | 67% | 100% | 80% | B | 97 | A |
| de | 1 | 3 | 3 | 0 | 100% | 100% | 100% | A | 104 | A |
| ja | 1 | 3 | 3 | 0 | 100% | 100% | 100% | A | 203 | A |
| multi | 1 | 8 | 8 | 0 | 100% | 100% | 100% | A | 64 | A |

## By category

| Category | Cases | Expected | Found | False pos. | Recall | Precision | F1 | Reliability | ms/1000 chars | Speed |
|---|---|---|---|---|---|---|---|---|---|---|
| names | 12 | 27 | 24 | 0 | 89% | 100% | 94% | A | 143 | A |
| organizations | 5 | 10 | 9 | 0 | 90% | 100% | 95% | A | 91 | A |
| locations | 5 | 14 | 13 | 0 | 93% | 100% | 96% | A | 102 | A |
| addresses | 2 | 4 | 4 | 1 | 100% | 80% | 89% | B | 137 | A |
| contacts | 5 | 14 | 14 | 0 | 100% | 100% | 100% | A | 95 | A |
| identifiers | 2 | 5 | 5 | 0 | 100% | 100% | 100% | A | 131 | A |
| mixed | 5 | 31 | 25 | 2 | 81% | 93% | 86% | B | 56 | A |
| negatives | 6 | 0 | 0 | 0 | 100% | 100% | 100% | A | 92 | A |
| dates | 1 | 2 | 2 | 0 | 100% | 100% | 100% | A | 128 | A |
| noisy | 1 | 4 | 2 | 3 | 50% | 40% | 44% | D | 51 | A |
| long | 2 | 46 | 40 | 4 | 87% | 94% | 90% | A | 52 | A |

## Per case

| Case | Chars | Expected | Hit | Partial | Missed | Wrong type | False pos. | F1 | ms | Notes |
|---|---|---|---|---|---|---|---|---|---|---|
| zh-name-01 | 16 | 3 | 3 | 0 | 0 | 0 | 0 | 100% | 10 |  |
| zh-name-02 | 17 | 1 | 1 | 0 | 0 | 0 | 0 | 100% | 4 |  |
| zh-name-03 | 21 | 2 | 2 | 0 | 0 | 0 | 0 | 100% | 4 |  |
| zh-org-01 | 21 | 2 | 2 | 0 | 0 | 0 | 0 | 100% | 5 |  |
| zh-loc-01 | 16 | 3 | 3 | 0 | 0 | 0 | 0 | 100% | 3 |  |
| zh-addr-01 | 29 | 1 | 1 | 0 | 0 | 0 | 0 | 100% | 5 |  |
| zh-contact-01 | 55 | 3 | 3 | 0 | 0 | 0 | 0 | 100% | 5 |  |
| zh-id-01 | 48 | 2 | 2 | 0 | 0 | 0 | 0 | 100% | 5 |  |
| zh-mixed-01 | 76 | 5 | 3 | 1 | 1 | 0 | 0 | 89% | 8 | missed: 招商银行 |
| zh-negative-01 | 22 | 0 | 0 | 0 | 0 | 0 | 0 | 100% | 4 |  |
| zh-trad-01 | 24 | 3 | 2 | 1 | 0 | 0 | 0 | 100% | 4 |  |
| en-name-01 | 60 | 2 | 2 | 0 | 0 | 0 | 0 | 100% | 6 |  |
| en-name-02 | 49 | 2 | 2 | 0 | 0 | 0 | 0 | 100% | 4 |  |
| en-name-03 | 60 | 2 | 0 | 0 | 2 | 0 | 0 | 0% | 8 | missed: aisha khan, ben lee |
| en-org-01 | 61 | 2 | 2 | 0 | 0 | 0 | 0 | 100% | 5 |  |
| en-loc-01 | 53 | 3 | 3 | 0 | 0 | 0 | 0 | 100% | 6 |  |
| en-addr-01 | 59 | 3 | 3 | 0 | 0 | 0 | 1 | 86% | 6 | extra: NW1 6XE(ADDRESS) |
| en-contact-01 | 84 | 3 | 3 | 0 | 0 | 0 | 0 | 100% | 9 |  |
| en-id-01 | 63 | 3 | 3 | 0 | 0 | 0 | 0 | 100% | 9 |  |
| en-date-01 | 67 | 2 | 2 | 0 | 0 | 0 | 0 | 100% | 8 |  |
| en-mixed-01 | 205 | 6 | 4 | 1 | 0 | 1 | 1 | 77% | 9 | wrong type: 0161 276 1234; extra: Infirmary(ADDRESS) |
| en-negative-01 | 70 | 0 | 0 | 0 | 0 | 0 | 0 | 100% | 6 |  |
| en-negative-02 | 85 | 0 | 0 | 0 | 0 | 0 | 0 | 100% | 6 |  |
| en-ocr-01 | 109 | 4 | 2 | 0 | 2 | 0 | 3 | 44% | 5 | missed: Johnson, Acme Corp oration; extra: 4471
Bill(ADDRESS), Rob ert   Johnson
Acme Corp(COMPANY), 12  High  Street(ADDRESS) |
| fr-name-01 | 63 | 2 | 2 | 0 | 0 | 0 | 0 | 100% | 6 |  |
| fr-org-01 | 64 | 2 | 2 | 0 | 0 | 0 | 0 | 100% | 4 |  |
| fr-loc-01 | 57 | 2 | 2 | 0 | 0 | 0 | 0 | 100% | 4 |  |
| fr-contact-01 | 89 | 3 | 2 | 1 | 0 | 0 | 0 | 100% | 6 |  |
| fr-mixed-01 | 151 | 7 | 4 | 1 | 2 | 0 | 0 | 83% | 5 | missed: 3 avril 1987, 1er septembre 2015 |
| fr-negative-01 | 69 | 0 | 0 | 0 | 0 | 0 | 0 | 100% | 5 |  |
| es-name-01 | 66 | 2 | 2 | 0 | 0 | 0 | 0 | 100% | 4 |  |
| es-org-01 | 62 | 2 | 2 | 0 | 0 | 0 | 0 | 100% | 4 |  |
| es-loc-01 | 60 | 3 | 3 | 0 | 0 | 0 | 0 | 100% | 4 |  |
| es-contact-01 | 62 | 3 | 3 | 0 | 0 | 0 | 0 | 100% | 6 |  |
| es-mixed-01 | 124 | 5 | 3 | 0 | 1 | 1 | 1 | 60% | 6 | missed: 20 de mayo de 2024; wrong type: El Corte Inglés; extra: 2024 en(ADDRESS) |
| es-negative-01 | 63 | 0 | 0 | 0 | 0 | 0 | 0 | 100% | 5 |  |
| hi-name-01 | 45 | 2 | 0 | 1 | 1 | 0 | 0 | 67% | 5 | missed: प्रिया वर्मा |
| hi-org-01 | 49 | 2 | 1 | 0 | 1 | 0 | 0 | 67% | 3 | missed: टाटा समूह |
| hi-loc-01 | 45 | 3 | 2 | 0 | 1 | 0 | 0 | 80% | 4 | missed: बेंगलुरु |
| hi-contact-01 | 50 | 2 | 2 | 0 | 0 | 0 | 0 | 100% | 4 |  |
| hi-negative-01 | 41 | 0 | 0 | 0 | 0 | 0 | 0 | 100% | 4 |  |
| de-name-01 | 54 | 3 | 3 | 0 | 0 | 0 | 0 | 100% | 5 |  |
| ja-name-01 | 26 | 3 | 3 | 0 | 0 | 0 | 0 | 100% | 5 |  |
| multi-mixed-01 | 147 | 8 | 7 | 1 | 0 | 0 | 0 | 100% | 9 |  |
| en-long-01 | 1321 | 28 | 23 | 1 | 2 | 2 | 2 | 87% | 47 | missed: Callaghan Innovation, NZD 4.2 million; wrong type: Priya Nair, Russell McVeagh; extra: CFO(COMPANY), NZD(ADDRESS) |
| zh-long-01 | 444 | 18 | 12 | 4 | 2 | 0 | 2 | 91% | 43 | missed: 阿里巴巴, 深圳; extra: 9月3日(DATE), 深圳总部法务部(COMPANY) |
