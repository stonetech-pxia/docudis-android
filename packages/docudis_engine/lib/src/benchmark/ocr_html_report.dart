import 'dart:convert';

import 'ocr_benchmark.dart';

/// Renders an offline OCR benchmark report with external fixture images.
///
/// Reports normally live under `docs/benchmark`, so relative fixture paths are
/// prefixed with `../../`. The original manifest path is a browser fallback.
String renderOcrHtml(OcrBenchmarkRun run) {
  final all = OcrGroupSummary('all')..results.addAll(run.results);
  final byLanguage = <String, OcrGroupSummary>{};
  final byCategory = <String, OcrGroupSummary>{};
  for (final result in run.results) {
    byLanguage
        .putIfAbsent(result.kase.lang, () => OcrGroupSummary(result.kase.lang))
        .results
        .add(result);
    byCategory
        .putIfAbsent(
          result.kase.category,
          () => OcrGroupSummary(result.kase.category),
        )
        .results
        .add(result);
  }

  final output = StringBuffer()
    ..writeln('<!DOCTYPE html><html lang="en"><head><meta charset="utf-8">')
    ..writeln(
      '<meta name="viewport" content="width=device-width, initial-scale=1">',
    )
    ..writeln('<title>${_escape(run.title)}</title>')
    ..writeln('<style>$_ocrCss</style></head><body>')
    ..writeln('<header><h1>${_escape(run.title)}</h1>')
    ..writeln(
      '<p class="meta">Recognizer <b>${_escape(run.recognizerName)}</b> · '
      '${_escape(run.platform)} · ${all.cases} cases · ${all.errors} errors</p>',
    )
    ..writeln(
      '<p class="overall">strict CER ${_percent(all.strictCharacterErrorRate)} · '
      'normalized CER ${_percent(all.normalizedCharacterErrorRate)} '
      '${_gradeChip(ocrReliabilityGrade(all.normalizedCharacterErrorRate))} · '
      'WER ${_percent(all.wordErrorRate)} · line F1 ${_percent(all.lineF1)} · '
      'critical recall ${_percent(all.criticalSpanRecall)} · '
      'exact ${all.exactMatches}/${all.cases} · '
      '${all.msPerMegapixel.toStringAsFixed(0)} ms/MP</p>',
    )
    ..writeln(
      '<p class="legend">Strict CER preserves whitespace after line-ending '
      'canonicalization. Normalized metrics collapse whitespace. CER counts '
      'Unicode code points, not grapheme clusters; case, punctuation, '
      'diacritics, symbols and digits remain significant.</p></header>',
    )
    ..writeln('<section class="summary"><div>')
    ..write(_summaryTable('By language', byLanguage.values))
    ..writeln('</div><div>')
    ..write(_summaryTable('By category', byCategory.values))
    ..writeln('</div></section>')
    ..writeln('<section class="filters">')
    ..writeln(
      '<label>Language <select id="lang"><option value="">All</option>'
      '${byLanguage.keys.map((value) => '<option>${_escape(value)}</option>').join()}'
      '</select></label>',
    )
    ..writeln(
      '<label>Category <select id="cat"><option value="">All</option>'
      '${byCategory.keys.map((value) => '<option>${_escape(value)}</option>').join()}'
      '</select></label>',
    )
    ..writeln(
      '<label><input type="checkbox" id="fail"> Problems only</label>'
      '<span id="count"></span></section><main>',
    );
  for (final result in run.results) {
    output.write(_caseCard(result));
  }
  output
    ..writeln('</main><script>$_ocrJs</script>')
    ..writeln('</body></html>');
  return output.toString();
}

String _summaryTable(String title, Iterable<OcrGroupSummary> groups) {
  final output = StringBuffer()
    ..writeln('<h2>$title</h2>')
    ..writeln(
      '<table><thead><tr><th>Group</th><th>Cases</th><th>Strict CER</th>'
      '<th>Normalized CER</th><th>WER</th><th>Line F1</th><th>Critical</th>'
      '<th>Exact</th><th>Errors</th><th>ms/MP</th></tr></thead><tbody>',
    );
  for (final group in groups) {
    output.writeln(
      '<tr><td>${_escape(group.key)}</td><td>${group.cases}</td>'
      '<td>${_percent(group.strictCharacterErrorRate)}</td>'
      '<td>${_percent(group.normalizedCharacterErrorRate)} '
      '${_gradeChip(ocrReliabilityGrade(group.normalizedCharacterErrorRate))}</td>'
      '<td>${_percent(group.wordErrorRate)}</td>'
      '<td>${_percent(group.lineF1)}</td>'
      '<td>${_percent(group.criticalSpanRecall)}</td>'
      '<td>${group.exactMatches}/${group.cases}</td><td>${group.errors}</td>'
      '<td>${group.msPerMegapixel.toStringAsFixed(0)}</td></tr>',
    );
  }
  output.writeln('</tbody></table>');
  return output.toString();
}

