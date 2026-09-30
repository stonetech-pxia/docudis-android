import 'dart:convert';

import '../anonymizer.dart';
import '../entity_type.dart';
import 'benchmark.dart';

/// Self-contained HTML report: summary tables plus, for every case, the
/// original text with detections highlighted next to the anonymized output.
/// No external assets, so it opens offline from the repo.
String renderHtml(BenchmarkRun run) {
  final all = GroupSummary('all')..results.addAll(run.results);
  final byLang = <String, GroupSummary>{};
  final byCategory = <String, GroupSummary>{};
  for (final r in run.results) {
    byLang.putIfAbsent(r.kase.lang, () => GroupSummary(r.kase.lang)).results.add(r);
    byCategory
        .putIfAbsent(r.kase.category, () => GroupSummary(r.kase.category))
        .results
        .add(r);
  }
  final langs = byLang.keys.toList();
  final categories = byCategory.keys.toList();

  final b = StringBuffer()
    ..writeln('<!DOCTYPE html><html lang="zh"><head><meta charset="utf-8">')
    ..writeln('<meta name="viewport" content="width=device-width, initial-scale=1">')
    ..writeln('<title>${_esc(run.title)}</title>')
    ..writeln('<style>$_css</style></head><body>')
    ..writeln('<header><h1>${_esc(run.title)}</h1>')
    ..writeln('<p class="meta">模型 <b>${_esc(run.modelName)}</b> · ${_esc(run.platform)} · '
        '${run.results.length} 条用例 · ${all.expected} 个预期实体</p>')
    ..writeln('<p class="overall">总体：召回 ${_pct(all.recall)} · 精确 ${_pct(all.precision)} · '
        'F1 ${_pct(all.f1)} ${_gradeChip(reliabilityGrade(all.f1))} · '
        '${all.msPerThousandChars.toStringAsFixed(0)} ms/千字符 ${_gradeChip(speedGrade(all.msPerThousandChars))}</p>')
    ..writeln('<p class="legend">图例：'
        '<mark class="t-PERSON">检测到的实体（按类型着色）</mark> '
        '<span class="missed">漏检（预期但未找到）</span> '
        '<mark class="fp">误报</mark> '
        '<mark class="wrong">类型错误</mark> '
        '<mark class="partial t-PERSON">部分命中</mark> '
        '<mark class="off t-DATE">检出但默认不遮（金额、非出生日期）</mark></p>')
    ..writeln('</header>')
    ..writeln('<section class="summary"><div>')
    ..write(_summaryTable('按语言', byLang.values))
    ..writeln('</div><div>')
    ..write(_summaryTable('按类别', byCategory.values))
    ..writeln('</div></section>')
    ..writeln('<section class="filters">')
    ..writeln('<label>语言 <select id="lang"><option value="">全部</option>'
        '${langs.map((l) => '<option>${_esc(l)}</option>').join()}</select></label>')
    ..writeln('<label>类别 <select id="cat"><option value="">全部</option>'
        '${categories.map((c) => '<option>${_esc(c)}</option>').join()}</select></label>')
    ..writeln('<label><input type="checkbox" id="fail"> 只看有问题的用例</label>')
    ..writeln('<span id="count"></span>')
    ..writeln('</section>')
    ..writeln('<main>');
  for (final r in run.results) {
    b.write(_caseCard(r));
  }
  b
    ..writeln('</main>')
    ..writeln('<script>$_js</script>')
    ..writeln('</body></html>');
  return b.toString();
}

String _summaryTable(String title, Iterable<GroupSummary> groups) {
  final b = StringBuffer()
    ..writeln('<h2>$title</h2><table><thead><tr><th>组</th><th>用例</th><th>预期</th>'
        '<th>找到</th><th>误报</th><th>召回</th><th>精确</th><th>F1</th><th>可靠度</th>'
        '<th>ms/千字</th><th>速度</th></tr></thead><tbody>');
  for (final g in groups) {
    b.writeln('<tr><td>${_esc(g.key)}</td><td>${g.results.length}</td><td>${g.expected}</td>'
        '<td>${g.found}</td><td>${g.falsePositives}</td><td>${_pct(g.recall)}</td>'
        '<td>${_pct(g.precision)}</td><td>${_pct(g.f1)}</td>'
        '<td>${_gradeChip(reliabilityGrade(g.f1))}</td>'
        '<td>${g.msPerThousandChars.toStringAsFixed(0)}</td>'
        '<td>${_gradeChip(speedGrade(g.msPerThousandChars))}</td></tr>');
  }
  b.writeln('</tbody></table>');
  return b.toString();
}

