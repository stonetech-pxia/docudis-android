# NER benchmark (desktop, Python onnxruntime)

- Model: xlm-roberta-base-ner-docudis
- Platform: windows "Windows 11 Famille" 10.0 (Build 26200), CPU, onnxruntime via bench_server.py
- Cases: 60, expected entities: 2145
- Overall: recall 89%, precision 94%, F1 91% → reliability **A**; 503 ms per 1000 chars → speed **B**

Grades: reliability by F1 (A ≥ 90%, B ≥ 75%, C ≥ 50%, D below); speed by ms per 1000 characters on this platform (A < 300, B < 1000, C < 3000, D above).

## By language

| Language | Cases | Expected | Found | False pos. | Recall | Precision | F1 | Reliability | ms/1000 chars | Speed |
|---|---|---|---|---|---|---|---|---|---|---|
| en | 20 | 737 | 645 | 44 | 88% | 95% | 91% | A | 181 | A |
| es | 20 | 652 | 588 | 41 | 90% | 95% | 92% | A | 644 | B |
| fr | 20 | 756 | 673 | 67 | 89% | 92% | 91% | A | 688 | B |

## By category

| Category | Cases | Expected | Found | False pos. | Recall | Precision | F1 | Reliability | ms/1000 chars | Speed |
|---|---|---|---|---|---|---|---|---|---|---|
| bank | 6 | 174 | 149 | 14 | 86% | 92% | 89% | B | 503 | B |
| chat | 6 | 77 | 69 | 12 | 90% | 91% | 90% | A | 556 | B |
| cv | 6 | 244 | 214 | 32 | 88% | 90% | 89% | B | 427 | B |
| insurance | 6 | 308 | 273 | 11 | 89% | 97% | 92% | A | 431 | B |
| invoice | 6 | 302 | 263 | 20 | 87% | 95% | 91% | A | 457 | B |
| lease | 6 | 241 | 211 | 14 | 88% | 95% | 91% | A | 508 | B |
| letter | 6 | 196 | 184 | 7 | 94% | 97% | 95% | A | 432 | B |
| medical | 6 | 228 | 211 | 13 | 93% | 95% | 94% | A | 521 | B |
| payslip | 6 | 195 | 168 | 9 | 86% | 95% | 91% | A | 634 | B |
| support | 6 | 180 | 164 | 20 | 91% | 91% | 91% | A | 640 | B |

## Per case

| Case | Chars | Expected | Hit | Partial | Missed | Wrong type | False pos. | F1 | ms | Notes |
|---|---|---|---|---|---|---|---|---|---|---|
| en-bank-01 | 2033 | 39 | 31 | 2 | 6 | 0 | 1 | 90% | 123 | missed: NatWest, Bristol, NWBKGB2L, SVL-002931-AM, England, 929027; extra: NatWest
Premier Banking(COMPANY) |
| en-bank-02 | 865 | 22 | 15 | 3 | 4 | 0 | 3 | 84% | 59 | missed: WT260910-004418, 7702, CHASUS33, 0817; extra: Wire Services(COMPANY), Airstream(COMPANY), FDIC(COMPANY) |
| en-chat-01 | 952 | 21 | 20 | 0 | 1 | 0 | 4 | 93% | 63 | missed: 14 Birchfield Court, Evington Road, Leicester LE2 1HJ; extra: van(PERSON)×2, flat is 14 Birchfield Court, Evington Road, Leicester (ADDRESS), van mans(PERSON) |
| en-chat-02 | 470 | 10 | 7 | 0 | 3 | 0 | 2 | 76% | 27 | missed: dana, halvorsen, reggie; extra: brightwater(ADDRESS), ping dana(PERSON) |
| en-cv-01 | 3677 | 40 | 32 | 2 | 6 | 0 | 8 | 84% | 175 | missed: RN298417, AACN, Byrdine F. Lewis College of Nursing, Sigma Theta Tau, Hôpital Saint-Michel, Jacmel, Haiti; extra: ACLS(COMPANY), BLS(COMPANY), CLABSI(COMPANY), Byrdine(ADDRESS), 12/2027)(DATE), Hôpital Saint-Michel, Jacmel, Haiti(ADDRESS), Philips IntelliVue(COMPANY), Alaris(ADDRESS) |
| en-cv-02 | 2742 | 34 | 28 | 3 | 2 | 1 | 2 | 92% | 140 | missed: Tesco, Unit 9, Kings Weston Trade Park, Avonmouth, Bristol BS11 8AZ; wrong type: St John Ambulance; extra: Tesco Distribution(COMPANY), City(ADDRESS) |
| en-insurance-01 | 4270 | 71 | 55 | 3 | 12 | 1 | 2 | 88% | 217 | missed: Aviva, NIDH001/MTR, 7 Cois Cuain, Bearna, Co. Galway, 211-G-4827, 408213, Premium Credit, 3308, 6120, C48213, 318842; wrong type: 02/11/1985; extra: 7 Cois Cuain
                 Bearna(ADDRESS), Aviva 24-hour claims(COMPANY) |
