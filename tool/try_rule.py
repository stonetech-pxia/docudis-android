r"""Score a candidate regex rule before it goes into rules/*.json.

    python tool/try_rule.py '<pattern>' [--flags gu] [--baseline -rules]

Gain  = entities the baseline run leaks or half-hides that a match would fully cover.
Cost  = matches that touch no expected entity (over-redaction) + any match on hard_negatives.
Both must be looked at; a rule that only reports gain is not evaluated, and a rule that
only reports totals is not evaluated either: after editing an existing rule, diff the
per-entity status against the baseline run as well. Loosening a value shape can raise the
hidden count while quietly turning half-hidden account numbers back into full leaks.

Baseline defaults to the newest `-rules` run; pass --baseline to compare against another tag.
Patterns use the `regex` module so \p{L} and variable-length lookbehind work as they do in
Dart. The ibanMod97 and similar validators are NOT applied here, so a shape that the engine
would reject on its check digits still shows up as a cost.
"""
import argparse, collections, importlib.util, json, sys

spec = importlib.util.spec_from_file_location('lr', 'tool/leak_report.py')
lr = importlib.util.module_from_spec(spec)
_argv, sys.argv = sys.argv, ['x', 'a', 'b']
try: spec.loader.exec_module(lr)
except SystemExit: pass
except Exception: pass
sys.argv = _argv
import regex

SETS = ['consumer', 'public', 'synthetic']


def spans(text, rx):
    return [(m.start(), m.end(), m.group(0)) for m in rx.finditer(text)]


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('pattern')
    ap.add_argument('--flags', default='gu')
    ap.add_argument('--baseline', default='-rules')
    args = ap.parse_args()
    f = regex.V1 | (regex.I if 'i' in args.flags else 0)
    rx = regex.compile(args.pattern, f)

    for name in SETS:
        cases = {c['id']: c for c in json.load(
            open(f'benchmark/{name}_cases.json', encoding='utf-8'))['cases']}
        run = json.load(open(
            f'docs/benchmark/desktop-xlmr-{name}{args.baseline}.json', encoding='utf-8'))
        gain, cost = [], []
        for r in run['results']:
            case = cases.get(r['case']['id'])
            if case is None: continue
            rows, _ = lr.analyse(case, r['detections'])
            ms = spans(case['text'], rx)
            if not ms: continue
            # every expected entity's character ranges, for the over-redaction test
            exp_ranges = []
            for e in case['expected']:
                start = 0
                while True:
                    i = case['text'].find(e['value'], start)
                    if i < 0: break
                    exp_ranges.append((i, i + len(e['value'])))
                    start = i + 1
            for a, b, v in ms:
                if not any(a < y and x < b for x, y in exp_ranges):
                    cost.append((case['id'], v))
            for e, status, visible in rows:
                if e.get('sub') == 'reference' or lr.visible_by_default(e): continue
                if status not in ('leaked', 'partial'): continue
                if lr.is_residue(e['value'], status, visible): continue
                start = 0
                covered = False
                while True:
                    i = case['text'].find(e['value'], start)
                    if i < 0: break
                    if any(a <= i and i + len(e['value']) <= b for a, b, _ in ms): covered = True
                    start = i + 1
                if covered: gain.append((case['id'], e['type'], e['value']))
        print(f"{name:10} 收益 {len(gain):3}   误伤 {len(cost):3}")
        if gain: print('   收益 →', ', '.join(sorted({v for _, _, v in gain}))[:300])
        if cost: print('   误伤 →', ', '.join(sorted({v for _, v in cost}))[:300])

    neg = json.load(open('benchmark/hard_negatives.json', encoding='utf-8'))
    ncases = neg['cases'] if isinstance(neg, dict) else neg
    nf = [(c['id'], m[2]) for c in ncases for m in spans(c.get('text', ''), rx)]
    print(f"{'negatives':10} 误报 {len(nf):3}" + ('   → ' + ', '.join(f'{i}:{v}' for i, v in nf[:8]) if nf else ''))


if __name__ == '__main__':
    main()
