#!/usr/bin/env bash
# Runs the desktop NER benchmark on every dataset and prints the numbers that matter:
# F1 / precision of the hand-written set, leak rate and over-redaction of the real-document
# sets, and every false positive on the hard negatives.
#
#   PYTHON=/path/to/python tool/run_all_benchmarks.sh [--no-stress]
#
# PYTHON must have onnxruntime and numpy (see benchmark/bench_server.py). Needs dart on PATH
# (it ships with Flutter: <flutter>/bin) and the XLM-R model files (tool/fetch_models.py).
set -euo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
# Report tags in docs/benchmark/, newest last:
#   (no tag)  the pre-fine-tune baseline: stock xlmr_ner_hrl, 2026-09-20. This is what section 2 of
#             docs/HANDOFF-ner-finetune-2026-09-19.md quotes, so DO NOT overwrite it — always pass a
#             TAG. Running this script with no TAG now scores the fine-tune into the baseline's files.
#   -ft/-ft2/-ft3  the three fine-tuning runs (ft3 is the one that shipped)
#   -rules    ft3 plus the 2026-09-21 ID rules
#   -ft4      ft4 plus those rules
#   -repair   ft4, the rules, and the 2026-09-21 span completion
#   -company  plus the 2026-09-21 company rules
#   -addrline plus the 2026-09-21 address-block line rule: the current shipping configuration
model="${MODEL:-../../assets/models/xlmr_ner_docudis}"  # MODEL=../../assets/models/xlmr_ner_hrl for the stock model
tag="${TAG:+-$TAG}"                                  # TAG=ft writes docs/benchmark/desktop-xlmr-public-ft.md, etc.
py="${PYTHON:-python}"
stress="--stress"
[[ "${1:-}" == "--no-stress" ]] && stress=""
export PYTHON="$py" PYTHONIOENCODING=utf-8

cd "$root/packages/docudis_engine"
run() { # <dataset or ""> <out-name> [extra flag]
  local args=(--model "$model" --out "../../docs/benchmark/$2$tag.md")
  [[ -n "$1" ]] && args+=(--dataset "../../benchmark/$1")
  [[ -n "${3:-}" ]] && args+=("$3")
  dart run benchmark/run_benchmark.dart "${args[@]}" 2>&1 | grep -E "^- Overall|Unhandled|Error" | sed "s/^/  /"
}
echo "== hand-written (ner_cases.json)";        run "" desktop-xlmr $stress
echo "== public records";                        run public_cases.json desktop-xlmr-public
echo "== synthetic documents";                   run synthetic_cases.json desktop-xlmr-synthetic
echo "== consumer documents";                    run consumer_cases.json desktop-xlmr-consumer
echo "== hard negatives";                        run hard_negatives.json desktop-xlmr-negatives

cd "$root"
for name in public synthetic consumer; do
  "$py" tool/leak_report.py "benchmark/${name}_cases.json" "docs/benchmark/desktop-xlmr-${name}${tag}.json" --out "docs/benchmark/leak-${name}${tag}.md" > /dev/null
  echo "== leak report: $name"
  grep -E "^\| (\*\*All\*\*|en|es|fr) \|" "docs/benchmark/leak-${name}${tag}.md" | head -4 | sed "s/^/  /"
  grep -E "^## Over-redaction" "docs/benchmark/leak-${name}${tag}.md" | sed "s/^/  /"
  grep -A8 "^## Documents with no leak" "docs/benchmark/leak-${name}${tag}.md" | grep -F "| **All** |" | sed "s/^/  documents (all, fully clean, share, no identifying leak, share): /"
done
echo "== false positives on hard negatives"
tag="$tag" "$py" - <<'EOF'
import json, os
tag = os.environ.get('tag', '')
run = json.load(open(f'docs/benchmark/desktop-xlmr-negatives{tag}.json', encoding='utf-8'))
n = 0
for r in run['results']:
    for d in r['detections']:
        n += 1
        print(f"  {r['case']['id']}: {d['type']} {d['value']!r} ({d['detector']})")
print(f'  total: {n}')
EOF
