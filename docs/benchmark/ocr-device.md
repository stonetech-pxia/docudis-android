# OCR Device Benchmark

- Date: 2026-09-17
- Device: Samsung SM-S948B (`R5GL44GGVTB`), Android 16 / API 36
- Recognizer: Google ML Kit on-device text recognition (`chinese`, `devanagari`)
- Command: `flutter test integration_test/ocr_benchmark_test.dart -d R5GL44GGVTB`
- Result: **PASS** — 15 cases executed, 0 recognition errors

> `PASS` means the benchmark pipeline completed without recognition exceptions. It does not mean that every OCR result met an accuracy threshold.

## Overall

| Metric | Result |
|---|---:|
| Strict CER | 55.3% |
| Normalized CER | 53.3% |
| WER | 66.7% |
| Line F1 | 30.1% |
| Critical-span recall | 73.2% |
| Exact matches | 2 / 15 |
| Processing speed | 24 ms/MP |
| Reliability grade | D |

## Per-case results

| Case | Accuracy | Normalized CER | WER | Critical spans | Time |
|---|---:|---:|---:|---:|---:|
| `zh-clean-notice` | 87.0% | 13.0% | 100.0% | 2 / 4 | 61 ms |
| `en-perspective-invoice` | 100.0% | 0.0% | 0.0% | 6 / 6 | 64 ms |
| `fr-low-contrast-receipt` | 94.2% | 5.8% | 30.4% | 4 / 4 | 66 ms |
| `multi-screen-glare` | 94.5% | 5.5% | 50.0% | 5 / 5 | 67 ms |
| `shipping-label-dense` | 100.0% | 0.0% | 0.0% | 5 / 5 | 70 ms |
| `en-handwritten-note` | 97.8% | 2.2% | 10.5% | 4 / 5 | 56 ms |
| `en-screen-access` | 98.3% | 1.7% | 28.6% | 2 / 4 | 66 ms |
| `hi-clean-notice` | 98.2% | 1.8% | 10.5% | 4 / 4 | 52 ms |
| `doc-en-prepaid-receipt` | 84.6% | 15.4% | 51.2% | 3 / 4 | 88 ms |
| `doc-en-traf-o-data-card` | 77.5% | 22.5% | 33.3% | 3 / 5 | 58 ms |
| `doc-zh-boarding-confirmation-card` | 93.3% | 6.7% | 14.3% | 2 / 3 | 46 ms |
| `doc-en-ziartides-business-card` | 92.6% | 7.4% | 15.2% | 3 / 5 | 73 ms |
| `a4-en-bank-statement` | 15.3% | 84.7% | 98.6% | 5 / 5 | 458 ms |
| `a4-en-commercial-lease` | 60.5% | 39.5% | 54.5% | 0 / 6 | 221 ms |
| `a4-en-patient-information` | 38.6% | 61.4% | 79.0% | 4 / 6 | 270 ms |

## A4 document observations

- Bank statement: all 5 critical values were found, but table reading order caused very high full-page CER/WER.
- Commercial lease: all 6 handwritten critical spans were missed; printed text was partially recognized.
- Patient information form: 4 of 6 critical spans were found. The name was split across fields, and `1QOSXUU56G` was misread.
- The three complex A4 layouts are the main reason the overall reliability grade is D.
