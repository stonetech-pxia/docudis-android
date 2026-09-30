# NER benchmark (desktop, Python onnxruntime)

- Model: xlm-roberta-base-ner-docudis
- Platform: windows "Windows 11 Famille" 10.0 (Build 26200), CPU, onnxruntime via bench_server.py
- Cases: 60, expected entities: 2138
- Overall: recall 92%, precision 94%, F1 93% → reliability **A**; 67 ms per 1000 chars → speed **A**

Grades: reliability by F1 (A ≥ 90%, B ≥ 75%, C ≥ 50%, D below); speed by ms per 1000 characters on this platform (A < 300, B < 1000, C < 3000, D above).

## By language

| Language | Cases | Expected | Found | False pos. | Recall | Precision | F1 | Reliability | ms/1000 chars | Speed |
|---|---|---|---|---|---|---|---|---|---|---|
| en | 20 | 730 | 669 | 66 | 92% | 93% | 92% | A | 74 | A |
| es | 20 | 652 | 612 | 36 | 94% | 96% | 95% | A | 58 | A |
| fr | 20 | 756 | 696 | 60 | 92% | 93% | 93% | A | 70 | A |

## By category

| Category | Cases | Expected | Found | False pos. | Recall | Precision | F1 | Reliability | ms/1000 chars | Speed |
|---|---|---|---|---|---|---|---|---|---|---|
| bank | 6 | 172 | 159 | 14 | 92% | 92% | 92% | A | 67 | A |
| chat | 6 | 77 | 68 | 5 | 88% | 96% | 92% | A | 68 | A |
| cv | 6 | 244 | 219 | 32 | 90% | 90% | 90% | B | 66 | A |
| insurance | 6 | 307 | 288 | 12 | 94% | 97% | 95% | A | 62 | A |
| invoice | 6 | 300 | 273 | 31 | 91% | 92% | 92% | A | 83 | A |
| lease | 6 | 241 | 220 | 14 | 91% | 95% | 93% | A | 67 | A |
| letter | 6 | 196 | 188 | 8 | 96% | 96% | 96% | A | 58 | A |
| medical | 6 | 228 | 214 | 15 | 94% | 95% | 94% | A | 59 | A |
| payslip | 6 | 194 | 179 | 12 | 92% | 94% | 93% | A | 80 | A |
| support | 6 | 179 | 169 | 19 | 94% | 92% | 93% | A | 59 | A |

## Per case

| Case | Chars | Expected | Hit | Partial | Missed | Wrong type | False pos. | F1 | ms | Notes |
|---|---|---|---|---|---|---|---|---|---|---|
| en-bank-01 | 2033 | 37 | 32 | 2 | 3 | 0 | 3 | 92% | 138 | missed: NatWest, Bristol, SVL-002931-AM; extra: NatWest
Premier Banking(COMPANY), England(ADDRESS), Wales(ADDRESS) |
| en-bank-02 | 865 | 22 | 16 | 4 | 2 | 0 | 3 | 89% | 63 | missed: 7702, 0817; extra: Wire Services(COMPANY), Airstream(COMPANY), FDIC(COMPANY) |
| en-chat-01 | 952 | 21 | 20 | 0 | 1 | 0 | 2 | 95% | 61 | missed: 14 Birchfield Court, Evington Road, Leicester LE2 1HJ; extra: flat is 14 Birchfield Court, Evington Road, Leicester (ADDRESS), van mans(PERSON) |
| en-chat-02 | 470 | 10 | 7 | 0 | 1 | 2 | 1 | 73% | 27 | missed: reggie; wrong type: brightwater, halvorsen; extra: brightwater(ADDRESS) |
| en-cv-01 | 3677 | 40 | 32 | 4 | 3 | 1 | 12 | 83% | 221 | missed: AACN, Sigma Theta Tau, Jacmel, Haiti; wrong type: Hôpital Saint-Michel; extra: MSN(COMPANY)×2, 06/2027(DATE), ACLS(COMPANY), BLS(COMPANY), 03/2026(DATE), CLABSI(COMPANY), COVID ICU(COMPANY), 12/2027)(DATE), SKILLS
Epic(COMPANY), BCMA(COMPANY), MHA(COMPANY) |
| en-cv-02 | 2742 | 34 | 27 | 5 | 2 | 0 | 2 | 95% | 285 | missed: Tesco, Harbour Road, Portishead BS20 7DD; extra: Tesco Distribution Centre(COMPANY), BTEC(COMPANY) |
| en-insurance-01 | 4270 | 71 | 61 | 1 | 8 | 1 | 2 | 91% | 295 | missed: 7 Cois Cuain, Bearna, Co. Galway, Premium Credit, 3308, 6120, C Ní Dhomhnaill, O Adebayo; wrong type: 02/11/1985; extra: 7 Cois Cuain
                 Bearna(ADDRESS), C Ní Dhomhnaill & O Adebayo(COMPANY) |
