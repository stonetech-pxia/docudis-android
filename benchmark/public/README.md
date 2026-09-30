# Public-record documents for the real-document test set

Real documents with real entities, all from sources that publish them on purpose.
They complement `benchmark/ner_cases.json` (hand-written sentences) and
`benchmark/synthetic_cases.json` (template + fake data for document types that have no
public samples: invoice, lease, payslip, medical letter, CV).

| Source | Language | What | Licence / status |
|---|---|---|---|
| [BODACC](https://www.bodacc.fr) open-data API | fr | Commercial-court announcements: company creations, business sales, insolvency judgments, modifications. The structured record is rendered to announcement text by the fetcher. | Licence Ouverte 2.0 (Etalab) |
| [BORME](https://www.boe.es/diario_borme/) | es | Company-registry gazette. PDF converted with `pdftotext`, six consecutive registry acts per document. | Official publication, reuse allowed with attribution (boe.es) |
| [The Gazette](https://www.thegazette.co.uk) | en | UK corporate insolvency notices only. Personal insolvency notices are deliberately excluded. | Open Government Licence v3.0 |
| Enron e-mail corpus (`corbt/enron-emails` mirror) | en | Business e-mails released by FERC in 2003: original casing, forwarded chains, recipient lists. | Public record, widely redistributed for research |

## Files

- `raw/<id>.txt`: the document text, as fetched. `index.json`: id, language, category, source URL.
- `labels/<id>.json`: ground-truth entities, written by an annotator who read the document without
  access to the detection pipeline. Rules: [ANNOTATION.md](ANNOTATION.md).
- `../public_cases.json`: the assembled dataset in the benchmark format.

## Rebuild

```bash
python tool/fetch_public_samples.py          # needs network and pdftotext; newest records, so texts change
python tool/build_public_cases.py            # validates every label, writes benchmark/public_cases.json
```

Re-fetching replaces the documents, so the labels must be redone. Treat `raw/` and `labels/` as a frozen snapshot.

## Scoring

The documents are dense and addresses are labelled as written (one value per contiguous address), so
span-for-span F1 understates how much is actually hidden. Use the coverage-based report:

```bash
cd packages/docudis_engine
PYTHON=<python> dart run benchmark/run_benchmark.dart --model ../../assets/models/xlmr_ner_hrl \
  --dataset ../../benchmark/public_cases.json --out ../../docs/benchmark/desktop-xlmr-public.md
cd ../..
python tool/leak_report.py benchmark/public_cases.json docs/benchmark/desktop-xlmr-public.json --out docs/benchmark/leak-public.md
```