String _caseCard(OcrCaseResult result) {
  final hasProblems =
      result.failed ||
      !result.exactMatch ||
      result.missedCriticalSpans.isNotEmpty;
  final output = StringBuffer()
    ..writeln(
      '<article class="case" data-lang="${_attribute(result.kase.lang)}" '
      'data-cat="${_attribute(result.kase.category)}" '
      'data-fail="$hasProblems">',
    )
    ..writeln(
      '<h3>${_escape(result.kase.id)} '
      '<small>${_escape(result.kase.lang)} · '
      '${_escape(result.kase.category)} · ${_escape(result.kase.difficulty)}</small>'
      '<span class="stats">strict CER ${_percent(result.strictCharacterErrorRate)} · '
      'normalized CER ${_percent(result.normalizedCharacterErrorRate)} '
      '${_gradeChip(ocrReliabilityGrade(result.normalizedCharacterErrorRate))} · '
      'WER ${_percent(result.wordErrorRate)} · '
      'line F1 ${_percent(result.lineF1)} · '
      'critical ${result.foundCriticalSpanCount}/${result.expectedCriticalSpanCount} · '
      '${result.elapsed.inMilliseconds} ms · '
      '${result.msPerMegapixel.toStringAsFixed(0)} ms/MP</span></h3>',
    )
    ..writeln('<div class="case-grid">')
    ..writeln(
      '<figure><img loading="lazy" '
      'src="${_attribute(_primaryImagePath(result.kase.imagePath))}" '
      'data-fallback="${_attribute(result.kase.imagePath)}" '
      'alt="${_attribute(result.kase.id)} OCR fixture" '
      'onerror="if(this.dataset.retry!==\'1\'){this.dataset.retry=\'1\';'
      'this.src=this.dataset.fallback}else{this.parentElement.classList.add(\'missing\')}">'
      '<figcaption>${_escape(result.kase.imagePath)} · '
      '${result.kase.width}×${result.kase.height}'
      '${_sourceCaption(result.kase)}</figcaption></figure>',
    )
    ..writeln('<div class="panes">')
    ..writeln(
      '<div class="pane"><h4>Expected</h4>'
      '<pre>${_escape(result.kase.expectedText)}</pre></div>',
    )
    ..writeln(
      '<div class="pane"><h4>Recognized</h4>'
      '<pre>${result.recognizedText.isEmpty ? '<span class="empty">(empty)</span>' : _escape(result.recognizedText)}</pre></div>',
    )
    ..writeln('</div></div>');
  if (result.error != null || result.missedCriticalSpans.isNotEmpty) {
    output.writeln('<ul class="issues">');
    if (result.error != null) {
      output.writeln('<li><b>Error</b> ${_escape(result.error!)}</li>');
    }
    for (final span in result.missedCriticalSpans) {
      output.writeln(
        '<li><b>Missed critical span</b> ${_escape(span.value)} '
        '<i>${_escape(span.type)}</i></li>',
      );
    }
    output.writeln('</ul>');
  }
  output.writeln('</article>');
  return output.toString();
}

String _sourceCaption(OcrBenchmarkCase kase) {
  final details = [
    if (kase.sourceAuthor != null) kase.sourceAuthor!,
    if (kase.sourceLicense != null) kase.sourceLicense!,
  ].map(_escape).join(' · ');
  if (kase.sourceUrl == null) {
    return details.isEmpty ? '' : ' · $details';
  }
  final label = details.isEmpty ? 'source' : details;
  return ' · <a href="${_attribute(kase.sourceUrl!)}" '
      'rel="noopener noreferrer">$label</a>';
}

String _percent(double value) => '${(value * 100).toStringAsFixed(1)}%';

String _gradeChip(String grade) => '<span class="grade g-$grade">$grade</span>';

