# NER benchmark (desktop, Python onnxruntime)

- Model: xlm-roberta-base-ner-docudis
- Platform: windows "Windows 11 Famille" 10.0 (Build 26200), CPU, onnxruntime via bench_server.py
- Cases: 45, expected entities: 890
- Overall: recall 90%, precision 86%, F1 88% → reliability **B**; 588 ms per 1000 chars → speed **B**

Grades: reliability by F1 (A ≥ 90%, B ≥ 75%, C ≥ 50%, D below); speed by ms per 1000 characters on this platform (A < 300, B < 1000, C < 3000, D above).

## By language

| Language | Cases | Expected | Found | False pos. | Recall | Precision | F1 | Reliability | ms/1000 chars | Speed |
|---|---|---|---|---|---|---|---|---|---|---|
| fr | 15 | 165 | 131 | 35 | 79% | 83% | 81% | B | 100 | A |
| es | 14 | 381 | 358 | 101 | 94% | 81% | 87% | B | 681 | B |
| en | 16 | 344 | 313 | 32 | 91% | 93% | 92% | A | 746 | B |

## By category

| Category | Cases | Expected | Found | False pos. | Recall | Precision | F1 | Reliability | ms/1000 chars | Speed |
|---|---|---|---|---|---|---|---|---|---|---|
| registry | 29 | 546 | 489 | 136 | 90% | 81% | 85% | B | 507 | B |
| notice | 8 | 118 | 96 | 21 | 81% | 88% | 84% | B | 678 | B |
| email | 8 | 226 | 217 | 11 | 96% | 96% | 96% | A | 808 | B |

## Per case

