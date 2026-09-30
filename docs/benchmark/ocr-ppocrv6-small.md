# OCR benchmark (local server)

- Recognizer: PP-OCRv6-small (PP-OCRv6_small_det + PP-OCRv6_small_rec; oneDNN disabled)
- Platform: Windows-11-10.0.26200-SP0 CPU
- Cases: 15, errors: 0
- Overall: strict CER 29.4%, normalized CER 26.5%, WER 34.3%, line F1 34.8%, critical-span recall 85.9%, exact 3/15, 3037 ms/MP, reliability **D**

Strict CER preserves whitespace after line-ending canonicalization. Normalized CER and WER collapse whitespace but remain case-, punctuation-, diacritic-, symbol-, and digit-sensitive. CER counts Unicode code points (`String.runes`), not grapheme clusters. Line F1 uses exact normalized line matches.

## By language

| Group | Cases | Strict CER | Normalized CER | WER | Line F1 | Critical recall | Exact | Errors | ms/MP | Grade |
|---|---|---|---|---|---|---|---|---|---|---|
| zh-Hans | 2 | 1.7% | 1.7% | 22.7% | 81.8% | 85.7% | 0/2 | 0 | 4215 | B |
| en | 10 | 30.4% | 27.3% | 34.7% | 33.2% | 86.3% | 2/10 | 0 | 2907 | D |
| fr | 1 | 5.6% | 0.0% | 0.0% | 40.0% | 100.0% | 1/1 | 0 | 4208 | A |
| multi | 1 | 5.5% | 5.5% | 30.0% | 50.0% | 100.0% | 0/1 | 0 | 4201 | C |
| hi | 1 | 62.2% | 65.8% | 73.7% | 0.0% | 50.0% | 0/1 | 0 | 3918 | D |

## By category

| Group | Cases | Strict CER | Normalized CER | WER | Line F1 | Critical recall | Exact | Errors | ms/MP | Grade |
|---|---|---|---|---|---|---|---|---|---|---|
| clean_print | 1 | 2.9% | 2.9% | 37.5% | 83.3% | 75.0% | 0/1 | 0 | 4073 | B |
| perspective | 1 | 0.0% | 0.0% | 0.0% | 100.0% | 100.0% | 1/1 | 0 | 3925 | A |
| low_contrast | 1 | 5.6% | 0.0% | 0.0% | 40.0% | 100.0% | 1/1 | 0 | 4208 | A |
| mixed_script_glare | 1 | 5.5% | 5.5% | 30.0% | 50.0% | 100.0% | 0/1 | 0 | 4201 | C |
| dense_label | 1 | 0.0% | 0.0% | 0.0% | 100.0% | 100.0% | 1/1 | 0 | 4010 | A |
| handwriting | 1 | 1.1% | 1.1% | 10.5% | 75.0% | 100.0% | 0/1 | 0 | 3707 | B |
| screen_glare | 1 | 1.7% | 1.7% | 14.3% | 83.3% | 100.0% | 0/1 | 0 | 4132 | B |
| devanagari | 1 | 62.2% | 65.8% | 73.7% | 0.0% | 50.0% | 0/1 | 0 | 3918 | D |
| real_receipt_photo | 1 | 21.4% | 20.7% | 51.2% | 13.3% | 75.0% | 0/1 | 0 | 4099 | D |
| real_business_card_perspective | 1 | 21.7% | 21.7% | 28.6% | 75.0% | 80.0% | 0/1 | 0 | 4477 | D |
| real_bilingual_card_photo | 1 | 1.0% | 1.0% | 14.3% | 80.0% | 100.0% | 0/1 | 0 | 4396 | A |
| real_contact_card | 1 | 41.4% | 40.9% | 57.6% | 58.3% | 40.0% | 0/1 | 0 | 7564 | D |
| a4_bank_statement_photo | 1 | 44.8% | 40.4% | 50.3% | 8.6% | 100.0% | 0/1 | 0 | 2707 | D |
| a4_lease_photo_handwriting | 1 | 11.4% | 7.0% | 11.8% | 36.4% | 83.3% | 0/1 | 0 | 5467 | C |
| a4_medical_form_photo | 1 | 36.3% | 34.8% | 44.1% | 62.5% | 83.3% | 0/1 | 0 | 2005 | D |

