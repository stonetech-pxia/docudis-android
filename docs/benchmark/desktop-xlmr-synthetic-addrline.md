# NER benchmark (desktop, Python onnxruntime)

- Model: xlm-roberta-base-ner-docudis
- Platform: windows "Windows 11 Famille" 10.0 (Build 26200), CPU, onnxruntime via bench_server.py
- Cases: 45, expected entities: 928
- Overall: recall 96%, precision 99%, F1 97% → reliability **A**; 183 ms per 1000 chars → speed **A**

Grades: reliability by F1 (A ≥ 90%, B ≥ 75%, C ≥ 50%, D below); speed by ms per 1000 characters on this platform (A < 300, B < 1000, C < 3000, D above).

## By language

| Language | Cases | Expected | Found | False pos. | Recall | Precision | F1 | Reliability | ms/1000 chars | Speed |
|---|---|---|---|---|---|---|---|---|---|---|
| en | 15 | 317 | 285 | 5 | 90% | 98% | 94% | A | 214 | A |
| fr | 15 | 303 | 300 | 0 | 99% | 100% | 100% | A | 147 | A |
| es | 15 | 308 | 302 | 1 | 98% | 100% | 99% | A | 190 | A |

## By category

| Category | Cases | Expected | Found | False pos. | Recall | Precision | F1 | Reliability | ms/1000 chars | Speed |
|---|---|---|---|---|---|---|---|---|---|---|
| invoice | 9 | 195 | 184 | 1 | 94% | 99% | 97% | A | 185 | A |
| lease | 9 | 205 | 197 | 2 | 96% | 99% | 98% | A | 192 | A |
| payslip | 9 | 186 | 180 | 0 | 97% | 100% | 98% | A | 213 | A |
| medical | 9 | 198 | 184 | 2 | 93% | 99% | 96% | A | 184 | A |
| cv | 9 | 144 | 142 | 1 | 99% | 99% | 99% | A | 143 | A |

## Per case

