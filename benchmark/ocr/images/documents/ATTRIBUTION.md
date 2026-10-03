# Real-document OCR fixtures

These are photographs or digital captures of real paper documents from
Wikimedia Commons. The benchmark manifest preserves the same provenance in
device-run JSON and generated HTML reports.

| Local file | Source | Author | License | Document type |
|---|---|---|---|---|
| `doc-en-receipt.jpg` | [Receipt](https://commons.wikimedia.org/wiki/File:Receipt.jpg) | Deavmi | CC BY-SA 3.0 | Hand-held prepaid voucher receipt |
| `doc-en-business-card.jpg` | [Traf-O-Data Business Card](https://commons.wikimedia.org/wiki/File:Traf-O-Data_Business_Card.jpg) | Marcin Wichary | CC BY 2.0 | Business card photographed through a display holder |
| `doc-zh-boarding-card.jpg` | [Boarding Pass Confirmation Card, Baiyun Airport](https://commons.wikimedia.org/wiki/File:Boarding_Pass_Confirmation_Card,_Baiyun_Airport.jpg) | David290 | CC BY-SA 4.0 | Hand-held bilingual airport document |
| `doc-el-business-card.jpg` | [Business Card](https://commons.wikimedia.org/wiki/File:Business_Card.jpg) | Evnicky | CC BY-SA 4.0 | Contact-information business card |

## Full-page A4 document fixtures

These samples and their reference transcriptions come from the permissive
MIT-licensed `getomni-ai/ocr-benchmark` subset, selected through the
[OCR Benchmark — Documents](https://huggingface.co/datasets/ilsilfverskiold/ocr-benchmark)
corpus. Long reference text is stored under `benchmark/ocr/ground_truth/` and
converted from lightweight Markdown to visible plain text before scoring.

| Local file | Source row | Document type | Capture conditions |
|---|---|---|---|
| `a4-en-bank-statement.jpg` | `bank_000` | Bank statement | Hand-held page, perspective, screen background |
| `a4-en-lease.jpg` | `lease_000` | Commercial lease | Mobile scan, paper texture, printed and handwritten text |
| `a4-en-medical.jpg` | `medical_000` | Patient information form | Desk photo, slight perspective, checkboxes and signature |

The `doc-*` files are resized versions of the Commons files above; the
`a4-*` files are resized versions of the getomni-ai/ocr-benchmark images (MIT
License). No text was composited or rewritten. Preserve attribution and
share-alike requirements when redistributing the affected fixtures or
derivatives. These files are test data only: Android release builds leave out
`benchmark/`.
