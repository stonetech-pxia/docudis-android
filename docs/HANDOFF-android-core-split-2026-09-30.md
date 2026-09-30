# Docudis Android / Core 双仓拆分：下一阶段交接提示词

请继续完成 Docudis 的 Android / Core 双仓拆分与真实 Android 集成。不要只给方案；请先检查两个仓库和原工作树的实际状态，然后直接迁移、实现、测试和修复，直到本阶段可以交付。

## 仓库

- Android：<https://github.com/stonetech-pxia/docudis-android>
- Core：<https://github.com/stonetech-pxia/docudis-core>
- 原始迁移工作树：`/Users/xiapengda/projects/docudis`

两个新仓库已经创建，但不要假设其内容、默认分支或 CI 状态。开始时必须分别检查：

```bash
git remote -v
git branch --show-current
git status --short
git log --oneline -n 10
```

如果本机还没有两个新仓库，请克隆到互不嵌套的独立目录。不要在原工作树内创建嵌套 Git 仓库。不要使用 `git reset --hard`、`git checkout --`、递归删除或其他会破坏未提交工作的命令。不要覆盖两个新仓库中已经存在的用户修改。未经明确授权不要推送、强推、创建 PR 或删除远端分支。

## 原工作树的重要状态

原仓库在 Rust 迁移开始前已有用户未提交的规则改进，主要包括：

- `docs/anonymization-design.md`
- `docs/rule-classification.md`
- `packages/docudis_engine/lib/docudis_engine.dart`
- `packages/docudis_engine/lib/src/detectors/regex_detector.dart`
- `packages/docudis_engine/lib/src/rules/*`
- `packages/docudis_engine/rules/*.json`
- `packages/docudis_engine/test/rules_test.dart`

这些文件是最新参考实现，不能从旧提交或旧远端版本覆盖。迁移时必须以原工作树的当前内容为准，并保留其来源和历史说明。

原工作树当前还包含尚未提交的 Rust 迁移成果：

- 根 Cargo workspace
- `crates/docudis-core`
- `crates/docudis-capi`
- `crates/docudis-cli`
- `bindings/dart`
- `conformance/`
- `crates/README.md`

先比较三个工作树，再决定复制、移动或补齐哪些文件。不要因为新仓库已经存在就重新实现一份不同版本。

## 已完成且必须保留的能力

### Rust Core

- EntityType、Detection、DetectionSource、PlaceholderMap
- anonymize / restore、previous map、重复值和人物变体
- UTF-8 / UTF-16 offset 安全转换
- 规则 schema、地区选择、规则配置
- 204 条当前 Dart 规则及 validators/checksum
- RegexDetector 的 Dart/Rust 兼容处理
- 内置公司/地点名单、用户词典、never-hide
- DetectionPipeline、优先级、重叠处理、propagation、repair
- birth date、title/department stoplist、public products、figure rows
- WordPiece/SentencePiece tokenizer、窗口构造、对齐和 BIO 解码
- 不包含 ONNX Runtime，不在 Rust 中执行 NER 推理

### Conformance

- `conformance/fixtures/v1/anonymization.json`
- 445 个共享规则差分案例
- 29 个共享 pipeline/repair 差分案例
- Dart 与 Rust 读取同一 fixture
- 同时校验 UTF-8 和 UTF-16 offset
- 记录 Dart RegExp 与 Rust regex 的重写及原因

### C ABI / CLI / Dart FFI

- 保留 `docudis_v1_*` ABI 和 schema version 1
- `docudis_v1_anonymize_json`
- `docudis_v1_detect_json`
- `docudis_v1_process_json`
- `docudis_v1_restore_json`
- 稳定错误码、错误信息、panic 边界和 Rust buffer free
- CLI 的规则检测、地区、词典、外部 NER 合并、匿名化、restore
- Dart FFI 的 JSON 调用、offset 转换、buffer 复制释放和异常映射
- `DocudisDifferentialRunner`：Rust 不一致或失败时继续使用 Dart 结果

### 已通过的基线

- `cargo fmt --all --check`
- `cargo clippy --workspace --all-targets -- -D warnings`
- `cargo test --workspace`：26 项通过
- `cargo build --release --workspace`
- C header + 动态库真实 smoke test
- Dart 参考引擎：482 项测试通过，analyze 通过
- Dart FFI：3 项真实动态库测试通过，analyze 通过
- PDF：3 项测试通过，analyze 通过
- Flutter 根项目 analyze 通过

