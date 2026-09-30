# NER benchmark (desktop, Python onnxruntime)

- Model: xlm-roberta-base-ner-docudis
- Platform: windows "Windows 11 Famille" 10.0 (Build 26200), CPU, onnxruntime via bench_server.py
- Cases: 60, expected entities: 2138
- Overall: recall 92%, precision 94%, F1 93% → reliability **A**; 555 ms per 1000 chars → speed **B**

Grades: reliability by F1 (A ≥ 90%, B ≥ 75%, C ≥ 50%, D below); speed by ms per 1000 characters on this platform (A < 300, B < 1000, C < 3000, D above).

## By language

| Language | Cases | Expected | Found | False pos. | Recall | Precision | F1 | Reliability | ms/1000 chars | Speed |
|---|---|---|---|---|---|---|---|---|---|---|
| en | 20 | 730 | 669 | 45 | 92% | 95% | 93% | A | 412 | B |
| es | 20 | 652 | 613 | 41 | 94% | 95% | 94% | A | 596 | B |
| fr | 20 | 756 | 692 | 66 | 92% | 93% | 92% | A | 659 | B |

## By category

| Category | Cases | Expected | Found | False pos. | Recall | Precision | F1 | Reliability | ms/1000 chars | Speed |
|---|---|---|---|---|---|---|---|---|---|---|
| bank | 6 | 172 | 158 | 14 | 92% | 92% | 92% | A | 436 | B |
| chat | 6 | 77 | 69 | 12 | 90% | 91% | 90% | A | 496 | B |
| cv | 6 | 244 | 216 | 32 | 89% | 90% | 89% | B | 409 | B |
| insurance | 6 | 307 | 289 | 11 | 94% | 97% | 95% | A | 423 | B |
| invoice | 6 | 300 | 274 | 20 | 91% | 95% | 93% | A | 611 | B |
| lease | 6 | 241 | 219 | 14 | 91% | 95% | 93% | A | 618 | B |
| letter | 6 | 196 | 187 | 7 | 95% | 97% | 96% | A | 587 | B |
| medical | 6 | 228 | 217 | 13 | 95% | 95% | 95% | A | 648 | B |
| payslip | 6 | 194 | 179 | 9 | 92% | 96% | 94% | A | 646 | B |
| support | 6 | 179 | 166 | 20 | 93% | 91% | 92% | A | 621 | B |

## Per case

| Case | Chars | Expected | Hit | Partial | Missed | Wrong type | False pos. | F1 | ms | Notes |
|---|---|---|---|---|---|---|---|---|---|---|
| en-bank-01 | 2033 | 37 | 34 | 0 | 3 | 0 | 2 | 93% | 122 | missed: NatWest, Bristol, SVL-002931-AM; extra: NatWest
Premier Banking(COMPANY), Wales(ADDRESS) |
| en-bank-02 | 865 | 22 | 17 | 3 | 2 | 0 | 3 | 89% | 57 | missed: 7702, 0817; extra: Wire Services(COMPANY), Airstream(COMPANY), FDIC(COMPANY) |
| en-chat-01 | 952 | 21 | 20 | 0 | 1 | 0 | 4 | 93% | 57 | missed: 14 Birchfield Court, Evington Road, Leicester LE2 1HJ; extra: van(PERSON)×2, flat is 14 Birchfield Court, Evington Road, Leicester (ADDRESS), van mans(PERSON) |
| en-chat-02 | 470 | 10 | 7 | 0 | 3 | 0 | 2 | 76% | 23 | missed: dana, halvorsen, reggie; extra: brightwater(ADDRESS), ping dana(PERSON) |
| en-cv-01 | 3677 | 40 | 33 | 2 | 5 | 0 | 8 | 86% | 197 | missed: AACN, Byrdine F. Lewis College of Nursing, Sigma Theta Tau, Hôpital Saint-Michel, Jacmel, Haiti; extra: ACLS(COMPANY), BLS(COMPANY), CLABSI(COMPANY), Byrdine(ADDRESS), 12/2027)(DATE), Hôpital Saint-Michel, Jacmel, Haiti(ADDRESS), Philips IntelliVue(COMPANY), Alaris(ADDRESS) |
| en-cv-02 | 2742 | 34 | 28 | 3 | 2 | 1 | 2 | 92% | 257 | missed: Tesco, Unit 9, Kings Weston Trade Park, Avonmouth, Bristol BS11 8AZ; wrong type: St John Ambulance; extra: Tesco Distribution(COMPANY), City(ADDRESS) |
| en-insurance-01 | 4270 | 71 | 62 | 1 | 7 | 1 | 2 | 92% | 274 | missed: Aviva, 7 Cois Cuain, Bearna, Co. Galway, Premium Credit, 3308, 6120; wrong type: 02/11/1985; extra: 7 Cois Cuain
                 Bearna(ADDRESS), Aviva 24-hour claims(COMPANY) |
