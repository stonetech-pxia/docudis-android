# OCR 识别器对比：中文识别器 vs 拉丁识别器（真机）

- 日期：2026-09-17
- 设备：Samsung SM-S948B（`R5GL44GGVTB`），Android 16 / API 36
- 起因：主要用户改为英语和法语后，重新验证"默认跑中文识别器（它同时识别汉字与拉丁字母）"这个选择
  （`docs/anonymization-design.md` 的"OCR 脚本选择"）。
- 命令：

```bash
flutter test integration_test/ocr_benchmark_test.dart -d R5GL44GGVTB
```

```bash
flutter test integration_test/ocr_benchmark_test.dart -d R5GL44GGVTB --dart-define=OCR_LATIN_SCRIPT=latin
```

第二条把 en / fr / es 用例换成拉丁识别器，zh 与 hi 用例不变（`_scriptFor`）。两轮都是 15 个用例、0 个识别错误。

## 结论

**保持现状，默认继续用中文识别器。** 13 个拉丁字母用例里，12 个两者输出完全相同；唯一有差别的那个，拉丁识别器明显更差。

## 总体

| 指标 | 中文识别器 | 拉丁识别器 |
|---|---:|---:|
| 归一化 CER | 53.3% | 53.6% |
| WER | 66.7% | 66.5% |
| 行 F1 | 30.1% | 29.7% |
| 关键信息召回 | 73.2% | 71.8% |
| 完全一致 | 2 / 15 | 2 / 15 |

（总体 CER 偏高由几张 A4 整页照片主导，与识别器选择无关。）

## 逐个用例（归一化 CER）

| 用例 | 语言 | 中文识别器 | 拉丁识别器 | 差 |
|---|---|---:|---:|---:|
| `fr-low-contrast-receipt` | fr | 5.8% | 29.8% | **+24.0** |
| `a4-en-patient-information` | en | 61.4% | 60.9% | −0.5 |
| 其余 11 个 en / fr 用例 | en / fr | — | 完全相同 | 0 |
| zh / hi / multi 用例（4 个） | zh, hi, multi | — | 未切换 | — |

## 差别出在哪

`fr-low-contrast-receipt` 是一张低对比度的法文咖啡馆收据。中文识别器保持了每行"品名 + 金额"的顺序；拉丁识别器把它拆成了两列，先输出三行品名，再输出三行金额，还把 `4,20 €` 断成 `4, 20 €`：

```
期望        2 croissants  7,80 €
中文识别器   2croissants 7,80 €
拉丁识别器   2 croissants ... （金额被挪到后面三行，4, 20 € 被断开）
```

对 Docudis 来说，行内顺序错乱会直接影响检测：关键信息召回从 4/4 掉到 3/4，金额 `4,20 €` 漏检。

## 副产品

`integration_test/ocr_benchmark_test.dart` 增加了 `--dart-define=OCR_LATIN_SCRIPT=<script>`，以后换识别器可以直接再跑一次对比，不用改数据集。
