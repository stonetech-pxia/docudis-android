# NER benchmark (desktop, Python onnxruntime)

- Model: xlm-roberta-base-ner-docudis
- Platform: windows "Windows 11 Famille" 10.0 (Build 26200), CPU, onnxruntime via bench_server.py
- Cases: 45, expected entities: 928
- Overall: recall 91%, precision 97%, F1 94% → reliability **A**; 116 ms per 1000 chars → speed **A**

Grades: reliability by F1 (A ≥ 90%, B ≥ 75%, C ≥ 50%, D below); speed by ms per 1000 characters on this platform (A < 300, B < 1000, C < 3000, D above).

## By language

| Language | Cases | Expected | Found | False pos. | Recall | Precision | F1 | Reliability | ms/1000 chars | Speed |
|---|---|---|---|---|---|---|---|---|---|---|
| en | 15 | 317 | 242 | 26 | 76% | 91% | 83% | B | 91 | A |
| fr | 15 | 303 | 300 | 0 | 99% | 100% | 100% | A | 131 | A |
| es | 15 | 308 | 302 | 1 | 98% | 100% | 99% | A | 124 | A |

## By category

| Category | Cases | Expected | Found | False pos. | Recall | Precision | F1 | Reliability | ms/1000 chars | Speed |
|---|---|---|---|---|---|---|---|---|---|---|
| invoice | 9 | 195 | 175 | 5 | 90% | 97% | 93% | A | 170 | A |
| lease | 9 | 205 | 189 | 6 | 92% | 97% | 95% | A | 104 | A |
| payslip | 9 | 186 | 168 | 6 | 90% | 97% | 93% | A | 137 | A |
| medical | 9 | 198 | 174 | 7 | 88% | 96% | 92% | A | 101 | A |
| cv | 9 | 144 | 138 | 3 | 96% | 98% | 97% | A | 80 | A |

## Per case

