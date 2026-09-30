# 交接：NER / 匿名化检测精度（2026-09-18）

给下一个对话用。读完这一份加上 `docs/anonymization-design.md` 的"检测引擎"和"打包、平台与测试"两节，就能接着干。
用户用中文交流；目标用户是**英语、法语、西班牙语**，中文优先级很低（预算原因）。

## 1. 现在在哪

分支 `store-materials-and-detection-precision`。

**已提交**（09-18 09:45，两个提交 `35f6315`、`ee8f756`，外加 `55837c5`）：
- 职务否决词表 `packages/docudis_engine/lib/src/rules/title_stoplist.dart`
- 内置名单 `BundledListDetector`（Wikidata 公司名 17500 家 + 中国地名），拉取脚本 `tool/fetch_bundled_lists.py`
- 第一批规则修复（邮编大写城市、英国座机、货币代码前置、法西文字日期、名称类规则不跨行、`cn:address` 收紧）

**未提交，都在工作区**（本次对话后半段的成果）：
- 真实文档测试集：`benchmark/public/`（原文、标注、说明）、`benchmark/public_cases.json`、`benchmark/synthetic_cases.json`、`benchmark/hard_negatives.json`
- 工具：`tool/fetch_public_samples.py`、`tool/build_public_cases.py`、`tool/generate_synthetic_cases.py`、`tool/leak_report.py`、`tool/run_all_benchmarks.sh`
- 第二批规则修复：`packages/docudis_engine/rules/{universal,fr,es,gb,us,be,ch}.json` 和重新生成的 `rules_data.dart`
- 测试：`packages/docudis_engine/test/rules_test.dart` 新增一组 14 条（含反例集）
- 运行器：`benchmark/run_benchmark.dart` 加了 `--dataset`；`dump_tokens.dart` 跟着改了常量名；`html_report.dart` 修了一个越界
- 报告：`docs/benchmark/desktop-xlmr*.{md,html}`、`leak-public.md`、`leak-synthetic.md`（`*.json` 被 gitignore）
- `docs/anonymization-design.md` 已同步

**不是我的改动，别碰**：`packages/docudis_pdf/`（未跟踪）、`test/goldens/*`。另一个会话在做图片脱敏和 PDF，提交时分开。

用户没有要求提交，我也没有提交。提交前先问。

## 2. 当前数字（桌面，XLM-R）

| 数据集 | 指标 | 这一轮之前 | 现在 |
|---|---|---|---|
| 手写基准 `ner_cases.json` 含压力用例 | F1 / 精确率 / 召回 | 97 / 97 / 97 | 97 / 97 / 97 |
| 公开记录 45 份 | 泄漏率 | 42.0% | **13.2%**（英 9.1、法 10.1、西 18.3） |
| 公开记录 | 过度遮盖 | 98 | 73 |
| 合成文档 45 份 | 泄漏率 | 9.1% | **1.3%** |
| 合成文档 | 过度遮盖 | 28 | 4 |
| 反例集 18 段 | 误报 | 20 | **0** |

引擎测试 325 个全过；`flutter analyze` 干净；app 层相关测试 18 个通过。手机端 benchmark 自 09-16 以后**没有重跑过**，手机当时没连。

## 3. 怎么跑

`dart` 要在 PATH 上（随 Flutter 附带，在 `<flutter>/bin`），`PYTHON` 指向装了 onnxruntime 和 numpy 的 Python
（Windows 上别用系统的 `python`，它是 WindowsApps 占位，会卡死）：

```bash
cd <仓库根目录>
PYTHON=/path/to/python bash tool/run_all_benchmarks.sh            # 四套数据，约 1 分钟
PYTHON=/path/to/python bash tool/run_all_benchmarks.sh --no-stress # 约 40 秒
cd packages/docudis_engine && dart test                                              # 325 个
```

改规则的流程：编辑 `packages/docudis_engine/rules/<region>.json` → `dart run tool/embed_rules.dart` → `dart test` → `run_all_benchmarks.sh`。
每条规则的 `examples` 会被自动测试，必须全部命中。改过的 DocCloak 规则在 `description` 里标 "(Docudis change …)"，新增的标 "(Docudis addition)"。

脚本里有反斜杠时**不要用 Bash heredoc 写文件**，它会吞掉双反斜杠；用 Write 工具写脚本再执行。终端是 GBK，Python 打印要带 `PYTHONIOENCODING=utf-8`。

## 4. 测试集是怎么回事

- **`public_cases.json`**：真实公开记录。法语 BODACC 15 份、西班牙语 BORME 14 份（PDF 经 `pdftotext`）、英语 The Gazette 公司清算公告 8 份 + Enron 邮件 8 封。881 条标注由三个**不接触检测流水线**的子代理通读全文写成，规则在 `benchmark/public/ANNOTATION.md`。**重新抓取会换掉文档、标注作废**，`raw/` 和 `labels/` 当冻结快照。用户明确**不提供自己的文档**。
- **`synthetic_cases.json`**：发票、租约、工资单、医疗/保险信件、简历 × 英法西 × 3 份。模板 + 假数据，填槽即标注，证件号带正确校验位。单据编号标为 ID 且带 `"sub": "reference"`，报告里单独计数。
- **`hard_negatives.json`**：18 段不含敏感信息的相似文本，任何命中都是误报。已接进 `rules_test.dart`，是防误判的永久防线。
- **主指标是泄漏率**（`tool/leak_report.py`），不是 F1：看每个预期实体的字符是否被某个检测完全覆盖，不论类型和切分。

