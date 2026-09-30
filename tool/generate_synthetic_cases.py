"""Generates synthetic documents (template + fake data) for the document types
that have no public real samples: invoice, lease, payslip, medical / insurance
letter, CV. English, French and Spanish, three instances of each.

    python tool/generate_synthetic_cases.py [--out benchmark/synthetic_cases.json] [--seed 7]

Every slot that holds an entity is recorded as an expected entity, so the gold
labels are exact. Identifiers carry valid check digits (IBAN mod-97, French NIR
key, Spanish DNI letter, NHS mod-11) because the rule packs validate them.
Reference numbers (invoice, contract, policy, employee numbers) are labelled ID
with "sub": "reference": the design doc says they should be masked, the rule
packs mostly do not catch them yet, and the report can count them separately.
Dates of birth are labelled BIRTH_DATE: they are the only dates hidden by
default.
Conventions follow benchmark/ner_cases.json: street line and "postcode city"
are separate ADDRESS entities; titles (Dr, Mme, D.) are not part of a PERSON.
"""
import argparse
import json
import random
import re
import unicodedata

EN_MONTHS = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December']
FR_MONTHS = ['janvier', 'février', 'mars', 'avril', 'mai', 'juin', 'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre']
ES_MONTHS = ['enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio', 'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre']

PEOPLE = {
    'en': ['Eleanor Whitfield', 'Marcus Oyelaran', 'Priyanka Deshmukh', 'Thomas Gallagher', 'Hannah Lindqvist', 'Darnell Whitaker',
           'Siobhan Kavanagh', 'Rajesh Venkataraman', 'Olivia Pemberton', 'Gareth Llewellyn', 'Naomi Adebayo', 'Callum Macpherson'],
    'fr': ['Camille Lefèvre', 'Julien Marchand', 'Aurélie Fontaine', 'Mathieu Girard', 'Nadia Benali', 'Étienne Rousseau',
           'Clémence Dupuis', 'Thibault Perrin', 'Yasmine Haddad', 'Bertrand Lemoine', 'Océane Morel', 'François-Xavier Delmas'],
    'es': ['María Fernández Ortiz', 'Javier Morales Peña', 'Lucía Navarro Gil', 'Alejandro Ruiz Cabrera', 'Carmen Iglesias Soto',
           'Pablo Herrero Vidal', 'Elena Domínguez Rey', 'Sergio Castaño Bravo', 'Nuria Beltrán Aguado', 'Íñigo Etxeberria Lasa',
           'Rocío Montenegro Díaz', 'Andrés Quintana Marín'],
}
COMPANIES = {
    'en': ['Harrowgate Building Supplies Ltd', 'Pennine Office Solutions Ltd', 'Calder & Finch LLP', 'Brightwater Dental Practice',
           'Northfield Insurance Group', 'Cascade Analytics Inc.', 'Holloway Property Management Ltd', 'Meridian Freight Services Ltd'],
    'fr': ['Menuiserie Berthelot SARL', 'Cabinet Vasseur & Associés', 'Transports Rhône-Alpes Logistique SAS', 'Clinique des Tilleuls',
           'Mutuelle Horizon Santé', 'Atelier Numérique Lyonnais SAS', 'Agence Immobilière du Parc', 'Boulangerie Maison Thévenet'],
    'es': ['Suministros Industriales Levante S.L.', 'Asesoría Méndez y Roldán S.L.', 'Transportes Guadalquivir S.A.', 'Clínica Dental Sonrisa Norte',
           'Seguros Atlántida Mutua', 'Innovación Digital Cantábrica S.L.', 'Inmobiliaria Puerta del Sol S.L.', 'Talleres Mecánicos Arganzuela S.L.'],
}
KNOWN_COMPANIES = {'en': ['Barclays', 'Rolls-Royce', 'Deloitte'], 'fr': ['Capgemini', 'Decathlon', 'BNP Paribas'], 'es': ['Telefónica', 'Mercadona', 'Banco Sabadell']}
SCHOOLS = {'en': ['University of Leeds', 'Manchester Metropolitan University'], 'fr': ['Université Lumière Lyon 2', 'INSA Lyon'],
           'es': ['Universidad de Salamanca', 'Universidad Politécnica de Valencia']}
