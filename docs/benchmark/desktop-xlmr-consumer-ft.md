# NER benchmark (desktop, Python onnxruntime)

- Model: xlm-roberta-base-ner-docudis
- Platform: windows "Windows 11 Famille" 10.0 (Build 26200), CPU, onnxruntime via bench_server.py
- Cases: 60, expected entities: 2145
- Overall: recall 89%, precision 94%, F1 92% → reliability **A**; 57 ms per 1000 chars → speed **A**

Grades: reliability by F1 (A ≥ 90%, B ≥ 75%, C ≥ 50%, D below); speed by ms per 1000 characters on this platform (A < 300, B < 1000, C < 3000, D above).

## By language

| Language | Cases | Expected | Found | False pos. | Recall | Precision | F1 | Reliability | ms/1000 chars | Speed |
|---|---|---|---|---|---|---|---|---|---|---|
| en | 20 | 737 | 654 | 50 | 89% | 94% | 91% | A | 53 | A |
| es | 20 | 652 | 585 | 46 | 90% | 94% | 92% | A | 53 | A |
| fr | 20 | 756 | 678 | 62 | 90% | 93% | 91% | A | 65 | A |

## By category

| Category | Cases | Expected | Found | False pos. | Recall | Precision | F1 | Reliability | ms/1000 chars | Speed |
|---|---|---|---|---|---|---|---|---|---|---|
| bank | 6 | 174 | 150 | 11 | 86% | 94% | 90% | B | 65 | A |
| chat | 6 | 77 | 67 | 9 | 87% | 93% | 90% | A | 66 | A |
| cv | 6 | 244 | 216 | 30 | 89% | 90% | 89% | B | 53 | A |
| insurance | 6 | 308 | 274 | 14 | 89% | 96% | 92% | A | 56 | A |
| invoice | 6 | 302 | 265 | 27 | 88% | 93% | 90% | A | 57 | A |
| lease | 6 | 241 | 215 | 15 | 89% | 95% | 92% | A | 57 | A |
| letter | 6 | 196 | 184 | 6 | 94% | 97% | 96% | A | 57 | A |
| medical | 6 | 228 | 211 | 13 | 93% | 95% | 94% | A | 56 | A |
| payslip | 6 | 195 | 171 | 13 | 88% | 94% | 91% | A | 57 | A |
| support | 6 | 180 | 164 | 20 | 91% | 91% | 91% | A | 55 | A |

## Per case

| Case | Chars | Expected | Hit | Partial | Missed | Wrong type | False pos. | F1 | ms | Notes |
|---|---|---|---|---|---|---|---|---|---|---|
| en-bank-01 | 2033 | 39 | 32 | 2 | 5 | 0 | 1 | 92% | 130 | missed: NatWest, Bristol, NWBKGB2L, SVL-002931-AM, 929027; extra: NatWest
Premier Banking(COMPANY) |
| en-bank-02 | 865 | 22 | 14 | 4 | 4 | 0 | 3 | 84% | 59 | missed: WT260910-004418, 7702, CHASUS33, 0817; extra: Wire Services(COMPANY), Airstream(COMPANY), FDIC(COMPANY) |
| en-chat-01 | 952 | 21 | 19 | 0 | 1 | 1 | 4 | 89% | 60 | missed: 14 Birchfield Court, Evington Road, Leicester LE2 1HJ; wrong type: luton; extra: van(PERSON)×2, flat is 14 Birchfield Court, Evington Road, Leicester (ADDRESS), van mans(PERSON) |
| en-chat-02 | 470 | 10 | 8 | 0 | 0 | 2 | 1 | 79% | 27 | wrong type: brightwater, halvorsen; extra: brightwater(ADDRESS) |
| en-cv-01 | 3677 | 40 | 33 | 3 | 4 | 0 | 7 | 88% | 170 | missed: RN298417, AACN, Sigma Theta Tau, Jacmel, Haiti; extra: 06/2027(DATE), 03/2026(DATE), COVID(ADDRESS), 12/2027)(DATE), BCMA(COMPANY), Philips IntelliVue(COMPANY), MHA(ADDRESS) |
| en-cv-02 | 2742 | 34 | 29 | 3 | 2 | 0 | 2 | 95% | 145 | missed: Tesco, Unit 9, Kings Weston Trade Park, Avonmouth, Bristol BS11 8AZ; extra: Tesco Distribution Centre(COMPANY), Safely(COMPANY) |
| en-insurance-01 | 4270 | 71 | 53 | 4 | 13 | 1 | 4 | 86% | 208 | missed: Aviva, NIDH001/MTR, 7 Cois Cuain, Bearna, Co. Galway, 211-G-4827, 408213, Premium Credit, 3308, 6120, O Adebayo, C48213 … +1 more; wrong type: 02/11/1985; extra: 7 Cois Cuain
                 Bearna(ADDRESS), Driveway(COMPANY), & O Adebayo(COMPANY), Aviva 24-hour(COMPANY) |
