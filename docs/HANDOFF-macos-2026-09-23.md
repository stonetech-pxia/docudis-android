# 交接：从 Windows 搬到 macOS（2026-09-23）

搬到 Mac 是为了做 iOS 版；Android 真机调试也在 Mac 上继续。本文件有两部分：
在 Mac 上把项目还原到能跑的状态，以及把 Claude Code 在 Windows 上积累的项目记忆带过去（附录是全部记忆原文）。

## 0. 交接时的状态

- 分支 `store-materials-and-detection-precision`，交接时的最后一个提交是本文件所在的提交，已推送到 GitHub（私有仓库）。
- Windows 上测试全绿：引擎 `dart test` 430 个，App `flutter test` 79 个。
- 最近的工作线：9/23 真机测试修复（`53b042d`）、OCR 按页面顺序读取、留出回归集（`fe3258e`），
  详见 `docs/HANDOFF-ner-finetune-2026-09-19.md` 和附录里的记忆。

## 1. 在 Mac 上还原项目

### 1.1 工具

| 工具 | 说明 |
|---|---|
| Xcode 16+（含命令行工具）、CocoaPods | iOS 构建，`SETUP_IOS.md` 第 4 节 |
| Flutter 3.47.4 | Windows 上用的就是这个版本；版本不同可能让 golden 截图出现像素差 |
| Android SDK：cmdline-tools、platform-tools、`platforms;android-36`、`build-tools;36.0.0` | 与 Windows 上一致；装 Android Studio 最省事 |
| JDK 17 | Android Studio 自带的即可 |
| Python 3 | `pip3 install huggingface_hub`（下载模型）；跑桌面基准再加 `onnxruntime numpy`，设计资源脚本再加 `Pillow` |

```bash
flutter doctor --android-licenses
```

文档和脚本里需要 Python 的地方都写成 `$PYTHON`，Mac 上设成 `export PYTHON=python3` 即可。

### 1.2 克隆

```bash
git clone https://github.com/stonetech-pxia/docudis.git
```
```bash
cd docudis && git checkout store-materials-and-detection-precision
```

### 1.3 模型

模型文件不在 git 里。正式发布的 `xlmr_ner_docudis` 在私有 Hugging Face 仓库 `leonx1995/docudis-ner-xlmr`，
`assets/models/manifest.json` 固定了版本和 SHA-256：

```bash
huggingface-cli login
```
```bash
python3 tool/fetch_models.py
```

加 `--all` 连同两个做 A/B 对比的原版模型一起下。细节见 `assets/models/README.md`。

### 1.4 需要从 Windows 手动拷过来的文件

都不在 git 里。**用 U 盘或 AirDrop 之类传，不要走公开的网盘链接**。

| 文件 | Windows 上的位置 | 用途 |
|---|---|---|
| `android/key.properties` | 仓库内 | 发布签名的口令；里面的 `storeFile` 路径要改成 Mac 上的路径 |
| `docudis-upload.jks` | `C:\Users\Xia\keys\` | 上传密钥库。**丢了就不能再用同一个签名更新 Play 上的应用** |

`local.properties`、`gradlew`、`GeneratedPluginRegistrant.*`、`ios/Flutter/Generated.xcconfig`、
`android/model_pack/src/` 会自动生成，不用拷。

### 1.5 装依赖并验证

```bash
flutter pub get
```
```bash
cd packages/docudis_engine && dart pub get && dart test
```
```bash
flutter test
```

预期结果：引擎 430 个全过，App 79 个全过。注意两点：
- zh 商店截图测试要用 Noto Sans SC 字体，会先读 `$NOTO_SANS_SC`，再找 `C:/Windows/Fonts`。Mac 上没有这个字体时测试会被跳过；
  要跑就下载 `NotoSansSC-VF.ttf`，然后 `export NOTO_SANS_SC=/path/to/NotoSansSC-VF.ttf`。
- golden 截图是在 Windows 上生成的。如果 Mac 上只差零点几个百分点的像素，是字体光栅化的差异，**先看图再决定是否
  `--update-goldens`**，不要直接覆盖。

### 1.6 Android 真机（S26 Ultra）

Mac 不需要三星 USB 驱动。第一次插上手机：Mac 会问"允许配件连接"，选允许；手机会重新问"允许 USB 调试"，
因为 Mac 的 adb 密钥和 Windows 那台不一样。Android File Transfer、Smart Switch 会抢占 USB，调试时先退出。

```bash
flutter devices
```

之后用 `flutter run -d <设备 id>`。debug 构建会把模型同步进普通 assets，发布必须用 `flutter build appbundle`（模型走 Play 资源包）。
Windows 上 Git Bash 需要的 `MSYS_NO_PATHCONV=1` 在 Mac 上不需要。

### 1.7 iOS

按 `SETUP_IOS.md` 做。

## 2. 留在 Windows 上的工作（用户的决定）

- **模型训练**：需要 NVIDIA 显卡（RTX 3080，10 GB），`training/README.md` 里的 Windows 路径故意没改。
  重新训练后在 Windows 上传到 HF，再更新 `manifest.json` 的版本号和哈希，步骤见 `assets/models/README.md`。
- **PDF 脱敏的桌面测试**（`packages/docudis_pdf`，还没接进 App）：用的是 `pdfium.dll`，见附录 `docudis-pdf-redaction`。

## 3. 移植 iOS 前已知的缺口（写本文件时发现，都没修）

- **模型加载只有 Android 实现**：`ModelLocator` 通过原生通道 `com.stonetech.docudis/model_assets` 把模型拷到
  App 支持目录，这个通道只在 `MainActivity.kt` 里实现，`ios/Runner` 里没有。iOS 上不补这个通道，NER 模型就加载不了；
  另外还要决定模型怎么打进 iOS 包（约 280 MB）。
- **文字选择菜单"匿名化"（Android `PROCESS_TEXT`）和快速设置磁贴只有 Android 版**；iOS 对应的是 Share / Action Extension，还没做。
- **"发送到"其他 AI App**：`Info.plist` 的 `LSApplicationQueriesSchemes` 里，ChatGPT、Claude 以外的 URL scheme 是猜的，没验证过。

## 4. 把 Claude Code 的项目记忆带到 Mac

Claude Code 的记忆按项目路径存放：`~/.claude/projects/<路径>/memory/`，其中 `<路径>` 是项目绝对路径里
每个非字母数字字符换成 `-`，比如 Windows 上是 `C--Users-Xia-projects-docudis`。Mac 上路径不同，所以要在新位置重建。

附录收录了全部记忆文件原文（交接时共 22 个加索引 `MEMORY.md`）。在 Mac 的仓库根目录运行下面这段，
会把它们写进正确的目录：

```bash
python3 - <<'EOF'
import os, pathlib, re
doc = pathlib.Path('docs/HANDOFF-macos-2026-09-23.md').read_text(encoding='utf-8')
dest = pathlib.Path.home() / '.claude' / 'projects' / re.sub(r'[^A-Za-z0-9]', '-', os.getcwd()) / 'memory'
dest.mkdir(parents=True, exist_ok=True)
for name, body in re.findall(r'<!-- memory-file: (\S+) -->\n`````markdown\n(.*?)\n`````\n', doc, re.S):
    (dest / name).write_text(body + '\n', encoding='utf-8')
    print(dest / name)