ADDRESSES = {  # (street, city part)
    'en': [('14 Marlborough Road', 'Leeds', 'LS6 2QT'), ('27 Clarendon Street', 'Nottingham', 'NG1 5JD'), ('8 Orchard Close', 'Bristol', 'BS8 4TH'),
           ('112 Kingsway', 'Manchester', 'M19 1BB'), ('3 Priory Lane', 'Cambridge', 'CB4 1DT'), ('59 Albert Terrace', 'Glasgow', 'G12 8RX')],
    'us': [('2815 Hawthorne Avenue', 'Portland', 'OR 97214'), ('407 Magnolia Street', 'Austin', 'TX 78704'), ('1260 Lakeview Drive', 'Madison', 'WI 53703')],
    'fr': [('27 rue des Lilas', '69003 Lyon'), ('8 avenue Jean Jaurès', '31000 Toulouse'), ('145 boulevard Voltaire', '75011 Paris'),
           ('3 impasse des Acacias', '44300 Nantes'), ('52 rue de la République', '13002 Marseille'), ('19 chemin du Moulin', '67000 Strasbourg')],
    'es': [('Calle de Alcalá 142', '28009 Madrid'), ('Avenida de la Constitución 18', '41004 Sevilla'), ('Carrer de Mallorca 275', '08008 Barcelona'),
           ('Calle Colón 31', '46004 Valencia'), ('Paseo de Pereda 22', '39004 Santander'), ('Gran Vía 45', '48011 Bilbao')],
}
DOMAINS = {'en': ['outlook.com', 'btinternet.com', 'gmail.com'], 'fr': ['orange.fr', 'laposte.net', 'gmail.com'], 'es': ['hotmail.es', 'telefonica.net', 'gmail.com']}


def fold(s):
    """Lower-case ASCII form of a name, for e-mail addresses and profile URLs."""
    return ''.join(c for c in unicodedata.normalize('NFD', s.lower()) if unicodedata.category(c) != 'Mn')


