# NER benchmark (desktop, Python onnxruntime)

- Model: xlm-roberta-base-ner-hrl
- Platform: windows "Windows 11 Famille" 10.0 (Build 26200), CPU, onnxruntime via bench_server.py
- Cases: 45, expected entities: 890
- Overall: recall 81%, precision 91%, F1 86% → reliability **B**; 105 ms per 1000 chars → speed **A**

Grades: reliability by F1 (A ≥ 90%, B ≥ 75%, C ≥ 50%, D below); speed by ms per 1000 characters on this platform (A < 300, B < 1000, C < 3000, D above).

## By language

| Language | Cases | Expected | Found | False pos. | Recall | Precision | F1 | Reliability | ms/1000 chars | Speed |
|---|---|---|---|---|---|---|---|---|---|---|
| fr | 15 | 165 | 122 | 39 | 74% | 81% | 78% | B | 102 | A |
| es | 14 | 381 | 345 | 45 | 91% | 92% | 91% | A | 104 | A |
| en | 16 | 344 | 258 | 45 | 75% | 93% | 83% | B | 107 | A |

## By category

| Category | Cases | Expected | Found | False pos. | Recall | Precision | F1 | Reliability | ms/1000 chars | Speed |
|---|---|---|---|---|---|---|---|---|---|---|
| registry | 29 | 546 | 467 | 84 | 86% | 89% | 87% | B | 103 | A |
| notice | 8 | 118 | 85 | 11 | 72% | 96% | 82% | B | 107 | A |
| email | 8 | 226 | 173 | 34 | 77% | 91% | 83% | B | 107 | A |

## Per case

