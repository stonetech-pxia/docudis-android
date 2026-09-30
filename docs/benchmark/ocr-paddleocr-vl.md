# OCR benchmark (local server)

- Recognizer: PaddlePaddle/PaddleOCR-VL-1.6 (whole page, prompt 'OCR:', no layout model)
- Platform: Windows-11-10.0.26200-SP0 NVIDIA GeForce RTX 3080 (bfloat16)
- Cases: 15, errors: 0
- Overall: strict CER 88.9%, normalized CER 85.6%, WER 139.2%, line F1 11.6%, critical-span recall 85.9%, exact 7/15, 28134 ms/MP, reliability **D**

Strict CER preserves whitespace after line-ending canonicalization. Normalized CER and WER collapse whitespace but remain case-, punctuation-, diacritic-, symbol-, and digit-sensitive. CER counts Unicode code points (`String.runes`), not grapheme clusters. Line F1 uses exact normalized line matches.

## By language

| Group | Cases | Strict CER | Normalized CER | WER | Line F1 | Critical recall | Exact | Errors | ms/MP | Grade |
|---|---|---|---|---|---|---|---|---|---|---|
| zh-Hans | 2 | 1.2% | 0.0% | 0.0% | 100.0% | 100.0% | 2/2 | 0 | 11685 | A |
| en | 10 | 95.1% | 91.8% | 150.6% | 9.2% | 82.4% | 4/10 | 0 | 29832 | D |
| fr | 1 | 2.8% | 0.0% | 0.0% | 100.0% | 100.0% | 1/1 | 0 | 14236 | A |
| multi | 1 | 9.1% | 9.1% | 10.0% | 83.3% | 80.0% | 0/1 | 0 | 14053 | D |
| hi | 1 | 11.7% | 7.2% | 10.5% | 0.0% | 100.0% | 0/1 | 0 | 15539 | C |

## By category

| Group | Cases | Strict CER | Normalized CER | WER | Line F1 | Critical recall | Exact | Errors | ms/MP | Grade |
|---|---|---|---|---|---|---|---|---|---|---|
| clean_print | 1 | 0.0% | 0.0% | 0.0% | 100.0% | 100.0% | 1/1 | 0 | 12387 | A |
| perspective | 1 | 2.6% | 0.0% | 0.0% | 100.0% | 100.0% | 1/1 | 0 | 12544 | A |
| low_contrast | 1 | 2.8% | 0.0% | 0.0% | 100.0% | 100.0% | 1/1 | 0 | 14236 | A |
| mixed_script_glare | 1 | 9.1% | 9.1% | 10.0% | 83.3% | 80.0% | 0/1 | 0 | 14053 | D |
| dense_label | 1 | 0.0% | 0.0% | 0.0% | 100.0% | 100.0% | 1/1 | 0 | 13942 | A |
| handwriting | 1 | 0.0% | 0.0% | 0.0% | 100.0% | 100.0% | 1/1 | 0 | 9355 | A |
| screen_glare | 1 | 0.0% | 0.0% | 0.0% | 100.0% | 100.0% | 1/1 | 0 | 12430 | A |
| devanagari | 1 | 11.7% | 7.2% | 10.5% | 0.0% | 100.0% | 0/1 | 0 | 15539 | C |
| real_receipt_photo | 1 | 14.3% | 13.5% | 39.0% | 21.4% | 75.0% | 0/1 | 0 | 17212 | D |
| real_business_card_perspective | 1 | 6.2% | 3.1% | 9.5% | 82.4% | 100.0% | 0/1 | 0 | 17405 | C |
| real_bilingual_card_photo | 1 | 1.9% | 0.0% | 0.0% | 100.0% | 100.0% | 1/1 | 0 | 10787 | A |
| real_contact_card | 1 | 3.9% | 3.0% | 30.3% | 72.7% | 60.0% | 0/1 | 0 | 25318 | B |
| a4_bank_statement_photo | 1 | 214.5% | 208.3% | 386.1% | 0.2% | 20.0% | 0/1 | 0 | 60067 | D |
| a4_lease_photo_handwriting | 1 | 9.0% | 4.2% | 12.9% | 19.7% | 83.3% | 0/1 | 0 | 31269 | C |
| a4_medical_form_photo | 1 | 35.8% | 34.7% | 45.1% | 54.3% | 83.3% | 0/1 | 0 | 6122 | D |

