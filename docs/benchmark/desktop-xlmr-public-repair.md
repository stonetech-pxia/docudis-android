# NER benchmark (desktop, Python onnxruntime)

- Model: xlm-roberta-base-ner-docudis
- Platform: windows "Windows 11 Famille" 10.0 (Build 26200), CPU, onnxruntime via bench_server.py
- Cases: 45, expected entities: 890
- Overall: recall 91%, precision 84%, F1 87% → reliability **B**; 50 ms per 1000 chars → speed **A**

Grades: reliability by F1 (A ≥ 90%, B ≥ 75%, C ≥ 50%, D below); speed by ms per 1000 characters on this platform (A < 300, B < 1000, C < 3000, D above).

## By language

| Language | Cases | Expected | Found | False pos. | Recall | Precision | F1 | Reliability | ms/1000 chars | Speed |
|---|---|---|---|---|---|---|---|---|---|---|
| fr | 15 | 165 | 129 | 42 | 78% | 80% | 79% | B | 54 | A |
| es | 14 | 381 | 351 | 105 | 92% | 80% | 85% | B | 50 | A |
| en | 16 | 344 | 328 | 47 | 95% | 90% | 93% | A | 48 | A |

## By category

| Category | Cases | Expected | Found | False pos. | Recall | Precision | F1 | Reliability | ms/1000 chars | Speed |
|---|---|---|---|---|---|---|---|---|---|---|
| registry | 29 | 546 | 480 | 147 | 88% | 80% | 84% | B | 51 | A |
| notice | 8 | 118 | 111 | 24 | 94% | 87% | 90% | A | 45 | A |
| email | 8 | 226 | 217 | 23 | 96% | 92% | 94% | A | 51 | A |

## Per case

