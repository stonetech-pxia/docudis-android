# NER benchmark (desktop, Python onnxruntime)

- Model: xlm-roberta-base-ner-docudis
- Platform: windows "Windows 11 Famille" 10.0 (Build 26200), CPU, onnxruntime via bench_server.py
- Cases: 45, expected entities: 928
- Overall: recall 93%, precision 99%, F1 96% → reliability **A**; 221 ms per 1000 chars → speed **A**

Grades: reliability by F1 (A ≥ 90%, B ≥ 75%, C ≥ 50%, D below); speed by ms per 1000 characters on this platform (A < 300, B < 1000, C < 3000, D above).

## By language

| Language | Cases | Expected | Found | False pos. | Recall | Precision | F1 | Reliability | ms/1000 chars | Speed |
|---|---|---|---|---|---|---|---|---|---|---|
| en | 15 | 317 | 276 | 5 | 87% | 98% | 92% | A | 53 | A |
| fr | 15 | 303 | 294 | 0 | 97% | 100% | 98% | A | 91 | A |
| es | 15 | 308 | 293 | 0 | 95% | 100% | 98% | A | 501 | B |

## By category

| Category | Cases | Expected | Found | False pos. | Recall | Precision | F1 | Reliability | ms/1000 chars | Speed |
|---|---|---|---|---|---|---|---|---|---|---|
| invoice | 9 | 195 | 184 | 1 | 94% | 99% | 97% | A | 78 | A |
| lease | 9 | 205 | 193 | 3 | 94% | 98% | 96% | A | 245 | A |
| payslip | 9 | 186 | 165 | 0 | 89% | 100% | 94% | A | 300 | B |
| medical | 9 | 198 | 178 | 1 | 90% | 99% | 94% | A | 257 | A |
| cv | 9 | 144 | 143 | 0 | 99% | 100% | 100% | A | 221 | A |

## Per case

