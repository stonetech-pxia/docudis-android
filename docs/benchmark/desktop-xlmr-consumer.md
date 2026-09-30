# NER benchmark (desktop, Python onnxruntime)

- Model: xlm-roberta-base-ner-hrl
- Platform: windows "Windows 11 Famille" 10.0 (Build 26200), CPU, onnxruntime via bench_server.py
- Cases: 60, expected entities: 2145
- Overall: recall 81%, precision 91%, F1 86% → reliability **B**; 112 ms per 1000 chars → speed **A**

Grades: reliability by F1 (A ≥ 90%, B ≥ 75%, C ≥ 50%, D below); speed by ms per 1000 characters on this platform (A < 300, B < 1000, C < 3000, D above).

## By language

| Language | Cases | Expected | Found | False pos. | Recall | Precision | F1 | Reliability | ms/1000 chars | Speed |
|---|---|---|---|---|---|---|---|---|---|---|
| en | 20 | 737 | 584 | 92 | 79% | 90% | 84% | B | 108 | A |
| es | 20 | 652 | 540 | 62 | 83% | 92% | 87% | B | 105 | A |
| fr | 20 | 756 | 622 | 77 | 82% | 91% | 86% | B | 122 | A |

## By category

| Category | Cases | Expected | Found | False pos. | Recall | Precision | F1 | Reliability | ms/1000 chars | Speed |
|---|---|---|---|---|---|---|---|---|---|---|
| bank | 6 | 174 | 137 | 14 | 79% | 92% | 85% | B | 132 | A |
| chat | 6 | 77 | 51 | 2 | 66% | 98% | 79% | B | 126 | A |
| cv | 6 | 244 | 210 | 33 | 86% | 90% | 88% | B | 109 | A |
| insurance | 6 | 308 | 249 | 28 | 81% | 92% | 86% | B | 100 | A |
| invoice | 6 | 302 | 251 | 26 | 83% | 93% | 88% | B | 108 | A |
| lease | 6 | 241 | 207 | 37 | 86% | 88% | 87% | B | 108 | A |
| letter | 6 | 196 | 151 | 18 | 77% | 91% | 84% | B | 106 | A |
| medical | 6 | 228 | 192 | 33 | 84% | 88% | 86% | B | 103 | A |
| payslip | 6 | 195 | 151 | 21 | 77% | 89% | 83% | B | 128 | A |
| support | 6 | 180 | 147 | 19 | 82% | 91% | 86% | B | 122 | A |

## Per case

| Case | Chars | Expected | Hit | Partial | Missed | Wrong type | False pos. | F1 | ms | Notes |
|---|---|---|---|---|---|---|---|---|---|---|
| en-bank-01 | 2033 | 39 | 25 | 4 | 10 | 0 | 2 | 83% | 243 | missed: NatWest, PO Box 4418, Bristol BS1 9XQ, Flat 2, 2 April, NWBKGB2L, SVL-002931-AM, 1 April, Gareth Llewellyn, 929027, 250 Bishopsgate, London EC2M 4AA; extra: NatWest
Premier Banking(COMPANY), Gareth Llewellyn
Arranged Overdraft Team(COMPANY) |
| en-bank-02 | 865 | 22 | 11 | 4 | 5 | 2 | 4 | 71% | 105 | missed: WT260910-004418, 7702, 3905 NW 7th St Apt 12B, Miami, FL 33126, CHASUS33, 0817; wrong type: Luz Marina Restrepo Cardenas, Priya Raghunathan; extra: Wire Services(COMPANY), N.A(ADDRESS), Airstream(COMPANY), FDIC(COMPANY) |
| en-chat-01 | 952 | 21 | 14 | 1 | 6 | 0 | 1 | 82% | 122 | missed: 26th sept, 14 Birchfield Court, Evington Road, Leicester LE2 1HJ, will, tom, luton, delroy; extra: flat is 14 Birchfield Court(ADDRESS) |
| en-chat-02 | 470 | 10 | 5 | 0 | 4 | 1 | 1 | 61% | 74 | missed: dana, halvorsen, reggie, faith; wrong type: brightwater; extra: brightwater(ADDRESS) |
| en-cv-01 | 3677 | 40 | 23 | 10 | 6 | 1 | 9 | 82% | 378 | missed: Atlanta, GA 30317, Georgia, RN298417, AACN, Sigma Theta Tau, Jacmel, Haiti; wrong type: Hôpital Saint-Michel; extra: Georgia Board of Nursing(COMPANY), ACLS(COMPANY), BLS(COMPANY), CLABSI(COMPANY), Rover(COMPANY), BCMA(COMPANY), Philips(COMPANY), Peachtree Regional Medical Center(ADDRESS), MHA(COMPANY) |
| en-cv-02 | 2742 | 34 | 25 | 5 | 3 | 1 | 5 | 88% | 320 | missed: YOUSEF AL-KHATIB, Flat 3, 48 Stapleton Road, Easton, Bristol BS5 0QY, Harbour Road, Portishead BS20 7DD; wrong type: St John Ambulance; extra: YOUSEF AL-KHATIB
Flat(ADDRESS), distribution(ADDRESS), Distribution(ADDRESS), Distinction(COMPANY), Haulage
Harbour Road(ADDRESS) |
| en-insurance-01 | 4270 | 71 | 54 | 4 | 12 | 1 | 7 | 85% | 398 | missed: NIDH001/MTR, 7 Cois Cuain, Bearna, 211-G-4827, 408213, Premium Credit, 3308, 6120, C Ní Dhomhnaill, O Adebayo, C48213, 318842; wrong type: 02/11/1985; extra: 7 Cois Cuain
                 Bearna(ADDRESS), Skoda(COMPANY), Driveway(COMPANY), C Ní Dhomhnaill & O Adebayo(COMPANY), Executive(COMPANY), Personal Lines
