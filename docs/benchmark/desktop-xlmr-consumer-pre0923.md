# NER benchmark (desktop, Python onnxruntime)

- Model: xlm-roberta-base-ner-docudis
- Platform: windows "Windows 11 Famille" 10.0 (Build 26200), CPU, onnxruntime via bench_server.py
- Cases: 60, expected entities: 2138
- Overall: recall 92%, precision 92%, F1 92% → reliability **A**; 497 ms per 1000 chars → speed **B**

Grades: reliability by F1 (A ≥ 90%, B ≥ 75%, C ≥ 50%, D below); speed by ms per 1000 characters on this platform (A < 300, B < 1000, C < 3000, D above).

## By language

| Language | Cases | Expected | Found | False pos. | Recall | Precision | F1 | Reliability | ms/1000 chars | Speed |
|---|---|---|---|---|---|---|---|---|---|---|
| en | 20 | 730 | 673 | 81 | 92% | 91% | 92% | A | 644 | B |
| es | 20 | 652 | 604 | 61 | 93% | 92% | 93% | A | 712 | B |
| fr | 20 | 756 | 697 | 67 | 92% | 93% | 92% | A | 133 | A |

## By category

| Category | Cases | Expected | Found | False pos. | Recall | Precision | F1 | Reliability | ms/1000 chars | Speed |
|---|---|---|---|---|---|---|---|---|---|---|
| bank | 6 | 172 | 158 | 17 | 92% | 91% | 91% | A | 577 | B |
| chat | 6 | 77 | 68 | 5 | 88% | 96% | 92% | A | 372 | B |
| cv | 6 | 244 | 217 | 37 | 89% | 88% | 89% | B | 292 | A |
| insurance | 6 | 307 | 288 | 19 | 94% | 95% | 94% | A | 545 | B |
| invoice | 6 | 300 | 273 | 37 | 91% | 91% | 91% | A | 614 | B |
| lease | 6 | 241 | 221 | 25 | 92% | 92% | 92% | A | 490 | B |
| letter | 6 | 196 | 185 | 15 | 94% | 93% | 94% | A | 475 | B |
| medical | 6 | 228 | 217 | 15 | 95% | 95% | 95% | A | 514 | B |
| payslip | 6 | 194 | 180 | 17 | 93% | 92% | 92% | A | 493 | B |
| support | 6 | 179 | 167 | 22 | 93% | 90% | 92% | A | 541 | B |

## Per case

| Case | Chars | Expected | Hit | Partial | Missed | Wrong type | False pos. | F1 | ms | Notes |
|---|---|---|---|---|---|---|---|---|---|---|
| en-bank-01 | 2033 | 37 | 33 | 2 | 2 | 0 | 3 | 93% | 230 | missed: NatWest, SVL-002931-AM; extra: NatWest
Premier Banking(COMPANY), England(ADDRESS), Wales No.(ADDRESS) |
| en-bank-02 | 865 | 22 | 17 | 2 | 3 | 0 | 4 | 85% | 99 | missed: 7702, 0817, Harrisburg; extra: Wire Services(COMPANY), Airstream(COMPANY), Relationship Banker, Harrisburg Main Office(ADDRESS), FDIC(COMPANY) |
| en-chat-01 | 952 | 21 | 20 | 0 | 1 | 0 | 2 | 95% | 104 | missed: 14 Birchfield Court, Evington Road, Leicester LE2 1HJ; extra: flat is 14 Birchfield Court, Evington Road, Leicester (ADDRESS), van mans(PERSON) |
| en-chat-02 | 470 | 10 | 7 | 0 | 1 | 2 | 1 | 73% | 50 | missed: reggie; wrong type: brightwater, halvorsen; extra: the brightwater(ADDRESS) |
| en-cv-01 | 3677 | 40 | 33 | 2 | 5 | 0 | 14 | 81% | 317 | missed: Georgia, AACN, Sigma Theta Tau, Hôpital Saint-Michel, Jacmel, Haiti; extra: MSN(COMPANY)×2, Registered Nurse, Georgia Board of Nursing, License No.(ADDRESS), 06/2027(DATE), ACLS(COMPANY), BLS(COMPANY), 03/2026(DATE), CLABSI(COMPANY), COVID ICU(COMPANY), 12/2027)(DATE), on, Hôpital Saint-Michel(ADDRESS), SKILLS
Epic(COMPANY), BCMA(COMPANY) … +1 more |
| en-cv-02 | 2742 | 34 | 26 | 6 | 2 | 0 | 2 | 95% | 564 | missed: Tesco, Harbour Road, Portishead BS20 7DD; extra: Tesco Distribution Centre(COMPANY), BTEC Level(COMPANY) |
| en-insurance-01 | 4270 | 71 | 61 | 2 | 7 | 1 | 4 | 91% | 3366 | missed: 7 Cois Cuain, Bearna, Premium Credit, 3308, 6120, C Ní Dhomhnaill, O Adebayo; wrong type: 02/11/1985; extra: 7 Cois Cuain
                 Bearna(ADDRESS), C Ní Dhomhnaill & O Adebayo(COMPANY), Central Bank of Ireland(COMPANY), Ireland No.(ADDRESS) |
