# NER benchmark (desktop, Python onnxruntime)

- Model: xlm-roberta-base-ner-docudis
- Platform: windows "Windows 11 Famille" 10.0 (Build 26200), CPU, onnxruntime via bench_server.py
- Cases: 48, expected entities: 1076
- Overall: recall 92%, precision 89%, F1 91% → reliability **A**; 90 ms per 1000 chars → speed **A**

Grades: reliability by F1 (A ≥ 90%, B ≥ 75%, C ≥ 50%, D below); speed by ms per 1000 characters on this platform (A < 300, B < 1000, C < 3000, D above).

## By language

| Language | Cases | Expected | Found | False pos. | Recall | Precision | F1 | Reliability | ms/1000 chars | Speed |
|---|---|---|---|---|---|---|---|---|---|---|
| en | 16 | 391 | 357 | 63 | 91% | 87% | 89% | B | 90 | A |
| es | 16 | 325 | 300 | 34 | 92% | 92% | 92% | A | 78 | A |
| fr | 16 | 360 | 334 | 46 | 93% | 89% | 91% | A | 101 | A |

## By category

| Category | Cases | Expected | Found | False pos. | Recall | Precision | F1 | Reliability | ms/1000 chars | Speed |
|---|---|---|---|---|---|---|---|---|---|---|
| bank | 3 | 128 | 123 | 5 | 96% | 97% | 96% | A | 125 | A |
| catalogue | 3 | 114 | 103 | 11 | 90% | 91% | 90% | A | 167 | A |
| chat | 3 | 35 | 33 | 2 | 94% | 98% | 96% | A | 88 | A |
| cv | 3 | 87 | 82 | 12 | 94% | 88% | 91% | A | 66 | A |
| insurance | 3 | 94 | 88 | 6 | 94% | 94% | 94% | A | 83 | A |
| invoice | 3 | 87 | 79 | 4 | 91% | 96% | 93% | A | 200 | A |
| jobad | 3 | 41 | 39 | 6 | 95% | 89% | 92% | A | 58 | A |
| lease | 3 | 79 | 73 | 8 | 92% | 91% | 92% | A | 86 | A |
| letter | 3 | 63 | 58 | 2 | 92% | 97% | 94% | A | 107 | A |
| manual | 3 | 15 | 12 | 15 | 80% | 52% | 63% | C | 62 | A |
| medical | 3 | 61 | 57 | 4 | 93% | 94% | 94% | A | 73 | A |
| notice | 3 | 36 | 33 | 41 | 92% | 48% | 63% | C | 58 | A |
| payslip | 3 | 64 | 60 | 4 | 94% | 94% | 94% | A | 145 | A |
| policy | 3 | 51 | 45 | 6 | 88% | 89% | 89% | B | 57 | A |
| support | 3 | 81 | 72 | 11 | 89% | 91% | 90% | B | 67 | A |
| terms | 3 | 40 | 34 | 6 | 85% | 86% | 85% | B | 65 | A |

## Per case

