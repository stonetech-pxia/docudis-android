# NER benchmark (desktop, Python onnxruntime)

- Model: xlm-roberta-base-ner-hrl
- Platform: windows "Windows 11 Famille" 10.0 (Build 26200), CPU, onnxruntime via bench_server.py
- Cases: 48, expected entities: 1076
- Overall: recall 84%, precision 85%, F1 84% → reliability **B**; 639 ms per 1000 chars → speed **B**

Grades: reliability by F1 (A ≥ 90%, B ≥ 75%, C ≥ 50%, D below); speed by ms per 1000 characters on this platform (A < 300, B < 1000, C < 3000, D above).

## By language

| Language | Cases | Expected | Found | False pos. | Recall | Precision | F1 | Reliability | ms/1000 chars | Speed |
|---|---|---|---|---|---|---|---|---|---|---|
| en | 16 | 391 | 322 | 101 | 82% | 81% | 82% | B | 458 | B |
| es | 16 | 325 | 275 | 48 | 85% | 88% | 86% | B | 742 | B |
| fr | 16 | 360 | 302 | 55 | 84% | 86% | 85% | B | 731 | B |

## By category

| Category | Cases | Expected | Found | False pos. | Recall | Precision | F1 | Reliability | ms/1000 chars | Speed |
|---|---|---|---|---|---|---|---|---|---|---|
| bank | 3 | 128 | 116 | 11 | 91% | 92% | 91% | A | 539 | B |
| catalogue | 3 | 114 | 98 | 19 | 86% | 84% | 85% | B | 558 | B |
| chat | 3 | 35 | 22 | 2 | 63% | 97% | 76% | B | 731 | B |
| cv | 3 | 87 | 81 | 24 | 93% | 79% | 85% | B | 500 | B |
| insurance | 3 | 94 | 79 | 10 | 84% | 90% | 87% | B | 517 | B |
| invoice | 3 | 87 | 73 | 9 | 84% | 91% | 87% | B | 407 | B |
| jobad | 3 | 41 | 39 | 10 | 95% | 84% | 89% | B | 525 | B |
| lease | 3 | 79 | 68 | 5 | 86% | 94% | 90% | B | 724 | B |
| letter | 3 | 63 | 51 | 7 | 81% | 90% | 85% | B | 759 | B |
| manual | 3 | 15 | 11 | 13 | 73% | 61% | 66% | C | 751 | B |
| medical | 3 | 61 | 48 | 7 | 79% | 89% | 83% | B | 738 | B |
| notice | 3 | 36 | 23 | 40 | 64% | 43% | 51% | C | 673 | B |
| payslip | 3 | 64 | 52 | 6 | 81% | 91% | 86% | B | 782 | B |
| policy | 3 | 51 | 44 | 23 | 86% | 68% | 76% | B | 626 | B |
| support | 3 | 81 | 64 | 7 | 79% | 94% | 86% | B | 772 | B |
| terms | 3 | 40 | 30 | 11 | 75% | 79% | 77% | B | 704 | B |

## Per case

