# 交接：默认不匿名化公司名 + 重训手机 NER（2026-09-30）

给下一个会话直接执行。用户已拍板产品口径，不需要再讨论是否应自动隐藏公司名。

## 1. 已确定的产品决策

1. **Docudis 默认不自动检测、匿名化公司或机构名称。** 公司、学校、医院、法院、政府机构等目前统一映射为
   `EntityType.company` 的名称，默认都应保持可见。
2. 如果用户确实需要隐藏某个公司名，使用“始终隐藏”词典即可。词典当前输出 `CUSTOM`，这正是期望行为；
   不需要为了个别公司名继续微调 ORG，也不需要提供一份默认公司白名单/黑名单。
3. 手机端仍使用本地 XLM-R NER，但要按新口径重新训练。训练目标只保留 `PER / LOC / DATE`，公司名作为
   **未标注的上下文与硬负样本**，而不是 `ORG` 正例。
4. Windows 端以后可以把 OpenAI Privacy Filter（OPF）作为较大模型的备用后端。OPF 不覆盖公司名与本产品
   新口径一致；OPF 接入不在本次交接范围内。
5. 本次只改变“公司/机构名称”的默认行为。邮箱、电话、地址、个人姓名、账号、证件号、VAT/公司登记号等
   现有类型不要顺手关闭。后者是否应隐藏是另一项产品决策。

一句话验收：普通公司名保持原文；把该公司名加入“始终隐藏”后，它会以 `[CUSTOM_n]` 隐藏；其旁边的人名、
地址、邮箱、电话等仍照常匿名化。

## 2. 当前状态与不要踩的坑

- 当前分支是 `main`，HEAD 为 `e3f409a`（写本文时）。
- 工作区已经有另一条尚未提交的规则分类 / Dart-Rust 一致性工作：大量 `rules/*.json`、
  `regex_detector.dart`、`rule.dart`、`rules_data.dart`、测试，以及未跟踪的 `crates/`、`bindings/`、
  `conformance/` 等。**先运行 `git status --short`；不要 reset、覆盖或替用户提交无关改动。**
- 当前规则分类新增了 `RuleSelection`，但尚未接入 app 默认流水线。不要通过批量回滚规则 JSON 来实现本任务。
- `EntityType.company`、`[COMPANY_n]`、颜色、序列化和恢复逻辑必须保留，用于旧记录、手工区间和潜在的显式模式。
  “默认不自动产生新 COMPANY”不等于删除 COMPANY 数据类型。
- 旧的冻结测试集把 COMPANY 当作应隐藏实体。直接用旧总 F1 比较会得出错误结论；必须使用新口径视图，且保留
  旧数据和历史报告。

先读：

- `docs/anonymization-design.md`
- `docs/HANDOFF-ner-finetune-2026-09-19.md`
- `training/README.md` 与 `training/GUIDE.md`
- `docs/ner-regression-2026-09-21.md`
- `docs/ner-benchmark-device-ft4.md`

当前真机模型是 `assets/models/xlmr_ner_docudis/`，约 265 MiB int8，输出九个标签：

```text
O, B-DATE, I-DATE, B-PER, I-PER, B-ORG, I-ORG, B-LOC, I-LOC
```

`model.json` 目前把 `ORG -> COMPANY`。当前真机手写集总体 recall / precision / F1 为 92 / 97 / 94，
333 ms / 1000 字符；organizations F1 为 95。这些数字只作旧口径存档，不能成为新模型必须保住的组织指标。

## 3. 公司名目前从哪里进入流水线

必须同时处理前三个自动来源，不能只删除 NER 的 `ORG` 映射：

| 来源 | 当前位置 | 新行为 |
|---|---|---|
| NER `ORG` | `assets/models/xlmr_ner_docudis/model.json`、`training/train.py`、`training/export_onnx.py` | 立即停止映射；随后重训为无 ORG 的模型 |
| 公司正则 | `packages/docudis_engine/rules/*.json` 中 `entityType: COMPANY` | 规则库可保留，但 Docudis 默认流水线不接受这些命中 |
| 内置公司词表 | `BundledListDetector.bundled()`，数据在 `bundled_lists_data.dart` | 默认只加载中文地点，不加载公司表；最好停止把公司大表打进手机版 |
| ML Kit | `lib/anonymize/detectors/mlkit_entity_detector.dart` | 不输出公司，无需改 |
| “始终隐藏”词典 | `DictionaryDetector` | 保留；公司名按 `CUSTOM` 隐藏 |
| 手工区间 / 旧记录 | reapply、placeholder map、record store | 保留兼容，不删除 COMPANY |