| Case | Chars | Expected | Hit | Partial | Missed | Wrong type | False pos. | F1 | ms | Notes |
|---|---|---|---|---|---|---|---|---|---|---|
| en-bank-01 | 2057 | 40 | 39 | 0 | 1 | 0 | 0 | 99% | 221 | missed: 929027 |
| en-catalogue-01 | 3885 | 38 | 32 | 0 | 6 | 0 | 5 | 85% | 1279 | missed: KFA-Q-24817, 419776, IE 4197763T, EUR  73.88, EUR    97.14, EUR   871.38; extra: 7318 14 91(NUMBER), 7318 15 59(NUMBER), Northern Ireland(ADDRESS), Ireland(ADDRESS), 24817 Rev 2(ADDRESS) |
| en-chat-01 | 791 | 8 | 7 | 0 | 0 | 1 | 1 | 90% | 80 | wrong type: 087 418 2263; extra: 08/29(DATE) |
| en-cv-01 | 3229 | 36 | 32 | 1 | 3 | 0 | 10 | 84% | 190 | missed: The University of Texas at Austin, CQE-218774, Kestrel Ridge Biologics; extra: 26-11840298(NUMBER), United States(ADDRESS), 5-point(ID), 2019-2022(NUMBER), 04/2025(DATE), Central Texas Veterans Health Care System(COMPANY), United States Army(COMPANY), EDUCATION
The University of Texas(COMPANY), 2027
Lean Six Sigma Green Belt, Kestrel Ridge(ADDRESS), Texas(ADDRESS) |
| en-insurance-01 | 2267 | 35 | 33 | 1 | 0 | 1 | 2 | 95% | 132 | wrong type: Bupa House; extra: England(ADDRESS), Wales No.(ADDRESS) |
| en-invoice-01 | 2052 | 45 | 38 | 1 | 3 | 3 | 3 | 87% | 107 | missed: Walk, KOWALCZYK 0913, Main Street, Bray, Co. Wicklow; wrong type: Kilcoole, Co. Wicklow, 086 330 9542, Naas, Co. Kildare; extra: KOWALCZYK(PERSON), Bray, Co. Wicklow(COMPANY), 086 330 9542(ID) |
| en-jobad-01 | 3783 | 14 | 13 | 0 | 1 | 0 | 3 | 88% | 159 | missed: Calderwych Bay; extra: United(COMPANY), Kingdom(ADDRESS), the Thornlow Road(ADDRESS) |
| en-lease-01 | 2348 | 37 | 35 | 1 | 1 | 0 | 4 | 94% | 147 | missed: Tenancy Deposit Scheme; extra: April(DATE), May(DATE), July(DATE), IBAN(PERSON) |
| en-letter-01 | 788 | 19 | 19 | 0 | 0 | 0 | 0 | 100% | 41 |  |
| en-manual-01 | 3656 | 6 | 5 | 0 | 1 | 0 | 6 | 59% | 197 | missed: HTS-IM-0440; extra: HX-440-S(ID), 88-4401-S(ID), of 2025(DATE), 60335-2-51(NUMBER), EMC(COMPANY), the United Kingdom(ADDRESS) |
| en-medical-01 | 2564 | 27 | 22 | 1 | 4 | 0 | 1 | 90% | 151 | missed: YRH8820416, 004791, Sanborn Eye, Associates; extra: Sanborn Eye
   Associates(COMPANY) |