| Case | Chars | Expected | Hit | Partial | Missed | Wrong type | False pos. | F1 | ms | Notes |
|---|---|---|---|---|---|---|---|---|---|---|
| en-syn-invoice-01 | 716 | 23 | 18 | 3 | 2 | 0 | 0 | 95% | 56 | missed: Nottingham, Bristol |
| en-syn-invoice-02 | 710 | 23 | 18 | 3 | 2 | 0 | 0 | 95% | 39 | missed: Leeds, Glasgow |
| en-syn-invoice-03 | 709 | 23 | 17 | 2 | 4 | 0 | 1 | 88% | 37 | missed: 112 Kingsway, Manchester, M19 1BB, Nottingham; extra: 112 Kingsway, Manchester, M19 1BB(ADDRESS) |
| en-syn-lease-01 | 976 | 23 | 18 | 1 | 4 | 0 | 1 | 88% | 55 | missed: 112 Kingsway, Manchester, M19 1BB, TEN/1805/25; extra: 112 Kingsway, Manchester, M19 1BB(ADDRESS) |
| en-syn-lease-02 | 983 | 24 | 18 | 1 | 5 | 0 | 1 | 86% | 56 | missed: Nottingham, 112 Kingsway, Manchester, M19 1BB, TEN/4193/25; extra: 112 Kingsway, Manchester, M19 1BB(ADDRESS) |
| en-syn-lease-03 | 992 | 23 | 19 | 1 | 3 | 0 | 1 | 91% | 56 | missed: Glasgow, G12 8RX, TEN/9829/25; extra: Glasgow, G12 8RX(ADDRESS) |
| en-syn-payslip-01 | 563 | 21 | 15 | 2 | 4 | 0 | 0 | 89% | 32 | missed: Bristol, Nottingham, 537/AB76020, E-77642 |
| en-syn-payslip-02 | 561 | 21 | 15 | 2 | 4 | 0 | 0 | 89% | 28 | missed: Cambridge, Glasgow, 930/AB66683, E-64507 |
| en-syn-payslip-03 | 556 | 21 | 15 | 2 | 4 | 0 | 0 | 89% | 26 | missed: Glasgow, Cambridge, 813/AB73433, E-73441 |
| en-syn-medical-01 | 768 | 22 | 16 | 2 | 4 | 0 | 1 | 88% | 36 | missed: 112 Kingsway, Manchester, M19 1BB, Bristol; extra: 112 Kingsway, Manchester, M19 1BB(ADDRESS) |
| en-syn-medical-02 | 769 | 22 | 17 | 3 | 2 | 0 | 0 | 95% | 37 | missed: Glasgow, Bristol |
| en-syn-medical-03 | 767 | 22 | 17 | 3 | 2 | 0 | 0 | 95% | 33 | missed: Nottingham, Glasgow |
| en-syn-cv-01 | 805 | 16 | 15 | 1 | 0 | 0 | 0 | 100% | 37 |  |
| en-syn-cv-02 | 822 | 17 | 15 | 1 | 1 | 0 | 0 | 97% | 40 | missed: Nottingham |
| en-syn-cv-03 | 809 | 16 | 15 | 1 | 0 | 0 | 0 | 100% | 40 |  |
| fr-syn-invoice-01 | 769 | 21 | 18 | 3 | 0 | 0 | 0 | 100% | 86 |  |
| fr-syn-invoice-02 | 778 | 21 | 18 | 3 | 0 | 0 | 0 | 100% | 79 |  |
| fr-syn-invoice-03 | 766 | 21 | 18 | 3 | 0 | 0 | 0 | 100% | 75 |  |
| fr-syn-lease-01 | 1028 | 22 | 21 | 1 | 0 | 0 | 0 | 100% | 101 |  |
| fr-syn-lease-02 | 1027 | 22 | 22 | 0 | 0 | 0 | 0 | 100% | 106 |  |
| fr-syn-lease-03 | 1023 | 22 | 20 | 2 | 0 | 0 | 0 | 100% | 100 |  |
| fr-syn-payslip-01 | 734 | 20 | 17 | 2 | 1 | 0 | 0 | 97% | 68 | missed: M-21487 |
| fr-syn-payslip-02 | 720 | 20 | 17 | 2 | 1 | 0 | 0 | 97% | 59 | missed: M-45995 |
| fr-syn-payslip-03 | 713 | 20 | 17 | 2 | 1 | 0 | 0 | 97% | 65 | missed: M-07302 |
| fr-syn-medical-01 | 883 | 22 | 18 | 2 | 2 | 0 | 0 | 95% | 92 | missed: SIN-3018608, MH-32950259 |
| fr-syn-medical-02 | 884 | 22 | 18 | 2 | 2 | 0 | 0 | 95% | 92 | missed: SIN-8215638, MH-94948091 |
| fr-syn-medical-03 | 885 | 22 | 18 | 2 | 2 | 0 | 0 | 95% | 95 | missed: SIN-6106891, MH-77454568 |
| fr-syn-cv-01 | 807 | 16 | 16 | 0 | 0 | 0 | 0 | 100% | 45 |  |
| fr-syn-cv-02 | 832 | 16 | 16 | 0 | 0 | 0 | 0 | 100% | 43 |  |
| fr-syn-cv-03 | 816 | 16 | 15 | 1 | 0 | 0 | 0 | 100% | 44 |  |
| es-syn-invoice-01 | 788 | 21 | 18 | 2 | 1 | 0 | 0 | 98% | 55 | missed: F-2025/8337 |
| es-syn-invoice-02 | 787 | 21 | 18 | 2 | 1 | 0 | 0 | 98% | 51 | missed: F-2025/3516 |
| es-syn-invoice-03 | 798 | 21 | 18 | 2 | 1 | 0 | 0 | 98% | 46 | missed: F-2025/7673 |
| es-syn-lease-01 | 1109 | 23 | 21 | 2 | 0 | 0 | 0 | 100% | 128 |  |
| es-syn-lease-02 | 1079 | 23 | 22 | 1 | 0 | 0 | 0 | 100% | 851 |  |
| es-syn-lease-03 | 1071 | 23 | 22 | 1 | 0 | 0 | 0 | 100% | 820 |  |
| es-syn-payslip-01 | 723 | 21 | 17 | 2 | 2 | 0 | 0 | 95% | 612 | missed: 28/5950695/21, T-02328 |
| es-syn-payslip-02 | 720 | 21 | 17 | 2 | 2 | 0 | 0 | 95% | 466 | missed: 28/4150732/59, T-97390 |
| es-syn-payslip-03 | 715 | 21 | 17 | 2 | 2 | 0 | 0 | 95% | 444 | missed: 28/6203984/96, T-33119 |
| es-syn-medical-01 | 795 | 22 | 18 | 2 | 2 | 0 | 0 | 95% | 509 | missed: SIN-4845434, PS-26495076 |
| es-syn-medical-02 | 804 | 22 | 18 | 2 | 2 | 0 | 0 | 95% | 490 | missed: SIN-4436684, PS-77925537 |
| es-syn-medical-03 | 808 | 22 | 18 | 2 | 2 | 0 | 0 | 95% | 501 | missed: SIN-4750713, PS-32743940 |
| es-syn-cv-01 | 832 | 16 | 15 | 1 | 0 | 0 | 0 | 100% | 415 |  |
| es-syn-cv-02 | 833 | 16 | 15 | 1 | 0 | 0 | 0 | 100% | 462 |  |
| es-syn-cv-03 | 837 | 15 | 14 | 1 | 0 | 0 | 0 | 100% | 502 |  |