## 5. 用户已经做的决定（别再争论）

1. **单据编号暂不扩规则**（09-17）。`ticket 845210`、`Facture n° 202603` 保持漏检可见。我试过 `universal:numbered_id` 又撤掉了，因为和这条冲突。想恢复先问用户。
2. **这个版本不支持多语言文件**（09-18）。语言识别的分段方案和相关测试放一边。
3. **人名不做内置名单**。常见名字同时是普通词，只会增加误报。
4. **OCR 空格归一化、小写人名暂缓**，等真机 OCR 输出再看。
5. 版本号 / versionCode 任何变动先问。

## 6. 用户定的方向（引擎部分已于 09-18 下午实现，未提交）

> 更新：NUMBER、金额默认不遮、只遮出生日期三项的引擎、泄漏报告、类型名和设计文档都已完成（设计文档"占位符要对下游模型说真话"一节），引擎测试 332 个通过。日期方向用户已同意。之后同一天：benchmark 数据集把出生日期标成 `BIRTH_DATE` 并与 DATE 严格区分计分；宽松电话规则命中纯数字也降为 NUMBER（`ie:phone` 降到 0.75）；商店文案和截图已改；死代码 `entityTypeLabel` 已删。引擎测试 333 个通过。点选页顶部已加"遮住全部金额 / 日期"两个开关（用户先说不做，同日改为要做）。**用户决定不做**：`fr:siret` 不加 Luhn，保持 NUMBER。下面是当时的原始记录。

用户 09-18 提出、我表示同意、**还没动代码**：

- **数字类标签宁可笼统也不要标错。** 新增通用类型 NUMBER（占位符 `[NUMBER_1]`）。只有带校验位的规则（IBAN、Luhn、法国 NIR、西班牙 DNI、NHS）和格式足够特殊的高置信度规则保留具体类型；其余低置信度的纯数字命中（`universal:long_number`、`fr:cni` "任意 12 位"、`gb:passport` "任意 9 位"、`gb:bank_account` "任意 7-8 位" 等）降级为 NUMBER。理由：错的类型会误导下游做分析的大模型。改动集中在 `RegexDetector`，外加 `EntityType` 和 l10n 里的类型名。泄漏报告的"已遮住但类型错"一栏可以直接验证效果（现在公开 23 处、合成 4 处）。
- **金额默认不匿名。** 检测保留，`Detection.enabled` 对 AMOUNT 默认 false，用户在结果页可一键打开。泄漏报告里金额要像单据编号那样**单独计数**，否则会被算成泄漏。需要提醒用户：商店文案如果写了"遮住金额"要同步改（文案位置见记忆 `docudis-store-materials`）。
- 我顺带提了**日期**（只遮出生日期，其余保留），用户还没表态，不要擅自做。

## 7. 剩余泄漏和我的建议

- （09-18 已做：`NerDetector.titleCased`，公开集泄漏 14.4% → 9.4%，见设计文档。）**全大写的人名和公司名**，占剩余泄漏的大半。BORME 写 `LOPEZ CORCOLES JOSE VICENTE`，BODACC 写 `JERVIS BAY`；法国行政文件普遍把姓氏写成全大写，对法语用户是真问题。规则解决不了。建议在 `NerDetector` 里做实验：喂模型之前把长度 ≥ 4 的全大写词转成首字母大写（偏移量不变，取值仍从原文取），用四套数据两分钟就能看出是帮忙还是添乱。
- BORME 特有的金额写法（`357.110,00E`、大写数字金额）：普通用户文档里见不到，不建议写规则。
- 已知未修：`cn:company` 会把"以及来自"吃进公司名；`gb:street` 不认没有后缀词的街名（`112 Kingsway`）；`阿里巴巴`、`深圳` 被模型更长的区间盖住（名单和模型同级优先级的代价）。中文优先级低，不急。
- **ML Kit 实体抽取**在真机上一直参与检测，但从没进过 benchmark，效果未知。手机端加个开关跑两次对比即可。

## 8. 踩过的坑

- 给公开接口发请求时**不要把用户邮箱放进 User-Agent**。我犯过一次，已清掉。SEC EDGAR 因此拿不到（它强制要邮箱），需要用户同意才能抓。
- 三个标注子代理同时跑的时候 benchmark 耗时会飙到平时十倍，那是 CPU 争用，不是模型问题。
- 桌面 benchmark 的速度有 ±50% 抖动，只看等级。
- `benchmark/public/raw` 里的 BORME 文本来自 `pdftotext` 的非 layout 模式，和 app 自己的 PDF 提取器输出不一定一致；另一个会话正在做 `packages/docudis_pdf`，将来可以用它重新提取一遍对比。

## 9. 相关记忆文件

`C:\Users\Xia\.claude\projects\C--Users-Xia-projects-docudis\memory\`：`docudis-anonymization-build`（功能状态和命令）、`docudis-placeholder-policy`（第 6 节的方向）、`docudis-target-market`（语言优先级）、`flutter-sdk-via-scoop`（PATH）。
