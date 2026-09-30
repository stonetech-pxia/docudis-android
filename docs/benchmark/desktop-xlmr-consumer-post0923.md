# NER benchmark (desktop, Python onnxruntime)

- Model: xlm-roberta-base-ner-docudis
- Platform: windows "Windows 11 Famille" 10.0 (Build 26200), CPU, onnxruntime via bench_server.py
- Cases: 60, expected entities: 2138
- Overall: recall 92%, precision 92%, F1 92% → reliability **A**; 94 ms per 1000 chars → speed **A**

Grades: reliability by F1 (A ≥ 90%, B ≥ 75%, C ≥ 50%, D below); speed by ms per 1000 characters on this platform (A < 300, B < 1000, C < 3000, D above).

## By language

| Language | Cases | Expected | Found | False pos. | Recall | Precision | F1 | Reliability | ms/1000 chars | Speed |
|---|---|---|---|---|---|---|---|---|---|---|
| en | 20 | 730 | 674 | 78 | 92% | 91% | 92% | A | 106 | A |
| es | 20 | 652 | 607 | 57 | 93% | 93% | 93% | A | 83 | A |
| fr | 20 | 756 | 696 | 62 | 92% | 93% | 93% | A | 94 | A |

## By category

| Category | Cases | Expected | Found | False pos. | Recall | Precision | F1 | Reliability | ms/1000 chars | Speed |
|---|---|---|---|---|---|---|---|---|---|---|
| bank | 6 | 172 | 159 | 16 | 92% | 91% | 92% | A | 97 | A |
| chat | 6 | 77 | 69 | 4 | 90% | 97% | 93% | A | 95 | A |
| cv | 6 | 244 | 217 | 34 | 89% | 89% | 89% | B | 96 | A |
| insurance | 6 | 307 | 287 | 17 | 93% | 95% | 94% | A | 87 | A |
| invoice | 6 | 300 | 273 | 37 | 91% | 91% | 91% | A | 114 | A |
| lease | 6 | 241 | 223 | 22 | 93% | 92% | 93% | A | 94 | A |
| letter | 6 | 196 | 186 | 13 | 95% | 94% | 95% | A | 77 | A |
| medical | 6 | 228 | 216 | 15 | 95% | 95% | 95% | A | 80 | A |
| payslip | 6 | 194 | 180 | 17 | 93% | 92% | 92% | A | 111 | A |
| support | 6 | 179 | 167 | 22 | 93% | 90% | 92% | A | 82 | A |

## Per case

| Case | Chars | Expected | Hit | Partial | Missed | Wrong type | False pos. | F1 | ms | Notes |
|---|---|---|---|---|---|---|---|---|---|---|
| en-bank-01 | 2033 | 37 | 33 | 2 | 2 | 0 | 3 | 93% | 210 | missed: NatWest, SVL-002931-AM; extra: NatWest
Premier Banking(COMPANY), England(ADDRESS), Wales No.(ADDRESS) |
| en-bank-02 | 865 | 22 | 17 | 2 | 3 | 0 | 4 | 85% | 89 | missed: 7702, 0817, Harrisburg; extra: Wire Services(COMPANY), Airstream(COMPANY), Relationship Banker, Harrisburg Main Office(ADDRESS), FDIC(COMPANY) |
| en-chat-01 | 952 | 21 | 20 | 1 | 0 | 0 | 1 | 99% | 78 | extra: van mans(PERSON) |
| en-chat-02 | 470 | 10 | 7 | 0 | 1 | 2 | 1 | 73% | 33 | missed: reggie; wrong type: brightwater, halvorsen; extra: brightwater(ADDRESS) |
| en-cv-01 | 3677 | 40 | 33 | 2 | 4 | 1 | 13 | 81% | 338 | missed: Georgia, AACN, Sigma Theta Tau, Jacmel, Haiti; wrong type: Hôpital Saint-Michel; extra: MSN(COMPANY)×2, Registered Nurse, Georgia Board of Nursing, License No.(ADDRESS), 06/2027(DATE), ACLS(COMPANY), BLS(COMPANY), 03/2026(DATE), CLABSI(COMPANY), COVID ICU(COMPANY), 12/2027)(DATE), SKILLS
Epic(COMPANY), BCMA(COMPANY), MHA(COMPANY) |
| en-cv-02 | 2742 | 34 | 28 | 4 | 2 | 0 | 2 | 95% | 423 | missed: Tesco, Harbour Road, Portishead BS20 7DD; extra: Tesco Distribution Centre(COMPANY), BTEC Level(COMPANY) |
| en-insurance-01 | 4270 | 71 | 63 | 0 | 7 | 1 | 4 | 91% | 463 | missed: 7 Cois Cuain, Bearna, Premium Credit, 3308, 6120, C Ní Dhomhnaill, O Adebayo; wrong type: 02/11/1985; extra: 7 Cois Cuain
                 Bearna(ADDRESS), C Ní Dhomhnaill & O Adebayo(COMPANY), Central Bank of Ireland(COMPANY), Ireland No.(ADDRESS) |