| Case | Chars | Expected | Hit | Partial | Missed | Wrong type | False pos. | F1 | ms | Notes |
|---|---|---|---|---|---|---|---|---|---|---|
| fr-bodacc-creation-01 | 630 | 8 | 4 | 2 | 1 | 1 | 1 | 76% | 93 | missed: Arras; wrong type: BENJAMIN ROUSSEAU; extra: Greffe du Tribunal de Commerce d'Arras(COMPANY) |
| fr-bodacc-creation-02 | 588 | 8 | 4 | 1 | 3 | 0 | 2 | 71% | 66 | missed: Boulogne-sur-Mer, 109 790 832, BOSQUET Cassandra, Stéphanie, Christiane; extra: Greffe du Tribunal de Commerce de Boulogne-sur-Mer(COMPANY), RCS Boulogne-sur-Mer 109 790 832(ID) |
| fr-bodacc-creation-03 | 559 | 8 | 5 | 1 | 2 | 0 | 2 | 76% | 59 | missed: Boulogne-sur-Mer, 109 954 446; extra: Greffe du Tribunal de Commerce de Boulogne-sur-Mer(COMPANY), RCS Boulogne-sur-Mer 109 954 446(ID) |
| fr-bodacc-creation-04 | 825 | 9 | 4 | 2 | 3 | 0 | 2 | 75% | 69 | missed: Boulogne-sur-Mer, 130 037 054, LB INVEST; extra: Greffe du Tribunal de Commerce de Boulogne-sur-Mer(COMPANY), RCS Boulogne-sur-Mer 130 037 054(ID) |
| fr-bodacc-vente-01 | 1558 | 20 | 8 | 5 | 7 | 0 | 8 | 69% | 210 | missed: 066 351 420, REST'OR, Route Nationale 1., Zone industrielle Kaweni, BP 633, 97600 Mamoudzou, 024 083 321, EAI 340, 2026 E n°1606, Zone Industrielle Kaweni BP 633 Route nationale 1 - 97600 MAMOUDZOU; extra: SIE MAMOUDZOU(COMPANY)×2, 2026 E(ADDRESS)×2, Greffe du Tribunal Mixte de Commerce de Mamoudzou(COMPANY), RCS Mamoudzou 066 351 420(ID), RCS Mamoudzou 024 083 321(ID), Zone(COMPANY) |
| fr-bodacc-vente-02 | 1205 | 16 | 6 | 7 | 3 | 0 | 2 | 86% | 122 | missed: Nice, JERVIS BAY, AIR DU TEMPS; extra: Greffe du Tribunal de Commerce de Nice(COMPANY), JERVIS(ADDRESS) |
| fr-bodacc-vente-03 | 1465 | 18 | 7 | 4 | 7 | 0 | 7 | 65% | 123 | missed: Marseille, 107 137 887, 809 297 807, FF BONNEVEINE MENAGER, MARSEILLE, 1314P61 2026 A 04288, Adrien JOLY; extra: Greffe du Tribunal des Activités Economiques de Marseille(COMPANY), RCS Marseille 107 137 887(ID), RCS Marseille 809 297 807(ID), BONNEVEINE MENAGER(PERSON), SDE MARSEILLE(COMPANY), 04288 Adresse(ADDRESS), Étude Maître Adrien JOLY(COMPANY) |
| fr-bodacc-vente-04 | 1147 | 16 | 10 | 3 | 3 | 0 | 4 | 82% | 126 | missed: 108 184 912, Place De l'Eglise, 38330 Saint-Ismier, 452 805 666; extra: Greffe du Tribunal de Commerce de Grenoble(COMPANY), RCS Grenoble 108 184 912(ID), RCS Grenoble 452 805 666(ID), Dauphiné(ADDRESS) |
| fr-bodacc-collective-01 | 1040 | 11 | 8 | 2 | 1 | 0 | 1 | 91% | 124 | missed: Reims; extra: Greffe du Tribunal de Commerce de Reims(COMPANY) |
| fr-bodacc-collective-02 | 864 | 10 | 6 | 2 | 2 | 0 | 2 | 82% | 69 | missed: Lons-le-Saunier, 893 120 105; extra: Greffe du Tribunal de Commerce de Lons-le-Saunier(COMPANY), RCS Lons-le-Saunier 893 120 105(ID) |
| fr-bodacc-collective-03 | 867 | 10 | 5 | 3 | 2 | 0 | 2 | 81% | 73 | missed: 919 580 597, HK-RS; extra: Greffe du Tribunal de Commerce de Grenoble(COMPANY), RCS Grenoble 919 580 597(ID) |
| fr-bodacc-collective-04 | 915 | 11 | 5 | 1 | 5 | 0 | 2 | 65% | 84 | missed: le Puy en Velay, 852 650 407, Net'Pro 43, 81 ZA de Chatimbarbe, 43200 Yssingeaux, 10 rue de la Ronzade 43000 Le Puy-en-Velay; extra: Greffe du Tribunal de Commerce du Puy-en-Velay(COMPANY), RCS le Puy en Velay 852 650 407(ID) |
| fr-bodacc-modification-01 | 561 | 6 | 3 | 2 | 1 | 0 | 1 | 85% | 53 | missed: Rennes; extra: Greffe du Tribunal de Commerce de Rennes(COMPANY) |
| fr-bodacc-modification-02 | 448 | 8 | 4 | 3 | 1 | 0 | 2 | 84% | 33 | missed: Tours; extra: BODACC(COMPANY), Greffe du Tribunal de Commerce de Tours(COMPANY) |
| fr-bodacc-modification-03 | 483 | 6 | 3 | 2 | 1 | 0 | 1 | 85% | 36 | missed: Nantes; extra: Greffe du Tribunal de Commerce de Nantes(COMPANY) |
| es-borme-01-1 | 2009 | 27 | 26 | 1 | 0 | 0 | 1 | 99% | 197 | extra: BOLETÍN OFICIAL DEL REGISTRO MERCANTIL(COMPANY) |
| es-borme-01-2 | 2078 | 28 | 26 | 2 | 0 | 0 | 1 | 99% | 202 | extra: MERCANTIL(COMPANY) |
| es-borme-01-3 | 1399 | 22 | 21 | 1 | 0 | 0 | 1 | 98% | 144 | extra: BOLETÍN OFICIAL DEL REGISTRO MERCANTIL(COMPANY) |
| es-borme-02-1 | 2204 | 30 | 23 | 0 | 7 | 0 | 1 | 86% | 219 | missed: TRESCIENTOS CINCUENTA Y SIETE MIL CIENTO DIEZ EUROS, 357.110,00E, UN EURO, 1,00E, TREINTA Y DOS MIL EUROS, 32.000 E, 1 E; extra: BOLETÍN OFICIAL DEL REGISTRO MERCANTIL(COMPANY) |
| es-borme-02-2 | 3285 | 29 | 24 | 1 | 4 | 0 | 2 | 90% | 278 | missed: TREINTA Y TRES MIL EUROS, 33. 000, 00E, DIEZ EUROS, 10E; extra: BOLETÍN OFICIAL DEL REGISTRO MERCANTIL(COMPANY), ALMERIA(ADDRESS) |
| es-borme-02-3 | 1945 | 24 | 20 | 2 | 2 | 0 | 2 | 93% | 178 | missed: UN MILLON QUINIENTOS CUARENTA Y SEIS MIL NOVECIENTOS CUARENTA Y SIETE EUROS, 1.546.947.- E; extra: BOLETÍN OFICIAL DEL REGISTRO MERCANTIL(COMPANY), Administración(COMPANY) |
| es-borme-03-1 | 2112 | 27 | 26 | 1 | 0 | 0 | 3 | 96% | 202 | extra: BOLETÍN OFICIAL DEL REGISTRO MERCANTIL(COMPANY), Sociedad(COMPANY), CNAE(COMPANY) |
| es-borme-03-2 | 3244 | 28 | 24 | 0 | 4 | 0 | 4 | 88% | 333 | missed: CTRA DE ENTRERRIOS, S/N-FABRICA DE TRANSA 06700 (VILLANUEVA DE LA SERENA), CTRA DE ENTRERRIOS S/N, FABRICA DE TRANSA, S/N-FAB (VILLANUEVA DE LA SERENA), ANA DE LLANO ARIAS, POLIG 9-PARCELA 54 (SIRUELA); extra: BOLETÍN OFICIAL DEL REGISTRO MERCANTIL(COMPANY), ANA DE(COMPANY), LLANO ARIAS(ADDRESS), CNAE 9609(ID) |
| es-borme-04-1 | 1713 | 23 | 21 | 1 | 1 | 0 | 11 | 83% | 216 | missed: Z21406076C; extra: EIVISSA(COMPANY)×3, .M.(ADDRESS)×2, R.M.(ADDRESS)×2, DEL REGISTRO MERCANTIL(COMPANY), R.M. EIVISSA(COMPANY), R.M. EIVISSA(ADDRESS), SALA TORRES JOSE(ADDRESS) |
| es-borme-04-2 | 1310 | 18 | 16 | 0 | 2 | 0 | 7 | 85% | 148 | missed: EIVISSA, FINANCIERE JL SAS; extra: R.M. EIVISSA(COMPANY)×6, BOLETÍN OFICIAL DEL REGISTRO MERCANTIL(COMPANY) |
| es-borme-04-3 | 2295 | 34 | 28 | 3 | 3 | 0 | 7 | 89% | 272 | missed: EIVISSA, MOREL REGINE-JEANNE-CLAUDE, MAHON; extra: R.M. EIVISSA(COMPANY)×2, R.M. MAHON(PERSON)×2, BOLETÍN OFICIAL DEL REGISTRO MERCANTIL(COMPANY), R.M. MAHON(COMPANY), M. MAHON(PERSON) |
| es-borme-05-1 | 1833 | 29 | 27 | 2 | 0 | 0 | 1 | 98% | 266 | extra: 88506 DONDE SE LEE COMO PRIMER APELLIDO DEL ADMINISTRADOR UNICO(ADDRESS) |
| es-borme-05-2 | 2133 | 29 | 26 | 0 | 3 | 0 | 1 | 93% | 205 | missed: CL FLORIDABLANCA NUM.29 P.4 PTA.2 (BADALONA), 3.000,00, CL TARRAGONA NUM.4 P.3 PTA.4 (MONTGAT); extra: BOLETÍN OFICIAL DEL REGISTRO MERCANTIL(COMPANY) |
| es-borme-05-3 | 3058 | 33 | 22 | 1 | 10 | 0 | 3 | 80% | 309 | missed: CL LLIBERTAT NUM.105 (PARETS DEL VALLES), CASTRO BALLESTEROS JUAN BAUTISTA, CL GRAN VIA CARLES III NUM.98 P.10 (BARCELONA), CL SANTIGA NUM.116 (SABADELL), CL PADRO NUM.87 P.0 (RIPOLLET), CL PROVENZA NUM.541 (BARCELONA), PINCHAS ROZEN, CL LLEDONERS NUM.17 (CABRILS), QUINTANS OSeS ALEJANDRO, ALEJANDRO QUINTANS OSeS; extra: BOLETÍN OFICIAL DEL REGISTRO MERCANTIL(COMPANY), BALLESTEROS JUAN BAUTISTA(ADDRESS), VIA CARLES III NUM(COMPANY) |
| en-gazette-01 | 864 | 14 | 9 | 0 | 4 | 1 | 3 | 74% | 90 | missed: 11 Second Floor, Savile Row, London, W1S 3PG, 31850, Heskin Hall Farm, Wood Lane, Heskin, Preston, PR7 5PA, 32230; wrong type: Marshall Peters; extra: Marshall(PERSON), Peters(ADDRESS), Marshall Peters(ADDRESS) |
| en-gazette-02 | 795 | 14 | 10 | 0 | 4 | 0 | 0 | 83% | 74 | missed: 1 Valley Court, Canal Road, Bradford, West Yorkshire, BD1 4SP, New North Road, Heckmondwike, West Yorkshire, WF16 9DH, 29010, Dalton House, 1 Hawksworth Street, Ilkley, West Yorkshire, LS29 9DU |
| en-gazette-03 | 1111 | 19 | 14 | 0 | 5 | 0 | 0 | 85% | 107 | missed: Suite B, Blackdown House, Blackbrook Park Avenue, Taunton, Somerset, TA1 2PX, 21 Silver Street, Ottery, St Mary, EX11 1DB, 11110, Hermes House, Fire Fly Avenue, Swindon, SN2 2GA, 18032 |
| en-gazette-04 | 1315 | 17 | 10 | 1 | 6 | 0 | 3 | 76% | 180 | missed: The Mill House Court Farm, Church Lane, Norton, Worcester, WR5 2PS, Unit 14C Hartlebury Trading Estate, Hartlebury, Kidderminste, DY104JB, Heskin Hall Farm, Heskin, Preston, PR7 5PA, 31850, Heskin Hall Farm, Wood Lane, Heskin, Preston, PR7 5PA, 32230; extra: Marshall Peters(ADDRESS)×2, Hartlebury Trading Estate(COMPANY) |
| en-gazette-05 | 939 | 18 | 12 | 0 | 6 | 0 | 1 | 79% | 107 | missed: Birmingham, CR-2026-BHM-0004, 34 Dudley Road, Brierley Hill, DY5 1LH, 22930, Azzurri House, Walsall Business Park, Walsall Road, Walsall, West Midlands, WS9 0RB, 020730; extra: High Court of Justice, Business and Property Courts(COMPANY) |
| en-gazette-06 | 977 | 14 | 10 | 1 | 3 | 0 | 1 | 86% | 106 | missed: Suite 060, Unit 2, 94A Wycliffe Road, Northampton, Northamptonshire, NN1 5JF, The Union Building 51-59 Rose Lane, Norwich, NR1 1BY, 13890; extra: High Court of Justice
Business and Property Courts(COMPANY) |
| en-gazette-07 | 2521 | 11 | 9 | 0 | 2 | 0 | 2 | 87% | 278 | missed: 71 Church Road, Manchester, M22 4WD, 2 Lakeside, Calder Island Way, Wakefield, WF2 7AW; extra: Rules(COMPANY), Board of Directors(COMPANY) |
| en-gazette-08 | 2318 | 11 | 9 | 0 | 2 | 0 | 1 | 88% | 219 | missed: Caledon Community Centre, Caledon Road, London Colney, St Albans, Hertfordshire AL2 1PU, 15 Horizon Business Village, 1 Brooklands Road, Weybridge, Surrey, KT13 0TJ; extra: Turpin Barker Armstrong(PERSON) |
| en-enron-01 | 863 | 16 | 11 | 1 | 4 | 0 | 5 | 76% | 72 | missed: Ina, Mog, karen, Allen, Phillip; extra: ECT(COMPANY)×3, Mog.

