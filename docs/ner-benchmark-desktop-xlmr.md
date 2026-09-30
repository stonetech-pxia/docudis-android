# NER benchmark (desktop, Python onnxruntime)

- Model: xlm-roberta-base-ner-hrl
- Platform: windows "Windows 11 Famille" 10.0 (Build 26200), CPU, onnxruntime via bench_server.py
- Cases: 46, expected entities: 157
- Overall: recall 90%, precision 92%, F1 91% → reliability **A**; 140 ms per 1000 chars → speed **A**

Grades: reliability by F1 (A ≥ 90%, B ≥ 75%, C ≥ 50%, D below); speed by ms per 1000 characters on this platform (A < 300, B < 1000, C < 3000, D above).

## By language

| Language | Cases | Expected | Found | False pos. | Recall | Precision | F1 | Reliability | ms/1000 chars | Speed |
|---|---|---|---|---|---|---|---|---|---|---|
| zh | 11 | 40 | 39 | 2 | 98% | 96% | 97% | A | 215 | A |
| zh-Hant | 1 | 3 | 3 | 0 | 100% | 100% | 100% | A | 445 | B |
| en | 14 | 60 | 51 | 9 | 85% | 87% | 86% | B | 105 | A |
| fr | 6 | 16 | 13 | 0 | 81% | 100% | 90% | B | 135 | A |
| es | 6 | 15 | 13 | 2 | 87% | 88% | 87% | B | 128 | A |
| hi | 5 | 9 | 8 | 0 | 89% | 100% | 94% | A | 201 | A |
| de | 1 | 3 | 3 | 0 | 100% | 100% | 100% | A | 225 | A |
| ja | 1 | 3 | 3 | 0 | 100% | 100% | 100% | A | 448 | B |
| multi | 1 | 8 | 8 | 0 | 100% | 100% | 100% | A | 122 | A |

## By category

| Category | Cases | Expected | Found | False pos. | Recall | Precision | F1 | Reliability | ms/1000 chars | Speed |
|---|---|---|---|---|---|---|---|---|---|---|
| names | 12 | 27 | 26 | 1 | 96% | 96% | 96% | A | 277 | A |
| organizations | 5 | 10 | 8 | 0 | 80% | 100% | 89% | B | 184 | A |
| locations | 5 | 14 | 14 | 0 | 100% | 100% | 100% | A | 200 | A |
| addresses | 2 | 4 | 4 | 1 | 100% | 80% | 89% | B | 225 | A |
| contacts | 5 | 14 | 14 | 0 | 100% | 100% | 100% | A | 166 | A |
| identifiers | 2 | 5 | 5 | 1 | 100% | 83% | 91% | A | 231 | A |
| mixed | 5 | 31 | 25 | 3 | 81% | 90% | 85% | B | 103 | A |
| negatives | 6 | 0 | 0 | 0 | 100% | 100% | 100% | A | 190 | A |
| dates | 1 | 2 | 2 | 0 | 100% | 100% | 100% | A | 178 | A |
| noisy | 1 | 4 | 2 | 3 | 50% | 40% | 44% | D | 165 | A |
| long | 2 | 46 | 41 | 4 | 89% | 93% | 91% | A | 73 | A |

## Per case