## 本阶段目标

完成真正可维护的双仓边界，并让 Android 应用在真实 Android ABI 上安全加载 Rust Core。迁移期间继续保留 Dart 参考实现和差分回退；不能仅因桌面 dylib 测试通过就切换 Android 生产路径。

目标依赖方向必须是单向的：

```text
docudis-android
    -> versioned docudis-core C ABI / Dart FFI package / native artifacts

docudis-core
    -> no dependency on Flutter, Android app, ML Kit, PDF, OCR or ONNX Runtime
```

Core 仓库不得通过相对路径读取 Android 仓库文件。Android 仓库也不得依赖 `/Users/xiapengda/projects/docudis` 或其他开发机绝对路径。

## 必须完成的工作

### 1. 建立明确的仓库归属

`docudis-core` 至少应拥有：

- Cargo workspace、lockfile 和全部 Rust crates
- C header、ABI 文档和真实 C smoke test
- Dart FFI package
- conformance fixtures、生成说明和 Rust 侧测试
- Rust 所需的规则 JSON、名单或确定性生成输入
- Apache-2.0、NOTICE 及 DocCloak.Core attribution

`docudis-android` 至少应拥有：

- Flutter 应用与 Android Gradle/Kotlin 工程
- OCR、PDF、文件分享、存储和 UI
- 当前 Dart/Flutter NER 推理与模型 asset pack
- 迁移期的 `packages/docudis_engine` Dart 参考实现
- Android 侧差分集成测试

不要让同一份规则在两个仓库中成为两个可独立编辑的 source of truth。以 Core 中的规则数据为主源；如果 Android 的 Dart 参考实现仍需要生成后的规则快照，必须提供确定性生成命令、来源版本或内容哈希，并在 CI 中检测漂移。不要手工维护两份规则。

### 2. 清除跨仓相对路径

当前 Rust 规则加载可能仍通过 `include_str!` 指向原仓库的 `packages/docudis_engine/rules`。迁到 Core 后必须改为 Core 仓库内部路径，并保持全部 204 条规则、445 个规则 fixture 和 29 个 pipeline fixture 通过。

检查 README、脚本、测试和 Dart package 中的 `../..` 路径。所有路径必须在各自仓库独立 clone 后仍可工作。

### 3. Android 原生库构建与打包

为 Android 构建 `libdocudis_capi.so`。先根据 Flutter/Gradle 当前支持矩阵确认 ABI，不要猜测；至少覆盖发布设备 ABI 和一个可用于 CI/模拟器测试的 ABI。通常需要验证：

- `arm64-v8a`
- `x86_64`
- 如果应用仍承诺支持，再加入 `armeabi-v7a`

使用可复现的 Cargo NDK、Gradle task、Flutter native assets 或独立构建脚本。选择一种清晰方案，不要要求开发者手工复制 `.so`。构建必须：

- 使用 Android NDK 支持的 Rust target
- 把每个 ABI 的 `.so` 放进 APK/AAB 可发现的位置
- 在增量构建和 clean build 后都正确
- Debug 与 Release 都能链接
- 不把 macOS/Linux 动态库误打进 Android
- 不提交 `.gradle`、NDK cache、签名密钥或 `local.properties`

检查最终 APK/AAB 内容，确认每个声明 ABI 都实际包含 `libdocudis_capi.so`，并验证导出的 `docudis_v1_*` 符号。

### 4. Android 使用 Dart FFI

让 Android 仓库通过明确、固定版本的 Core 依赖使用 Dart FFI。可以使用 Git tag/commit、发布包或仓库子目录，但必须可复现，不能追踪无固定提交的移动分支。

补充：

- Android/Linux 下 `DynamicLibrary.open('libdocudis_capi.so')` 的真实加载测试
- ABI version 检查；不兼容时不得继续调用
- 缺少动态库、缺少 symbol、无效 JSON、Rust panic 状态的诊断
- Rust buffer 始终由同一动态库的 free 函数释放
- Release/R8 配置不能破坏 native 加载

### 5. 接入差分模式，不直接硬切