## Per case

| Case | Language | Category | Size | Strict CER | Normalized CER | WER | Line F1 | Critical | Exact | ms | ms/MP | Notes |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| zh-clean-notice | zh-Hans | clean_print | 1055×1491 | 2.9% | 2.9% | 37.5% | 83.3% | 3/4 | no | 6407 | 4073 | missed: 138 2468 1357(PHONE) |
| en-perspective-invoice | en | perspective | 1086×1448 | 0.0% | 0.0% | 0.0% | 100.0% | 6/6 | yes | 6172 | 3925 |  |
| fr-low-contrast-receipt | fr | low_contrast | 1024×1536 | 5.6% | 0.0% | 0.0% | 40.0% | 4/4 | yes | 6619 | 4208 |  |
| multi-screen-glare | multi | mixed_script_glare | 1536×1024 | 5.5% | 5.5% | 30.0% | 50.0% | 5/5 | no | 6608 | 4201 |  |
| shipping-label-dense | en | dense_label | 1448×1086 | 0.0% | 0.0% | 0.0% | 100.0% | 5/5 | yes | 6305 | 4010 |  |
| en-handwritten-note | en | handwriting | 1254×1254 | 1.1% | 1.1% | 10.5% | 75.0% | 5/5 | no | 5829 | 3707 |  |
| en-screen-access | en | screen_glare | 1536×1024 | 1.7% | 1.7% | 14.3% | 83.3% | 4/4 | no | 6499 | 4132 |  |
| hi-clean-notice | hi | devanagari | 1091×1442 | 62.2% | 65.8% | 73.7% | 0.0% | 2/4 | no | 6163 | 3918 | missed: 16 सितंबर 2026(DATE), राहुल शर्मा(PERSON) |
| doc-en-prepaid-receipt | en | real_receipt_photo | 1280×2276 | 21.4% | 20.7% | 51.2% | 13.3% | 3/4 | no | 11940 | 4099 | missed: 119322644410(ID) |
| doc-en-traf-o-data-card | en | real_business_card_perspective | 1280×960 | 21.7% | 21.7% | 28.6% | 75.0% | 4/5 | no | 5501 | 4477 | missed: 19506 RICHMOND BEACH DR NW(ADDRESS) |
| doc-zh-boarding-confirmation-card | zh-Hans | real_bilingual_card_photo | 1280×960 | 1.0% | 1.0% | 14.3% | 80.0% | 3/3 | no | 5401 | 4396 |  |
| doc-en-ziartides-business-card | en | real_contact_card | 1023×598 | 41.4% | 40.9% | 57.6% | 58.3% | 2/5 | no | 4627 | 7564 | missed: 31-35 Archemou Str. Nicosia(ADDRESS), 7 Acropolis Av.(ADDRESS), 73192 - 96(PHONE) |
| a4-en-bank-statement | en | a4_bank_statement_photo | 4284×5712 | 44.8% | 40.4% | 50.3% | 8.6% | 5/5 | no | 66250 | 2707 |  |
| a4-en-commercial-lease | en | a4_lease_photo_handwriting | 1840×2592 | 11.4% | 7.0% | 11.8% | 36.4% | 5/6 | no | 26075 | 5467 | missed: Weimann Inc(COMPANY) |
| a4-en-patient-information | en | a4_medical_form_photo | 5712×4284 | 36.3% | 34.8% | 44.1% | 62.5% | 5/6 | no | 49063 | 2005 | missed: Jessica Smith(PERSON) |