String _caseCard(CaseResult r) {
  final problems = r.misses.length + r.falsePositives.length + r.typeMismatches.length;
  final anonymized = anonymize(r.kase.text, r.detections).text;
  final rss = r.rssAfterBytes;
  final tooLong = r.kase.text.length > _previewChars;
  final b = StringBuffer()
    ..writeln('<article class="case" data-lang="${_esc(r.kase.lang)}" '
        'data-cat="${_esc(r.kase.category)}" data-fail="${problems > 0 || r.partialHits.isNotEmpty}">')
    ..writeln('<h3>${_esc(r.kase.id)} <small>${_esc(r.kase.lang)} · ${_esc(r.kase.category)}'
        '${r.kase.rulesOnly ? ' · 仅规则' : ''}</small>'
        '<span class="stats">F1 ${_pct(r.f1)} ${_gradeChip(reliabilityGrade(r.f1))} · '
        '${r.elapsed.inMilliseconds} ms · ${r.kase.text.length} 字符 · '
        '预期 ${r.expectedCount} / 命中 ${r.hits.length} / 部分 ${r.partialHits.length} / '
        '漏检 ${r.misses.length} / 误报 ${r.falsePositives.length} / 类型错 ${r.typeMismatches.length}'
        '${r.kase.category == 'stress' && rss != null ? ' · RSS ${(rss / 1048576).round()} MB' : ''}'
        '</span></h3>')
    ..writeln('<div class="panes">')
    ..writeln('<div class="pane"><h4>原文与检测${tooLong ? '（仅前 $_previewChars 字符）' : ''}</h4>'
        '<pre>${_highlighted(r, limit: tooLong ? _previewChars : null)}</pre></div>')
    ..writeln('<div class="pane"><h4>匿名化输出${tooLong ? '（仅前 $_previewChars 字符）' : ''}</h4>'
        '<pre>${_placeholders(tooLong ? anonymized.substring(0, anonymized.length < _previewChars ? anonymized.length : _previewChars) : anonymized)}</pre></div>')
    ..writeln('</div>');
  if (problems > 0) {
    b.writeln('<ul class="issues">');
    for (final line in _distinct(r.misses.map((e) => '${_esc(e.value)} <i>${e.type.placeholderName}</i>'))) {
      b.writeln('<li><b>漏检</b> $line</li>');
    }
    for (final line in _distinct(
        r.typeMismatches.map((e) => '${_esc(e.value)} 应为 <i>${e.type.placeholderName}</i>'))) {
      b.writeln('<li><b>类型错误</b> $line</li>');
    }
    for (final line in _distinct(r.falsePositives.map((d) =>
        '${_esc(d.value)} <i>${d.type.placeholderName}</i> '
        '<span class="src">${_esc(d.detector)} ${(d.confidence * 100).round()}%</span>'))) {
      b.writeln('<li><b>误报</b> $line</li>');
    }
    b.writeln('</ul>');
  }
  b.writeln('</article>');
  return b.toString();
}

const _previewChars = 2000;

/// Distinct lines with a repeat count, most frequent first, at most 30.
Iterable<String> _distinct(Iterable<String> lines) {
  final counts = <String, int>{};
  for (final l in lines) {
    counts[l] = (counts[l] ?? 0) + 1;
  }
  final entries = counts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
  return entries.take(30).map((e) => e.value > 1 ? '${e.key} <b>×${e.value}</b>' : e.key);
}