String _escape(String value) =>
    const HtmlEscape(HtmlEscapeMode.element).convert(value);

String _attribute(String value) =>
    const HtmlEscape(HtmlEscapeMode.attribute).convert(value);

String _primaryImagePath(String path) {
  final uri = Uri.tryParse(path);
  if ((uri?.hasScheme ?? false) ||
      path.startsWith('/') ||
      path.startsWith('\\')) {
    return path;
  }
  return '../../$path';
}

const _ocrCss = '''
:root{color-scheme:light}
body{margin:0;font:14px/1.5 -apple-system,"Segoe UI",Roboto,"PingFang SC","Microsoft YaHei",sans-serif;color:#25221f;background:#f3efe9}
header{padding:20px 24px 8px}h1{margin:0 0 4px;font-size:22px}.meta,.legend{margin:4px 0;color:#6b6259}.overall{font-size:16px}
.summary{display:grid;grid-template-columns:1fr 1fr;gap:16px;padding:0 24px}@media(max-width:900px){.summary{grid-template-columns:1fr}}
h2{font-size:16px;margin:8px 0}table{border-collapse:collapse;width:100%;background:#fffdf9;font-size:12px}th,td{padding:5px 7px;border-bottom:1px solid #e8dfd4;text-align:right}th:first-child,td:first-child{text-align:left}
.filters{position:sticky;top:0;z-index:2;display:flex;gap:16px;align-items:center;padding:10px 24px;background:#f3efe9;border-bottom:1px solid #ded5ca}
main{padding:12px 24px 40px}.case{margin:12px 0;padding:12px 16px;border-radius:14px;background:#fffdf9;box-shadow:0 6px 20px rgba(80,60,40,.08)}.case[data-fail="true"] h3:before{content:"⚠ ";color:#b33b2e}
h3{display:flex;flex-wrap:wrap;gap:8px;align-items:baseline;margin:0 0 10px;font-size:15px}h3 small{color:#83766b;font-weight:400}.stats{margin-left:auto;color:#6b6259;font-size:12px;font-weight:400}
.case-grid{display:grid;grid-template-columns:minmax(220px,34%) 1fr;gap:14px}@media(max-width:900px){.case-grid{grid-template-columns:1fr}}
figure{margin:0;padding:8px;border-radius:9px;background:#f7f2ec}figure img{display:block;max-width:100%;max-height:400px;margin:auto;border-radius:5px}figure.missing{min-height:110px}figure.missing:before{content:"Image unavailable from this report location";display:block;padding:28px 8px;color:#9a897c;text-align:center}figure.missing img{display:none}figcaption{margin-top:6px;color:#83766b;font-size:11px;overflow-wrap:anywhere}
.panes{display:grid;grid-template-columns:1fr 1fr;gap:10px}@media(max-width:1100px){.panes{grid-template-columns:1fr}}h4{margin:0 0 4px;color:#83766b;font-size:11px;text-transform:uppercase;letter-spacing:.05em}
pre{box-sizing:border-box;min-height:100px;margin:0;padding:10px;border-radius:8px;background:#f8f4ef;white-space:pre-wrap;word-break:break-word;font:13px/1.65 ui-monospace,"SFMono-Regular",Consolas,monospace}.empty{color:#a49990;font-style:italic}
.issues{margin:10px 0 0;padding-left:20px;color:#6b6259}.issues i{font-size:11px;color:#9a897c}.grade{display:inline-block;min-width:18px;padding:0 5px;border-radius:6px;color:#fff;text-align:center;font-size:11px;font-weight:700}.g-A{background:#4e6644}.g-B{background:#6b7f62}.g-C{background:#b8926a}.g-D{background:#a84e2c}.hidden{display:none}
''';

const _ocrJs = r'''
const lang=document.getElementById('lang'),cat=document.getElementById('cat'),fail=document.getElementById('fail'),count=document.getElementById('count');
function apply(){let n=0;for(const c of document.querySelectorAll('article.case')){const show=(!lang.value||c.dataset.lang===lang.value)&&(!cat.value||c.dataset.cat===cat.value)&&(!fail.checked||c.dataset.fail==='true');c.classList.toggle('hidden',!show);if(show)n++;}count.textContent='Showing '+n+' cases';}
lang.onchange=cat.onchange=fail.onchange=apply;apply();
''';
