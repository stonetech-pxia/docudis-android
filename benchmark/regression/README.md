# Held-out regression set (frozen 2026-09-21)

48 documents written **after** the fine-tuned model (`xlmr_ner_docudis`, ft4), the 2026-09-21 ID rules, the span
completion and the company rules had all shipped. Nothing here was ever read while writing a rule, a template or a
training inventory, and nothing here may be. It exists to answer one question the other sets cannot:

> after the model fine-tune and five commits' worth of new rules, did anything get **worse** on documents nobody
> tuned against?

## The two groups

| Group | Documents | What it measures |
|---|---|---|
| **A — consumer** | 30: English, French and Spanish × the same ten categories as the frozen consumer set (bank, chat, cv, insurance, invoice, lease, letter, medical, payslip, support) | Whether the gains on the frozen 60 hold on fresh documents of the same kind, or were partly fitted to that set |
| **B — about a thing, not a person** | 18: terms and conditions, price lists and quotations, internal policies, technical manuals, job advertisements, public notices, three per language | Over-redaction. These are full of product references, standard numbers (EN / ISO / UNE / CE), article numbers of legislation, job titles, department names and the document's own reference numbers — exactly what the span completion and the new labelled-ID rules could reach into. Most carry one contact name at most, several carry none |

## How it was made

- **Writers** (12 subagents, one language each, 3 to 5 documents): given the document type, country, layout features and
  name-diversity requirements, and `tool/valid_ids.py` for identifiers with a check digit. They were forbidden to open any
  file in the repository — no engine, no rules, no other test set, no annotation guide. (One writer saw the *file names*
  in `raw/` while checking a character count; no content was opened.)
- **Annotators** (9 subagents): given `../public/ANNOTATION.md` and `../consumer/ANNOTATION.md` and the raw text, nothing
  else. No detector output was ever shown to anyone. Each verified its own files with
  `python tool/build_public_cases.py --set regression --check <id> ...`.
- **Reviewers**: a second pass over every document against the same two guides.

The annotation convention is the consumer guide unchanged, including the 2026-09-21 corrections (a company's statement of
registration is not an address; a public body's name is not a COMPANY but a place inside it is an ADDRESS).

## Files

- `raw/<id>.txt`, `labels/<id>.json`, `index.json` (id, language, category, group).
- `../regression_cases.json`: assembled by `python tool/build_public_cases.py --set regression` (validates every label).

## Scoring

Run the two configurations on it and diff them entity by entity:

```bash
# current shipping configuration
cd packages/docudis_engine && dart run benchmark/run_benchmark.dart \
  --model ../../assets/models/xlmr_ner_docudis --dataset ../../benchmark/regression_cases.json \
  --out ../../docs/benchmark/desktop-regression-current.md
# pre-fine-tune baseline: engine at 65e73e2 in a worktree, stock model
dart run benchmark/run_benchmark.dart --model <repo>/assets/models/xlmr_ner_hrl \
  --dataset <repo>/benchmark/regression_cases.json --out <out>/desktop-regression-baseline.md
python tool/compare_runs.py <baseline>.json <current>.json --out docs/benchmark/regression-diff.md
python tool/leak_report.py benchmark/regression_cases.json <current>.json --out docs/benchmark/leak-regression.md
```

`tool/compare_runs.py` lists every expected entity whose status got worse (hit → partial / wrong type / missed) and
every over-redaction one run has and the other does not. Those two tables are the answer; the summary numbers are not.

## Overlap with the other sets

Checked after freezing: six documents share an eight-word run with an existing test or training text, and every one of
them is boilerplate a real document of that kind must contain (`authorised and regulated by the Financial Conduct
Authority`, `under the Late Payment of Commercial Debts`). `National Westminster Bank Plc` appears here and in the
frozen consumer set because both name a real bank, which the brief allows. One invented person name, `Youssef El
Amrani`, collides by chance with a name in the frozen consumer set; the writers could not see that set, and the
fine-tune never saw either, so it biases nothing.
