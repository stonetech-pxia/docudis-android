# NER benchmark (desktop, Python onnxruntime)

- Model: xlm-roberta-base-ner-docudis
- Platform: windows "Windows 11 Famille" 10.0 (Build 26200), CPU, onnxruntime via bench_server.py
- Cases: 45, expected entities: 928
- Overall: recall 93%, precision 99%, F1 96% → reliability **A**; 60 ms per 1000 chars → speed **A**

Grades: reliability by F1 (A ≥ 90%, B ≥ 75%, C ≥ 50%, D below); speed by ms per 1000 characters on this platform (A < 300, B < 1000, C < 3000, D above).

## By language

| Language | Cases | Expected | Found | False pos. | Recall | Precision | F1 | Reliability | ms/1000 chars | Speed |
|---|---|---|---|---|---|---|---|---|---|---|
| en | 15 | 317 | 277 | 4 | 87% | 99% | 93% | A | 52 | A |
| fr | 15 | 303 | 293 | 3 | 97% | 99% | 98% | A | 72 | A |
| es | 15 | 308 | 293 | 0 | 95% | 100% | 98% | A | 56 | A |

## By category

| Category | Cases | Expected | Found | False pos. | Recall | Precision | F1 | Reliability | ms/1000 chars | Speed |
|---|---|---|---|---|---|---|---|---|---|---|
| invoice | 9 | 195 | 184 | 1 | 94% | 99% | 97% | A | 65 | A |
| lease | 9 | 205 | 194 | 5 | 95% | 97% | 96% | A | 68 | A |
| payslip | 9 | 186 | 165 | 0 | 89% | 100% | 94% | A | 60 | A |
| medical | 9 | 198 | 178 | 1 | 90% | 99% | 94% | A | 61 | A |
| cv | 9 | 144 | 142 | 0 | 99% | 100% | 99% | A | 46 | A |

## Per case

