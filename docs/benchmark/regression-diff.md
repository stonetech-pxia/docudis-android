# Run diff: C:/Users/Xia/projects/docudis/docs/benchmark/desktop-regression-baseline.json → C:/Users/Xia/projects/docudis/docs/benchmark/desktop-regression-current.json

48 documents, 1076 expected entities.

| | hit | wrong type | partial | missed | over-redaction |
|---|---|---|---|---|---|
| before | 794 | 9 | 105 | 168 | 169 |
| after | 905 | 9 | 80 | 82 | 131 |

**42 entities got worse, 164 got better; 75 new over-redactions, 113 gone.**

## Worse (42)

| document | value | type | before | after |
|---|---|---|---|---|
| en-bank-01 | `Bristol` | ADDRESS | hit | missed |
| en-bank-01 | `Leicester` | ADDRESS | hit | missed |
| en-cv-01 | `Kestrel Ridge` | COMPANY | hit | partial |
| en-cv-01 | `Kestrel Ridge Biologics` | COMPANY | hit | missed |
| en-insurance-01 | `London` | ADDRESS | hit | missed |
| en-jobad-01 | `Calderwych Bay` | ADDRESS | hit | missed |
| en-lease-01 | `Manchester` | ADDRESS | hit | missed |
| en-letter-01 | `Rotherham` | ADDRESS | hit | missed |
| en-policy-01 | `Beaverton` | ADDRESS | hit | partial |
| es-insurance-01 | `M. Trujillo Abad` | PERSON | hit | missed |
| es-lease-01 | `Avinguda del` | ADDRESS | partial | missed |
| es-lease-01 | `València` | ADDRESS | hit | partial |
| es-letter-01 | `Sergio Montull Aldeanueva` | PERSON | hit | missed |
| es-notice-01 | `Puente Almanzor` | ADDRESS | hit | partial |
| es-notice-01 | `plaza Mayor 1, planta baja` | ADDRESS | partial | missed |
| es-support-01 | `Ribarroja` | ADDRESS | hit | partial |
| fr-bank-01 | `14 rue des Cinq-Diamants` | ADDRESS | hit | partial |
| fr-chat-01 | `Bruxelles` | ADDRESS | hit | partial |
| fr-chat-01 | `Liège` | ADDRESS | hit | partial |
| fr-cv-01 | `France` | ADDRESS | hit | type |
| fr-cv-01 | `Italie` | ADDRESS | hit | missed |
| fr-cv-01 | `Vaulx-en-Velin` | ADDRESS | hit | partial |
| fr-insurance-01 | `7 impasse des Tisserands` | ADDRESS | hit | partial |
| fr-insurance-01 | `Toulouse` | ADDRESS | hit | partial |
| fr-insurance-01 | `lieu-dit Le Bourdieu` | ADDRESS | partial | missed |
| fr-jobad-01 | `Brétigny-la-Forêt` | ADDRESS | hit | partial |
| fr-lease-01 | `8 bis, allée des Frênes` | ADDRESS | hit | partial |
| fr-lease-01 | `Lyon` | ADDRESS | hit | partial |
| fr-letter-01 | `17 avenue du Général-Compans` | ADDRESS | hit | partial |
| fr-letter-01 | `Haute-Garonne` | ADDRESS | hit | partial |
| fr-letter-01 | `Toulouse` | ADDRESS | hit | partial |
| fr-medical-01 | `Lausanne` | ADDRESS | hit | partial |
| fr-medical-01 | `Rue Pichard 7` | ADDRESS | hit | partial |
| fr-notice-01 | `1 place de l'Ancien Presbytère` | ADDRESS | hit | partial |
| fr-notice-01 | `Hélène Vasseur` | PERSON | hit | partial |
| fr-notice-01 | `PONTMÉLIE` | ADDRESS | hit | partial |
| fr-notice-01 | `Pontmélie` | ADDRESS | hit | partial |
| fr-payslip-01 | `12 rue des Tanneurs — ZA du Ried` | ADDRESS | hit | partial |
| fr-payslip-01 | `6 impasse des Charmilles` | ADDRESS | hit | partial |
| fr-payslip-01 | `Alsace` | ADDRESS | partial | missed |
| fr-policy-01 | `Île-de-France` | ADDRESS | hit | missed |
| fr-support-01 | `22 rue Hector-Malot` | ADDRESS | hit | partial |

## New over-redaction (75)

