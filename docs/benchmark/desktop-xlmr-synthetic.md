# NER benchmark (desktop, Python onnxruntime)

- Model: xlm-roberta-base-ner-hrl
- Platform: windows "Windows 11 Famille" 10.0 (Build 26200), CPU, onnxruntime via bench_server.py
- Cases: 45, expected entities: 928
- Overall: recall 95%, precision 100%, F1 97% → reliability **A**; 133 ms per 1000 chars → speed **A**

Grades: reliability by F1 (A ≥ 90%, B ≥ 75%, C ≥ 50%, D below); speed by ms per 1000 characters on this platform (A < 300, B < 1000, C < 3000, D above).

## By language

| Language | Cases | Expected | Found | False pos. | Recall | Precision | F1 | Reliability | ms/1000 chars | Speed |
|---|---|---|---|---|---|---|---|---|---|---|
| en | 15 | 317 | 304 | 3 | 96% | 99% | 97% | A | 117 | A |
| fr | 15 | 303 | 291 | 0 | 96% | 100% | 98% | A | 160 | A |
| es | 15 | 308 | 290 | 1 | 94% | 100% | 97% | A | 121 | A |

## By category

| Category | Cases | Expected | Found | False pos. | Recall | Precision | F1 | Reliability | ms/1000 chars | Speed |
|---|---|---|---|---|---|---|---|---|---|---|
| invoice | 9 | 195 | 190 | 0 | 97% | 100% | 99% | A | 153 | A |
| lease | 9 | 205 | 200 | 0 | 98% | 100% | 99% | A | 151 | A |
| payslip | 9 | 186 | 170 | 0 | 91% | 100% | 96% | A | 137 | A |
| medical | 9 | 198 | 182 | 4 | 92% | 98% | 95% | A | 117 | A |
| cv | 9 | 144 | 143 | 0 | 99% | 100% | 100% | A | 105 | A |

## Per case