| en-insurance-02 | 2210 | 40 | 35 | 3 | 2 | 0 | 1 | 96% | 1686 | missed: PLM/SHF/118264, 4402; extra: Their Sheffield(ADDRESS) |
| en-invoice-01 | 2150 | 44 | 39 | 3 | 2 | 0 | 4 | 94% | 2104 | missed: Q-1187, WISNIEWSKA; extra: Worcester Bosch Greenstar(COMPANY), 24781 WISNIEWSKA(ADDRESS), O&D Building Services Ltd. Registered(COMPANY), England(ADDRESS) |
| en-invoice-02 | 4444 | 59 | 46 | 4 | 8 | 1 | 15 | 85% | 4411 | missed: P.O. Box 660418, Dallas, TX 75266-0418, 2217 LARKSPUR TRL APT 1406, PLANO TX 75074, 1554, $0.098700, $0.025510, 13.9 cents, Texas, 2217 LARKSPUR TRL APT 1406 PLANO TX 75074; wrong type: Oncor; extra: Aug(DATE)×2, Oncor(ADDRESS), Sep(DATE), Oct(DATE), Nov(DATE), Dec(DATE), Jan(DATE), Feb(DATE), Mar(DATE), Apr(DATE), May(DATE), Jun(DATE) … +2 more |
| en-lease-01 | 4358 | 45 | 41 | 1 | 3 | 0 | 6 | 92% | 2924 | missed: 1184 Neil Avenue, Apt. 2C, Columbus, OH 43201, pay.hallgrenpm.com, AEP Ohio; extra: Ohio DL(ADDRESS)×2, an Ohio(ADDRESS), Ohio Revised Code 5321.16. Tenant(ADDRESS), Rules and Regulations(COMPANY), WZ  MD(PERSON) |
| en-lease-02 | 977 | 21 | 19 | 1 | 1 | 0 | 0 | 98% | 862 | missed: 0214 |
| en-letter-01 | 2190 | 42 | 39 | 1 | 2 | 0 | 3 | 95% | 1527 | missed: Whitlock, Harcourt & Webb Lettings Ltd; extra: Mr D. Whitlock
Branch Manager
Harcourt & Webb Lettings Ltd(COMPANY), Leicester City Council(ADDRESS), Deposit Protection(COMPANY) |
| en-letter-02 | 2168 | 29 | 22 | 5 | 2 | 0 | 1 | 95% | 1607 | missed: Leeds, Mehta; extra: rose(PERSON) |
| en-medical-01 | 4464 | 53 | 43 | 7 | 3 | 0 | 4 | 94% | 3237 | missed: Leeds Teaching Hospitals NHS Trust, St James's University Hospital, 80-2214; extra: The Leeds Teaching Hospitals NHS Trust
St James's University Hospital(COMPANY), MDT(COMPANY), Clinic C(COMPANY), Dictated(PERSON) |
| en-medical-02 | 1438 | 30 | 25 | 4 | 0 | 1 | 2 | 94% | 1083 | wrong type: Mylan; extra: TJO(COMPANY), NDC 00378-1805(ADDRESS) |
| en-payslip-01 | 3821 | 38 | 37 | 0 | 1 | 0 | 3 | 95% | 2686 | missed: $27.4500; extra: Illinois(ADDRESS), BCBSIL PPO EE(COMPANY), +1       86.50(NUMBER) |
| en-payslip-02 | 1275 | 28 | 23 | 2 | 3 | 0 | 1 | 93% | 1041 | missed: HARCASTLE JOINERY, SHOPFITTING LTD, 20-49; extra: HARCASTLE JOINERY &
SHOPFITTING LTD(COMPANY) |
| en-support-01 | 2759 | 41 | 37 | 2 | 2 | 0 | 9 | 90% | 2318 | missed: British Airways, 9901; extra: BA1393(ID)×3, Mastercard(COMPANY)×2, British Airways Customer Relations(COMPANY), on BA032 on(ADDRESS), Manchester on BA(ADDRESS), Terminal 5, the(ADDRESS) |
| en-support-02 | 1470 | 25 | 21 | 2 | 2 | 0 | 2 | 93% | 1135 | missed: Tomasz, 4471; extra: MPRN(COMPANY)×2 |
| es-bank-01 | 2148 | 37 | 30 | 5 | 2 | 0 | 2 | 95% | 1611 | missed: 4410, Vallès Occidental; extra: Oficina 0417 Terrassa(ADDRESS), el Registro Mercantil de Alicante(ADDRESS) |
| es-bank-02 | 942 | 19 | 17 | 1 | 1 | 0 | 1 | 95% | 816 | missed: ABANCA; extra: ABANCA Avisos(COMPANY) |
| es-chat-01 | 926 | 14 | 13 | 1 | 0 | 0 | 0 | 100% | 788 |  |
| es-chat-02 | 441 | 9 | 7 | 0 | 2 | 0 | 1 | 83% | 249 | missed: grupo alcor, transportes beltran; extra: beltran(PERSON) |
| es-cv-01 | 3673 | 48 | 38 | 3 | 7 | 0 | 11 | 84% | 2338 | missed: Zamudio (Bizkaia), 4,3 M€, Coslada (Madrid), Bermeo (Bizkaia), Sarriko, Kaiku, Sestao; extra: Coordinadora(COMPANY), 2020-2021(NUMBER), Empresa, Sarriko(ADDRESS), 2008-2013(NUMBER), 2011-2012(NUMBER), 2013-2015(NUMBER), S/4HANA(COMPANY), Cámara de Comercio de Bilbao(COMPANY), 05/2028(DATE), Kaiku de Sestao(COMPANY), septiembre de 2026(DATE) |
| es-cv-02 | 2268 | 29 | 24 | 4 | 1 | 0 | 2 | 96% | 1587 | missed: Pereira, Colombia; extra: 11/2027(DATE), INAEM(COMPANY) |
| es-insurance-01 | 4026 | 53 | 47 | 4 | 1 | 1 | 5 | 93% | 2944 | missed: MU-80.417; wrong type: J-2841; extra: Consorcio de Compensación de Seguros(COMPANY), Dirección Técnica de Automóviles(COMPANY), Seguros y Reaseguros. Entidad(COMPANY), General de Seguros y Fondos de Pensiones. Santamaría Ortuño Correduría de Seguros, S.L.(COMPANY), el Registro Mercantil de Murcia(ADDRESS) |
| es-insurance-02 | 2170 | 33 | 27 | 4 | 2 | 0 | 5 | 91% | 1745 | missed: Sanchis, Beltrán y Asociados, S.L.P., Valencia; extra: Turia Hogar Plus(COMPANY), Beltrán y Asociados, S.L.P. El(COMPANY), Hogar(COMPANY), Aseguradora Turia, S.A. de Seguros y Reaseguros. Inscrita(COMPANY), el Registro Mercantil de Valencia, Tomo 6.128, Folio 44(ADDRESS) |
| es-invoice-01 | 1987 | 26 | 22 | 1 | 3 | 0 | 2 | 91% | 1354 | missed: C/ Telletxe, 12, bajo · 48991 Getxo (Bizkaia), P-26/0412, 48/IF-02917; extra: FRA 2026(ID), 02917 (Gobierno Vasco)(ADDRESS) |
| es-invoice-02 | 4391 | 65 | 48 | 8 | 9 | 0 | 5 | 90% | 3345 | missed: 0,083921 €, 0,012575 €, 0,189450 €, 0,142310 €, 0,098760 €, 0,026630 €, 0,012742 €, Apartado de Correos 4127, 50080 Zaragoza, Aragón; extra: Servicio de Reclamaciones, Apartado de Correos 4127(ADDRESS), la Junta Arbitral de Consumo de Aragón(ADDRESS), Minas del Gobierno de Aragón(ADDRESS), Lumbre Energía, S.L.U. Domicilio(COMPANY), el Registro Mercantil de Zaragoza, Tomo 4.312, Folio 87(ADDRESS) |
| es-lease-01 | 4441 | 57 | 48 | 7 | 2 | 0 | 7 | 93% | 2961 | missed: 684, 31.877; extra: el Registro Mercantil de Madrid(ADDRESS), de Madrid D.(ADDRESS), I. Que Berzosa Anguita Patrimonio, S.L.(COMPANY), 14 de Madrid(ADDRESS), la Agencia de Vivienda Social de la Comunidad de Madrid(ADDRESS), .p. Berzosa Anguita Patrimonio, S.L.(COMPANY), el R.M. de Madrid(ADDRESS) |
| es-lease-02 | 989 | 24 | 22 | 0 | 2 | 0 | 1 | 94% | 695 | missed: C/ Alfonso XIII, 14, 2º B, 14001 Córdoba, C/ El Peso 27, 1º, 14900 Lucena (Córdoba); extra: de C/ Alfonso XIII, 14, 2º B, (ADDRESS) |
| es-letter-01 | 2075 | 33 | 30 | 1 | 2 | 0 | 3 | 93% | 1332 | missed: 3.412, ATL-2026/0381; extra: BUROFAX CON ACUSE DE RECIBO Y CERTIFICACIÓN(COMPANY), el Servicio de Disciplina Urbanística del Ayuntamiento de València(ADDRESS), 14 de València(ADDRESS) |
| es-letter-02 | 2105 | 26 | 23 | 2 | 1 | 0 | 3 | 94% | 1296 | missed: calle Urzáiz 84, 5º B, 36204 Vigo; extra: el de la calle Urzáiz 84, 5º B, (ADDRESS), el de Madrid(ADDRESS), el puente del Pilar, del 10(ADDRESS) |
| es-medical-01 | 4463 | 40 | 35 | 3 | 2 | 0 | 4 | 93% | 3104 | missed: 36208 Vigo (Pontevedra), Costel Munteanu; extra: Vigo
Hospital Álvaro Cunqueiro(COMPANY), el Concello de Vigo(ADDRESS), cardiaca(COMPANY), Cardiaca(COMPANY) |
| es-medical-02 | 1350 | 21 | 17 | 3 | 1 | 0 | 0 | 98% | 1109 | missed: LABORATORIO IBARZ |
| es-payslip-01 | 4002 | 35 | 31 | 1 | 3 | 0 | 3 | 92% | 2626 | missed: Trabanca, Rúa Ourense, 9, 2º esq. - 36630 Cambados (Pontevedra), PO-31.906; extra: Planta de Trabanca(COMPANY), el BOP de Pontevedra(ADDRESS), el Registro Mercantil de Pontevedra(ADDRESS) |
| es-payslip-02 | 1557 | 26 | 20 | 4 | 2 | 0 | 1 | 94% | 1330 | missed: ARLANZÓN, S.L., A. M. Ciobanu; extra: C.I(COMPANY) |
| es-support-01 | 2731 | 37 | 31 | 2 | 4 | 0 | 5 | 90% | 1983 | missed: Vueling, 08841527, 8036, 41011 Sevilla; extra: Mastercard(COMPANY)×2, Vueling Atención(COMPANY), 2219 de Sevilla(ADDRESS), AVE(COMPANY) |
| es-support-02 | 1474 | 20 | 19 | 1 | 0 | 0 | 0 | 100% | 1048 |  |
| fr-bank-01 | 2050 | 38 | 29 | 3 | 6 | 0 | 3 | 88% | 1592 | missed: Bayonne Saint-Esprit, 64100 Bayonne, Bât. C - Appt 27, 30857, 70037, 77; extra: Agence de Bayonne Saint-Esprit(COMPANY)×2, Bayonne, le(ADDRESS) |
| fr-bank-02 | 899 | 19 | 17 | 2 | 0 | 0 | 4 | 91% | 804 | extra: SEPA(PERSON)×2, Agence Schiltigheim Centre(COMPANY), Centre(COMPANY) |
| fr-chat-01 | 965 | 14 | 10 | 1 | 3 | 0 | 1 | 87% | 315 | missed: leclerc, jo, 3e etage; extra: Momo(COMPANY) |
| fr-chat-02 | 413 | 9 | 9 | 0 | 0 | 0 | 0 | 100% | 43 |  |
| fr-cv-01 | 3471 | 57 | 41 | 8 | 7 | 1 | 5 | 88% | 314 | missed: 4,2 M€, Pampelune, ETCHEVERRY Maitena, AFTRAL, IUT de Bordeaux, IUT de Bayonne et du Pays basque, Ustaritz; wrong type: Irun; extra: Micro-entreprise ETCHEVERRY Maitena(COMPANY), SIRET(ADDRESS), AFTRAL Bordeaux(COMPANY), du Pays(ADDRESS), Leroy Merlin Mérignac(COMPANY) |
| fr-cv-02 | 2307 | 36 | 28 | 4 | 3 | 1 | 3 | 89% | 169 | missed: Nord vaudois, Suisse, Morat; wrong type: Guin; extra: 2022-2024(NUMBER), on de Fribourg(ADDRESS), 2015          Cours de chef d'équipe(ADDRESS) |
| fr-insurance-01 | 4012 | 71 | 63 | 5 | 3 | 0 | 3 | 96% | 365 | missed: Le Mans, 775 652 126, 440 048 882; extra: Villeurbanne, le(ADDRESS), RCS Le Mans 775 652 126(ID), RCS Le Mans 440 048 882(ID) |
| fr-insurance-02 | 2190 | 39 | 29 | 8 | 2 | 0 | 1 | 96% | 170 | missed: Bât. C - 3e étage - Appt 32, appt 42; extra: Multirisque Habitation Sérénité(COMPANY) |
| fr-invoice-01 | 2142 | 41 | 37 | 3 | 1 | 0 | 2 | 97% | 197 | missed: 833 304 132; extra: Atlantic Zénéo(COMPANY), RCS Quimper 833 304 132(ID) |
| fr-invoice-02 | 4038 | 65 | 52 | 10 | 3 | 0 | 9 | 93% | 340 | missed: Libre réponse n° 59252, 75443 Paris Cedex 09, TSA 70233 - 34967 Montpellier Cedex 2, 619 326 754; extra: Lumio Énergie
VOTRE FACTURE D'ÉLECTRICITÉ(COMPANY), Lumio Heures Creuses(COMPANY), Linky(PERSON), Heures pleines  48 213(ADDRESS), Dépannage électricité Enedis(COMPANY), 34967 Montpellier Cedex 2. Si la(ADDRESS), 59252(NUMBER), 75443 Paris Cedex 09.(ADDRESS), RCS Montpellier 619 326 754(ID) |
| fr-lease-01 | 4331 | 71 | 54 | 5 | 10 | 2 | 11 | 84% | 363 | missed: 204, 477 897 292, 433 002 565, SYLLA, FERREIRA, CHU de Montpellier, Bâtiment : B     Étage : 2e     Porte : 204, 1er octobre, 41 avenue Roger Salengro, Escalier 2, 94500 Champigny-sur-Marne, soixante-cinq mille cinq cent vingt euros; wrong type: AOGI, FNAIM; extra: AOGI(PERSON)×2, RCS de Montpellier sous le numéro 477 897 292(ID), AOGI GESTION LOCATIVE(COMPANY), SYLLA-FERREIRA LOT(PERSON), Montpellier, le(ADDRESS), MLS(COMPANY), IFS(COMPANY), AFS(COMPANY), SARL(PERSON), RCS Montpellier 433 002 565(ID) |
| fr-lease-02 | 1025 | 23 | 20 | 3 | 0 | 0 | 0 | 100% | 96 |  |
| fr-letter-01 | 2178 | 42 | 35 | 5 | 1 | 1 | 1 | 95% | 161 | missed: 0417-B32; wrong type: Aydın; extra: la CAF de Lyon(ADDRESS) |
| fr-letter-02 | 2076 | 24 | 20 | 2 | 1 | 1 | 4 | 88% | 148 | missed: Lucie-Aubrac; wrong type: Kerleroux; extra: Rezéens(PERSON), rose(PERSON), école élémentaire
Lucie-Aubrac(COMPANY), dentaire(COMPANY) |
| fr-medical-01 | 4423 | 61 | 55 | 4 | 1 | 1 | 3 | 96% | 339 | missed: Sin-le-Noble; wrong type: Cuincy; extra: Confrère(PERSON)×2, FINESS(ADDRESS) |
| fr-medical-02 | 1306 | 23 | 18 | 3 | 2 | 0 | 2 | 92% | 87 | missed: COULIBALY, Fatoumata; extra: Site Rennes Alma(ADDRESS), COULIBALY
Fatoumata(PERSON) |
| fr-payslip-01 | 4459 | 40 | 33 | 4 | 3 | 0 | 6 | 90% | 441 | missed: AG2R, Bas-Rhin, 778 972 976; extra: EMPLOYEUR
BISCUITERIE HEINRICH SAS(COMPANY), Erstein(COMPANY), Atelier 2(COMPANY), AG2R Agirc-Arrco(COMPANY), CPAM du Bas-Rhin(COMPANY), RCS Strasbourg 778 972 976(ID) |
| fr-payslip-02 | 1652 | 27 | 23 | 2 | 2 | 0 | 3 | 91% | 136 | missed: Bretagne, PRO BTP; extra: SIRET(ADDRESS), URSSAF Bretagne(COMPANY), Mutuelle PRO BTP(COMPANY) |
| fr-support-01 | 2718 | 36 | 27 | 5 | 4 | 0 | 5 | 89% | 194 | missed: Chronopost, 8538, Lille Métropole, 676 336 068; extra: Mastercard(COMPANY)×2, Lenovo IdeaPad Slim(COMPANY), RCS Lille Métropole 676 336 068(ID), SignalConso(COMPANY) |
| fr-support-02 | 1404 | 20 | 19 | 1 | 0 | 0 | 1 | 98% | 108 | extra: boulanger(PERSON) |