当前 app 的组合点是 `lib/anonymize/anonymize_service.dart`：dictionary → regex → bundled list → NER → ML Kit。
基准运行器 `packages/docudis_engine/benchmark/run_benchmark.dart` 也独立组装 regex、list、NER，别只改 app 后误以为
基准已经测试了发布行为。

## 4. 建议实施顺序

### A. 先落实产品默认策略，独立于模型

先让当前九标签模型也无法自动隐藏公司名，再开始训练。这样即使模型导出或下载失败，产品口径仍正确。

建议在 engine 加一个明确的检测策略（名字可自行调整），并在**原始 detector 结果进入标题清理、重叠裁决、跨度修复和传播之前**
过滤自动 `EntityType.company`。不要在匿名化结果生成后才删，否则公司跨度已经可能压掉人名/地址跨度或触发 repair。

推荐语义：

```text
DetectionPolicy(autoDetectCompanies: false)   // Docudis 默认
DetectionPolicy(autoDetectCompanies: true)    // 仅给底层规则测试或未来显式模式
```

实现要求：

- app 和桌面基准必须显式使用同一个默认策略；Dart/Rust 的 conformance 工作若已覆盖 pipeline，也要同步策略字段与用例。
- 规则本身的单元测试可以在 `autoDetectCompanies: true` 下继续验证匹配正确性，不必删除二十多条 COMPANY 规则。
- `BundledListDetector.bundled()` 增加“仅地点”配置，app 默认不解析公司名单。若 tree shaking 不能排除 1.5 MiB 的
  `bundled_lists_data.dart`，把生成文件拆成 places / companies，使手机版只引用 places。先保留生成源，不要粗暴删除数据。
- 作为过渡防线，现有 `model.json` 删除 `ORG: COMPANY` 映射后，`NerDetector` 会忽略 ORG；但这不是重训的替代品：
  ORG 仍可能赢 argmax，从而压掉本应输出的 PER/LOC。
- 不要把自动 COMPANY 改成 `enabled: false` 的“检测但不遮”。用户的决策是默认不做公司识别；需要隐藏时走词典。
- 不要把 `EntityType.company` 从 enum、placeholder、历史记录 JSON 或恢复页面删除。

需要新增的核心回归：

1. regex、bundled list、旧 NER 各自报出的 COMPANY 在默认策略下都被丢弃。
2. 同一句里的 PERSON、ADDRESS、EMAIL、PHONE 仍保留。
3. `Worcester Bosch`、`Société Générale`、`华为技术有限公司`、`Universidad de Salamanca` 等不产生自动区间。
4. “以人名命名的公司”如 `Villanueva Oduya & Partners`、`Jean Dupont Conseil` 不应把内部姓名误遮。
5. 把上述词加入“始终隐藏”后产生 `CUSTOM` 并被隐藏。
6. 已保存的 `[COMPANY_1]` 记录仍能加载、重新应用与恢复。
7. list-only 模式不变。

### B. 把训练语义改成三类实体

发布模型建议使用七标签头：

```text
O, B-DATE, I-DATE, B-PER, I-PER, B-LOC, I-LOC
```

涉及：

- `training/GUIDE.md`：删除 ORG 正例定义，明确公司、学校、医院、政府机构、法院、商号、品牌为 `O`；公司里的
  人名和地名默认也不要拆出来标 PER/LOC，除非文本同时明确指向真实个人或独立地址。
- `training/markup.py`：导出的实体标签只允许 `PER / LOC / DATE`。
- `training/build.py`：公司生成能力仍保留，用来制造真实上下文，但不导出 ORG span。
- `training/fetch_registry.py`：公司字段继续出现在公告原文，却不进入训练 spans；PER、LOC、DATE 仍正常标注。
- `training/train.py`、`training/export_onnx.py`：七标签顺序一致；导出的 `labelMap` 只含
  `PER -> PERSON`、`LOC -> ADDRESS`、`DATE -> DATE`。
- `training/README.md`、`docs/ner-finetune-scope.md` 和模型 descriptor source 文案同步。

不要简单删除所有公司生成逻辑。公司名称是重要的 O 类难例，尤其需要覆盖：