| document | value | detected as | detector |
|---|---|---|---|
| en-catalogue-01 | `24817 Rev 2` | ADDRESS | regex:universal:postal_city |
| en-chat-01 | `08/29` | DATE | ner:xlm-roberta-base-ner-docudis |
| en-cv-01 | `04/2025` | DATE | ner:xlm-roberta-base-ner-docudis |
| en-cv-01 | `2027
Lean Six Sigma Green Belt, Kestrel Ridge` | ADDRESS | regex:gb:street |
| en-cv-01 | `5-point` | ID | regex:universal:labeled_id |
| en-cv-01 | `United States Army` | COMPANY | ner:xlm-roberta-base-ner-docudis |
| en-insurance-01 | `Wales No.` | ADDRESS | ner:xlm-roberta-base-ner-docudis |
| en-invoice-01 | `Bray, Co. Wicklow` | COMPANY | regex:us:company |
| en-jobad-01 | `Kingdom` | ADDRESS | ner:xlm-roberta-base-ner-docudis |
| en-jobad-01 | `United` | COMPANY | list:company |
| en-jobad-01 | `the Thornlow Road` | ADDRESS | ner:xlm-roberta-base-ner-docudis |
| en-lease-01 | `April` | DATE | ner:xlm-roberta-base-ner-docudis |
| en-lease-01 | `IBAN` | PERSON | ner:xlm-roberta-base-ner-docudis |
| en-lease-01 | `July` | DATE | ner:xlm-roberta-base-ner-docudis |
| en-lease-01 | `May` | DATE | ner:xlm-roberta-base-ner-docudis |
| en-manual-01 | `88-4401-S` | ID | regex:universal:labeled_id |
| en-manual-01 | `HX-440-S` | ID | regex:universal:labeled_id |
| en-manual-01 | `of 2025` | DATE | ner:xlm-roberta-base-ner-docudis |
| en-manual-01 | `the United Kingdom` | ADDRESS | ner:xlm-roberta-base-ner-docudis |
| en-notice-01 | `Netherfield House` | COMPANY | ner:xlm-roberta-base-ner-docudis |
| en-notice-01 | `of Hollowgate Lane` | ADDRESS | ner:xlm-roberta-base-ner-docudis |
| en-notice-01 | `on Carlow Street` | ADDRESS | ner:xlm-roberta-base-ner-docudis |
| en-notice-01 | `on Dunmoor Avenue` | ADDRESS | ner:xlm-roberta-base-ner-docudis |
| en-notice-01 | `the Ashcombe Green` | ADDRESS | ner:xlm-roberta-base-ner-docudis |
| en-policy-01 | `December 2027` | DATE | ner:xlm-roberta-base-ner-docudis |
| en-support-01 | `04/29` | DATE | ner:xlm-roberta-base-ner-docudis |
| en-support-01 | `O Riordain
Customer Resolutions Team
Ardmore Home & Kitchen Ltd` | COMPANY | regex:universal:company_wrapped |
| es-catalogue-01 | `Registro Mercantil de Madrid` | ADDRESS | ner:xlm-roberta-base-ner-docudis |
| es-chat-01 | `IMG-20260911-WA0003` | ID | regex:universal:labeled_id |
| es-cv-01 | `Cámara de Comercio de` | COMPANY | ner:xlm-roberta-base-ner-docudis |
| es-insurance-01 | `M. Trujillo Abad
Departamento de Tramitación de Siniestros
MAPFRE ESPAÑA, S.A.` | COMPANY | regex:universal:company_wrapped |
| es-jobad-01 | `Grupo 3` | COMPANY | regex:es:company_head |
| es-lease-01 | `9 de València` | ADDRESS | ner:xlm-roberta-base-ner-docudis |
| es-lease-01 | `DE AGOSTO DE 2026` | DATE | ner:xlm-roberta-base-ner-docudis |
| es-lease-01 | `Institut Valencià de l'Edificació` | COMPANY | ner:xlm-roberta-base-ner-docudis |
| es-letter-01 | `Sergio Montull Aldeanueva
Departamento de Facturación y Lecturas
Endesa Energía, S.A.U.` | COMPANY | regex:universal:company_wrapped |
| es-manual-01 | `41-2400-B` | ID | regex:universal:labeled_id |
| es-manual-01 | `Departamento de Postventa
Termavent Ibérica, S.L.U.` | COMPANY | regex:universal:company_wrapped |
| es-notice-01 | `AYUNTAMIENTO DE PUENTE` | ADDRESS | ner:xlm-roberta-base-ner-docudis |
| es-notice-01 | `Oficina de Atención Ciudadana, plaza Mayor 1` | ADDRESS | regex:es:street |
| es-notice-01 | `de Poniente` | ADDRESS | ner:xlm-roberta-base-ner-docudis |
| es-notice-01 | `de la avenida de los Olmares` | ADDRESS | ner:xlm-roberta-base-ner-docudis |
| es-notice-01 | `de los Olmares` | ADDRESS | ner:xlm-roberta-base-ner-docudis |
| es-notice-01 | `la avenida de los Olmares` | ADDRESS | ner:xlm-roberta-base-ner-docudis |
| es-notice-01 | `la calle Cantarranas` | ADDRESS | ner:xlm-roberta-base-ner-docudis |
| es-notice-01 | `la calle Herradores` | ADDRESS | ner:xlm-roberta-base-ner-docudis |
| es-notice-01 | `les Herradores` | ADDRESS | ner:xlm-roberta-base-ner-docudis |
| es-payslip-01 | `Artes Gráficas` | COMPANY | list:company |
| es-payslip-01 | `Grupo 4` | COMPANY | regex:es:company_head |
| es-support-01 | `LP-4471` | ID | regex:universal:labeled_id_no |
| es-terms-01 | `Registro Mercantil de Valencia` | ADDRESS | ner:xlm-roberta-base-ner-docudis |
| es-terms-01 | `de Valencia` | ADDRESS | ner:xlm-roberta-base-ner-docudis |
| fr-bank-01 | `Mastercard Gold` | COMPANY | ner:xlm-roberta-base-ner-docudis |
| fr-bank-01 | `Vincennes, le` | ADDRESS | ner:xlm-roberta-base-ner-docudis |
| fr-catalogue-01 | `SIRET` | ADDRESS | ner:xlm-roberta-base-ner-docudis |
| fr-insurance-01 | `SANTÉ ESSENTIEL 3` | COMPANY | ner:xlm-roberta-base-ner-docudis |
| fr-insurance-01 | `on Sud-Ouest` | ADDRESS | ner:xlm-roberta-base-ner-docudis |
| fr-jobad-01 | `de Brétigny-la-Forêt` | ADDRESS | ner:xlm-roberta-base-ner-docudis |
| fr-jobad-01 | `du Grand Ouest` | ADDRESS | ner:xlm-roberta-base-ner-docudis |
| fr-lease-01 | `1er` | DATE | ner:xlm-roberta-base-ner-docudis |
| fr-letter-01 | `Caisse d'allocations familiales de la Haute-Garonne` | COMPANY | ner:xlm-roberta-base-ner-docudis |
| fr-manual-01 | `TH-VLT-4200-B` | ID | regex:universal:labeled_id |
| fr-manual-01 | `VLT42-KJ-01873` | ID | regex:universal:labeled_id |
| fr-manual-01 | `VOLTARIS 4200` | ADDRESS | ner:xlm-roberta-base-ner-docudis |
| fr-medical-01 | `LAMal` | COMPANY | ner:xlm-roberta-base-ner-docudis |
| fr-notice-01 | `Hôpital nord` | ADDRESS | ner:xlm-roberta-base-ner-docudis |
| fr-notice-01 | `RUE DES TANNEURS ET` | ADDRESS | ner:xlm-roberta-base-ner-docudis |
| fr-notice-01 | `de la place du Marché couvert, du` | ADDRESS | ner:xlm-roberta-base-ner-docudis |
| fr-notice-01 | `le boulevard Sainte-Colombe` | ADDRESS | ner:xlm-roberta-base-ner-docudis |
| fr-notice-01 | `le de la rue Fresnaye` | ADDRESS | ner:xlm-roberta-base-ner-docudis |
| fr-notice-01 | `rue des Tanneurs, la` | ADDRESS | ner:xlm-roberta-base-ner-docudis |
| fr-policy-01 | `France` | COMPANY | list:company |
| fr-policy-01 | `SIRET` | ADDRESS | ner:xlm-roberta-base-ner-docudis |
| fr-support-01 | `M. Tran-Bouchard` | PERSON | ner:xlm-roberta-base-ner-docudis |
| fr-terms-01 | `SIRET` | ADDRESS | ner:xlm-roberta-base-ner-docudis |