Phillip(PERSON), ENRON(ADDRESS) |
| en-enron-02 | 2306 | 52 | 49 | 0 | 3 | 0 | 4 | 94% | 302 | missed: tom, June 5, Suite 165; extra: Desert Southwest(ADDRESS)×2, Desert(COMPANY), Southwest(ADDRESS) |
| en-enron-03 | 1341 | 15 | 14 | 0 | 1 | 0 | 1 | 94% | 118 | missed: Enron North America; extra: North America(ADDRESS) |
| en-enron-04 | 1423 | 31 | 9 | 12 | 9 | 1 | 7 | 76% | 123 | missed: Sheppard, Kathryn, Eriksson, Fredrik, Erwin, Kenton, Gang, Lisa, Kane, Paul, Mays, Wayne, O'Neil, Murray P, Thompson, Virginia, Tully, Mike; wrong type: Khymberly Booth; extra: Khymberly Booth(ADDRESS)×2, O'Neil(COMPANY), Murray P.(PERSON), Jeff G.(PERSON), Enron Portland(COMPANY), Sheppard(COMPANY) |
| en-enron-05 | 946 | 19 | 15 | 0 | 2 | 2 | 3 | 77% | 98 | missed: EnronOnline, RICE; wrong type: Rice, IVY GHOSE; extra: HOU(COMPANY), ECT(COMPANY), RICE MBA(PERSON) |
| en-enron-06 | 1170 | 19 | 16 | 1 | 2 | 0 | 2 | 92% | 115 | missed: Smith, Will, EPMI; extra: will(PERSON), Enpower(COMPANY) |
| en-enron-07 | 2195 | 60 | 15 | 17 | 28 | 0 | 9 | 68% | 261 | missed: Baxter, Bryce, Bussell, Kathryn, Dawes, Cheryl, Farmer, Daren J, Greif, Donna, Hall, Bob M, Harwell, Melanie, Heal, Kevin, Jacobs, Charles, Jaquet, Tammy, Machleit, Shirley, Olinger, Kimberly S … +16 more; extra: Regan M.(PERSON)×2, SQL_MAIL(PERSON)×2, terry(PERSON), Daren J.(PERSON), Kimberly S.(PERSON), George F.(PERSON), Rita
Cc(PERSON) |
| en-enron-08 | 1589 | 14 | 13 | 0 | 0 | 1 | 3 | 85% | 173 | wrong type: Hertzberg; extra: Assembly(COMPANY), Sentate(COMPANY), COB(COMPANY) |
