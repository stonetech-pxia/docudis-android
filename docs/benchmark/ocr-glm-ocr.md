# OCR benchmark (local server)

- Recognizer: zai-org/GLM-OCR (whole page, prompt 'Text Recognition:', no layout model)
- Platform: Windows-11-10.0.26200-SP0 NVIDIA GeForce RTX 3080 (bfloat16)
- Cases: 15, errors: 0
- Overall: strict CER 7.6%, normalized CER 5.8%, WER 10.5%, line F1 69.2%, critical-span recall 85.9%, exact 8/15, 1481 ms/MP, reliability **C**

Strict CER preserves whitespace after line-ending canonicalization. Normalized CER and WER collapse whitespace but remain case-, punctuation-, diacritic-, symbol-, and digit-sensitive. CER counts Unicode code points (`String.runes`), not grapheme clusters. Line F1 uses exact normalized line matches.

## By language

| Group | Cases | Strict CER | Normalized CER | WER | Line F1 | Critical recall | Exact | Errors | ms/MP | Grade |
|---|---|---|---|---|---|---|---|---|---|---|
| zh-Hans | 2 | 4.0% | 0.0% | 0.0% | 100.0% | 100.0% | 2/2 | 0 | 1500 | A |
| en | 10 | 7.7% | 6.0% | 10.7% | 67.0% | 84.3% | 4/10 | 0 | 1479 | C |
| fr | 1 | 2.8% | 0.0% | 0.0% | 100.0% | 100.0% | 1/1 | 0 | 1070 | A |
| multi | 1 | 0.9% | 0.0% | 0.0% | 100.0% | 100.0% | 1/1 | 0 | 920 | A |
| hi | 1 | 14.4% | 14.4% | 36.8% | 16.7% | 50.0% | 0/1 | 0 | 2542 | D |

## By category

| Group | Cases | Strict CER | Normalized CER | WER | Line F1 | Critical recall | Exact | Errors | ms/MP | Grade |
|---|---|---|---|---|---|---|---|---|---|---|
| clean_print | 1 | 7.2% | 0.0% | 0.0% | 100.0% | 100.0% | 1/1 | 0 | 897 | A |
| perspective | 1 | 2.6% | 0.0% | 0.0% | 100.0% | 100.0% | 1/1 | 0 | 1176 | A |
| low_contrast | 1 | 2.8% | 0.0% | 0.0% | 100.0% | 100.0% | 1/1 | 0 | 1070 | A |
| mixed_script_glare | 1 | 0.9% | 0.0% | 0.0% | 100.0% | 100.0% | 1/1 | 0 | 920 | A |
| dense_label | 1 | 0.0% | 0.0% | 0.0% | 100.0% | 100.0% | 1/1 | 0 | 1065 | A |
| handwriting | 1 | 0.0% | 0.0% | 0.0% | 100.0% | 100.0% | 1/1 | 0 | 873 | A |
| screen_glare | 1 | 0.0% | 0.0% | 0.0% | 100.0% | 100.0% | 1/1 | 0 | 1126 | A |
| devanagari | 1 | 14.4% | 14.4% | 36.8% | 16.7% | 50.0% | 0/1 | 0 | 2542 | D |
| real_receipt_photo | 1 | 8.6% | 8.6% | 34.1% | 29.6% | 75.0% | 0/1 | 0 | 4043 | D |
| real_business_card_perspective | 1 | 39.5% | 38.0% | 42.9% | 15.4% | 100.0% | 0/1 | 0 | 3384 | D |
| real_bilingual_card_photo | 1 | 1.9% | 0.0% | 0.0% | 100.0% | 100.0% | 1/1 | 0 | 2272 | A |
| real_contact_card | 1 | 9.4% | 8.9% | 24.2% | 72.7% | 60.0% | 0/1 | 0 | 7106 | D |
| a4_bank_statement_photo | 1 | 4.6% | 4.2% | 5.8% | 87.5% | 80.0% | 0/1 | 0 | 1982 | C |
| a4_lease_photo_handwriting | 1 | 7.1% | 2.4% | 9.0% | 16.2% | 50.0% | 0/1 | 0 | 2140 | B |
| a4_medical_form_photo | 1 | 13.6% | 12.2% | 15.4% | 87.2% | 83.3% | 0/1 | 0 | 412 | D |

