# Docudis Android：NER 换成 Rust 版、删除 Dart 旧引擎 —— 交接提示词

请把 Android 应用的 NER 从 Dart 实现换成 `docudis-ner` 的 Rust 实现，并让 Rust Core 成为生产路径，最后删除 Dart 旧引擎 `packages/docudis_engine`。不要只给方案：先检查三个仓库的实际状态，然后按下面的阶段迁移、实现、测试，每个阶段单独验收。

## 仓库与 2026-10-01 的状态

| 仓库 | 地址 | 状态 |
|---|---|---|
| Android | <https://github.com/stonetech-pxia/docudis-android> | `26984e5`，Core 锁定在 `8743fd8`（`tool/docudis_core_version.json`、`pubspec.yaml`、`.github/workflows/android.yml` 的 `CORE_REVISION`）。阶段 0 完成后见下文 |
| Core | <https://github.com/stonetech-pxia/docudis-core> | main = `fb41dd1`（"Move model code out of Core"）：已删除 `ner.rs`、`tokenizers` 依赖和 `testdata/tokenizers/` |
| NER | <https://github.com/stonetech-pxia/docudis-ner> | main = `33b1383`：Rust crate（tokenizer 对齐、分窗、softmax、窗口合并、BIO 解码）、模型 manifest 和 `model.json`、`tool/fetch_models.py`、`training/`。**还没有 C ABI、Dart 绑定和推理** |

开始时对三个仓库都执行：

```bash
git remote -v
git branch --show-current
git status --short
git log --oneline -n 10
```

不要使用 `git reset --hard`、`git checkout --`、递归删除或其他会破坏未提交工作的命令。未经用户明确授权，不要推送、强推、创建 PR 或删除远端分支。

## 已经定下的决定（不要重新讨论）

- **分工**：用哪个模型由 App 决定；推理由模型完成，代码在 `docudis-ner`；推理结果怎么使用（合并、重叠处理、匿名化）由 Core 决定。Core 自己从不加载或调用模型。
- 模型相关代码属于 `docudis-ner`，用 Rust 实现。依赖方向只能是 `docudis-ner → docudis-core`，Core 永远不依赖模型。
- **Android 直接用 Rust 推理**：分词、分窗、推理、解码全部在 `docudis-ner` 里完成，推理用 `ort` crate 调用 ONNX Runtime。不做"Rust 解码 + Dart 推理"的过渡方案；切换完成后删除 `flutter_onnxruntime` 和 `onnx_token_classifier.dart`。
- chunker（`chunkText`）和 reply_match（`ReplyMatcher`/`ReplyCheck`）迁到 Core 的 Rust 代码，并通过 C ABI 暴露。
- Dart 侧的类型化模型（`Detection`、`DetectionSource`、`EntityType`、`AnonymizedText`、`PlaceholderMap`、`MappingEntry`）放进 Core 的 `bindings/dart`，作为契约的一部分。App 和 docudis-ner 的 Dart 绑定都使用这套类型。
- **两个原生库各自独立**：`libdocudis_capi.so`（Core）和 `libdocudis_ner.so`（NER）。两者之间只通过 v1 JSON 交换 `Detection`，不共享 Rust 结构体。
- Core 通过请求里的 `detections` 字段（`source: "model"`，用 `detector` 区分模型）接收一个或多个模型的结果。以后 Windows 版（Flutter Desktop）会接入 OpenAI Privacy Filter（BIOES + Viterbi 解码），所以 NER 接口不能写死只支持 XLM-R 和 BIO。
- ML Kit（实体识别、语言识别、OCR）留在 App 里，作为 App 侧的检测器，不进入 docudis-ner。
- `training/` 已经搬到 docudis-ner。它的隔离检查通过 `DOCUDIS_APP_ROOT` 读取本仓库的 `benchmark/*_cases.json`、`tool/generate_synthetic_cases.py` 和 `packages/docudis_engine/lists/companies.json`。**测试集留在 Android 仓库**，移动或改名之前，要先改 docudis-ner 的 `training/check_isolation.py`。