/// Original text with one `<mark>` per detection and a dashed span per
/// missed expectation (located by first uncovered occurrence).
String _highlighted(CaseResult r, {int? limit}) {
  final text = limit == null ? r.kase.text : r.kase.text.substring(0, limit);
  final fps = r.falsePositives.toSet();
  final partialValues = {for (final e in r.partialHits) e.value};
  final mismatchValues = {for (final e in r.typeMismatches) e.value};
  final spans = <_Span>[
    for (final d in r.detections)
      _Span(
        d.start,
        d.end,
        cls: fps.contains(d)
            ? 'fp t-${d.type.placeholderName}'
            : mismatchValues.contains(d.value.trim())
                ? 'wrong t-${d.type.placeholderName}'
                : partialValues.any((v) => d.value.contains(v) || v.contains(d.value))
                    ? 'partial t-${d.type.placeholderName}'
                    : '${d.enabled ? '' : 'off '}t-${d.type.placeholderName}',
        title: '${d.type.placeholderName}${d.enabled ? '' : '（默认不遮）'} · ${d.detector} · '
            '${(d.confidence * 100).round()}%',
      ),
  ];
  for (final e in r.misses) {
    var from = 0;
    while (true) {
      final idx = text.indexOf(e.value, from);
      if (idx == -1) break;
      final end = idx + e.value.length;
      if (!spans.any((s) => s.start < end && s.end > idx)) {
        spans.add(_Span(idx, end, cls: 'missed', title: '漏检 ${e.type.placeholderName}'));
        break;
      }
      from = idx + 1;
    }
  }
  spans.sort((a, b) => a.start.compareTo(b.start));
  final b = StringBuffer();
  var cursor = 0;
  for (final s in spans) {
    if (s.start < cursor) continue;
    if (s.end > text.length) break;
    b.write(_esc(text.substring(cursor, s.start)));
    final tag = s.cls == 'missed' ? 'span' : 'mark';
    b.write('<$tag class="${s.cls}" title="${_esc(s.title)}">'
        '${_esc(text.substring(s.start, s.end))}</$tag>');
    cursor = s.end;
  }
  b.write(_esc(text.substring(cursor)));
  return b.toString();
}

final _placeholderRe = RegExp(r'\[[A-Z_]+_\d+\]');

String _placeholders(String anonymized) {
  final b = StringBuffer();
  var cursor = 0;
  for (final m in _placeholderRe.allMatches(anonymized)) {
    b.write(_esc(anonymized.substring(cursor, m.start)));
    final type = m.group(0)!.substring(1, m.group(0)!.lastIndexOf('_'));
    b.write('<mark class="ph t-$type">${_esc(m.group(0)!)}</mark>');
    cursor = m.end;
  }
  b.write(_esc(anonymized.substring(cursor)));
  return b.toString();
}

class _Span {
  _Span(this.start, this.end, {required this.cls, required this.title});
  final int start;
  final int end;
  final String cls;
  final String title;
}

String _pct(double v) => '${(v * 100).round()}%';

String _gradeChip(String g) => '<span class="grade g-$g">$g</span>';

String _esc(String s) => const HtmlEscape(HtmlEscapeMode.element).convert(s);