## Per case

| Case | Language | Category | Size | Strict CER | Normalized CER | WER | Line F1 | Critical | Exact | ms | ms/MP | Notes |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| zh-clean-notice | zh-Hans | clean_print | 1055×1491 | 7.2% | 0.0% | 0.0% | 100.0% | 4/4 | yes | 1411 | 897 |  |
| en-perspective-invoice | en | perspective | 1086×1448 | 2.6% | 0.0% | 0.0% | 100.0% | 6/6 | yes | 1848 | 1176 |  |
| fr-low-contrast-receipt | fr | low_contrast | 1024×1536 | 2.8% | 0.0% | 0.0% | 100.0% | 4/4 | yes | 1682 | 1070 |  |
| multi-screen-glare | multi | mixed_script_glare | 1536×1024 | 0.9% | 0.0% | 0.0% | 100.0% | 5/5 | yes | 1447 | 920 |  |
| shipping-label-dense | en | dense_label | 1448×1086 | 0.0% | 0.0% | 0.0% | 100.0% | 5/5 | yes | 1674 | 1065 |  |
| en-handwritten-note | en | handwriting | 1254×1254 | 0.0% | 0.0% | 0.0% | 100.0% | 5/5 | yes | 1372 | 873 |  |
| en-screen-access | en | screen_glare | 1536×1024 | 0.0% | 0.0% | 0.0% | 100.0% | 4/4 | yes | 1771 | 1126 |  |
| hi-clean-notice | hi | devanagari | 1091×1442 | 14.4% | 14.4% | 36.8% | 16.7% | 2/4 | no | 3999 | 2542 | missed: 16 सितंबर 2026(DATE), राहुल शर्मा(PERSON) |
| doc-en-prepaid-receipt | en | real_receipt_photo | 1280×2276 | 8.6% | 8.6% | 34.1% | 29.6% | 3/4 | no | 11778 | 4043 | missed: 119322644410(ID) |
| doc-en-traf-o-data-card | en | real_business_card_perspective | 1280×960 | 39.5% | 38.0% | 42.9% | 15.4% | 5/5 | no | 4158 | 3384 |  |
| doc-zh-boarding-confirmation-card | zh-Hans | real_bilingual_card_photo | 1280×960 | 1.9% | 0.0% | 0.0% | 100.0% | 3/3 | yes | 2791 | 2272 |  |
| doc-en-ziartides-business-card | en | real_contact_card | 1023×598 | 9.4% | 8.9% | 24.2% | 72.7% | 3/5 | no | 4347 | 7106 | missed: 31-35 Archemou Str. Nicosia(ADDRESS), 73192 - 96(PHONE) |
| a4-en-bank-statement | en | a4_bank_statement_photo | 4284×5712 | 4.6% | 4.2% | 5.8% | 87.5% | 4/5 | no | 48496 | 1982 | missed: 212 Beier Walks North Richland Hills Kentucky, 18382-7941(ADDRESS) |
| a4-en-commercial-lease | en | a4_lease_photo_handwriting | 1840×2592 | 7.1% | 2.4% | 9.0% | 16.2% | 3/6 | no | 10204 | 2140 | missed: Mrs. Patti Fay MD(PERSON), Weimann Inc(COMPANY), 84784 Godfrey Grove(ADDRESS) |
| a4-en-patient-information | en | a4_medical_form_photo | 5712×4284 | 13.6% | 12.2% | 15.4% | 87.2% | 5/6 | no | 10088 | 412 | missed: Jessica Smith(PERSON) |