| Case | Chars | Expected | Hit | Partial | Missed | Wrong type | False pos. | F1 | ms | Notes |
|---|---|---|---|---|---|---|---|---|---|---|
| en-syn-invoice-01 | 716 | 23 | 18 | 3 | 2 | 0 | 0 | 95% | 53 | missed: Nottingham, Bristol |
| en-syn-invoice-02 | 710 | 23 | 18 | 3 | 2 | 0 | 0 | 95% | 38 | missed: Leeds, Glasgow |
| en-syn-invoice-03 | 709 | 23 | 17 | 2 | 4 | 0 | 1 | 88% | 38 | missed: 112 Kingsway, Manchester, M19 1BB, Nottingham; extra: 112 Kingsway, Manchester, M19 1BB(ADDRESS) |
| en-syn-lease-01 | 976 | 23 | 18 | 1 | 4 | 0 | 1 | 88% | 54 | missed: 112 Kingsway, Manchester, M19 1BB, TEN/1805/25; extra: 112 Kingsway, Manchester, M19 1BB(ADDRESS) |
| en-syn-lease-02 | 983 | 24 | 18 | 1 | 5 | 0 | 1 | 86% | 53 | missed: Nottingham, 112 Kingsway, Manchester, M19 1BB, TEN/4193/25; extra: 112 Kingsway, Manchester, M19 1BB(ADDRESS) |
| en-syn-lease-03 | 992 | 23 | 19 | 2 | 2 | 0 | 0 | 95% | 61 | missed: Glasgow, TEN/9829/25 |
| en-syn-payslip-01 | 563 | 21 | 15 | 2 | 4 | 0 | 0 | 89% | 29 | missed: Bristol, Nottingham, 537/AB76020, E-77642 |
| en-syn-payslip-02 | 561 | 21 | 15 | 2 | 4 | 0 | 0 | 89% | 28 | missed: Cambridge, Glasgow, 930/AB66683, E-64507 |
| en-syn-payslip-03 | 556 | 21 | 15 | 2 | 4 | 0 | 0 | 89% | 27 | missed: Glasgow, Cambridge, 813/AB73433, E-73441 |
| en-syn-medical-01 | 768 | 22 | 16 | 2 | 4 | 0 | 1 | 88% | 33 | missed: 112 Kingsway, Manchester, M19 1BB, Bristol; extra: 112 Kingsway, Manchester, M19 1BB(ADDRESS) |
| en-syn-medical-02 | 769 | 22 | 17 | 3 | 2 | 0 | 0 | 95% | 34 | missed: Glasgow, Bristol |
| en-syn-medical-03 | 767 | 22 | 17 | 3 | 2 | 0 | 0 | 95% | 33 | missed: Nottingham, Glasgow |
| en-syn-cv-01 | 805 | 16 | 15 | 1 | 0 | 0 | 0 | 100% | 33 |  |
| en-syn-cv-02 | 822 | 17 | 15 | 1 | 1 | 0 | 0 | 97% | 35 | missed: Nottingham |
| en-syn-cv-03 | 809 | 16 | 15 | 1 | 0 | 0 | 0 | 100% | 36 |  |
| fr-syn-invoice-01 | 769 | 21 | 18 | 3 | 0 | 0 | 0 | 100% | 70 |  |
| fr-syn-invoice-02 | 778 | 21 | 18 | 3 | 0 | 0 | 0 | 100% | 60 |  |
| fr-syn-invoice-03 | 766 | 21 | 18 | 3 | 0 | 0 | 0 | 100% | 53 |  |
| fr-syn-lease-01 | 1028 | 22 | 20 | 2 | 0 | 0 | 1 | 98% | 78 | extra: LOGEMENT VIDE(COMPANY) |
| fr-syn-lease-02 | 1027 | 22 | 21 | 1 | 0 | 0 | 1 | 98% | 76 | extra: LOGEMENT VIDE(COMPANY) |
| fr-syn-lease-03 | 1023 | 22 | 21 | 1 | 0 | 0 | 1 | 98% | 80 | extra: LOGEMENT VIDE(COMPANY) |
| fr-syn-payslip-01 | 734 | 20 | 17 | 2 | 1 | 0 | 0 | 97% | 51 | missed: M-21487 |
| fr-syn-payslip-02 | 720 | 20 | 17 | 2 | 1 | 0 | 0 | 97% | 57 | missed: M-45995 |
| fr-syn-payslip-03 | 713 | 20 | 17 | 2 | 1 | 0 | 0 | 97% | 52 | missed: M-07302 |
| fr-syn-medical-01 | 883 | 22 | 18 | 2 | 2 | 0 | 0 | 95% | 72 | missed: SIN-3018608, MH-32950259 |
| fr-syn-medical-02 | 884 | 22 | 18 | 2 | 2 | 0 | 0 | 95% | 70 | missed: SIN-8215638, MH-94948091 |
| fr-syn-medical-03 | 885 | 22 | 18 | 2 | 2 | 0 | 0 | 95% | 72 | missed: SIN-6106891, MH-77454568 |
| fr-syn-cv-01 | 807 | 16 | 16 | 0 | 0 | 0 | 0 | 100% | 39 |  |
| fr-syn-cv-02 | 832 | 16 | 15 | 0 | 1 | 0 | 0 | 97% | 37 | missed: INSA Lyon |
| fr-syn-cv-03 | 816 | 16 | 16 | 0 | 0 | 0 | 0 | 100% | 43 |  |
| es-syn-invoice-01 | 788 | 21 | 18 | 2 | 1 | 0 | 0 | 98% | 42 | missed: F-2025/8337 |
| es-syn-invoice-02 | 787 | 21 | 18 | 2 | 1 | 0 | 0 | 98% | 41 | missed: F-2025/3516 |
| es-syn-invoice-03 | 798 | 21 | 18 | 2 | 1 | 0 | 0 | 98% | 43 | missed: F-2025/7673 |
| es-syn-lease-01 | 1109 | 23 | 21 | 2 | 0 | 0 | 0 | 100% | 78 |  |
| es-syn-lease-02 | 1079 | 23 | 22 | 1 | 0 | 0 | 0 | 100% | 86 |  |
| es-syn-lease-03 | 1071 | 23 | 22 | 1 | 0 | 0 | 0 | 100% | 63 |  |
| es-syn-payslip-01 | 723 | 21 | 17 | 2 | 2 | 0 | 0 | 95% | 38 | missed: 28/5950695/21, T-02328 |
| es-syn-payslip-02 | 720 | 21 | 17 | 2 | 2 | 0 | 0 | 95% | 38 | missed: 28/4150732/59, T-97390 |
| es-syn-payslip-03 | 715 | 21 | 17 | 2 | 2 | 0 | 0 | 95% | 36 | missed: 28/6203984/96, T-33119 |
| es-syn-medical-01 | 795 | 22 | 18 | 2 | 2 | 0 | 0 | 95% | 42 | missed: SIN-4845434, PS-26495076 |
| es-syn-medical-02 | 804 | 22 | 18 | 2 | 2 | 0 | 0 | 95% | 43 | missed: SIN-4436684, PS-77925537 |
| es-syn-medical-03 | 808 | 22 | 18 | 2 | 2 | 0 | 0 | 95% | 45 | missed: SIN-4750713, PS-32743940 |
| es-syn-cv-01 | 832 | 16 | 15 | 1 | 0 | 0 | 0 | 100% | 38 |  |
| es-syn-cv-02 | 833 | 16 | 15 | 1 | 0 | 0 | 0 | 100% | 38 |  |
| es-syn-cv-03 | 837 | 15 | 15 | 0 | 0 | 0 | 0 | 100% | 35 |  |
