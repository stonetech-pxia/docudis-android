"""Fetches real public-record documents for the real-document NER test set.

    python tool/fetch_public_samples.py [--out benchmark/public]

Sources (all public records, real entities):
  fr  BODACC   French commercial announcements (open data API, Licence Ouverte 2.0),
               rendered from the structured record into announcement text.
  es  BORME    Spanish company registry gazette (boe.es, PDF -> pdftotext),
               a few consecutive registry acts per document.
  en  Gazette  UK corporate insolvency notices (thegazette.co.uk, Open Government Licence).
               Personal insolvency notices are deliberately not used.
  en  Enron    Enron e-mail corpus released by FERC (Hugging Face mirror corbt/enron-emails),
               original casing, forwarded chains and recipient lists included.

Writes <out>/raw/<id>.txt and <out>/index.json (id, lang, category, source, url).
Needs `pdftotext` on PATH for BORME. Annotation is a separate step.
"""
import argparse
import html
import json
import os
import re
import subprocess
import tempfile

import requests

H = {'User-Agent': 'docudis-testset-builder/1.0'}


def strip_tags(x):
    x = re.sub(r'<(script|style)[\s\S]*?</\1>', ' ', x)
    x = re.sub(r'<br\s*/?>|</p>|</div>|</tr>|</dd>|</dt>|</h\d>|</li>', '\n', x, flags=re.I)
    x = html.unescape(re.sub(r'<[^>]+>', ' ', x))
    x = re.sub(r'[ \t]+', ' ', x)
    x = re.sub(r' *\n *', '\n', x)
    x = re.sub(r' ([,.;:)])', r'\1', x)
    return re.sub(r'\n{2,}', '\n', x).strip()


# ---------------------------------------------------------------- BODACC (fr)

def fr_date(iso):
    m = re.fullmatch(r'(\d{4})-(\d{2})-(\d{2})', iso or '')
    return f'{m.group(3)}/{m.group(2)}/{m.group(1)}' if m else (iso or '')


def address_lines(a):
    street = ' '.join(x for x in [a.get('numeroVoie'), a.get('typeVoie'), a.get('nomVoie')] if x)
    city = ' '.join(x for x in [a.get('codePostal'), a.get('ville')] if x)
    return ', '.join(x for x in [a.get('complGeographique'), street, a.get('BP'), city, a.get('pays')] if x)


def as_list(x):
    return x if isinstance(x, list) else [x] if x else []


def render_person(p, out, label=None):
    if label:
        out.append(label)
    imm = p.get('numeroImmatriculation') or {}
    if imm.get('numeroIdentification'):
        out.append(f"{imm.get('codeRCS', 'RCS')} {imm.get('nomGreffeImmat', '')} {imm['numeroIdentification']}".replace('  ', ' '))
    elif p.get('nonInscrit'):
        out.append('Non inscrit au RCS')
    if p.get('denomination'):
        out.append(p['denomination'])
    if p.get('nom') or p.get('prenom'):
        name = ' '.join(x for x in [p.get('nom'), p.get('prenom')] if x)
        if p.get('nomUsage'):
            name += f" (nom d'usage : {p['nomUsage']})"
        out.append(name)
    for key, lab in [('sigle', 'Sigle'), ('nomCommercial', 'Nom commercial'), ('formeJuridique', 'Forme juridique'),
                     ('nationalite', 'Nationalité'), ('activite', 'Activité'), ('administration', 'Administration')]:
        if p.get(key):
            out.append(f'{lab} : {p[key]}')
    cap = p.get('capital') or {}
    if cap.get('montantCapital'):
        out.append(f"Capital : {cap['montantCapital']} {cap.get('devise', '')}".strip())
    for key, lab in [('adresseSiegeSocial', 'Siège social'), ('adresse', 'Adresse'), ('adressePP', 'Adresse')]:
        a = p.get(key)
        if isinstance(a, dict):
            a = a.get('france') or a.get('etranger') or a
            out.append(f'{lab} : {address_lines(a)}')