| en-insurance-02 | 2210 | 40 | 34 | 3 | 3 | 0 | 0 | 96% | 108 | missed: Ecclesall, PLM/SHF/118264, 4402 |
| en-invoice-01 | 2150 | 44 | 37 | 4 | 3 | 0 | 4 | 93% | 151 | missed: Leeds, Q-1187, WISNIEWSKA; extra: Worcester(COMPANY), 24781 WISNIEWSKA(ADDRESS), O&D Building Services Ltd.(COMPANY), England(ADDRESS) |
| en-invoice-02 | 4444 | 59 | 47 | 4 | 7 | 1 | 14 | 86% | 594 | missed: P.O. Box 660418, Dallas, TX 75266-0418, 2217 LARKSPUR TRL APT 1406, PLANO TX 75074, 1554, $0.098700, $0.025510, 13.9 cents, 2217 LARKSPUR TRL APT 1406 PLANO TX 75074; wrong type: Oncor; extra: Aug(DATE)×2, Oncor(ADDRESS), Sep(DATE), Oct(DATE), Nov(DATE), Dec(DATE), Jan(DATE), Feb(DATE), Mar(DATE), Apr(DATE), May(DATE), Jun(DATE) … +1 more |
| en-lease-01 | 4358 | 45 | 41 | 1 | 3 | 0 | 2 | 95% | 266 | missed: 1184 Neil Avenue, Apt. 2C, Columbus, OH 43201, pay.hallgrenpm.com, AEP Ohio; extra: Rules(COMPANY), WZ  MD(PERSON) |
| en-lease-02 | 977 | 21 | 17 | 1 | 3 | 0 | 0 | 92% | 93 | missed: 0214, Flat 3, 41 Harold's Cross Road, Dublin 6W, D6W XK72, 17 Cnoc na Cathrach, Knocknacarra, Galway, H91 T2RV |
| en-letter-01 | 2190 | 42 | 42 | 0 | 0 | 0 | 1 | 99% | 104 | extra: Deposit Protection(COMPANY) |
| en-letter-02 | 2168 | 29 | 25 | 2 | 2 | 0 | 1 | 95% | 114 | missed: Leeds, Mehta; extra: rose(PERSON) |
| en-medical-01 | 4464 | 53 | 43 | 6 | 4 | 0 | 4 | 93% | 243 | missed: Leeds Teaching Hospitals NHS Trust, St James's University Hospital, Leeds, 80-2214; extra: The Leeds Teaching Hospitals NHS Trust
St James's University Hospital(COMPANY), MDT(COMPANY), Clinic C(COMPANY), Dictated(PERSON) |
| en-medical-02 | 1438 | 30 | 24 | 4 | 1 | 1 | 2 | 93% | 94 | missed: Logan Square Internal Medicine; wrong type: Mylan; extra: TJO(COMPANY), 00378-1805(ADDRESS) |
| en-payslip-01 | 3821 | 38 | 35 | 1 | 2 | 0 | 3 | 94% | 415 | missed: $27.4500, Alliant Credit Union; extra: Illinois(ADDRESS), BCBSIL PPO EE(COMPANY), +1       86.50(NUMBER) |
| en-payslip-02 | 1275 | 28 | 23 | 2 | 3 | 0 | 0 | 94% | 69 | missed: HARCASTLE JOINERY, Loughborough, 20-49 |
| en-support-01 | 2759 | 41 | 39 | 1 | 1 | 0 | 8 | 92% | 144 | missed: 9901; extra: BA1393(ID)×4, Mastercard(COMPANY)×2, BA032(ADDRESS), Terminal 5(ADDRESS) |
| en-support-02 | 1470 | 25 | 21 | 1 | 3 | 0 | 2 | 90% | 88 | missed: Apartment 12, Millrace Court, Old Kilmainham, Dublin 8, D08 X4K7, Tomasz, 4471; extra: MPRN(COMPANY)×2 |
| es-bank-01 | 2148 | 37 | 32 | 3 | 2 | 0 | 1 | 96% | 112 | missed: 4410, Vallès Occidental; extra: 0417 Terrassa(ADDRESS) |
| es-bank-02 | 942 | 19 | 16 | 2 | 1 | 0 | 1 | 95% | 66 | missed: ABANCA; extra: ABANCA Avisos(COMPANY) |
| es-chat-01 | 926 | 14 | 13 | 1 | 0 | 0 | 0 | 100% | 63 |  |
| es-chat-02 | 441 | 9 | 7 | 0 | 2 | 0 | 1 | 83% | 23 | missed: grupo alcor, transportes beltran; extra: beltran(PERSON) |
| es-cv-01 | 3673 | 48 | 39 | 3 | 6 | 0 | 10 | 86% | 204 | missed: Zamudio (Bizkaia), 4,3 M€, Coslada (Madrid), Bermeo (Bizkaia), Kaiku, Sestao; extra: Coordinadora(COMPANY), 2020-2021(NUMBER), 2008-2013(NUMBER), 2011-2012(NUMBER), 2013-2015(NUMBER), S/4HANA(COMPANY), Cámara de Comercio de Bilbao(COMPANY), 05/2028(DATE), Kaiku de Sestao(COMPANY), septiembre de 2026(DATE) |
| es-cv-02 | 2268 | 29 | 24 | 4 | 1 | 0 | 2 | 96% | 115 | missed: Pereira, Colombia; extra: 11/2027(DATE), INAEM(COMPANY) |
| es-insurance-01 | 4026 | 53 | 47 | 4 | 1 | 1 | 4 | 94% | 228 | missed: MU-80.417; wrong type: J-2841; extra: Consorcio de Compensación de Seguros(COMPANY), Dirección Técnica de(COMPANY), Seguros y Reaseguros. Entidad(COMPANY), General de Seguros y Fondos de Pensiones. Santamaría Ortuño Correduría de Seguros, S.L.(COMPANY) |
| es-insurance-02 | 2170 | 33 | 28 | 5 | 0 | 0 | 3 | 96% | 119 | extra: Turia Hogar Plus(COMPANY), Hogar(COMPANY), Aseguradora Turia, S.A. de Seguros y Reaseguros. Inscrita(COMPANY) |
| es-invoice-01 | 1987 | 26 | 22 | 1 | 3 | 0 | 2 | 91% | 114 | missed: C/ Telletxe, 12, bajo · 48991 Getxo (Bizkaia), P-26/0412, 48/IF-02917; extra: FRA 2026(ID), 02917 (Gobierno Vasco)(ADDRESS) |
| es-invoice-02 | 4391 | 65 | 52 | 5 | 8 | 0 | 0 | 93% | 298 | missed: 0,083921 €, 0,012575 €, 0,189450 €, 0,142310 €, 0,098760 €, 0,026630 €, 0,012742 €, Apartado de Correos 4127, 50080 Zaragoza |
| es-lease-01 | 4441 | 57 | 49 | 6 | 2 | 0 | 2 | 97% | 278 | missed: 684, 31.877; extra: I. Que Berzosa Anguita Patrimonio, S.L.(COMPANY), .p. Berzosa Anguita Patrimonio, S.L.(COMPANY) |
| es-lease-02 | 989 | 24 | 22 | 1 | 1 | 0 | 0 | 98% | 64 | missed: C/ El Peso 27, 1º, 14900 Lucena (Córdoba) |
| es-letter-01 | 2075 | 33 | 31 | 0 | 2 | 0 | 1 | 96% | 124 | missed: 3.412, ATL-2026/0381; extra: BUROFAX CON ACUSE DE(COMPANY) |
| es-letter-02 | 2105 | 26 | 25 | 1 | 0 | 0 | 1 | 99% | 109 | extra: puente del Pilar(ADDRESS) |
| es-medical-01 | 4463 | 40 | 35 | 3 | 2 | 0 | 3 | 94% | 226 | missed: 36208 Vigo (Pontevedra), Costel Munteanu; extra: Vigo
Hospital Álvaro Cunqueiro(COMPANY), cardiaca(COMPANY), Cardiaca(COMPANY) |
| es-medical-02 | 1350 | 21 | 18 | 2 | 1 | 0 | 0 | 98% | 83 | missed: LABORATORIO IBARZ |
| es-payslip-01 | 4002 | 35 | 31 | 1 | 3 | 0 | 1 | 94% | 212 | missed: Trabanca, Rúa Ourense, 9, 2º esq. - 36630 Cambados (Pontevedra), PO-31.906; extra: Planta de Trabanca(COMPANY) |
| es-payslip-02 | 1557 | 26 | 22 | 2 | 2 | 0 | 1 | 94% | 107 | missed: EMBUTIDOS Y SALAZONES, A. M. Ciobanu; extra: C.I(COMPANY) |
| es-support-01 | 2731 | 37 | 35 | 0 | 2 | 0 | 3 | 94% | 170 | missed: 08841527, 8036; extra: Mastercard(COMPANY)×2, AVE(COMPANY) |
| es-support-02 | 1474 | 20 | 19 | 1 | 0 | 0 | 0 | 100% | 81 |  |
| fr-bank-01 | 2050 | 38 | 32 | 1 | 5 | 0 | 2 | 91% | 142 | missed: Bayonne Saint-Esprit, Bât. C - Appt 27, 30857, 70037, 77; extra: Agence de Bayonne Saint-Esprit(COMPANY)×2 |
| fr-bank-02 | 899 | 19 | 17 | 2 | 0 | 0 | 4 | 91% | 73 | extra: SEPA(PERSON)×2, Agence Schiltigheim Centre(COMPANY), Centre(COMPANY) |
| fr-chat-01 | 965 | 14 | 10 | 1 | 3 | 0 | 1 | 87% | 81 | missed: leclerc, jo, 3e etage; extra: Momo(COMPANY) |
| fr-chat-02 | 413 | 9 | 9 | 0 | 0 | 0 | 0 | 100% | 25 |  |
| fr-cv-01 | 3471 | 57 | 46 | 3 | 7 | 1 | 4 | 89% | 222 | missed: 4,2 M€, Pampelune, ETCHEVERRY Maitena, AFTRAL, IUT de Bordeaux, IUT de Bayonne et du Pays basque, Ustaritz; wrong type: Irun; extra: Micro-entreprise ETCHEVERRY Maitena(COMPANY), SIRET(ADDRESS), AFTRAL Bordeaux(COMPANY), Leroy Merlin Mérignac(COMPANY) |
| fr-cv-02 | 2307 | 36 | 30 | 2 | 3 | 1 | 2 | 90% | 146 | missed: Nord vaudois, Suisse, Morat; wrong type: Guin; extra: 2022-2024(NUMBER), 2015          Cours de chef d'équipe(ADDRESS) |
| fr-insurance-01 | 4012 | 71 | 64 | 4 | 3 | 0 | 2 | 97% | 260 | missed: Le Mans, 775 652 126, 440 048 882; extra: RCS Le Mans 775 652 126(ID), RCS Le Mans 440 048 882(ID) |
| fr-insurance-02 | 2190 | 39 | 31 | 6 | 2 | 0 | 1 | 96% | 151 | missed: Bât. C - 3e étage - Appt 32, appt 42; extra: Multirisque Habitation Sérénité(COMPANY) |
| fr-invoice-01 | 2142 | 41 | 37 | 3 | 1 | 0 | 2 | 97% | 154 | missed: 833 304 132; extra: Atlantic(COMPANY), RCS Quimper 833 304 132(ID) |
| fr-invoice-02 | 4038 | 65 | 51 | 10 | 4 | 0 | 9 | 92% | 273 | missed: RESIDENCE LE BELVEDERE BAT A APPT 207, Libre réponse n° 59252, 75443 Paris Cedex 09, TSA 70233 - 34967 Montpellier Cedex 2, 619 326 754; extra: Lumio Énergie
VOTRE(COMPANY), Lumio Heures Creuses(COMPANY), Linky(PERSON), pleines  48(ADDRESS), Dépannage électricité Enedis(COMPANY), 34967 Montpellier Cedex 2.(ADDRESS), 59252(NUMBER), 75443 Paris Cedex 09.(ADDRESS), RCS Montpellier 619 326 754(ID) |
| fr-lease-01 | 4331 | 71 | 54 | 5 | 10 | 2 | 10 | 84% | 278 | missed: 204, 477 897 292, 433 002 565, SYLLA, FERREIRA, CHU de Montpellier, Bâtiment : B     Étage : 2e     Porte : 204, 1er octobre, 41 avenue Roger Salengro, Escalier 2, 94500 Champigny-sur-Marne, soixante-cinq mille cinq cent vingt euros; wrong type: AOGI, FNAIM; extra: AOGI(PERSON)×2, RCS de Montpellier sous le numéro 477 897 292(ID), AOGI GESTION LOCATIVE(COMPANY), SYLLA-FERREIRA LOT(PERSON), MLS(COMPANY), IFS(COMPANY), AFS(COMPANY), SARL(PERSON), RCS Montpellier 433 002 565(ID) |
| fr-lease-02 | 1025 | 23 | 21 | 2 | 0 | 0 | 0 | 100% | 97 |  |
| fr-letter-01 | 2178 | 42 | 37 | 3 | 1 | 1 | 0 | 96% | 154 | missed: 0417-B32; wrong type: Aydın |
| fr-letter-02 | 2076 | 24 | 21 | 1 | 1 | 1 | 4 | 88% | 130 | missed: Lucie-Aubrac; wrong type: Kerleroux; extra: Rezéens(PERSON), rose(PERSON), école élémentaire
Lucie-Aubrac(COMPANY), dentaire(COMPANY) |
| fr-medical-01 | 4423 | 61 | 54 | 4 | 2 | 1 | 4 | 94% | 306 | missed: Maison de santé des Épis, Sin-le-Noble; wrong type: Cuincy; extra: Confrère(PERSON)×2, -Vaast(ADDRESS), FINESS(ADDRESS) |
| fr-medical-02 | 1306 | 23 | 18 | 3 | 2 | 0 | 2 | 92% | 73 | missed: COULIBALY, Fatoumata; extra: Rennes Alma(ADDRESS), COULIBALY
Fatoumata(PERSON) |
| fr-payslip-01 | 4459 | 40 | 34 | 3 | 3 | 0 | 4 | 92% | 411 | missed: AG2R, Bas-Rhin, 778 972 976; extra: Erstein(COMPANY), AG2R Agirc-Arrco(COMPANY), CPAM du Bas-Rhin(COMPANY), RCS Strasbourg 778 972 976(ID) |
| fr-payslip-02 | 1652 | 27 | 24 | 1 | 2 | 0 | 3 | 91% | 126 | missed: Bretagne, PRO BTP; extra: SIRET(ADDRESS), URSSAF Bretagne(COMPANY), Mutuelle PRO BTP(COMPANY) |
| fr-support-01 | 2718 | 36 | 27 | 5 | 4 | 0 | 5 | 89% | 168 | missed: Chronopost, 8538, Lille Métropole, 676 336 068; extra: Mastercard(COMPANY)×2, Lenovo(COMPANY), RCS Lille Métropole 676 336 068(ID), SignalConso(COMPANY) |
| fr-support-02 | 1404 | 20 | 19 | 1 | 0 | 0 | 1 | 98% | 87 | extra: boulanger(PERSON) |