| Case | Chars | Expected | Hit | Partial | Missed | Wrong type | False pos. | F1 | ms | Notes |
|---|---|---|---|---|---|---|---|---|---|---|
| en-syn-invoice-01 | 716 | 23 | 22 | 1 | 0 | 0 | 0 | 100% | 113 |  |
| en-syn-invoice-02 | 710 | 23 | 22 | 1 | 0 | 0 | 0 | 100% | 70 |  |
| en-syn-invoice-03 | 709 | 23 | 22 | 1 | 0 | 0 | 0 | 100% | 78 |  |
| en-syn-lease-01 | 976 | 23 | 22 | 0 | 1 | 0 | 0 | 98% | 118 | missed: TEN/1805/25 |
| en-syn-lease-02 | 983 | 24 | 23 | 0 | 1 | 0 | 0 | 98% | 110 | missed: TEN/4193/25 |
| en-syn-lease-03 | 992 | 23 | 22 | 0 | 1 | 0 | 0 | 98% | 179 | missed: TEN/9829/25 |
| en-syn-payslip-01 | 563 | 21 | 19 | 0 | 2 | 0 | 0 | 95% | 62 | missed: 537/AB76020, E-77642 |
| en-syn-payslip-02 | 561 | 21 | 19 | 0 | 2 | 0 | 0 | 95% | 63 | missed: 930/AB66683, E-64507 |
| en-syn-payslip-03 | 556 | 21 | 19 | 0 | 2 | 0 | 0 | 95% | 68 | missed: 813/AB73433, E-73441 |
| en-syn-medical-01 | 768 | 22 | 20 | 1 | 1 | 0 | 1 | 96% | 81 | missed: Darnell Whitaker; extra: Darnell Whitaker
Patient Services(COMPANY) |
| en-syn-medical-02 | 769 | 22 | 20 | 1 | 1 | 0 | 1 | 96% | 81 | missed: Naomi Adebayo; extra: Adebayo
Patient Services(COMPANY) |
| en-syn-medical-03 | 767 | 22 | 20 | 1 | 1 | 0 | 1 | 96% | 68 | missed: Olivia Pemberton; extra: Olivia Pemberton
Patient Services(COMPANY) |
| en-syn-cv-01 | 805 | 16 | 15 | 0 | 1 | 0 | 0 | 97% | 73 | missed: Brightwater Dental Practice |
| en-syn-cv-02 | 822 | 17 | 17 | 0 | 0 | 0 | 0 | 100% | 78 |  |
| en-syn-cv-03 | 809 | 16 | 16 | 0 | 0 | 0 | 0 | 100% | 92 |  |
| fr-syn-invoice-01 | 769 | 21 | 20 | 1 | 0 | 0 | 0 | 100% | 195 |  |
| fr-syn-invoice-02 | 778 | 21 | 20 | 1 | 0 | 0 | 0 | 100% | 149 |  |
| fr-syn-invoice-03 | 766 | 21 | 20 | 1 | 0 | 0 | 0 | 100% | 108 |  |
| fr-syn-lease-01 | 1028 | 22 | 21 | 0 | 1 | 0 | 0 | 98% | 158 | missed: Paris |
| fr-syn-lease-02 | 1027 | 22 | 21 | 0 | 1 | 0 | 0 | 98% | 158 | missed: Paris |
| fr-syn-lease-03 | 1023 | 22 | 22 | 0 | 0 | 0 | 0 | 100% | 152 |  |
| fr-syn-payslip-01 | 734 | 20 | 18 | 0 | 1 | 1 | 0 | 92% | 99 | missed: M-21487; wrong type: Océane Morel |
| fr-syn-payslip-02 | 720 | 20 | 19 | 0 | 1 | 0 | 0 | 97% | 137 | missed: M-45995 |
| fr-syn-payslip-03 | 713 | 20 | 19 | 0 | 1 | 0 | 0 | 97% | 134 | missed: M-07302 |
| fr-syn-medical-01 | 883 | 22 | 20 | 0 | 2 | 0 | 0 | 95% | 132 | missed: SIN-3018608, MH-32950259 |
| fr-syn-medical-02 | 884 | 22 | 20 | 0 | 2 | 0 | 0 | 95% | 152 | missed: SIN-8215638, MH-94948091 |
| fr-syn-medical-03 | 885 | 22 | 20 | 0 | 2 | 0 | 0 | 95% | 133 | missed: SIN-6106891, MH-77454568 |
| fr-syn-cv-01 | 807 | 16 | 16 | 0 | 0 | 0 | 0 | 100% | 79 |  |
| fr-syn-cv-02 | 832 | 16 | 16 | 0 | 0 | 0 | 0 | 100% | 113 |  |
| fr-syn-cv-03 | 816 | 16 | 16 | 0 | 0 | 0 | 0 | 100% | 117 |  |
| es-syn-invoice-01 | 788 | 21 | 19 | 0 | 2 | 0 | 0 | 95% | 119 | missed: Rocío Montenegro Díaz, F-2025/8337 |
| es-syn-invoice-02 | 787 | 21 | 20 | 0 | 1 | 0 | 0 | 98% | 102 | missed: F-2025/3516 |
| es-syn-invoice-03 | 798 | 21 | 19 | 0 | 2 | 0 | 0 | 95% | 104 | missed: Andrés Quintana Marín, F-2025/7673 |
| es-syn-lease-01 | 1109 | 23 | 20 | 3 | 0 | 0 | 0 | 100% | 220 |  |
| es-syn-lease-02 | 1079 | 23 | 20 | 3 | 0 | 0 | 0 | 100% | 151 |  |
| es-syn-lease-03 | 1071 | 23 | 20 | 3 | 0 | 0 | 0 | 100% | 150 |  |
| es-syn-payslip-01 | 723 | 21 | 19 | 0 | 2 | 0 | 0 | 95% | 74 | missed: 28/5950695/21, T-02328 |
| es-syn-payslip-02 | 720 | 21 | 19 | 0 | 2 | 0 | 0 | 95% | 89 | missed: 28/4150732/59, T-97390 |
| es-syn-payslip-03 | 715 | 21 | 19 | 0 | 2 | 0 | 0 | 95% | 92 | missed: 28/6203984/96, T-33119 |
| es-syn-medical-01 | 795 | 22 | 20 | 0 | 2 | 0 | 0 | 95% | 69 | missed: SIN-4845434, PS-26495076 |
| es-syn-medical-02 | 804 | 22 | 19 | 0 | 3 | 0 | 1 | 91% | 73 | missed: Carmen Iglesias Soto, SIN-4436684, PS-77925537; extra: Carmen(ADDRESS) |
| es-syn-medical-03 | 808 | 22 | 20 | 0 | 2 | 0 | 0 | 95% | 64 | missed: SIN-4750713, PS-32743940 |
| es-syn-cv-01 | 832 | 16 | 16 | 0 | 0 | 0 | 0 | 100% | 66 |  |
| es-syn-cv-02 | 833 | 16 | 16 | 0 | 0 | 0 | 0 | 100% | 81 |  |
| es-syn-cv-03 | 837 | 15 | 15 | 0 | 0 | 0 | 0 | 100% | 73 |  |