def render_bodacc(rec):
    out = [f"BODACC {rec.get('publicationavis', '')} n° {rec.get('parution', '')} du {fr_date(rec.get('dateparution'))} - Annonce n° {rec.get('numeroannonce')}",
           f"{rec.get('familleavis_lib', '')} - {rec.get('typeavis_lib', '')}", rec.get('tribunal', ''), '']
    for p in as_list(json.loads(rec['listepersonnes']).get('personne')) if rec.get('listepersonnes') else []:
        render_person(p, out)
        out.append('')
    for e in as_list(json.loads(rec['listeetablissements']).get('etablissement')) if rec.get('listeetablissements') else []:
        out.append('Établissement' + (f" ({e['qualiteEtablissement']})" if e.get('qualiteEtablissement') else '') + ' :')
        for key, lab in [('origineFonds', 'Origine du fonds'), ('enseigne', 'Enseigne'), ('activite', 'Activité')]:
            if e.get(key):
                out.append(f'{lab} : {e[key]}')
        if isinstance(e.get('adresse'), dict):
            out.append(f"Adresse : {address_lines(e['adresse'].get('france') or e['adresse'])}")
        out.append('')
    for key, lab in [('listeprecedentproprietaire', 'Précédent propriétaire :'), ('listeprecedentexploitant', 'Précédent exploitant :')]:
        if rec.get(key):
            for p in as_list(json.loads(rec[key]).get('personne')):
                render_person(p, out, lab)
            out.append('')
    if rec.get('acte'):
        acte = json.loads(rec['acte'])
        for key, lab in [('descriptif', 'Descriptif'), ('dateImmatriculation', "Date d'immatriculation"),
                         ('dateCommencementActivite', "Date de commencement d'activité"), ('dateEffet', "Date d'effet")]:
            if acte.get(key):
                out.append(f'{lab} : {fr_date(acte[key]) if key.startswith("date") else acte[key]}')
        for block in ('vente', 'creation', 'immatriculation'):
            b = acte.get(block) or {}
            for v in b.values():
                if isinstance(v, str):
                    out.append(v)
                elif isinstance(v, dict):
                    out.append(' - '.join(fr_date(x) if re.fullmatch(r'\d{4}-\d{2}-\d{2}', str(x)) else str(x) for x in v.values()))
    if rec.get('jugement'):
        j = json.loads(rec['jugement'])
        out.append(f"{j.get('nature', 'Jugement')} du {fr_date(j.get('date'))}")
        if j.get('complementJugement'):
            out.append(j['complementJugement'])
    if rec.get('modificationsgenerales'):
        m = json.loads(rec['modificationsgenerales'])
        for v in m.values():
            if isinstance(v, str):
                out.append(v)
    return re.sub(r'\n{3,}', '\n\n', '\n'.join(x for x in out if x is not None)).strip()


def fetch_bodacc():
    docs = []
    plan = [('creation', 4), ('vente', 4), ('collective', 4), ('modification', 3)]
    for family, count in plan:
        r = requests.get('https://bodacc-datadila.opendatasoft.com/api/explore/v2.1/catalog/datasets/annonces-commerciales/records',
                         params={'limit': count * 3, 'offset': 40, 'order_by': 'dateparution desc', 'where': f'familleavis="{family}"'},
                         headers=H, timeout=60)
        r.raise_for_status()
        kept = 0
        for rec in r.json()['results']:
            text = render_bodacc(rec)
            if len(text) < 350 or kept >= count:
                continue
            kept += 1
            docs.append({'id': f'fr-bodacc-{family}-{kept:02d}', 'lang': 'fr', 'category': 'registry',
                         'source': 'BODACC', 'url': rec.get('url_complete'), 'text': text})
    return docs


# ----------------------------------------------------------------- BORME (es)

def fetch_borme():
    r = requests.get('https://www.boe.es/datosabiertos/api/borme/sumario/20240912',
                     headers={**H, 'Accept': 'application/json'}, timeout=60)
    r.raise_for_status()
    items = re.findall(r'"titulo":\s*"([^"]+)"[^{}]*?"texto":\s*"(https:[^"]+?BORME-A-[^"]+?\.pdf)"', r.text.replace('\\/', '/'))
    if not items:
        urls = re.findall(r'https://www\.boe\.es/borme/dias/[^"]+?BORME-A-[^"]+?\.pdf', r.text.replace('\\/', '/'))
        items = [(u.rsplit('-', 1)[1][:2], u) for u in urls]
    wanted = ['MADRID', 'BARCELONA', 'VALENCIA', 'SEVILLA', 'BIZKAIA', 'MÁLAGA', 'ZARAGOZA', 'ALICANTE']
    chosen = [i for w in wanted for i in items if w in i[0].upper()][:5] or items[:5]
    docs = []
    for n, (title, url) in enumerate(chosen, 1):
        pdf = requests.get(url, headers=H, timeout=60).content
        with tempfile.TemporaryDirectory() as tmp:
            path = os.path.join(tmp, 'b.pdf')
            open(path, 'wb').write(pdf)
            text = subprocess.run(['pdftotext', '-enc', 'UTF-8', '-l', '3', path, '-'], capture_output=True).stdout.decode('utf-8', 'replace')
        lines = [l for l in text.splitlines()
                 if l.strip() and not re.search(r'^cve:|Verificable en|BOLET[ÍI]N OFICIAL DEL REGISTRO|^N[úu]m\. \d+|^P[áa]g\. \d+|^https?://|D\.L\.:|ISSN', l.strip())]
        body = '\n'.join(lines)
        acts = re.split(r'\n(?=\d{5,6} - )', body)
        acts = [a.strip() for a in acts if re.match(r'\d{5,6} - ', a.strip())]
        for g in range(3):
            group = acts[g * 6:(g + 1) * 6]
            if len(group) < 3:
                break
            docs.append({'id': f'es-borme-{n:02d}-{g + 1}', 'lang': 'es', 'category': 'registry', 'source': 'BORME', 'url': url,
                         'text': f'BOLETÍN OFICIAL DEL REGISTRO MERCANTIL\nJueves 12 de septiembre de 2024\nActos inscritos\n\n' + '\n\n'.join(group)})
    return docs