Direct(COMPANY), Central Bank of Ireland(COMPANY) |
| en-insurance-02 | 2210 | 41 | 28 | 2 | 11 | 0 | 5 | 81% | 243 | missed: PO Box 3661, Norwich NR1 3JX, 27 Whinfell Road, Sheffield S11 9QA, 27 Whinfell Road, Ecclesall, Sheffield S11 9QA, 29 August, 3rd Floor, Cutlers Court, 12 Leopold Street, Sheffield S1 2GY, PLM/SHF/118264, 4402, Hannah Pickersgill, SC002116, Pitheavlis, Perth PH2 0NH; extra: Prudential Regulation Authority(COMPANY)×2, floor(ADDRESS), Pitheavlis(COMPANY), Financial Conduct Authority(COMPANY) |
| en-invoice-01 | 2150 | 46 | 32 | 5 | 9 | 0 | 5 | 85% | 233 | missed: 612884, 047731, OD-24781, J/2026/0319, Q-1187, WISNIEWSKA, Delroy Okonkwo, Okonkwo & Dale, Unit 4, Sheepscar Court, Meanwood Road, Leeds LS7 2BB; extra: NICEIC Approved Contractor(COMPANY), Worcester Bosch(COMPANY), 24781 WISNIEWSKA(ADDRESS), Delroy Okonkwo
Director