## Per case

| Case | Language | Category | Size | Strict CER | Normalized CER | WER | Line F1 | Critical | Exact | ms | ms/MP | Notes |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| zh-clean-notice | zh-Hans | clean_print | 1055×1491 | 0.0% | 0.0% | 0.0% | 100.0% | 4/4 | yes | 19484 | 12387 |  |
| en-perspective-invoice | en | perspective | 1086×1448 | 2.6% | 0.0% | 0.0% | 100.0% | 6/6 | yes | 19725 | 12544 |  |
| fr-low-contrast-receipt | fr | low_contrast | 1024×1536 | 2.8% | 0.0% | 0.0% | 100.0% | 4/4 | yes | 22391 | 14236 |  |
| multi-screen-glare | multi | mixed_script_glare | 1536×1024 | 9.1% | 9.1% | 10.0% | 83.3% | 4/5 | no | 22104 | 14053 | missed: Docudis_Guest(SECRET) |
| shipping-label-dense | en | dense_label | 1448×1086 | 0.0% | 0.0% | 0.0% | 100.0% | 5/5 | yes | 21924 | 13942 |  |
| en-handwritten-note | en | handwriting | 1254×1254 | 0.0% | 0.0% | 0.0% | 100.0% | 5/5 | yes | 14711 | 9355 |  |
| en-screen-access | en | screen_glare | 1536×1024 | 0.0% | 0.0% | 0.0% | 100.0% | 4/4 | yes | 19551 | 12430 |  |
| hi-clean-notice | hi | devanagari | 1091×1442 | 11.7% | 7.2% | 10.5% | 0.0% | 4/4 | no | 24446 | 15539 |  |
| doc-en-prepaid-receipt | en | real_receipt_photo | 1280×2276 | 14.3% | 13.5% | 39.0% | 21.4% | 3/4 | no | 50141 | 17212 | missed: 119322644410(ID) |
| doc-en-traf-o-data-card | en | real_business_card_perspective | 1280×960 | 6.2% | 3.1% | 9.5% | 82.4% | 5/5 | no | 21386 | 17405 |  |
| doc-zh-boarding-confirmation-card | zh-Hans | real_bilingual_card_photo | 1280×960 | 1.9% | 0.0% | 0.0% | 100.0% | 3/3 | yes | 13254 | 10787 |  |
| doc-en-ziartides-business-card | en | real_contact_card | 1023×598 | 3.9% | 3.0% | 30.3% | 72.7% | 3/5 | no | 15488 | 25318 | missed: 31-35 Archemou Str. Nicosia(ADDRESS), 73192 - 96(PHONE) |
| a4-en-bank-statement | en | a4_bank_statement_photo | 4284×5712 | 214.5% | 208.3% | 386.1% | 0.2% | 1/5 | no | 1469845 | 60067 | missed: Dr. Gregory Frami(PERSON), jUefATevv(ID), 212 Beier Walks North Richland Hills Kentucky, 18382-7941(ADDRESS), 663 999-5583(PHONE) |
| a4-en-commercial-lease | en | a4_lease_photo_handwriting | 1840×2592 | 9.0% | 4.2% | 12.9% | 19.7% | 5/6 | no | 149129 | 31269 | missed: Mrs. Patti Fay MD(PERSON) |
| a4-en-patient-information | en | a4_medical_form_photo | 5712×4284 | 35.8% | 34.7% | 45.1% | 54.3% | 5/6 | no | 149809 | 6122 | missed: Jessica Smith(PERSON) |
