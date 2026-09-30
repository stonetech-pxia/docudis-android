# On-device NER models

The model binaries are **not** committed (see `.gitignore`); only each folder's
`model.json` (the spec the app reads) is tracked. `manifest.json` pins every
binary to a Hugging Face repo, revision and SHA-256. On a fresh clone:

```bash
pip install huggingface_hub
huggingface-cli login                                # once: xlmr_ner_docudis is a private repo
"$PYTHON" tool/fetch_models.py                       # the shipped model
"$PYTHON" tool/fetch_models.py --all                 # plus the two stock models, for A/B benchmarks
```

| Folder | Hugging Face repo | Use |
|---|---|---|
| `xlmr_ner_docudis` | private, see `manifest.json` | **Shipped since 2026-09-21.** Our fine-tune of `Davlan/xlm-roberta-base-ner-hrl` on en / fr / es material, AFL-3.0 |
| `xlmr_ner_hrl` | `tjruesch/xlm-roberta-base-ner-hrl-onnx` | The stock model it was fine-tuned from, for A/B benchmarks (`MODEL=../../assets/models/xlmr_ner_hrl tool/run_all_benchmarks.sh`) |
| `distilbert_ner_hrl` | `Xenova/distilbert-base-multilingual-cased-ner-hrl` | Smaller/faster alternative, for A/B benchmarks; add its files to `assets:` in pubspec.yaml to ship it instead |

**Retraining `xlmr_ner_docudis`** happens on the Windows machine only (it needs
the NVIDIA GPU): `training/README.md` has the pipeline and
`docs/HANDOFF-ner-finetune-2026-09-19.md` §3.5a what each run scored. After
exporting a new model to `assets/models/xlmr_ner_docudis`, publish it and move
the pin:

```bash
huggingface-cli upload <repo> assets/models/xlmr_ner_docudis . --include "model_quantized.onnx" "tokenizer.json" "model.json"
```

then put the commit id it prints and the new SHA-256 of both files into
`manifest.json`, and commit.

How the app gets the files: they are not Flutter assets. Gradle syncs
`xlmr_ner_docudis/{model.json,tokenizer.json,model_quantized.onnx}` into the Play
Asset Delivery pack `android/model_pack` (release, `flutter build appbundle`)
and into the debug source set (`flutter run`). `ModelLocator` streams them to
the app support dir through the native `model_assets` channel.

Swapping the model: drop a new `.onnx` plus its tokenizer file into a new
folder, write a `model.json` (fields documented in
`packages/docudis_engine/lib/src/ner/ner_model_spec.dart`), update the file
lists in `android/model_pack/build.gradle.kts` and `android/app/build.gradle.kts`,
and point `ModelLocator(assetDir: 'models/<folder>')` at it. WordPiece
(`tokenizer.json`) and SentencePiece (`.model` or HF `tokenizer.json`)
tokenizers are both supported.

Licenses: both models are Academic Free License 3.0 (Davlan).