| en-insurance-02 | 2210 | 40 | 34 | 3 | 3 | 0 | 0 | 96% | 142 | missed: Ecclesall, PLM/SHF/118264, 4402 |
| en-invoice-01 | 2150 | 44 | 37 | 4 | 3 | 0 | 3 | 93% | 189 | missed: Leeds, Q-1187, WISNIEWSKA; extra: Worcester(COMPANY), 24781 WISNIEWSKA(ADDRESS), O&D Building Services Ltd.(COMPANY) |
| en-invoice-02 | 4444 | 59 | 48 | 4 | 7 | 0 | 0 | 94% | 3407 | missed: P.O. Box 660418, Dallas, TX 75266-0418, 1554, $0.098700, Oncor, $0.025510, 13.9 cents, 2217 LARKSPUR TRL APT 1406 PLANO TX 75074 |
| en-lease-01 | 4358 | 45 | 40 | 1 | 4 | 0 | 3 | 93% | 2649 | missed: 1184 Neil Avenue, Apt. 2C, Columbus, OH 43201, pay.hallgrenpm.com, AEP Ohio, Columbus, OH 43215; extra: Section(ADDRESS)×2, Rules(COMPANY) |
| en-lease-02 | 977 | 21 | 18 | 1 | 2 | 0 | 0 | 95% | 674 | missed: 0214, 17 Cnoc na Cathrach, Knocknacarra, Galway, H91 T2RV |
| en-letter-01 | 2190 | 42 | 42 | 0 | 0 | 0 | 1 | 99% | 1218 | extra: FIRST CLASS POST(COMPANY) |
| en-letter-02 | 2168 | 29 | 25 | 2 | 2 | 0 | 1 | 95% | 1281 | missed: Leeds, Mehta; extra: rose(PERSON) |
| en-medical-01 | 4464 | 53 | 45 | 4 | 4 | 0 | 3 | 94% | 2786 | missed: Leeds Teaching Hospitals NHS Trust, St James's University Hospital, Leeds, 80-2214; extra: The Leeds Teaching Hospitals NHS Trust
St James's University Hospital(COMPANY), June 2026(DATE), Clinic C(COMPANY) |
| en-medical-02 | 1438 | 30 | 25 | 4 | 1 | 0 | 2 | 96% | 949 | missed: Mylan; extra: 00378-1805(ADDRESS), Mylan    Discard(PERSON) |
| en-payslip-01 | 3821 | 38 | 36 | 0 | 2 | 0 | 2 | 95% | 2324 | missed: $27.4500, Alliant Credit Union; extra: Illinois(ADDRESS), +1       86.50(NUMBER) |
| en-payslip-02 | 1275 | 28 | 23 | 2 | 3 | 0 | 0 | 94% | 814 | missed: HARCASTLE JOINERY, Loughborough, 20-49 |
| en-support-01 | 2759 | 41 | 39 | 1 | 1 | 0 | 7 | 93% | 1737 | missed: 9901; extra: BA1393(ID)×4, Mastercard(COMPANY)×2, Terminal 5(ADDRESS) |
| en-support-02 | 1470 | 25 | 20 | 1 | 4 | 0 | 0 | 91% | 904 | missed: Apartment 12, Millrace Court, Old Kilmainham, Dublin 8, D08 X4K7, Tomasz, AIB, 4471 |
| es-bank-01 | 2148 | 37 | 32 | 3 | 2 | 0 | 1 | 96% | 1113 | missed: 4410, Vallès Occidental; extra: 0417 Terrassa(ADDRESS) |
| es-bank-02 | 942 | 19 | 17 | 1 | 1 | 0 | 2 | 93% | 601 | missed: ABANCA; extra: ABANCA Avisos(COMPANY), Oficina 0417(ADDRESS) |
| es-chat-01 | 926 | 14 | 13 | 1 | 0 | 0 | 1 | 98% | 699 | extra: iban(PERSON) |
| es-chat-02 | 441 | 9 | 8 | 0 | 1 | 0 | 0 | 94% | 284 | missed: grupo alcor |
| es-cv-01 | 3673 | 48 | 41 | 3 | 4 | 0 | 10 | 88% | 2082 | missed: Zamudio (Bizkaia), 4,3 M€, Coslada (Madrid), Bermeo (Bizkaia); extra: Suministro(COMPANY), 2020-2021(NUMBER), 2008-2013(NUMBER), 2011-2012(NUMBER), 2013-2015(NUMBER), Cámara de Comercio de Bilbao(COMPANY), 05/2028(DATE), Lanbide(COMPANY), Cambridge(COMPANY), 2026(DATE) |
| es-cv-02 | 2268 | 29 | 24 | 3 | 2 | 0 | 3 | 93% | 1246 | missed: Pereira, Colombia, Aula de Cata Ribera Alta; extra: 11/2027(DATE), INAEM(COMPANY), Revo(PERSON) |
| es-insurance-01 | 4026 | 53 | 49 | 3 | 1 | 0 | 3 | 97% | 2405 | missed: MU-80.417; extra: Consorcio de Compensación de Seguros(COMPANY), Seguros y Reaseguros. Entidad(COMPANY), General de Seguros y Fondos de Pensiones. Santamaría Ortuño Correduría de Seguros, S.L.(COMPANY) |
| es-insurance-02 | 2170 | 33 | 29 | 4 | 0 | 0 | 2 | 98% | 1308 | extra: Turia Hogar Plus(COMPANY), Aseguradora Turia, S.A. de Seguros y Reaseguros. Inscrita(COMPANY) |
| es-invoice-01 | 1987 | 26 | 22 | 1 | 3 | 0 | 2 | 91% | 1239 | missed: C/ Telletxe, 12, bajo · 48991 Getxo (Bizkaia), P-26/0412, 48/IF-02917; extra: FRA 2026(ID), 02917 (Gobierno Vasco)(ADDRESS) |
| es-invoice-02 | 4391 | 65 | 52 | 5 | 8 | 0 | 1 | 93% | 2675 | missed: 0,083921 €, 0,012575 €, 0,189450 €, 0,142310 €, 0,098760 €, 0,026630 €, 0,012742 €, Apartado de Correos 4127, 50080 Zaragoza; extra: Correos(COMPANY) |
| es-lease-01 | 4441 | 57 | 48 | 6 | 2 | 1 | 2 | 95% | 2525 | missed: 684, 31.877; wrong type: Canal de Isabel II; extra: I. Que Berzosa Anguita Patrimonio, S.L.(COMPANY), p.p. Berzosa Anguita Patrimonio, S.L.(COMPANY) |
| es-lease-02 | 989 | 24 | 22 | 1 | 1 | 0 | 1 | 96% | 636 | missed: C/ El Peso 27, 1º, 14900 Lucena (Córdoba); extra: DE ALQUILER Nº 47(COMPANY) |
| es-letter-01 | 2075 | 33 | 31 | 0 | 2 | 0 | 1 | 96% | 1186 | missed: 3.412, ATL-2026/0381; extra: DESTINATARIO(COMPANY) |
| es-letter-02 | 2105 | 26 | 25 | 1 | 0 | 0 | 1 | 99% | 1189 | extra: Pilar(ADDRESS) |
| es-medical-01 | 4463 | 40 | 35 | 3 | 2 | 0 | 3 | 94% | 2656 | missed: 36208 Vigo (Pontevedra), Costel Munteanu; extra: Vigo
Hospital Álvaro Cunqueiro(COMPANY), cardiaca(COMPANY), Cardiaca(COMPANY) |
| es-medical-02 | 1350 | 21 | 18 | 2 | 1 | 0 | 0 | 98% | 906 | missed: LABORATORIO IBARZ |
| es-payslip-01 | 4002 | 35 | 31 | 1 | 3 | 0 | 1 | 94% | 2340 | missed: Trabanca, Rúa Ourense, 9, 2º esq. - 36630 Cambados (Pontevedra), PO-31.906; extra: Planta de Trabanca(COMPANY) |
| es-payslip-02 | 1557 | 26 | 22 | 2 | 2 | 0 | 1 | 94% | 1152 | missed: EMBUTIDOS Y SALAZONES, A. M. Ciobanu; extra: C.I(COMPANY) |
| es-support-01 | 2731 | 37 | 34 | 0 | 2 | 1 | 6 | 89% | 1639 | missed: 08841527, 8036; wrong type: QK7M2D; extra: QK7M2D(ADDRESS)×3, Mastercard(COMPANY)×2, AVE(COMPANY) |
| es-support-02 | 1474 | 20 | 19 | 1 | 0 | 0 | 0 | 100% | 829 |  |
| fr-bank-01 | 2050 | 38 | 30 | 3 | 5 | 0 | 2 | 91% | 1355 | missed: Bayonne Saint-Esprit, Bât. C - Appt 27, 30857, 70037, 77; extra: Agence de Bayonne Saint-Esprit(COMPANY)×2 |
| fr-bank-02 | 899 | 19 | 15 | 3 | 1 | 0 | 4 | 88% | 651 | missed: CIC; extra: SEPA(PERSON)×2, Agence Schiltigheim Centre(COMPANY), CIC Schiltigheim Centre(COMPANY) |
| fr-chat-01 | 965 | 14 | 10 | 1 | 2 | 1 | 5 | 80% | 711 | missed: jo, 3e etage; wrong type: leclerc; extra: jai(PERSON)×2, karim sil(PERSON), quil(PERSON), Momo(COMPANY) |
| fr-chat-02 | 413 | 9 | 9 | 0 | 0 | 0 | 0 | 100% | 289 |  |
| fr-cv-01 | 3471 | 57 | 46 | 2 | 7 | 2 | 7 | 85% | 2243 | missed: 4,2 M€, Pays basque, ETCHEVERRY Maitena, AFTRAL, IUT de Bordeaux, IUT de Bayonne et du Pays basque, Ustaritz; wrong type: Irun, Pampelune; extra: 64)(ADDRESS)×2, Micro-entreprise ETCHEVERRY Maitena(COMPANY), SIRET(ADDRESS), AFTRAL Bordeaux(COMPANY), TOEIC(COMPANY), Leroy Merlin Mérignac(PERSON) |
| fr-cv-02 | 2307 | 36 | 30 | 1 | 2 | 3 | 2 | 87% | 1385 | missed: Nord vaudois, Suisse; wrong type: Bulle, Morat, Guin; extra: 2022-2024(NUMBER), 2015          Cours de chef d'équipe(ADDRESS) |
| fr-insurance-01 | 4012 | 71 | 62 | 5 | 4 | 0 | 2 | 96% | 2441 | missed: MMA, Le Mans, 775 652 126, 440 048 882; extra: RCS Le Mans 775 652 126(ID), RCS Le Mans 440 048 882(ID) |
| fr-insurance-02 | 2190 | 39 | 32 | 5 | 2 | 0 | 2 | 95% | 1416 | missed: Bât. C - 3e étage - Appt 32, appt 42; extra: Multirisque Habitation Sérénité(COMPANY), Habitation

