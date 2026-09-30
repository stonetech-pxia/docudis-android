# NER benchmark (desktop, Python onnxruntime)

- Model: xlm-roberta-base-ner-docudis
- Platform: windows "Windows 11 Famille" 10.0 (Build 26200), CPU, onnxruntime via bench_server.py
- Cases: 63, expected entities: 0
- Overall: recall 100%, precision 0%, F1 0% → reliability **D**; 91 ms per 1000 chars → speed **A**

Grades: reliability by F1 (A ≥ 90%, B ≥ 75%, C ≥ 50%, D below); speed by ms per 1000 characters on this platform (A < 300, B < 1000, C < 3000, D above).

## By language

| Language | Cases | Expected | Found | False pos. | Recall | Precision | F1 | Reliability | ms/1000 chars | Speed |
|---|---|---|---|---|---|---|---|---|---|---|
| en | 21 | 0 | 0 | 0 | 100% | 100% | 100% | A | 89 | A |
| fr | 21 | 0 | 0 | 0 | 100% | 100% | 100% | A | 94 | A |
| es | 21 | 0 | 0 | 1 | 100% | 0% | 0% | D | 90 | A |

## By category

| Category | Cases | Expected | Found | False pos. | Recall | Precision | F1 | Reliability | ms/1000 chars | Speed |
|---|---|---|---|---|---|---|---|---|---|---|
| negatives | 18 | 0 | 0 | 1 | 100% | 0% | 0% | D | 76 | A |
| name-words | 45 | 0 | 0 | 0 | 100% | 100% | 100% | A | 102 | A |

## Per case