| en-insurance-02 | 2210 | 40 | 38 | 0 | 2 | 0 | 1 | 96% | 165 | missed: PLM/SHF/118264, 4402; extra: Their Sheffield(ADDRESS) |
| en-invoice-01 | 2150 | 44 | 39 | 3 | 2 | 0 | 4 | 94% | 220 | missed: Q-1187, WISNIEWSKA; extra: Worcester Bosch Greenstar(COMPANY), 24781 WISNIEWSKA(ADDRESS), O&D Building Services Ltd. Registered(COMPANY), England(ADDRESS) |
| en-invoice-02 | 4444 | 59 | 46 | 4 | 8 | 1 | 15 | 85% | 800 | missed: P.O. Box 660418, Dallas, TX 75266-0418, 2217 LARKSPUR TRL APT 1406, PLANO TX 75074, 1554, $0.098700, $0.025510, 13.9 cents, Texas, 2217 LARKSPUR TRL APT 1406 PLANO TX 75074; wrong type: Oncor; extra: Aug(DATE)×2, Oncor(ADDRESS), Sep(DATE), Oct(DATE), Nov(DATE), Dec(DATE), Jan(DATE), Feb(DATE), Mar(DATE), Apr(DATE), May(DATE), Jun(DATE) … +2 more |
| en-lease-01 | 4358 | 45 | 41 | 1 | 3 | 0 | 5 | 93% | 402 | missed: 1184 Neil Avenue, Apt. 2C, Columbus, OH 43201, pay.hallgrenpm.com, AEP Ohio; extra: Ohio DL(ADDRESS)×2, Ohio Revised Code 5321.16. Tenant(ADDRESS), Rules and Regulations(COMPANY), WZ  MD(PERSON) |
| en-lease-02 | 977 | 21 | 19 | 1 | 1 | 0 | 0 | 98% | 133 | missed: 0214 |
| en-letter-01 | 2190 | 42 | 39 | 1 | 2 | 0 | 3 | 95% | 140 | missed: Whitlock, Harcourt & Webb Lettings Ltd; extra: Mr D. Whitlock
Branch Manager
Harcourt & Webb Lettings Ltd(COMPANY), Leicester City Council(ADDRESS), Deposit Protection(COMPANY) |
| en-letter-02 | 2168 | 29 | 26 | 1 | 2 | 0 | 1 | 95% | 154 | missed: Leeds, Mehta; extra: rose(PERSON) |
| en-medical-01 | 4464 | 53 | 45 | 5 | 3 | 0 | 4 | 94% | 339 | missed: Leeds Teaching Hospitals NHS Trust, St James's University Hospital, 80-2214; extra: The Leeds Teaching Hospitals NHS Trust
St James's University Hospital(COMPANY), MDT(COMPANY), Clinic C(COMPANY), Dictated(PERSON) |
| en-medical-02 | 1438 | 30 | 25 | 4 | 0 | 1 | 2 | 94% | 128 | wrong type: Mylan; extra: TJO(COMPANY), NDC 00378-1805(ADDRESS) |
| en-payslip-01 | 3821 | 38 | 37 | 0 | 1 | 0 | 3 | 95% | 586 | missed: $27.4500; extra: Illinois(ADDRESS), BCBSIL PPO EE(COMPANY), +1       86.50(NUMBER) |
| en-payslip-02 | 1275 | 28 | 23 | 2 | 3 | 0 | 1 | 93% | 100 | missed: HARCASTLE JOINERY, SHOPFITTING LTD, 20-49; extra: HARCASTLE JOINERY &
SHOPFITTING LTD(COMPANY) |
| en-support-01 | 2759 | 41 | 38 | 1 | 2 | 0 | 9 | 90% | 219 | missed: British Airways, 9901; extra: BA1393(ID)×3, Mastercard(COMPANY)×2, British Airways Customer Relations(COMPANY), BA032(ADDRESS), Manchester on BA(ADDRESS), Terminal 5(ADDRESS) |
| en-support-02 | 1470 | 25 | 22 | 1 | 2 | 0 | 2 | 93% | 112 | missed: Tomasz, 4471; extra: MPRN(COMPANY)×2 |
| es-bank-01 | 2148 | 37 | 31 | 4 | 2 | 0 | 2 | 95% | 154 | missed: 4410, Vallès Occidental; extra: Oficina 0417 Terrassa(ADDRESS), Registro Mercantil de Alicante(ADDRESS) |
| es-bank-02 | 942 | 19 | 17 | 1 | 1 | 0 | 1 | 95% | 103 | missed: ABANCA; extra: ABANCA Avisos(COMPANY) |
| es-chat-01 | 926 | 14 | 13 | 1 | 0 | 0 | 0 | 100% | 102 |  |
| es-chat-02 | 441 | 9 | 7 | 0 | 2 | 0 | 1 | 83% | 32 | missed: grupo alcor, transportes beltran; extra: beltran(PERSON) |
| es-cv-01 | 3673 | 48 | 39 | 2 | 7 | 0 | 11 | 84% | 308 | missed: Zamudio (Bizkaia), 4,3 M€, Coslada (Madrid), Bermeo (Bizkaia), Sarriko, Kaiku, Sestao; extra: Coordinadora(COMPANY), 2020-2021(NUMBER), Empresa, Sarriko(ADDRESS), 2008-2013(NUMBER), 2011-2012(NUMBER), 2013-2015(NUMBER), S/4HANA(COMPANY), Cámara de Comercio de Bilbao(COMPANY), 05/2028(DATE), Kaiku de Sestao(COMPANY), septiembre de 2026(DATE) |
| es-cv-02 | 2268 | 29 | 25 | 3 | 1 | 0 | 2 | 96% | 152 | missed: Pereira, Colombia; extra: 11/2027(DATE), INAEM(COMPANY) |
| es-insurance-01 | 4026 | 53 | 47 | 4 | 1 | 1 | 4 | 94% | 316 | missed: MU-80.417; wrong type: J-2841; extra: Consorcio de Compensación de Seguros(COMPANY), Dirección Técnica de Automóviles(COMPANY), General de Seguros y Fondos de Pensiones. Santamaría Ortuño Correduría de Seguros, S.L.(COMPANY), Registro Mercantil de Murcia(ADDRESS) |
| es-insurance-02 | 2170 | 33 | 27 | 4 | 2 | 0 | 5 | 91% | 168 | missed: Sanchis, Beltrán y Asociados, S.L.P., Valencia; extra: Turia Hogar Plus(COMPANY), Beltrán y Asociados, S.L.P. El(COMPANY), Hogar(COMPANY), Aseguradora Turia, S.A. de Seguros y Reaseguros. Inscrita(COMPANY), Registro Mercantil de Valencia, Tomo 6.128, Folio 44(ADDRESS) |
| es-invoice-01 | 1987 | 26 | 22 | 1 | 3 | 0 | 2 | 91% | 165 | missed: C/ Telletxe, 12, bajo · 48991 Getxo (Bizkaia), P-26/0412, 48/IF-02917; extra: FRA 2026(ID), 02917 (Gobierno Vasco)(ADDRESS) |
| es-invoice-02 | 4391 | 65 | 51 | 5 | 9 | 0 | 5 | 90% | 414 | missed: 0,083921 €, 0,012575 €, 0,189450 €, 0,142310 €, 0,098760 €, 0,026630 €, 0,012742 €, Apartado de Correos 4127, 50080 Zaragoza, Aragón; extra: Servicio de Reclamaciones, Apartado de Correos 4127(ADDRESS), Junta Arbitral de Consumo de Aragón(ADDRESS), Minas del Gobierno de Aragón(ADDRESS), Lumbre Energía, S.L.U. Domicilio(COMPANY), Registro Mercantil de Zaragoza, Tomo 4.312, Folio 87(ADDRESS) |
| es-lease-01 | 4441 | 57 | 49 | 6 | 2 | 0 | 7 | 93% | 404 | missed: 684, 31.877; extra: Registro Mercantil de Madrid(ADDRESS), Madrid D.(ADDRESS), I. Que Berzosa Anguita Patrimonio, S.L.(COMPANY), 14 de Madrid(ADDRESS), Agencia de Vivienda Social de la Comunidad de Madrid(ADDRESS), .p. Berzosa Anguita Patrimonio, S.L.(COMPANY), R.M. de Madrid(ADDRESS) |
| es-lease-02 | 989 | 24 | 23 | 1 | 0 | 0 | 0 | 100% | 92 |  |
| es-letter-01 | 2075 | 33 | 30 | 1 | 2 | 0 | 3 | 93% | 155 | missed: 3.412, ATL-2026/0381; extra: BUROFAX CON ACUSE DE RECIBO Y CERTIFICACIÓN(COMPANY), Servicio de Disciplina Urbanística del Ayuntamiento de València(ADDRESS), 14 de València(ADDRESS) |
| es-letter-02 | 2105 | 26 | 26 | 0 | 0 | 0 | 1 | 98% | 162 | extra: puente del Pilar, del 10(ADDRESS) |
| es-medical-01 | 4463 | 40 | 35 | 3 | 2 | 0 | 4 | 93% | 328 | missed: 36208 Vigo (Pontevedra), Costel Munteanu; extra: Vigo
Hospital Álvaro Cunqueiro(COMPANY), Concello de Vigo(ADDRESS), cardiaca(COMPANY), Cardiaca(COMPANY) |
| es-medical-02 | 1350 | 21 | 17 | 3 | 1 | 0 | 0 | 98% | 112 | missed: LABORATORIO IBARZ |
| es-payslip-01 | 4002 | 35 | 31 | 1 | 3 | 0 | 3 | 92% | 315 | missed: Trabanca, Rúa Ourense, 9, 2º esq. - 36630 Cambados (Pontevedra), PO-31.906; extra: Planta de Trabanca(COMPANY), BOP de Pontevedra(ADDRESS), Registro Mercantil de Pontevedra(ADDRESS) |
| es-payslip-02 | 1557 | 26 | 20 | 4 | 2 | 0 | 1 | 94% | 148 | missed: ARLANZÓN, S.L., A. M. Ciobanu; extra: C.I(COMPANY) |
| es-support-01 | 2731 | 37 | 31 | 2 | 4 | 0 | 5 | 90% | 226 | missed: Vueling, 08841527, 8036, 41011 Sevilla; extra: Mastercard(COMPANY)×2, Vueling Atención(COMPANY), 2219 de Sevilla(ADDRESS), AVE(COMPANY) |
| es-support-02 | 1474 | 20 | 19 | 1 | 0 | 0 | 0 | 100% | 116 |  |
| fr-bank-01 | 2050 | 38 | 32 | 1 | 5 | 0 | 2 | 91% | 200 | missed: Bayonne Saint-Esprit, Bât. C - Appt 27, 30857, 70037, 77; extra: Agence de Bayonne Saint-Esprit(COMPANY)×2 |
| fr-bank-02 | 899 | 19 | 17 | 2 | 0 | 0 | 4 | 91% | 107 | extra: SEPA(PERSON)×2, Agence Schiltigheim Centre(COMPANY), Centre(COMPANY) |
| fr-chat-01 | 965 | 14 | 10 | 1 | 3 | 0 | 1 | 87% | 112 | missed: leclerc, jo, 3e etage; extra: Momo(COMPANY) |
| fr-chat-02 | 413 | 9 | 9 | 0 | 0 | 0 | 0 | 100% | 38 |  |
| fr-cv-01 | 3471 | 57 | 46 | 3 | 7 | 1 | 4 | 89% | 326 | missed: 4,2 M€, Pampelune, ETCHEVERRY Maitena, AFTRAL, IUT de Bordeaux, IUT de Bayonne et du Pays basque, Ustaritz; wrong type: Irun; extra: Micro-entreprise ETCHEVERRY Maitena(COMPANY), SIRET(ADDRESS), AFTRAL Bordeaux(COMPANY), Leroy Merlin Mérignac(COMPANY) |
| fr-cv-02 | 2307 | 36 | 29 | 3 | 3 | 1 | 2 | 90% | 200 | missed: Nord vaudois, Suisse, Morat; wrong type: Guin; extra: 2022-2024(NUMBER), 2015          Cours de chef d'équipe(ADDRESS) |
| fr-insurance-01 | 4012 | 71 | 64 | 3 | 4 | 0 | 2 | 96% | 347 | missed: Le Mans, 775 652 126, 440 048 882, 160 rue Henri Champion, 72030 Le Mans Cedex 9; extra: RCS Le Mans 775 652 126(ID), RCS Le Mans 440 048 882(ID) |
| fr-insurance-02 | 2190 | 39 | 30 | 7 | 2 | 0 | 1 | 96% | 189 | missed: Bât. C - 3e étage - Appt 32, appt 42; extra: Multirisque Habitation Sérénité(COMPANY) |
| fr-invoice-01 | 2142 | 41 | 37 | 3 | 1 | 0 | 2 | 97% | 218 | missed: 833 304 132; extra: Atlantic Zénéo(COMPANY), RCS Quimper 833 304 132(ID) |
| fr-invoice-02 | 4038 | 65 | 52 | 10 | 3 | 0 | 9 | 93% | 359 | missed: Libre réponse n° 59252, 75443 Paris Cedex 09, TSA 70233 - 34967 Montpellier Cedex 2, 619 326 754; extra: Lumio Énergie
VOTRE FACTURE D'ÉLECTRICITÉ(COMPANY), Lumio Heures Creuses(COMPANY), Linky(PERSON), Heures pleines  48 213(ADDRESS), Dépannage électricité Enedis(COMPANY), 34967 Montpellier Cedex 2. Si(ADDRESS), 59252(NUMBER), 75443 Paris Cedex 09.(ADDRESS), RCS Montpellier 619 326 754(ID) |
| fr-lease-01 | 4331 | 71 | 54 | 5 | 10 | 2 | 10 | 84% | 371 | missed: 204, 477 897 292, 433 002 565, SYLLA, FERREIRA, CHU de Montpellier, Bâtiment : B     Étage : 2e     Porte : 204, 1er octobre, 41 avenue Roger Salengro, Escalier 2, 94500 Champigny-sur-Marne, soixante-cinq mille cinq cent vingt euros; wrong type: AOGI, FNAIM; extra: AOGI(PERSON)×2, RCS de Montpellier sous le numéro 477 897 292(ID), AOGI GESTION LOCATIVE(COMPANY), SYLLA-FERREIRA LOT(PERSON), MLS(COMPANY), IFS(COMPANY), AFS(COMPANY), SARL(PERSON), RCS Montpellier 433 002 565(ID) |
| fr-lease-02 | 1025 | 23 | 21 | 2 | 0 | 0 | 0 | 100% | 111 |  |
| fr-letter-01 | 2178 | 42 | 37 | 3 | 1 | 1 | 1 | 95% | 195 | missed: 0417-B32; wrong type: Aydın; extra: CAF de Lyon(ADDRESS) |
| fr-letter-02 | 2076 | 24 | 21 | 1 | 1 | 1 | 4 | 88% | 179 | missed: Lucie-Aubrac; wrong type: Kerleroux; extra: Rezéens(PERSON), rose(PERSON), école élémentaire
Lucie-Aubrac(COMPANY), dentaire(COMPANY) |
| fr-medical-01 | 4423 | 61 | 56 | 2 | 2 | 1 | 3 | 95% | 386 | missed: Sin-le-Noble, 6 avenue de Verdun, 59300 Valenciennes; wrong type: Cuincy; extra: Confrère(PERSON)×2, FINESS(ADDRESS) |
| fr-medical-02 | 1306 | 23 | 19 | 2 | 2 | 0 | 2 | 92% | 100 | missed: COULIBALY, Fatoumata; extra: Site Rennes Alma(ADDRESS), COULIBALY
Fatoumata(PERSON) |
| fr-payslip-01 | 4459 | 40 | 33 | 4 | 3 | 0 | 6 | 90% | 546 | missed: AG2R, Bas-Rhin, 778 972 976; extra: EMPLOYEUR
BISCUITERIE HEINRICH SAS(COMPANY), Erstein(COMPANY), Atelier 2(COMPANY), AG2R Agirc-Arrco(COMPANY), CPAM du Bas-Rhin(COMPANY), RCS Strasbourg 778 972 976(ID) |
| fr-payslip-02 | 1652 | 27 | 23 | 2 | 2 | 0 | 3 | 91% | 154 | missed: Bretagne, PRO BTP; extra: SIRET(ADDRESS), URSSAF Bretagne(COMPANY), Mutuelle PRO BTP(COMPANY) |
| fr-support-01 | 2718 | 36 | 27 | 5 | 4 | 0 | 5 | 89% | 222 | missed: Chronopost, 8538, Lille Métropole, 676 336 068; extra: Mastercard(COMPANY)×2, Lenovo IdeaPad Slim(COMPANY), RCS Lille Métropole 676 336 068(ID), SignalConso(COMPANY) |
| fr-support-02 | 1404 | 20 | 19 | 1 | 0 | 0 | 1 | 98% | 125 | extra: boulanger(PERSON) |
