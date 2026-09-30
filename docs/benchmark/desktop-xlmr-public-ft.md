# NER benchmark (desktop, Python onnxruntime)

- Model: xlm-roberta-base-ner-docudis
- Platform: windows "Windows 11 Famille" 10.0 (Build 26200), CPU, onnxruntime via bench_server.py
- Cases: 45, expected entities: 890
- Overall: recall 90%, precision 84%, F1 87% → reliability **B**; 54 ms per 1000 chars → speed **A**

Grades: reliability by F1 (A ≥ 90%, B ≥ 75%, C ≥ 50%, D below); speed by ms per 1000 characters on this platform (A < 300, B < 1000, C < 3000, D above).

## By language

| Language | Cases | Expected | Found | False pos. | Recall | Precision | F1 | Reliability | ms/1000 chars | Speed |
|---|---|---|---|---|---|---|---|---|---|---|
| fr | 15 | 165 | 132 | 37 | 80% | 82% | 81% | B | 57 | A |
| es | 14 | 381 | 358 | 113 | 94% | 79% | 86% | B | 54 | A |
| en | 16 | 344 | 314 | 40 | 91% | 91% | 91% | A | 54 | A |

## By category

| Category | Cases | Expected | Found | False pos. | Recall | Precision | F1 | Reliability | ms/1000 chars | Speed |
|---|---|---|---|---|---|---|---|---|---|---|
| registry | 29 | 546 | 490 | 150 | 90% | 80% | 84% | B | 55 | A |
| notice | 8 | 118 | 97 | 18 | 82% | 89% | 86% | B | 55 | A |
| email | 8 | 226 | 217 | 22 | 96% | 93% | 94% | A | 53 | A |

## Per case

