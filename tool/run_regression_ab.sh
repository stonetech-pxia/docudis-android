#!/usr/bin/env bash
# Runs the held-out regression set (benchmark/regression) on two configurations and diffs them:
#   before = the engine as of 65e73e2 (pre-fine-tune) with the stock xlmr_ner_hrl model
#   after  = this working tree with assets/models/xlmr_ner_docudis
#
#   BASELINE=/path/to/worktree PYTHON=/path/to/python tool/run_regression_ab.sh
#
# BASELINE must be a git worktree at 65e73e2 with `dart pub get` already run in
# packages/docudis_engine. Needs dart on PATH (<flutter>/bin).
# Writes docs/benchmark/desktop-regression-{baseline,current}.md|.json, regression-diff.md and
# leak-regression{,-baseline}.md.
set -euo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
py="${PYTHON:-python}"
baseline="${BASELINE:?set BASELINE to the 65e73e2 worktree}"
export PYTHON="$py" PYTHONIOENCODING=utf-8
out="$root/docs/benchmark"
data="$root/benchmark/regression_cases.json"

"$py" "$root/tool/build_public_cases.py" --set regression

echo "== current (ft4 + ID rules + span completion + company rules)"
cd "$root/packages/docudis_engine"
dart run benchmark/run_benchmark.dart --model ../../assets/models/xlmr_ner_docudis \
  --dataset "$data" --out "$out/desktop-regression-current.md" 2>&1 | grep -E "^- Overall|Unhandled|Error"

echo "== baseline (65e73e2, stock xlmr_ner_hrl)"
cd "$baseline/packages/docudis_engine"
dart run benchmark/run_benchmark.dart --model "$root/assets/models/xlmr_ner_hrl" \
  --dataset "$data" --out "$out/desktop-regression-baseline.md" 2>&1 | grep -E "^- Overall|Unhandled|Error"

cd "$root"
"$py" tool/compare_runs.py "$out/desktop-regression-baseline.json" "$out/desktop-regression-current.json" \
  --out "$out/regression-diff.md"
for cfg in current baseline; do
  "$py" tool/leak_report.py "$data" "$out/desktop-regression-$cfg.json" --out "$out/leak-regression-$cfg.md" > /dev/null
  echo "== leak report: $cfg"
  grep -E "^\| (\*\*All\*\*|en|es|fr) \|" "$out/leak-regression-$cfg.md" | head -4 | sed "s/^/  /"
  grep -E "^## Over-redaction" "$out/leak-regression-$cfg.md" | sed "s/^/  /"
  grep -A8 "^## Documents with no leak" "$out/leak-regression-$cfg.md" | grep -F "| **All** |" |
    sed "s/^/  documents (all, fully clean, share, no identifying leak, share): /"
done