| en-insurance-02 | 2210 | 41 | 34 | 4 | 3 | 0 | 0 | 96% | 113 | missed: PLM/SHF/118264, 4402, SC002116 |
| en-invoice-01 | 2150 | 46 | 35 | 4 | 7 | 0 | 3 | 89% | 112 | missed: Leeds, 612884, 047731, OD-24781, J/2026/0319, Q-1187, WISNIEWSKA; extra: Worcester(COMPANY), 24781 WISNIEWSKA(ADDRESS), O&D Building Services Ltd.(COMPANY) |
| en-invoice-02 | 4444 | 59 | 46 | 4 | 9 | 0 | 7 | 88% | 242 | missed: 10287, Dallas, 1554, $0.098700, Oncor, $0.025510, Plano, 13.9 cents, 2217 LARKSPUR TRL APT 1406 PLANO TX 75074; extra: Aug 25(DATE), Sep(DATE), Oct(DATE), Nov(DATE), May(DATE), Jul 26(DATE), Aug 26(DATE) |
| en-lease-01 | 4358 | 45 | 39 | 1 | 5 | 0 | 1 | 93% | 219 | missed: UT482913, RK170652, 1184 Neil Avenue, Apt. 2C, Columbus, OH 43201, pay.hallgrenpm.com, AEP Ohio; extra: Rules(COMPANY) |
| en-lease-02 | 977 | 21 | 17 | 2 | 2 | 0 | 0 | 95% | 59 | missed: 0214, 17 Cnoc na Cathrach, Knocknacarra, Galway, H91 T2RV |
| en-letter-01 | 2190 | 42 | 41 | 0 | 1 | 0 | 0 | 99% | 111 | missed: HWL/NAR58-2/0319 |
| en-letter-02 | 2168 | 29 | 26 | 2 | 1 | 0 | 1 | 97% | 115 | missed: Mehta; extra: rose(PERSON) |
| en-medical-01 | 4464 | 53 | 44 | 5 | 4 | 0 | 4 | 93% | 228 | missed: Leeds Teaching Hospitals NHS Trust, St James's University Hospital, Leeds, 80-2214; extra: The Leeds Teaching Hospitals NHS Trust
St James's University Hospital(COMPANY), Clinic C(COMPANY), FRCP(ADDRESS), GMC(ADDRESS) |
| en-medical-02 | 1438 | 30 | 24 | 4 | 1 | 1 | 1 | 94% | 85 | missed: 14D2087315; wrong type: Mylan; extra: 00378-1805(ADDRESS) |
| en-payslip-01 | 3821 | 38 | 34 | 1 | 3 | 0 | 3 | 92% | 175 | missed: $27.4500, Alliant Credit Union, xxxxxx9026; extra: Freezer Warehouse(COMPANY), Illinois(ADDRESS), +1       86.50(NUMBER) |
| en-payslip-02 | 1275 | 29 | 21 | 2 | 6 | 0 | 0 | 88% | 78 | missed: HARCASTLE JOINERY, 567/HA41207, 004417, 20-49, 3817, England |
| en-support-01 | 2759 | 42 | 38 | 1 | 3 | 0 | 8 | 89% | 140 | missed: K7XQ2M, 9901, England; extra: BA1393(ID)×4, Mastercard(COMPANY)×2, BA032(ADDRESS), Terminal 5(ADDRESS) |
| en-support-02 | 1470 | 25 | 20 | 1 | 4 | 0 | 0 | 91% | 76 | missed: Apartment 12, Millrace Court, Old Kilmainham, Dublin 8, D08 X4K7, Tomasz, AIB, 4471 |
| es-bank-01 | 2148 | 37 | 31 | 2 | 3 | 1 | 1 | 92% | 100 | missed: CG/2026/08831, 4410, A-156980; wrong type: Vallès Occidental; extra: 0417 Terrassa(ADDRESS) |
| es-bank-02 | 942 | 19 | 15 | 2 | 2 | 0 | 2 | 90% | 64 | missed: ABANCA, ES62 5533 **** **** **** 0127; extra: ABANCA Avisos(COMPANY), Oficina(ADDRESS) |
| es-chat-01 | 926 | 14 | 13 | 1 | 0 | 0 | 0 | 100% | 62 |  |
| es-chat-02 | 441 | 9 | 7 | 0 | 2 | 0 | 1 | 83% | 23 | missed: grupo alcor, transportes beltran; extra: beltran(PERSON) |
| es-cv-01 | 3673 | 48 | 37 | 3 | 7 | 1 | 12 | 82% | 187 | missed: Zamudio (Bizkaia), 4,3 M€, Coslada (Madrid), Bermeo (Bizkaia), CS-48-02291, Kaiku, Sestao; wrong type: Derio; extra: Coordinadora(COMPANY), 2020-2021(NUMBER), 2008-2013(NUMBER), 2011-2012(NUMBER), 2013-2015(NUMBER), Cámara de Comercio de Bilbao(COMPANY), 05/2028(DATE), Lanbide(COMPANY), Cambridge Advanced(COMPANY), DELF(COMPANY), Kaiku de Sestao(COMPANY), septiembre de 2026(DATE) |
| es-cv-02 | 2268 | 29 | 23 | 4 | 2 | 0 | 1 | 95% | 110 | missed: Pereira, Colombia, Aula de Cata Ribera Alta; extra: INAEM(COMPANY) |
| es-insurance-01 | 4026 | 53 | 43 | 5 | 4 | 1 | 3 | 92% | 220 | missed: 7G-48-210.556.931, 4817 LKM, VSSZZZKLZNR041877, MU-80.417; wrong type: J-2841; extra: Consorcio de Compensación de Seguros(COMPANY), Seguros y Reaseguros. Entidad(COMPANY), General de Seguros y Fondos de Pensiones. Santamaría Ortuño Correduría de Seguros, S.L.(COMPANY) |
| es-insurance-02 | 2170 | 33 | 26 | 5 | 2 | 0 | 4 | 92% | 131 | missed: 2026/HG/0381746, ES90 8200 **** **** **** 4820; extra: Turia Hogar Plus(COMPANY), 2º(ADDRESS), Hogar(COMPANY), Aseguradora Turia, S.A. de Seguros y Reaseguros. Inscrita(COMPANY) |
| es-invoice-01 | 1987 | 26 | 20 | 1 | 5 | 0 | 2 | 86% | 103 | missed: C/ Telletxe, 12, bajo · 48991 Getxo (Bizkaia), 2026/0187, P-26/0412, 48/IF-02917, RC-3307419; extra: FRA 2026(ID), 02917 (Gobierno Vasco)(ADDRESS) |
| es-invoice-02 | 4391 | 65 | 49 | 8 | 8 | 0 | 1 | 93% | 234 | missed: 0,083921 €, 0,012575 €, 0,189450 €, 0,142310 €, 0,098760 €, 0,026630 €, 0,012742 €, ES60 2368 **** **** **** 4146; extra: Correos(COMPANY) |
| es-lease-01 | 4441 | 57 | 46 | 5 | 6 | 0 | 6 | 91% | 221 | missed: M-561932, 684, 0847612VK4704H0012RT, 31.877, MV38-B42, M-662.480; extra: los arrendatarios(COMPANY)×2, I. Que Berzosa Anguita Patrimonio, S.L.(COMPANY), Los arrendatarios(COMPANY), p.p. Berzosa Anguita Patrimonio, S.L.(COMPANY), LOS ARRENDATARIOS(COMPANY) |
| es-lease-02 | 989 | 24 | 22 | 1 | 1 | 0 | 0 | 98% | 66 | missed: C/ El Peso 27, 1º, 14900 Lucena (Córdoba) |
| es-letter-01 | 2075 | 33 | 30 | 0 | 3 | 0 | 0 | 95% | 118 | missed: 3.412, ATL-2026/0381, Amparo Tortajada |
| es-letter-02 | 2105 | 26 | 24 | 2 | 0 | 0 | 1 | 99% | 102 | extra: Pilar(ADDRESS) |
| es-medical-01 | 4463 | 40 | 32 | 3 | 5 | 0 | 3 | 90% | 218 | missed: 36208 Vigo (Pontevedra), 2026/0457713, Costel Munteanu, 36/3607152, 36/3611894; extra: Vigo
Hospital Álvaro Cunqueiro(COMPANY), cardiaca(COMPANY), Cardiaca(COMPANY) |
| es-medical-02 | 1350 | 21 | 16 | 2 | 3 | 0 | 1 | 90% | 71 | missed: 50/5012874, LABORATORIO IBARZ, 50/5017306; extra: RECETA MEDICA PRIVADA(COMPANY) |
| es-payslip-01 | 4002 | 35 | 29 | 1 | 5 | 0 | 1 | 91% | 202 | missed: Trabanca, 36/1048827/83, 00412, Rúa Ourense, 9, 2º esq. - 36630 Cambados (Pontevedra), PO-31.906; extra: Planta de Trabanca(COMPANY) |
| es-payslip-02 | 1557 | 26 | 21 | 2 | 3 | 0 | 1 | 92% | 108 | missed: EMBUTIDOS Y SALAZONES, 09/1048823/61, A. M. Ciobanu; extra: C.I(COMPANY) |
| es-support-01 | 2731 | 37 | 34 | 0 | 2 | 1 | 6 | 89% | 139 | missed: 08841527, 8036; wrong type: QK7M2D; extra: QK7M2D(ADDRESS)×3, Mastercard(COMPANY)×2, AVE(COMPANY) |
| es-support-02 | 1474 | 20 | 18 | 2 | 0 | 0 | 0 | 100% | 77 |  |
| fr-bank-01 | 2050 | 38 | 29 | 2 | 7 | 0 | 2 | 88% | 149 | missed: Bayonne Saint-Esprit, Bât. C - Appt 27, BSE/RC/2026-09/1184, 30857, 70037, 77, AGRIFRPP869; extra: Agence de Bayonne Saint-Esprit(COMPANY)×2 |
| fr-bank-02 | 899 | 19 | 13 | 4 | 2 | 0 | 2 | 90% | 76 | missed: CIC, FR76 8457 **** **** **** **31 349; extra: Agence Schiltigheim Centre(COMPANY), CIC Schiltigheim Centre(COMPANY) |
| fr-chat-01 | 965 | 14 | 9 | 1 | 3 | 1 | 3 | 78% | 75 | missed: leclerc, jo, 3e etage; wrong type: Momo; extra: karim sil(PERSON), quil(PERSON), Momo(COMPANY) |
| fr-chat-02 | 413 | 9 | 9 | 0 | 0 | 0 | 0 | 100% | 27 |  |
| fr-cv-01 | 3471 | 57 | 47 | 2 | 7 | 1 | 6 | 87% | 213 | missed: 4,2 M€, Pampelune, ETCHEVERRY Maitena, AFTRAL, IUT de Bordeaux, IUT de Bayonne et du Pays basque, Ustaritz; wrong type: Irun; extra: Micro-entreprise ETCHEVERRY Maitena(COMPANY), SIRET(ADDRESS), AFTRAL Bordeaux(COMPANY), TOEIC(COMPANY), Pelote(PERSON), Leroy Merlin Mérignac(COMPANY) |
| fr-cv-02 | 2307 | 36 | 31 | 1 | 3 | 1 | 2 | 90% | 132 | missed: Nord vaudois, Suisse, Morat; wrong type: Guin; extra: 2022-2024(NUMBER), 2015          Cours de chef d'équipe(ADDRESS) |
| fr-insurance-01 | 4012 | 71 | 59 | 5 | 7 | 0 | 2 | 94% | 241 | missed: MMA, GH-482-LQ, CEPAFRPP382, MMA-AU7482913C-001, Le Mans, 775 652 126, 440 048 882; extra: RCS Le Mans 775 652 126(ID), RCS Le Mans 440 048 882(ID) |
| fr-insurance-02 | 2190 | 39 | 31 | 5 | 3 | 0 | 1 | 95% | 140 | missed: Bât. C - 3e étage - Appt 32, 2026-DDE-0738214, appt 42; extra: Multirisque Habitation Sérénité(COMPANY) |
| fr-invoice-01 | 2142 | 41 | 32 | 5 | 4 | 0 | 6 | 88% | 143 | missed: 4402817, EURL LE GOFF PLOMBERIE CHAUFFAGE, CMBRFR2BXXX, 833 304 132; extra: EURL(PERSON)×2, LE GOFF PLOMBERIE CHAUFFAGE(PERSON), Plomberie(PERSON), Atlantic(COMPANY), RCS Quimper 833 304 132(ID) |
| fr-invoice-02 | 4038 | 65 | 48 | 13 | 4 | 0 | 8 | 92% | 259 | missed: FR76 6193 **** **** **** **52 384, Libre réponse n° 59252, 75443 Paris Cedex 09, TSA 70233 - 34967 Montpellier Cedex 2, 619 326 754; extra: Lumio Énergie
VOTRE(COMPANY), Lumio Heures Creuses(COMPANY), Linky(PERSON), pleines  48(ADDRESS), Dépannage électricité Enedis(COMPANY), 34967 Montpellier Cedex 2.(ADDRESS), 75443 Paris Cedex 09.(ADDRESS), RCS Montpellier 619 326 754(ID) |
| fr-lease-01 | 4331 | 71 | 52 | 7 | 10 | 2 | 8 | 85% | 265 | missed: 204, 477 897 292, 433 002 565, SYLLA, FERREIRA, CHU de Montpellier, Bâtiment : B     Étage : 2e     Porte : 204, 0038215, CCBPFRPPPPG, soixante-cinq mille cinq cent vingt euros; wrong type: AOGI, FNAIM; extra: RÉSIDENCE PRINCIPALE(ADDRESS), RCS de Montpellier sous le numéro 477 897 292(ID), AOGI GESTION LOCATIVE(COMPANY), SYLLA-FERREIRA LOT(PERSON), AOGI(ADDRESS), AOGI(PERSON), SARL(PERSON), RCS Montpellier 433 002 565(ID) |
| fr-lease-02 | 1025 | 23 | 21 | 2 | 0 | 0 | 0 | 100% | 87 |  |
| fr-letter-01 | 2178 | 42 | 36 | 2 | 3 | 1 | 0 | 94% | 147 | missed: 0417-B32, D-2607-118, 4182736; wrong type: Aydın |
| fr-letter-02 | 2076 | 24 | 20 | 1 | 3 | 0 | 4 | 87% | 136 | missed: Lucie-Aubrac, Anne, Kerleroux; extra: Rezéens(PERSON), rose(PERSON), école élémentaire
Lucie-Aubrac(COMPANY), dentaire Anne
Kerleroux(COMPANY) |
| fr-medical-01 | 4423 | 61 | 57 | 3 | 0 | 1 | 3 | 96% | 286 | wrong type: Cuincy; extra: Confrère(PERSON)×2, Veuve(PERSON) |
| fr-medical-02 | 1306 | 23 | 18 | 3 | 2 | 0 | 1 | 94% | 84 | missed: COULIBALY, Fatoumata; extra: COULIBALY
Fatoumata(PERSON) |
| fr-payslip-01 | 4459 | 40 | 32 | 4 | 4 | 0 | 5 | 90% | 280 | missed: 00417, AG2R, CMCIFR2A, 778 972 976; extra: Erstein(COMPANY), Agirc-Arrco(COMPANY), CPAM du(COMPANY), Rhin(COMPANY), RCS Strasbourg 778 972 976(ID) |
| fr-payslip-02 | 1652 | 27 | 23 | 1 | 3 | 0 | 3 | 89% | 117 | missed: 00147, PRO BTP, CMBRFR2BXXX; extra: SIRET(ADDRESS), URSSAF(ADDRESS), Mutuelle PRO BTP(COMPANY) |
| fr-support-01 | 2718 | 36 | 25 | 5 | 6 | 0 | 5 | 86% | 171 | missed: Chronopost, 8538, 10573826, Lille Métropole, 676 336 068, Résidence Les Hauts du Lac, esc. D, 5e étage, appt 512; extra: Mastercard(COMPANY)×2, Lenovo(COMPANY), RCS Lille Métropole 676 336 068(ID), SignalConso(COMPANY) |
| fr-support-02 | 1404 | 20 | 19 | 1 | 0 | 0 | 1 | 98% | 89 | extra: boulanger(PERSON) |