EOF
```

写完后在 Mac 上开一个新的 Claude Code 会话，它会自动读到这些记忆。

**记忆里只适用于 Windows 的内容**（Mac 上读到时忽略或改写）：
- `flutter-sdk-via-scoop`：整条都是 Windows 环境（scoop 路径、PATH 前缀、手写许可证哈希）。Mac 上装好环境后可以删掉或改写。
- 各条里的 `C:/Users/Xia/anaconda3/python.exe`、`C:/Users/Xia/scoop/...`：Mac 上换成 `$PYTHON` 和 Flutter 自带的 `dart`。
- `MSYS_NO_PATHCONV=1`（Git Bash 专用）、`WinError 1314`（Windows 上 HF 缓存不能建符号链接）、`C:/Windows/Fonts`、
  WindowsApps 占位的 `python` 会卡死：都是 Windows 特有的问题。
- `docudis-pdf-redaction` 的桌面测试命令、`recorder-app-clay-b` 里的 `C:\Users\Xia\projects\BrainFiles`：路径只在 Windows 上存在，工作也留在 Windows。
- "这台笔记本连续跑基准会降速到十分之一"：说的是 Windows 笔记本，Mac 上的速度要重新量。

## 附录：记忆原文

以下内容由 Windows 上的 `~/.claude/projects/C--Users-Xia-projects-docudis/memory/` 原样导出，交接之后不会自动更新。

### MEMORY.md

<!-- memory-file: MEMORY.md -->
`````markdown
- [Flutter SDK via scoop](flutter-sdk-via-scoop.md) — flutter/adb/java not on tool-shell PATH; exact dirs to prepend; SDK licenses already accepted
- [Docudis design: Clay](docudis-design-clay.md) — chosen UI direction, tokens, canvas URL; implemented 2026-09-16 in lib/theme, goldens in test/goldens; app icon = logo concept A (design/logo)
- [Docudis anonymization build](docudis-anonymization-build.md) — feature state, design doc contract, benchmark commands (Anaconda python path), phone benchmark not yet run
- [Docudis home: minimal](docudis-home-minimal.md) — user wants home tab = one sentence + three cards, inputs staged in place with confirm/cancel; no header, badge or recent list
- [Docudis hidden features](docudis-hidden-features.md) — delete hidden 2026-09-17; review came back, restore back 2026-09-23 (header icon, stable placeholders); result page send-to logos, AiApp list, logo asset source
- [Docudis store materials](docudis-store-materials.md) — personal dev account, contact email, listing/policy/screenshot locations, what store copy omits
- [Docudis target market](docudis-target-market.md) — users mainly English/French/Spanish, Chinese low priority (2026-09-18); cn gating, postal_city + euro-amount rules, OCR recognizer settled 2026-09-17
- [Docudis version bumps](docudis-version-bumps.md) — 1.0.0+1 set 2026-09-17; ask before every later version/versionCode change
- [Docudis PDF redaction](docudis-pdf-redaction.md) — route B in packages/docudis_pdf (not wired in); PDFium z-order/clip constraints; desktop test command
- [Docudis tap-to-redact](docudis-tap-to-redact.md) — second-pass page is tap-only; blocks come from engine chunkText; decided 2026-09-17
- [Docudis custom dictionary](docudis-custom-dictionary.md) — "Always hide" card built 2026-09-18: suggestion-only, yields to longer hidden span, dictionary.json outside backup, not cleared with data
- [Docudis rule audit 2026-09](docudis-rule-audit-2026-09.md) — confirmed rule conflicts/false positives (leaks, wrong types, swallowed prose); five items fixed 2026-09-18 (see tests), verify the rest before assuming open
- [Docudis NER fine-tune plan](docudis-ner-finetune-plan.md) — shipped 2026-09-21: own xlmr_ner_docudis fine-tune + ID/company rules + span completion, clean consumer documents 11 → 40 of 60; launch criterion accepted by the user, held-out regression set, the one question still waiting
- [Docudis span repair](docudis-span-repair.md) — repairSpans added 2026-09-19 (half-hidden names/addresses/numbers); ML Kit phone beating long_number was the real NIR cause; leak 9.5 → 7.2%; verified on the phone, commit 8fbf347 (only this line of work staged)
- [Docudis phone walkthrough 2026-09-19](docudis-phone-walkthrough-2026-09-19.md) — end-user test of paste/upload/photo on the S26: leaks and wrong types found (nothing fixed), how to drive the phone over adb
- [Docudis phone walkthrough 2026-09-23](docudis-phone-walkthrough-2026-09-23.md) — "would I pay": no; leaks/label defects, root causes, fixes verified on the phone (committed 53b042d); SIRET-as-ADDRESS still open
- [Recorder app: Clay B](recorder-app-clay-b.md) — second Flutter app (record/upload → on-device summary) reuses Clay with pine primary, terracotta only for recording; mockup URL, dark tokens, shared theme package not started
- [Docudis placeholder policy](docudis-placeholder-policy.md) — NUMBER over a wrong type (IDs and loose phones), amounts + non-birth dates visible by default, single-language docs; done 2026-09-18 incl. store copy and hide-all switches on the review page; SIRET stays NUMBER
- [Docudis OCR reading order](docudis-ocr-reading-order.md) — page-order OCR text since 2026-09-23 (CER 53 → 10%), two-column cost, photo test set deferred by the user
- [Laya evaluated, not an NER](laya-evaluated-not-ner.md) — tested 2026-09-20 against the docudis NER and rejected; no span head, cannot redact
- [Docudis model hosting + Mac move](docudis-model-hosting-mac-move.md) — models via private HF repo + fetch_models.py (2026-09-23); training/PDF tests stay on Windows; files to copy by hand
`````

### docudis-anonymization-build.md

<!-- memory-file: docudis-anonymization-build.md -->
`````markdown
---
name: docudis-anonymization-build
description: "State of the Docudis anonymization feature after the 2026-09-16 build session; where decisions live, how to benchmark, what is still unverified on device"
metadata: 
  node_type: memory
  type: project
  originSessionId: 8ab47341-637e-4fdb-8e92-e0baacb1d525
  modified: 2026-09-17T14:00:52.410Z
---

Built 2026-09-16 after a long grilling session; every product decision is recorded in
`docs/anonymization-design.md` (Chinese) — read it before changing behaviour, and update it
when a decision changes (two were refined after benchmarking: strong rules ≥0.8 beat the model,
region packs are gated by detected language instead of all-on).

- Engine = pure Dart package `packages/docudis_engine` (204 tests, `dart test`); app side = `lib/anonymize/`.
- NER model files (135 MB int8 ONNX + tokenizer.json) are downloaded from Hugging Face and git-ignored;
  only `assets/models/distilbert_ner_hrl/model.json` is tracked. Re-download steps in `assets/models/README.md`.
- Desktop benchmark needs Anaconda Python: `PYTHON=C:/Users/Xia/anaconda3/python.exe dart run benchmark/run_benchmark.dart`
  from the engine dir (plain `python` on PATH hangs — WindowsApps stub). Report: `docs/ner-benchmark-desktop.md`.
  Reports now live in `docs/benchmark/` (desktop-xlmr.md is the canonical one; run with
  `--model ../../assets/models/xlmr_ner_hrl --stress --out ../../docs/benchmark/desktop-xlmr.md`). `dart` is not on the
  tool-shell PATH: prepend `C:/Users/Xia/scoop/apps/flutter/current/bin`.
- 2026-09-18: rule gaps from the benchmark fixed + title/department stoplist (`lib/src/rules/title_stoplist.dart`,
  applied to model spans and name-part propagation only): desktop XLM-R F1 90% → 95%, precision 91% → 98%; after fixing three missing labels in
  `benchmark/ner_cases.json` and giving `multi` stress cases fr/es tags: F1 98%, precision 99%, recall 97%; name-type rules no longer span line breaks; OCR whitespace normalisation and lowercase names deferred by the user. Details and the
  gaps deliberately left open (ticket numbers, `cn:company` prefix) are in the design
  doc under 检测引擎. Device (phone) benchmark not re-run after this change.
- Phone benchmark: `flutter test integration_test/ner_benchmark_test.dart -d <device>`; not yet run — no device
  was attached during the build session. User wants speed/reliability grades per language/category as a table.