| Case | Chars | Expected | Hit | Partial | Missed | Wrong type | False pos. | F1 | ms | Notes |
|---|---|---|---|---|---|---|---|---|---|---|
| zh-name-01 | 16 | 3 | 3 | 0 | 0 | 0 | 0 | 100% | 15 |  |
| zh-name-02 | 17 | 1 | 1 | 0 | 0 | 0 | 0 | 100% | 10 |  |
| zh-name-03 | 21 | 2 | 2 | 0 | 0 | 0 | 1 | 80% | 9 | extra: 销售部(COMPANY) |
| zh-org-01 | 21 | 2 | 2 | 0 | 0 | 0 | 0 | 100% | 9 |  |
| zh-loc-01 | 16 | 3 | 3 | 0 | 0 | 0 | 0 | 100% | 8 |  |
| zh-addr-01 | 29 | 1 | 1 | 0 | 0 | 0 | 0 | 100% | 9 |  |
| zh-contact-01 | 55 | 3 | 3 | 0 | 0 | 0 | 0 | 100% | 10 |  |
| zh-id-01 | 48 | 2 | 2 | 0 | 0 | 0 | 0 | 100% | 13 |  |
| zh-mixed-01 | 76 | 5 | 4 | 1 | 0 | 0 | 0 | 100% | 12 |  |
| zh-negative-01 | 22 | 0 | 0 | 0 | 0 | 0 | 0 | 100% | 9 |  |
| zh-trad-01 | 24 | 3 | 2 | 1 | 0 | 0 | 0 | 100% | 10 |  |
| en-name-01 | 60 | 2 | 2 | 0 | 0 | 0 | 0 | 100% | 14 |  |
| en-name-02 | 49 | 2 | 2 | 0 | 0 | 0 | 0 | 100% | 11 |  |
| en-name-03 | 60 | 2 | 0 | 1 | 1 | 0 | 0 | 67% | 10 | missed: ben lee |
| en-org-01 | 61 | 2 | 2 | 0 | 0 | 0 | 0 | 100% | 10 |  |
| en-loc-01 | 53 | 3 | 1 | 2 | 0 | 0 | 0 | 100% | 10 |  |
| en-addr-01 | 59 | 3 | 2 | 1 | 0 | 0 | 1 | 86% | 10 | extra: NW1 6XE(ADDRESS) |
| en-contact-01 | 84 | 3 | 3 | 0 | 0 | 0 | 0 | 100% | 14 |  |
| en-id-01 | 63 | 3 | 3 | 0 | 0 | 0 | 1 | 86% | 11 | extra: SSN(COMPANY) |
| en-date-01 | 67 | 2 | 2 | 0 | 0 | 0 | 0 | 100% | 11 |  |
| en-mixed-01 | 205 | 6 | 3 | 1 | 0 | 2 | 1 | 62% | 18 | wrong type: Manchester Royal Infirmary, 0161 276 1234; extra: NHS(COMPANY) |
| en-negative-01 | 70 | 0 | 0 | 0 | 0 | 0 | 0 | 100% | 12 |  |
| en-negative-02 | 85 | 0 | 0 | 0 | 0 | 0 | 0 | 100% | 16 |  |
| en-ocr-01 | 109 | 4 | 2 | 0 | 2 | 0 | 3 | 44% | 17 | missed: Johnson, Acme Corp oration; extra: 4471
Bill(ADDRESS), Rob ert   Johnson
Acme Corp(COMPANY), 12  High  Street(ADDRESS) |
| fr-name-01 | 63 | 2 | 2 | 0 | 0 | 0 | 0 | 100% | 15 |  |
| fr-org-01 | 64 | 2 | 1 | 0 | 1 | 0 | 0 | 67% | 9 | missed: Université de Lyon |
| fr-loc-01 | 57 | 2 | 1 | 1 | 0 | 0 | 0 | 100% | 9 |  |
| fr-contact-01 | 89 | 3 | 2 | 1 | 0 | 0 | 0 | 100% | 11 |  |
| fr-mixed-01 | 151 | 7 | 3 | 2 | 2 | 0 | 0 | 83% | 12 | missed: 3 avril 1987, 1er septembre 2015 |
| fr-negative-01 | 69 | 0 | 0 | 0 | 0 | 0 | 0 | 100% | 8 |  |
| es-name-01 | 66 | 2 | 2 | 0 | 0 | 0 | 0 | 100% | 9 |  |
| es-org-01 | 62 | 2 | 2 | 0 | 0 | 0 | 0 | 100% | 9 |  |
| es-loc-01 | 60 | 3 | 2 | 1 | 0 | 0 | 0 | 100% | 8 |  |
| es-contact-01 | 62 | 3 | 3 | 0 | 0 | 0 | 0 | 100% | 9 |  |
| es-mixed-01 | 124 | 5 | 1 | 2 | 2 | 0 | 2 | 63% | 10 | missed: El Corte Inglés, 20 de mayo de 2024; extra: Sr.(PERSON), 2024 en(ADDRESS) |
| es-negative-01 | 63 | 0 | 0 | 0 | 0 | 0 | 0 | 100% | 8 |  |
| hi-name-01 | 45 | 2 | 2 | 0 | 0 | 0 | 0 | 100% | 8 |  |
| hi-org-01 | 49 | 2 | 1 | 0 | 1 | 0 | 0 | 67% | 8 | missed: टाटा समूह |
| hi-loc-01 | 45 | 3 | 3 | 0 | 0 | 0 | 0 | 100% | 9 |  |
| hi-contact-01 | 50 | 2 | 2 | 0 | 0 | 0 | 0 | 100% | 10 |  |
| hi-negative-01 | 41 | 0 | 0 | 0 | 0 | 0 | 0 | 100% | 9 |  |
| de-name-01 | 54 | 3 | 2 | 1 | 0 | 0 | 0 | 100% | 12 |  |
| ja-name-01 | 26 | 3 | 3 | 0 | 0 | 0 | 0 | 100% | 11 |  |
| multi-mixed-01 | 147 | 8 | 8 | 0 | 0 | 0 | 0 | 100% | 17 |  |
| en-long-01 | 1321 | 28 | 16 | 8 | 4 | 0 | 3 | 88% | 75 | missed: Wellington, Sydney, Russell McVeagh, NZD 4.2 million; extra: Al-Sayed,(PERSON), Russell McVeagh.(PERSON), Margaret Chen.(PERSON) |
| zh-long-01 | 444 | 18 | 14 | 3 | 1 | 0 | 1 | 95% | 54 | missed: 阿里巴巴; extra: 9月3日(DATE) |