| Case | Chars | Expected | Hit | Partial | Missed | Wrong type | False pos. | F1 | ms | Notes |
|---|---|---|---|---|---|---|---|---|---|---|
| en-neg-years | 189 | 0 | 0 | 0 | 0 | 0 | 0 | 100% | 17 |  |
| en-neg-versions | 181 | 0 | 0 | 0 | 0 | 0 | 0 | 100% | 13 |  |
| en-neg-units | 202 | 0 | 0 | 0 | 0 | 0 | 0 | 100% | 16 |  |
| en-neg-form | 220 | 0 | 0 | 0 | 0 | 0 | 0 | 100% | 14 |  |
| en-neg-ranges | 165 | 0 | 0 | 0 | 0 | 0 | 0 | 100% | 14 |  |
| en-neg-words | 201 | 0 | 0 | 0 | 0 | 0 | 0 | 100% | 13 |  |
| fr-neg-years | 190 | 0 | 0 | 0 | 0 | 0 | 0 | 100% | 16 |  |
| fr-neg-table | 228 | 0 | 0 | 0 | 0 | 0 | 0 | 100% | 13 |  |
| fr-neg-versions | 158 | 0 | 0 | 0 | 0 | 0 | 0 | 100% | 12 |  |
| fr-neg-form | 225 | 0 | 0 | 0 | 0 | 0 | 0 | 100% | 14 |  |
| fr-neg-units | 172 | 0 | 0 | 0 | 0 | 0 | 0 | 100% | 22 |  |
| fr-neg-words | 203 | 0 | 0 | 0 | 0 | 0 | 0 | 100% | 16 |  |
| es-neg-years | 184 | 0 | 0 | 0 | 0 | 0 | 0 | 100% | 14 |  |
| es-neg-table | 242 | 0 | 0 | 0 | 0 | 0 | 0 | 100% | 12 |  |
| es-neg-versions | 162 | 0 | 0 | 0 | 0 | 0 | 0 | 100% | 15 |  |
| es-neg-form | 238 | 0 | 0 | 0 | 0 | 0 | 0 | 100% | 14 |  |
| es-neg-units | 164 | 0 | 0 | 0 | 0 | 0 | 0 | 100% | 12 |  |
| es-neg-words | 237 | 0 | 0 | 0 | 0 | 0 | 1 | 0% | 15 | extra: C. Domicilio(PERSON) |
| en-nameword-01 | 112 | 0 | 0 | 0 | 0 | 0 | 0 | 100% | 12 |  |
| en-nameword-02 | 120 | 0 | 0 | 0 | 0 | 0 | 0 | 100% | 10 |  |
| en-nameword-03 | 110 | 0 | 0 | 0 | 0 | 0 | 0 | 100% | 11 |  |
| en-nameword-04 | 118 | 0 | 0 | 0 | 0 | 0 | 0 | 100% | 10 |  |
| en-nameword-05 | 128 | 0 | 0 | 0 | 0 | 0 | 0 | 100% | 12 |  |
| en-nameword-06 | 67 | 0 | 0 | 0 | 0 | 0 | 0 | 100% | 8 |  |
| en-nameword-07 | 92 | 0 | 0 | 0 | 0 | 0 | 0 | 100% | 9 |  |
| en-nameword-08 | 116 | 0 | 0 | 0 | 0 | 0 | 0 | 100% | 10 |  |
| en-nameword-09 | 108 | 0 | 0 | 0 | 0 | 0 | 0 | 100% | 11 |  |
| en-nameword-10 | 125 | 0 | 0 | 0 | 0 | 0 | 0 | 100% | 10 |  |
| en-nameword-11 | 92 | 0 | 0 | 0 | 0 | 0 | 0 | 100% | 9 |  |
| en-nameword-12 | 95 | 0 | 0 | 0 | 0 | 0 | 0 | 100% | 9 |  |
| en-nameword-13 | 111 | 0 | 0 | 0 | 0 | 0 | 0 | 100% | 10 |  |
| en-nameword-14 | 131 | 0 | 0 | 0 | 0 | 0 | 0 | 100% | 10 |  |
| en-nameword-15 | 120 | 0 | 0 | 0 | 0 | 0 | 0 | 100% | 11 |  |
| fr-nameword-01 | 100 | 0 | 0 | 0 | 0 | 0 | 0 | 100% | 14 |  |
| fr-nameword-02 | 94 | 0 | 0 | 0 | 0 | 0 | 0 | 100% | 9 |  |
| fr-nameword-03 | 89 | 0 | 0 | 0 | 0 | 0 | 0 | 100% | 9 |  |
| fr-nameword-04 | 97 | 0 | 0 | 0 | 0 | 0 | 0 | 100% | 10 |  |
| fr-nameword-05 | 137 | 0 | 0 | 0 | 0 | 0 | 0 | 100% | 11 |  |
| fr-nameword-06 | 105 | 0 | 0 | 0 | 0 | 0 | 0 | 100% | 10 |  |
| fr-nameword-07 | 70 | 0 | 0 | 0 | 0 | 0 | 0 | 100% | 9 |  |
| fr-nameword-08 | 122 | 0 | 0 | 0 | 0 | 0 | 0 | 100% | 10 |  |
| fr-nameword-09 | 107 | 0 | 0 | 0 | 0 | 0 | 0 | 100% | 10 |  |
| fr-nameword-10 | 105 | 0 | 0 | 0 | 0 | 0 | 0 | 100% | 9 |  |
| fr-nameword-11 | 79 | 0 | 0 | 0 | 0 | 0 | 0 | 100% | 9 |  |
| fr-nameword-12 | 91 | 0 | 0 | 0 | 0 | 0 | 0 | 100% | 10 |  |
| fr-nameword-13 | 124 | 0 | 0 | 0 | 0 | 0 | 0 | 100% | 10 |  |
| fr-nameword-14 | 115 | 0 | 0 | 0 | 0 | 0 | 0 | 100% | 11 |  |
| fr-nameword-15 | 114 | 0 | 0 | 0 | 0 | 0 | 0 | 100% | 11 |  |
| es-nameword-01 | 97 | 0 | 0 | 0 | 0 | 0 | 0 | 100% | 13 |  |
| es-nameword-02 | 108 | 0 | 0 | 0 | 0 | 0 | 0 | 100% | 10 |  |
| es-nameword-03 | 71 | 0 | 0 | 0 | 0 | 0 | 0 | 100% | 9 |  |
| es-nameword-04 | 90 | 0 | 0 | 0 | 0 | 0 | 0 | 100% | 10 |  |
| es-nameword-05 | 114 | 0 | 0 | 0 | 0 | 0 | 0 | 100% | 10 |  |
| es-nameword-06 | 115 | 0 | 0 | 0 | 0 | 0 | 0 | 100% | 10 |  |
| es-nameword-07 | 101 | 0 | 0 | 0 | 0 | 0 | 0 | 100% | 10 |  |
| es-nameword-08 | 65 | 0 | 0 | 0 | 0 | 0 | 0 | 100% | 9 |  |
| es-nameword-09 | 80 | 0 | 0 | 0 | 0 | 0 | 0 | 100% | 9 |  |
| es-nameword-10 | 88 | 0 | 0 | 0 | 0 | 0 | 0 | 100% | 10 |  |
| es-nameword-11 | 82 | 0 | 0 | 0 | 0 | 0 | 0 | 100% | 9 |  |
| es-nameword-12 | 101 | 0 | 0 | 0 | 0 | 0 | 0 | 100% | 10 |  |
| es-nameword-13 | 81 | 0 | 0 | 0 | 0 | 0 | 0 | 100% | 9 |  |
| es-nameword-14 | 106 | 0 | 0 | 0 | 0 | 0 | 0 | 100% | 9 |  |
| es-nameword-15 | 103 | 0 | 0 | 0 | 0 | 0 | 0 | 100% | 9 |  |