/// One colour per entity type; the placeholder in the output pane uses the
/// same colour as the span in the original.
String get _css {
  final colors = <EntityType, String>{
    EntityType.person: '#c8623a',
    EntityType.email: '#2563eb',
    EntityType.phone: '#0d9488',
    EntityType.id: '#b45309',
    EntityType.number: '#92400e',
    EntityType.card: '#ca8a04',
    EntityType.iban: '#a16207',
    EntityType.date: '#6d28d9',
    EntityType.birthDate: '#4c1d95',
    EntityType.amount: '#ea580c',
    EntityType.ip: '#0284c7',
    EntityType.url: '#0369a1',
    EntityType.address: '#dc2626',
    EntityType.company: '#db2777',
    EntityType.secret: '#e11d48',
    EntityType.apiKey: '#059669',
    EntityType.custom: '#6b7f62',
    EntityType.other: '#6b7280',
  };
  final typeRules = colors.entries
      .map((e) => 'mark.t-${e.key.placeholderName}{background:${e.value}22;'
          'border-bottom:2px solid ${e.value}}'
          'mark.ph.t-${e.key.placeholderName}{background:${e.value};color:#fff;border:0}')
      .join('\n');
  return '''
:root{color-scheme:light}
body{margin:0;font:14px/1.5 -apple-system,"Segoe UI",Roboto,"PingFang SC","Microsoft YaHei",sans-serif;color:#2a2420;background:#f5efe8}
header{padding:20px 24px 8px}h1{margin:0 0 4px;font-size:22px}.meta{margin:0;color:#6b5f55}
.overall{font-size:16px}.legend{color:#6b5f55}.legend mark,.legend span{margin-right:8px}
section.summary{display:grid;grid-template-columns:1fr 1fr;gap:16px;padding:0 24px}
@media(max-width:900px){section.summary{grid-template-columns:1fr}}
h2{font-size:16px;margin:8px 0}table{border-collapse:collapse;width:100%;background:#fffcf8;font-size:13px}
th,td{padding:4px 8px;border-bottom:1px solid #e8dfd4;text-align:right}th:first-child,td:first-child{text-align:left}
.filters{position:sticky;top:0;background:#f5efe8;padding:10px 24px;border-bottom:1px solid #e8dfd4;display:flex;gap:16px;align-items:center;z-index:2}
main{padding:12px 24px 40px}
article.case{background:#fffcf8;border-radius:14px;padding:12px 16px;margin:12px 0;box-shadow:0 6px 20px rgba(120,90,60,.08)}
article.case[data-fail="true"] h3::before{content:"⚠ ";color:#dc2626}
h3{margin:0 0 8px;font-size:15px;display:flex;flex-wrap:wrap;gap:8px;align-items:baseline}
h3 small{color:#8a7b6f;font-weight:400}h3 .stats{margin-left:auto;font-weight:400;color:#6b5f55;font-size:12px}
.panes{display:grid;grid-template-columns:1fr 1fr;gap:12px}@media(max-width:900px){.panes{grid-template-columns:1fr}}
.pane h4{margin:0 0 4px;font-size:12px;color:#8a7b6f;font-weight:600;text-transform:uppercase;letter-spacing:.04em}
pre{white-space:pre-wrap;word-break:break-word;margin:0;padding:10px;background:#faf6f1;border-radius:8px;font:14px/1.7 inherit}
mark{border-radius:4px;padding:0 2px;color:inherit}
mark.fp{background:#fee2e2!important;border-bottom:2px solid #dc2626!important;text-decoration:line-through}
mark.wrong{background:#fef3c7!important;border-bottom:2px dotted #b45309!important}
mark.partial{outline:1px dashed #6b5f55}
mark.off{background:transparent!important;border-bottom-style:dotted!important}
span.missed{border-bottom:2px dashed #dc2626;background:#fff1f1}
mark.ph{padding:0 5px;border-radius:6px;font-weight:600;font-size:12px}
ul.issues{margin:8px 0 0;padding-left:18px;color:#6b5f55}ul.issues .src{color:#a89a8e;font-size:12px}
.grade{display:inline-block;min-width:18px;text-align:center;border-radius:6px;padding:0 6px;font-weight:700;color:#fff;font-size:12px}
.g-A{background:#4e6644}.g-B{background:#6b7f62}.g-C{background:#b8926a}.g-D{background:#a84e2c}
.hidden{display:none}
$typeRules
''';
}

const _js = r'''
const lang=document.getElementById('lang'),cat=document.getElementById('cat'),fail=document.getElementById('fail'),count=document.getElementById('count');
function apply(){let n=0;for(const c of document.querySelectorAll('article.case')){const show=(!lang.value||c.dataset.lang===lang.value)&&(!cat.value||c.dataset.cat===cat.value)&&(!fail.checked||c.dataset.fail==='true');c.classList.toggle('hidden',!show);if(show)n++;}count.textContent='显示 '+n+' 条';}
lang.onchange=cat.onchange=fail.onchange=apply;apply();
''';