Okonkwo & Dale(COMPANY), O&D Building Services Ltd.(COMPANY) |
| en-invoice-02 | 4444 | 59 | 40 | 6 | 13 | 0 | 4 | 86% | 501 | missed: 10287, Dallas, CHIDINMA A OKONKWO, 2217 LARKSPUR TRL APT 1406, PLANO TX 75074, 1554, $0.098700, $0.025510, Plano, 13.9 cents, Texas, 2217 LARKSPUR TRL APT 1406 PLANO TX 75074, P.O. BOX 660418 … +1 more; extra: AutoPay(COMPANY), Public Utility Commission of Texas(COMPANY), CHIDINMA(COMPANY), AUTOPAY(COMPANY) |
| en-lease-01 | 4358 | 45 | 37 | 3 | 5 | 0 | 12 | 86% | 444 | missed: UT482913, RK170652, 1184 Neil Avenue, Apt. 2C, Columbus, OH 43201, pay.hallgrenpm.com, 318 W. Las Tunas Drive, San Gabriel, CA 91776; extra: Landlord(COMPANY)×9, Rules(COMPANY), LANDLORD(COMPANY), WZ  MD(PERSON) |
| en-lease-02 | 977 | 21 | 17 | 2 | 2 | 0 | 2 | 92% | 135 | missed: 0214, 17 Cnoc na Cathrach, Knocknacarra, Galway, H91 T2RV; extra: RTB(COMPANY)×2 |
| en-letter-01 | 2190 | 42 | 33 | 1 | 8 | 0 | 4 | 86% | 209 | missed: HWL/NAR58-2/0319, 15 January, 2 February, 16 March, 30 March, 9 April, 22 June, 10 September; extra: Private Sector Housing(COMPANY), Leicester City Council(COMPANY), Deposit Protection Service(COMPANY), County Court(COMPANY) |
| en-letter-02 | 2168 | 29 | 21 | 2 | 5 | 1 | 3 | 84% | 184 | missed: 29th of August, 27 Thornsett Avenue, Nether Edge, Sheffield S7 1NB, St Oswald's Primary, Mehta, 17 October; wrong type: Sandhu & Partners Medical Centre; extra: rose(PERSON), St Oswald's(ADDRESS), God(PERSON) |
| en-medical-01 | 4464 | 53 | 33 | 10 | 9 | 1 | 9 | 83% | 397 | missed: St James's University Hospital, Beckett Street, Leeds LS9 7TF, Roundhay Road Medical Practice, 16 June, 21 September, Gledhow Wing, 80-2214, Spencer Place, Leeds LS7 4BB, Adeyemi-Clarke, Folasade; wrong type: Chapeltown Health Centre; extra: Hospital(ADDRESS)×2, Department of Cardiology(COMPANY), 2, Gledhow Wing
Beckett Street(ADDRESS), LVEF(PERSON), Clinic C(ADDRESS), ST5)(COMPANY), Community Heart Failure Service(COMPANY), Chapeltown Health(ADDRESS) |
| en-medical-02 | 1438 | 30 | 20 | 5 | 5 | 0 | 1 | 90% | 137 | missed: Chicago, IL 60614, Chicago IL 60618, Mylan, 14D2087315, Logan Square Internal Medicine; extra: 00378-1805(ADDRESS) |
| en-payslip-01 | 3821 | 38 | 23 | 4 | 10 | 1 | 6 | 77% | 432 | missed: Hillside, IL 60162, Berwyn, IL 60402, $27.4500, Alliant Credit Union, xxxxxx9026, October 12, October 30, October 1, Marisol Quintanilla, CHIAMAKA A NWOSU; wrong type: Chiamaka; extra: Illinois(ADDRESS), +1       86.50(NUMBER), Fed(COMPANY), Payroll(COMPANY), Marisol Quintanilla
Payroll Specialist(COMPANY), CHIAMAKA(COMPANY) |
| en-payslip-02 | 1275 | 29 | 16 | 5 | 8 | 0 | 4 | 78% | 212 | missed: HARCASTLE JOINERY, 567/HA41207, 004417, 20-49, 3817, 02/08, 16/08, Denise Hallworth; extra: Workshop(PERSON)×2, Loughborough
Leics(ADDRESS), Denise Hallworth
Accounts & Payroll(COMPANY) |
| en-support-01 | 2759 | 42 | 34 | 3 | 4 | 1 | 8 | 86% | 338 | missed: British Airways, K7XQ2M, 28 August, 9901; wrong type: Aldgate Court Hotel; extra: BA1393(ID)×4, Mastercard(COMPANY)×2, British Airways Customer Relations(COMPANY), Executive Club(COMPANY) |
| en-support-02 | 1470 | 25 | 15 | 2 | 8 | 0 | 0 | 81% | 158 | missed: Apartment 12, Millrace Court, Old Kilmainham, Dublin 8, D08 X4K7, 11 February, 31 August, Tomasz, 8 September, 4471, 21 September, 1 July |
| es-bank-01 | 2148 | 37 | 26 | 6 | 5 | 0 | 2 | 90% | 211 | missed: CG/2026/08831, 4410, 6 de octubre, Vallès Occidental, A-156980; extra: Occidental(COMPANY), Registro Mercantil de Alicante(COMPANY) |
| es-bank-02 | 942 | 19 | 15 | 2 | 2 | 0 | 2 | 90% | 118 | missed: ABANCA, ES62 5533 **** **** **** 0127; extra: ABANCA Avisos(COMPANY), 0417, Rúa do Xeneral Pardiñas(ADDRESS) |
| es-chat-01 | 926 | 14 | 10 | 0 | 4 | 0 | 0 | 83% | 107 | missed: rocio, paco, Calle Iturribide 47, 2º izda, 48006 Bilbao, rosa |
| es-chat-02 | 441 | 9 | 6 | 0 | 3 | 0 | 0 | 80% | 43 | missed: grupo alcor, nuria, andres pedraza |
| es-cv-01 | 3673 | 48 | 34 | 6 | 8 | 0 | 7 | 86% | 339 | missed: Zamudio (Bizkaia), 4,3 M€, Coslada (Madrid), Conservas Ortuondo, Bermeo (Bizkaia), CS-48-02291, Kaiku, Sestao; extra: Ortuondo(ADDRESS), 2020-2021(NUMBER), Facultad de Economía y(COMPANY), 2008-2013(NUMBER), 2011-2012(NUMBER), 2013-2015(NUMBER), Cámara de Comercio de Bilbao(COMPANY) |
| es-cv-02 | 2268 | 29 | 23 | 4 | 2 | 0 | 2 | 94% | 222 | missed: Pereira, Colombia, Aula de Cata Ribera Alta; extra: INAEM(COMPANY), Ministerio de Educación(COMPANY) |
| es-insurance-01 | 4026 | 53 | 41 | 6 | 6 | 0 | 5 | 90% | 364 | missed: 7G-48-210.556.931, J-2841, 4817 LKM, VSSZZZKLZNR041877, Íñigo Aldecoa Murguía, MU-80.417; extra: SEAT(COMPANY), Consorcio de Compensación de Seguros(COMPANY), Seguros y Reaseguros. Entidad(COMPANY), Dirección General de Seguros y Fondos de Pensiones. Santamaría Ortuño Correduría de Seguros, S.L.(COMPANY), Registro Mercantil de Murcia(COMPANY) |
| es-insurance-02 | 2170 | 33 | 18 | 6 | 9 | 0 | 4 | 80% | 213 | missed: Avda. de Aragón 30, planta 9 - 46021 València, C/ Cuba 52, 3º pta. 6, 2026/HG/0381746, C/ Cuba 52, 3º pta. 6, 46006 València, 29 de agosto, 10 de septiembre, ES90 8200 **** **** **** 4820, Rosa Mª Chuliá Peris, Valencia; extra: D. Vicent Beltrán Oliver(PERSON), Rosa Mª Chuliá(COMPANY), Aseguradora Turia, S.A. de Seguros y Reaseguros. Inscrita(COMPANY), Registro Mercantil de Valencia(COMPANY) |
| es-invoice-01 | 1987 | 26 | 18 | 2 | 6 | 0 | 4 | 82% | 177 | missed: FONTANERÍA Y CALEFACCIÓN ETXEBERRIA, C/ Telletxe, 12, bajo · 48991 Getxo (Bizkaia), 2026/0187, P-26/0412, 48/IF-02917, RC-3307419; extra: ETXEBERRIA(PERSON), Iker(COMPANY), FRA 2026(ID), 02917 (Gobierno Vasco)(ADDRESS) |
| es-invoice-02 | 4391 | 65 | 43 | 11 | 11 | 0 | 5 | 88% | 404 | missed: 0,083921 €, 0,012575 €, 0,189450 €, 0,142310 €, 0,098760 €, 0,026630 €, 0,012742 €, ES60 2368 **** **** **** 4146, Coso Bajo 63, bajo, 22001 Huesca, Aragón, Pº de la Independencia 24, 4ª planta, 50004 Zaragoza; extra: Lumbre Energía, Servicio de Reclamaciones(COMPANY), Correos(COMPANY), Junta Arbitral de Consumo de Aragón(COMPANY), Dirección General de Energía y Minas del Gobierno de Aragón(COMPANY), Registro Mercantil de Zaragoza(COMPANY) |
| es-lease-01 | 4441 | 57 | 41 | 7 | 8 | 1 | 8 | 86% | 392 | missed: M-561932, 684, Rúa San Roque, 41, 2º esq., 27002 Lugo, 0847612VK4704H0012RT, 31.877, 26 de agosto, MV38-B42, M-662.480; wrong type: Canal de Isabel II; extra: AVALISTA(PERSON)×2, Registro Mercantil de Madrid(COMPANY), . Gonzalo Berzosa Anguita(PERSON), . Hugo Ferreiro Santalla(PERSON), I. Que Berzosa Anguita Patrimonio, S.L.(COMPANY), Agencia de Vivienda Social de la Comunidad de Madrid(COMPANY), . Ramiro Ferreiro Couto(PERSON) |
| es-lease-02 | 989 | 24 | 19 | 4 | 1 | 0 | 1 | 96% | 126 | missed: Lucena; extra: INE(COMPANY) |
| es-letter-01 | 2075 | 33 | 19 | 7 | 7 | 0 | 3 | 84% | 193 | missed: 3.412, ATL-2026/0381, 12 de mayo, 3 de junio, 19 de junio, 29 de agosto, 2 de septiembre; extra: . Vicent Ferrandis Monzó(PERSON), Servicio de Disciplina Urbanística del Ayuntamiento de València(COMPANY), Juzgado de Primera Instancia nº 14(COMPANY) |
| es-letter-02 | 2105 | 26 | 21 | 1 | 2 | 2 | 0 | 89% | 268 | missed: 10 de septiembre, 12 de octubre; wrong type: Mudanzas Couto, CEIP Mestre Valcarce |
| es-medical-01 | 4463 | 40 | 25 | 6 | 8 | 1 | 8 | 79% | 459 | missed: Estrada Clara Campoamor, 341 - 36312 Vigo (Pontevedra), 36208 Vigo (Pontevedra), 02/09, 2026/0457713, Costel Munteanu, 04/09, 36/3607152, 36/3611894; wrong type: Centro de Saúde de Coia; extra: Cunqueiro(ADDRESS)×2, SERVIZO GALEGO DE SAÚDE(COMPANY), Área Sanitaria de(ADDRESS), Vigo
Hospital(COMPANY), SERVICIO DE CARDIOLOGÍA(COMPANY), Concello de Vigo(ADDRESS), Servicio de Cardiología(COMPANY) |
| es-medical-02 | 1350 | 21 | 13 | 3 | 5 | 0 | 2 | 83% | 128 | missed: 50/5012874, Pº Sagasta, 47, 2º izda., QUISPE MAMANI, Wilson Fernando, Avda. Goya, 23, local  50006 Zaragoza, 50/5017306; extra: Pº Sagasta(PERSON), Wilson Fernando
F.(PERSON) |
| es-payslip-01 | 4002 | 35 | 24 | 3 | 8 | 0 | 3 | 84% | 516 | missed: Trabanca, 36/1048827/83, 00412, Rúa Ourense, 9, 2º esq. - 36630 Cambados (Pontevedra), 14 de agosto, 1 de enero, Pilar Abalde Nogueira, PO-31.906; extra: Planta de Trabanca(ADDRESS), Abalde Nogueira(COMPANY), Registro Mercantil(COMPANY) |
| es-payslip-02 | 1557 | 26 | 15 | 5 | 6 | 0 | 3 | 82% | 255 | missed: EMBUTIDOS Y SALAZONES, 09/1048823/61, 20 de septiembre, Burgos, Mª Begoña Ortega Villanueva, A. M. Ciobanu; extra: C.I(COMPANY), Mª Begoña Ortega(COMPANY), . de Administración(COMPANY) |
| es-support-01 | 2731 | 37 | 31 | 1 | 4 | 1 | 3 | 89% | 303 | missed: QK7M2D, 08841527, 28 de agosto, 8036; wrong type: Hostal Puerta Carmona; extra: Mastercard(COMPANY)×2, AVE(COMPANY) |
| es-support-02 | 1474 | 20 | 15 | 3 | 2 | 0 | 0 | 95% | 215 | missed: 1 de agosto, 3 de agosto |
| fr-bank-01 | 2050 | 38 | 26 | 2 | 10 | 0 | 2 | 83% | 336 | missed: CRÉDIT AGRICOLE PYRÉNÉES GASCOGNE, Bayonne Saint-Esprit, 64100 Bayonne, Résidence Les Hauts de Mousserolles, Bât. C - Appt 27, BSE/RC/2026-09/1184, 30857, 70037, 77, AGRIFRPP869; extra: Agence de Bayonne Saint-Esprit(COMPANY)×2 |
| fr-bank-02 | 899 | 19 | 12 | 4 | 3 | 0 | 2 | 87% | 160 | missed: CIC, 17 sept. 2026, FR76 8457 **** **** **** **31 349; extra: Agence Schiltigheim Centre(COMPANY), CIC Schiltigheim Centre(COMPANY) |
| fr-chat-01 | 965 | 14 | 8 | 1 | 5 | 0 | 0 | 78% | 126 | missed: Momo, leclerc, jo, pierre, 3e etage |
| fr-chat-02 | 413 | 9 | 5 | 1 | 3 | 0 | 0 | 80% | 49 | missed: novalis, hugo blanc, sandrine |
| fr-cv-01 | 3471 | 57 | 45 | 4 | 5 | 3 | 5 | 87% | 466 | missed: 4,2 M€, AFTRAL, Bordeaux-Bastide, IUT de Bayonne et du Pays basque, Les Voisins du Jardin Public; wrong type: Irun, Pampelune, ETCHEVERRY Maitena; extra: WMS Reflex(COMPANY), Micro(COMPANY), SIRET(ADDRESS), AFTRAL Bordeaux(COMPANY), Leroy Merlin Mérignac(COMPANY) |
| fr-cv-02 | 2307 | 36 | 29 | 2 | 3 | 2 | 5 | 85% | 244 | missed: Crissier, Nord vaudois, Bulle; wrong type: Morat, Guin; extra: CFC(COMPANY)×2, 2022-2024(NUMBER), 2015          Cours de chef d'équipe(ADDRESS), Messerli Bauad(PERSON) |
| fr-insurance-01 | 4012 | 71 | 52 | 5 | 14 | 0 | 4 | 87% | 402 | missed: MMA, Allée B, 3e étage, 1er novembre 2026, GH-482-LQ, VASSEUR, Grégory, TRAN K.A., CEPAFRPP382, MMA-AU7482913C-001, 20 octobre, 3 septembre, Le Mans, 775 652 126 … +2 more; extra: Peugeot(COMPANY), VASSEUR G. - TRAN(PERSON), RCS Le Mans 775 652 126(ID), RCS Le Mans 440 048 882(ID) |
| fr-insurance-02 | 2190 | 39 | 27 | 6 | 4 | 2 | 3 | 86% | 262 | missed: Résidence Les Hauts de Marracq, Bât. C - 3e étage - Appt 32, 2026-DDE-0738214, appt 42; wrong type: Peintures Hiriart, Sandrine Vasseur; extra: Habitation(COMPANY)×2, habitation(COMPANY) |
| fr-invoice-01 | 2142 | 41 | 28 | 6 | 7 | 0 | 5 | 85% | 272 | missed: Résidence Cap Coz, maison n° 6, 4402817, 15 septembre, EURL LE GOFF PLOMBERIE CHAUFFAGE, CMBRFR2BXXX, 833 304 132, MAAF Assurances; extra: GOFF(PERSON), PLOMBERIE(ADDRESS), Plomberie(ADDRESS), Atlantic(COMPANY), RCS Quimper 833 304 132(ID) |
| fr-invoice-02 | 4038 | 65 | 47 | 13 | 5 | 0 | 3 | 94% | 470 | missed: RESIDENCE LE BELVEDERE BAT A APPT 207, LIEU-DIT LES FEDIES, FR76 6193 **** **** **** **52 384, Libre réponse n° 59252, 75443 Paris Cedex 09, 619 326 754; extra: Linky(PERSON), pleines  48(ADDRESS), RCS Montpellier 619 326 754(ID) |
| fr-lease-01 | 4331 | 71 | 49 | 7 | 15 | 0 | 12 | 82% | 486 | missed: 204, 477 897 292, 433 002 565, Hérault, SYLLA, FERREIRA, CHU de Montpellier, Résidence Le Clos des Arceaux, 14 rue Marioge, 34000 Montpellier, Bâtiment : B     Étage : 2e     Porte : 204, 1er octobre, 0038215, CCBPFRPPPPG … +3 more; extra: RCS de Montpellier sous le numéro 477 897 292(ID), SIRET(ADDRESS), CCI de l'Hérault(COMPANY), Résidence Le Clos des Arceaux(COMPANY), AOGI GESTION LOCATIVE(COMPANY), SYLLA-FERREIRA(ADDRESS), Élodie(COMPANY), IFS(COMPANY), AFS(COMPANY), AOGI(PERSON), SARL(PERSON), RCS Montpellier 433 002 565(ID) |
| fr-lease-02 | 1025 | 23 | 20 | 1 | 2 | 0 | 2 | 92% | 162 | missed: appartement n° 12, 2e étage, 46 rue Paul Bert, 69003 Lyon, H. de La Rochère; extra: La Rochère(ADDRESS), IBAN(COMPANY) |
| fr-letter-01 | 2178 | 42 | 26 | 3 | 12 | 1 | 3 | 78% | 243 | missed: Résidence Le Clos des Charmilles, Bât. B, 3e étage, porte 32, Villeurbanne, Lyon, 0417-B32, 30 juin, 9 juillet, D-2607-118, 21 juillet, 6 août, 28 août, 4182736; wrong type: Aydın; extra: commission départementale de conciliation(COMPANY), tribunal judiciaire de Lyon(COMPANY), CAF de Lyon(COMPANY) |
| fr-letter-02 | 2076 | 24 | 15 | 2 | 6 | 1 | 5 | 74% | 260 | missed: Élo, Mai-Linh Pham, 20 sept. 2026, Lucie-Aubrac, Anne, 17 octobre; wrong type: Mai-Linh; extra: Coucou(ADDRESS), Mai-Linh(ADDRESS), Rezéens(ADDRESS), rose(PERSON), école élémentaire
Lucie-Aubrac(COMPANY) |
| fr-medical-01 | 4423 | 61 | 52 | 4 | 5 | 0 | 12 | 88% | 541 | missed: Maison de santé des Épis, Résidence Les Glycines, bât. C, appt 14, 04/09, 6 avenue de Verdun, 59300 Valenciennes, GH du Douaisis; extra: de Cardiologie(COMPANY)×2, Confrère(PERSON)×2, Pôle Cardio-Vasculaire(COMPANY), Unité de Soins Intensifs Cardiologiques(COMPANY), Résidence(COMPANY), Glycines(COMPANY), la Scarpe(ADDRESS), Veuve(PERSON), les(ADDRESS), Douaisis(ADDRESS) |
| fr-medical-02 | 1306 | 23 | 18 | 3 | 2 | 0 | 1 | 94% | 135 | missed: COULIBALY, Fatoumata; extra: COULIBALY
Fatoumata(PERSON) |
| fr-payslip-01 | 4459 | 40 | 31 | 3 | 6 | 0 | 3 | 89% | 528 | missed: BP 40118, Appartement 12, 2e étage, 00417, AG2R, CMCIFR2A, 778 972 976; extra: URSSAF(ADDRESS), CPAM(COMPANY), RCS Strasbourg 778 972 976(ID) |
| fr-payslip-02 | 1652 | 27 | 20 | 2 | 5 | 0 | 2 | 87% | 205 | missed: 00147, Appt 4, PRO BTP, CMBRFR2BXXX, 03/08; extra: URSSAF(ADDRESS), Mutuelle PRO BTP(COMPANY) |
| fr-support-01 | 2718 | 36 | 20 | 5 | 11 | 0 | 7 | 75% | 310 | missed: Colis Privé, NGUYEN, 8538, 10573826, Élodie M., Comptoir Numérik SAS, Lille Métropole, 676 336 068, 15 sept. 2026, 7 septembre, Résidence Les Hauts du Lac, esc. D, 5e étage, appt 512; extra: Mastercard(COMPANY)×2, Lenovo(COMPANY), RCS Lille Métropole 676 336 068(ID), résidence(COMPANY), Résidence(COMPANY), SignalConso(COMPANY) |
| fr-support-02 | 1404 | 20 | 16 | 2 | 2 | 0 | 1 | 93% | 203 | missed: 1er mars, 25/09; extra: boulanger(PERSON) |
