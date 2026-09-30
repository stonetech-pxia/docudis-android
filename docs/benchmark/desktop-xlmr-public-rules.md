# NER benchmark (desktop, Python onnxruntime)

- Model: xlm-roberta-base-ner-docudis
- Platform: windows "Windows 11 Famille" 10.0 (Build 26200), CPU, onnxruntime via bench_server.py
- Cases: 45, expected entities: 890
- Overall: recall 92%, precision 85%, F1 88% → reliability **B**; 288 ms per 1000 chars → speed **A**

Grades: reliability by F1 (A ≥ 90%, B ≥ 75%, C ≥ 50%, D below); speed by ms per 1000 characters on this platform (A < 300, B < 1000, C < 3000, D above).

## By language

| Language | Cases | Expected | Found | False pos. | Recall | Precision | F1 | Reliability | ms/1000 chars | Speed |
|---|---|---|---|---|---|---|---|---|---|---|
| fr | 15 | 165 | 132 | 37 | 80% | 82% | 81% | B | 56 | A |
| es | 14 | 381 | 361 | 98 | 95% | 81% | 87% | B | 171 | A |
| en | 16 | 344 | 324 | 43 | 94% | 91% | 93% | A | 582 | B |

## By category

| Category | Cases | Expected | Found | False pos. | Recall | Precision | F1 | Reliability | ms/1000 chars | Speed |
|---|---|---|---|---|---|---|---|---|---|---|
| registry | 29 | 546 | 493 | 135 | 90% | 81% | 86% | B | 137 | A |
| notice | 8 | 118 | 108 | 19 | 92% | 90% | 91% | A | 563 | B |
| email | 8 | 226 | 216 | 24 | 96% | 92% | 94% | A | 598 | B |

## Per case