## 现状清单（2026-10-01 调查结果）

### NER 现在怎么跑

- `lib/anonymize/anonymize_service.dart:89-112` 的 `_nerDetector()`：`ModelLocator` 通过 MethodChannel `com.stonetech.docudis/model_assets` 读取 `models/xlmr_ner_docudis/model.json`，把 ONNX 和 tokenizer 复制到 app support 目录。
- 纯算法部分在 `packages/docudis_engine/lib/src/ner/`：
  - `NerTokenizer.fromSpec`：WordPiece 用 `dart_bert_tokenizer`；SentencePiece 用 `dart_sentencepiece_tokenizer`，带 Strip normalizer 绕过方案，以及码点到 UTF-16 的 offset 映射。
  - `NerDetector`：`titleCased` 预处理、`maxTokens-2` 滑动窗口（步长 `window-stride`，保留最居中的预测）、softmax argmax、以词为单位的 BIO 解码、平均概率阈值、去首尾空白。
- 推理部分：`lib/anonymize/model/onnx_token_classifier.dart`，用 `flutter_onnxruntime` 的 CPU provider，实现引擎的 `TokenClassifier.classify(ids, mask)`。
- `model.json` 字段：`name`、`model`、`tokenizer.kind`、`tokenizer.file`、`labels`、`labelMap`、`maxTokens`、`stride`、`threshold`、`padId`、`inputs.ids`、`inputs.mask`、`output`。`padId` 会被解析但从未使用。
- Android 打包相关：
  - `android/app/build.gradle.kts`：`noCompress "onnx"`；`syncDebugModelAssets`；强制 `onnxruntime-android` 1.30.0（旧版会 SIGILL）。
  - `android/model_pack`：install-time asset pack，从 `../assets/models/xlmr_ner_docudis` 同步模型文件。
  - `proguard-rules.pro`：保留 `ai.onnxruntime.**`。

### Rust Core 现在的角色

- 只在差分模式下运行：`--dart-define=DOCUDIS_RUST_DIFFERENTIAL=true`（`core_differential.dart:21-24`），默认关闭。
- Dart 先算出完整结果，Rust 再跑 `docudis_v1_process_json`，然后比较规范化后的 JSON。
- 只有两边**逐字节相同**时才用 Rust 的结果。加载失败、ABI 不匹配、异常或不一致时，都回退到 Dart。
- `reapply`、review 预览和 `restore` 从不经过 Rust。

### 旧引擎被哪些地方使用

- **lib/ 共 14 个文件**：
  - `anonymize_service`、`core_differential`、`providers`（`ReplyMatcher`）
  - `ui/review_page`（`chunkText`、`DetectionPipeline.merge`、`anonymize(previous:)`）、`ui/restore_page`（`ReplyCheck`）
  - `storage/record_store` 和 `storage/anonymization_record`（`Detection`/`PlaceholderMap` 的 toJson/fromJson 持久化）
  - `output/document_redaction`、`model/*`、`detectors/mlkit_entity_detector`、`manual_blocks`、`image_redaction`、`ui/highlights`
  - `theme/clay_theme`（按 `EntityType` 配色）