| Case | Chars | Expected | Hit | Partial | Missed | Wrong type | False pos. | F1 | ms | Notes |
|---|---|---|---|---|---|---|---|---|---|---|
| en-bank-01 | 2057 | 40 | 36 | 1 | 3 | 0 | 6 | 89% | 179 | missed: PO Box 4402, PLS/OD/26/774301, 929027; extra: Lending(COMPANY), HM Revenue & Customs(COMPANY), Lending Review Team
Personal Lending Services(COMPANY), England(ADDRESS), Wales(ADDRESS), Prudential Regulation Authority(COMPANY) |
| en-catalogue-01 | 3885 | 38 | 29 | 1 | 8 | 0 | 8 | 79% | 221 | missed: Cork, KFA-Q-24817, 419776, IE 4197763T, Fergus Naughton, EUR  73.88, EUR    97.14, EUR   871.38; extra: DAP(COMPANY), 7318 14 91(NUMBER), 7318 15 59(NUMBER), Northern Ireland(ADDRESS), Internal Sales Desk(COMPANY), Fergus Naughton, Internal Sales(COMPANY), Ireland(ADDRESS), 24817 Rev(ADDRESS) |
| en-chat-01 | 791 | 8 | 2 | 0 | 5 | 1 | 0 | 39% | 72 | missed: aoife, tomek, sinead, rathgar, 14 Sycamore Lawn, Clonsilla, Dublin 15, D15 XK72; wrong type: 087 418 2263 |
| en-cv-01 | 3229 | 36 | 27 | 6 | 3 | 0 | 18 | 77% | 263 | missed: NAVEEN BALASUBRAMANIAN, The University of Texas at Austin, CQE-218774; extra: FDA(COMPANY)×2, Department of Veterans Affairs(COMPANY)×2, CAPA(COMPANY)×2, NAVEEN(ADDRESS), BALASUBRAMANIAN(COMPANY), 26-11840298(NUMBER), United States(ADDRESS), 2019-2022(NUMBER), Central Texas Veterans Health Care System(COMPANY), MILITARY SERVICE
United States Army(COMPANY), EDUCATION
The University of Texas(COMPANY), Austin(ADDRESS) … +3 more |
| en-insurance-01 | 2267 | 35 | 30 | 2 | 2 | 1 | 5 | 89% | 186 | missed: Road, 1 Angel Court, London EC2R 7HJ; wrong type: Bupa House; extra: Nether Parkfield
Road(ADDRESS), Claims Review Team(COMPANY), Financial Conduct Authority(COMPANY), England(ADDRESS), Wales(ADDRESS) |
| en-invoice-01 | 2052 | 45 | 33 | 2 | 9 | 1 | 7 | 81% | 169 | missed: Kilcoole, Co. Wicklow, IE3847291GH, 612884, FERR-014, Walk, Naas, Co. Kildare, KOWALCZYK 0913, Main Street, Bray, Co. Wicklow, AIBKIE2D; wrong type: 086 330 9542; extra: Kilcoole, Co.(COMPANY), Naas, Co.(COMPANY), KOWALCZYK(PERSON), Street, Bray, Co.(COMPANY), ECB(COMPANY), main(ADDRESS), 086 330 9542(ID) |
| en-jobad-01 | 3783 | 14 | 13 | 0 | 1 | 0 | 8 | 79% | 1037 | missed: Thornlow Road, Calderwych Bay CB14 3PN; extra: Clinical Engineering(COMPANY)×2, ISO(COMPANY)×2, MHRA(COMPANY), United Kingdom(ADDRESS), Engineering Council(COMPANY), Clinical Engineering(PERSON) |
| en-lease-01 | 2348 | 37 | 32 | 0 | 5 | 0 | 1 | 92% | 1557 | missed: MT/TEN/4471-B, Adeyemi, Folasade O., Heaton Moor, Stockport SK4 3QN, Tenancy Deposit Scheme, H. Draycott; extra: H. Draycott
Property Management Team(COMPANY) |
| en-letter-01 | 788 | 19 | 14 | 1 | 4 | 0 | 2 | 84% | 520 | missed: PO Box 227, 41 Lindley Croft, BG/MTR/2026/55120, K. Ademola; extra: Lindley(COMPANY), K. Ademola
Metering Services(COMPANY) |
| en-manual-01 | 3656 | 6 | 4 | 1 | 1 | 0 | 6 | 65% | 2769 | missed: HTS-IM-0440; extra: 88-4401(NUMBER)×3, 60335-2-51(NUMBER), EMC(COMPANY), United Kingdom(ADDRESS) |
| en-medical-01 | 2564 | 27 | 16 | 5 | 6 | 0 | 3 | 83% | 1976 | missed: Columbus, OH 43215, YRH8820416, 004791, Sanborn Eye, Associates, BR4471908; extra: Sanborn Eye
   Associates(COMPANY), Division of Endocrinology(COMPANY), BR4471908