| Case | Chars | Expected | Hit | Partial | Missed | Wrong type | False pos. | F1 | ms | Notes |
|---|---|---|---|---|---|---|---|---|---|---|
| en-syn-invoice-01 | 716 | 23 | 16 | 1 | 6 | 0 | 2 | 81% | 111 | missed: 27 Clarendon Street, Nottingham, NG1 5JD, 8 Orchard Close, Bristol, BS8 4TH; extra: 27 Clarendon Street, Nottingham, NG1 5JD(ADDRESS), 8 Orchard Close, Bristol, BS8 4TH(ADDRESS) |
| en-syn-invoice-02 | 710 | 23 | 16 | 2 | 5 | 0 | 1 | 86% | 87 | missed: Leeds, LS6 2QT, 59 Albert Terrace, Glasgow, G12 8RX; extra: 59 Albert Terrace, Glasgow, G12 8RX(ADDRESS) |
| en-syn-invoice-03 | 709 | 23 | 16 | 1 | 6 | 0 | 2 | 81% | 91 | missed: 112 Kingsway, Manchester, M19 1BB, 27 Clarendon Street, Nottingham, NG1 5JD; extra: 112 Kingsway, Manchester, M19 1BB(ADDRESS), 27 Clarendon Street, Nottingham, NG1 5JD(ADDRESS) |
| en-syn-lease-01 | 976 | 23 | 18 | 0 | 5 | 0 | 2 | 84% | 94 | missed: 8 Orchard Close, BS8 4TH, 112 Kingsway, Manchester, M19 1BB; extra: 8 Orchard Close, Bristol, BS8 4TH(ADDRESS), 112 Kingsway, Manchester, M19 1BB(ADDRESS) |
| en-syn-lease-02 | 983 | 24 | 18 | 0 | 6 | 0 | 2 | 82% | 83 | missed: 27 Clarendon Street, Nottingham, NG1 5JD, 112 Kingsway, Manchester, M19 1BB; extra: 27 Clarendon Street, Nottingham, NG1 5JD(ADDRESS), 112 Kingsway, Manchester, M19 1BB(ADDRESS) |
| en-syn-lease-03 | 992 | 23 | 18 | 0 | 5 | 0 | 2 | 84% | 88 | missed: 59 Albert Terrace, Glasgow, G12 8RX, 3 Priory Lane, CB4 1DT; extra: 59 Albert Terrace, Glasgow, G12 8RX(ADDRESS), 3 Priory Lane, Cambridge, CB4 1DT(ADDRESS) |
| en-syn-payslip-01 | 563 | 21 | 15 | 0 | 6 | 0 | 2 | 79% | 53 | missed: 8 Orchard Close, Bristol, BS8 4TH, 27 Clarendon Street, Nottingham, NG1 5JD; extra: 8 Orchard Close, Bristol, BS8 4TH(ADDRESS), 27 Clarendon Street, Nottingham, NG1 5JD(ADDRESS) |
| en-syn-payslip-02 | 561 | 21 | 15 | 0 | 6 | 0 | 2 | 79% | 52 | missed: 3 Priory Lane, Cambridge, CB4 1DT, 59 Albert Terrace, Glasgow, G12 8RX; extra: 3 Priory Lane, Cambridge, CB4 1DT(ADDRESS), 59 Albert Terrace, Glasgow, G12 8RX(ADDRESS) |
| en-syn-payslip-03 | 556 | 21 | 15 | 0 | 6 | 0 | 2 | 79% | 52 | missed: 59 Albert Terrace, Glasgow, G12 8RX, 3 Priory Lane, Cambridge, CB4 1DT; extra: 59 Albert Terrace, Glasgow, G12 8RX(ADDRESS), 3 Priory Lane, Cambridge, CB4 1DT(ADDRESS) |
| en-syn-medical-01 | 768 | 22 | 15 | 1 | 6 | 0 | 2 | 80% | 54 | missed: 112 Kingsway, Manchester, M19 1BB, 8 Orchard Close, Bristol, BS8 4TH; extra: 112 Kingsway, Manchester, M19 1BB(ADDRESS), 8 Orchard Close, Bristol, BS8 4TH(ADDRESS) |
| en-syn-medical-02 | 769 | 22 | 15 | 1 | 6 | 0 | 2 | 80% | 50 | missed: 59 Albert Terrace, Glasgow, G12 8RX, 8 Orchard Close, Bristol, BS8 4TH; extra: 59 Albert Terrace, Glasgow, G12 8RX(ADDRESS), 8 Orchard Close, Bristol, BS8 4TH(ADDRESS) |
| en-syn-medical-03 | 767 | 22 | 15 | 1 | 6 | 0 | 2 | 80% | 54 | missed: 27 Clarendon Street, Nottingham, NG1 5JD, 59 Albert Terrace, Glasgow, G12 8RX; extra: 27 Clarendon Street, Nottingham, NG1 5JD(ADDRESS), 59 Albert Terrace, Glasgow, G12 8RX(ADDRESS) |
| en-syn-cv-01 | 805 | 16 | 14 | 0 | 2 | 0 | 1 | 91% | 55 | missed: 27 Clarendon Street, NG1 5JD; extra: 27 Clarendon Street, Nottingham, NG1 5JD(ADDRESS) |
| en-syn-cv-02 | 822 | 17 | 14 | 0 | 3 | 0 | 1 | 88% | 62 | missed: 27 Clarendon Street, Nottingham, NG1 5JD; extra: 27 Clarendon Street, Nottingham, NG1 5JD(ADDRESS) |
| en-syn-cv-03 | 809 | 16 | 15 | 0 | 1 | 0 | 1 | 94% | 57 | missed: NG1 5JD; extra: Nottingham, NG1 5JD(ADDRESS) |
| fr-syn-invoice-01 | 769 | 21 | 21 | 0 | 0 | 0 | 0 | 100% | 147 |  |
| fr-syn-invoice-02 | 778 | 21 | 21 | 0 | 0 | 0 | 0 | 100% | 133 |  |
| fr-syn-invoice-03 | 766 | 21 | 21 | 0 | 0 | 0 | 0 | 100% | 124 |  |
| fr-syn-lease-01 | 1028 | 22 | 22 | 0 | 0 | 0 | 0 | 100% | 116 |  |
| fr-syn-lease-02 | 1027 | 22 | 22 | 0 | 0 | 0 | 0 | 100% | 119 |  |
| fr-syn-lease-03 | 1023 | 22 | 22 | 0 | 0 | 0 | 0 | 100% | 116 |  |
| fr-syn-payslip-01 | 734 | 20 | 20 | 0 | 0 | 0 | 0 | 100% | 104 |  |
| fr-syn-payslip-02 | 720 | 20 | 20 | 0 | 0 | 0 | 0 | 100% | 106 |  |
| fr-syn-payslip-03 | 713 | 20 | 20 | 0 | 0 | 0 | 0 | 100% | 110 |  |
| fr-syn-medical-01 | 883 | 22 | 21 | 0 | 1 | 0 | 0 | 98% | 129 | missed: MH-32950259 |
| fr-syn-medical-02 | 884 | 22 | 21 | 0 | 1 | 0 | 0 | 98% | 110 | missed: MH-94948091 |
| fr-syn-medical-03 | 885 | 22 | 21 | 0 | 1 | 0 | 0 | 98% | 118 | missed: MH-77454568 |
| fr-syn-cv-01 | 807 | 16 | 16 | 0 | 0 | 0 | 0 | 100% | 64 |  |
| fr-syn-cv-02 | 832 | 16 | 16 | 0 | 0 | 0 | 0 | 100% | 77 |  |
| fr-syn-cv-03 | 816 | 16 | 16 | 0 | 0 | 0 | 0 | 100% | 81 |  |
| es-syn-invoice-01 | 788 | 21 | 20 | 0 | 1 | 0 | 0 | 98% | 155 | missed: F-2025/8337 |
| es-syn-invoice-02 | 787 | 21 | 20 | 0 | 1 | 0 | 0 | 98% | 147 | missed: F-2025/3516 |
| es-syn-invoice-03 | 798 | 21 | 20 | 0 | 1 | 0 | 0 | 98% | 158 | missed: F-2025/7673 |
| es-syn-lease-01 | 1109 | 23 | 22 | 1 | 0 | 0 | 0 | 100% | 110 |  |
| es-syn-lease-02 | 1079 | 23 | 22 | 1 | 0 | 0 | 0 | 100% | 126 |  |
| es-syn-lease-03 | 1071 | 23 | 22 | 1 | 0 | 0 | 0 | 100% | 113 |  |
| es-syn-payslip-01 | 723 | 21 | 21 | 0 | 0 | 0 | 0 | 100% | 128 |  |
| es-syn-payslip-02 | 720 | 21 | 21 | 0 | 0 | 0 | 0 | 100% | 99 |  |
| es-syn-payslip-03 | 715 | 21 | 21 | 0 | 0 | 0 | 0 | 100% | 112 |  |
| es-syn-medical-01 | 795 | 22 | 20 | 1 | 1 | 0 | 1 | 95% | 78 | missed: PS-26495076; extra: Díaz(ADDRESS) |
| es-syn-medical-02 | 804 | 22 | 21 | 0 | 1 | 0 | 0 | 98% | 83 | missed: PS-77925537 |
| es-syn-medical-03 | 808 | 22 | 21 | 0 | 1 | 0 | 0 | 98% | 67 | missed: PS-32743940 |
| es-syn-cv-01 | 832 | 16 | 16 | 0 | 0 | 0 | 0 | 100% | 66 |  |
| es-syn-cv-02 | 833 | 16 | 16 | 0 | 0 | 0 | 0 | 100% | 64 |  |
| es-syn-cv-03 | 837 | 15 | 15 | 0 | 0 | 0 | 0 | 100% | 63 |  |