class Doc:
    def __init__(self, rng, lang):
        self.rng, self.lang, self.expected = rng, lang, []
        self._people = rng.sample(PEOPLE[lang], len(PEOPLE[lang]))
        self._companies = rng.sample(COMPANIES[lang], len(COMPANIES[lang]))
        self._addresses = rng.sample(ADDRESSES[lang], len(ADDRESSES[lang]))
        self._day = rng.randint(20, 200)  # day-of-year cursor: dates in a document move forward
        self._year = rng.choice([2024, 2025])

    def e(self, value, type_, sub=None):
        entry = {'value': value, 'type': type_}
        if sub:
            entry['sub'] = sub
        if not any(x['value'] == value and x['type'] == type_ for x in self.expected):
            self.expected.append(entry)
        return value

    # ---- people, companies, places
    def person(self):
        return self.e(self._people.pop(), 'PERSON')

    def people(self, n):
        return [self.person() for _ in range(n)]

    def company(self, pool=None):
        return self.e(self.rng.choice(pool) if pool else self._companies.pop(), 'COMPANY')

    def address(self):
        return [self.e(part, 'ADDRESS') for part in self._addresses.pop()]

    def city(self):
        a = self.rng.choice(ADDRESSES[self.lang])
        return self.e(a[1] if self.lang == 'en' else a[1].split(' ', 1)[1], 'ADDRESS')

    def email(self, name, domain=None):
        parts = re.findall(r'[a-z]+', fold(name))
        return self.e(f'{parts[0]}.{parts[-1]}@{domain or self.rng.choice(DOMAINS[self.lang])}', 'EMAIL')

    def phone(self, mobile=False):
        r = self.rng
        if self.lang == 'en':
            v = f'07700 900{r.randint(100, 999)}' if mobile else f'020 7946 0{r.randint(100, 999)}'
        elif self.lang == 'fr':
            v = ('06' if mobile else '0' + str(r.randint(1, 5))) + ''.join(f' {r.randint(10, 99)}' for _ in range(4))
        else:
            v = f"{'6' if mobile else '9'}{r.randint(10, 99)} {r.randint(100, 999)} {r.randint(100, 999)}"
        return self.e(v, 'PHONE')

    # ---- dates and amounts
    def date(self, year=None, words=True, type_='DATE'):
        """The next date of the document's timeline (or a free date in [year])."""
        r = self.rng
        if year:
            d, m, y = r.randint(1, 28), r.randint(1, 12), year
        else:
            self._day += r.randint(3, 35)
            y = self._year + (self._day - 1) // 336
            m, d = ((self._day - 1) % 336) // 28 + 1, (self._day - 1) % 28 + 1
        if not words:
            v = f'{d:02d}/{m:02d}/{y}'
        elif self.lang == 'en':
            v = f'{d} {EN_MONTHS[m - 1]} {y}'
        elif self.lang == 'fr':
            v = f"{'1er' if d == 1 else d} {FR_MONTHS[m - 1]} {y}"
        else:
            v = f'{d} de {ES_MONTHS[m - 1]} de {y}'
        return self.e(v, type_)

    def birth(self):
        return self.date(year=self.rng.randint(1962, 1999), words=self.rng.random() < 0.5, type_='BIRTH_DATE')

    def amount(self, low, high, value=None):
        x = value if value is not None else round(self.rng.uniform(low, high), 2)
        whole, cents = f'{x:,.2f}'.split('.')
        if self.lang == 'en':
            v = f'£{whole}.{cents}'
        elif self.lang == 'fr':
            v = f"{whole.replace(',', ' ')},{cents} €"
        else:
            v = f"{whole.replace(',', '.')},{cents} €"
        self.e(v, 'AMOUNT')
        return v, x

    # ---- identifiers
    def iban(self):
        r = self.rng
        country, bban = {
            'en': ('GB', r.choice(['NWBK', 'BARC', 'LOYD', 'HBUK']) + ''.join(str(r.randint(0, 9)) for _ in range(14))),
            'fr': ('FR', ''.join(str(r.randint(0, 9)) for _ in range(23))),
            'es': ('ES', ''.join(str(r.randint(0, 9)) for _ in range(20))),
        }[self.lang]
        digits = ''.join(str(int(c, 36)) for c in bban + country + '00')
        check = 98 - int(digits) % 97
        raw = f'{country}{check:02d}{bban}'
        return self.e(' '.join(raw[i:i + 4] for i in range(0, len(raw), 4)), 'IBAN')

    def national_id(self):
        r = self.rng
        if self.lang == 'fr':  # NIR with its mod-97 key
            body = f"{r.choice('12')}{r.randint(62, 99):02d}{r.randint(1, 12):02d}{r.choice(['69', '75', '31', '13', '44'])}{r.randint(1, 989):03d}{r.randint(1, 999):03d}"
            key = 97 - int(body) % 97
            v = f'{body[0]} {body[1:3]} {body[3:5]} {body[5:7]} {body[7:10]} {body[10:13]} {key:02d}'
        elif self.lang == 'es':  # DNI with its control letter
            n = r.randint(10000000, 99999999)
            v = f"{n}{'TRWAGMYFPDXBNJZSQVHLCKE'[n % 23]}"
        else:  # UK National Insurance number
            v = f"{r.choice(['JG', 'SH', 'NP', 'KE', 'LR'])} {r.randint(10, 99)} {r.randint(10, 99)} {r.randint(10, 99)} {r.choice('ABCD')}"
        return self.e(v, 'ID')

    def nhs(self):
        while True:
            d = [self.rng.randint(0, 9) for _ in range(9)]
            check = 11 - sum(w * x for w, x in zip(range(10, 1, -1), d)) % 11
            if check == 10:
                continue
            s = ''.join(map(str, d)) + str(0 if check == 11 else check)
            return self.e(f'{s[:3]} {s[3:6]} {s[6:]}', 'ID')

    def company_id(self):
        r = self.rng
        if self.lang == 'fr':
            v = f'{r.randint(300, 899)} {r.randint(100, 999)} {r.randint(100, 999)} 000{r.randint(10, 99)}'
        elif self.lang == 'es':
            v = f"{r.choice('AB')}{r.randint(1000000, 9999999)}{r.randint(0, 9)}"
        else:
            v = f'GB{r.randint(100, 999)} {r.randint(1000, 9999)} {r.randint(10, 99)}'
        return self.e(v, 'ID')

    def ref(self, pattern):
        v = re.sub(r'#', lambda _: str(self.rng.randint(0, 9)), pattern)
        return self.e(v, 'ID', 'reference')