# --------------------------------------------------------------- Gazette (en)

def fetch_gazette():
    docs, companies = [], set()
    for code in ['2443', '2441', '2410', '2442', '2445']:
        r = requests.get('https://www.thegazette.co.uk/insolvency/notice/data.json',
                         params={'noticetypes': code, 'results-page-size': 12}, headers=H, timeout=60)
        if r.status_code != 200:
            continue
        taken = 0
        for e in r.json().get('entry', []):
            title = e.get('title', '')
            if title in companies or taken >= 2 or len(docs) >= 8:
                continue
            nid = e['id'].rsplit('/', 1)[-1]
            page = requests.get(f'https://www.thegazette.co.uk/notice/{nid}', headers=H, timeout=60).text
            m = re.search(r'<article[\s\S]*?</article>', page)
            body = strip_tags(m.group(0) if m else '')
            body = re.sub(r'^Notice category:[\s\S]*?Notice code:\n\d+\n', '', body)
            if len(body) < 400:
                continue
            companies.add(title)
            taken += 1
            docs.append({'id': f'en-gazette-{len(docs) + 1:02d}', 'lang': 'en', 'category': 'notice', 'source': 'The Gazette',
                         'url': f'https://www.thegazette.co.uk/notice/{nid}', 'text': body})
    return docs


# ----------------------------------------------------------------- Enron (en)

def fetch_enron():
    docs, senders = [], set()
    for offset in [300, 9000, 30000, 60000, 120000, 200000, 300000, 400000, 450000, 500000]:
        r = requests.get('https://datasets-server.huggingface.co/rows',
                         params={'dataset': 'corbt/enron-emails', 'config': 'default', 'split': 'train', 'offset': offset, 'length': 60},
                         headers=H, timeout=60)
        if r.status_code != 200:
            continue
        for x in (row['row'] for row in r.json()['rows']):
            body = (x.get('body') or '').replace('\r\n', '\n').strip()
            sender = x.get('from') or ''
            names = re.findall(r'\b[A-Z][a-z]+ [A-Z][a-z]+\b', body)
            if not (500 < len(body) < 2200) or len(set(names)) < 3 or sender in senders or 'Forwarded by' in body[:80]:
                continue
            senders.add(sender)
            to = ', '.join(as_list(x.get('to'))[:6])
            header = f"From: {sender}\nTo: {to}\nDate: {str(x.get('date'))[:10]}\nSubject: {x.get('subject')}\n\n"
            docs.append({'id': f'en-enron-{len(docs) + 1:02d}', 'lang': 'en', 'category': 'email', 'source': 'Enron corpus',
                         'url': f"corbt/enron-emails:{x.get('file_name')}", 'text': header + re.sub(r'\n{3,}', '\n\n', body)})
            break
        if len(docs) >= 8:
            break
    return docs


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--out', default='benchmark/public')
    args = ap.parse_args()
    raw = os.path.join(args.out, 'raw')
    os.makedirs(raw, exist_ok=True)
    index = []
    for name, fn in [('BODACC', fetch_bodacc), ('BORME', fetch_borme), ('Gazette', fetch_gazette), ('Enron', fetch_enron)]:
        try:
            docs = fn()
        except Exception as e:  # one source failing must not lose the others
            print(f'{name}: FAILED {e!r}')
            continue
        for d in docs:
            open(os.path.join(raw, d['id'] + '.txt'), 'w', encoding='utf-8', newline='\n').write(d['text'] + '\n')
            index.append({k: v for k, v in d.items() if k != 'text'} | {'chars': len(d['text'])})
        print(f'{name}: {len(docs)} documents, {sum(len(d["text"]) for d in docs)} chars')
    json.dump(index, open(os.path.join(args.out, 'index.json'), 'w', encoding='utf-8', newline='\n'), ensure_ascii=False, indent=1)


if __name__ == '__main__':
    main()