- 2026-09-17: text-selection menu entry ("匿名化", Android `PROCESS_TEXT`) acts on the selection directly, no review
  (user's explicit choice): editable selection replaced in place, read-only copied to clipboard; runs on the app engine
  or a headless `processTextMain` engine. Verified on the phone in Chrome (in place) and cold start (headless).
  The entry does NOT show in WeChat/WhatsApp/Telegram/Gmail/Google Messages: they declare neither PROCESS_TEXT queries
  nor QUERY_ALL_PACKAGES, so no third-party entries appear there at all. iOS Share Extension not built (no Mac).
  Framework forces PROCESS_TEXT items into the ⋮ overflow (SHOW_AS_ACTION_NEVER); cannot be promoted by the app.
- 2026-09-17: "匿名化剪贴板" Quick Settings tile covers those apps (copy → tile → paste), verified by a real tap.
  One UI testing gotcha: `cmd statusbar add-tile` does NOT make the tile visible (it shows greyed in 添加控件 and is
  never bound, so `click-tile` does nothing); remove it with `remove-tile` and add it via 编辑 → 添加控件 instead.
  Quick settings = swipe down from the top right on this phone; top left is notifications.
- User's stated priority: fully on-device, minimal manual work for the user, model must be swappable
  (`model.json` spec), MVP languages zh/en/fr/es/hi (hi has no NER coverage yet).

- 2026-09-17 OCR model search: user unhappy with ML Kit / PP-OCRv6-small. Desktop run (RTX 3080) of PP-OCRv6-medium,
  PaddleOCR-VL-1.6, GLM-OCR: GLM-OCR best overall (norm CER 5.8%), PaddleOCR-VL best on Hindi + handwriting but loops
  on whole-page A4 without a layout model. Several receipt/business-card ground-truth spans don't match what's printed
  (flagged to user, not changed). Both have official GGUF (llama.cpp) — phone test not yet done.

- 2026-09-18 bundled lists: `BundledListDetector` (companies + Chinese places from Wikidata; root `tool/fetch_bundled_lists.py`
  needs Anaconda python + network, caches SPARQL results in the OS temp dir; then `dart run tool/embed_lists.dart` in the
  engine). Priority equal to the model. Person names deliberately NOT bundled. `cn:address` prefix/tail bounded.
  Desktop XLM-R now F1 97% / precision 97%; the missing point is two real locations the dataset does not label.

- 2026-09-18 real-document test sets (en/fr/es; user will NOT provide own documents): `benchmark/public_cases.json` (45 public
  records: BODACC, BORME, The Gazette corporate notices, Enron; 881 labels by independent annotator agents, guide in
  `benchmark/public/ANNOTATION.md`) and `benchmark/synthetic_cases.json` (45 template docs from `tool/generate_synthetic_cases.py`).
  Run with `run_benchmark.dart --dataset ...`, then `tool/leak_report.py <dataset> <run.json>`: leak rate is now the main metric.
  First result: public 42% leaked (en 9.7 / fr 42 / es 71), synthetic 9.1%. Causes are rules, not the model: be/ch 4-digit postal
  rule eats years in fr dates, fr:postal eats the SIRET tail, es:postal (0.75) loses to the model, amounts without thousands
  separators or with the word "euros", d.mm.yy dates, all-caps company names, no URL rule, long_number on year ranges.
  Fixed the same day: public 42% -> 13.2%, synthetic 9.1% -> 1.3%, hand-written set unchanged; `benchmark/hard_negatives.json`
  (18 look-alike texts, 0 false positives, wired into rules_test) guards precision; `tool/run_all_benchmarks.sh` runs everything.
  Remaining leaks are the model on ALL-CAPS names/companies. A "n° 12345" numbered-id rule was tried and removed: it conflicts
  with the 2026-09-17 decision not to extend reference-number rules. Do not put the user's e-mail in request headers (done once by mistake; removed).

- 2026-09-18 later: `NerDetector.titleCased` feeds the model title case for words of 4+ capitals (offsets unchanged); public-record leak rate 14.4% -> 9.4% (es 18.8 -> 8.9), F1 83 -> 85. Desktop numbers after that: hand-written F1 97, public 85, synthetic 97 / leak 1.5%, hard negatives 0. **Benchmark speed on this laptop is only trustworthy on a cool machine**: back-to-back runs slow down up to 10x with identical code (checked with an A/B), so do not read a speed regression into a second consecutive run.

**Why:** the design doc is the contract for this feature; the benchmark is how the user decides on the final model.

**How to apply:** when asked to change detection behaviour, run the benchmark before and after and report the
table; keep the doc in sync. Related: [[docudis-design-clay]], [[flutter-sdk-via-scoop]].
`````

### docudis-custom-dictionary.md

<!-- memory-file: docudis-custom-dictionary.md -->
`````markdown
---
name: docudis-custom-dictionary
description: "Custom dictionary (\"Always hide\") decisions of 2026-09-18 — filled only from manual-block suggestions, yields to a longer hidden span, stored in dictionary.json outside Android backup"
metadata: 
  node_type: memory
  type: project
  originSessionId: a68dcc73-e2cf-4043-89c4-6954fdbb4008
  modified: 2026-09-18T16:34:50.192Z
---

Built 2026-09-18 on the user's request (`lib/home/dictionary_page.dart`, uncommitted at the time).

**Account tab layout (same day):** the user found the first version (a big dictionary card inline) cluttered and accepted rows of one shape, each with an icon tile, title and one status caption. "Always hide" shows "2 words · 3 suggestions" and opens the dictionary page. Same taste as [[docudis-home-minimal]]: keep top-level pages to a few uniform cards.

Decisions the user accepted ("按照你推荐的做"):
- The dictionary starts empty and is filled **only** by one tap on a suggestion; no free-text entry, no type picker (entries are `[CUSTOM_n]`), no edit/group/import.
- Suggestions are not stored: `recentManualBlocks` (`lib/anonymize/manual_blocks.dart`) reads `source: manual` + enabled detections back from the kept records, newest document first, max 100 on the "All" page; the dictionary page puts forward the 5 hidden by hand in the most documents.
- "Highest priority" means "always hidden", not "wins every overlap": a dictionary hit strictly inside a longer *enabled* span gives way (`DetectionPipeline.resolveOverlaps`), so "Jean Dupont" stays one PERSON.
- Bringing a dictionary hit back on the review page affects that document only.
- "Clear data on this device" does **not** clear the dictionary; terms are removed one by one on the dictionary page.
- No "always hide this?" prompt on the review page — it must stay one-gesture ([[docudis-tap-to-redact]]).

**Why:** same stance as [[docudis-placeholder-policy]] (a truthful placeholder beats a half-hidden name) and the privacy promise: the dictionary holds the user's most sensitive words, so it moved from SharedPreferences (included in Android backup) to `<app support>/dictionary.json`, excluded in `backup_rules.xml` / `data_extraction_rules.xml`.

**How to apply:** matching rules (accent/case-insensitive, whole word for Latin, `\s+` for spaces) live in `DictionaryDetector`; widget tests override `DictionaryNotifier.read/write`. Store listing and privacy policy do not mention the dictionary yet ([[docudis-store-materials]]).
`````

### docudis-design-clay.md

<!-- memory-file: docudis-design-clay.md -->
`````markdown
---
name: docudis-design-clay
description: "Docudis app visual direction is \"Clay\" (sand/terracotta/sage, Sora + Karla); implemented in lib/theme on 2026-09-16; design canvas URL and where the source files live"
metadata: 
  node_type: memory
  type: project
  originSessionId: 3d4ca2e8-87ff-4447-82aa-497e42692348
  modified: 2026-09-16T21:07:48.502Z
---

On 2026-09-16 the user chose direction **F · Clay** for the Docudis mobile UI, out of seven directions on the design canvas https://claude.ai/artifact/JA2XU28pDbdoCzdQHZB7rX. They said they will make modifications later.

Tokens: bg #F5EFE8, surface #FFFCF8, primary terracotta #C8623A, secondary sage #6B7F62, tertiary tan #B8926A, ink #2A2420, radius 22, Sora headings + Karla body. Full table in `design/README.md`; artboard sources in `design/mockups/`.

**Implemented the same day** (not yet verified on a phone, no device was attached): `lib/theme/clay_theme.dart` (tokens, entity highlight colours, ThemeData) and `lib/theme/clay_widgets.dart` (ClayPage, ClayCard, ClayNavBar, ...); screens in `lib/anonymize/ui/` (protect, paste, result "Protected copy", review, restore, history) plus `lib/home/account_page.dart`. Fonts are bundled variable TTFs in `assets/fonts/` (both fontWeight and fontVariations must be set; use `Clay.heading()` / `Clay.body()`). Screenshots of every screen come from `test/clay_screens_test.dart` → `test/goldens/*.png`. The four Harbor-styled flow artboards in `design/mockups/` were NOT restyled; the app follows the Clay direction artboard plus the Harbor flow layouts.

**Why:** the user wanted a modern, trust-inspiring look and picked the warm earthy option over the cooler "Harbor" default.

**How to apply:** build new Docudis screens with `Clay*` widgets and tokens, never Material indigo defaults; regenerate goldens after UI changes. Feature scope follows the design doc `docs/anonymization-design.md` (design doc wins over mockups). Related: [[docudis-anonymization-build]], [[flutter-sdk-via-scoop]].

**App icon (2026-09-17):** user picked concept A "Page masquée" (cream page with a redacted line on terracotta) out of four in `design/logo/`. `design/logo/render_icons.py` (Anaconda python) regenerates the iOS AppIcon PNGs, legacy Android mipmaps and the 1024/512 store PNGs; the Android adaptive icon is hand-written vectors (`mipmap-anydpi-v26/ic_launcher.xml`, `drawable/ic_launcher_foreground.xml`), so keep both in sync when the logo changes.
`````

### docudis-hidden-features.md

<!-- memory-file: docudis-hidden-features.md -->
`````markdown
---
name: docudis-hidden-features
description: "Which Docudis features the user asked to hide from the UI on 2026-09-17 and how the result page's \"send to\" row works"
metadata: 
  node_type: memory
  type: project
  originSessionId: 3d4ca2e8-87ff-4447-82aa-497e42692348
  modified: 2026-09-23T08:29:38.917Z
---

On 2026-09-17 the user asked to hide, not delete, these features:
- Restore flow: came back on 2026-09-23 as a restore icon next to the pencil in the result page header
  (the old restore-key card stays hidden). Manual `[CUSTOM_n]` blocks restore like any other placeholder
  (user's call). `reapply` passes the old map as `anonymize(previous:)` so edits after sending never
  renumber placeholders and un-hidden values stay restorable.
- Per-record delete menu: dropped from the result page header.
- Review page (`ReviewPage`) was hidden too, but came back on 2026-09-17 as a pencil action in the
  result page header, rewritten as a tap-only page (see [[docudis-tap-to-redact]]).
- History: the History tab was removed from the shell (`HistoryPage` still exists); the bar has only Protect and Account.
The code, strings and golden tests for all of them still exist.

Result page bottom bar: "Send to" + round logo buttons for ChatGPT and Claude (`AiApp.featured`), an
"Other" button opening a sheet with Gemini, Grok, Perplexity, DeepSeek, Copilot, Kimi, Doubao, Qwen,
Mistral; then small equal "Copy text" / "Share file" buttons. Logos are MIT-licensed SVGs from
@lobehub/icons-static-svg in `assets/ai_logos/` (rendered with flutter_svg); ChatGPT, Grok and Kimi use
mono glyphs tinted ink. Since 2026-09-17 (user request) only installed apps are shown
(`installedAiAppsProvider`); no installed app hides the whole "Send to" row. Files go out as a copy in
`records/<id>/share/<l10n.sharedFileName>.txt` ("匿名化文本.txt"), because receiving apps show the real
file name and share_plus `fileNameOverrides` had no effect on Android. Photos are named by capture time
(`CameraInput.name`, `yyyy-MM-dd HH:mm:ss.jpg`). Qwen's Play package is `com.tongyi.intl` (Qwen Team);
`com.aliyun.tongyi` is the mainland build, absent from Play. Android `<queries>` and iOS `LSApplicationQueriesSchemes` list every app;
iOS schemes for the non-featured apps are guesses.

**Why:** the user wants the MVP surface minimal; restore/review can come back later.

**How to apply:** do not re-add entry points for hidden features unless asked; to add an AI app,
extend `AiApp`, add its logo, manifest package and plist scheme. Related: [[docudis-home-minimal]],
[[docudis-design-clay]].
`````

### docudis-home-minimal.md

<!-- memory-file: docudis-home-minimal.md -->
`````markdown
---
name: docudis-home-minimal
description: "User wants the Docudis home tab radically simple - no app title, no on-device badge, no recent list; inputs are staged in place with confirm/cancel"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 3d4ca2e8-87ff-4447-82aa-497e42692348
  modified: 2026-09-17T11:09:46.403Z
---

On 2026-09-17 the user asked to strip the Docudis home tab down, then approved this
layout ("方案 B"): two-line Sora headline + one lock caption ("runs on this phone"), a
filled terracotta "Paste text" card as the primary path, "Upload a document" and "Scan a
photo" as two half-width cream cards, the whole block vertically centred. No app title,
no badge, no Recent list, no card subtitles. "Paste text" reads the clipboard directly.
A chosen input is staged in place: icon + cancel cross, preview (max 2x card height),
full-width Anonymize button; the other two entries shrink to chips below.

**Why:** the user finds the marketing-style header and hints noise; they want the fewest
possible taps and to see what will be processed before it runs.

**How to apply:** keep the home tab to headline + caption + three cards; do not re-add
headers, badges or recent items there (history lives in its own tab). Reuse the
staged-card pattern (`_StagedCard` in `lib/anonymize/ui/protect_page.dart`) for any new
input type. Related: [[docudis-design-clay]].
`````

### docudis-model-hosting-mac-move.md

<!-- memory-file: docudis-model-hosting-mac-move.md -->
`````markdown
---
name: docudis-model-hosting-mac-move
description: "Model binaries on private HF repo leonx1995/docudis-ner-xlmr via manifest + tool/fetch_models.py (2026-09-23); Mac move for iOS, what stays Windows-only and what must be copied by hand"
metadata:
  node_type: memory
  type: project
  originSessionId: e273682c-3f32-458f-b2c1-f79bf1f3763f
  modified: 2026-09-23T14:32:02.612Z
---

2026-09-23: the user is moving docudis development to a Mac to build the iOS version (Android phone debugging continues there).

- Shipped model `xlmr_ner_docudis` uploaded to the **private** HF repo `leonx1995/docudis-ner-xlmr` (user chose private). `assets/models/manifest.json` pins it and the two stock models (repo, revision, SHA-256); `tool/fetch_models.py` downloads and checks them (needs `huggingface_hub` and `huggingface-cli login`). Commit ae67460.
- After a retrain: upload to that repo, then update the revision and SHA-256 in the manifest (steps in assets/models/README.md).
- User's decision: **model training and the docudis_pdf desktop redaction test stay on Windows only**. training/README.md keeps its Windows paths on purpose; other docs/scripts use `$PYTHON` (commit 3593c33).
- Still copied by hand to the Mac (not in git): `.env`, `android/key.properties` + `C:\Users\Xia\keys\docudis-upload.jks`, `android/app/google-services.json`, `lib/firebase_options.dart` (or rerun flutterfire configure), and this memory folder.

Full restore steps and every memory verbatim: `docs/HANDOFF-macos-2026-09-23.md`.

**Why:** these facts are not all in the repo, and a Mac session would otherwise try to port training or look for the model on disk.
**How to apply:** on a fresh clone, run fetch_models.py rather than asking for the model to be copied; do not port training or PDFium tests to macOS unless the user asks. Related: [[docudis-ner-finetune-plan]], [[docudis-pdf-redaction]], [[flutter-sdk-via-scoop]].
`````

### docudis-ner-finetune-plan.md

<!-- memory-file: docudis-ner-finetune-plan.md -->
`````markdown
---
name: docudis-ner-finetune-plan
description: "The 2026-09-19..21 NER fine-tune line: the user's standing decisions, what shipped, and the two open questions left"
metadata:
  node_type: memory
  type: project
  originSessionId: 20ef8db0-ca5b-4e44-8c7b-1cfbdce4e15e
  modified: 2026-09-21T12:47:44.870Z
---

**Shipped 2026-09-21** on `store-materials-and-detection-precision`: `assets/models/xlmr_ner_docudis`, our own
fine-tune of `Davlan/xlm-roberta-base-ner-hrl` for en/fr/es, plus ID rules, span completion and company rules.
Consumer set (60 frozen documents): documents with no identifying leak **11 → 36**, leak rate 18.7% → 4.8%;
public records 7.3% → 2.1%. Five commits, `270fb4f`..`c95cce1`.
Everything — per-step results, every trap hit, what is left — is in `docs/HANDOFF-ner-finetune-2026-09-19.md`
sections 3.5a–3.5f. Read that before touching this line of work; this memory only holds what the repo does not say.

**The user's standing decisions** (asked explicitly, do not re-litigate):
- one full fine-tune for en/fr/es, not per-language LoRA; regression in Chinese and the other base languages accepted;
- a local body's name is not labelled but **the place inside it is ADDRESS** (`Nantes` in `CPAM de Nantes`);
- the jurisdiction in `Registered in England and Wales No. 929027` is **not** an address — it says where a company
  was incorporated, not where anyone is (decided 2026-09-21, seven labels removed from the frozen consumer set);
- acceptance criterion 3 is now "no false positive that hides a common word", not "zero false positives"
  (decided 2026-09-21 over `C. Domicilio`, a sentence I had invented for the hard negatives in the first place).

**Decided 2026-09-21 (evening):** the user accepts acceptance criterion 1 as **passed** — the leaks left on the
frozen consumer set "do not entirely count as leaks". The 95% target is dead; do not re-open it. What the user
asked for instead was a **second, held-out set** to check the fine-tune and the new rules for regressions:
`benchmark/regression/` (48 documents, frozen, never to be used for writing rules or training material — same
prohibition as the other test sets). Result and the one fix it produced: `docs/ner-regression-2026-09-21.md`
and section 3.5g of the handoff.

**One question still waiting on the user:**
1. Place names in prose — `Sa fille Céline habite Sin-le-Noble`, `chantiers à Morat`, `The Leeds Teaching
   Hospital`. Nine of the remaining leaks. Hiding them costs readability; leaving them exposes a relative's town.
   Same kind of judgement as the footer question above, so ask, do not decide it.

**Why:** the next session will otherwise redo work that is finished, or re-open decisions the user has already made.

**How to apply:** never read `benchmark/consumer/`, `benchmark/public/`, `benchmark/regression/` or the hard negatives when writing training
material — rules may be measured against them, training material may not. Score a candidate rule with
`tool/try_rule.py` before writing it, and always diff per-entity status against the previous run: a change can
improve every summary number while quietly turning half-hidden values back into full leaks. Device speed needs the
median of three runs; one reading swings 28%. Training needs the GPU to itself — another process holding it makes
PyTorch spill to system memory and run ten times slower with no error. Related: [[docudis-span-repair]],
[[docudis-anonymization-build]], [[docudis-target-market]], [[docudis-placeholder-policy]].
`````

### docudis-ocr-reading-order.md

<!-- memory-file: docudis-ocr-reading-order.md -->
`````markdown
---
name: docudis-ocr-reading-order
description: "OCR text is built in page order by ImageLayout.read since 2026-09-23 (not ML Kit result.text); results, the two-column cost, and why the photo test set was deferred"
metadata:
  node_type: memory
  type: project
  originSessionId: a0c5e5db-1bb2-4b50-94d0-7f75a91e33fc
  modified: 2026-09-23T09:13:20.264Z
---

2026-09-23: the user asked how to improve image OCR accuracy. Plan given, in order: (1) a real-photo test set
(30 consumer_cases en/fr/es rendered as realistic layouts, printed, photographed on the S26, scored as leak
rate against the pasted-text baseline), (2) page reading order, (3) ML Kit document scanner, (4) tiling A4,
(5) PP-OCRv6 on ONNX Runtime; VLMs (GLM-OCR) ruled out, no word boxes. The user deferred (1) ("later") and had (2) done.

(2) done, committed 53b042d: `ImageLayout.read` in lib/anonymize/image_redaction.dart; device numbers and the known cost
are written in docs/anonymization-design.md (OCR 阅读顺序). Normalized CER 53.3% → 10.3%, detection on the OCR
text neutral (37 → 36 missed of 71). Cost: side-by-side columns (business cards, letterhead address + right date)
interleave; may weaken repair.dart's address-block line rule.

Phone retest the same day (debug build, uploaded fr letter / en bank statement / es invoice, invented data):
table rows read perfectly; leaks: phone numbers read as `o113 496 o721` / `o6` (0 → letter o in Georgia's
old-style figures; rules miss them), and "Leeds" (address-block line rule broken by the joined right column).
Spans cross the tab between cells (address ate the company name, a number ate the amount 41.60).
Fixed the same day in RegexDetector (user approved a + b): o/O read as 0 in digit tokens (same-length view), no
match spanning a tab (second pass on a tab-blocked view). Desktop A/B on 6 standard sets: identical entity by entity.
Phone retest: both phones and the company cell fixed, 41.60 visible again. Still open: address-block rule per column
("Leeds"). New finding: ML Kit Entity Extraction (`mlkit-entity`, phone only, not in desktop benchmarks) tags
amounts "250.00"/"120.00" and an account number as PHONE; it was silent in the first round because its language
model re-downloads after a reinstall — compare detector counts in records/<id>/detections.json before blaming a change.
Quota counter was set 0 for the retest via run-as sed and restored to 3.
Warning: `flutter test integration_test/...` uninstalls the app afterwards and wipes its data (records, quota counter).

**Why:** the 15-case OCR set cannot tell tables from two-column layouts; no heuristic was added on purpose.

**How to apply:** when the photo set from (1) exists, measure letterhead/two-column leaks before tuning the row
grouping. A/B with `--dart-define=OCR_ORDER=mlkit` on integration_test/ocr_benchmark_test.dart. Related:
[[docudis-phone-walkthrough-2026-09-19]], [[docudis-span-repair]], [[docudis-target-market]].
`````

### docudis-pdf-redaction.md

<!-- memory-file: docudis-pdf-redaction.md -->
`````markdown
---
name: docudis-pdf-redaction
description: "Route B (true PDF text removal via PDFium edit API) lives in packages/docudis_pdf, not wired into the app; PDFium constraints found, how to run the desktop test"
metadata: 
  node_type: memory
  type: project
  originSessionId: 09829e69-7bd1-4f28-9d1e-db22ea6d20a6
  modified: 2026-09-18T08:30:44.153Z
---

Started 2026-09-18. User chose route B (delete text objects from the content stream, keep vector PDF) over route A (rasterize pages). Code: `packages/docudis_pdf` (pure Dart; `redactPdf(bytes, [PdfRedaction(pageIndex,start,end,label)])`, indices = pdfrx `loadText()` char indices). **Not wired into the app yet** (user's explicit instruction). Uses only what pdfrx 2.6.1 already ships: `pdfium_dart` FFI bindings, run on pdfrx's worker via `PdfrxEntryFunctions.instance.compute`.

Non-obvious PDFium facts learned (verified in source / by test):
- New page objects are ALWAYS written to a new content stream appended at the end, so they draw on top; `FPDFPage_InsertObjectAtIndex` order does not survive save. No API to set an object's clip path either.
- Hence hidden text (under a later opaque rectangle, or clipped away) must not be re-created or labelled. Chrome/HTML-to-PDF payslips really do this: the test file's page 1 carries page 2's whole header (name, address, SSN) under a white rect. Cover detection is tested; the clip-path branch is NOT exercised by any file yet.
- No getter for charcodes/char spacing: surviving words are rebuilt per word with `FPDFText_SetText` (needs ToUnicode), verified by bounds, fallback per character; failures mark the page in `failedPages` for a future raster fallback (route A, not written).
- Labels: standard Helvetica (ASCII only, regular weight even if source was bold), shrunk to the replaced text's width so they never overlap neighbours (can get tiny).

**How to apply:** Desktop test, from `packages/docudis_pdf`: set `PDFIUM_PATH=C:\Users\Xia\projects\docudis\.dart_tool\lib\pdfium.dll`, then `dart run tool/redact_pdf.dart <in> <out> <term>...` (checks text is gone + pixel diff outside redactions). `tool/anonymize_pdf.dart <in> <out> <lang> [term...]` drives it from docudis_engine (regex + lists + terms via DictionaryDetector; NER/ML Kit are phone-only) and mirrors TextExtractor._pdf's text assembly to map detection offsets -> page char indices; passed on the payslip 2026-09-18 (56 spans, no leak, identical rendering). Engine precision issues it exposed on that payslip, not yet fixed: `ch:street-french` swallows the postal code ("rue Jules Verne 92300", leaving "36" and the city), SIRET labelled CARD, `long_number` false positive across table cells ("9750 3 787"), amounts without € not detected. To avoid the pdfium_dart build hook downloading, copy the dll to `packages/docudis_pdf/.dart_tool/hooks_runner/shared/pdfium_dart/build/chromium_7811/win-x64/`. Read tool cannot render PDFs here (no pdftoppm); render to PNG with pdfrx + `image` package instead. Test file used: user's own payslip in Downloads (personal data; keep outputs in scratchpad). Related: [[docudis-anonymization-build]], [[docudis-tap-to-redact]].
`````

### docudis-phone-walkthrough-2026-09-19.md

<!-- memory-file: docudis-phone-walkthrough-2026-09-19.md -->
`````markdown
---
name: docudis-phone-walkthrough-2026-09-19
description: End-user walkthrough of paste / upload / photo on the S26 Ultra with the 2026-09-19 debug build; defects found (none fixed) and how to drive the phone over adb
metadata: 
  node_type: memory
  type: project
  originSessionId: d93456ae-4882-4cc1-8793-175b08b764ec
  modified: 2026-09-19T14:49:48.418Z
---

On 2026-09-19 the working tree was installed over the phone's debug build (`flutter build apk --debug` +
`adb install -r`; release APK has no model and a different key, so debug is the only in-place update) and the
three home entries were tested with invented fr / en / es documents. Nothing was fixed afterwards.

Defects seen (all reproducible from the test texts, see [[docudis-rule-audit-2026-09]], [[docudis-placeholder-policy]]):
- An ID that fails its checksum (French NIR with a wrong key) is half-hidden: the head "2 88 03 44" stays
  visible and the tail becomes `[PHONE_n]`. With a valid key it is one `[ID_1]`.
- Wrong `PHONE` type instead of `NUMBER`: fr "dossier n° 2026-44871", UK 8-digit bank account number.
- Two people sharing a surname (Eleanor / Thomas Whitcombe) get the same `[PERSON_1]`.
- A signature block "Priya Raman\nAccounts Manager" became `[COMPANY_2] Manager` (span crosses the line break).
- OCR path: "citas@ sonrisasur-ejemplo.es" (space after @) leaked the e-mail; a phone wrapped over two lines
  ("954 21\n07 65") leaked. **Fixed the same day in the rules, not by rewriting OCR text** (offsets must stay
  valid for the image boxes): email allows one space each side of @; `es:phone` knows 3-2-2-2 and 2-3-2-2;
  `fr:phone` with spaces may wrap to the next line. Benchmarks unchanged before/after. Not re-checked on the
  phone: only the real OCR text (pulled with `run-as ... cat files/records/<id>/original.txt`)
  was run through the engine. Still open: right-aligned date line moved far down in reading order.
- Found while fixing, not fixed: `universal:long_number` ends with `(?![.\d])`, so a number before a full stop is
  cut short ("... 954 21 07 65." hides only "954 21 07" when no phone rule takes it).
- UI: "Copy text" shows the app snackbar and the Android system toast together; the text-less photo error says
  "无法从该输入中读取文字" with no retake shortcut; an uploaded image has no thumbnail while a camera photo has.

**Why:** the user asked for an end-user impression, not fixes; these are the open items from it.

**How to apply:** treat the list as candidate work, confirm with the user before fixing. Driving the phone:
`cmd clipboard` does not exist on this One UI build — serve a page with Anaconda `python -m http.server`,
`adb reverse`, open it in Chrome, long-press → 全选 → 复制. Use a fresh port: 8765 had a stale server from an
earlier session. The camera cannot be aimed over adb; test OCR by uploading a rendered image instead
(headless Edge `--screenshot`).
Env setup: [[flutter-sdk-via-scoop]].
`````

### docudis-phone-walkthrough-2026-09-23.md

<!-- memory-file: docudis-phone-walkthrough-2026-09-23.md -->
`````markdown
---
name: docudis-phone-walkthrough-2026-09-23
description: "Second end-user test on the S26 (build of 2026-09-23 11:09); defects, root causes and fixes verified on the phone, committed 53b042d"
metadata:
  node_type: memory
  type: project
  originSessionId: 5cab7dc1-8df2-4a62-8c62-9299edfd2680
  modified: 2026-09-23T10:52:49.346Z
---

On 2026-09-23 the user asked for an honest real-user test. Tested
paste (fr rental email, en patient message, es electricity complaint), the Chrome text-selection entry,
a payslip PDF, a tilted letter photo (uploaded), send to ChatGPT (not sent), and restore.

Good: text under 1 s, PDF ~2 s, photo ~4 s; the photo's redacted image was clean; restore round trip worked;
no names/emails/phones/IBANs/addresses leaked in 6 documents.

Defects (not fixed):
- Leaks: es CUPS (electricity supply ID) has no rule; a DNI with a wrong check letter after the word "DNI" leaks whole.
- Mme Garnier and M. Julien Garnier → same [PERSON_1] (shared-surname merge still open, see [[docudis-phone-walkthrough-2026-09-19]]).
- Street + postal code split into glued `[ADDRESS_2][ADDRESS_3]`, separator swallowed; the same street gets a different number the second time.
- Spans eat words: "from St Luke's on" → "from [ADDRESS_1]"; payslip "4941A\nURSSAF…\nSalarié" is one ADDRESS (the heading is lost); the label "SIRET" itself → ADDRESS.
- Wrong types: NHS number → PHONE (us:phone), matricule → PHONE, the same contract number was NUMBER on one run and PHONE on the next.
- UX: the text-selection "匿名化" entry is last in the menu, has no app name, and copies silently without showing what was hidden; "拍照识别" opens the camera with no gallery; with no History tab, restore only works for the record currently open.

Root causes (investigated the same day, reproduced on desktop with a fake ML Kit detector, nothing fixed):
- DNI: `RegexDetector.detectSync` drops a match whose validator fails; `long_number` cannot fall back on a digits+letter token (`\b`). CUPS: no rule anywhere.
- Glued `[A][B]` + same address renumbered: `repairSpans` loop 1 grows the winner over an overlapping ML Kit ADDRESS up to the next span, eating ", "; `_joins` then sees an empty gap. The value now ends in ", ", and `PlaceholderMap` keys on the exact value. Rules alone give the right output.
- PHONE labels: ML Kit phone goes in at model priority (beats loose rules' NUMBER); the `typeFor` NUMBER downgrade is regex-only. An NHS number with a bad check digit falls to `us:phone`.
- "on" is an `_addressWord`; ML Kit address spans across lines are not filtered; `_isPersonVariant` merges a lone surname into a full name.
- The ML Kit entity detector is in no test or benchmark, which is why none of this showed up.

**Fixed later on 2026-09-23 (user: "1,2,3 全修"), committed 53b042d:** `universal:named_national_id` (label → NUMBER, 0.88,
CIF kept on purpose: +2 on the regression set) + `es:cups` (validator `cups`); repair loop 1 leaves a joinable gap to the join
and never ends on a separator; `anonymize` keeps edge separators outside the placeholder and passes an honorific gender to
`PlaceholderMap` (conflicting genders do not merge); address runs do not end on a particle; model spans across a line break
drop title lines; ML Kit: cross-line spans dropped, bare-digit PHONE → NUMBER. Leaks unchanged or better on every set
(regression 7.1 → 6.8%); synthetic F1 97 → 94 only because street+town+postcode now join into one span (scorer artefact,
leak 0%). Tags `pre0923` / `post0923` in docs/benchmark. **Verified on the S26 the same day** (paste A/B/C, valid C,
payslip PDF, letter photo): all walkthrough defects gone. The phone found two more, fixed then: a label on the line
before its value, and ML Kit PHONE with a letter in it ("30567812W") → now any ML Kit phone without +/brackets is NUMBER.
Still open: NER tags the word "SIRET" as ADDRESS; OCR "ESg1" (IBAN check digits misread) stays visible.

**Why:** users lose trust after one leak or a wrong label.

**How to apply:** treat as candidate work and ask before fixing. Git Bash needs `MSYS_NO_PATHCONV=1` for adb push/shell paths. Related: [[docudis-placeholder-policy]].
`````

### docudis-placeholder-policy.md

<!-- memory-file: docudis-placeholder-policy.md -->
`````markdown
---
name: docudis-placeholder-policy
description: "User's stance (2026-09-18) on what the anonymized text should look like for the downstream LLM - NUMBER over a wrong type, amounts and non-birth dates left visible, single-language documents only; implemented 2026-09-18 incl. store copy and hide-all switches on the review page"
metadata: 
  node_type: memory
  type: project
  originSessionId: 03f8e081-edb1-4f31-827b-2552d6a7ba20
  modified: 2026-09-18T09:09:07.089Z
---

Stated by the user on 2026-09-18, after the real-document test sets were built:

- **Single-language documents only in this version.** Multilingual files are rare in practice; do not spend time on per-paragraph language detection or multilingual test cases. Language-detection tests can be set aside.
- **A generic label beats a wrong label.** When a digit string cannot be typed with confidence, the placeholder should say "this is a number" rather than guess ID / PHONE / CARD. A wrong type can mislead the LLM that analyses the anonymized text.
- **Amounts may stay visible.** If the rest of the document is anonymized well, money amounts do not need to be replaced: the LLM often needs them for the analysis the user is asking for.
- **Dates: only birth dates are hidden by default** (agreed 2026-09-18). A date counts as a birth date only through a context keyword (born / date of birth / né(e) le / date de naissance / fecha de nacimiento / nacido el); no guessing from an old year. Every other date is detected but left visible, same mechanism as amounts. Store copy must not claim "hides all dates".

**Why:** the anonymized text is input for another LLM, so its usefulness for analysis matters as much as hiding identifiers; the placeholder vocabulary is part of the product, not just an internal detail.

**How to apply:** prefer fewer, truthful placeholder types; keep detection running for amounts (so they can be toggled and measured) but do not replace them by default; count amounts separately in the leak report. Engine side implemented 2026-09-18 (uncommitted at the time): `RegexDetector.typeFor` (NUMBER), `DetectionPipeline.withDefaults` (amounts and non-birth dates off, BIRTH_DATE via `rules/birth_date.dart`), leak report counts them separately; design doc section "占位符要对下游模型说真话". Loose phone rules follow the same NUMBER downgrade (`ie:phone` lowered to 0.75 because it fired on a UK company number). User decisions the same day: bulk control first declined, then requested and built the same day: two switches "Hide all amounts" / "Hide all dates" at the top of the review page, shown only when the document has such detections (the dates switch never touches BIRTH_DATE); **`fr:siret` stays NUMBER**, no Luhn validator; store listing and screenshots were changed to "dates of birth" with amounts and other dates left readable. Benchmark datasets label dates of birth `BIRTH_DATE`, scored strictly apart from DATE. Related: [[docudis-anonymization-build]], [[docudis-target-market]], [[docudis-tap-to-redact]].
`````

### docudis-rule-audit-2026-09.md

<!-- memory-file: docudis-rule-audit-2026-09.md -->
`````markdown
---
name: docudis-rule-audit-2026-09
description: "Rule-pack audit of 2026-09-18 (regex + pipeline, no NER run) — confirmed conflicts and false positives, none fixed yet; how the probes were run"
metadata: 
  node_type: memory
  type: project
  originSessionId: dad61838-8511-43ea-95f9-646e7fa7b6ba
  modified: 2026-09-19T15:35:16.855Z
---

Audit requested by the user on 2026-09-18; findings reported in chat, **nothing fixed yet** (user has not chosen what to fix). All confirmed by running `RegexDetector.bundled(regions)` + `withDefaults` + `merge` on probe sentences (scratch Dart package with a path dependency on `packages/docudis_engine`; NER and ML Kit not run).

Checked 2026-09-19: "nothing fixed" is out of date. `test/rules_test.dart` has a group "rule audit fixes (2026-09-18)"
covering five items — dotted/hyphenated French phone vs `ipv4`, `phone_intl` ending with its line, labelled SIRET as a
number instead of CARD, Eircode alphabet, capitalised English streets ("10 minute drive"). Verify each remaining item
against the current rules before treating it as open.

Confirmed, by severity:
- **Leaks:** dotted French phone `01.23.45.67.89` → `universal:ipv4` takes four groups, `.89` stays (fr:phone only accepts spaces); `universal:phone_intl` uses `\s` so it crosses a line break and eats the first digits of the next line's postcode (`08 Paris` left); a default-off DATE wins the overlap and erases an enabled span (`gb:sort_code` 20-05-17 vs `date_numeric_short`; `date_word` "54 Bruxelles 1050" beats `be:street`); es landline `91 234 56 78` → partial; `us:phone` has no left boundary.
- **Wrong type:** every unspaced SIRET is Luhn-valid → `universal:credit_card` CARD (validated, top priority); `gb:nhs` (1/11) + `us:npi` (1/10) turn ~20% of bare 10-digit numbers into ID and beat `us:phone`; `es:phone` types 43% of 9-digit numbers PHONE; `es:cif` takes `F20240015`; `us:zip_plus4`/`us:ein` take reference numbers; `universal:labeled_id` takes "Period: June 2024", "Re: Your 2024", "Montant : 125000".
- **Prose swallowed (strong rules beat the model):** `ie:eircode` with `i` flag on all English ("B12 with", "M25 near", "P604512"); `gb:street`/`us:street` with `i` flag ("10 minute drive", "15 percent rise"); `fr:street` greedy tail + "1 place de parking"; `be:street`, `ch:street-french`, `ch:street-german` load for all French ("place depuis 2019", "placement de 500", "terrain 250"); `es:street` ("Camino de Santiago 2024"); postal rules ("10000 Actions"); company rules join two parties through and/for/et/y ("Alice Martin and Beta Corp."), "The Company" propagates; `labeled_company` takes "Néant"/"N/A"; name-part propagation is case-insensitive ("Katie Price" → every "price"), non-ASCII terms have no word boundary ("René" inside "Renée"); birth label `\bborn` matches French "borne", `naissance` matches "naissance de la société".
- de/at/it/nl/pl/se/no/dk/fi/pt packs are still the untuned DocCloak originals (low priority per [[docudis-target-market]]).

**Why:** the user wants conflicts and likely misjudgments removed before release; type truthfulness matters per [[docudis-placeholder-policy]].

**How to apply:** when asked to fix rules, start from this list; edit `packages/docudis_engine/rules/*.json`, then `dart run tool/embed_rules.dart`; re-run the benchmark in [[docudis-anonymization-build]] before and after.
`````

### docudis-span-repair.md

<!-- memory-file: docudis-span-repair.md -->
`````markdown
---
name: docudis-span-repair
description: "repairSpans step added 2026-09-19 between overlap resolution and propagation (commit 8fbf347); what it does, what was tried and dropped, numbers before/after, verified on the phone; address-block line rule added 2026-09-21"
metadata: 
  node_type: memory
  type: project
  originSessionId: 20ef8db0-ca5b-4e44-8c7b-1cfbdce4e15e
  modified: 2026-09-19T15:35:07.765Z
---

2026-09-19: `packages/docudis_engine/lib/src/repair.dart` (`repairSpans`), called from `DetectionPipeline.run` only
(never from `merge`, which re-runs on what the user toggled). Tests in `test/repair_test.dart`; contract paragraph in
`docs/anonymization-design.md` under 冲突裁决.

Why it exists: 40 of the 66 exposures in the public-record leak report were half-hidden entities, always right next
to a hidden span. And the half-hidden French NIR seen on the phone ([[docudis-phone-walkthrough-2026-09-19]]) was
**not** a checksum problem: ML Kit's PHONE on the tail (`model`, 20) beat `universal:long_number` over the whole
string (`rule`, 10), and the loser's head was left showing. Same cause for "dossier n°" and the UK account number
typed PHONE.

What it does: a same-kind loser of an overlap is grown over (number kinds → NUMBER); capitals after an all-caps
PERSON/COMPANY (max 3 words) and only a caps name particle before it; digit groups next to a number; unit / house
number before an ADDRESS; joins same-kind neighbours over a particle (names) or over address filler that contains
something to hide.

Tried and dropped, with the reason:
- growing all-caps names to the left over any capitals: BORME sentences are all caps ("SIENDO SOCIO UNICO MARIA …"),
  the absorbed words then spread through name-part propagation (over-redaction 73 → 81).
- joining "street, town" over a bare comma: hides nothing and turned synthetic F1 97 → 88 purely through the
  value-based scorer (one detection can match only one expected entity).

Numbers (desktop, XLM-R): public leak 9.5% → 7.2% (partial 40 → 24, leaked 26 unchanged), synthetic 1.5% → 0.9%,
over-redaction 73 → 68, F1 97 / 86 / 97 unchanged, hard negatives 0.

**Verified on the S26 Ultra 2026-09-19:** pasting "1 91 05 75 109 042 17" (wrong key) gives one `[NUMBER_1]`.
Use a head that is not in the phone's "Always hide" dictionary: it holds a leftover test term "2 88 03 44", which
turns the original test number into `[CUSTOM_1][NUMBER_1]`. "dossier n° 2026-44871" is still typed PHONE by ML Kit.
Committed as `8fbf347` with only this line of work: `pipeline.dart` and the design doc were staged as HEAD + these
hunks (blob built with `git hash-object` / `update-index --cacheinfo`) because other sessions had uncommitted edits in
the same files; the benchmark reports were left uncommitted for the same reason.

**2026-09-21, fourth rule** (`_addressBlockLines`): a line whose neighbours above and below are both address lines
becomes its own ADDRESS span — the town alone on its line in a letterhead, which the fine-tuned model stopped
tagging. Found by the held-out regression set, not by the frozen ones ([[docudis-ner-finetune-plan]]). A neighbour
counts as an address line only when **three fifths of what it prints is already hidden as an address**; "the line
contains a place name" was the first version and it ate a CV's job title. Consumer set 36 → 40 / 60 clean, no set
gained an over-redaction.

**How to apply:** Still open: mixed-case "Roche, Jean" / "Hammond, Don", BORME "CL xxx NUM.n" streets (missing rule), the model tagging
"Name\nDepartment" across a line break as COMPANY, and the 26 full leaks (model blind spots: lowercase first names,
acronyms, all-caps trade names). Run `tool/run_all_benchmarks.sh --no-stress` before and after any change here.
Related: [[docudis-anonymization-build]], [[docudis-rule-audit-2026-09]].
`````

### docudis-store-materials.md

<!-- memory-file: docudis-store-materials.md -->
`````markdown
---
name: docudis-store-materials
description: "Play store listing state — personal dev account (12 testers/14 days rule), contact email, where copy/policy/screenshots live, what copy must not mention"
metadata: 
  node_type: memory
  type: project
  originSessionId: 5c71b138-b115-441b-86fa-4bad540d2e4b
  modified: 2026-09-17T14:51:25.594Z
---

As of 2026-09-17: Google Play developer account is **personal** (so production needs a 12-tester, 14-day closed test first). Contact email: stonetechdigital@gmail.com. Developer display name not yet confirmed; the privacy policy avoids naming it.

Drafts made 2026-09-17: `docs/store/privacy-policy/index.html` (en/fr/zh, hosting not decided), `docs/store/listing.md` (+ `check_listing.py` length check), screenshots and feature graphics rendered by `test/store/` and exported to `design/store/play/` via `design/store/export_play_assets.py`. zh screenshots need Noto Sans SC from C:/Windows/Fonts.

**Why:** the user decided the PROCESS_TEXT menu / Quick Settings tile ships but is not described or shown in the store for now; hidden features (restore, history, review) also stay out of the copy. Play Console answer sheet is `docs/store/play-console.md`.

**How to apply:** keep store copy and screenshot captions (`_captions` in test/store/store_screenshots.dart) in sync. The Data safety form must declare ML Kit diagnostics, so don't answer "collects nothing". Related: [[docudis-hidden-features]], [[docudis-design-clay]].
`````

### docudis-tap-to-redact.md

<!-- memory-file: docudis-tap-to-redact.md -->
`````markdown
---
name: docudis-tap-to-redact
description: "The second-pass edit page is tap-only (no confirm button, no type picker) and its one-tap blocks come from the engine's rule-based chunkText; decided 2026-09-17"
metadata: 
  node_type: memory
  type: project
  originSessionId: d42871e6-e676-4203-b061-7722cd7a40ae
  modified: 2026-09-17T19:05:35.882Z
---

Decisions the user made on 2026-09-17 for the page after anonymization (`ReviewPage`, reached by the
pencil in the result page header):

- **Phrase-level blocks**, not whole lines: one tap covers a name, a number group or a street address.
- **Tap applies immediately** — the tapped text turns into its placeholder in place, tapping the
  placeholder brings the value back, and there is no confirm button.
- **One generic type** for manual blocks: everything the user taps becomes `[CUSTOM_n]`; no type picker.

Blocks come from `chunkText()` in `packages/docudis_engine/lib/src/chunker.dart` — pure rules, no word
segmentation model; the rule set and its known tradeoffs are written up in `docs/anonymization-design.md`.
Accepted weak spots: Chinese redacts a whole clause per tap, a sentence-initial capitalised word glues
to the name after it, OCR's in-word double spaces cut a word in two.

**Why:** the user wants the page as simple as possible — "点一下就能匿名化某块文字" — and asked for the
segmentation mechanism to be designed from scratch, since there was none.

**How to apply:** keep this page one-gesture; put new segmentation rules in `chunkText` with a test in
`packages/docudis_engine/test/chunker_test.dart`, and check tap behaviour with `test/review_tap_test.dart`.
Related: [[docudis-hidden-features]], [[docudis-anonymization-build]].
`````

### docudis-target-market.md

<!-- memory-file: docudis-target-market.md -->
`````markdown
---
name: docudis-target-market
description: "Docudis primary users speak English, French and Spanish; Chinese is low priority (budget) — drives engine defaults, benchmark effort, OCR script, store priorities"
metadata: 
  node_type: memory
  type: project
  originSessionId: 5c71b138-b115-441b-86fa-4bad540d2e4b
  modified: 2026-09-17T16:01:55.791Z
---

Stated by the user 2026-09-17: the target audience is mainly English and French speakers; Chinese is secondary. The earlier design doc assumed China as the "home market".

Done the same day: the cn rule pack is no longer always on. It turns on for detected zh, or for Han characters in non-Japanese text (`RegexDetector.regionsForLanguages(tags, text)`). Two en/fr business cases were added to `benchmark/ner_cases.json`.

OCR: settled 2026-09-17 on the phone — the Chinese recognizer stays the default even for English/French. The Latin recognizer matched it on 12 of 13 Latin cases and was much worse on a low-contrast French receipt (it reads the receipt as two columns). Report: `docs/benchmark/ocr-recognizer-comparison.md`; rerun the comparison with `--dart-define=OCR_LATIN_SCRIPT=latin`.

Rules fixed 2026-09-17 after the same session: `universal:postal_city` now needs a capitalised city word and a postal-code-shaped number (it used to label "482913 for", "350000 units", "2024 en" as ADDRESS), and `universal:currency_symbol_suffix` gained € and £ so French-style `12 450,00 €` is detected. Desktop benchmark went F1 91% → 94%, precision 91% → 96%, fr 82% → 94%, zh unchanged. Rules are edited in `packages/docudis_engine/rules/*.json`, then `dart run tool/embed_rules.dart` regenerates `rules_data.dart`.

Open: `universal:labeled_id` flags "ticket #845210" as an ID (its documented "Ref: 987654" behaviour). Left as is, benchmark gold not adjusted; the user knows.

Restated 2026-09-18 with the budget in mind: Chinese users will be very few, so Chinese testing and tuning is low
priority; the languages that matter are English, French and Spanish. Chinese-only work (cn rule prefixes, the
Chinese place list, zh stress-case errors) should not be the next thing to spend time on.

**Why:** defaults tuned for Chinese hurt precision for the users who matter most.

**How to apply:** when choosing defaults, benchmark cases or store-copy effort, put en/fr first. Related: [[docudis-anonymization-build]], [[docudis-store-materials]].
`````

### docudis-version-bumps.md

<!-- memory-file: docudis-version-bumps.md -->
`````markdown
---
name: docudis-version-bumps
description: Never bump pubspec version/versionCode on my own — ask the user before every change
metadata: 
  node_type: memory
  type: feedback
  originSessionId: fe5249e6-89ee-413c-8c65-29c8ecc974e1
  modified: 2026-09-17T18:30:02.178Z
---

Set `version: 1.0.0+1` in `pubspec.yaml` on 2026-09-17 (was 0.1.0+1) for the first Play upload. The user approved that bump and asked to be consulted before every later one.

**Why:** Play refuses an upload whose versionCode is not higher than the last, and a wasted versionCode cannot be reused — the user wants to own that number rather than have it move silently.

**How to apply:** Before editing `version:` in `pubspec.yaml`, ask which version name and code to use. Related: [[docudis-anonymization-build]].
`````

### flutter-sdk-via-scoop.md

<!-- memory-file: flutter-sdk-via-scoop.md -->
`````markdown
---
name: flutter-sdk-via-scoop
description: Flutter, JDK 17 and Android cmdline SDK are installed through scoop on this machine; tool shells need their bin dirs prepended to PATH
metadata:
  type: project
---

Installed on 2026-09-16 via scoop (no Android Studio, no Xcode on this Windows machine):
- Flutter 3.47.4: `C:\Users\Xia\scoop\apps\flutter\current\bin` (no shim in scoop/shims, must add this dir explicitly)
- Temurin JDK 17: `C:\Users\Xia\scoop\apps\temurin17-jdk\current` (JAVA_HOME)
- Android cmdline-tools + platform-tools + platforms;android-36 + build-tools;36.0.0:
  `C:\Users\Xia\scoop\apps\android-clt\current` (ANDROID_HOME); sdkmanager in `cmdline-tools\latest\bin`, adb in `platform-tools`
- `flutter config --android-sdk / --jdk-dir` already points at those dirs.
- SDK licenses accepted (user consented) by writing hash files into `<ANDROID_HOME>\licenses` because sdkmanager's interactive prompt cannot read stdin from the tool shell.

**Why:** The Bash/PowerShell tool shells do not pick up PATH changes made by scoop, so `flutter`, `adb`, `sdkmanager`, `java` all fail with "command not found".

**How to apply:** Prepend all of these to PATH in every PowerShell call:
`$env:Path = "C:\Users\Xia\scoop\shims;C:\Users\Xia\scoop\apps\flutter\current\bin;C:\Users\Xia\scoop\apps\temurin17-jdk\current\bin;C:\Users\Xia\scoop\apps\android-clt\current\cmdline-tools\latest\bin;C:\Users\Xia\scoop\apps\android-clt\current\platform-tools;$env:Path"` and set JAVA_HOME / ANDROID_HOME.
Pub cache: `C:\Users\Xia\AppData\Local\Pub\Cache\hosted\pub.dev` (read package source to confirm APIs). User's test phone is a Samsung S26 Ultra (USB VID_04E8 PID_6860). Related: [[docudis-project]].
`````

### laya-evaluated-not-ner.md

<!-- memory-file: laya-evaluated-not-ner.md -->
`````markdown
---
name: laya-evaluated-not-ner
description: Laya (convaiinnovations) evaluated 2026-09-20 as an alternative to the docudis NER and rejected — it has no span head
metadata:
  type: project
---

Laya (github.com/NandhaKishorM/laya, pip `laya` 0.3.4) was deployed locally and tested against the
fine-tuned docudis XLM-R on the frozen consumer set on 2026-09-20. It is **not** an NER: the only heads
are `choice`, `score` and `noul`, all whole-sequence, so it cannot produce character offsets and cannot
redact. Tested on the two things it can do, over 2123 gold spans + 2019 distractors from all 60 consumer
documents: type assignment 43% correct vs 70% for docudis on the same candidate list, 60% of distractors
kept vs 13%; 220 mistakes at ≥0.90 confidence. As a whole-sentence screen (3951 sentences, 4 phrasings, threshold swept) its best accuracy is 72%
against 68% for answering "no" to everything, and its best F1 47% is below the 49% of answering "yes"
to everything; AUC 0.61 overall, 0.79 en but 0.55 fr and 0.53 es. Not worth revisiting
unless it grows a token-classification head.

**Why:** it is a decision/classification engine for triage and guardrails, a different problem from the
span detection [[docudis-ner-finetune-plan]] targets.

**How to apply:** do not re-evaluate Laya or similar typed-decision models for detection. On Windows,
`laya.load()` from the Hub fails with `OSError: WinError 1314` (HF cache symlinks) — use
`snapshot_download(local_dir=...)` and load the directory.
`````

### recorder-app-clay-b.md

<!-- memory-file: recorder-app-clay-b.md -->
`````markdown
---
name: recorder-app-clay-b
description: "User's second Flutter app (one-tap recording / file upload, on-device summary) reuses the Docudis Clay design with pine-green primary; mockup URL, light + dark tokens, shared theme package idea"
metadata: 
  node_type: memory
  type: project
  originSessionId: b6de3eb1-fd84-4415-acd7-2679c0a091e3
  modified: 2026-09-21T10:06:46.952Z
---

On 2026-09-19 the user decided to reuse the Docudis Clay design ([[docudis-design-clay]]) in a second Flutter app: one-tap recording or file upload, summarised by an on-device model. The app's project folder is `C:\Users\Xia\projects\BrainFiles` (on 2026-09-21 it held only an SLM benchmark, `REPORT.md` + `bench/`, no Flutter project yet). On 2026-09-21 I saved a design handoff there for another session: `design/clay-b/` with `HANDOFF.md`, `mockups.html`, verbatim copies of the two Docudis theme files in `flutter-reference/`, and the fonts.

Chosen direction **B**: same Clay skeleton (sand bg, cream cards, radius 22, Sora + Karla, blob, bottom nav), but primary = pine `#3F6B5C` (tint `#DCE8E2`, text `#2F5447`); terracotta `#C8623A` is reserved for the record button, Stop, the "Recording" pill and the waveform. Option A (terracotta primary, straight copy) was rejected.

Dark tokens proposed the same day (recording page only, user has not commented on them yet): bg `#1C1815`, surface `#28221D` + 1px edge `#352D26` and no shadow, ink `#F1E9DF`, muted `#B9AC9E`, divider `#3A322B`, pine `#86BDA8` with on-primary `#10231C`, pine tint `#22352E`, record `#DB7347`, record tint `#3D241A`. Suggested cooler error `#B4233C` / dark `#F08A98` so it does not collide with the record colour.

Mockups (home, recording, summary; A vs B; dark recording): https://claude.ai/artifact/45XVJPCKbkGgRAHcEpGs6V

**Why:** both apps sell "processed on this phone", same developer account and audience, so a family look is wanted, but two identical-looking apps would be confused in the store.

**How to apply:** when the theme gets shared, extract `lib/theme/clay_theme.dart` + `clay_widgets.dart` into a local package with the primary/record colours as parameters, and drop the entity highlight colours and the `docudis_engine` import. Not started; Docudis itself has no dark theme. Mockup copy (English UI, Record / Library / Settings tabs, upload formats) was my assumption, not confirmed.
`````
