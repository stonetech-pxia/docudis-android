"""Leak-rate report for a benchmark run: is every sensitive span hidden?

    python tool/leak_report.py <dataset.json> <run.json> [--out report.md] [--examples 12]

The benchmark's F1 compares spans one to one, so an address detected as two
spans, or a company hidden under an ADDRESS placeholder, looks like an error
although nothing leaks. This report asks the question that matters for
anonymization: for every expected entity, are all its characters covered by
some detection (of any type)?

  hidden   every occurrence fully covered
  partial  some characters of some occurrence left visible
  leaked   at least one occurrence with no coverage at all

Whitespace and punctuation inside a value do not need to be covered. Latin
values are matched on word boundaries so "tom" does not match inside "bottom".
Over-redaction is reported as detections that touch no expected entity.
Entities marked "sub": "reference" (document reference numbers) are counted
separately: the rule packs deliberately do not catch most of them yet.

A leak is *residue* when what stays visible could not identify anyone on its own:
only short numbers (up to four digits; five, a postcode, next to a hidden part),
unit designators ("2R", "12B"), single initials, two-letter state codes and unit or
legal-form words ("2", "Suite 060", "S ████████", "███████, GA 30317", "Ltd").
Everything else is an *identifying* leak. Both count in the leak rate; the
split is reported separately, per language and per document.

Only enabled detections hide anything. Amounts and dates other than dates of
birth (BIRTH_DATE) are detected but switched off by default, so they are
counted separately too: for them the report says how many the user could
switch on (covered by any detection, enabled or not).
"""
import argparse
import collections
import json
import re
import sys

CJK = re.compile('[㐀-鿿]')
ID_FAMILY = {'ID', 'NUMBER', 'CARD', 'IBAN', 'OTHER'}
RESIDUE_WORDS = set('apt apartment ste box po bp appartement appt suite ste unit flat floor étage etage bât bat bâtiment porte piso pta puerta planta '
                    'esc escalera bajo izda dcha nº no n lot lote ltd limited llc llp inc plc co sa sas sarl eurl sci sl slu slp'.split())


def occurrences(text, value):
    if CJK.search(value):
        pattern = re.escape(value)
    else:
        pattern = r'(?<![^\W_])' + re.escape(value) + r'(?![^\W_])'
    return [(m.start(), m.end()) for m in re.finditer(pattern, text)]


def same_family(detected, expected):
    """NUMBER claims no kind, so it is never the wrong type."""
    return (detected == expected or detected == 'NUMBER'
            or (detected in ID_FAMILY and expected in ID_FAMILY))


def is_residue(value, status, visible):
    shown = value if status == 'leaked' else visible
    tokens = re.findall(r'[^\W_█]+', shown)
    digits = 4 if status == 'leaked' else 5

    def harmless(t):
        return (t.isdigit() and len(t) <= digits or len(t) == 1 or len(t) == 2 and t.isupper()
                or len(t) <= 3 and any(c.isdigit() for c in t) or t.lower() in RESIDUE_WORDS)
    return all(harmless(t) for t in tokens)


def visible_by_default(e):
    return e['type'] in ('AMOUNT', 'DATE')