def invoice(d):
    seller, s_addr, buyer, b_addr = d.company(), d.address(), d.person(), d.address()
    unit1, x1 = d.amount(40, 400)
    unit2, x2 = d.amount(15, 120)
    net = round(x1 * 3 + x2, 2)
    line1, _ = d.amount(0, 0, round(x1 * 3, 2))
    rate = {'en': 0.20, 'fr': 0.20, 'es': 0.21}[d.lang]
    net_s, _ = d.amount(0, 0, net)
    vat_s, _ = d.amount(0, 0, round(net * rate, 2))
    total_s, _ = d.amount(0, 0, round(net * (1 + rate), 2))
    a, b = ', '.join(s_addr), ', '.join(b_addr)
    if d.lang == 'en':
        return f"""{seller}
{a}
VAT Reg No: {d.company_id()}   Tel: {d.phone()}   {d.email('accounts team', 'harrowgate-supplies.co.uk')}

INVOICE {d.ref('INV-2025-####')}
Invoice date: {d.date()}          Payment due: {d.date()}

Bill to:
{buyer}
{b}

Description                          Qty    Unit price    Amount
Site survey and measurement           3     {unit1}      {line1}
Delivery and handling                 1     {unit2}      {unit2}

Net total: {net_s}
VAT at 20%: {vat_s}
Total due: {total_s}

Please pay by bank transfer to {d.iban()}, quoting the invoice number.
Queries: {d.person()}, Credit Control, {d.phone()}."""
    if d.lang == 'fr':
        return f"""{seller}
{a}
SIRET : {d.company_id()} - Tél. : {d.phone()} - {d.email('comptabilite service', 'berthelot-menuiserie.fr')}

FACTURE N° {d.ref('FA-2025-####')}
Date de facturation : {d.date()}        Échéance : {d.date()}

Client :
{buyer}
{b}

Désignation                          Qté    Prix unitaire HT    Montant HT
Pose et ajustement sur mesure         3     {unit1}             {line1}
Frais de déplacement                  1     {unit2}             {unit2}

Total HT : {net_s}
TVA 20 % : {vat_s}
Total TTC : {total_s}

Règlement par virement sur le compte {d.iban()} en rappelant le numéro de facture.
Votre contact : {d.person()}, service comptabilité, {d.phone()}."""
    return f"""{seller}
{a}
CIF: {d.company_id()} - Tel.: {d.phone()} - {d.email('administracion dpto', 'suministros-levante.es')}

FACTURA N.º {d.ref('F-2025/####')}
Fecha de emisión: {d.date()}        Vencimiento: {d.date()}

Cliente:
{buyer}
{b}

Concepto                             Cant.   Precio unitario    Importe
Revisión e instalación de equipos     3      {unit1}            {line1}
Portes y embalaje                     1      {unit2}            {unit2}

Base imponible: {net_s}
IVA 21 %: {vat_s}
Total a pagar: {total_s}

Forma de pago: transferencia a la cuenta {d.iban()}, indicando el número de factura.
Persona de contacto: {d.person()}, departamento de administración, {d.phone()}."""


