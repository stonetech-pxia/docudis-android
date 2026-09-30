# Annotation guide for the consumer-document test set

Same goal, file format, value rules and types as [the public-record guide](../public/ANNOTATION.md):
read that first. Label files go to `benchmark/consumer/labels/<id>.json`, values are exact substrings of
`benchmark/consumer/raw/<id>.txt`. This page only adds what consumer documents need.

## Additions

| Type | Label | Do not label |
|---|---|---|
| BIRTH_DATE | A date of birth, whatever its format: `14/03/1987`, `née le 3 avril 1987`→`3 avril 1987`, `DOB 1987-03-14`. Use BIRTH_DATE instead of DATE for it. | Ages (`38 ans`). |
| PERSON | Also first names, nicknames and lowercase names in chats and e-mails (`karen`, `Mog`, `tía Carmen`→`Carmen`), initials plus surname (`J. Whitfield`), names in e-mail signatures and in "Last, First" order. | Names that only appear inside an e-mail address or URL (the EMAIL / URL label covers them). Famous people named as a topic, brand mascots. |
| COMPANY | Employers, landlords' agencies, clinics, surgeries, pharmacies, banks, insurers, schools, shops, as written, with or without legal form (`Brightwater Dental Practice`, `Cabinet Morel`, `Seguros Ocaso`). A department or team on its own (`Patient Services`, `Service Comptabilité`) is **not** labelled. | Public bodies: tax office, social security (`CPAM`, `URSSAF`, `HMRC`, `Seguridad Social`, `NHS` as a system), courts, town halls. If such a body's name contains a place, label the place as ADDRESS. Product and plan names (`Forfait Sérénité`). |
| ADDRESS | As in the public guide: one value per contiguous address on one line; when an address runs over several lines, one value per line. Towns, regions and countries standing alone. A floor / flat / suite on its own line is an ADDRESS value. | Generic places (`the office`, `la clinique`). Nationalities and languages. The jurisdiction in a company's statement of registration (`Registered in England and Wales No. 929027`): it says where the company was incorporated, not where anyone is, and it is on every letter that company sends. Corrected 2026-09-21 — seven labels were removed; where the same place name is also a real address in that document (`Ireland` in en-insurance-01, `Montpellier` in fr-lease-01) the label stays, because labels are matched by value. |
| ID | Social security, tax, national identity, passport, driving licence, patient / NHS, employee, customer and member numbers, SIREN / SIRET / NIF / VAT numbers, bank account numbers and sort codes that are not an IBAN, licence plates. Contract, policy and membership numbers are plain ID too: they identify the customer's account for years. With `"sub": "reference"`: numbers of one document, transaction or case: invoice, order, quote, receipt, claim, ticket, file, prescription, certificate, SEPA mandate and transfer references, registered-letter numbers. | Quantities, product codes, legal article numbers, postcodes (they are part of the ADDRESS), page numbers. |
| DATE / AMOUNT | As in the public guide. Amounts need a currency symbol, code or word. | Pay periods written as month + year, percentages, hours, rates without currency. |

## Judgement calls

- A number keeps the type its label gives it in the document, not the type it looks like: `N° client : 0612345678` is an ID.
- The same person written in different ways (`Hélène Garnier`, `Mme GARNIER`, `Hélène`) gives three values: `Hélène Garnier`, `GARNIER`, `Hélène`.
- Table rows: label each cell value on its own; never label the column header.
- When a line mixes a name and a role (`Dr Priya Raman, Consultant Cardiologist`), only `Priya Raman` is labelled.

## Settled conventions (from the first annotation pass)

- BIC / SWIFT codes, routing numbers, sort codes, meter and supply-point numbers (MPRN, PDL, CUPS, EAN), professional registration
  numbers (GMC, NPI, RPPS, nº de colegiado, ORIAS), company and land registry sheet numbers (`Hoja Z-61204` → `Z-61204`, without tomo / folio and without the word) are plain ID.
- Masked numbers: a masked IBAN is one IBAN value as written, asterisks included. For a masked card or account
  (`card ending 3308`, `**** 4402`) label the visible group when it has at least 4 digits: CARD for a card, ID for an account.
- The final period of an abbreviation belongs to the value (`S.L.`, `Inc.`, `N.A.`, `2º izda.`); a sentence's full stop does not.
  US phone numbers keep their opening parenthesis: `(717) 364-0192`.
- Dates: day + month without a year is a DATE (`17 October`, `04/09`, `1er mars`); the weekday is left out. In a range that shares
  its month (`du 3 au 10 septembre 2026`) only the complete part is labelled. Month + year (`06/2027`) is not a date.
- Table amounts count only when the currency is in the cell (`£3,600.60`), not when it is only in the column header.
  Unit prices with a currency (`0,1635 €`) count.
- Schools, universities, hospitals, health centres, associations, clubs and publicly owned utilities run as companies are COMPANY.
  Tax, social-security and employment agencies, regulators, ombudsmen, courts, chambers of commerce and town halls are not; the
  place name in a local one is an ADDRESS. A bank branch named after its town: the bank is the COMPANY, the town an ADDRESS.
- A practice described through its doctor (`Dr Okonkwo's surgery`, `cabinet du dr Vasseur`) gives only the PERSON.
- Not labelled: flight and train numbers, bare initials (`TJO`, paraphes), product, plan, drug and card-brand names,
  ward / clinic / terminal names, house or flat numbers standing alone in prose (`le 41`), nationalities and demonyms.

## Self-check

`C:/Users/Xia/anaconda3/python.exe tool/build_public_cases.py --set consumer --check <id> [<id> ...]` from the repository root
(with `PYTHONIOENCODING=utf-8`). It must report 0 problems for your documents.