MASO Assurances(COMPANY) |
| fr-invoice-01 | 2142 | 41 | 35 | 5 | 1 | 0 | 3 | 95% | 1465 | missed: 833 304 132; extra: Atlantic(COMPANY), EURL(ADDRESS), RCS Quimper 833 304 132(ID) |
| fr-invoice-02 | 4038 | 65 | 50 | 11 | 4 | 0 | 11 | 91% | 2723 | missed: RESIDENCE LE BELVEDERE BAT A APPT 207, Libre réponse n° 59252, 75443 Paris Cedex 09, TSA 70233 - 34967 Montpellier Cedex 2, 619 326 754; extra: BELVEDERE(COMPANY), Linky(PERSON), GONCALVES PEREIRA
IBAN(PERSON), pleines  48(ADDRESS), Dépannage électricité Enedis(COMPANY), 34967 Montpellier Cedex 2.(ADDRESS), 59252(NUMBER), 75443 Paris Cedex 09.(ADDRESS), TALON(ADDRESS), IBAN(PERSON), RCS Montpellier 619 326 754(ID) |
| fr-lease-01 | 4331 | 71 | 54 | 5 | 10 | 2 | 8 | 85% | 2685 | missed: 204, 477 897 292, 433 002 565, SYLLA, FERREIRA, CHU de Montpellier, Bâtiment : B     Étage : 2e     Porte : 204, 1er octobre, 41 avenue Roger Salengro, Escalier 2, 94500 Champigny-sur-Marne, soixante-cinq mille cinq cent vingt euros; wrong type: AOGI, FNAIM; extra: RCS de Montpellier sous le numéro 477 897 292(ID), AOGI GESTION LOCATIVE(COMPANY), SYLLA-FERREIRA LOT(PERSON), AOGI(ADDRESS), AFS(COMPANY), AOGI(PERSON), SARL(PERSON), RCS Montpellier 433 002 565(ID) |
| fr-lease-02 | 1025 | 23 | 21 | 2 | 0 | 0 | 0 | 100% | 786 |  |
| fr-letter-01 | 2178 | 42 | 38 | 2 | 1 | 1 | 0 | 96% | 1403 | missed: 0417-B32; wrong type: Aydın |
| fr-letter-02 | 2076 | 24 | 20 | 1 | 3 | 0 | 3 | 88% | 1227 | missed: Lucie-Aubrac, Anne, Kerleroux; extra: rose(PERSON), école élémentaire
Lucie-Aubrac(COMPANY), dentaire Anne
Kerleroux(COMPANY) |
| fr-medical-01 | 4423 | 61 | 57 | 3 | 0 | 1 | 4 | 96% | 3061 | wrong type: Cuincy; extra: Confrère(PERSON)×2, Veuve(PERSON), FINESS(ADDRESS) |
| fr-medical-02 | 1306 | 23 | 18 | 3 | 2 | 0 | 1 | 94% | 935 | missed: COULIBALY, Fatoumata; extra: COULIBALY
Fatoumata(PERSON) |
| fr-payslip-01 | 4459 | 40 | 36 | 1 | 3 | 0 | 3 | 93% | 3082 | missed: AG2R, Bas-Rhin, 778 972 976; extra: Agirc-Arrco(COMPANY), CPAM du Bas-Rhin(COMPANY), RCS Strasbourg 778 972 976(ID) |
| fr-payslip-02 | 1652 | 27 | 24 | 1 | 2 | 0 | 2 | 93% | 1115 | missed: Bretagne, PRO BTP; extra: SIRET(ADDRESS), Mutuelle PRO BTP(COMPANY) |
| fr-support-01 | 2718 | 36 | 27 | 4 | 5 | 0 | 6 | 86% | 1761 | missed: Chronopost, 8538, Lille Métropole, 676 336 068, Résidence Les Hauts du Lac, esc. D, 5e étage, appt 512; extra: Mastercard(COMPANY)×2, Lenovo(COMPANY), Livraisons(COMPANY), RCS Lille Métropole 676 336 068(ID), SignalConso(COMPANY) |
| fr-support-02 | 1404 | 20 | 19 | 1 | 0 | 0 | 1 | 98% | 928 | extra: boulanger(PERSON) |
