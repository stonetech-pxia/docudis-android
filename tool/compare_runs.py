"""Diffs two benchmark run files entity by entity, to find regressions.

    python tool/compare_runs.py <before.json> <after.json> [--out report.md]

Both files are written by packages/docudis_engine/benchmark/run_benchmark.dart on the same
dataset. Every expected entity gets a status in each run — hit, partial (only part of it is
hidden), wrong type, missed — and the diff lists the ones whose status got worse, the ones that
got better, and the detections that touch no expected entity (over-redaction) that each run has
and the other does not.

Written for the A/B of the 2026-09-21 shipping configuration against the pre-fine-tune engine.
"""
import argparse
import json
import sys

RANK = {'hit': 0, 'type': 1, 'partial': 2, 'missed': 3}  # higher is worse


def statuses(result):
    """{(value, type): status} for every expected entity of one document."""
    out = {}
    for kind, key in (('hit', 'hits'), ('partial', 'partialHits'), ('type', 'typeMismatches'), ('missed', 'misses')):
        for e in result.get(key, []):
            out[(e['value'], e['type'])] = kind
    for e in result['case']['expected']:
        out.setdefault((e['value'], e['type']), 'missed')
    return out


def over_redactions(result):
    """Detections that hit no expected entity, as {(value, type): detector}."""
    return {(d['value'], d['type']): d.get('detector', '') for d in result.get('falsePositives', [])}


def totals(runs):
    n = {k: 0 for k in RANK}
    n['over'] = 0
    for r in runs.values():
        for s in statuses(r).values():
            n[s] += 1
        n['over'] += len(over_redactions(r))
    return n


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('before')
    ap.add_argument('after')
    ap.add_argument('--out')
    args = ap.parse_args()

    before = {r['case']['id']: r for r in json.load(open(args.before, encoding='utf-8'))['results']}
    after = {r['case']['id']: r for r in json.load(open(args.after, encoding='utf-8'))['results']}
    shared = [i for i in before if i in after]
    if len(shared) != len(before) or len(shared) != len(after):
        print(f'WARNING: {len(before)} documents before, {len(after)} after, {len(shared)} in common', file=sys.stderr)

    worse, better, over_new, over_gone = [], [], [], []
    for doc_id in shared:
        b, a = statuses(before[doc_id]), statuses(after[doc_id])
        for key in sorted(set(b) | set(a)):
            sb, sa = b.get(key, 'missed'), a.get(key, 'missed')
            if RANK[sa] > RANK[sb]:
                worse.append((doc_id, key, sb, sa))
            elif RANK[sa] < RANK[sb]:
                better.append((doc_id, key, sb, sa))
        ob, oa = over_redactions(before[doc_id]), over_redactions(after[doc_id])
        over_new += [(doc_id, k, oa[k]) for k in sorted(oa) if k not in ob]
        over_gone += [(doc_id, k, ob[k]) for k in sorted(ob) if k not in oa]

    tb, ta = totals({i: before[i] for i in shared}), totals({i: after[i] for i in shared})
    lines = [f'# Run diff: {args.before} → {args.after}', '',
             f'{len(shared)} documents, {sum(tb[k] for k in RANK)} expected entities.', '',
             '| | hit | wrong type | partial | missed | over-redaction |', '|---|---|---|---|---|---|',
             f'| before | {tb["hit"]} | {tb["type"]} | {tb["partial"]} | {tb["missed"]} | {tb["over"]} |',
             f'| after | {ta["hit"]} | {ta["type"]} | {ta["partial"]} | {ta["missed"]} | {ta["over"]} |', '',
             f'**{len(worse)} entities got worse, {len(better)} got better; '
             f'{len(over_new)} new over-redactions, {len(over_gone)} gone.**', '']

    def table(title, rows, cols):
        lines.append(f'## {title} ({len(rows)})')
        lines.append('')
        if not rows:
            lines.append('None.')
            lines.append('')
            return
        lines.append('| ' + ' | '.join(cols) + ' |')
        lines.append('|' + '---|' * len(cols))
        for row in rows:
            lines.append('| ' + ' | '.join(str(c).replace('|', r'\|') for c in row) + ' |')
        lines.append('')

    table('Worse', [(d, f'`{v}`', t, sb, sa) for d, (v, t), sb, sa in worse],
          ['document', 'value', 'type', 'before', 'after'])
    table('New over-redaction', [(d, f'`{v}`', t, det) for d, (v, t), det in over_new],
          ['document', 'value', 'detected as', 'detector'])
    table('Better', [(d, f'`{v}`', t, sb, sa) for d, (v, t), sb, sa in better],
          ['document', 'value', 'type', 'before', 'after'])
    table('Over-redaction gone', [(d, f'`{v}`', t, det) for d, (v, t), det in over_gone],
          ['document', 'value', 'detected as', 'detector'])

    text = '\n'.join(lines)
    if args.out:
        open(args.out, 'w', encoding='utf-8', newline='\n').write(text + '\n')
        print('written', args.out)
    print('\n'.join(lines[:12]))


if __name__ == '__main__':
    main()