CONFIDENTIALITY NOTICE(IBAN) |
| en-notice-01 | 2839 | 13 | 7 | 0 | 5 | 1 | 12 | 51% | 1950 | missed: Netherfield House, 3 Arkwright Way, Pennerbridge PB2 7QD, PW/STW/2026/04872, 0492-HG-26-117, TRUNK-RENEW-38, 12 October; wrong type: Pennerbridge Water; extra: Marsden Row(ADDRESS)×5, Hollowgate Lane(ADDRESS)×3, Carlow Street(ADDRESS)×2, Dunmoor Avenue(ADDRESS)×2 |
| en-payslip-01 | 1663 | 17 | 11 | 2 | 4 | 0 | 2 | 82% | 1188 | missed: 083/HR4419, Nest, Unite, D. Fairhurst-Naylor; extra: Machine(COMPANY), D. Fairhurst-Naylor
Payroll Services(COMPANY) |
| en-policy-01 | 3504 | 11 | 8 | 2 | 1 | 0 | 12 | 63% | 2271 | missed: NL-ISP-014; extra: Information Security(COMPANY)×3, IT Service Desk(COMPANY)×3, NIST SP(COMPANY)×2, INFORMATION SECURITY(COMPANY), ATLAS(COMPANY), Procurement(COMPANY), Beaverton(COMPANY) |
| en-support-01 | 3211 | 30 | 20 | 4 | 5 | 1 | 7 | 83% | 2282 | missed: 1651, Naas Road, Dublin 22, D22 XK79, Knocknacarra, Galway H91 R2VC, 641208, IE 4412097T; wrong type: 09/02/1984; extra: Case 2026-118447(ID)×3, Kinvara(COMPANY), One(COMPANY), one(COMPANY), Ireland(ADDRESS) |
| en-terms-01 | 3967 | 15 | 11 | 2 | 2 | 0 | 4 | 85% | 2848 | missed: HV-STC-0417, WEE/JB3392AC; extra: Facilities(PERSON), Procurement(COMPANY), England(ADDRESS), Wales(ADDRESS) |
| es-bank-01 | 2732 | 47 | 39 | 5 | 3 | 0 | 2 | 95% | 2185 | missed: 6046, Ferretería Baldosa, 20 de octubre; extra: Nómina INVERNADEROS EL SAUCAL SL(COMPANY)×2 |
| es-catalogue-01 | 3272 | 33 | 28 | 1 | 4 | 0 | 4 | 88% | 2928 | missed: Carretera de Burgos, km 12,400 — Parque Empresarial Valdehierro, nave 21, PR-2026/04187, A-28455091, M-431.778; extra: Parque(COMPANY), Departamento Comercial(COMPANY), Departamento de Administración de Ventas(COMPANY), Registro Mercantil de Madrid(COMPANY) |
| es-chat-01 | 1653 | 16 | 11 | 1 | 4 | 0 | 2 | 83% | 1600 | missed: marta, yusuf, Carrer del Molí Nou, 42, esc. B, 4t 2a, 1 de octubre; extra: piso es Carrer del Molí Nou, 42(ADDRESS), IMG-20260911(ID) |
| es-cv-01 | 2030 | 18 | 15 | 2 | 1 | 0 | 1 | 95% | 1725 | missed: Aula Bética; extra: Cámara de Comercio de Sevilla(COMPANY) |
| es-insurance-01 | 1957 | 30 | 19 | 6 | 5 | 0 | 1 | 89% | 1599 | missed: bajo C, 2026/ZAR/033118, 26 de agosto, 2 de septiembre, 18 de septiembre; extra: . Oleksandr Hrytsenko Marín(PERSON) |
| es-invoice-01 | 712 | 17 | 12 | 4 | 1 | 0 | 0 | 97% | 568 | missed: 2026/118 |
| es-jobad-01 | 3516 | 11 | 9 | 1 | 1 | 0 | 1 | 92% | 2276 | missed: Camino de la Fuente Vieja 8, 47195 Arroyo del Valle (Valladolid); extra: Departamento de Personas(COMPANY) |
| es-lease-01 | 2205 | 25 | 17 | 3 | 5 | 0 | 4 | 83% | 1717 | missed: izquierda, 46008 València (Valencia), Port, 112, escalera B, 5ª puerta C, 46023 València, 7382901YJ2778S0012KP, 41.228, 31; extra: D. Youssef El Amrani Bouzid(PERSON)×2, Dña. Rosa María Villalba Pons(PERSON), Institut Valencià de l'Edificació.