| Case | Chars | Expected | Hit | Partial | Missed | Wrong type | False pos. | F1 | ms | Notes |
|---|---|---|---|---|---|---|---|---|---|---|
| fr-bodacc-creation-01 | 630 | 8 | 4 | 2 | 1 | 1 | 1 | 76% | 50 | missed: Arras; wrong type: BENJAMIN ROUSSEAU; extra: Greffe du Tribunal de Commerce d'Arras(COMPANY) |
| fr-bodacc-creation-02 | 588 | 8 | 5 | 1 | 2 | 0 | 2 | 76% | 31 | missed: Boulogne-sur-Mer, 109 790 832; extra: Greffe du Tribunal de Commerce de Boulogne-sur-Mer(COMPANY), RCS Boulogne-sur-Mer 109 790 832(ID) |
| fr-bodacc-creation-03 | 559 | 8 | 5 | 1 | 2 | 0 | 2 | 76% | 29 | missed: Boulogne-sur-Mer, 109 954 446; extra: Greffe du Tribunal de Commerce de Boulogne-sur-Mer(COMPANY), RCS Boulogne-sur-Mer 109 954 446(ID) |
| fr-bodacc-creation-04 | 825 | 9 | 6 | 1 | 2 | 0 | 2 | 80% | 37 | missed: Boulogne-sur-Mer, 130 037 054; extra: Greffe du Tribunal de Commerce de Boulogne-sur-Mer(COMPANY), RCS Boulogne-sur-Mer 130 037 054(ID) |
| fr-bodacc-vente-01 | 1558 | 20 | 9 | 6 | 5 | 0 | 11 | 71% | 105 | missed: 066 351 420, 024 083 321, EAI 340, 2026 E n°1606, Zone Industrielle Kaweni BP 633 Route nationale 1 - 97600 MAMOUDZOU; extra: Dossier Opération EAI 340(COMPANY)×2, 2026 E(ADDRESS)×2, Greffe du Tribunal Mixte de Commerce de Mamoudzou(COMPANY), RCS Mamoudzou 066 351 420(ID), RCS Mamoudzou 024 083 321(ID), Enregistrement de SIE MAMOUDZOU le(ADDRESS), Enregistrement de SIE(ADDRESS), MAMOUDZOU le(ADDRESS), Flash Infos(COMPANY) |
| fr-bodacc-vente-02 | 1205 | 16 | 8 | 5 | 3 | 0 | 2 | 85% | 63 | missed: Nice, AIR DU TEMPS, 27 Rue Carnot 06500 Menton; extra: Greffe du Tribunal de Commerce de Nice(COMPANY), Notaire 27 Rue Carnot (ADDRESS) |
| fr-bodacc-vente-03 | 1465 | 18 | 7 | 5 | 5 | 1 | 6 | 69% | 65 | missed: Marseille, 107 137 887, 809 297 807, 1314P61 2026 A 04288, Adrien JOLY; wrong type: FF BONNEVEINE MENAGER; extra: Greffe du Tribunal des Activités Economiques de Marseille(COMPANY), RCS Marseille 107 137 887(ID), RCS Marseille 809 297 807(ID), SDE(COMPANY), 1314P61 2026 A 04288 Adresse de(ADDRESS), Étude Maître Adrien JOLY(COMPANY) |
| fr-bodacc-vente-04 | 1147 | 16 | 10 | 3 | 3 | 0 | 5 | 79% | 83 | missed: Grenoble, 108 184 912, 452 805 666; extra: Greffe du Tribunal de Commerce de Grenoble(COMPANY), RCS Grenoble 108 184 912(ID), RCS Grenoble 452 805 666(ID), Les Affiches de Grenoble(COMPANY), du Dauphiné(COMPANY) |
| fr-bodacc-collective-01 | 1040 | 11 | 7 | 3 | 1 | 0 | 1 | 92% | 62 | missed: Reims; extra: Greffe du Tribunal de Commerce de Reims(COMPANY) |
| fr-bodacc-collective-02 | 864 | 10 | 6 | 2 | 2 | 0 | 3 | 78% | 35 | missed: Lons-le-Saunier, 893 120 105; extra: Greffe du Tribunal de Commerce de Lons-le-Saunier(COMPANY), RCS Lons-le-Saunier 893 120 105(ID), Société par Actions Simplifiée(COMPANY) |
| fr-bodacc-collective-03 | 867 | 10 | 6 | 3 | 1 | 0 | 2 | 87% | 35 | missed: 919 580 597; extra: Greffe du Tribunal de Commerce de Grenoble(COMPANY), RCS Grenoble 919 580 597(ID) |
| fr-bodacc-collective-04 | 915 | 11 | 7 | 1 | 3 | 0 | 2 | 77% | 37 | missed: le Puy en Velay, 852 650 407, 10 rue de la Ronzade 43000 Le Puy-en-Velay; extra: Greffe du Tribunal de Commerce du Puy-en-Velay(COMPANY), RCS le Puy en Velay 852 650 407(ID) |
| fr-bodacc-modification-01 | 561 | 6 | 2 | 2 | 1 | 1 | 1 | 69% | 24 | missed: Rennes; wrong type: PILLOT Nathalie Michèle; extra: Greffe du Tribunal de Commerce de Rennes(COMPANY) |
| fr-bodacc-modification-02 | 448 | 8 | 5 | 2 | 1 | 0 | 1 | 88% | 20 | missed: Tours; extra: Greffe du Tribunal de Commerce de Tours(COMPANY) |
| fr-bodacc-modification-03 | 483 | 6 | 3 | 2 | 1 | 0 | 1 | 85% | 20 | missed: Nantes; extra: Greffe du Tribunal de Commerce de Nantes(COMPANY) |
| es-borme-01-1 | 2009 | 27 | 24 | 3 | 0 | 0 | 6 | 93% | 93 | extra: 4.09.24)(DATE)×5, 02003 (ALBACETE). Datos(ADDRESS) |
| es-borme-01-2 | 2078 | 28 | 23 | 5 | 0 | 0 | 7 | 90% | 115 | extra: 4.09.24)(DATE)×5, 02005 (ALBACETE). Capital(ADDRESS), 02660 (CAUDETE). Datos(ADDRESS) |
| es-borme-01-3 | 1399 | 22 | 21 | 1 | 0 | 0 | 3 | 94% | 69 | extra: 5.09.24)(DATE)×3 |
| es-borme-02-1 | 2204 | 30 | 22 | 1 | 7 | 0 | 5 | 80% | 97 | missed: TRESCIENTOS CINCUENTA Y SIETE MIL CIENTO DIEZ EUROS, 357.110,00E, UN EURO, 1,00E, TREINTA Y DOS MIL EUROS, 32.000 E, 1 E; extra: 5.09.24)(DATE)×5 |
| es-borme-02-2 | 3285 | 29 | 24 | 1 | 4 | 0 | 5 | 86% | 157 | missed: TREINTA Y TRES MIL EUROS, 33. 000, 00E, DIEZ EUROS, 10E; extra: 5.09.24)(DATE)×5 |
| es-borme-02-3 | 1945 | 24 | 19 | 1 | 4 | 0 | 6 | 81% | 117 | missed: UN MILLON QUINIENTOS CUARENTA Y SEIS MIL NOVECIENTOS CUARENTA Y SIETE EUROS, 1.546.947.- E, Calle Galeón, edificio 1, 3ºA, 04711 ALMERIMAR, EL EJIDO, ALMERIA, C/ GALEON 3º A EDIFICIO 1. ALMERIMAR. (EJIDO (EL)); extra: 5.09.24)(DATE)×5, 1, 3ºA, 04711 ALMERIMAR, EL EJIDO, ALMERIA. Por(ADDRESS) |
| es-borme-03-1 | 2112 | 27 | 19 | 7 | 1 | 0 | 7 | 87% | 99 | missed: JAMON EXCLUSIVE S.L.; extra: 5.09.24)(DATE)×5, JAMON EXCLUSIVE S.L. Constitución. Comienzo(COMPANY), 06200 (ALMENDRALEJO). Capital(ADDRESS) |
| es-borme-03-2 | 3244 | 28 | 16 | 9 | 3 | 0 | 11 | 80% | 144 | missed: GONFERJA HOLDING S.L., AGRICOLA LOVAINA S.L., CTRA DE ENTRERRIOS S/N, FABRICA DE TRANSA, S/N-FAB (VILLANUEVA DE LA SERENA); extra: 5.09.24)(DATE)×4, GONFERJA HOLDING S.L. Nombramientos. Adm. Unico(COMPANY)×2, AGRICOLA LOVAINA S.L. Constitución. Comienzo(COMPANY), 3.09.24.(DATE), DE TRANSA(COMPANY), , S/N-FAB (VILLANUEVA DE LA SERENA). Capital(ADDRESS), CNAE 9609(ID) |
| es-borme-04-1 | 1713 | 23 | 16 | 4 | 2 | 1 | 10 | 77% | 88 | missed: Z21406076C, C/ FAISAN, 10-LOCAL 2, NUESTRA SEÑORA DE JESUS 078 (SANTA EULALIA DEL RIO); wrong type: EIVISSA; extra: R.M. EIVISSA(PERSON)×4, 5.09.24)(DATE)×4, . EIVISSA(PERSON), 07849 (SANTA EULALIA DEL RIO). Datos(ADDRESS) |
| es-borme-04-2 | 1310 | 18 | 15 | 3 | 0 | 0 | 10 | 83% | 69 | extra: R.M. EIVISSA(ADDRESS)×5, 5.09.24)(DATE)×5 |
| es-borme-04-3 | 2295 | 34 | 27 | 3 | 4 | 0 | 12 | 80% | 112 | missed: EIVISSA, MAHON, Ciutadella, C/ SANT BARTOMEU, 1 07760 (CIUTADELLA DE MENORCA); extra: R.M. MAHON(PERSON)×4, R.M. EIVISSA(PERSON)×2, 5.09.24)(DATE)×2, 2.09.24)(DATE)×2, el Notario de Ciutadella(ADDRESS), 07760 (CIUTADELLA DE MENORCA). Capital(ADDRESS) |
| es-borme-05-1 | 1833 | 29 | 20 | 9 | 0 | 0 | 3 | 95% | 102 | extra: 88506 DONDE SE LEE COMO PRIMER APELLIDO DEL ADMINISTRADOR UNICO(ADDRESS), DE LA APODERADA(PERSON), DEL APODERADO(PERSON) |
| es-borme-05-2 | 2133 | 29 | 19 | 9 | 1 | 0 | 8 | 87% | 101 | missed: 3.000,00; extra: NOMBRE(PERSON)×2, 5.09.24)(DATE)×2, ANDREU COMA, SIENSO SU NOMBRE COMPLETO(PERSON), ANDREU COMA, SIENDO SU NOMBRE COMPLETO(PERSON), (11.07.24)(DATE), 4.09.24.(DATE) |
| es-borme-05-3 | 3058 | 33 | 17 | 13 | 3 | 0 | 12 | 82% | 148 | missed: JBCB TRANSPORTS S.L., OASIS DEL SOÑADOR S.L., INFAM WELLINGTON S.L.; extra: 5.09.24)(DATE)×6, 4.09.24.(DATE)×2, JBCB TRANSPORTS S.L. Constitución. Comienzo(COMPANY), OASIS DEL SOÑADOR S.L. Constitución. Comienzo(COMPANY), 5.09.24.(DATE), INFAM WELLINGTON S.L. Constitución. Comienzo(COMPANY) |
| en-gazette-01 | 864 | 14 | 13 | 0 | 1 | 0 | 4 | 88% | 45 | missed: Heskin Hall Farm, Wood Lane, Heskin, Preston, PR7 5PA; extra: Heskin Hall Farm(COMPANY)×2, Wood Lane(COMPANY)×2 |
| en-gazette-02 | 795 | 14 | 11 | 2 | 0 | 1 | 2 | 89% | 35 | wrong type: Walter Dawson & Son; extra: Canal Road(COMPANY), Dalton House(COMPANY) |
| en-gazette-03 | 1111 | 19 | 16 | 3 | 0 | 0 | 1 | 98% | 51 | extra: Hermes House(COMPANY) |
| en-gazette-04 | 1315 | 17 | 14 | 1 | 2 | 0 | 6 | 84% | 58 | missed: The Mill House Court Farm, Church Lane, Norton, Worcester, WR5 2PS, Heskin Hall Farm, Wood Lane, Heskin, Preston, PR7 5PA; extra: Wood Lane(COMPANY)×2, The Mill House Court Farm(COMPANY), Norton(COMPANY), Worcester(COMPANY), Heskin(COMPANY) |
| en-gazette-05 | 939 | 18 | 15 | 2 | 1 | 0 | 3 | 92% | 52 | missed: Birmingham; extra: Azzurri House(COMPANY)×2, Birmingham Insolvency(ADDRESS) |
| en-gazette-06 | 977 | 14 | 10 | 2 | 2 | 0 | 3 | 85% | 48 | missed: Manchester, The Union Building 51-59 Rose Lane, Norwich, NR1 1BY; extra: Manchester, Insolvency(ADDRESS), , Northampton, Northamptonshire, NN1 5JF (Formerly) The Union Building 51-59 Rose Lane, Norwich, (ADDRESS), United Kingdom.(COMPANY) |
| en-gazette-07 | 2521 | 11 | 10 | 1 | 0 | 0 | 2 | 94% | 104 | extra: Rules(COMPANY), 2 Lakeside, Calder Island Way, Wakefield, WF2 7AW on the(ADDRESS) |
| en-gazette-08 | 2318 | 11 | 9 | 2 | 0 | 0 | 3 | 90% | 92 | extra: Turpin Barker Armstrong(PERSON)×2, N/A(ADDRESS) |
| en-enron-01 | 863 | 16 | 13 | 1 | 2 | 0 | 3 | 86% | 35 | missed: Ina, Mog; extra: HOU(PERSON)×2, ENRON(PERSON) |
| en-enron-02 | 2306 | 52 | 50 | 1 | 1 | 0 | 6 | 94% | 133 | missed: Suite 165; extra: Desert Southwest(ADDRESS)×2, CAISO Last(COMPANY), CAISO(PERSON), the Desert Southwest(ADDRESS), Enron(PERSON) |
| en-enron-03 | 1341 | 15 | 14 | 0 | 1 | 0 | 0 | 97% | 66 | missed: EnronOnline |
| en-enron-04 | 1423 | 31 | 28 | 2 | 1 | 0 | 5 | 92% | 69 | missed: Kath; extra: WTC Parking(COMPANY)×2, Portland Employees-(ADDRESS), Enron Portland(COMPANY), on Portland(ADDRESS) |
| en-enron-05 | 946 | 19 | 15 | 2 | 1 | 1 | 0 | 92% | 55 | missed: RICE; wrong type: Rice |
| en-enron-06 | 1170 | 19 | 18 | 0 | 1 | 0 | 3 | 92% | 61 | missed: EPMI; extra: will(PERSON), EPMI-West-Bank(COMPANY), Enpower(COMPANY) |
| en-enron-07 | 2195 | 60 | 55 | 5 | 0 | 0 | 4 | 98% | 108 | extra: SQL_MAIL(PERSON)×2, Gas Settlements(COMPANY), Smith, Regan M.(PERSON) |
| en-enron-08 | 1589 | 14 | 12 | 1 | 0 | 1 | 2 | 87% | 69 | wrong type: Hertzberg; extra: DWR(COMPANY), COB(COMPANY) |