def analyse(case, detections):
    text = case['text']
    hidden_at = [False] * len(text)  # under an enabled detection
    detected_at = [False] * len(text)  # under any detection
    for d in detections:
        for i in range(d['start'], min(d['end'], len(text))):
            detected_at[i] = True
            hidden_at[i] = hidden_at[i] or d.get('enabled', True)
    touched = set()
    rows = []
    for e in case['expected']:
        occ = occurrences(text, e['value'])
        if not occ:
            rows.append((e, 'unlocated', ''))
            continue
        worst, visible, wrong_type = 'hidden', '', True
        covered = detected_at if visible_by_default(e) else hidden_at
        for s, t in occ:
            need = [i for i in range(s, t) if text[i].isalnum()]
            got = [i for i in need if covered[i]]
            for k, d in enumerate(detections):
                if d['start'] < t and d['end'] > s:
                    touched.add(k)
                    if same_family(d['type'], e['type']):
                        wrong_type = False
            if not got:
                worst = 'leaked'
                visible = visible or text[s:t]
            elif len(got) < len(need) and worst != 'leaked':
                worst = 'partial'
                visible = visible or ''.join(text[i] if not covered[i] else '█' for i in range(s, t))
        rows.append((e, worst if worst != 'hidden' or not wrong_type else 'hidden-wrong-type', visible))
    extras = [d for k, d in enumerate(detections) if k not in touched and d.get('enabled', True)]
    return rows, extras


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('dataset')
    ap.add_argument('run')
    ap.add_argument('--out')
    ap.add_argument('--examples', type=int, default=12)
    args = ap.parse_args()
    cases = {c['id']: c for c in json.load(open(args.dataset, encoding='utf-8'))['cases']}
    run = json.load(open(args.run, encoding='utf-8'))

    by = {k: collections.defaultdict(collections.Counter) for k in ('lang', 'category', 'type')}
    total, refs = collections.Counter(), collections.Counter()
    optional = collections.defaultdict(collections.Counter)
    generic = collections.Counter()
    clean_docs = collections.Counter()
    no_identifying = collections.Counter()
    tiers = collections.defaultdict(collections.Counter)
    docs = collections.Counter()
    leaks, partials, extras_all = [], [], []
    for r in run['results']:
        case = cases.get(r['case']['id'])
        if case is None:
            continue
        rows, extras = analyse(case, r['detections'])
        for d in r['detections']:
            if d['type'] == 'NUMBER':
                generic[d['detector']] += 1
        docs[case['lang']] += 1
        doc_leaks = doc_identifying = 0
        for e, status, visible in rows:
            if e.get('sub') == 'reference':
                refs[status] += 1
                continue
            if visible_by_default(e):
                optional[e['type']][status] += 1
                continue
            total[status] += 1
            by['lang'][case['lang']][status] += 1
            by['category'][case['category']][status] += 1
            by['type'][e['type']][status] += 1
            tiers[case['lang']]['entities'] += status != 'unlocated'
            if status in ('leaked', 'partial'):
                residue = is_residue(e['value'], status, visible)
                tiers[case['lang']]['residue' if residue else 'identifying'] += 1
                doc_identifying += not residue
            if status == 'leaked':
                doc_leaks += 1
                leaks.append((case['id'], e['type'], e['value']))
            elif status == 'partial':
                doc_leaks += 1
                partials.append((case['id'], e['type'], e['value'], visible))
        if doc_leaks == 0:
            clean_docs[case['lang']] += 1
        if doc_identifying == 0:
            no_identifying[case['lang']] += 1
        extras_all += [(case['id'], d['type'], d['value'].replace('\n', '⏎'), d['detector']) for d in extras]

    def line(name, c):
        n = sum(c[k] for k in ('hidden', 'hidden-wrong-type', 'partial', 'leaked'))
        if not n:
            return None
        hidden = c['hidden'] + c['hidden-wrong-type']
        return f"| {name} | {n} | {hidden} | {c['hidden-wrong-type']} | {c['partial']} | {c['leaked']} | {100 * (c['partial'] + c['leaked']) / n:.1f}% |"

    out = [f"# Leak report: {run.get('modelName', '')}", '',
           f"Dataset: `{args.dataset}`, {sum(docs.values())} documents.", '',
           'An entity is *hidden* when every alphanumeric character of every occurrence is covered by some detection, '
           'of any type. *Wrong type* is hidden under another placeholder type (no leak). *Partial* and *leaked* both expose text.', '',
           '| | Entities | Hidden | of which wrong type | Partial | Leaked | Leak rate |', '|---|---|---|---|---|---|---|',
           line('**All**', total)]
    for key, title in (('lang', 'By language'), ('category', 'By document type'), ('type', 'By entity type')):
        out += ['', f'## {title}', '', '| | Entities | Hidden | of which wrong type | Partial | Leaked | Leak rate |', '|---|---|---|---|---|---|---|']
        out += [l for l in (line(k, v) for k, v in sorted(by[key].items())) if l]
    out += ['', '## Documents with no leak at all', '',
            '| Language | Documents | Fully clean | Share | No identifying leak | Share |', '|---|---|---|---|---|---|']
    for lang in sorted(docs) + ['**All**']:
        n, clean, safe = ((docs[lang], clean_docs[lang], no_identifying[lang]) if lang in docs else
                          (sum(docs.values()), sum(clean_docs.values()), sum(no_identifying.values())))
        out.append(f'| {lang} | {n} | {clean} | {100 * clean / n:.0f}% | {safe} | {100 * safe / n:.0f}% |')
    out += ['', '## Identifying leaks and residue', '',
            'Residue: what stays visible is only short numbers, unit designators, single initials, state codes and unit or legal-form words.', '',
            '| Language | Entities | Identifying | Residue | Identifying leak rate |', '|---|---|---|---|---|']
    for lang in sorted(tiers):
        c = tiers[lang]
        out.append(f"| {lang} | {c['entities']} | {c['identifying']} | {c['residue']} | {100 * c['identifying'] / c['entities']:.1f}% |")
    if sum(refs.values()):
        n = sum(refs.values())
        out += ['', '## Reference numbers (counted separately)', '',
                f"{n} invoice, contract, policy and file numbers: {refs['hidden'] + refs['hidden-wrong-type']} hidden, "
                f"{refs['partial']} partial, {refs['leaked']} leaked."]
    if optional:
        out += ['', '## Left visible by default (counted separately)', '',
                'Amounts and dates other than dates of birth are detected but switched off. '
                '*Detected* means the user can switch them on.', '',
                '| | Entities | Detected | Partly detected | Not detected |', '|---|---|---|---|---|']
        for t, c in sorted(optional.items()):
            out.append(f"| {t} | {sum(c.values()) - c['unlocated']} | {c['hidden'] + c['hidden-wrong-type']} | {c['partial']} | {c['leaked']} |")
    if generic:
        out += ['', f'## NUMBER placeholders: {sum(generic.values())}', '',
                'Digit strings matched by a loose rule, hidden under the generic type instead of a guessed one.', '']
        out += [f'- {n}× {det}' for det, n in generic.most_common()]
    out += ['', f'## Over-redaction: {len(extras_all)} detections that touch no expected entity', '']
    for (t, v, det), n in collections.Counter((t, v, det) for _, t, v, det in extras_all).most_common(args.examples * 2):
        out.append(f'- {n}× `{v}` as {t} ({det})')
    out += ['', f'## Leaked ({len(leaks)})', '']
    for (t, v), n in collections.Counter((t, v) for _, t, v in leaks).most_common(args.examples * 4):
        ids = sorted({i for i, tt, vv in leaks if (tt, vv) == (t, v)})
        out.append(f"- {t} `{v}` ({', '.join(ids[:3])}{'…' if len(ids) > 3 else ''})")
    out += ['', f'## Partially visible ({len(partials)})', '']
    for cid, t, v, visible in partials[:args.examples * 4]:
        out.append(f'- {t} `{v}` → `{visible}` ({cid})')
    report = '\n'.join(x for x in out if x is not None) + '\n'
    if args.out:
        open(args.out, 'w', encoding='utf-8', newline='\n').write(report)
    sys.stdout.write(report)


if __name__ == '__main__':
    main()