| en-insurance-02 | 2210 | 41 | 32 | 4 | 5 | 0 | 0 | 94% | 122 | missed: Ecclesall, PLM/SHF/118264, 4402, Scotland, SC002116 |
| en-invoice-01 | 2150 | 46 | 33 | 4 | 9 | 0 | 3 | 86% | 113 | missed: Leeds, 612884, 047731, OD-24781, J/2026/0319, Q-1187, WISNIEWSKA, England, Wales; extra: Worcester(COMPANY), 24781 WISNIEWSKA(ADDRESS), O&D Building Services Ltd.(COMPANY) |
| en-invoice-02 | 4444 | 59 | 46 | 5 | 8 | 0 | 0 | 93% | 240 | missed: 10287, P.O. Box 660418, Dallas, TX 75266-0418, 1554, $0.098700, Oncor, $0.025510, 13.9 cents, 2217 LARKSPUR TRL APT 1406 PLANO TX 75074 |
| en-lease-01 | 4358 | 45 | 38 | 1 | 6 | 0 | 3 | 91% | 226 | missed: UT482913, RK170652, 1184 Neil Avenue, Apt. 2C, Columbus, OH 43201, pay.hallgrenpm.com, AEP Ohio, Columbus, OH 43215; extra: Section(ADDRESS)×2, Rules(COMPANY) |
| en-lease-02 | 977 | 21 | 17 | 2 | 2 | 0 | 0 | 95% | 62 | missed: 0214, 17 Cnoc na Cathrach, Knocknacarra, Galway, H91 T2RV |
| en-letter-01 | 2190 | 42 | 41 | 0 | 1 | 0 | 1 | 98% | 120 | missed: HWL/NAR58-2/0319; extra: FIRST CLASS POST(COMPANY) |
| en-letter-02 | 2168 | 29 | 25 | 2 | 2 | 0 | 1 | 95% | 123 | missed: Leeds, Mehta; extra: rose(PERSON) |
| en-medical-01 | 4464 | 53 | 44 | 5 | 4 | 0 | 3 | 94% | 251 | missed: Leeds Teaching Hospitals NHS Trust, St James's University Hospital, Leeds, 80-2214; extra: The Leeds Teaching Hospitals NHS Trust
St James's University Hospital(COMPANY), June 2026(DATE), Clinic C(COMPANY) |
| en-medical-02 | 1438 | 30 | 24 | 4 | 2 | 0 | 2 | 94% | 810 | missed: Mylan, 14D2087315; extra: 00378-1805(ADDRESS), Mylan    Discard(PERSON) |
| en-payslip-01 | 3821 | 38 | 34 | 1 | 3 | 0 | 2 | 93% | 2041 | missed: $27.4500, Alliant Credit Union, xxxxxx9026; extra: Illinois(ADDRESS), +1       86.50(NUMBER) |
| en-payslip-02 | 1275 | 29 | 21 | 1 | 7 | 0 | 0 | 86% | 1089 | missed: HARCASTLE JOINERY, Loughborough, 567/HA41207, 004417, 20-49, 3817, England |
| en-support-01 | 2759 | 42 | 38 | 1 | 3 | 0 | 7 | 90% | 1876 | missed: K7XQ2M, 9901, England; extra: BA1393(ID)×4, Mastercard(COMPANY)×2, Terminal 5(ADDRESS) |
| en-support-02 | 1470 | 25 | 20 | 1 | 4 | 0 | 0 | 91% | 946 | missed: Apartment 12, Millrace Court, Old Kilmainham, Dublin 8, D08 X4K7, Tomasz, AIB, 4471 |
| es-bank-01 | 2148 | 37 | 31 | 2 | 4 | 0 | 1 | 93% | 1478 | missed: CG/2026/08831, 4410, Vallès Occidental, A-156980; extra: 0417 Terrassa(ADDRESS) |
| es-bank-02 | 942 | 19 | 16 | 1 | 2 | 0 | 2 | 90% | 778 | missed: ABANCA, ES62 5533 **** **** **** 0127; extra: ABANCA Avisos(COMPANY), Oficina 0417(ADDRESS) |
| es-chat-01 | 926 | 14 | 13 | 1 | 0 | 0 | 1 | 98% | 864 | extra: iban(PERSON) |
| es-chat-02 | 441 | 9 | 8 | 0 | 1 | 0 | 0 | 94% | 308 | missed: grupo alcor |
| es-cv-01 | 3673 | 48 | 40 | 3 | 5 | 0 | 10 | 87% | 2216 | missed: Zamudio (Bizkaia), 4,3 M€, Coslada (Madrid), Bermeo (Bizkaia), CS-48-02291; extra: Suministro(COMPANY), 2020-2021(NUMBER), 2008-2013(NUMBER), 2011-2012(NUMBER), 2013-2015(NUMBER), Cámara de Comercio de Bilbao(COMPANY), 05/2028(DATE), Lanbide(COMPANY), Cambridge(COMPANY), 2026(DATE) |
| es-cv-02 | 2268 | 29 | 24 | 3 | 2 | 0 | 3 | 93% | 1308 | missed: Pereira, Colombia, Aula de Cata Ribera Alta; extra: 11/2027(DATE), INAEM(COMPANY), Revo(PERSON) |
| es-insurance-01 | 4026 | 53 | 44 | 4 | 5 | 0 | 3 | 93% | 2332 | missed: 7G-48-210.556.931, J-2841, 4817 LKM, VSSZZZKLZNR041877, MU-80.417; extra: Consorcio de Compensación de Seguros(COMPANY), Seguros y Reaseguros. Entidad(COMPANY), General de Seguros y Fondos de Pensiones. Santamaría Ortuño Correduría de Seguros, S.L.(COMPANY) |
| es-insurance-02 | 2170 | 33 | 26 | 5 | 2 | 0 | 2 | 94% | 1347 | missed: 2026/HG/0381746, ES90 8200 **** **** **** 4820; extra: Turia Hogar Plus(COMPANY), Aseguradora Turia, S.A. de Seguros y Reaseguros. Inscrita(COMPANY) |
| es-invoice-01 | 1987 | 26 | 20 | 1 | 5 | 0 | 2 | 86% | 1345 | missed: C/ Telletxe, 12, bajo · 48991 Getxo (Bizkaia), 2026/0187, P-26/0412, 48/IF-02917, RC-3307419; extra: FRA 2026(ID), 02917 (Gobierno Vasco)(ADDRESS) |
| es-invoice-02 | 4391 | 65 | 49 | 7 | 9 | 0 | 1 | 92% | 2643 | missed: 0,083921 €, 0,012575 €, 0,189450 €, 0,142310 €, 0,098760 €, 0,026630 €, 0,012742 €, ES60 2368 **** **** **** 4146, Apartado de Correos 4127, 50080 Zaragoza; extra: Correos(COMPANY) |
| es-lease-01 | 4441 | 57 | 45 | 5 | 6 | 1 | 2 | 92% | 3050 | missed: M-561932, 684, 0847612VK4704H0012RT, 31.877, MV38-B42, M-662.480; wrong type: Canal de Isabel II; extra: I. Que Berzosa Anguita Patrimonio, S.L.(COMPANY), p.p. Berzosa Anguita Patrimonio, S.L.(COMPANY) |
| es-lease-02 | 989 | 24 | 22 | 1 | 1 | 0 | 1 | 96% | 923 | missed: C/ El Peso 27, 1º, 14900 Lucena (Córdoba); extra: DE ALQUILER Nº 47(COMPANY) |
| es-letter-01 | 2075 | 33 | 31 | 0 | 2 | 0 | 1 | 96% | 1243 | missed: 3.412, ATL-2026/0381; extra: DESTINATARIO(COMPANY) |
| es-letter-02 | 2105 | 26 | 25 | 1 | 0 | 0 | 1 | 99% | 1283 | extra: Pilar(ADDRESS) |
| es-medical-01 | 4463 | 40 | 32 | 3 | 5 | 0 | 3 | 90% | 2995 | missed: 36208 Vigo (Pontevedra), 2026/0457713, Costel Munteanu, 36/3607152, 36/3611894; extra: Vigo
Hospital Álvaro Cunqueiro(COMPANY), cardiaca(COMPANY), Cardiaca(COMPANY) |
| es-medical-02 | 1350 | 21 | 16 | 2 | 3 | 0 | 0 | 92% | 921 | missed: 50/5012874, LABORATORIO IBARZ, 50/5017306 |
| es-payslip-01 | 4002 | 35 | 29 | 1 | 5 | 0 | 1 | 91% | 2264 | missed: Trabanca, 36/1048827/83, 00412, Rúa Ourense, 9, 2º esq. - 36630 Cambados (Pontevedra), PO-31.906; extra: Planta de Trabanca(COMPANY) |
| es-payslip-02 | 1557 | 26 | 21 | 2 | 3 | 0 | 1 | 92% | 1162 | missed: EMBUTIDOS Y SALAZONES, 09/1048823/61, A. M. Ciobanu; extra: C.I(COMPANY) |
| es-support-01 | 2731 | 37 | 34 | 0 | 2 | 1 | 6 | 89% | 1646 | missed: 08841527, 8036; wrong type: QK7M2D; extra: QK7M2D(ADDRESS)×3, Mastercard(COMPANY)×2, AVE(COMPANY) |
| es-support-02 | 1474 | 20 | 18 | 2 | 0 | 0 | 0 | 100% | 920 |  |
| fr-bank-01 | 2050 | 38 | 28 | 3 | 7 | 0 | 2 | 88% | 1340 | missed: Bayonne Saint-Esprit, Bât. C - Appt 27, BSE/RC/2026-09/1184, 30857, 70037, 77, AGRIFRPP869; extra: Agence de Bayonne Saint-Esprit(COMPANY)×2 |
| fr-bank-02 | 899 | 19 | 13 | 4 | 2 | 0 | 5 | 84% | 716 | missed: CIC, FR76 8457 **** **** **** **31 349; extra: SEPA(PERSON)×3, Agence Schiltigheim Centre(COMPANY), CIC Schiltigheim Centre(COMPANY) |
| fr-chat-01 | 965 | 14 | 10 | 1 | 2 | 1 | 5 | 80% | 774 | missed: jo, 3e etage; wrong type: leclerc; extra: jai(PERSON)×2, karim sil(PERSON), quil(PERSON), Momo(COMPANY) |
| fr-chat-02 | 413 | 9 | 9 | 0 | 0 | 0 | 0 | 100% | 280 |  |
| fr-cv-01 | 3471 | 57 | 46 | 2 | 7 | 2 | 7 | 85% | 2357 | missed: 4,2 M€, Pays basque, ETCHEVERRY Maitena, AFTRAL, IUT de Bordeaux, IUT de Bayonne et du Pays basque, Ustaritz; wrong type: Irun, Pampelune; extra: 64)(ADDRESS)×2, Micro-entreprise ETCHEVERRY Maitena(COMPANY), SIRET(ADDRESS), AFTRAL Bordeaux(COMPANY), TOEIC(COMPANY), Leroy Merlin Mérignac(PERSON) |
| fr-cv-02 | 2307 | 36 | 30 | 1 | 2 | 3 | 2 | 87% | 1546 | missed: Nord vaudois, Suisse; wrong type: Bulle, Morat, Guin; extra: 2022-2024(NUMBER), 2015          Cours de chef d'équipe(ADDRESS) |
| fr-insurance-01 | 4012 | 71 | 59 | 5 | 7 | 0 | 2 | 94% | 2597 | missed: MMA, GH-482-LQ, CEPAFRPP382, MMA-AU7482913C-001, Le Mans, 775 652 126, 440 048 882; extra: RCS Le Mans 775 652 126(ID), RCS Le Mans 440 048 882(ID) |
| fr-insurance-02 | 2190 | 39 | 31 | 5 | 3 | 0 | 2 | 94% | 1514 | missed: Bât. C - 3e étage - Appt 32, 2026-DDE-0738214, appt 42; extra: Multirisque Habitation Sérénité(COMPANY), Habitation