def lease(d):
    landlord, tenant, cotenant = d.people(3)
    l_addr, p_addr = d.address(), d.address()
    rent, _ = d.amount(650, 1900)
    deposit, _ = d.amount(1300, 3800)
    a, p = ', '.join(l_addr), ', '.join(p_addr)
    if d.lang == 'en':
        return f"""ASSURED SHORTHOLD TENANCY AGREEMENT
Reference: {d.ref('TEN/####/25')}

This agreement is made on {d.date()} between:

The Landlord: {landlord}, of {a} (telephone {d.phone(True)}, email {d.email(landlord)}),
and
The Tenants: {tenant}, born {d.birth()}, National Insurance number {d.national_id()}, and {cotenant}, born {d.birth()}.

1. The Property. The Landlord lets to the Tenants the dwelling at {p} for a term of twelve months beginning on {d.date()}.
2. Rent. The rent is {rent} per calendar month, payable in advance by standing order to account {d.iban()}.
3. Deposit. A deposit of {deposit} is payable on signature and will be protected in an authorised scheme within thirty days.
4. Managing agent. The Property is managed by {d.company()}; repairs should be reported to {d.person()} on {d.phone()}.

Signed at {d.city()} by the parties named above."""
    if d.lang == 'fr':
        return f"""CONTRAT DE LOCATION - LOGEMENT VIDE
Référence du dossier : {d.ref('LOC-2025-####')}

Entre les soussignés :

Le bailleur : {landlord}, demeurant {a}, téléphone {d.phone(True)}, courriel {d.email(landlord)},
et
Les locataires : {tenant}, née le {d.birth()}, numéro de sécurité sociale {d.national_id()}, et {cotenant}, né le {d.birth()}.

Article 1 - Désignation. Le bailleur loue aux locataires le logement situé {p}, pour une durée de trois ans à compter du {d.date()}.
Article 2 - Loyer. Le loyer mensuel est fixé à {rent}, payable d'avance par virement sur le compte {d.iban()}.
Article 3 - Dépôt de garantie. Un dépôt de garantie de {deposit} est versé à la signature du présent contrat.
Article 4 - Gestion. Le bien est géré par {d.company()} ; toute demande d'intervention est à adresser à {d.person()} au {d.phone()}.

Fait à {d.city()}, le {d.date()}, en deux exemplaires originaux."""
    return f"""CONTRATO DE ARRENDAMIENTO DE VIVIENDA
Expediente: {d.ref('ARR-2025-####')}

En {d.city()}, a {d.date()}, reunidos:

De una parte, D. {landlord}, con DNI {d.national_id()} y domicilio en {a}, teléfono {d.phone(True)}, correo {d.email(landlord)}, como arrendador;
y de otra, D.ª {tenant}, nacida el {d.birth()}, con DNI {d.national_id()}, y D. {cotenant}, nacido el {d.birth()}, como arrendatarios.

Primera. Objeto. El arrendador cede en arrendamiento la vivienda sita en {p}, por un plazo de cinco años a contar desde el {d.date()}.
Segunda. Renta. La renta mensual se fija en {rent}, pagadera por adelantado mediante transferencia a la cuenta {d.iban()}.
Tercera. Fianza. Los arrendatarios entregan en este acto una fianza de {deposit}.
Cuarta. Administración. La finca es administrada por {d.company()}; las incidencias se comunicarán a {d.person()} en el {d.phone()}.

Y en prueba de conformidad, firman el presente contrato por duplicado."""


def payslip(d):
    employer, e_addr, worker, w_addr = d.company(), d.address(), d.person(), d.address()
    gross, g = d.amount(2200, 4800)
    ded, x = d.amount(0, 0, round(g * 0.22, 2))
    net, _ = d.amount(0, 0, round(g - x, 2))
    a, w = ', '.join(e_addr), ', '.join(w_addr)
    if d.lang == 'en':
        return f"""{employer}
{a}
PAYE reference: {d.ref('###/AB#####')}

PAYSLIP
Employee: {worker}                 Employee No: {d.ref('E-#####')}
Address: {w}
NI number: {d.national_id()}       Tax code: 1257L
Pay period: {d.date(words=False)} to {d.date(words=False)}      Pay date: {d.date()}

Basic salary            {gross}
Income tax and NI       {ded}
NET PAY                 {net}

Paid by BACS to account {d.iban()}.
Payroll queries: {d.person()}, HR, {d.phone()}, {d.email('payroll team', 'pennine-office.co.uk')}"""
    if d.lang == 'fr':
        return f"""BULLETIN DE PAIE
Employeur : {employer}
{a}
SIRET : {d.company_id()}    Code NAF : 4332A

Salarié : {worker}                 Matricule : {d.ref('M-#####')}
Adresse : {w}
N° de sécurité sociale : {d.national_id()}
Emploi : technicien confirmé        Date d'entrée : {d.date()}
Période du {d.date(words=False)} au {d.date(words=False)}      Paiement le {d.date()}

Salaire de base                 {gross}
Cotisations salariales          {ded}
NET À PAYER                     {net}

Virement sur le compte {d.iban()}.
Pour toute question : {d.person()}, service paie, {d.phone()}, {d.email('paie service', 'rhone-alpes-logistique.fr')}"""
    return f"""NÓMINA
Empresa: {employer}
{a}
CIF: {d.company_id()}    CCC: {d.ref('28/#######/##')}

Trabajador: {worker}               N.º empleado: {d.ref('T-#####')}
Domicilio: {w}
DNI: {d.national_id()}
Categoría: oficial de primera       Antigüedad: {d.date()}
Periodo de liquidación: del {d.date(words=False)} al {d.date(words=False)}      Fecha de pago: {d.date()}

Salario base                    {gross}
Deducciones (IRPF y Seg. Social)  {ded}
LÍQUIDO A PERCIBIR              {net}

Abono por transferencia en la cuenta {d.iban()}.
Consultas: {d.person()}, recursos humanos, {d.phone()}, {d.email('nominas dpto', 'transportes-guadalquivir.es')}"""


