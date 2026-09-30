# NER benchmark (desktop, Python onnxruntime)

- Model: xlm-roberta-base-ner-docudis
- Platform: windows "Windows 11 Famille" 10.0 (Build 26200), CPU, onnxruntime via bench_server.py
- Cases: 60, expected entities: 2145
- Overall: recall 90%, precision 94%, F1 92% → reliability **A**; 641 ms per 1000 chars → speed **B**

Grades: reliability by F1 (A ≥ 90%, B ≥ 75%, C ≥ 50%, D below); speed by ms per 1000 characters on this platform (A < 300, B < 1000, C < 3000, D above).

## By language

| Language | Cases | Expected | Found | False pos. | Recall | Precision | F1 | Reliability | ms/1000 chars | Speed |
|---|---|---|---|---|---|---|---|---|---|---|
| en | 20 | 737 | 653 | 48 | 89% | 94% | 91% | A | 476 | B |
| es | 20 | 652 | 584 | 41 | 90% | 95% | 92% | A | 715 | B |
| fr | 20 | 756 | 685 | 68 | 91% | 92% | 91% | A | 735 | B |

## By category

| Category | Cases | Expected | Found | False pos. | Recall | Precision | F1 | Reliability | ms/1000 chars | Speed |
|---|---|---|---|---|---|---|---|---|---|---|
| bank | 6 | 174 | 149 | 12 | 86% | 93% | 89% | B | 522 | B |
| chat | 6 | 77 | 66 | 10 | 86% | 92% | 89% | B | 578 | B |
| cv | 6 | 244 | 219 | 32 | 90% | 90% | 90% | B | 488 | B |
| insurance | 6 | 308 | 275 | 13 | 89% | 96% | 93% | A | 509 | B |
| invoice | 6 | 302 | 265 | 29 | 88% | 92% | 90% | A | 671 | B |
| lease | 6 | 241 | 216 | 12 | 90% | 96% | 93% | A | 732 | B |
| letter | 6 | 196 | 184 | 11 | 94% | 95% | 94% | A | 722 | B |
| medical | 6 | 228 | 212 | 13 | 93% | 95% | 94% | A | 728 | B |
| payslip | 6 | 195 | 170 | 10 | 87% | 95% | 91% | A | 694 | B |
| support | 6 | 180 | 166 | 15 | 92% | 93% | 93% | A | 733 | B |

## Per case

| Case | Chars | Expected | Hit | Partial | Missed | Wrong type | False pos. | F1 | ms | Notes |
|---|---|---|---|---|---|---|---|---|---|---|
| en-bank-01 | 2033 | 39 | 31 | 3 | 5 | 0 | 1 | 92% | 216 | missed: NatWest, Bristol, NWBKGB2L, SVL-002931-AM, 929027; extra: NatWest
Premier Banking(COMPANY) |
| en-bank-02 | 865 | 22 | 14 | 4 | 4 | 0 | 3 | 84% | 89 | missed: WT260910-004418, 7702, CHASUS33, 0817; extra: Wire Services(COMPANY), Airstream(COMPANY), FDIC(COMPANY) |
| en-chat-01 | 952 | 21 | 19 | 0 | 2 | 0 | 4 | 90% | 77 | missed: 14 Birchfield Court, Evington Road, Leicester LE2 1HJ, will; extra: van(PERSON)×3, flat is 14 Birchfield Court, Evington Road, Leicester (ADDRESS) |
| en-chat-02 | 470 | 10 | 7 | 0 | 2 | 1 | 1 | 76% | 30 | missed: halvorsen, reggie; wrong type: brightwater; extra: brightwater(ADDRESS) |
| en-cv-01 | 3677 | 40 | 32 | 4 | 3 | 1 | 9 | 85% | 219 | missed: RN298417, AACN, Sigma Theta Tau; wrong type: Hôpital Saint-Michel; extra: MSN(COMPANY)×2, 06/2027(DATE), 03/2026(DATE), COVID(ADDRESS), Rover(COMPANY), BCMA(COMPANY), Philips IntelliVue(COMPANY), Alaris(ADDRESS) |
| en-cv-02 | 2742 | 34 | 28 | 4 | 2 | 0 | 1 | 96% | 201 | missed: Tesco, Unit 9, Kings Weston Trade Park, Avonmouth, Bristol BS11 8AZ; extra: Tesco Distribution Centre(COMPANY) |
| en-insurance-01 | 4270 | 71 | 54 | 3 | 13 | 1 | 3 | 87% | 246 | missed: Aviva, NIDH001/MTR, 7 Cois Cuain, Bearna, Co. Galway, 211-G-4827, 408213, 3308, 6120, C Ní Dhomhnaill, O Adebayo, C48213 … +1 more; wrong type: 02/11/1985; extra: 7 Cois Cuain
                 Bearna(ADDRESS), C Ní Dhomhnaill & O Adebayo(COMPANY), Aviva 24-hour(COMPANY) |