- **test/ 共 15 个文件**；**integration_test/** 里有 `ner_benchmark_test`、`ocr_benchmark_test`、`image_redaction_device_test`。
- `packages/docudis_pdf/tool/anonymize_pdf.dart`（dev_dependency）。
- **工具链**：
  - `tool/run_all_benchmarks.sh` 和 `tool/run_regression_ab.sh` 会调用 `packages/docudis_engine/benchmark/run_benchmark.dart`（推理走 `benchmark/bench_server.py`）。
  - `tool/fetch_bundled_lists.py` 写入 `packages/docudis_engine/lists`。
- **CI**（`.github/workflows/android.yml`）：
  - "Dart reference engine" 测试
  - "Verify Core data snapshot"：`verify_core_snapshot.sh`，接着 `embed_rules`/`embed_lists`，再 `git diff --exit-code`

### Core 的 C ABI 还缺什么（删除旧引擎前必须补齐或另作安排）

- `chunkText`/`TextChunk`：Rust 里没有。
- `ReplyMatcher`/`ReplyCandidate`/`ReplyCheck`：Rust 里没有。
- 按语言选地区：Rust 有 `regions_for_languages`，但没有暴露在 ABI 里。
- 只做 `merge`、不重新检测（review_page 和 reapply 用到）：Rust 有 `merge`，但没有暴露在 ABI 里。
- Dart 侧的类型化模型（`Detection`、`DetectionSource`、`EntityType`、`AnonymizedText`、`PlaceholderMap`）：`docudis_ffi` 目前只有无类型的 Map，而 UI、主题和存储都需要这些类型。
- benchmark 库（`lib/benchmark.dart` 和 OCR benchmark 的辅助代码）。

## 开工前必须先验证的技术点（结论写进 docudis-ner README）

1. **ONNX Runtime 原生库怎么来**：`ort` 没有为 Android 提供可直接下载的预编译库。优先考虑 `ort` 的动态加载方式，在运行时加载 App 打包的 `libonnxruntime.so`，库文件来自 Gradle 直接依赖的 `com.microsoft.onnxruntime:onnxruntime-android`。版本不能低于 1.28（1.23.0 在部分设备上会 SIGILL，见 `android/app/build.gradle.kts:135-139`），并且必须和所用 `ort` 版本支持的 ORT API 版本匹配。迁移期间 `flutter_onnxruntime` 还在，进程里只能有一份 `libonnxruntime.so`，两边必须共用同一份。
2. **体积和速度**：在真机 arm64 上对比 Rust 和 Dart 两条推理路径的首次加载时间、单次推理耗时和峰值内存。Rust 不能比现状明显更差。
3. **模型文件怎么交给 Rust**：`ModelLocator` 已经把模型复制到 app support 目录，Rust 直接按文件路径加载即可，不要再复制一份。

## 阶段 0：升级到 Core `fb41dd1`，模型资料改由 docudis-ner 提供

> **已完成（2026-10-01，分支 `phase0-core-ner-pins`）**：
> - Core 锁定在 `7244cd3`（包含 NER 拆分和浮点修复），docudis-ner 锁定在 `ec73943`（`tool/docudis_ner_version.json`）。
> - `assets/models/` 整个改为 git 忽略，由 `tool/fetch_models.sh` 调用 docudis-ner 的 `fetch_models.py --dest` 写入。
> - `ner_detector_test` 用到的 distilbert `model.json` 快照放在 `packages/docudis_engine/testdata/models/`，由 `tool/verify_ner_snapshot.sh` 校验。
> - 已执行：flutter analyze 无问题；flutter test 128 项通过；引擎 482 项通过；PDF 3 项通过；Core 和 NER 快照校验通过；Debug APK 三个 ABI 都包含 `libdocudis_capi.so` 和模型文件。
> - **未执行**：真机复测浮点修复（当时没有连接设备），以及 CI 上的实际运行。
> - **已知的遗留问题**：`ner_detector_test.dart` 的 "the XLM-R tokenizer keeps every word on its own text" 读取 git 忽略的 `assets/models/xlmr_ner_docudis/tokenizer.json`，没有跳过条件，CI 的 "Dart reference engine" 步骤会因此失败。这个问题在阶段 0 之前就存在。

- 把 Core 锁定升级到 `fb41dd1` 或更新的版本，三处版本号同时改。
- `tool/verify_core_snapshot.sh` 第 31–40 行会因为 `testdata/tokenizers/wordpiece.json` 已删除而失败。删掉对 tokenizer 的检查，并从 `tool/docudis_core_version.json` 移除 `wordpiece_sha256`。
- 新增 `tool/docudis_ner_version.json`，锁定 docudis-ner 的 commit。`packages/docudis_engine/testdata/tokenizers/wordpiece.json`（`ner_detector_test.dart:29` 在用）改为对照 docudis-ner 的 `testdata/tokenizers/wordpiece.json` 校验。
- 模型 manifest 和 `model.json` 以 docudis-ner 为唯一来源：
  - Gradle（`android/model_pack`、`syncDebugModelAssets`）改为从锁定版本的 docudis-ner 获取 `model.json`，模型二进制用它的 `tool/fetch_models.py` 下载。参照 `tool/prepare_docudis_core.sh` 的做法，不要依赖开发机上的绝对路径。
  - 删除本仓库的 `assets/models/{manifest.json,*/model.json,README.md}`、`tool/fetch_models.py`、`training/`，以及 `.gitignore` 里对应的条目。
  - `tool/valid_ids.py` 和 `tool/fetch_public_samples.py` 继续保留，测试集的编写和抓取还要用。
- **注意**：Core 的 `ISSUE-float-roundtrip.md`（serde_json 没开 `float_roundtrip`，confidence 有 1 ULP 偏差，导致差分几乎每次都报不一致）要先修好，否则后面的差分结果没有参考价值。docudis-ner 的 Rust 代码也要开启同一个 feature。

验收：
- Android CI 全部通过。
- 在 docudis-ner 里设置 `DOCUDIS_APP_ROOT=<本仓库>` 后，`training/check_isolation.py` 能正常运行。
- Debug APK 和 AAB 里的模型文件与 manifest 的 SHA-256 一致。

## 阶段 1：docudis-ner 提供 C ABI、Dart 绑定和 Android 产物

> **已完成（2026-10-01）**：docudis-ner `66bd2c6` 提供 `NerModel`（`onnxruntime` feature，`ort` 2.0.0-rc.13 运行时加载）、`docudis_ner_v1_*` C ABI、`docudis_ner_ffi` Dart 绑定和 Android 构建脚本（API 26，三个 ABI）。App 通过 `tool/prepare_docudis_ner.sh` 和 Gradle 任务 `prepareDocudisNer{Debug,Release}Native` 打包 `libdocudis_ner_capi.so`，并通过文件名加载 onnxruntime-android 自带的 `libonnxruntime.so`（迁移期与 `flutter_onnxruntime` 共用同一份）。
> - 实测（Samsung SM-S948B）：Rust 67–77 ms/千字符，Dart 98.6；加载 0.9–1.0 s。tokenizer 解析后约 268 MB 常驻，加载后用 `mallopt` 归还空闲页（约 90 MB）；ONNX 会话约 316 MB。
> - 实测发现并修复：XLM-R 在 CJK 前切出零宽的 `▁` token，Rust `validate` 原先拒绝它，导致所有中文、日文输入无法解码（docudis-ner `47b3e3f`）。
> - `ort` rc.13 的两个限制见 docudis-ner README：首次加载失败后不能在同一进程重试；命令行进程在 Android 上退出时会在 ONNX Runtime 析构中 abort（App 进程不受影响）。

- 新增 `docudis-ner-capi` crate，导出 `docudis_ner_v1_*` 前缀的函数，并提供 `docudis_ner_v1_abi_version()`。复用 Core C ABI 的约定：JSON 请求和响应带 `schema_version: 1`；offset 用 UTF-8 字节；输出由 Rust 分配，并且只能用同一个库的 free 函数释放；有线程局部的错误信息；任何 panic 都不能跨过 ABI 边界。
- 在 docudis-ner 里实现推理（`ort`，CPU execution provider），沿用现有的分窗、合并、解码逻辑。
- ABI 至少要有三个函数：`load`（传入 `model.json` 路径，返回模型句柄）、`detect`（传入句柄和文本，返回 v1 `Detection` 列表，UTF-8 offset）、`close`（释放句柄）。句柄要支持同时加载多个模型。不要在每个窗口上都跨一次 FFI。
- 在 Rust 里解析 `model.json`。现在的 `NerDecodeConfig` 只有 `model_name`、`labels`、`label_map`、`threshold`。要为 BIOES 和 Viterbi 预留扩展点（比如 `scheme`、`decoder` 字段），但**这一阶段不要实现** Privacy Filter。
- 参照 Core 的 `scripts/build-android.sh`，为 docudis-ner 写 Android 构建脚本，覆盖 `arm64-v8a`、`armeabi-v7a`、`x86_64` 三个 ABI，并检查导出符号。
- 在 docudis-ner 里新增 `bindings/dart`：校验 ABI 版本、做 UTF-16 和 UTF-8 offset 转换、保证 buffer 所有权安全，参照 Core 的 `bindings/dart`。推理很慢，`detect` 不能阻塞 UI isolate。
- Android 侧：参照 `prepare_docudis_core.sh` 新建 `tool/prepare_docudis_ner.sh` 和对应的 Gradle 任务；`tool/verify_android_package.sh` 要同时检查 `libdocudis_capi.so`、`libdocudis_ner.so` 和 `libonnxruntime.so`。

验收：
- docudis-ner 的 CI 通过：fmt、clippy、test、release 构建、C 头文件 smoke test、Dart FFI 测试。
- APK 里每个 ABI 都同时包含 `libdocudis_capi.so` 和 `libdocudis_ner.so`。

## 阶段 2：NER 差分，然后切换

> **已完成大部分（2026-10-01）**：没有做运行时差分开关，改为用设备测试证明一致：108 段语料（1884 处）以及 `integration_test/docudis_ner_ffi_test.dart` 的 48 个 `ner_cases`（152 处）上，Rust 与 Dart 的类型、跨度、文本、置信度逐位相同。App 现在**默认使用 Rust NER**（`RustNerDetector`），Rust 加载失败时回退到 Dart `NerDetector`；`--dart-define=DOCUDIS_DART_NER=true` 强制走 Dart。
> - 尚未做：删除 `onnx_token_classifier.dart`、`flutter_onnxruntime` 和引擎里的 Dart NER（需用户确认，且要先把 `libonnxruntime.so` 改为来自 Gradle 直接依赖的 onnxruntime-android）；`tool/run_all_benchmarks.sh` 仍通过 Dart 运行 NER。

- 新增开关 `--dart-define=DOCUDIS_RUST_NER`。打开后同时跑 Dart `NerDetector`（加上 `flutter_onnxruntime`）和 Rust NER，比较 `detections`：类型、跨度、enabled。confidence 允许有很小的误差，因为两边的推理引擎和浮点路径不同，误差上限要根据实测数据定下来并写进文档。
- 已知风险：Dart 的 SentencePiece 用 `dart_sentencepiece_tokenizer` 加绕过方案，Rust 用 HF `tokenizers` 加 `realign_sentencepiece`，token id 和 offset 可能不一致。要在 `benchmark/` 的全部语料上，先比较 token 序列，再比较 detection。
- `titleCased` 预处理和"保留最居中预测"的窗口合并规则，必须和 Dart 完全一致。
- 不一致时回退到 Dart。日志只能记录 case 摘要、类型、长度、offset 和错误码，**不能记录原文或检测出的值**。
- 真机差分覆盖充分之后，再把 Rust NER 设为默认。用户确认后，删除 `onnx_token_classifier.dart`、`flutter_onnxruntime` 和引擎里的 Dart NER（`packages/docudis_engine/lib/src/ner/`）。`libonnxruntime.so` 改为来自 Gradle 直接依赖的 `onnxruntime-android`；`proguard-rules.pro` 里的 `ai.onnxruntime.**` 是否还需要，要实测确认。

验收：
- `tool/run_all_benchmarks.sh` 的 NER 分数和切换前一致，差异要逐条解释。
- 真机（arm64）和模拟器（x86_64）都实际跑通，不能用 mock 代替。

## 阶段 3：Rust Core 成为生产路径

- 补齐上面"Core 的 C ABI 还缺什么"里列出的缺口：chunker、reply_match、按语言选地区、只合并不检测，都放进 Core 的 Rust 代码；类型化模型放进 Core 的 `bindings/dart`。chunker 和 reply_match 迁移前，先用 Dart 的现有行为生成 conformance fixtures。新增 ABI 函数时保持 `docudis_v1_*` 已有函数的行为不变；如果要做破坏性修改，就新开版本命名空间。
- `reapply`、review 预览、`restore` 也接入 Rust，同样先经过差分。
- **持久化兼容**：`record_store` 里保存的是 `Detection.toJson`（UTF-16 offset）和 `PlaceholderMap.toJson`。切换后必须还能读出旧记录，要写迁移测试。
- 差分覆盖充分后，把 `DOCUDIS_RUST_DIFFERENTIAL` 换成"默认用 Rust，出错时报错"。至于是否保留 Dart 作为回退，由用户决定。

## 阶段 4：删除 `packages/docudis_engine`

以下内容都要替换或删除，删完后用 grep 确认 `docudis_engine` 已无任何引用：

- `pubspec.yaml` 里的 `docudis_engine`；`dart_bert_tokenizer` 和 `dart_sentencepiece_tokenizer`（它们是旧引擎的依赖，旧引擎删除后自然消失）。
- lib/ 的 14 个文件、test/ 的 15 个文件、integration_test 里的 3 个文件，全部改为使用新的类型化模型。
- CI 里的 "Dart reference engine" 测试和 "Verify Core data snapshot" 里的 `embed_rules`/`embed_lists`/`git diff`。快照没有了，校验也就不需要了。`verify_core_snapshot.sh` 改为只校验锁定的版本，或者直接删掉。
- `tool/fetch_bundled_lists.py`：Core 的 `data/lists` 才是唯一来源，判断这个脚本是否应该移到 Core。
- benchmark 运行器：`run_benchmark.dart`、`bench_server.py`、`run_all_benchmarks.sh`、`run_regression_ab.sh` 改为通过 Rust（Core CLI 加 docudis-ner）运行，评分逻辑和输出格式保持不变，好让 `compare_runs.py` 能对比新旧结果。
- `packages/docudis_pdf/tool/anonymize_pdf.dart` 的 dev_dependency。
- **docudis-ner 的 `training/check_isolation.py`** 读的是本仓库的 `packages/docudis_engine/lists/companies.json`，文件不存在时会直接报错退出（这是有意设计的）。删除之前，先把它改成读 Core 的 `data/lists/companies.json`，或者别的确定来源。
- 删除 `LICENSE-DocCloak.Core`/`NOTICE-DocCloak.Core` 之前，先确认本仓库已经没有派生自 DocCloak 的代码。如果还有，就保留。

验收：
- `flutter analyze`、全部测试、Debug 和 Release 构建、AAB 全部通过。
- 真机上完整走一遍：文本、PDF、DOCX、图片、restore、reply check。
- 从 `benchmark/` 跑出的分数和删除前一致。

## 约束

- 每个阶段单独提交，每个提交的 CI 都必须通过。
- 不能只靠桌面平台的 dylib 测试，就说 Android 已经验证。真机或模拟器没跑过的项目，要明确列出来，不能写成"已通过"。
- 不在 App 和 docudis-ner 之间复制规则、名单或模型 spec，每份数据只有一个可编辑的来源。
- 日志不能泄漏敏感文本。

## 结束时需要汇报

- 三个仓库最终锁定的版本，以及升级步骤。
- 每个阶段实际执行过的命令和测试数量。
- 真机和模拟器的验证矩阵。
- 剩下的 feature flag 以及各自的回退条件。
- 没有执行的验证，以及"开工前必须先验证的技术点"的结论。