| Case | Chars | Expected | Hit | Partial | Missed | Wrong type | False pos. | F1 | ms | Notes |
|---|---|---|---|---|---|---|---|---|---|---|
| en-syn-invoice-01 | 716 | 23 | 18 | 3 | 2 | 0 | 0 | 95% | 188 | missed: Nottingham, Bristol |
| en-syn-invoice-02 | 710 | 23 | 18 | 3 | 2 | 0 | 0 | 95% | 109 | missed: Leeds, Glasgow |
| en-syn-invoice-03 | 709 | 23 | 17 | 2 | 4 | 0 | 1 | 88% | 114 | missed: 112 Kingsway, Manchester, M19 1BB, Nottingham; extra: 112 Kingsway, Manchester, M19 1BB(ADDRESS) |
| en-syn-lease-01 | 976 | 23 | 19 | 1 | 3 | 0 | 1 | 91% | 348 | missed: 112 Kingsway, Manchester, M19 1BB; extra: 112 Kingsway, Manchester, M19 1BB(ADDRESS) |
| en-syn-lease-02 | 983 | 24 | 19 | 1 | 4 | 0 | 1 | 89% | 362 | missed: Nottingham, 112 Kingsway, Manchester, M19 1BB; extra: 112 Kingsway, Manchester, M19 1BB(ADDRESS) |
| en-syn-lease-03 | 992 | 23 | 20 | 2 | 1 | 0 | 0 | 98% | 189 | missed: Glasgow |
| en-syn-payslip-01 | 563 | 21 | 17 | 2 | 2 | 0 | 0 | 95% | 116 | missed: Bristol, Nottingham |
| en-syn-payslip-02 | 561 | 21 | 17 | 2 | 2 | 0 | 0 | 95% | 139 | missed: Cambridge, Glasgow |
| en-syn-payslip-03 | 556 | 21 | 17 | 2 | 2 | 0 | 0 | 95% | 146 | missed: Glasgow, Cambridge |
| en-syn-medical-01 | 768 | 22 | 16 | 2 | 4 | 0 | 1 | 88% | 192 | missed: 112 Kingsway, Manchester, M19 1BB, Bristol; extra: 112 Kingsway, Manchester, M19 1BB(ADDRESS) |
| en-syn-medical-02 | 769 | 22 | 17 | 3 | 2 | 0 | 0 | 95% | 128 | missed: Glasgow, Bristol |
| en-syn-medical-03 | 767 | 22 | 17 | 3 | 2 | 0 | 0 | 95% | 114 | missed: Nottingham, Glasgow |
| en-syn-cv-01 | 805 | 16 | 15 | 1 | 0 | 0 | 0 | 100% | 66 |  |
| en-syn-cv-02 | 822 | 17 | 15 | 1 | 1 | 0 | 0 | 97% | 61 | missed: Nottingham |
| en-syn-cv-03 | 809 | 16 | 15 | 0 | 1 | 0 | 1 | 94% | 186 | missed: NG1 5JD; extra: Nottingham, NG1 5JD(ADDRESS) |
| fr-syn-invoice-01 | 769 | 21 | 19 | 2 | 0 | 0 | 0 | 100% | 158 |  |
| fr-syn-invoice-02 | 778 | 21 | 19 | 2 | 0 | 0 | 0 | 100% | 110 |  |
| fr-syn-invoice-03 | 766 | 21 | 19 | 2 | 0 | 0 | 0 | 100% | 96 |  |
| fr-syn-lease-01 | 1028 | 22 | 21 | 1 | 0 | 0 | 0 | 100% | 79 |  |
| fr-syn-lease-02 | 1027 | 22 | 20 | 2 | 0 | 0 | 0 | 100% | 89 |  |
| fr-syn-lease-03 | 1023 | 22 | 19 | 3 | 0 | 0 | 0 | 100% | 71 |  |
| fr-syn-payslip-01 | 734 | 20 | 18 | 2 | 0 | 0 | 0 | 100% | 80 |  |
| fr-syn-payslip-02 | 720 | 20 | 18 | 2 | 0 | 0 | 0 | 100% | 72 |  |
| fr-syn-payslip-03 | 713 | 20 | 18 | 2 | 0 | 0 | 0 | 100% | 72 |  |
| fr-syn-medical-01 | 883 | 22 | 18 | 3 | 1 | 0 | 0 | 98% | 232 | missed: MH-32950259 |
| fr-syn-medical-02 | 884 | 22 | 18 | 3 | 1 | 0 | 0 | 98% | 93 | missed: MH-94948091 |
| fr-syn-medical-03 | 885 | 22 | 18 | 3 | 1 | 0 | 0 | 98% | 216 | missed: MH-77454568 |
| fr-syn-cv-01 | 807 | 16 | 16 | 0 | 0 | 0 | 0 | 100% | 232 |  |
| fr-syn-cv-02 | 832 | 16 | 16 | 0 | 0 | 0 | 0 | 100% | 138 |  |
| fr-syn-cv-03 | 816 | 16 | 16 | 0 | 0 | 0 | 0 | 100% | 113 |  |
| es-syn-invoice-01 | 788 | 21 | 18 | 2 | 1 | 0 | 0 | 98% | 145 | missed: F-2025/8337 |
| es-syn-invoice-02 | 787 | 21 | 18 | 2 | 1 | 0 | 0 | 98% | 187 | missed: F-2025/3516 |
| es-syn-invoice-03 | 798 | 21 | 18 | 2 | 1 | 0 | 0 | 98% | 150 | missed: F-2025/7673 |
| es-syn-lease-01 | 1109 | 23 | 20 | 3 | 0 | 0 | 0 | 100% | 199 |  |
| es-syn-lease-02 | 1079 | 23 | 21 | 2 | 0 | 0 | 0 | 100% | 288 |  |
| es-syn-lease-03 | 1071 | 23 | 22 | 1 | 0 | 0 | 0 | 100% | 151 |  |
| es-syn-payslip-01 | 723 | 21 | 19 | 2 | 0 | 0 | 0 | 100% | 129 |  |
| es-syn-payslip-02 | 720 | 21 | 19 | 2 | 0 | 0 | 0 | 100% | 311 |  |
| es-syn-payslip-03 | 715 | 21 | 19 | 2 | 0 | 0 | 0 | 100% | 209 |  |
| es-syn-medical-01 | 795 | 22 | 18 | 3 | 1 | 0 | 1 | 95% | 176 | missed: PS-26495076; extra: Díaz(ADDRESS) |
| es-syn-medical-02 | 804 | 22 | 19 | 2 | 1 | 0 | 0 | 98% | 74 | missed: PS-77925537 |
| es-syn-medical-03 | 808 | 22 | 19 | 2 | 1 | 0 | 0 | 98% | 129 | missed: PS-32743940 |
| es-syn-cv-01 | 832 | 16 | 15 | 1 | 0 | 0 | 0 | 100% | 101 |  |
| es-syn-cv-02 | 833 | 16 | 16 | 0 | 0 | 0 | 0 | 100% | 102 |  |
| es-syn-cv-03 | 837 | 15 | 14 | 1 | 0 | 0 | 0 | 100% | 54 |  |