- 带法律形式和不带法律形式的公司；缩写、全大写、中文无后缀商号。
- 学校、大学、医院、银行、保险公司、协会、法院、政府机构。
- 人名型商号和地名型商号，防止被误判为 PERSON / LOC。
- 公司旁边紧邻真实联系人、地址、日期、邮箱和电话的混合文档。
- 当前模型容易误判的 `SIRET`、`IBAN`、`Grupo N` 等标签词。

模板系统最好把“生成器语义”和“训练标签”分开。例如把旧 `ORG` 槽机械迁移成 `COMPANY_CTX`：它仍能绑定
公司名、域名和 URL，也能参与替换与 OCR 增强，但 `to_record()` 永远不为它输出 span。不要继续让一个名为 `ORG`
的标记有时表示正例、有时表示 O，后续维护很容易再次标错。

登记公告有额外注意点：`fetch_registry.py` 中有些公司边界不仅用于生成 ORG span，也用于从
“公司名, 地址”里切出正确 LOC。移除 ORG 输出时仍要保留内部边界信息，避免把公司名吞进地址标签。

所有现有训练材料都要重新生成并审计：

- `training/out/{train,dev}.jsonl` 中 ORG span 必须为 0。
- 公司文本必须仍大量存在，不能因为去掉标签而从记录里消失。
- 随机抽查含公司文本的英、法、西文档，确认其附近 PER/LOC 偏移未漂移。
- 测试集隔离继续执行；`real_organisations.txt` 和公司 inventory 仍可保留用于生成负上下文。

### C. 重训与分类头迁移

不要仅用 `ignore_mismatched_sizes=True` 就结束：从 9 类改成 7 类时，它通常会重新初始化整个 classifier，连已经学好的
PER/LOC/DATE 行也丢掉。首选做法是从训练机上仍保存的 ft4 **PyTorch checkpoint** 加载 backbone，并把旧头的这些行按下表
复制到新头。仓库里发布的是量化 ONNX，不要把它误当成 Transformers checkpoint；如果训练机已没有 ft4 checkpoint，
就从 `Davlan/xlm-roberta-base-ner-hrl` 的九标签 PyTorch 模型做同样的行复制，再完整微调，并在结果中记录这个差异。

| 新索引 | 标签 | 旧索引 |
|---:|---|---:|
| 0 | O | 0 |
| 1 | B-DATE | 1 |
| 2 | I-DATE | 2 |
| 3 | B-PER | 3 |
| 4 | I-PER | 4 |
| 5 | B-LOC | 7 |
| 6 | I-LOC | 8 |

权重和 bias 都复制，然后用新数据完整 fine-tune。也可以重建七类头从头训练，但必须在结果文档中写明，并通过同样的非公司
回归门槛；不要假装 Hugging Face 的 mismatch 自动完成了行映射。

Windows 训练环境沿用 `docudis-ner`（RTX 3080 10 GB）。开始前看 `nvidia-smi`，保证显存没有被其他程序占满；
`conda run` 加 `--no-capture-output`，否则训练日志会一直缓冲。

```bash
py=C:/Users/Xia/anaconda3/python.exe
$py training/fetch_registry.py
$py training/check_isolation.py
$py training/build.py --chunks 30000
$py training/check_isolation.py --jsonl training/out/train.jsonl training/out/dev.jsonl
conda run --no-capture-output -n docudis-ner python training/train.py
```

先导出到新目录，不要覆盖当前可回退模型：

```bash
conda run --no-capture-output -n docudis-ner python training/export_onnx.py \
  --out assets/models/xlmr_ner_docudis_noorg
```

确认 ONNX `logits` 最后一维为 7、`model.json` 标签顺序正确、没有 ORG labelMap，再进行量化前后对比。模型是否明显变小
不是验收目标：参数主体在 XLM-R backbone，少两个输出几乎不会改变 265 MiB 体积。

### D. 新口径 benchmark，不污染旧基线

不要直接修改冻结的 `benchmark/*_cases.json`。新增一个可重复生成的 policy-v2 视图或 runner 选项：

- 从 expected entities 中过滤 `type == COMPANY`。
- 原文中的公司仍保留，因此模型把公司误报为 PERSON / ADDRESS 会自然计为 false positive。
- leak report 不再把 COMPANY 算作泄露。
- 旧数据、旧报告和旧口径数值保留，文件名/tag 明确写 `no-company`。