| Case | Chars | Expected | Hit | Partial | Missed | Wrong type | False pos. | F1 | ms | Notes |
|---|---|---|---|---|---|---|---|---|---|---|
| fr-bodacc-creation-01 | 630 | 8 | 4 | 2 | 1 | 1 | 1 | 76% | 68 | missed: Arras; wrong type: BENJAMIN ROUSSEAU; extra: Greffe du Tribunal de Commerce d'Arras(COMPANY) |
| fr-bodacc-creation-02 | 588 | 8 | 5 | 1 | 2 | 0 | 2 | 76% | 42 | missed: Boulogne-sur-Mer, 109 790 832; extra: Greffe du Tribunal de Commerce de Boulogne-sur-Mer(COMPANY), RCS Boulogne-sur-Mer 109 790 832(ID) |
| fr-bodacc-creation-03 | 559 | 8 | 5 | 1 | 2 | 0 | 2 | 76% | 47 | missed: Boulogne-sur-Mer, 109 954 446; extra: Greffe du Tribunal de Commerce de Boulogne-sur-Mer(COMPANY), RCS Boulogne-sur-Mer 109 954 446(ID) |
| fr-bodacc-creation-04 | 825 | 9 | 6 | 1 | 2 | 0 | 2 | 80% | 75 | missed: Boulogne-sur-Mer, 130 037 054; extra: Greffe du Tribunal de Commerce de Boulogne-sur-Mer(COMPANY), RCS Boulogne-sur-Mer 130 037 054(ID) |
| fr-bodacc-vente-01 | 1558 | 20 | 10 | 5 | 5 | 0 | 6 | 78% | 175 | missed: 066 351 420, 024 083 321, EAI 340, 2026 E n°1606, Zone Industrielle Kaweni BP 633 Route nationale 1 - 97600 MAMOUDZOU; extra: 2026 E(ADDRESS)×2, Greffe du Tribunal Mixte de Commerce de Mamoudzou(COMPANY), RCS Mamoudzou 066 351 420(ID), RCS Mamoudzou 024 083 321(ID), Industrielle Kaweni(COMPANY) |
| fr-bodacc-vente-02 | 1205 | 16 | 8 | 6 | 2 | 0 | 1 | 91% | 154 | missed: Nice, AIR DU TEMPS; extra: Greffe du Tribunal de Commerce de Nice(COMPANY) |
| fr-bodacc-vente-03 | 1465 | 18 | 8 | 4 | 6 | 0 | 7 | 69% | 165 | missed: Marseille, 107 137 887, 809 297 807, FF BONNEVEINE MENAGER, 1314P61 2026 A 04288, Adrien JOLY; extra: Greffe du Tribunal des Activités Economiques de Marseille(COMPANY), RCS Marseille 107 137 887(ID), RCS Marseille 809 297 807(ID), BONNEVEINE MENAGER(PERSON), SDE(COMPANY), 04288 Adresse(ADDRESS), Étude Maître Adrien JOLY(COMPANY) |
| fr-bodacc-vente-04 | 1147 | 16 | 11 | 2 | 3 | 0 | 4 | 81% | 160 | missed: Grenoble, 108 184 912, 452 805 666; extra: Greffe du Tribunal de Commerce de Grenoble(COMPANY), RCS Grenoble 108 184 912(ID), RCS Grenoble 452 805 666(ID), Les Affiches de Grenoble et du Dauphiné(COMPANY) |
| fr-bodacc-collective-01 | 1040 | 11 | 7 | 3 | 1 | 0 | 1 | 92% | 99 | missed: Reims; extra: Greffe du Tribunal de Commerce de Reims(COMPANY) |
| fr-bodacc-collective-02 | 864 | 10 | 6 | 2 | 2 | 0 | 2 | 82% | 70 | missed: Lons-le-Saunier, 893 120 105; extra: Greffe du Tribunal de Commerce de Lons-le-Saunier(COMPANY), RCS Lons-le-Saunier 893 120 105(ID) |
| fr-bodacc-collective-03 | 867 | 10 | 6 | 3 | 1 | 0 | 2 | 87% | 68 | missed: 919 580 597; extra: Greffe du Tribunal de Commerce de Grenoble(COMPANY), RCS Grenoble 919 580 597(ID) |
| fr-bodacc-collective-04 | 915 | 11 | 7 | 1 | 3 | 0 | 2 | 77% | 66 | missed: le Puy en Velay, 852 650 407, 10 rue de la Ronzade 43000 Le Puy-en-Velay; extra: Greffe du Tribunal de Commerce du Puy-en-Velay(COMPANY), RCS le Puy en Velay 852 650 407(ID) |
| fr-bodacc-modification-01 | 561 | 6 | 3 | 2 | 1 | 0 | 1 | 85% | 44 | missed: Rennes; extra: Greffe du Tribunal de Commerce de Rennes(COMPANY) |
| fr-bodacc-modification-02 | 448 | 8 | 5 | 2 | 1 | 0 | 1 | 88% | 43 | missed: Tours; extra: Greffe du Tribunal de Commerce de Tours(COMPANY) |
| fr-bodacc-modification-03 | 483 | 6 | 3 | 2 | 1 | 0 | 1 | 85% | 31 | missed: Nantes; extra: Greffe du Tribunal de Commerce de Nantes(COMPANY) |
| es-borme-01-1 | 2009 | 27 | 25 | 2 | 0 | 0 | 6 | 93% | 129 | extra: 4.09.24)(DATE)×5, 02003 (ALBACETE).(ADDRESS) |
| es-borme-01-2 | 2078 | 28 | 24 | 4 | 0 | 0 | 7 | 90% | 1534 | extra: 4.09.24)(DATE)×5, 02005 (ALBACETE).(ADDRESS), 02660 (CAUDETE).(ADDRESS) |
| es-borme-01-3 | 1399 | 22 | 21 | 1 | 0 | 0 | 3 | 94% | 960 | extra: 5.09.24)(DATE)×3 |
| es-borme-02-1 | 2204 | 30 | 22 | 1 | 7 | 0 | 5 | 80% | 1615 | missed: TRESCIENTOS CINCUENTA Y SIETE MIL CIENTO DIEZ EUROS, 357.110,00E, UN EURO, 1,00E, TREINTA Y DOS MIL EUROS, 32.000 E, 1 E; extra: 5.09.24)(DATE)×5 |
| es-borme-02-2 | 3285 | 29 | 24 | 1 | 4 | 0 | 5 | 86% | 2028 | missed: TREINTA Y TRES MIL EUROS, 33. 000, 00E, DIEZ EUROS, 10E; extra: 5.09.24)(DATE)×5 |
| es-borme-02-3 | 1945 | 24 | 19 | 1 | 4 | 0 | 7 | 80% | 1479 | missed: UN MILLON QUINIENTOS CUARENTA Y SEIS MIL NOVECIENTOS CUARENTA Y SIETE EUROS, 1.546.947.- E, Calle Galeón, edificio 1, 3ºA, 04711 ALMERIMAR, EL EJIDO, ALMERIA, C/ GALEON 3º A EDIFICIO 1. ALMERIMAR. (EJIDO (EL)); extra: 5.09.24)(DATE)×5, EJIDO(PERSON)×2 |
| es-borme-03-1 | 2112 | 27 | 24 | 3 | 0 | 0 | 7 | 89% | 1508 | extra: 5.09.24)(DATE)×5, 06200 (ALMENDRALEJO).(ADDRESS), CNAE(ADDRESS) |
| es-borme-03-2 | 3244 | 28 | 20 | 7 | 1 | 0 | 6 | 90% | 2049 | missed: CTRA DE ENTRERRIOS, S/N-FABRICA DE TRANSA 06700 (VILLANUEVA DE LA SERENA); extra: 5.09.24)(DATE)×4, 3.09.24.(DATE), CNAE 9609(ID) |
| es-borme-04-1 | 1713 | 23 | 17 | 4 | 2 | 0 | 10 | 81% | 1361 | missed: Z21406076C, C/ FAISAN, 10-LOCAL 2, NUESTRA SEÑORA DE JESUS 078 (SANTA EULALIA DEL RIO); extra: 5.09.24)(DATE)×4, R.M. EIVISSA(ADDRESS)×3, .M. EIVISSA(ADDRESS), 07849 (SANTA EULALIA DEL RIO).(ADDRESS), M. EIVISSA(ADDRESS) |
| es-borme-04-2 | 1310 | 18 | 17 | 1 | 0 | 0 | 10 | 83% | 946 | extra: 5.09.24)(DATE)×5, EIVISSA(COMPANY)×2, R.M. EIVISSA(COMPANY), .M. EIVISSA(COMPANY), .M. EIVISSA(ADDRESS) |
| es-borme-04-3 | 2295 | 34 | 28 | 3 | 1 | 2 | 9 | 83% | 1705 | missed: C/ SANT BARTOMEU, 1 07760 (CIUTADELLA DE MENORCA); wrong type: EIVISSA, MAHON; extra: 5.09.24)(DATE)×2, 2.09.24)(DATE)×2, MAHON(PERSON)×2, EIVISSA(COMPANY), .M. MAHON(PERSON), 07760 (CIUTADELLA DE MENORCA).(ADDRESS) |
| es-borme-05-1 | 1833 | 29 | 23 | 6 | 0 | 0 | 1 | 98% | 1563 | extra: 88506 DONDE SE LEE COMO PRIMER APELLIDO DEL ADMINISTRADOR UNICO(ADDRESS) |
| es-borme-05-2 | 2133 | 29 | 21 | 7 | 1 | 0 | 8 | 87% | 1564 | missed: 3.000,00; extra: NOMBRE(PERSON)×2, 5.09.24)(DATE)×2, ANDREU COMA, SIENSO SU NOMBRE COMPLETO(PERSON), ANDREU COMA, SIENDO SU NOMBRE COMPLETO(PERSON), (11.07.24)(DATE), 4.09.24.(DATE) |
| es-borme-05-3 | 3058 | 33 | 17 | 15 | 1 | 0 | 17 | 80% | 2414 | missed: ALEJANDRO QUINTANS OSeS; extra: UNICO(PERSON)×6, 5.09.24)(DATE)×6, 4.09.24.(DATE)×2, 5.09.24.(DATE), UNICO SHAHBAZ YOUSAF(PERSON), UNICO ALEJANDRO QUINTANS(PERSON) |
| en-gazette-01 | 864 | 14 | 11 | 1 | 2 | 0 | 4 | 84% | 514 | missed: 31850, 32230; extra: Heskin Hall Farm(COMPANY)×2, Wood(COMPANY)×2 |
| en-gazette-02 | 795 | 14 | 9 | 2 | 3 | 0 | 2 | 83% | 538 | missed: Walter Dawson & Son, New North Road, Heckmondwike, West Yorkshire, WF16 9DH, 29010; extra: Canal(COMPANY), Dalton House,(COMPANY) |
| en-gazette-03 | 1111 | 19 | 13 | 3 | 3 | 0 | 1 | 90% | 788 | missed: Suite B, Blackdown House, Blackbrook Park Avenue, Taunton, Somerset, TA1 2PX, 11110, 18032; extra: Hermes House(COMPANY) |
| en-gazette-04 | 1315 | 17 | 11 | 2 | 4 | 0 | 7 | 76% | 1018 | missed: The Mill House Court Farm, Church Lane, Norton, Worcester, WR5 2PS, Unit 14C Hartlebury Trading Estate, Hartlebury, Kidderminste, DY104JB, 31850, 32230; extra: Wood(COMPANY)×2, The Mill(COMPANY), Norton(COMPANY), Worcester(COMPANY), Hall Farm(COMPANY), Heskin Hall Farm(COMPANY) |
| en-gazette-05 | 939 | 18 | 12 | 1 | 5 | 0 | 2 | 80% | 789 | missed: Birmingham, CR-2026-BHM-0004, 22930, Azzurri House, Walsall Business Park, Walsall Road, Walsall, West Midlands, WS9 0RB, 020730; extra: Azzurri House(COMPANY)×2 |
| en-gazette-06 | 977 | 14 | 10 | 2 | 2 | 0 | 2 | 87% | 760 | missed: The Union Building 51-59 Rose Lane, Norwich, NR1 1BY, 13890; extra: , Northampton, Northamptonshire, NN1 5JF (Formerly) The Union Building 51-59 Rose Lane, Norwich, (ADDRESS), United(COMPANY) |
| en-gazette-07 | 2521 | 11 | 9 | 1 | 1 | 0 | 1 | 93% | 1465 | missed: 2 Lakeside, Calder Island Way, Wakefield, WF2 7AW; extra: Rules(COMPANY) |
| en-gazette-08 | 2318 | 11 | 9 | 0 | 2 | 0 | 2 | 85% | 1473 | missed: Caledon Community Centre, Caledon Road, London Colney, St Albans, Hertfordshire AL2 1PU, 15 Horizon Business Village, 1 Brooklands Road, Weybridge, Surrey, KT13 0TJ; extra: N/A(ADDRESS), Armstrong(PERSON) |
| en-enron-01 | 863 | 16 | 16 | 0 | 0 | 0 | 0 | 100% | 526 |  |
| en-enron-02 | 2306 | 52 | 50 | 1 | 1 | 0 | 3 | 97% | 1976 | missed: Suite 165; extra: Desert Southwest(ADDRESS)×2, Desert Southwest

tom(PERSON) |
| en-enron-03 | 1341 | 15 | 14 | 0 | 1 | 0 | 0 | 97% | 911 | missed: Enron North America |
| en-enron-04 | 1423 | 31 | 27 | 2 | 2 | 0 | 2 | 94% | 1057 | missed: Kath, UBS; extra: WTC Parking

Portland(COMPANY), Enron Portland(COMPANY) |
| en-enron-05 | 946 | 19 | 16 | 1 | 1 | 1 | 2 | 87% | 1028 | missed: RICE; wrong type: Rice; extra: HOU(PERSON), ECT(PERSON) |
| en-enron-06 | 1170 | 19 | 18 | 0 | 1 | 0 | 2 | 94% | 1216 | missed: EPMI; extra: will(PERSON), EPMI-West-Bank(COMPANY) |
| en-enron-07 | 2195 | 60 | 54 | 5 | 1 | 0 | 2 | 98% | 1895 | missed: ENA; extra: Gas Settlements(COMPANY), Smith, Regan M.(PERSON) |
| en-enron-08 | 1589 | 14 | 13 | 0 | 0 | 1 | 0 | 93% | 947 | wrong type: Hertzberg |