Android 的当前 NER 推理继续由 Dart/Flutter 完成：

1. Dart 完成 NER 推理。
2. 将 NER detection 从 UTF-16 转成 UTF-8 offset。
3. 将 NER detection、地区、词典、never-hide 和 previous map 交给 Rust。
4. Rust 执行规则/名单/词典合并、pipeline、repair 和匿名化。
5. 同时运行 Dart 参考实现。
6. 自动比较 detections、enabled、类型、跨度、匿名化文本、map 和 restore。
7. 一致时可以返回 Rust 结果；不一致、加载失败或调用异常时必须返回 Dart 结果。

差分诊断不得把原始敏感文本、检测值或映射写入普通日志。记录 case id、类型、长度、offset、错误码和不可逆摘要即可。提供可关闭的 feature flag；在真机差分覆盖充分前，不要删除 Dart 路径，不要默认强制只用 Rust。

### 6. 真机和模拟器验证

不能只跑 macOS dylib。至少完成：

- 一个 Android 模拟器 ABI 的 FFI 集成测试
- 一个真实 ARM64 Android 设备或等价 CI runner 的加载与调用测试
- Unicode 文本：CJK、emoji、组合字符、NBSP
- 规则检测、外部 NER 合并、process、restore
- invalid offset、invalid JSON 和错误信息
- repeated calls 和 buffer free
- Debug APK
- Release APK 或用于发布的 AAB 路径；注意现有 NER model asset pack 约束

如果当前环境没有设备，仍要完成可自动运行的 Gradle/Flutter 集成测试和 APK 内容验证，并明确列出尚未执行的设备矩阵；不能把未执行描述为通过。

### 7. CI 与版本发布契约

Core CI 至少运行：

```bash
cargo fmt --all --check
cargo clippy --workspace --all-targets -- -D warnings
cargo test --workspace
cargo build --release --workspace
```

并增加 Android target 构建、C header smoke、Dart FFI analyze/test 和 artifact 检查。

Android CI 至少运行 Flutter analyze、现有 Dart/Flutter 测试、PDF 测试、Debug Android build 和差分 fixture。固定 Core commit/tag，并提供可审计的升级步骤。ABI/schema 破坏性变化必须新增明确版本，不能偷偷改变 v1。

### 8. 许可证与来源

两个仓库都必须保留：

- Apache-2.0 说明
- `DocCloak.Core`
- `Copyright 2026 Witold Lojek`
- `LICENSE-DocCloak.Core`
- `NOTICE-DocCloak.Core`

生成的规则、名单、fixture、C header、Rust、Dart、Kotlin、构建脚本和测试都要保留兼容的许可证说明与生成来源。不要把签名文件、私钥、token 或本机配置迁入新仓库。

## 暂不实施

- 不创建 `docudis-ort`
- 不在 Rust 中加载或执行 ONNX
- 不更换或重新训练 NER 模型
- 不迁移 OCR 到 Rust
- 不重写 Flutter UI
- 不删除 Dart 参考实现
- 不重写 PDF/DOCX 到 Rust
- 不增加 C#、Python、Node、Kotlin 或 Swift binding

## 验收要求

最终必须证明：

1. 两个仓库都能在独立 clone 中构建，不依赖原 monorepo 路径。
2. Core 的 204 条规则、445 个规则 fixture、29 个 pipeline/repair fixture 保持一致。
3. Rust 四项门禁全部通过。
4. C ABI 和 Dart FFI 测试通过。
5. Android APK/AAB 中存在正确 ABI 的 `libdocudis_capi.so`。
6. Android 实际加载并调用 Rust，而不是 mock。
7. 差分不一致时确实回退 Dart，且日志不泄漏敏感文本。
8. Flutter、PDF、OCR、模型 asset pack 和现有平台行为未回归。
9. 没有 ONNX Runtime Rust 依赖。
10. `git diff --check` 通过，且没有覆盖用户原有修改。

请在结束时给出：

- 两仓最终目录边界
- Core 依赖版本/commit 和升级方式
- Android ABI 与产物清单
- 实际执行的命令及测试数量
- 真机/模拟器验证矩阵
- 仍保留的差分 feature flag 与回退条件
- 任何尚未执行的外部验证，不得隐瞒或表述为已完成