先用“当前 ft4 模型 + A 阶段公司过滤”跑一次新口径基线，再用七标签模型跑同一套数据。这样能区分产品策略带来的变化与重训带来的变化。
`tool/run_all_benchmarks.sh` 必须设置新 TAG，绝不能覆盖无 tag 的历史文件，例如：

```bash
MODEL=../../assets/models/xlmr_ner_docudis \
TAG=no-company-policy-current \
PYTHON=/path/to/python \
tool/run_all_benchmarks.sh --no-stress

MODEL=../../assets/models/xlmr_ner_docudis_noorg \
TAG=no-company-ner-v1 \
PYTHON=/path/to/python \
tool/run_all_benchmarks.sh --no-stress
```

如果 runner 尚未切到 policy-v2 数据，先改 runner，再跑上面命令；不能拿包含 COMPANY expected 的旧报告验收。

另建公司可见性硬负例集，至少覆盖中、英、法、西、德、日，以及：公司后缀、无后缀品牌、大学、医院、法院、公共机构、
人名型公司、地名型公司、公司 + 联系人 + 地址混合场景。纯公司名不应产生任何检测；混合场景只允许非公司 PII 检测。

## 5. 验收门槛

全部满足后才替换 `assets/models/xlmr_ner_docudis/` 或 Android model pack：

1. 默认 app、Dart benchmark 和（若已接入）Rust pipeline 对公司策略一致，自动 COMPANY 数为 0。
2. 公司可见性硬负例：公司文本没有 COMPANY，也没有被误标为 PERSON / ADDRESS；词典命中除外。
3. 新口径下 PERSON / ADDRESS / BIRTH_DATE 的召回不得低于“当前 ft4 + 公司过滤”基线；若有个别语言下降，逐实体列出，
   不可只给总体 F1。
4. 现有 hard negatives 不新增会遮住普通词的误报。
5. consumer / public / regression 三套按新口径计算的可识别泄露不恶化；公司不再计泄露。
6. 公司旁边的地址、联系人、邮箱、电话、账号仍被识别，特别检查公司跨度过去会压住其他跨度的样例。
7. 字典可隐藏任意公司名，list-only 模式正常，旧 COMPANY 记录可恢复。
8. int8 与 fp32 的逐实体结果一致或差异有书面说明。
9. Android 真机可加载新图，桌面与真机结果一致，速度不比当前约 333 ms / 1000 字符显著变差。

建议验证命令（按仓库实际 Flutter/Dart 环境调整路径）：

```bash
dart format --output=none --set-exit-if-changed packages/docudis_engine/lib packages/docudis_engine/test
cd packages/docudis_engine && dart test
cd ../.. && flutter test
flutter test integration_test/ner_benchmark_test.dart -d <device>
git diff --check
```

如果规则分类 / Rust conformance 那条工作仍未完成，先确认它的生成命令和工作区所有权，再运行会改写
`rules_data.dart` 或 conformance fixtures 的工具。

## 6. 文档与商店文案

至少更新：

- `docs/anonymization-design.md`：默认类型、模型标签、内置公司表、Windows OPF 关系。
- `training/GUIDE.md`、`training/README.md`、`docs/ner-finetune-scope.md`。
- `docs/store/listing.md`：删除“自动识别公司名/organizations”的承诺，改为“可通过始终隐藏词典指定公司名”。
- README 中任何“company names are detected automatically”的描述。
- 模型目录的 README / descriptor source / 新 benchmark 结果文档。

字典页的现有提示“姓名、公司、地址……”应保留，它现在正好解释了隐藏个别公司的正确方法。不要因为默认策略变化把该提示删掉。

## 7. 建议提交拆分

为了可回滚和审查，建议至少分三次提交：

1. `policy: stop automatic company-name anonymization by default`
2. `training: treat organizations as negative context`
3. `model: ship seven-label mobile NER and no-company benchmarks`

不要把当前工作区里无关的规则分类、Rust scaffolding 或用户其他改动顺手混进这些提交。

## 8. 下一会话可直接使用的开场指令

> 阅读 `docs/HANDOFF-no-company-mobile-ner-2026-09-30.md` 并按顺序执行。先检查并保护现有未提交改动；先实现默认公司过滤和测试，
> 再迁移训练标签、生成新口径 benchmark、重训并导出七标签手机 NER。不要删除 `EntityType.company` 或破坏旧记录兼容性，
> 不要覆盖历史 benchmark 和当前可回退模型。完成后给出逐实体回归、真机结果和仍未完成项。