MASO Assurances(COMPANY) |
| fr-invoice-01 | 2142 | 41 | 32 | 6 | 3 | 0 | 3 | 93% | 1499 | missed: 4402817, CMBRFR2BXXX, 833 304 132; extra: Atlantic(COMPANY), EURL(ADDRESS), RCS Quimper 833 304 132(ID) |
| fr-invoice-02 | 4038 | 65 | 47 | 13 | 5 | 0 | 11 | 90% | 2905 | missed: RESIDENCE LE BELVEDERE BAT A APPT 207, FR76 6193 **** **** **** **52 384, Libre réponse n° 59252, 75443 Paris Cedex 09, TSA 70233 - 34967 Montpellier Cedex 2, 619 326 754; extra: BELVEDERE(COMPANY), Linky(PERSON), GONCALVES PEREIRA
IBAN(PERSON), LUMIO(COMPANY), pleines  48(ADDRESS), Dépannage électricité Enedis(COMPANY), 34967 Montpellier Cedex 2.(ADDRESS), 75443 Paris Cedex 09.(ADDRESS), TALON(ADDRESS), IBAN(PERSON), RCS Montpellier 619 326 754(ID) |
| fr-lease-01 | 4331 | 71 | 51 | 6 | 12 | 2 | 8 | 84% | 3088 | missed: 204, 477 897 292, 433 002 565, SYLLA, FERREIRA, CHU de Montpellier, Bâtiment : B     Étage : 2e     Porte : 204, 1er octobre, 0038215, CCBPFRPPPPG, 41 avenue Roger Salengro, Escalier 2, 94500 Champigny-sur-Marne, soixante-cinq mille cinq cent vingt euros; wrong type: AOGI, FNAIM; extra: RCS de Montpellier sous le numéro 477 897 292(ID), AOGI GESTION LOCATIVE(COMPANY), SYLLA-FERREIRA LOT(PERSON), AOGI(ADDRESS), AFS(COMPANY), AOGI(PERSON), SARL(PERSON), RCS Montpellier 433 002 565(ID) |
| fr-lease-02 | 1025 | 23 | 21 | 2 | 0 | 0 | 0 | 100% | 845 |  |
| fr-letter-01 | 2178 | 42 | 36 | 2 | 3 | 1 | 0 | 94% | 1416 | missed: 0417-B32, D-2607-118, 4182736; wrong type: Aydın |
| fr-letter-02 | 2076 | 24 | 20 | 1 | 3 | 0 | 3 | 88% | 1337 | missed: Lucie-Aubrac, Anne, Kerleroux; extra: rose(PERSON), école élémentaire
Lucie-Aubrac(COMPANY), dentaire Anne
Kerleroux(COMPANY) |
| fr-medical-01 | 4423 | 61 | 57 | 3 | 0 | 1 | 4 | 96% | 3156 | wrong type: Cuincy; extra: Confrère(PERSON)×2, Veuve(PERSON), FINESS(ADDRESS) |
| fr-medical-02 | 1306 | 23 | 18 | 3 | 2 | 0 | 1 | 94% | 958 | missed: COULIBALY, Fatoumata; extra: COULIBALY
Fatoumata(PERSON) |
| fr-payslip-01 | 4459 | 40 | 34 | 1 | 5 | 0 | 3 | 90% | 2810 | missed: 00417, AG2R, CMCIFR2A, Bas-Rhin, 778 972 976; extra: Agirc-Arrco(COMPANY), CPAM du Bas-Rhin(COMPANY), RCS Strasbourg 778 972 976(ID) |
| fr-payslip-02 | 1652 | 27 | 22 | 1 | 4 | 0 | 2 | 89% | 1258 | missed: Bretagne, 00147, PRO BTP, CMBRFR2BXXX; extra: SIRET(ADDRESS), Mutuelle PRO BTP(COMPANY) |
| fr-support-01 | 2718 | 36 | 25 | 5 | 6 | 0 | 6 | 85% | 1769 | missed: Chronopost, 8538, 10573826, Lille Métropole, 676 336 068, Résidence Les Hauts du Lac, esc. D, 5e étage, appt 512; extra: Mastercard(COMPANY)×2, Lenovo(COMPANY), Livraisons(COMPANY), RCS Lille Métropole 676 336 068(ID), SignalConso(COMPANY) |
| fr-support-02 | 1404 | 20 | 19 | 1 | 0 | 0 | 1 | 98% | 874 | extra: boulanger(PERSON) |
