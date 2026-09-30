/// Words the NER model keeps tagging as PERSON or COMPANY although they name
/// a role, not a person or an organisation: job titles, honorifics,
/// department names, identifier labels and the parties of a contract. A model
/// span that is exactly one of these is dropped, and a person name never
/// propagates one of them as a name part ("Head of Operations" -> "Head").
/// Found by the NER benchmark: one "Chair" tagged as PERSON in a board minute
/// propagated to every later "Chair" in the document; a lease did the same
/// with "Lessor" and "Lessee".
///
/// Matching is on the trimmed, lower-cased value with surrounding
/// punctuation removed. Dictionary and manual spans are never filtered.
const Set<String> titleStoplist = {
  // English titles and honorifics
  'chair', 'chairman', 'chairwoman', 'chairperson', 'ceo', 'cfo', 'coo', 'cto',
  'cio', 'cmo', 'president', 'vice president', 'director', 'managing director',
  'manager', 'general manager', 'secretary', 'treasurer', 'head',
  'head of operations', 'mr', 'mrs', 'ms', 'miss', 'dr', 'prof', 'sir', 'madam',
  // English departments and identifier labels
  'operations', 'hr', 'human resources', 'finance', 'legal', 'sales',
  'marketing', 'engineering', 'accounting', 'board', 'committee', 'department',
  'team', 'staff', 'ssn', 'nhs', 'nino', 'vat', 'iban', 'bic', 'swift',
  // English contract parties ("hereinafter referred to as the Lessor")
  'lessor', 'lessee', 'landlord', 'landlady', 'tenant', 'tenants', 'licensor',
  'licensee', 'buyer', 'seller', 'purchaser', 'vendor', 'employer', 'employee',
  'borrower', 'lender', 'guarantor', 'contractor', 'subcontractor', 'supplier',
  'client', 'customer', 'insured', 'insurer', 'policyholder', 'beneficiary',
  'claimant', 'assignor', 'assignee', 'mortgagor', 'mortgagee', 'party',
  'parties',
  // French
  'monsieur', 'madame', 'mademoiselle', 'mme', 'mlle', 'président',
  'présidente', 'directeur', 'directrice', 'directeur général', 'secrétaire',
  'trésorier', 'responsable', 'chef', 'gérant', 'gérante', 'service',
  'service juridique', 'direction', 'siège', 'siège social', 'comptabilité',
  'ressources humaines', 'rh', 'ventes', 'juridique',
  // French identifier labels: "SIRET" before the number is a label; read in
  // title case ("Siret") the model takes it for a place or a company.
  'siret', 'siren', 'urssaf', 'naf', 'ape', 'idcc', 'nir', 'rcs', 'tva', 'rib',
  // French contract parties
  'bailleur', 'bailleresse', 'preneur', 'preneuse', 'locataire', 'locataires',
  'propriétaire', 'vendeur', 'vendeuse', 'acquéreur', 'acheteur', 'employeur',
  'salarié', 'salariée', 'emprunteur', 'emprunteuse', 'prêteur', 'caution',
  'assuré', 'assurée', 'assureur', 'souscripteur', 'bénéficiaire', 'mandant',
  'mandataire', 'cédant', 'cessionnaire',
  // Spanish
  'señor', 'señora', 'sr', 'sra', 'don', 'doña', 'presidente', 'presidenta',
  'directora', 'gerente', 'secretario', 'secretaria', 'jefe', 'jefa',
  'tesorero', 'departamento', 'dirección', 'sede', 'recursos humanos',
  'contabilidad', 'mir',
  // Spanish identifier labels
  'dni', 'nif', 'nie', 'cif', 'nuss', 'cups', 'nhc', 'cip',
  // Spanish contract parties
  'arrendador', 'arrendadora', 'arrendatario', 'arrendataria', 'inquilino',
  'inquilina', 'propietario', 'propietaria', 'vendedor', 'vendedora',
  'comprador', 'compradora', 'empleador', 'empleadora', 'trabajador',
  'trabajadora', 'prestatario', 'prestataria', 'prestamista', 'avalista',
  'fiador', 'fiadora', 'asegurado', 'asegurada', 'asegurador', 'aseguradora',
  'tomador', 'tomadora', 'beneficiario', 'beneficiaria', 'cedente',
  'cesionario', 'partes',
  // Chinese
  '先生', '女士', '小姐', '总部', '分公司', '公司', '集团', '部门', '法务', '法务部',
  '总部法务部', '销售部', '人事部', '财务部', '市场部', '技术部', '研发部', '采购部',
  '客服部', '行政部', '运营部', '生产部', '办公室', '董事会', '董事长', '董事',
  '总经理', '副总经理', '经理', '总监', '主任', '主管', '顾问', '秘书', '会计',
  '出纳', '检测中心', '中心',
  // Sub-word fragment XLM-R leaves behind when it splits 法务部
  '务部',
};

/// Articles, prepositions and conjunctions: a span made only of these is
/// never a name ("THE" left over from a heading "THE POLICYHOLDER" hid every
/// "the" of an insurance letter once it propagated).
const Set<String> functionWords = {
  'the', 'a', 'an', 'of', 'and', 'or', 'to', 'in', 'on', 'at', 'for', 'by',
  'with', 'from', 'as',
  'le', 'la', 'les', 'l', 'un', 'une', 'des', 'du', 'de', 'd', 'et', 'ou', 'à',
  'au', 'aux', 'en', 'pour', 'par', 'avec', 'sur',
  'el', 'los', 'las', 'lo', 'una', 'unos', 'unas', 'y', 'o', 'del', 'al', 'con',
  'por', 'para', 'sin',
};

final _edgePunctuation = RegExp(r'^[\s\p{P}]+|[\s\p{P}]+$', unicode: true);
final _leadingArticle = RegExp(r"^(?:(?:the|a|an|le|la|les|el|los|las|un|une|una)\s+|l['’]\s*)");
final _wordSeparator = RegExp(r"[\s'’\p{P}]+", unicode: true);

/// True when [value] is nothing but a title, honorific, department name,
/// identifier label or contract party from [titleStoplist], with or without
/// an article in front ("the Lessor", "EL ARRENDATARIO", "l'Assureur").
bool isTitleOrDepartment(String value) {
  final v = value.replaceAll(_edgePunctuation, '').toLowerCase();
  if (v.isEmpty) return false;
  return titleStoplist.contains(v) || titleStoplist.contains(v.replaceFirst(_leadingArticle, ''));
}

/// True when every word of [value] is one of [functionWords].
bool isFunctionWordsOnly(String value) {
  final words = value.toLowerCase().split(_wordSeparator).where((w) => w.isNotEmpty);
  return words.isNotEmpty && words.every(functionWords.contains);
}
