# Consumer-document test set (frozen 2026-09-19)

What users actually paste: letters, invoices, payslips, medical letters and prescriptions, leases and rent
receipts, bank and insurance letters, CVs, customer-service e-mail threads, chat exports. 60 documents,
20 each in English (UK, US, Ireland), French (France, one Belgian, one Swiss) and Spanish (Spain), two per
document type, from 400 to 4 500 characters. Every person, small business, address and number is invented;
large real organisations appear where a real document would name them.

**Frozen.** It is the acceptance test for the NER fine-tune: nothing in it may be used to write training
templates, inventories or rules, and its leak report is not to be mined for examples while training.
docudis-ner's `training/check_isolation.py` must treat it like the other test sets.

## How it was made

- Writers (12 subagents, five documents each, one language) saw no repository file: not the detection engine, not the other
  test sets, not the annotation guide. They were given the document type, country, layout features (letterhead, field
  blocks, flattened tables, signature with the department on the next line, OCR line breaks, chat timestamps), name
  diversity requirements and `tool/valid_ids.py` for identifiers with a check digit (NIR, SIREN / SIRET, DNI / NIE,
  Spanish social security, NINO, NHS, SSN, IBAN, card).
- Annotators (9 subagents) saw only the two annotation guides and the raw text; reviewers (6) the same plus the
  first-pass labels. Nobody saw detector output. Guide: [ANNOTATION.md](ANNOTATION.md), which extends
  [the public-record guide](../public/ANNOTATION.md).

## Files

- `raw/<id>.txt`, `labels/<id>.json`, `index.json` (id, language, category).
- `../consumer_cases.json`: assembled by `python tool/build_public_cases.py --set consumer` (validates every label).

## Scoring

`tool/run_all_benchmarks.sh` runs it with the other sets and writes `docs/benchmark/leak-consumer.md`. The number
that matters is the share of documents with **no identifying leak** (see `tool/leak_report.py` for what counts
as residue). Baseline before fine-tuning, desktop XLM-R int8: leak rate 18.7 %, 11 of 60 documents without an
identifying leak.