| Case | Chars | Expected | Hit | Partial | Missed | Wrong type | False pos. | F1 | ms | Notes |
|---|---|---|---|---|---|---|---|---|---|---|
| fr-bodacc-creation-01 | 630 | 8 | 4 | 2 | 1 | 1 | 1 | 76% | 47 | missed: Arras; wrong type: BENJAMIN ROUSSEAU; extra: Greffe du Tribunal de Commerce d'Arras(COMPANY) |
| fr-bodacc-creation-02 | 588 | 8 | 5 | 1 | 2 | 0 | 2 | 76% | 32 | missed: Boulogne-sur-Mer, 109 790 832; extra: Greffe du Tribunal de Commerce de Boulogne-sur-Mer(COMPANY), RCS Boulogne-sur-Mer 109 790 832(ID) |
| fr-bodacc-creation-03 | 559 | 8 | 5 | 1 | 2 | 0 | 2 | 76% | 29 | missed: Boulogne-sur-Mer, 109 954 446; extra: Greffe du Tribunal de Commerce de Boulogne-sur-Mer(COMPANY), RCS Boulogne-sur-Mer 109 954 446(ID) |
| fr-bodacc-creation-04 | 825 | 9 | 6 | 1 | 2 | 0 | 2 | 80% | 39 | missed: Boulogne-sur-Mer, 130 037 054; extra: Greffe du Tribunal de Commerce de Boulogne-sur-Mer(COMPANY), RCS Boulogne-sur-Mer 130 037 054(ID) |
| fr-bodacc-vente-01 | 1558 | 20 | 10 | 6 | 4 | 0 | 10 | 75% | 109 | missed: 066 351 420, 024 083 321, EAI 340, 2026 E n°1606; extra: SIE(COMPANY)×2, Opération(COMPANY)×2, 2026 E(ADDRESS)×2, Greffe du Tribunal Mixte de Commerce de Mamoudzou(COMPANY), RCS Mamoudzou 066 351 420(ID), RCS Mamoudzou 024 083 321(ID), Flash Infos(COMPANY) |
| fr-bodacc-vente-02 | 1205 | 16 | 8 | 6 | 2 | 0 | 1 | 91% | 71 | missed: Nice, AIR DU TEMPS; extra: Greffe du Tribunal de Commerce de Nice(COMPANY) |
| fr-bodacc-vente-03 | 1465 | 18 | 8 | 4 | 5 | 1 | 5 | 70% | 70 | missed: Marseille, 107 137 887, 809 297 807, 1314P61 2026 A 04288, Adrien JOLY; wrong type: FF BONNEVEINE MENAGER; extra: Greffe du Tribunal des Activités Economiques de Marseille(COMPANY), RCS Marseille 107 137 887(ID), RCS Marseille 809 297 807(ID), 04288 Adresse(ADDRESS), Étude Maître Adrien JOLY(COMPANY) |
| fr-bodacc-vente-04 | 1147 | 16 | 11 | 2 | 3 | 0 | 4 | 81% | 75 | missed: Grenoble, 108 184 912, 452 805 666; extra: Greffe du Tribunal de Commerce de Grenoble(COMPANY), RCS Grenoble 108 184 912(ID), RCS Grenoble 452 805 666(ID), Dauphiné(ADDRESS) |
| fr-bodacc-collective-01 | 1040 | 11 | 7 | 3 | 1 | 0 | 1 | 92% | 65 | missed: Reims; extra: Greffe du Tribunal de Commerce de Reims(COMPANY) |
| fr-bodacc-collective-02 | 864 | 10 | 6 | 2 | 2 | 0 | 2 | 82% | 46 | missed: Lons-le-Saunier, 893 120 105; extra: Greffe du Tribunal de Commerce de Lons-le-Saunier(COMPANY), RCS Lons-le-Saunier 893 120 105(ID) |
| fr-bodacc-collective-03 | 867 | 10 | 6 | 3 | 1 | 0 | 2 | 87% | 41 | missed: 919 580 597; extra: Greffe du Tribunal de Commerce de Grenoble(COMPANY), RCS Grenoble 919 580 597(ID) |
| fr-bodacc-collective-04 | 915 | 11 | 7 | 1 | 3 | 0 | 2 | 77% | 43 | missed: le Puy en Velay, 852 650 407, 10 rue de la Ronzade 43000 Le Puy-en-Velay; extra: Greffe du Tribunal de Commerce du Puy-en-Velay(COMPANY), RCS le Puy en Velay 852 650 407(ID) |
| fr-bodacc-modification-01 | 561 | 6 | 3 | 2 | 1 | 0 | 1 | 85% | 27 | missed: Rennes; extra: Greffe du Tribunal de Commerce de Rennes(COMPANY) |
| fr-bodacc-modification-02 | 448 | 8 | 5 | 2 | 1 | 0 | 1 | 88% | 22 | missed: Tours; extra: Greffe du Tribunal de Commerce de Tours(COMPANY) |
| fr-bodacc-modification-03 | 483 | 6 | 3 | 2 | 1 | 0 | 1 | 85% | 21 | missed: Nantes; extra: Greffe du Tribunal de Commerce de Nantes(COMPANY) |
| es-borme-01-1 | 2009 | 27 | 25 | 2 | 0 | 0 | 6 | 93% | 106 | extra: 4.09.24)(DATE)×5, 02003 (ALBACETE).(ADDRESS) |
| es-borme-01-2 | 2078 | 28 | 24 | 4 | 0 | 0 | 9 | 87% | 113 | extra: 4.09.24)(DATE)×5, Jueves(ADDRESS)×2, 02005 (ALBACETE).(ADDRESS), 02660 (CAUDETE).(ADDRESS) |
| es-borme-01-3 | 1399 | 22 | 21 | 1 | 0 | 0 | 3 | 94% | 71 | extra: 5.09.24)(DATE)×3 |
| es-borme-02-1 | 2204 | 30 | 22 | 1 | 7 | 0 | 6 | 79% | 108 | missed: TRESCIENTOS CINCUENTA Y SIETE MIL CIENTO DIEZ EUROS, 357.110,00E, UN EURO, 1,00E, TREINTA Y DOS MIL EUROS, 32.000 E, 1 E; extra: 5.09.24)(DATE)×5, Jueves(ADDRESS) |
| es-borme-02-2 | 3285 | 29 | 24 | 1 | 4 | 0 | 5 | 86% | 150 | missed: TREINTA Y TRES MIL EUROS, 33. 000, 00E, DIEZ EUROS, 10E; extra: 5.09.24)(DATE)×5 |
| es-borme-02-3 | 1945 | 24 | 19 | 1 | 4 | 0 | 5 | 83% | 102 | missed: UN MILLON QUINIENTOS CUARENTA Y SEIS MIL NOVECIENTOS CUARENTA Y SIETE EUROS, 1.546.947.- E, Calle Galeón, edificio 1, 3ºA, 04711 ALMERIMAR, EL EJIDO, ALMERIA, C/ GALEON 3º A EDIFICIO 1. ALMERIMAR. (EJIDO (EL)); extra: 5.09.24)(DATE)×5 |
| es-borme-03-1 | 2112 | 27 | 24 | 3 | 0 | 0 | 12 | 82% | 108 | extra: 5.09.24)(DATE)×5, Dimisiones(COMPANY)×4, Jueves(ADDRESS), 06200 (ALMENDRALEJO).(ADDRESS), CNAE(ADDRESS) |
| es-borme-03-2 | 3244 | 28 | 22 | 5 | 1 | 0 | 8 | 88% | 157 | missed: CTRA DE ENTRERRIOS, S/N-FABRICA DE TRANSA 06700 (VILLANUEVA DE LA SERENA); extra: 5.09.24)(DATE)×4, Jueves(ADDRESS)×2, 3.09.24.(DATE), CNAE 9609(ID) |
| es-borme-04-1 | 1713 | 23 | 16 | 4 | 2 | 1 | 9 | 79% | 95 | missed: Z21406076C, C/ FAISAN, 10-LOCAL 2, NUESTRA SEÑORA DE JESUS 078 (SANTA EULALIA DEL RIO); wrong type: EIVISSA; extra: 5.09.24)(DATE)×4, . EIVISSA(PERSON)×2, R.M. EIVISSA(PERSON)×2, EIVISSA(PERSON) |
| es-borme-04-2 | 1310 | 18 | 16 | 2 | 0 | 0 | 11 | 82% | 77 | extra: 5.09.24)(DATE)×5, . EIVISSA(COMPANY)×2, Jueves(ADDRESS), .M. EIVISSA(COMPANY), EIVISSA(COMPANY), R.M. EIVISSA(ADDRESS) |
| es-borme-04-3 | 2295 | 34 | 28 | 3 | 1 | 2 | 11 | 81% | 155 | missed: C/ SANT BARTOMEU, 1 07760 (CIUTADELLA DE MENORCA); wrong type: EIVISSA, MAHON; extra: R.M. MAHON(PERSON)×3, 5.09.24)(DATE)×2, 2.09.24)(DATE)×2, Jueves(ADDRESS), EIVISSA(PERSON), Jueves(PERSON), 07760 (CIUTADELLA DE MENORCA).(ADDRESS) |
| es-borme-05-1 | 1833 | 29 | 22 | 7 | 0 | 0 | 2 | 97% | 114 | extra: 88506 DONDE SE LEE COMO PRIMER APELLIDO DEL ADMINISTRADOR UNICO(ADDRESS), DEL APODERADO(PERSON) |
| es-borme-05-2 | 2133 | 29 | 20 | 8 | 1 | 0 | 8 | 87% | 117 | missed: 3.000,00; extra: NOMBRE(PERSON)×2, 5.09.24)(DATE)×2, ANDREU COMA, SIENSO SU NOMBRE COMPLETO(PERSON), ANDREU COMA, SIENDO SU NOMBRE COMPLETO(PERSON), (11.07.24)(DATE), 4.09.24.(DATE) |
| es-borme-05-3 | 3058 | 33 | 22 | 11 | 0 | 0 | 18 | 80% | 168 | extra: UNICO(PERSON)×8, 5.09.24)(DATE)×6, 4.09.24.(DATE)×2, 5.09.24.(DATE), UNICO SHAHBAZ YOUSAF(PERSON) |
| en-gazette-01 | 864 | 14 | 11 | 1 | 2 | 0 | 2 | 88% | 45 | missed: 31850, 32230; extra: Wood(COMPANY)×2 |
| en-gazette-02 | 795 | 14 | 9 | 2 | 2 | 1 | 2 | 81% | 35 | missed: New North Road, Heckmondwike, West Yorkshire, WF16 9DH, 29010; wrong type: Walter Dawson & Son; extra: Canal(COMPANY), Dalton House(COMPANY) |
| en-gazette-03 | 1111 | 19 | 14 | 2 | 3 | 0 | 1 | 90% | 62 | missed: Suite B, Blackdown House, Blackbrook Park Avenue, Taunton, Somerset, TA1 2PX, 11110, 18032; extra: Hermes House(COMPANY) |
| en-gazette-04 | 1315 | 17 | 11 | 2 | 4 | 0 | 6 | 78% | 67 | missed: The Mill House Court Farm, Church Lane, Norton, Worcester, WR5 2PS, Unit 14C Hartlebury Trading Estate, Hartlebury, Kidderminste, DY104JB, 31850, 32230; extra: Wood(COMPANY)×2, The Mill(COMPANY), Norton(COMPANY), Worcester(COMPANY), Hall Farm(COMPANY) |
| en-gazette-05 | 939 | 18 | 13 | 1 | 4 | 0 | 2 | 84% | 57 | missed: CR-2026-BHM-0004, 22930, Azzurri House, Walsall Business Park, Walsall Road, Walsall, West Midlands, WS9 0RB, 020730; extra: Azzurri House(COMPANY)×2 |
| en-gazette-06 | 977 | 14 | 10 | 2 | 2 | 0 | 2 | 87% | 54 | missed: The Union Building 51-59 Rose Lane, Norwich, NR1 1BY, 13890; extra: , Northampton, Northamptonshire, NN1 5JF (Formerly) The Union Building 51-59 Rose Lane, Norwich, (ADDRESS), United(COMPANY) |
| en-gazette-07 | 2521 | 11 | 9 | 1 | 1 | 0 | 1 | 93% | 123 | missed: 2 Lakeside, Calder Island Way, Wakefield, WF2 7AW; extra: Rules(COMPANY) |
| en-gazette-08 | 2318 | 11 | 9 | 0 | 2 | 0 | 2 | 85% | 147 | missed: Caledon Community Centre, Caledon Road, London Colney, St Albans, Hertfordshire AL2 1PU, 15 Horizon Business Village, 1 Brooklands Road, Weybridge, Surrey, KT13 0TJ; extra: N/A(ADDRESS), Turpin Barker Armstrong(PERSON) |
| en-enron-01 | 863 | 16 | 16 | 0 | 0 | 0 | 3 | 92% | 39 | extra: Trading Track A&A(COMPANY)×2, Track(COMPANY) |
| en-enron-02 | 2306 | 52 | 52 | 0 | 0 | 0 | 5 | 96% | 133 | extra: Desert Southwest(ADDRESS)×3, Corp(PERSON), Enron(PERSON) |
| en-enron-03 | 1341 | 15 | 13 | 0 | 2 | 0 | 0 | 93% | 68 | missed: Enron North America, Global Products |
| en-enron-04 | 1423 | 31 | 27 | 2 | 2 | 0 | 3 | 93% | 70 | missed: Kath, UBS; extra: WTC(COMPANY)×2, Enron Portland(COMPANY) |
| en-enron-05 | 946 | 19 | 16 | 1 | 1 | 1 | 0 | 92% | 51 | missed: RICE; wrong type: Rice |
| en-enron-06 | 1170 | 19 | 18 | 0 | 1 | 0 | 3 | 92% | 59 | missed: EPMI; extra: will(PERSON), EPMI-West-Bank(COMPANY), Enpower(COMPANY) |
| en-enron-07 | 2195 | 60 | 54 | 5 | 1 | 0 | 8 | 94% | 123 | missed: ENA; extra: Gas(COMPANY)×3, SQL_MAIL(PERSON)×2, Gas Settlements(COMPANY), ENA Sales/Supply(COMPANY), Smith, Regan M.(PERSON) |
| en-enron-08 | 1589 | 14 | 13 | 0 | 0 | 1 | 0 | 93% | 76 | wrong type: Hertzberg |