| Case | Chars | Expected | Hit | Partial | Missed | Wrong type | False pos. | F1 | ms | Notes |
|---|---|---|---|---|---|---|---|---|---|---|
| fr-bodacc-creation-01 | 630 | 8 | 4 | 2 | 1 | 1 | 1 | 76% | 50 | missed: Arras; wrong type: BENJAMIN ROUSSEAU; extra: Greffe du Tribunal de Commerce d'Arras(COMPANY) |
| fr-bodacc-creation-02 | 588 | 8 | 5 | 1 | 2 | 0 | 2 | 76% | 32 | missed: Boulogne-sur-Mer, 109 790 832; extra: Greffe du Tribunal de Commerce de Boulogne-sur-Mer(COMPANY), RCS Boulogne-sur-Mer 109 790 832(ID) |
| fr-bodacc-creation-03 | 559 | 8 | 5 | 1 | 2 | 0 | 2 | 76% | 30 | missed: Boulogne-sur-Mer, 109 954 446; extra: Greffe du Tribunal de Commerce de Boulogne-sur-Mer(COMPANY), RCS Boulogne-sur-Mer 109 954 446(ID) |
| fr-bodacc-creation-04 | 825 | 9 | 6 | 1 | 2 | 0 | 2 | 80% | 34 | missed: Boulogne-sur-Mer, 130 037 054; extra: Greffe du Tribunal de Commerce de Boulogne-sur-Mer(COMPANY), RCS Boulogne-sur-Mer 130 037 054(ID) |
| fr-bodacc-vente-01 | 1558 | 20 | 10 | 5 | 5 | 0 | 8 | 75% | 98 | missed: 066 351 420, 024 083 321, EAI 340, 2026 E n°1606, Zone Industrielle Kaweni BP 633 Route nationale 1 - 97600 MAMOUDZOU; extra: SIE(COMPANY)×2, 2026 E(ADDRESS)×2, Greffe du Tribunal Mixte de Commerce de Mamoudzou(COMPANY), RCS Mamoudzou 066 351 420(ID), RCS Mamoudzou 024 083 321(ID), Zone Industrielle Kaweni(COMPANY) |
| fr-bodacc-vente-02 | 1205 | 16 | 8 | 6 | 2 | 0 | 1 | 91% | 63 | missed: Nice, AIR DU TEMPS; extra: Greffe du Tribunal de Commerce de Nice(COMPANY) |
| fr-bodacc-vente-03 | 1465 | 18 | 8 | 4 | 5 | 1 | 6 | 69% | 79 | missed: Marseille, 107 137 887, 809 297 807, 1314P61 2026 A 04288, Adrien JOLY; wrong type: FF BONNEVEINE MENAGER; extra: Greffe du Tribunal des Activités Economiques de Marseille(COMPANY), RCS Marseille 107 137 887(ID), RCS Marseille 809 297 807(ID), SDE(COMPANY), 04288 Adresse(ADDRESS), Étude Maître Adrien JOLY(COMPANY) |
| fr-bodacc-vente-04 | 1147 | 16 | 12 | 2 | 2 | 0 | 4 | 84% | 72 | missed: 108 184 912, 452 805 666; extra: Greffe du Tribunal de Commerce de Grenoble(COMPANY), RCS Grenoble 108 184 912(ID), RCS Grenoble 452 805 666(ID), Dauphiné(ADDRESS) |
| fr-bodacc-collective-01 | 1040 | 11 | 7 | 3 | 1 | 0 | 2 | 88% | 66 | missed: Reims; extra: Greffe du Tribunal de Commerce de Reims(COMPANY), par Actions(COMPANY) |
| fr-bodacc-collective-02 | 864 | 10 | 6 | 2 | 2 | 0 | 2 | 82% | 42 | missed: Lons-le-Saunier, 893 120 105; extra: Greffe du Tribunal de Commerce de Lons-le-Saunier(COMPANY), RCS Lons-le-Saunier 893 120 105(ID) |
| fr-bodacc-collective-03 | 867 | 10 | 6 | 3 | 1 | 0 | 2 | 87% | 41 | missed: 919 580 597; extra: Greffe du Tribunal de Commerce de Grenoble(COMPANY), RCS Grenoble 919 580 597(ID) |
| fr-bodacc-collective-04 | 915 | 11 | 7 | 1 | 3 | 0 | 2 | 77% | 49 | missed: le Puy en Velay, 852 650 407, 10 rue de la Ronzade 43000 Le Puy-en-Velay; extra: Greffe du Tribunal de Commerce du Puy-en-Velay(COMPANY), RCS le Puy en Velay 852 650 407(ID) |
| fr-bodacc-modification-01 | 561 | 6 | 3 | 2 | 1 | 0 | 1 | 85% | 29 | missed: Rennes; extra: Greffe du Tribunal de Commerce de Rennes(COMPANY) |
| fr-bodacc-modification-02 | 448 | 8 | 5 | 2 | 1 | 0 | 1 | 88% | 23 | missed: Tours; extra: Greffe du Tribunal de Commerce de Tours(COMPANY) |
| fr-bodacc-modification-03 | 483 | 6 | 3 | 2 | 1 | 0 | 1 | 85% | 23 | missed: Nantes; extra: Greffe du Tribunal de Commerce de Nantes(COMPANY) |
| es-borme-01-1 | 2009 | 27 | 25 | 2 | 0 | 0 | 6 | 93% | 108 | extra: 4.09.24)(DATE)×5, 02003 (ALBACETE).(ADDRESS) |
| es-borme-01-2 | 2078 | 28 | 24 | 4 | 0 | 0 | 7 | 90% | 110 | extra: 4.09.24)(DATE)×5, 02005 (ALBACETE).(ADDRESS), 02660 (CAUDETE).(ADDRESS) |
| es-borme-01-3 | 1399 | 22 | 21 | 1 | 0 | 0 | 3 | 94% | 72 | extra: 5.09.24)(DATE)×3 |
| es-borme-02-1 | 2204 | 30 | 22 | 1 | 7 | 0 | 5 | 80% | 114 | missed: TRESCIENTOS CINCUENTA Y SIETE MIL CIENTO DIEZ EUROS, 357.110,00E, UN EURO, 1,00E, TREINTA Y DOS MIL EUROS, 32.000 E, 1 E; extra: 5.09.24)(DATE)×5 |
| es-borme-02-2 | 3285 | 29 | 24 | 1 | 4 | 0 | 5 | 86% | 153 | missed: TREINTA Y TRES MIL EUROS, 33. 000, 00E, DIEZ EUROS, 10E; extra: 5.09.24)(DATE)×5 |
| es-borme-02-3 | 1945 | 24 | 19 | 1 | 4 | 0 | 5 | 83% | 108 | missed: UN MILLON QUINIENTOS CUARENTA Y SEIS MIL NOVECIENTOS CUARENTA Y SIETE EUROS, 1.546.947.- E, Calle Galeón, edificio 1, 3ºA, 04711 ALMERIMAR, EL EJIDO, ALMERIA, C/ GALEON 3º A EDIFICIO 1. ALMERIMAR. (EJIDO (EL)); extra: 5.09.24)(DATE)×5 |
| es-borme-03-1 | 2112 | 27 | 24 | 3 | 0 | 0 | 11 | 83% | 121 | extra: 5.09.24)(DATE)×5, Dimisiones(COMPANY)×4, 06200 (ALMENDRALEJO).(ADDRESS), CNAE(ADDRESS) |
| es-borme-03-2 | 3244 | 28 | 21 | 6 | 1 | 0 | 6 | 90% | 166 | missed: CTRA DE ENTRERRIOS, S/N-FABRICA DE TRANSA 06700 (VILLANUEVA DE LA SERENA); extra: 5.09.24)(DATE)×4, 3.09.24.(DATE), CNAE 9609(ID) |
| es-borme-04-1 | 1713 | 23 | 16 | 5 | 2 | 0 | 9 | 82% | 100 | missed: Z21406076C, C/ FAISAN, 10-LOCAL 2, NUESTRA SEÑORA DE JESUS 078 (SANTA EULALIA DEL RIO); extra: 5.09.24)(DATE)×4, R.M. EIVISSA(PERSON)×3, R.M. EIVISSA(ADDRESS), M. EIVISSA(ADDRESS) |
| es-borme-04-2 | 1310 | 18 | 16 | 2 | 0 | 0 | 10 | 83% | 73 | extra: 5.09.24)(DATE)×5, M. EIVISSA(ADDRESS)×2, R.M. EIVISSA(ADDRESS)×2, .M. EIVISSA(ADDRESS) |
| es-borme-04-3 | 2295 | 34 | 29 | 4 | 1 | 0 | 11 | 86% | 132 | missed: C/ SANT BARTOMEU, 1 07760 (CIUTADELLA DE MENORCA); extra: Jueves(PERSON)×2, 5.09.24)(DATE)×2, 2.09.24)(DATE)×2, R.M. MAHON(ADDRESS)×2, R.M. EIVISSA(ADDRESS), R.M. MAHON(PERSON), 07760 (CIUTADELLA DE MENORCA).(ADDRESS) |
| es-borme-05-1 | 1833 | 29 | 23 | 6 | 0 | 0 | 3 | 95% | 108 | extra: 88506 DONDE SE LEE COMO PRIMER APELLIDO DEL ADMINISTRADOR UNICO(ADDRESS), DO DE LA APODERADA(PERSON), DEL APODERADO(PERSON) |
| es-borme-05-2 | 2133 | 29 | 21 | 7 | 1 | 0 | 8 | 87% | 1574 | missed: 3.000,00; extra: NOMBRE(PERSON)×2, 5.09.24)(DATE)×2, ANDREU COMA, SIENSO SU NOMBRE COMPLETO(PERSON), ANDREU COMA, SIENDO SU NOMBRE COMPLETO(PERSON), (11.07.24)(DATE), 4.09.24.(DATE) |
| es-borme-05-3 | 3058 | 33 | 19 | 14 | 0 | 0 | 9 | 89% | 2297 | extra: 5.09.24)(DATE)×6, 4.09.24.(DATE)×2, 5.09.24.(DATE) |
| en-gazette-01 | 864 | 14 | 13 | 1 | 0 | 0 | 2 | 96% | 498 | extra: Wood(COMPANY)×2 |
| en-gazette-02 | 795 | 14 | 10 | 2 | 2 | 0 | 2 | 88% | 422 | missed: Walter Dawson & Son, New North Road, Heckmondwike, West Yorkshire, WF16 9DH; extra: Canal(COMPANY), Dalton House(COMPANY) |
| en-gazette-03 | 1111 | 19 | 16 | 2 | 1 | 0 | 1 | 95% | 610 | missed: Suite B, Blackdown House, Blackbrook Park Avenue, Taunton, Somerset, TA1 2PX; extra: Hermes House(COMPANY) |
| en-gazette-04 | 1315 | 17 | 13 | 2 | 2 | 0 | 8 | 82% | 821 | missed: The Mill House Court Farm, Church Lane, Norton, Worcester, WR5 2PS, Unit 14C Hartlebury Trading Estate, Hartlebury, Kidderminste, DY104JB; extra: Farm(COMPANY)×3, Wood(COMPANY)×2, The Mill(COMPANY), Norton(COMPANY), Worcester(COMPANY) |
| en-gazette-05 | 939 | 18 | 16 | 1 | 1 | 0 | 2 | 93% | 681 | missed: Azzurri House, Walsall Business Park, Walsall Road, Walsall, West Midlands, WS9 0RB; extra: Azzurri House(COMPANY)×2 |
| en-gazette-06 | 977 | 14 | 11 | 2 | 1 | 0 | 2 | 91% | 600 | missed: The Union Building 51-59 Rose Lane, Norwich, NR1 1BY; extra: , Northampton, Northamptonshire, NN1 5JF (Formerly) The Union Building 51-59 Rose Lane, Norwich, (ADDRESS), United(COMPANY) |
| en-gazette-07 | 2521 | 11 | 9 | 1 | 1 | 0 | 1 | 93% | 1262 | missed: 2 Lakeside, Calder Island Way, Wakefield, WF2 7AW; extra: Rules(COMPANY) |
| en-gazette-08 | 2318 | 11 | 9 | 0 | 2 | 0 | 1 | 88% | 1210 | missed: Caledon Community Centre, Caledon Road, London Colney, St Albans, Hertfordshire AL2 1PU, 15 Horizon Business Village, 1 Brooklands Road, Weybridge, Surrey, KT13 0TJ; extra: N/A(ADDRESS) |
| en-enron-01 | 863 | 16 | 15 | 1 | 0 | 0 | 3 | 92% | 459 | extra: Trading Track A&A(COMPANY)×3 |
| en-enron-02 | 2306 | 52 | 50 | 1 | 1 | 0 | 6 | 94% | 1604 | missed: Suite 165; extra: CAISO re(COMPANY)×2, Desert Southwest(ADDRESS)×2, Southwest(COMPANY), Corp(PERSON) |
| en-enron-03 | 1341 | 15 | 13 | 0 | 2 | 0 | 0 | 93% | 795 | missed: Enron North America, Global Products |
| en-enron-04 | 1423 | 31 | 27 | 2 | 2 | 0 | 3 | 93% | 827 | missed: Kath, UBS; extra: WTC Parking

Kath(COMPANY), WTC Parking

Portland(COMPANY), Enron Portland(COMPANY) |
| en-enron-05 | 946 | 19 | 15 | 1 | 2 | 1 | 2 | 84% | 598 | missed: EnronOnline, RICE; wrong type: Rice; extra: HOU(PERSON), ECT(PERSON) |
| en-enron-06 | 1170 | 19 | 18 | 0 | 1 | 0 | 3 | 92% | 661 | missed: EPMI; extra: will(PERSON), EPMI-West-Bank(COMPANY), Enpower(COMPANY) |
| en-enron-07 | 2195 | 60 | 55 | 5 | 0 | 0 | 7 | 96% | 1342 | extra: Unify Gas(COMPANY)×2, SQL_MAIL(PERSON)×2, Gas(COMPANY)×2, Smith, Regan M.(PERSON) |
| en-enron-08 | 1589 | 14 | 13 | 0 | 1 | 0 | 0 | 96% | 790 | missed: California |