| en-insurance-02 | 2210 | 41 | 34 | 4 | 3 | 0 | 0 | 96% | 284 | missed: PLM/SHF/118264, 4402, SC002116 |
| en-invoice-01 | 2150 | 46 | 36 | 2 | 8 | 0 | 4 | 87% | 393 | missed: Leeds, 612884, 047731, OD-24781, J/2026/0319, Chapel Allerton, Q-1187, WISNIEWSKA; extra: NICEIC(COMPANY), Worcester Bosch(COMPANY), 24781 WISNIEWSKA(ADDRESS), O&D Building Services Ltd.(COMPANY) |
| en-invoice-02 | 4444 | 59 | 46 | 5 | 8 | 0 | 5 | 90% | 3263 | missed: 10287, P.O. Box 660418, Dallas, TX 75266-0418, 1554, $0.098700, Oncor, $0.025510, 13.9 cents, 2217 LARKSPUR TRL APT 1406 PLANO TX 75074; extra: AutoPay(COMPANY), Aug(DATE), Sep(DATE), DOWNED LINES(ADDRESS), AUTOPAY(COMPANY) |
| en-lease-01 | 4358 | 45 | 39 | 1 | 5 | 0 | 1 | 93% | 3484 | missed: UT482913, RK170652, 1184 Neil Avenue, Apt. 2C, Columbus, OH 43201, pay.hallgrenpm.com, AEP Ohio; extra: Rules(COMPANY) |
| en-lease-02 | 977 | 21 | 17 | 2 | 2 | 0 | 0 | 95% | 799 | missed: 0214, 17 Cnoc na Cathrach, Knocknacarra, Galway, H91 T2RV |
| en-letter-01 | 2190 | 42 | 41 | 0 | 1 | 0 | 2 | 97% | 1623 | missed: HWL/NAR58-2/0319; extra: Council(COMPANY), Deposit Protection Service(COMPANY) |
| en-letter-02 | 2168 | 29 | 25 | 2 | 2 | 0 | 1 | 95% | 1620 | missed: Leeds, Mehta; extra: rose(PERSON) |
| en-medical-01 | 4464 | 53 | 44 | 5 | 4 | 0 | 3 | 94% | 3317 | missed: Leeds Teaching Hospitals NHS Trust, St James's University Hospital, Leeds, 80-2214; extra: The Leeds Teaching Hospitals NHS Trust
St James's University Hospital(COMPANY), J16(COMPANY), Clinic C(COMPANY) |
| en-medical-02 | 1438 | 30 | 24 | 4 | 1 | 1 | 1 | 94% | 1183 | missed: 14D2087315; wrong type: Mylan; extra: 00378-1805(ADDRESS) |
| en-payslip-01 | 3821 | 38 | 33 | 2 | 3 | 0 | 2 | 93% | 2143 | missed: $27.4500, Alliant Credit Union, xxxxxx9026; extra: Illinois(ADDRESS), +1       86.50(NUMBER) |
| en-payslip-02 | 1275 | 29 | 22 | 1 | 6 | 0 | 0 | 88% | 980 | missed: HARCASTLE JOINERY, Loughborough, 567/HA41207, 004417, 20-49, 3817 |
| en-support-01 | 2759 | 42 | 38 | 1 | 3 | 0 | 7 | 90% | 2052 | missed: K7XQ2M, 9901, England; extra: BA1393(ID)×4, Mastercard(COMPANY)×2, Terminal 5(ADDRESS) |
| en-support-02 | 1470 | 25 | 21 | 1 | 3 | 0 | 0 | 94% | 977 | missed: Apartment 12, Millrace Court, Old Kilmainham, Dublin 8, D08 X4K7, Tomasz, 4471 |
| es-bank-01 | 2148 | 37 | 31 | 2 | 3 | 1 | 1 | 92% | 1341 | missed: CG/2026/08831, 4410, A-156980; wrong type: Vallès Occidental; extra: 0417 Terrassa(ADDRESS) |
| es-bank-02 | 942 | 19 | 15 | 2 | 2 | 0 | 1 | 92% | 871 | missed: ABANCA, ES62 5533 **** **** **** 0127; extra: ABANCA Avisos(COMPANY) |
| es-chat-01 | 926 | 14 | 13 | 1 | 0 | 0 | 0 | 100% | 790 |  |
| es-chat-02 | 441 | 9 | 6 | 0 | 3 | 0 | 1 | 76% | 317 | missed: grupo alcor, nuria, transportes beltran; extra: nuria de transportes beltran(PERSON) |
| es-cv-01 | 3673 | 48 | 38 | 3 | 7 | 0 | 10 | 85% | 2659 | missed: Zamudio (Bizkaia), 4,3 M€, Coslada (Madrid), Bermeo (Bizkaia), CS-48-02291, Kaiku, Sestao; extra: 2020-2021(NUMBER), 2008-2013(NUMBER), 2011-2012(NUMBER), 2013-2015(NUMBER), Cámara de Comercio de Bilbao(COMPANY), 05/2028(DATE), Lanbide(COMPANY), Cambridge Advanced(COMPANY), Kaiku de Sestao(COMPANY), 2026(DATE) |
| es-cv-02 | 2268 | 29 | 23 | 4 | 2 | 0 | 3 | 93% | 1580 | missed: Pereira, Colombia, Aula de Cata Ribera Alta; extra: 11/2027(DATE), INAEM(COMPANY), Ágora(COMPANY) |
| es-insurance-01 | 4026 | 53 | 44 | 4 | 5 | 0 | 3 | 93% | 3245 | missed: 7G-48-210.556.931, J-2841, 4817 LKM, VSSZZZKLZNR041877, MU-80.417; extra: Consorcio de Compensación de Seguros(COMPANY), Seguros y Reaseguros. Entidad(COMPANY), General de Seguros y Fondos de Pensiones. Santamaría Ortuño Correduría de Seguros, S.L.(COMPANY) |
| es-insurance-02 | 2170 | 33 | 26 | 5 | 2 | 0 | 3 | 93% | 1519 | missed: 2026/HG/0381746, ES90 8200 **** **** **** 4820; extra: Turia Hogar Plus(COMPANY), Hogar(COMPANY), Aseguradora Turia, S.A. de Seguros y Reaseguros. Inscrita(COMPANY) |
| es-invoice-01 | 1987 | 26 | 20 | 1 | 5 | 0 | 2 | 86% | 1377 | missed: C/ Telletxe, 12, bajo · 48991 Getxo (Bizkaia), 2026/0187, P-26/0412, 48/IF-02917, RC-3307419; extra: FRA 2026(ID), 02917 (Gobierno Vasco)(ADDRESS) |
| es-invoice-02 | 4391 | 65 | 50 | 6 | 9 | 0 | 5 | 90% | 3125 | missed: 0,083921 €, 0,012575 €, 0,189450 €, 0,142310 €, 0,098760 €, 0,026630 €, 0,012742 €, ES60 2368 **** **** **** 4146, Apartado de Correos 4127, 50080 Zaragoza; extra: Potencia(ADDRESS), potencia(ADDRESS), POTENCIA(ADDRESS), ENERGÍA
Punta(COMPANY), Correos(COMPANY) |
| es-lease-01 | 4441 | 57 | 45 | 5 | 6 | 1 | 2 | 92% | 3009 | missed: M-561932, 684, 0847612VK4704H0012RT, 31.877, MV38-B42, M-662.480; wrong type: Canal de Isabel II; extra: I. Que Berzosa Anguita Patrimonio, S.L.(COMPANY), p.p. Berzosa Anguita Patrimonio, S.L.(COMPANY) |
| es-lease-02 | 989 | 24 | 22 | 1 | 1 | 0 | 0 | 98% | 831 | missed: C/ El Peso 27, 1º, 14900 Lucena (Córdoba) |
| es-letter-01 | 2075 | 33 | 31 | 0 | 2 | 0 | 2 | 94% | 1515 | missed: 3.412, ATL-2026/0381; extra: BUROFAX CON ACUSE DE(COMPANY), DESTINATARIO(COMPANY) |
| es-letter-02 | 2105 | 26 | 25 | 1 | 0 | 0 | 2 | 97% | 1498 | extra: puente del(ADDRESS), Pilar(ADDRESS) |
| es-medical-01 | 4463 | 40 | 32 | 3 | 5 | 0 | 2 | 91% | 3037 | missed: 36208 Vigo (Pontevedra), 2026/0457713, Costel Munteanu, 36/3607152, 36/3611894; extra: Vigo
Hospital Álvaro Cunqueiro(COMPANY), Coia(ADDRESS) |
| es-medical-02 | 1350 | 21 | 16 | 2 | 3 | 0 | 0 | 92% | 982 | missed: 50/5012874, LABORATORIO IBARZ, 50/5017306 |
| es-payslip-01 | 4002 | 35 | 29 | 1 | 5 | 0 | 1 | 91% | 2625 | missed: Trabanca, 36/1048827/83, 00412, Rúa Ourense, 9, 2º esq. - 36630 Cambados (Pontevedra), PO-31.906; extra: Planta de Trabanca(COMPANY) |
| es-payslip-02 | 1557 | 26 | 20 | 3 | 3 | 0 | 1 | 92% | 1312 | missed: EMBUTIDOS Y SALAZONES, 09/1048823/61, A. M. Ciobanu; extra: C.I(COMPANY) |
| es-support-01 | 2731 | 37 | 34 | 0 | 3 | 0 | 2 | 94% | 1807 | missed: QK7M2D, 08841527, 8036; extra: Mastercard(COMPANY)×2 |
| es-support-02 | 1474 | 20 | 18 | 2 | 0 | 0 | 0 | 100% | 983 |  |
| fr-bank-01 | 2050 | 38 | 28 | 2 | 7 | 1 | 2 | 85% | 1407 | missed: Bayonne Saint-Esprit, Bât. C - Appt 27, BSE/RC/2026-09/1184, 30857, 70037, 77, AGRIFRPP869; wrong type: Résidence Les Hauts de Mousserolles; extra: Agence de Bayonne Saint-Esprit(COMPANY)×2 |
| fr-bank-02 | 899 | 19 | 13 | 4 | 2 | 0 | 4 | 86% | 742 | missed: CIC, FR76 8457 **** **** **** **31 349; extra: SEPA(COMPANY)×2, Agence Schiltigheim Centre(COMPANY), SEPA(PERSON) |
| fr-chat-01 | 965 | 14 | 10 | 1 | 2 | 1 | 3 | 82% | 857 | missed: jo, 3e etage; wrong type: leclerc; extra: karim sil(PERSON), quil(PERSON), Momo(COMPANY) |
| fr-chat-02 | 413 | 9 | 9 | 0 | 0 | 0 | 1 | 96% | 333 | extra: relance sandrine(PERSON) |
| fr-cv-01 | 3471 | 57 | 48 | 2 | 5 | 2 | 6 | 88% | 2620 | missed: 4,2 M€, ETCHEVERRY Maitena, AFTRAL, IUT de Bordeaux, IUT de Bayonne et du Pays basque; wrong type: Irun, Pampelune; extra: Micro-entreprise ETCHEVERRY Maitena(COMPANY), SIRET(ADDRESS), AFTRAL Bordeaux(COMPANY), TOEIC 845(COMPANY), Pelote(PERSON), Leroy Merlin Mérignac(PERSON) |
| fr-cv-02 | 2307 | 36 | 31 | 2 | 3 | 0 | 3 | 92% | 1577 | missed: Nord vaudois, EPAI, Suisse; extra: quartier(ADDRESS), 2022-2024(NUMBER), 2015          Cours de chef d'équipe(ADDRESS) |
| fr-insurance-01 | 4012 | 71 | 61 | 4 | 6 | 0 | 3 | 94% | 2705 | missed: GH-482-LQ, CEPAFRPP382, MMA-AU7482913C-001, Le Mans, 775 652 126, 440 048 882; extra: Mémo Véhicule Assuré(COMPANY), RCS Le Mans 775 652 126(ID), RCS Le Mans 440 048 882(ID) |
| fr-insurance-02 | 2190 | 39 | 30 | 6 | 3 | 0 | 1 | 95% | 1602 | missed: Bât. C - 3e étage - Appt 32, 2026-DDE-0738214, appt 42; extra: Multirisque Habitation Sérénité(COMPANY) |
| fr-invoice-01 | 2142 | 41 | 33 | 5 | 3 | 0 | 4 | 92% | 1722 | missed: 4402817, CMBRFR2BXXX, 833 304 132; extra: EURL(PERSON)×2, Atlantic Zénéo(COMPANY), RCS Quimper 833 304 132(ID) |
| fr-invoice-02 | 4038 | 65 | 47 | 14 | 4 | 0 | 9 | 92% | 2973 | missed: FR76 6193 **** **** **** **52 384, Libre réponse n° 59252, 75443 Paris Cedex 09, TSA 70233 - 34967 Montpellier Cedex 2, 619 326 754; extra: Linky(PERSON), GONCALVES PEREIRA
IBAN(PERSON), LUMIO(COMPANY), pleines  48(ADDRESS), Dépannage électricité Enedis(COMPANY), 34967 Montpellier Cedex 2.(ADDRESS), 75443 Paris Cedex 09.(ADDRESS), IBAN(PERSON), RCS Montpellier 619 326 754(ID) |
| fr-lease-01 | 4331 | 71 | 54 | 7 | 10 | 0 | 9 | 87% | 2907 | missed: 204, 477 897 292, 433 002 565, SYLLA, FERREIRA, CHU de Montpellier, Bâtiment : B     Étage : 2e     Porte : 204, 0038215, CCBPFRPPPPG, soixante-cinq mille cinq cent vingt euros; extra: AOGI(PERSON)×2, RCS de Montpellier sous le numéro 477 897 292(ID), AOGI GESTION LOCATIVE(COMPANY), SYLLA-FERREIRA LOT(PERSON), MLS(COMPANY), IFS(COMPANY), SARL(PERSON), RCS Montpellier 433 002 565(ID) |
| fr-lease-02 | 1025 | 23 | 21 | 2 | 0 | 0 | 0 | 100% | 771 |  |
| fr-letter-01 | 2178 | 42 | 36 | 2 | 3 | 1 | 0 | 94% | 1499 | missed: 0417-B32, D-2607-118, 4182736; wrong type: Aydın |
| fr-letter-02 | 2076 | 24 | 20 | 1 | 3 | 0 | 4 | 87% | 1476 | missed: Lucie-Aubrac, Anne, Kerleroux; extra: Rezéens(ADDRESS), rose(PERSON), école élémentaire
Lucie-Aubrac(COMPANY), dentaire Anne
Kerleroux(COMPANY) |
| fr-medical-01 | 4423 | 61 | 58 | 3 | 0 | 0 | 6 | 96% | 3235 | extra: Confrère(PERSON)×2, Saint(ADDRESS), Vaast(ADDRESS), Veuve(PERSON), FINESS(ADDRESS) |
| fr-medical-02 | 1306 | 23 | 19 | 2 | 2 | 0 | 1 | 94% | 944 | missed: COULIBALY, Fatoumata; extra: COULIBALY
Fatoumata(PERSON) |
| fr-payslip-01 | 4459 | 40 | 32 | 3 | 5 | 0 | 3 | 90% | 3193 | missed: Strasbourg, 00417, AG2R, CMCIFR2A, 778 972 976; extra: URSSAF de Strasbourg(COMPANY), Agirc-Arrco(ADDRESS), RCS Strasbourg 778 972 976(ID) |
| fr-payslip-02 | 1652 | 27 | 23 | 1 | 3 | 0 | 3 | 89% | 1378 | missed: 00147, PRO BTP, CMBRFR2BXXX; extra: SIRET(ADDRESS), URSSAF(ADDRESS), Mutuelle PRO BTP(COMPANY) |
| fr-support-01 | 2718 | 36 | 25 | 6 | 5 | 0 | 5 | 87% | 2263 | missed: Chronopost, 8538, 10573826, Lille Métropole, 676 336 068; extra: Mastercard(COMPANY)×2, Lenovo(COMPANY), RCS Lille Métropole 676 336 068(ID), SignalConso(COMPANY) |
| fr-support-02 | 1404 | 20 | 19 | 1 | 0 | 0 | 1 | 98% | 1119 | extra: boulanger(PERSON) |