def medical(d):
    org, o_addr, patient, p_addr, doctor = d.company(), d.address(), d.person(), d.address(), d.person()
    claim, _ = d.amount(60, 900)
    paid, _ = d.amount(30, 600)
    o, p = ', '.join(o_addr), ', '.join(p_addr)
    if d.lang == 'en':
        return f"""{org}
{o}
Tel: {d.phone()}

{d.date()}

{patient}
{p}

Our ref: {d.ref('CLM-#######')}        NHS number: {d.nhs()}        Date of birth: {d.birth()}

Dear Ms {patient.split()[-1]},

Following your consultation with Dr {doctor} on {d.date()}, we have reviewed your claim for treatment costs of {claim}. Under policy {d.ref('HP-########')} we have approved a payment of {paid}, which will be credited to the account ending in the details you provided within ten working days.

Your follow-up appointment is booked for {d.date()} at 10:40. If you cannot attend, please call {d.phone()} or write to {d.email('appointments desk', 'brightwater-dental.co.uk')}.

Yours sincerely,
{d.person()}
Patient Services"""
    if d.lang == 'fr':
        return f"""{org}
{o}
Tél. : {d.phone()}

{d.city()}, le {d.date()}

{patient}
{p}

Nos réf. : {d.ref('SIN-#######')}        N° de sécurité sociale : {d.national_id()}        Née le : {d.birth()}

Madame,

À la suite de votre consultation du {d.date()} auprès du Dr {doctor}, nous avons étudié votre demande de remboursement d'un montant de {claim}. Au titre du contrat {d.ref('MH-########')}, nous vous informons de la prise en charge de {paid}, qui sera versée sous dix jours ouvrés sur le compte {d.iban()}.

Votre prochain rendez-vous est fixé au {d.date()} à 10 h 40. En cas d'empêchement, merci d'appeler le {d.phone()} ou d'écrire à {d.email('accueil secretariat', 'clinique-tilleuls.fr')}.

Veuillez agréer, Madame, l'expression de nos salutations distinguées.
{d.person()}
Service des adhérents"""
    return f"""{org}
{o}
Tel.: {d.phone()}

{d.city()}, {d.date()}

{patient}
{p}

N/ref.: {d.ref('SIN-#######')}        DNI: {d.national_id()}        Fecha de nacimiento: {d.birth()}

Estimada señora:

Tras su consulta del {d.date()} con el Dr. {doctor}, hemos revisado su solicitud de reembolso por importe de {claim}. Con cargo a la póliza {d.ref('PS-########')}, le comunicamos la aprobación de un pago de {paid}, que se abonará en un plazo de diez días hábiles en la cuenta {d.iban()}.

Su próxima cita queda fijada para el {d.date()} a las 10:40. Si no puede acudir, llame al {d.phone()} o escriba a {d.email('citas recepcion', 'sonrisa-norte.es')}.

Atentamente,
{d.person()}
Atención al asegurado"""


