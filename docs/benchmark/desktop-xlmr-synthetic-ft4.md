# NER benchmark (desktop, Python onnxruntime)

- Model: xlm-roberta-base-ner-docudis
- Platform: windows "Windows 11 Famille" 10.0 (Build 26200), CPU, onnxruntime via bench_server.py
- Cases: 45, expected entities: 928
- Overall: recall 96%, precision 99%, F1 97% → reliability **A**; 76 ms per 1000 chars → speed **A**

Grades: reliability by F1 (A ≥ 90%, B ≥ 75%, C ≥ 50%, D below); speed by ms per 1000 characters on this platform (A < 300, B < 1000, C < 3000, D above).

## By language

| Language | Cases | Expected | Found | False pos. | Recall | Precision | F1 | Reliability | ms/1000 chars | Speed |
|---|---|---|---|---|---|---|---|---|---|---|
| en | 15 | 317 | 285 | 5 | 90% | 98% | 94% | A | 62 | A |
| fr | 15 | 303 | 300 | 0 | 99% | 100% | 100% | A | 89 | A |
| es | 15 | 308 | 302 | 1 | 98% | 100% | 99% | A | 75 | A |

## By category

| Category | Cases | Expected | Found | False pos. | Recall | Precision | F1 | Reliability | ms/1000 chars | Speed |
|---|---|---|---|---|---|---|---|---|---|---|
| invoice | 9 | 195 | 184 | 1 | 94% | 99% | 97% | A | 109 | A |
| lease | 9 | 205 | 197 | 2 | 96% | 99% | 98% | A | 72 | A |
| payslip | 9 | 186 | 180 | 0 | 97% | 100% | 98% | A | 86 | A |
| medical | 9 | 198 | 184 | 2 | 93% | 99% | 96% | A | 70 | A |
| cv | 9 | 144 | 142 | 1 | 99% | 99% | 99% | A | 48 | A |

## Per case