## Better (164)

| document | value | type | before | after |
|---|---|---|---|---|
| en-bank-01 | `P. Ravindran-Blake` | PERSON | partial | hit |
| en-bank-01 | `PLS/OD/26/774301` | ID | missed | hit |
| en-bank-01 | `PO Box 4402` | ADDRESS | missed | hit |
| en-catalogue-01 | `Cork` | ADDRESS | missed | hit |
| en-catalogue-01 | `Fergus Naughton` | PERSON | missed | hit |
| en-catalogue-01 | `Unit 7B, Clonshaugh Industrial Estate, Dublin 17, D17 XH62` | ADDRESS | partial | hit |
| en-chat-01 | `14 Sycamore Lawn, Clonsilla, Dublin 15, D15 XK72` | ADDRESS | missed | hit |
| en-chat-01 | `aoife` | PERSON | missed | hit |
| en-chat-01 | `rathgar` | ADDRESS | missed | hit |
| en-chat-01 | `sinead` | PERSON | missed | hit |
| en-chat-01 | `tomek` | PERSON | missed | hit |
| en-cv-01 | `2184 Cedarbrook Trail, Apt 3C` | ADDRESS | partial | hit |
| en-cv-01 | `47 Rockwell Bend Road, Killeen, TX 76541` | ADDRESS | partial | hit |
| en-cv-01 | `900 Loop Crossing Drive, Georgetown, TX 78626` | ADDRESS | partial | hit |
| en-cv-01 | `Cedar Park, TX` | ADDRESS | partial | hit |
| en-cv-01 | `NAVEEN BALASUBRAMANIAN` | PERSON | missed | hit |
| en-cv-01 | `Round Rock, TX 78664` | ADDRESS | partial | hit |
| en-cv-01 | `Temple, TX` | ADDRESS | partial | hit |
| en-insurance-01 | `1 Angel Court, London EC2R 7HJ` | ADDRESS | missed | partial |
| en-insurance-01 | `15-19 Bloomsbury Way` | ADDRESS | partial | hit |
| en-insurance-01 | `27 Brambleside Court, Nether Parkfield` | ADDRESS | partial | hit |
| en-invoice-01 | `612884` | ID | missed | hit |
| en-invoice-01 | `AIBKIE2D` | ID | missed | hit |
| en-invoice-01 | `FERR-014` | ID | missed | hit |
| en-invoice-01 | `IE3847291GH` | ID | missed | hit |
| en-invoice-01 | `Kilcoole, Co. Wicklow` | ADDRESS | missed | type |
| en-invoice-01 | `Naas, Co. Kildare` | ADDRESS | missed | type |
| en-invoice-01 | `Q-2026-0913` | ID | partial | hit |
| en-jobad-01 | `Thornlow Road, Calderwych Bay CB14 3PN` | ADDRESS | missed | hit |
| en-lease-01 | `Adeyemi, Folasade O.` | PERSON | missed | hit |
| en-lease-01 | `H. Draycott` | PERSON | missed | hit |
| en-lease-01 | `Heaton Moor, Stockport SK4 3QN` | ADDRESS | missed | partial |
| en-lease-01 | `MT/TEN/4471-B` | ID | missed | hit |
| en-letter-01 | `41 Lindley Croft` | ADDRESS | missed | hit |
| en-letter-01 | `BG/MTR/2026/55120` | ID | missed | hit |
| en-letter-01 | `Birmingham B43 5TU` | ADDRESS | partial | hit |
| en-letter-01 | `K. Ademola` | PERSON | missed | hit |
| en-letter-01 | `PO Box 227` | ADDRESS | missed | hit |
| en-manual-01 | `Unit 12 Brantwood Trading Estate, Kelsington, KL9 4TR` | ADDRESS | partial | hit |
| en-medical-01 | `2180 Harnett Boulevard, Suite 410` | ADDRESS | partial | hit |
| en-medical-01 | `3117 Winnemac Avenue, Apt 2B` | ADDRESS | partial | hit |
| en-medical-01 | `BR4471908` | ID | missed | hit |
| en-medical-01 | `Columbus, OH 43215` | ADDRESS | missed | hit |
| en-medical-01 | `Lakeview Internal Medicine Associates` | COMPANY | partial | hit |
| en-medical-01 | `Okonkwo, Chidinma R.` | PERSON | partial | hit |
| en-notice-01 | `0492-HG-26-117` | ID | missed | hit |
| en-notice-01 | `12 October` | DATE | missed | hit |
| en-notice-01 | `Netherfield House, 3 Arkwright Way, Pennerbridge PB2 7QD` | ADDRESS | missed | partial |
| en-notice-01 | `PW/STW/2026/04872` | ID | missed | hit |
| en-notice-01 | `Pennerbridge Water` | COMPANY | type | hit |
| en-notice-01 | `TRUNK-RENEW-38` | ID | missed | hit |
| en-payslip-01 | `083/HR4419` | ID | missed | hit |
| en-payslip-01 | `D. Fairhurst-Naylor` | PERSON | missed | hit |
| en-payslip-01 | `Unit 7, Parkfield Industrial Estate` | ADDRESS | partial | hit |
| en-payslip-01 | `Wolverhampton WV10 9TQ` | ADDRESS | partial | hit |
| en-policy-01 | `2400 SW Halverson Loop, Beaverton, OR 97006` | ADDRESS | partial | hit |
| en-policy-01 | `NORTHLARK INSTRUMENTS, INC.` | COMPANY | partial | hit |
| en-support-01 | `DKT-55219-B` | ID | partial | hit |
| en-support-01 | `Knocknacarra, Galway H91 R2VC` | ADDRESS | missed | hit |
| en-support-01 | `Naas Road, Dublin 22, D22 XK79` | ADDRESS | missed | hit |
| en-support-01 | `Unit 12, Cloverhill Retail Park` | ADDRESS | partial | hit |
| en-terms-01 | `Unit 14, Ravensworth Business Park, Aldridge Road, Sheffield S9 2QX` | ADDRESS | partial | hit |
| es-bank-01 | `20 de octubre` | DATE | missed | hit |
| es-bank-01 | `C/ Almendro de la Vega, 27, 3.º B` | ADDRESS | partial | hit |
| es-bank-01 | `COM/2451/0098-2026` | ID | partial | hit |
| es-bank-01 | `Ferretería Baldosa` | COMPANY | missed | hit |
| es-catalogue-01 | `Carretera de Burgos, km 12,400 — Parque Empresarial Valdehierro, nave 21` | ADDRESS | missed | partial |
| es-catalogue-01 | `M-431.778` | ID | missed | partial |
| es-catalogue-01 | `PR-2026/04187` | ID | missed | hit |
| es-chat-01 | `1 de octubre` | DATE | missed | hit |
| es-chat-01 | `Carrer del Molí Nou, 42, esc. B, 4t 2a` | ADDRESS | missed | partial |
| es-chat-01 | `marta` | PERSON | missed | hit |
| es-chat-01 | `yusuf` | PERSON | missed | hit |
| es-cv-01 | `Amadou Sagnane` | PERSON | partial | hit |
| es-cv-01 | `Aula Bética` | COMPANY | missed | hit |
| es-cv-01 | `C/ Cordeleros del Arenal, 118, 2.º izq.` | ADDRESS | partial | hit |
| es-insurance-01 | `18 de septiembre` | DATE | missed | hit |
| es-insurance-01 | `2 de septiembre` | DATE | missed | hit |
| es-insurance-01 | `26 de agosto` | DATE | missed | hit |
| es-insurance-01 | `Paseo de la Alameda Vieja, 9, planta 3` | ADDRESS | partial | hit |
| es-insurance-01 | `Rubén Achterberg Lillo` | PERSON | partial | hit |
| es-insurance-01 | `SIN-2026-0473812/HM` | ID | partial | hit |
| es-insurance-01 | `Zaragoza` | ADDRESS | partial | hit |
| es-invoice-01 | `Barrio Ugarte, 7, lonja` | ADDRESS | partial | hit |
| es-invoice-01 | `C/ Zumalabe Kalea, 12, 5.º C` | ADDRESS | partial | hit |
| es-jobad-01 | `SEL-2025/117` | ID | partial | hit |
| es-lease-01 | `ARR-2024/0318` | ID | partial | hit |
| es-lease-01 | `Carrer del Palleter, 47, 3º` | ADDRESS | partial | hit |
| es-lease-01 | `Port, 112, escalera B, 5ª puerta C, 46023 València` | ADDRESS | missed | hit |
| es-letter-01 | `1 de marzo` | DATE | missed | hit |
| es-letter-01 | `Apartado de Correos 1128` | ADDRESS | missed | hit |
| es-letter-01 | `Calle Doctor Fleming, 8, bloque 2, bajo C, 50006 Zaragoza` | ADDRESS | missed | partial |
| es-letter-01 | `ES0021000010441563VL` | ID | partial | hit |
| es-letter-01 | `SAC/2026/0771-4432` | ID | partial | hit |
| es-medical-01 | `2026/CEX/55219` | ID | missed | hit |
| es-medical-01 | `28/4419788` | ID | missed | hit |
| es-medical-01 | `Carretera de Toledo, km 12,500` | ADDRESS | missed | hit |
| es-notice-01 | `LOV-2025/318` | ID | partial | hit |
| es-notice-01 | `PUENTE ALMANZOR` | ADDRESS | missed | partial |
| es-payslip-01 | `04127` | ID | missed | hit |
| es-payslip-01 | `B-87421903` | ID | missed | hit |
| es-payslip-01 | `NKEMDIRIM OKAFOR, Chinaza` | PERSON | partial | hit |
| es-payslip-01 | `Nerea Oyarzábal Ferrer` | PERSON | type | hit |
| es-payslip-01 | `Polígono Industrial Les Comes, nave 14` | ADDRESS | partial | hit |
| es-policy-01 | `CI-2026/031` | ID | missed | hit |
| es-support-01 | `208877` | ID | missed | hit |
| es-support-01 | `2ª, 46701 Gandia (Valencia)` | ADDRESS | missed | partial |
| es-support-01 | `Camí dels Horts, 6, 46394 Ribarroja del Túria` | ADDRESS | partial | hit |
| es-support-01 | `Carrer de Sant Bartomeu, 23, 2º` | ADDRESS | partial | hit |
| es-terms-01 | `Polígono Industrial Las Cañadas, calle Torrente Ballester 14, nave 7` | ADDRESS | missed | partial |
| es-terms-01 | `V-152.334` | ID | missed | partial |
| fr-bank-01 | `10 octobre` | DATE | missed | hit |
| fr-bank-01 | `FR76 6443 5625 6530 9499 6263 791` | IBAN | partial | hit |
| fr-bank-01 | `RE/2026-09/4412` | ID | missed | hit |
| fr-bank-01 | `Résidence Le Clos Sainte-Anne` | ADDRESS | partial | hit |
| fr-bank-01 | `cabinet Lorquin & associés` | COMPANY | missed | partial |
| fr-catalogue-01 | `COMPTOIR METALLURGIQUE DE L'AUZANCE` | COMPANY | partial | hit |
| fr-catalogue-01 | `DV-2026-04871` | ID | partial | hit |
| fr-chat-01 | `karim` | PERSON | missed | hit |
| fr-chat-01 | `lena` | PERSON | missed | hit |
| fr-cv-01 | `3e étage, 69003 Lyon` | ADDRESS | partial | hit |
| fr-cv-01 | `Lyon` | ADDRESS | missed | hit |
| fr-cv-01 | `TNV Maintenance` | COMPANY | missed | hit |
| fr-cv-01 | `Université Claude Bernard Lyon 1` | COMPANY | partial | hit |
| fr-insurance-01 | `13 août` | DATE | missed | hit |
| fr-insurance-01 | `2026/AC/55031` | ID | missed | hit |
| fr-insurance-01 | `24 août` | DATE | missed | hit |
| fr-insurance-01 | `31093 Toulouse Cedex 9` | ADDRESS | partial | hit |
| fr-insurance-01 | `Ferreira` | PERSON | missed | hit |
| fr-insurance-01 | `GSO-55031/ML` | ID | partial | hit |
| fr-insurance-01 | `H4-2211879` | ID | missed | hit |
| fr-insurance-01 | `TSA 70124` | ADDRESS | missed | hit |
| fr-invoice-01 | `4471280` | ID | missed | hit |
| fr-invoice-01 | `9 chemin du Moulin Rouge, zone artisanale` | ADDRESS | partial | hit |
| fr-invoice-01 | `SMABTP` | COMPANY | missed | hit |
| fr-invoice-01 | `des Aubiers, 33300 Bordeaux` | ADDRESS | partial | hit |
| fr-lease-01 | `Bâtiment C, 2e étage` | ADDRESS | missed | hit |
| fr-lease-01 | `Q-2026-0417` | ID | partial | hit |
| fr-letter-01 | `31046 TOULOUSE CEDEX 9` | ADDRESS | partial | hit |
| fr-letter-01 | `K. Aubry-Pineau` | PERSON | partial | hit |
| fr-letter-01 | `RSA/2026/ATT-51840` | ID | missed | hit |
| fr-manual-01 | `ZA des Quatre Sillons, 12 rue de la Fonderie, 41260 Sarnay-sur-Cisse` | ADDRESS | missed | partial |
| fr-medical-01 | `4 septembre` | DATE | missed | hit |
| fr-medical-01 | `4482-19` | ID | missed | hit |
| fr-medical-01 | `CHUV` | COMPANY | missed | hit |
| fr-medical-01 | `Cabinet médical de la Riponne` | COMPANY | missed | hit |
| fr-notice-01 | `2026-ARR-318` | ID | missed | hit |
| fr-notice-01 | `25 octobre` | DATE | missed | hit |
| fr-notice-01 | `5 octobre` | DATE | missed | hit |
| fr-notice-01 | `AP-2026-47` | ID | missed | hit |
| fr-payslip-01 | `00418` | ID | missed | hit |
| fr-payslip-01 | `HM-6120884` | ID | missed | hit |
| fr-payslip-01 | `Malakoff Humanis` | COMPANY | type | hit |
| fr-payslip-01 | `SIST Alsace Nord` | COMPANY | missed | hit |
| fr-policy-01 | `NS-2026-017` | ID | missed | hit |
| fr-policy-01 | `SOCIETE NOUVELLE BEAUREPAIRE & CIE` | COMPANY | partial | hit |
| fr-support-01 | `5512048` | ID | missed | hit |
| fr-support-01 | `8 septembre` | DATE | missed | hit |
| fr-support-01 | `9 septembre` | DATE | partial | hit |
| fr-support-01 | `9 septembre 2026` | DATE | missed | hit |
| fr-support-01 | `S. Lemaître` | PERSON | partial | hit |
| fr-support-01 | `bâtiment C, appartement 12` | ADDRESS | missed | hit |
| fr-terms-01 | `1er janvier` | DATE | missed | hit |
| fr-terms-01 | `CGS-CTA-2026` | ID | missed | hit |