| en-notice-01 | 2839 | 13 | 12 | 1 | 0 | 0 | 14 | 67% | 139 | extra: Marsden Row(ADDRESS)×5, Hollowgate Lane(ADDRESS)×2, the Ashcombe Green(ADDRESS), Carlow Street(ADDRESS), Dunmoor Avenue(ADDRESS), on Carlow Street(ADDRESS), on Dunmoor Avenue(ADDRESS), of Hollowgate Lane(ADDRESS), Netherfield House(COMPANY) |
| en-payslip-01 | 1663 | 17 | 15 | 0 | 2 | 0 | 0 | 94% | 349 | missed: Nest, Unite |
| en-policy-01 | 3504 | 11 | 9 | 1 | 1 | 0 | 3 | 84% | 192 | missed: NL-ISP-014; extra: NIST SP(COMPANY)×2, December 2027(DATE) |
| en-support-01 | 3211 | 30 | 24 | 2 | 3 | 1 | 9 | 84% | 176 | missed: 1651, 641208, IE 4412097T; wrong type: 09/02/1984; extra: Case 2026-118447(ID)×3, O Riordain
Customer Resolutions Team
Ardmore Home & Kitchen Ltd(COMPANY)×2, One(COMPANY), one(COMPANY), 04/29(DATE), Ireland(ADDRESS) |
| en-terms-01 | 3967 | 15 | 12 | 1 | 2 | 0 | 2 | 87% | 256 | missed: HV-STC-0417, WEE/JB3392AC; extra: England(ADDRESS), Wales(ADDRESS) |
| es-bank-01 | 2732 | 47 | 43 | 3 | 1 | 0 | 2 | 97% | 184 | missed: 6046; extra: Nómina INVERNADEROS EL SAUCAL SL(COMPANY)×2 |
| es-catalogue-01 | 3272 | 33 | 29 | 3 | 1 | 0 | 1 | 97% | 267 | missed: A-28455091; extra: Registro Mercantil de Madrid(ADDRESS) |
| es-chat-01 | 1653 | 16 | 14 | 2 | 0 | 0 | 1 | 99% | 126 | extra: IMG-20260911-WA0003(ID) |
| es-cv-01 | 2030 | 18 | 18 | 0 | 0 | 0 | 1 | 98% | 130 | extra: Cámara de Comercio de(COMPANY) |
| es-insurance-01 | 1957 | 30 | 25 | 2 | 3 | 0 | 1 | 93% | 146 | missed: bajo C, 2026/ZAR/033118, M. Trujillo Abad; extra: M. Trujillo Abad
Departamento de Tramitación de Siniestros
MAPFRE ESPAÑA, S.A.(COMPANY) |
| es-invoice-01 | 712 | 17 | 14 | 2 | 1 | 0 | 0 | 97% | 71 | missed: 2026/118 |
| es-jobad-01 | 3516 | 11 | 10 | 0 | 1 | 0 | 1 | 92% | 207 | missed: Camino de la Fuente Vieja 8, 47195 Arroyo del Valle (Valladolid); extra: Grupo 3(COMPANY) |
| es-lease-01 | 2205 | 25 | 19 | 1 | 5 | 0 | 3 | 85% | 235 | missed: izquierda, 46008 València (Valencia), Avinguda del, 7382901YJ2778S0012KP, 41.228, 31; extra: 9 de València(ADDRESS), Institut Valencià de l'Edificació(COMPANY), DE AGOSTO DE 2026(DATE) |
| es-letter-01 | 1831 | 23 | 17 | 3 | 2 | 1 | 1 | 89% | 260 | missed: bajo C, Sergio Montull Aldeanueva; wrong type: 902547118; extra: Sergio Montull Aldeanueva
Departamento de Facturación y Lecturas
Endesa Energía, S.A.U.(COMPANY) |
| es-manual-01 | 3638 | 5 | 4 | 0 | 1 | 0 | 4 | 69% | 237 | missed: Polígono Industrial Las Cañadas, nave 17, 50820 Villamayor (Zaragoza); extra: 41-2400-B(ID), 60335-2-80(NUMBER), 1.1.4.2(IP), Departamento de Postventa
Termavent Ibérica, S.L.U.(COMPANY) |
| es-medical-01 | 793 | 12 | 11 | 1 | 0 | 0 | 0 | 100% | 60 |  |
| es-notice-01 | 2999 | 11 | 6 | 2 | 3 | 0 | 12 | 56% | 181 | missed: plaza Mayor 1, planta baja, 2025/OB-0442, 114/2025/INF; extra: AYUNTAMIENTO DE PUENTE(ADDRESS), la avenida de los Olmares(ADDRESS), de la avenida de los Olmares(ADDRESS), les Herradores(ADDRESS), Molino Bajo(ADDRESS), de los Olmares(ADDRESS), la calle Cantarranas(ADDRESS), de Poniente(ADDRESS), Estación(ADDRESS), Barrio del Carmen(ADDRESS), la calle Herradores(ADDRESS), Oficina de Atención Ciudadana, plaza Mayor 1(ADDRESS) |
| es-payslip-01 | 2672 | 18 | 17 | 1 | 0 | 0 | 3 | 93% | 403 | extra: C.I(COMPANY), Artes Gráficas(COMPANY), Grupo 4(COMPANY) |
| es-policy-01 | 3460 | 21 | 18 | 2 | 1 | 0 | 0 | 98% | 175 | missed: 0,26 € |
| es-support-01 | 2383 | 27 | 22 | 3 | 2 | 0 | 1 | 95% | 157 | missed: 4471028, F-2026/19884; extra: LP-4471(ID) |
| es-terms-01 | 3974 | 11 | 5 | 3 | 3 | 0 | 3 | 73% | 266 | missed: 42,50 €, 36,80 €, B-97684512; extra: Instituto Nacional de Estadística(COMPANY), de Valencia(ADDRESS), Registro Mercantil de Valencia(ADDRESS) |
| fr-bank-01 | 2971 | 41 | 32 | 6 | 3 | 0 | 3 | 93% | 560 | missed: Vincennes-Château, bâtiment C, appartement 42, Fontenay; extra: Agence de Vincennes-Château(COMPANY), Vincennes, le(ADDRESS), Mastercard Gold(COMPANY) |
| fr-catalogue-01 | 3661 | 43 | 37 | 2 | 4 | 0 | 5 | 90% | 259 | missed: 40712, Geodis, Poitiers, 524 108 663 00041; extra: 7318 15 81(NUMBER), 7318 16 91(NUMBER), 7308 90 98(NUMBER), RCS Poitiers 524 108 663(ID), SIRET(ADDRESS) |
| fr-chat-01 | 789 | 11 | 7 | 3 | 0 | 1 | 0 | 94% | 77 | wrong type: 04/11/1994 |
| fr-cv-01 | 2735 | 33 | 29 | 2 | 1 | 1 | 1 | 94% | 206 | missed: Italie; wrong type: France; extra: SIRET(ADDRESS) |
| fr-insurance-01 | 2386 | 29 | 25 | 2 | 2 | 0 | 3 | 92% | 267 | missed: lieu-dit Le Bourdieu, centre hospitalier d'Agen; extra: Sud-Ouest(COMPANY), SANTÉ ESSENTIEL 3(COMPANY), on Sud-Ouest(ADDRESS) |
| fr-invoice-01 | 1754 | 25 | 22 | 2 | 1 | 0 | 1 | 96% | 724 | missed: Résidence Les Hauts de Caudéran; extra: SIRET(ADDRESS) |
| fr-jobad-01 | 3198 | 16 | 14 | 2 | 0 | 0 | 2 | 95% | 241 | extra: du Grand Ouest(ADDRESS), de Brétigny-la-Forêt(ADDRESS) |
| fr-lease-01 | 708 | 17 | 15 | 2 | 0 | 0 | 1 | 97% | 68 | extra: 1er(DATE) |
| fr-letter-01 | 1402 | 21 | 16 | 3 | 2 | 0 | 1 | 93% | 126 | missed: Résidence Les Coteaux, bâtiment B, appartement 214; extra: Caisse d'allocations familiales de la Haute-Garonne(COMPANY) |
| fr-manual-01 | 3617 | 4 | 2 | 1 | 1 | 0 | 5 | 60% | 244 | missed: NM-4200; extra: VOLTARIS 4200(ADDRESS), TH-VLT-4200-B(ID), VLT42-KJ-01873(ID), 60335-2-51(NUMBER), 61000-6-3(NUMBER) |
| fr-medical-01 | 1539 | 22 | 18 | 4 | 0 | 0 | 3 | 94% | 146 | extra: Collègue(PERSON)×2, LAMal(COMPANY) |
| fr-notice-01 | 3131 | 12 | 8 | 4 | 0 | 0 | 15 | 65% | 195 | extra: rue des Tanneurs(ADDRESS)×2, RUE DES TANNEURS ET(ADDRESS), PLACE DU MARCHÉ COUVERT(ADDRESS), de la place du Marché couvert, du(ADDRESS), Gare(ADDRESS), Hôpital nord(ADDRESS), le boulevard Sainte-Colombe(ADDRESS), Tanneurs(ADDRESS), Sainte-Colombe(ADDRESS), Poste(ADDRESS), rue des Tanneurs, la(ADDRESS), place du Marché couvert(ADDRESS) … +2 more |
| fr-payslip-01 | 2597 | 29 | 25 | 2 | 2 | 0 | 1 | 95% | 252 | missed: Alsace, bâtiment 4, 2e étage; extra: URSSAF Alsace(PERSON) |
| fr-policy-01 | 3340 | 19 | 12 | 3 | 4 | 0 | 3 | 82% | 215 | missed: NS-2024-008, Île-de-France, Grenoble, 379 615 244 00073; extra: France(COMPANY), RCS Grenoble 379 615 244(ID), SIRET(ADDRESS) |
| fr-support-01 | 1684 | 24 | 19 | 2 | 3 | 0 | 1 | 92% | 153 | missed: R-118472, 6H-4410829, 3716; extra: M. Tran-Bouchard(PERSON) |
| fr-terms-01 | 3983 | 14 | 11 | 2 | 1 | 0 | 1 | 93% | 258 | missed: Nantes; extra: SIRET(ADDRESS) |