| Case | Chars | Expected | Hit | Partial | Missed | Wrong type | False pos. | F1 | ms | Notes |
|---|---|---|---|---|---|---|---|---|---|---|
| en-syn-invoice-01 | 716 | 23 | 18 | 3 | 2 | 0 | 0 | 95% | 77 | missed: Nottingham, Bristol |
| en-syn-invoice-02 | 710 | 23 | 18 | 3 | 2 | 0 | 0 | 95% | 67 | missed: Leeds, Glasgow |
| en-syn-invoice-03 | 709 | 23 | 17 | 2 | 4 | 0 | 1 | 88% | 66 | missed: 112 Kingsway, Manchester, M19 1BB, Nottingham; extra: 112 Kingsway, Manchester, M19 1BB(ADDRESS) |
| en-syn-lease-01 | 976 | 23 | 19 | 1 | 3 | 0 | 1 | 91% | 58 | missed: 112 Kingsway, Manchester, M19 1BB; extra: 112 Kingsway, Manchester, M19 1BB(ADDRESS) |
| en-syn-lease-02 | 983 | 24 | 19 | 1 | 4 | 0 | 1 | 89% | 55 | missed: Nottingham, 112 Kingsway, Manchester, M19 1BB; extra: 112 Kingsway, Manchester, M19 1BB(ADDRESS) |
| en-syn-lease-03 | 992 | 23 | 20 | 2 | 1 | 0 | 0 | 98% | 56 | missed: Glasgow |
| en-syn-payslip-01 | 563 | 21 | 17 | 2 | 2 | 0 | 0 | 95% | 35 | missed: Bristol, Nottingham |
| en-syn-payslip-02 | 561 | 21 | 17 | 2 | 2 | 0 | 0 | 95% | 39 | missed: Cambridge, Glasgow |
| en-syn-payslip-03 | 556 | 21 | 17 | 2 | 2 | 0 | 0 | 95% | 33 | missed: Glasgow, Cambridge |
| en-syn-medical-01 | 768 | 22 | 16 | 2 | 4 | 0 | 1 | 88% | 39 | missed: 112 Kingsway, Manchester, M19 1BB, Bristol; extra: 112 Kingsway, Manchester, M19 1BB(ADDRESS) |
| en-syn-medical-02 | 769 | 22 | 17 | 3 | 2 | 0 | 0 | 95% | 36 | missed: Glasgow, Bristol |
| en-syn-medical-03 | 767 | 22 | 17 | 3 | 2 | 0 | 0 | 95% | 40 | missed: Nottingham, Glasgow |
| en-syn-cv-01 | 805 | 16 | 15 | 1 | 0 | 0 | 0 | 100% | 34 |  |
| en-syn-cv-02 | 822 | 17 | 15 | 1 | 1 | 0 | 0 | 97% | 35 | missed: Nottingham |
| en-syn-cv-03 | 809 | 16 | 15 | 0 | 1 | 0 | 1 | 94% | 36 | missed: NG1 5JD; extra: Nottingham, NG1 5JD(ADDRESS) |
| fr-syn-invoice-01 | 769 | 21 | 19 | 2 | 0 | 0 | 0 | 100% | 93 |  |
| fr-syn-invoice-02 | 778 | 21 | 19 | 2 | 0 | 0 | 0 | 100% | 88 |  |
| fr-syn-invoice-03 | 766 | 21 | 19 | 2 | 0 | 0 | 0 | 100% | 91 |  |
| fr-syn-lease-01 | 1028 | 22 | 22 | 0 | 0 | 0 | 0 | 100% | 86 |  |
| fr-syn-lease-02 | 1027 | 22 | 21 | 1 | 0 | 0 | 0 | 100% | 75 |  |
| fr-syn-lease-03 | 1023 | 22 | 20 | 2 | 0 | 0 | 0 | 100% | 88 |  |
| fr-syn-payslip-01 | 734 | 20 | 18 | 2 | 0 | 0 | 0 | 100% | 70 |  |
| fr-syn-payslip-02 | 720 | 20 | 18 | 2 | 0 | 0 | 0 | 100% | 77 |  |
| fr-syn-payslip-03 | 713 | 20 | 18 | 2 | 0 | 0 | 0 | 100% | 71 |  |
| fr-syn-medical-01 | 883 | 22 | 19 | 2 | 1 | 0 | 0 | 98% | 91 | missed: MH-32950259 |
| fr-syn-medical-02 | 884 | 22 | 19 | 2 | 1 | 0 | 0 | 98% | 82 | missed: MH-94948091 |
| fr-syn-medical-03 | 885 | 22 | 19 | 2 | 1 | 0 | 0 | 98% | 81 | missed: MH-77454568 |
| fr-syn-cv-01 | 807 | 16 | 16 | 0 | 0 | 0 | 0 | 100% | 43 |  |
| fr-syn-cv-02 | 832 | 16 | 16 | 0 | 0 | 0 | 0 | 100% | 44 |  |
| fr-syn-cv-03 | 816 | 16 | 16 | 0 | 0 | 0 | 0 | 100% | 39 |  |
| es-syn-invoice-01 | 788 | 21 | 18 | 2 | 1 | 0 | 0 | 98% | 86 | missed: F-2025/8337 |
| es-syn-invoice-02 | 787 | 21 | 18 | 2 | 1 | 0 | 0 | 98% | 82 | missed: F-2025/3516 |
| es-syn-invoice-03 | 798 | 21 | 18 | 2 | 1 | 0 | 0 | 98% | 86 | missed: F-2025/7673 |
| es-syn-lease-01 | 1109 | 23 | 21 | 2 | 0 | 0 | 0 | 100% | 78 |  |
| es-syn-lease-02 | 1079 | 23 | 22 | 1 | 0 | 0 | 0 | 100% | 92 |  |
| es-syn-lease-03 | 1071 | 23 | 23 | 0 | 0 | 0 | 0 | 100% | 80 |  |
| es-syn-payslip-01 | 723 | 21 | 19 | 2 | 0 | 0 | 0 | 100% | 71 |  |
| es-syn-payslip-02 | 720 | 21 | 19 | 2 | 0 | 0 | 0 | 100% | 57 |  |
| es-syn-payslip-03 | 715 | 21 | 19 | 2 | 0 | 0 | 0 | 100% | 55 |  |
| es-syn-medical-01 | 795 | 22 | 18 | 3 | 1 | 0 | 1 | 95% | 44 | missed: PS-26495076; extra: Díaz(ADDRESS) |
| es-syn-medical-02 | 804 | 22 | 19 | 2 | 1 | 0 | 0 | 98% | 50 | missed: PS-77925537 |
| es-syn-medical-03 | 808 | 22 | 19 | 2 | 1 | 0 | 0 | 98% | 47 | missed: PS-32743940 |
| es-syn-cv-01 | 832 | 16 | 15 | 1 | 0 | 0 | 0 | 100% | 42 |  |
| es-syn-cv-02 | 833 | 16 | 16 | 0 | 0 | 0 | 0 | 100% | 40 |  |
| es-syn-cv-03 | 837 | 15 | 14 | 1 | 0 | 0 | 0 | 100% | 36 |  |