## Over-redaction gone (113)

| document | value | detected as | detector |
|---|---|---|---|
| en-bank-01 | `England` | ADDRESS | ner:xlm-roberta-base-ner-hrl |
| en-bank-01 | `HM Revenue & Customs` | COMPANY | ner:xlm-roberta-base-ner-hrl |
| en-bank-01 | `Lending` | COMPANY | ner:xlm-roberta-base-ner-hrl |
| en-bank-01 | `Lending Review Team
Personal Lending Services` | COMPANY | ner:xlm-roberta-base-ner-hrl |
| en-bank-01 | `Prudential Regulation Authority` | COMPANY | ner:xlm-roberta-base-ner-hrl |
| en-bank-01 | `Wales` | ADDRESS | ner:xlm-roberta-base-ner-hrl |
| en-catalogue-01 | `24817 Rev` | ADDRESS | regex:universal:postal_city |
| en-catalogue-01 | `DAP` | COMPANY | ner:xlm-roberta-base-ner-hrl |
| en-catalogue-01 | `Fergus Naughton, Internal Sales` | COMPANY | ner:xlm-roberta-base-ner-hrl |
| en-catalogue-01 | `Internal Sales Desk` | COMPANY | ner:xlm-roberta-base-ner-hrl |
| en-cv-01 | `2027
Lean Six Sigma Green` | ADDRESS | regex:gb:street |
| en-cv-01 | `A.A.S` | ADDRESS | ner:xlm-roberta-base-ner-hrl |
| en-cv-01 | `Austin` | ADDRESS | ner:xlm-roberta-base-ner-hrl |
| en-cv-01 | `BALASUBRAMANIAN` | COMPANY | ner:xlm-roberta-base-ner-hrl |
| en-cv-01 | `CAPA` | COMPANY | propagated |
| en-cv-01 | `Department of Veterans Affairs` | COMPANY | ner:xlm-roberta-base-ner-hrl |
| en-cv-01 | `FDA` | COMPANY | ner:xlm-roberta-base-ner-hrl |
| en-cv-01 | `MILITARY SERVICE
United States Army` | COMPANY | ner:xlm-roberta-base-ner-hrl |
| en-cv-01 | `NAVEEN` | ADDRESS | ner:xlm-roberta-base-ner-hrl |
| en-insurance-01 | `Claims Review Team` | COMPANY | ner:xlm-roberta-base-ner-hrl |
| en-insurance-01 | `Financial Conduct Authority` | COMPANY | ner:xlm-roberta-base-ner-hrl |
| en-insurance-01 | `Nether Parkfield
Road` | ADDRESS | ner:xlm-roberta-base-ner-hrl |
| en-insurance-01 | `Wales` | ADDRESS | ner:xlm-roberta-base-ner-hrl |
| en-invoice-01 | `ECB` | COMPANY | ner:xlm-roberta-base-ner-hrl |
| en-invoice-01 | `Kilcoole, Co.` | COMPANY | regex:us:company |
| en-invoice-01 | `Naas, Co.` | COMPANY | regex:us:company |
| en-invoice-01 | `Street, Bray, Co.` | COMPANY | ner:xlm-roberta-base-ner-hrl |
| en-invoice-01 | `main` | ADDRESS | propagated |
| en-jobad-01 | `Clinical Engineering` | COMPANY | ner:xlm-roberta-base-ner-hrl |
| en-jobad-01 | `Clinical Engineering` | PERSON | ner:xlm-roberta-base-ner-hrl |
| en-jobad-01 | `Engineering Council` | COMPANY | ner:xlm-roberta-base-ner-hrl |
| en-jobad-01 | `ISO` | COMPANY | ner:xlm-roberta-base-ner-hrl |
| en-jobad-01 | `MHRA` | COMPANY | ner:xlm-roberta-base-ner-hrl |
| en-jobad-01 | `United Kingdom` | ADDRESS | ner:xlm-roberta-base-ner-hrl |
| en-lease-01 | `H. Draycott
Property Management Team` | COMPANY | ner:xlm-roberta-base-ner-hrl |
| en-letter-01 | `K. Ademola
Metering Services` | COMPANY | ner:xlm-roberta-base-ner-hrl |
| en-letter-01 | `Lindley` | COMPANY | ner:xlm-roberta-base-ner-hrl |
| en-manual-01 | `88-4401` | NUMBER | propagated |
| en-manual-01 | `United Kingdom` | ADDRESS | ner:xlm-roberta-base-ner-hrl |
| en-medical-01 | `BR4471908

CONFIDENTIALITY NOTICE` | IBAN | regex:universal:iban |
| en-medical-01 | `Division of Endocrinology` | COMPANY | ner:xlm-roberta-base-ner-hrl |
| en-payslip-01 | `D. Fairhurst-Naylor
Payroll Services` | COMPANY | ner:xlm-roberta-base-ner-hrl |
| en-payslip-01 | `Machine` | COMPANY | ner:xlm-roberta-base-ner-hrl |
| en-policy-01 | `ATLAS` | COMPANY | ner:xlm-roberta-base-ner-hrl |
| en-policy-01 | `Beaverton` | COMPANY | ner:xlm-roberta-base-ner-hrl |
| en-policy-01 | `INFORMATION SECURITY` | COMPANY | propagated |
| en-policy-01 | `IT Service Desk` | COMPANY | ner:xlm-roberta-base-ner-hrl |
| en-policy-01 | `Information Security` | COMPANY | ner:xlm-roberta-base-ner-hrl |
| en-policy-01 | `Procurement` | COMPANY | ner:xlm-roberta-base-ner-hrl |
| en-support-01 | `Kinvara` | COMPANY | ner:xlm-roberta-base-ner-hrl |
| en-terms-01 | `Facilities` | PERSON | ner:xlm-roberta-base-ner-hrl |
| en-terms-01 | `Procurement` | COMPANY | ner:xlm-roberta-base-ner-hrl |
| es-catalogue-01 | `Departamento Comercial` | COMPANY | ner:xlm-roberta-base-ner-hrl |
| es-catalogue-01 | `Departamento de Administración de Ventas` | COMPANY | ner:xlm-roberta-base-ner-hrl |
| es-catalogue-01 | `Parque` | COMPANY | ner:xlm-roberta-base-ner-hrl |
| es-catalogue-01 | `Registro Mercantil de Madrid` | COMPANY | ner:xlm-roberta-base-ner-hrl |
| es-chat-01 | `IMG-20260911` | ID | regex:universal:labeled_id |
| es-chat-01 | `piso es Carrer del Molí Nou, 42` | ADDRESS | regex:es:street |
| es-cv-01 | `Cámara de Comercio de Sevilla` | COMPANY | ner:xlm-roberta-base-ner-hrl |
| es-insurance-01 | `. Oleksandr Hrytsenko Marín` | PERSON | ner:xlm-roberta-base-ner-hrl |
| es-jobad-01 | `Departamento de Personas` | COMPANY | ner:xlm-roberta-base-ner-hrl |
| es-lease-01 | `D. Youssef El Amrani Bouzid` | PERSON | ner:xlm-roberta-base-ner-hrl |
| es-lease-01 | `Dña. Rosa María Villalba Pons` | PERSON | ner:xlm-roberta-base-ner-hrl |
| es-lease-01 | `Institut Valencià de l'Edificació.

CUARTA. Suministros` | COMPANY | ner:xlm-roberta-base-ner-hrl |
| es-letter-01 | `Correos` | COMPANY | list:company |
| es-letter-01 | `Departamento de Facturación` | COMPANY | ner:xlm-roberta-base-ner-hrl |
| es-manual-01 | `41-2400` | NUMBER | propagated |
| es-notice-01 | `AYUNTAMIENTO DE PUENTE ALMANZOR` | COMPANY | ner:xlm-roberta-base-ner-hrl |
| es-notice-01 | `Herradores` | ADDRESS | ner:xlm-roberta-base-ner-hrl |
| es-notice-01 | `Oficina de Atención Ciudadana` | ADDRESS | ner:xlm-roberta-base-ner-hrl |
| es-notice-01 | `avenida de los Olmares` | ADDRESS | ner:xlm-roberta-base-ner-hrl |
| es-notice-01 | `calle Cantarranas` | ADDRESS | ner:xlm-roberta-base-ner-hrl |
| es-notice-01 | `calle Herradores` | ADDRESS | ner:xlm-roberta-base-ner-hrl |
| es-notice-01 | `calles` | ADDRESS | ner:xlm-roberta-base-ner-hrl |
| es-notice-01 | `plaza del Peso` | ADDRESS | ner:xlm-roberta-base-ner-hrl |
| es-notice-01 | `ronda de Poniente` | ADDRESS | ner:xlm-roberta-base-ner-hrl |
| es-payslip-01 | `Artes` | COMPANY | list:company |
| es-payslip-01 | `Seguridad Social` | COMPANY | ner:xlm-roberta-base-ner-hrl |
| es-policy-01 | `Departamento de Administración` | COMPANY | ner:xlm-roberta-base-ner-hrl |
| es-policy-01 | `Dirección de Recursos Humanos` | COMPANY | ner:xlm-roberta-base-ner-hrl |
| es-policy-01 | `VIATIA` | COMPANY | ner:xlm-roberta-base-ner-hrl |
| es-terms-01 | `Juzgados` | COMPANY | ner:xlm-roberta-base-ner-hrl |
| es-terms-01 | `Mercantil de Valencia` | COMPANY | ner:xlm-roberta-base-ner-hrl |
| es-terms-01 | `de Administración` | COMPANY | ner:xlm-roberta-base-ner-hrl |
| fr-bank-01 | `Lorquin` | PERSON | ner:xlm-roberta-base-ner-hrl |
| fr-bank-01 | `Mastercard` | COMPANY | list:company |
| fr-catalogue-01 | `AUZANCE` | ADDRESS | ner:xlm-roberta-base-ner-hrl |
| fr-catalogue-01 | `COMPTOIR METALLURGIQUE DE L'AUZANCE - SAS` | COMPANY | ner:xlm-roberta-base-ner-hrl |
| fr-catalogue-01 | `SIRET` | COMPANY | ner:xlm-roberta-base-ner-hrl |
| fr-cv-01 | `Carl Source` | PERSON | ner:xlm-roberta-base-ner-hrl |
| fr-cv-01 | `Schneider` | COMPANY | ner:xlm-roberta-base-ner-hrl |
| fr-cv-01 | `Siemens` | COMPANY | ner:xlm-roberta-base-ner-hrl |
| fr-cv-01 | `U13` | COMPANY | ner:xlm-roberta-base-ner-hrl |
| fr-insurance-01 | `IBAN` | COMPANY | ner:xlm-roberta-base-ner-hrl |
| fr-insurance-01 | `SANTÉ ESSENTIEL` | COMPANY | ner:xlm-roberta-base-ner-hrl |
| fr-insurance-01 | `Sud-Ouest` | ADDRESS | ner:xlm-roberta-base-ner-hrl |
| fr-invoice-01 | `IBAN` | COMPANY | ner:xlm-roberta-base-ner-hrl |
| fr-jobad-01 | `Grand Ouest` | ADDRESS | ner:xlm-roberta-base-ner-hrl |
| fr-letter-01 | `Caisse d'allocations familiales` | COMPANY | ner:xlm-roberta-base-ner-hrl |
| fr-letter-01 | `IBAN` | COMPANY | ner:xlm-roberta-base-ner-hrl |
| fr-letter-01 | `Résidence Les Coteaux` | COMPANY | ner:xlm-roberta-base-ner-hrl |
| fr-manual-01 | `VOLTARIS` | COMPANY | ner:xlm-roberta-base-ner-hrl |
| fr-medical-01 | `Dresse` | PERSON | propagated |
| fr-medical-01 | `Riponne` | ADDRESS | ner:xlm-roberta-base-ner-hrl |
| fr-notice-01 | `RUE DES TANNEURS` | ADDRESS | ner:xlm-roberta-base-ner-hrl |
| fr-notice-01 | `boulevard Sainte-Colombe` | ADDRESS | ner:xlm-roberta-base-ner-hrl |
| fr-notice-01 | `rue Fresnaye` | ADDRESS | ner:xlm-roberta-base-ner-hrl |
| fr-policy-01 | `Direction des ressources humaines` | COMPANY | ner:xlm-roberta-base-ner-hrl |
| fr-policy-01 | `SIRET` | COMPANY | ner:xlm-roberta-base-ner-hrl |
| fr-policy-01 | `SOCIETE NOUVELLE BEAUREPAIRE & CIE - SA` | COMPANY | ner:xlm-roberta-base-ner-hrl |
| fr-terms-01 | `Banque centrale européenne` | COMPANY | ner:xlm-roberta-base-ner-hrl |
| fr-terms-01 | `INSEE` | COMPANY | ner:xlm-roberta-base-ner-hrl |
| fr-terms-01 | `SIRET` | COMPANY | ner:xlm-roberta-base-ner-hrl |