CUARTA. Suministros(COMPANY) |
| es-letter-01 | 1831 | 23 | 14 | 4 | 4 | 1 | 2 | 83% | 1095 | missed: Apartado de Correos 1128, bajo C, Calle Doctor Fleming, 8, bloque 2, bajo C, 50006 Zaragoza, 1 de marzo; wrong type: 902547118; extra: Correos(COMPANY), Departamento de Facturación(COMPANY) |
| es-manual-01 | 3638 | 5 | 4 | 0 | 1 | 0 | 4 | 73% | 2813 | missed: Polígono Industrial Las Cañadas, nave 17, 50820 Villamayor (Zaragoza); extra: 41-2400(NUMBER)×2, 60335-2-80(NUMBER), 1.1.4.2(IP) |
| es-medical-01 | 793 | 12 | 8 | 1 | 3 | 0 | 0 | 86% | 545 | missed: Carretera de Toledo, km 12,500, 2026/CEX/55219, 28/4419788 |
| es-notice-01 | 2999 | 11 | 6 | 2 | 3 | 0 | 14 | 48% | 1934 | missed: PUENTE ALMANZOR, 2025/OB-0442, 114/2025/INF; extra: avenida de los Olmares(ADDRESS)×3, AYUNTAMIENTO DE PUENTE ALMANZOR(COMPANY), calles(ADDRESS), Herradores(ADDRESS), Molino Bajo(ADDRESS), calle Cantarranas(ADDRESS), ronda de Poniente(ADDRESS), Estación(ADDRESS), Barrio del Carmen(ADDRESS), calle Herradores(ADDRESS), plaza del Peso(ADDRESS), Oficina de Atención Ciudadana(ADDRESS) |
| es-payslip-01 | 2672 | 18 | 12 | 3 | 2 | 1 | 3 | 82% | 1912 | missed: B-87421903, 04127; wrong type: Nerea Oyarzábal Ferrer; extra: C.I(COMPANY), Artes(COMPANY), Seguridad Social(COMPANY) |
| es-policy-01 | 3460 | 21 | 17 | 2 | 2 | 0 | 6 | 83% | 2065 | missed: CI-2026/031, 0,26 €; extra: Dirección de Recursos Humanos(COMPANY)×2, VIATIA(COMPANY)×2, Departamento de Administración(COMPANY)×2 |
| es-support-01 | 2383 | 27 | 20 | 3 | 4 | 0 | 0 | 92% | 1896 | missed: 4471028, 2ª, 46701 Gandia (Valencia), F-2026/19884, 208877 |
| es-terms-01 | 3974 | 11 | 5 | 1 | 5 | 0 | 4 | 61% | 2688 | missed: Polígono Industrial Las Cañadas, calle Torrente Ballester 14, nave 7, 42,50 €, 36,80 €, B-97684512, V-152.334; extra: Instituto Nacional de Estadística(COMPANY), Juzgados(COMPANY), Mercantil de Valencia(COMPANY), de Administración(COMPANY) |
| fr-bank-01 | 2971 | 41 | 29 | 6 | 6 | 0 | 3 | 89% | 1817 | missed: Vincennes-Château, bâtiment C, appartement 42, RE/2026-09/4412, cabinet Lorquin & associés, Fontenay, 10 octobre; extra: Agence de Vincennes-Château(COMPANY), Lorquin(PERSON), Mastercard(COMPANY) |
| fr-catalogue-01 | 3661 | 43 | 35 | 4 | 4 | 0 | 7 | 88% | 2885 | missed: 40712, Geodis, Poitiers, 524 108 663 00041; extra: AUZANCE(ADDRESS), 7318 15 81(NUMBER), 7318 16 91(NUMBER), 7308 90 98(NUMBER), COMPTOIR METALLURGIQUE DE L'AUZANCE - SAS(COMPANY), RCS Poitiers 524 108 663(ID), SIRET(COMPANY) |
| fr-chat-01 | 789 | 11 | 7 | 1 | 2 | 1 | 0 | 82% | 690 | missed: lena, karim; wrong type: 04/11/1994 |
| fr-cv-01 | 2735 | 33 | 28 | 3 | 2 | 0 | 5 | 90% | 2012 | missed: TNV Maintenance, Lyon; extra: Siemens(COMPANY), Schneider(COMPANY), Carl Source(PERSON), SIRET(ADDRESS), U13(COMPANY) |
| fr-insurance-01 | 2386 | 29 | 19 | 3 | 7 | 0 | 4 | 80% | 1628 | missed: TSA 70124, Ferreira, H4-2211879, 2026/AC/55031, 13 août, centre hospitalier d'Agen, 24 août; extra: Sud-Ouest(COMPANY), SANTÉ ESSENTIEL(COMPANY), IBAN(COMPANY), Sud-Ouest(ADDRESS) |
| fr-invoice-01 | 1754 | 25 | 18 | 4 | 3 | 0 | 2 | 90% | 1100 | missed: SMABTP, Résidence Les Hauts de Caudéran, 4471280; extra: SIRET(ADDRESS), IBAN(COMPANY) |
| fr-jobad-01 | 3198 | 16 | 15 | 1 | 0 | 0 | 1 | 98% | 2199 | extra: Grand Ouest(ADDRESS) |
| fr-lease-01 | 708 | 17 | 15 | 1 | 1 | 0 | 0 | 97% | 535 | missed: Bâtiment C, 2e étage |
| fr-letter-01 | 1402 | 21 | 16 | 2 | 3 | 0 | 3 | 86% | 1434 | missed: Résidence Les Coteaux, bâtiment B, appartement 214, RSA/2026/ATT-51840; extra: Caisse d'allocations familiales(COMPANY), Résidence Les Coteaux(COMPANY), IBAN(COMPANY) |
| fr-manual-01 | 3617 | 4 | 2 | 0 | 2 | 0 | 3 | 56% | 2608 | missed: ZA des Quatre Sillons, 12 rue de la Fonderie, 41260 Sarnay-sur-Cisse, NM-4200; extra: VOLTARIS(COMPANY), 60335-2-51(NUMBER), 61000-6-3(NUMBER) |
| fr-medical-01 | 1539 | 22 | 16 | 2 | 4 | 0 | 4 | 82% | 1090 | missed: Cabinet médical de la Riponne, 4482-19, CHUV, 4 septembre; extra: Collègue(PERSON)×2, Dresse(PERSON), Riponne(ADDRESS) |
| fr-notice-01 | 3131 | 12 | 8 | 0 | 4 | 0 | 14 | 49% | 2154 | missed: AP-2026-47, 2026-ARR-318, 5 octobre, 25 octobre; extra: rue des Tanneurs(ADDRESS)×3, place du Marché couvert(ADDRESS)×2, RUE DES TANNEURS(ADDRESS), PLACE DU MARCHÉ COUVERT(ADDRESS), Gare(ADDRESS), boulevard Sainte-Colombe(ADDRESS), Tanneurs(ADDRESS), Sainte-Colombe(ADDRESS), Poste(ADDRESS), rue Fresnaye(ADDRESS), MÉDIATHÈQUE DES GRANDS MOULINS(COMPANY) |
| fr-payslip-01 | 2597 | 29 | 23 | 1 | 4 | 1 | 1 | 88% | 2318 | missed: 00418, bâtiment 4, 2e étage, HM-6120884, SIST Alsace Nord; wrong type: Malakoff Humanis; extra: URSSAF Alsace(PERSON) |
| fr-policy-01 | 3340 | 19 | 11 | 4 | 4 | 0 | 5 | 78% | 2117 | missed: NS-2026-017, NS-2024-008, Grenoble, 379 615 244 00073; extra: Direction des ressources humaines(COMPANY)×2, SOCIETE NOUVELLE BEAUREPAIRE & CIE - SA(COMPANY), RCS Grenoble 379 615 244(ID), SIRET(COMPANY) |
| fr-support-01 | 1684 | 24 | 14 | 3 | 7 | 0 | 0 | 83% | 1436 | missed: R-118472, 6H-4410829, 3716, bâtiment C, appartement 12, 5512048, 9 septembre 2026, 8 septembre |
| fr-terms-01 | 3983 | 14 | 9 | 2 | 3 | 0 | 3 | 80% | 2851 | missed: CGS-CTA-2026, 1er janvier, Nantes; extra: INSEE(COMPANY), Banque centrale européenne(COMPANY), SIRET(COMPANY) |