def cv(d):
    me, referee = d.people(2)
    addr = d.address()
    a = ', '.join(addr)
    known = d.company(KNOWN_COMPANIES[d.lang])
    c1, c2 = d.company(), d.company()
    while c2 == c1:
        c2 = d.company()
    school = d.e(d.rng.choice(SCHOOLS[d.lang]), 'COMPANY')
    url = d.e('linkedin.com/in/' + '-'.join(re.findall(r'[a-z]+', fold(me))), 'URL')
    if d.lang == 'en':
        return f"""{me}
{a}
{d.phone(True)} | {d.email(me)} | {url}
Date of birth: {d.birth()}

PROFILE
Operations analyst with eight years of experience in logistics and financial reporting.

EXPERIENCE
Senior Operations Analyst, {known}, {d.city()} (2021 - present)
Led the migration of the monthly reporting pack and cut closing time by three days.
Operations Analyst, {c1}, {d.city()} (2017 - 2021)
Built the carrier performance dashboard used by the regional managers.
Graduate Trainee, {c2} (2016 - 2017)

EDUCATION
BSc Economics, {school}, 2016

REFERENCES
{referee}, Head of Operations, {c1}, {d.phone()}, {d.email(referee, 'meridian-freight.co.uk')}"""
    if d.lang == 'fr':
        return f"""{me}
{a}
{d.phone(True)} | {d.email(me)} | {url}
Née le {d.birth()}

PROFIL
Contrôleuse de gestion, huit ans d'expérience en logistique et en reporting financier.

EXPÉRIENCE PROFESSIONNELLE
Contrôleuse de gestion senior, {known}, {d.city()} (depuis 2021)
Pilotage de la refonte du reporting mensuel, clôture raccourcie de trois jours.
Contrôleuse de gestion, {c1}, {d.city()} (2017 - 2021)
Mise en place du tableau de bord de performance des transporteurs.
Stagiaire, {c2} (2016 - 2017)

FORMATION
Master Contrôle de gestion, {school}, 2016

RÉFÉRENCES
{referee}, directeur des opérations, {c1}, {d.phone()}, {d.email(referee, 'atelier-numerique.fr')}"""
    return f"""{me}
{a}
{d.phone(True)} | {d.email(me)} | {url}
Fecha de nacimiento: {d.birth()}

PERFIL
Analista de operaciones con ocho años de experiencia en logística e información financiera.

EXPERIENCIA
Analista sénior de operaciones, {known}, {d.city()} (2021 - actualidad)
Dirigió la renovación del informe mensual y redujo el cierre en tres días.
Analista de operaciones, {c1}, {d.city()} (2017 - 2021)
Creó el cuadro de mando de rendimiento de transportistas.
Becaria, {c2} (2016 - 2017)

FORMACIÓN
Grado en Economía, {school}, 2016

REFERENCIAS
{referee}, director de operaciones, {c1}, {d.phone()}, {d.email(referee, 'innovacion-cantabrica.es')}"""


TYPES = [('invoice', invoice), ('lease', lease), ('payslip', payslip), ('medical', medical), ('cv', cv)]


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--out', default='benchmark/synthetic_cases.json')
    ap.add_argument('--seed', type=int, default=7)
    ap.add_argument('--per-type', type=int, default=3)
    args = ap.parse_args()
    rng = random.Random(args.seed)
    cases = []
    for lang in ['en', 'fr', 'es']:
        for name, fn in TYPES:
            for i in range(1, args.per_type + 1):
                d = Doc(rng, lang)
                text = fn(d)
                missing = [x['value'] for x in d.expected if x['value'] not in text]
                assert not missing, (lang, name, missing)
                cases.append({'id': f'{lang}-syn-{name}-{i:02d}', 'lang': lang, 'category': name, 'source': 'synthetic',
                              'text': text, 'expected': d.expected})
    doc = {'version': 1,
           'description': 'Synthetic documents (template + fake data) for types without public real samples. '
                          'Generated by tool/generate_synthetic_cases.py; do not edit by hand. '
                          'Expected entries with "sub": "reference" are document reference numbers.',
           'cases': cases}
    json.dump(doc, open(args.out, 'w', encoding='utf-8', newline='\n'), ensure_ascii=False, indent=1)
    print(f'{len(cases)} cases, {sum(len(c["expected"]) for c in cases)} expected entities, '
          f'{sum(len(c["text"]) for c in cases)} chars -> {args.out}')


if __name__ == '__main__':
    main()
