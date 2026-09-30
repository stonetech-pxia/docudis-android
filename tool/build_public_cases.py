"""Assembles benchmark/public_cases.json from the fetched public documents and
their annotation files, validating every label.

    python tool/build_public_cases.py [--set consumer] [--check <doc-id> ...]

--set consumer reads benchmark/consumer/ (written consumer documents) and writes
benchmark/consumer_cases.json; the default is the public-record set.

Inputs:  benchmark/public/index.json, benchmark/public/raw/<id>.txt,
         benchmark/public/labels/<id>.json  ({"id": ..., "expected": [{"value", "type", "sub"?}]})
A label is valid when its type is known, its value is an exact substring of the
document, has no line break and is not duplicated. With --check only the named
documents are validated and nothing is written.
"""
import argparse
import json
import os
import sys

TYPES = {'PERSON', 'COMPANY', 'ADDRESS', 'PHONE', 'EMAIL', 'ID', 'IBAN', 'CARD', 'DATE', 'BIRTH_DATE', 'AMOUNT', 'URL', 'IP'}
ROOT = 'benchmark/public'
DESCRIPTIONS = {
    'public': 'Real public-record documents (BODACC, BORME, The Gazette, Enron corpus) with hand-checked labels. '
              'Fetched by tool/fetch_public_samples.py, assembled by tool/build_public_cases.py. '
              'Addresses are labelled as written, one value per contiguous address.',
    'consumer': 'Written consumer documents (letters, invoices, payslips, medical, leases, bank and insurance letters, CVs, '
                'support e-mails, chat messages) in English, French and Spanish; every person and number is invented. '
                'Frozen test set, never used for training. Assembled by tool/build_public_cases.py --set consumer.',
    'regression': 'Held-out regression set (frozen 2026-09-21): 30 fresh consumer documents in the same ten categories as '
                  'the consumer set, plus 18 documents that are about a thing rather than a person (terms, catalogues, '
                  'policies, manuals, job ads, public notices) which carry many codes and titles but almost no personal data. '
                  'Written after the fine-tune and the 2026-09-21 rules shipped, to measure regressions on documents no rule '
                  'was ever written against. Assembled by tool/build_public_cases.py --set regression.',
}


def load(doc_id):
    text = open(os.path.join(ROOT, 'raw', doc_id + '.txt'), encoding='utf-8').read().rstrip('\n')
    path = os.path.join(ROOT, 'labels', doc_id + '.json')
    if not os.path.exists(path):
        return text, None, [f'{doc_id}: no label file']
    labels = json.load(open(path, encoding='utf-8'))['expected']
    errors, seen = [], set()
    for e in labels:
        v, t = e.get('value', ''), e.get('type')
        if t not in TYPES:
            errors.append(f'{doc_id}: unknown type {t!r} for {v!r}')
        if not v or v != v.strip() or '\n' in v:
            errors.append(f'{doc_id}: empty, untrimmed or multi-line value {v!r}')
        elif v not in text:
            errors.append(f'{doc_id}: value not found in text: {v!r}')
        if (v, t) in seen:
            errors.append(f'{doc_id}: duplicate {v!r} {t}')
        seen.add((v, t))
    return text, labels, errors


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--check', nargs='*')
    ap.add_argument('--set', choices=sorted(DESCRIPTIONS), default='public')
    args = ap.parse_args()
    global ROOT
    ROOT = f'benchmark/{args.set}'
    index = json.load(open(os.path.join(ROOT, 'index.json'), encoding='utf-8'))
    ids = args.check if args.check else [d['id'] for d in index]
    meta = {d['id']: d for d in index}
    cases, problems = [], []
    for doc_id in ids:
        text, labels, errors = load(doc_id)
        problems += errors
        if labels is not None and not errors:
            m = meta[doc_id]
            cases.append({'id': doc_id, 'lang': m['lang'], 'category': m['category'], 'source': m['source'], 'url': m.get('url', ''),
                          'text': text, 'expected': labels})
    for p in problems:
        print('ERROR', p)
    print(f'{len(cases)} valid of {len(ids)} documents, {sum(len(c["expected"]) for c in cases)} labels, {len(problems)} problems')
    if args.check is not None and args.check != []:
        sys.exit(1 if problems else 0)
    if not problems:
        doc = {'version': 1, 'description': DESCRIPTIONS[args.set], 'cases': cases}
        out = f'benchmark/{args.set}_cases.json'
        json.dump(doc, open(out, 'w', encoding='utf-8', newline='\n'), ensure_ascii=False, indent=1)
        print('written', out)
    else:
        sys.exit(1)


if __name__ == '__main__':
    main()
