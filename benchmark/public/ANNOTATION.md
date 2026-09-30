# Annotation guide for the public-record test set

Goal: list every span a person would want hidden before pasting the document into an AI assistant.
The labels are the ground truth for a leak-rate metric, so **a missing label hides a leak and a wrong
label creates a false one**. Read the whole document; do not rely on any tool's output.

One file per document: `benchmark/public/labels/<id>.json`

```json
{"id": "<id>", "expected": [{"value": "Lee Morris", "type": "PERSON"}, {"value": "CR-2026-BHM-0004", "type": "ID", "sub": "reference"}]}
```

## Rules for `value`

- An **exact substring** of `benchmark/public/raw/<id>.txt`: same characters, accents, case, inner spacing.
- Never contains a line break. If an entity wraps over two lines, label the part on each line separately.
- No leading or trailing spaces or punctuation.
- Each distinct (value, type) pair appears once, however often it occurs in the text.
- If the same entity is written in two ways ("Marshall Peters" and "Marshall Peters Limited"), label both.

## Types

| Type | Label | Do not label |
|---|---|---|
| PERSON | Natural persons, without titles: `Lee Morris`, `LOPEZ CORCOLES MIGUEL ANGEL` (BORME writes surnames first, all caps), `Phillip K Allen`. First names or surnames standing alone (`Phillip`, `tom`, `Kean`) when they refer to a person. In Enron recipient strings such as `Tim Belden/HOU/ECT@ECT` label only `Tim Belden`. | `Mr`, `Dr`, `Maître`, `Me`, `D.`, job titles, roles (`Gérant`, `Adm. Unico`, `Joint Liquidator`). |
| COMPANY | Companies, firms, partnerships, banks, schools, hospitals, associations, named with or without legal form: `ALPHA KILO CREATIVE LIMITED`, `Marshall Peters`, `Selarl Amandine Riquelme`, `SAS BLENET-CHUL`, acronyms and trade names (`MECADISTRIB`). A company acting as director in BORME is a COMPANY. | Courts, tribunals, registries, ministries, regulators and other government bodies (`Tribunal de Commerce de Reims`, `High Court of Justice`, `FERC`). Newspapers named only as the place of a legal notice. Generic words (`the Company`, `la société`). |
| ADDRESS | A postal address as written, as **one value** when it is contiguous on one line: `11 Second Floor, Savile Row, London, W1S 3PG`, `7 rue de la République, 51700 Festigny`, `C/ PONTEVEDRA, 1 4º D 02003 (ALBACETE)`. Also towns, regions and countries standing alone (`Reims`, `Houston`, `Albacete`), including the place name inside the name of a local court, registry or public body: `Reims` in `Tribunal de Commerce de Reims`, `Nantes` in `CPAM de Nantes`, `Sevilla` in `Juzgado de lo Mercantil de Sevilla`, `MAHON` in `R.M. MAHON`, `Birmingham` in `Business and Property Courts in Birmingham`. | The rest of the body's name (`Tribunal de Commerce de`, `R.M.`). Place words that are part of a national body's fixed name (`High Court of England and Wales`) or of a company's statement of registration (`Registered in England and Wales No. 929027`, `Registered in Scotland No. SC002116`): these name the legal jurisdiction a company was incorporated in, not where anyone is. Department or region codes. |
| DATE | Calendar dates with at least a day and a month, in any format: `14 September 2026`, `08/09/2026`, `17 juillet 2026`, `4.09.24`, `06/02/2000`. | Times, bare years, month plus year, durations, the BODACC or BORME issue number. |
| AMOUNT | Money with its currency: `60.000,00 Euros`, `1000.00 EUR`, `80000.00 euros`. | Percentages, quantities, share counts. |
| ID | Identifiers of a person or company: `838 805 653` (RCS / SIREN, label the number only), `09583892` (company number), `31850` (insolvency practitioner number), BORME registry data `H AB 23576`. With `"sub": "reference"`: court case numbers, file and dossier numbers (`CR-2026-BHM-0004`, `2026 00048497`). | Announcement numbers, BORME act sequence numbers (`393331`), article numbers of laws, NAF codes. |
| PHONE, EMAIL, URL | As written. | URLs of the official gazette itself. |
| IBAN, CARD, IP | If any occur. | |

## Judgement calls

- When unsure whether an organisation is "government", ask: would naming it identify the parties? A liquidator's firm does, a court does not.
- A person's name inside a firm name (`Selarl Amandine Riquelme`) is labelled as the COMPANY; if the person is also named separately (`me Amandine Riquelme`) label that PERSON too.
- Header lines added by the fetcher (`BODACC A n° ... du 18/09/2026`, `Jueves 12 de septiembre de 2024`) contain real dates: label them.

## Self-check

Run `C:/Users/Xia/anaconda3/python.exe tool/build_public_cases.py --check <id> [<id> ...]` from the repository root
(set `PYTHONIOENCODING=utf-8`). It must report 0 problems for your documents.
