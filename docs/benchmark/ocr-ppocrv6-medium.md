# OCR benchmark (local server)

- Recognizer: PP-OCRv6-medium (PP-OCRv6_medium_det + PP-OCRv6_medium_rec; script recognizers: devanagari_PP-OCRv5_mobile_rec; 32px white padding; oneDNN disabled)
- Platform: Windows-11-10.0.26200-SP0 CPU
- Cases: 15, errors: 0
- Overall: strict CER 28.7%, normalized CER 25.8%, WER 33.4%, line F1 38.6%, critical-span recall 87.3%, exact 6/15, 11437 ms/MP, reliability **D**

Strict CER preserves whitespace after line-ending canonicalization. Normalized CER and WER collapse whitespace but remain case-, punctuation-, diacritic-, symbol-, and digit-sensitive. CER counts Unicode code points (`String.runes`), not grapheme clusters. Line F1 uses exact normalized line matches.

## By language

| Group | Cases | Strict CER | Normalized CER | WER | Line F1 | Critical recall | Exact | Errors | ms/MP | Grade |
|---|---|---|---|---|---|---|---|---|---|---|
| zh-Hans | 2 | 0.6% | 0.6% | 9.1% | 90.9% | 100.0% | 1/2 | 0 | 10341 | A |
| en | 10 | 30.0% | 27.1% | 34.5% | 36.2% | 86.3% | 4/10 | 0 | 9785 | D |
| fr | 1 | 4.7% | 0.0% | 0.0% | 57.1% | 100.0% | 1/1 | 0 | 20824 | A |
| multi | 1 | 6.4% | 6.4% | 35.0% | 66.7% | 100.0% | 0/1 | 0 | 47749 | C |
| hi | 1 | 34.2% | 32.4% | 42.1% | 12.5% | 50.0% | 0/1 | 0 | 35682 | D |

## By category

| Group | Cases | Strict CER | Normalized CER | WER | Line F1 | Critical recall | Exact | Errors | ms/MP | Grade |
|---|---|---|---|---|---|---|---|---|---|---|
| clean_print | 1 | 0.0% | 0.0% | 0.0% | 100.0% | 100.0% | 1/1 | 0 | 10513 | A |
| perspective | 1 | 0.0% | 0.0% | 0.0% | 100.0% | 100.0% | 1/1 | 0 | 11715 | A |
| low_contrast | 1 | 4.7% | 0.0% | 0.0% | 57.1% | 100.0% | 1/1 | 0 | 20824 | A |
| mixed_script_glare | 1 | 6.4% | 6.4% | 35.0% | 66.7% | 100.0% | 0/1 | 0 | 47749 | C |
| dense_label | 1 | 0.0% | 0.0% | 0.0% | 100.0% | 100.0% | 1/1 | 0 | 21291 | A |
| handwriting | 1 | 0.0% | 0.0% | 0.0% | 100.0% | 100.0% | 1/1 | 0 | 39760 | A |
| screen_glare | 1 | 0.0% | 0.0% | 0.0% | 100.0% | 100.0% | 1/1 | 0 | 39714 | A |
| devanagari | 1 | 34.2% | 32.4% | 42.1% | 12.5% | 50.0% | 0/1 | 0 | 35682 | D |
| real_receipt_photo | 1 | 24.8% | 23.7% | 48.8% | 19.4% | 75.0% | 0/1 | 0 | 39057 | D |
| real_business_card_perspective | 1 | 24.0% | 24.0% | 38.1% | 58.8% | 80.0% | 0/1 | 0 | 11158 | D |
| real_bilingual_card_photo | 1 | 1.0% | 1.0% | 14.3% | 80.0% | 100.0% | 0/1 | 0 | 10121 | A |
| real_contact_card | 1 | 40.9% | 40.9% | 51.5% | 69.6% | 60.0% | 0/1 | 0 | 15720 | D |
| a4_bank_statement_photo | 1 | 45.0% | 40.5% | 50.6% | 9.4% | 100.0% | 0/1 | 0 | 5527 | D |
| a4_lease_photo_handwriting | 1 | 10.2% | 6.4% | 12.2% | 45.8% | 66.7% | 0/1 | 0 | 11474 | C |
| a4_medical_form_photo | 1 | 35.1% | 33.7% | 44.6% | 62.5% | 83.3% | 0/1 | 0 | 5300 | D |

## Per case

| Case | Language | Category | Size | Strict CER | Normalized CER | WER | Line F1 | Critical | Exact | ms | ms/MP | Notes |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| zh-clean-notice | zh-Hans | clean_print | 1055×1491 | 0.0% | 0.0% | 0.0% | 100.0% | 4/4 | yes | 16536 | 10513 |  |
| en-perspective-invoice | en | perspective | 1086×1448 | 0.0% | 0.0% | 0.0% | 100.0% | 6/6 | yes | 18421 | 11715 |  |
| fr-low-contrast-receipt | fr | low_contrast | 1024×1536 | 4.7% | 0.0% | 0.0% | 57.1% | 4/4 | yes | 32752 | 20824 |  |
| multi-screen-glare | multi | mixed_script_glare | 1536×1024 | 6.4% | 6.4% | 35.0% | 66.7% | 5/5 | no | 75102 | 47749 |  |
| shipping-label-dense | en | dense_label | 1448×1086 | 0.0% | 0.0% | 0.0% | 100.0% | 5/5 | yes | 33480 | 21291 |  |
| en-handwritten-note | en | handwriting | 1254×1254 | 0.0% | 0.0% | 0.0% | 100.0% | 5/5 | yes | 62523 | 39760 |  |
| en-screen-access | en | screen_glare | 1536×1024 | 0.0% | 0.0% | 0.0% | 100.0% | 4/4 | yes | 62464 | 39714 |  |
| hi-clean-notice | hi | devanagari | 1091×1442 | 34.2% | 32.4% | 42.1% | 12.5% | 2/4 | no | 56135 | 35682 | missed: राहुल शर्मा(PERSON), 204(ID) |
| doc-en-prepaid-receipt | en | real_receipt_photo | 1280×2276 | 24.8% | 23.7% | 48.8% | 19.4% | 3/4 | no | 113784 | 39057 | missed: 119322644410(ID) |
| doc-en-traf-o-data-card | en | real_business_card_perspective | 1280×960 | 24.0% | 24.0% | 38.1% | 58.8% | 4/5 | no | 13710 | 11158 | missed: 19506 RICHMOND BEACH DR NW(ADDRESS) |
| doc-zh-boarding-confirmation-card | zh-Hans | real_bilingual_card_photo | 1280×960 | 1.0% | 1.0% | 14.3% | 80.0% | 3/3 | no | 12436 | 10121 |  |
| doc-en-ziartides-business-card | en | real_contact_card | 1023×598 | 40.9% | 40.9% | 51.5% | 69.6% | 3/5 | no | 9616 | 15720 | missed: 31-35 Archemou Str. Nicosia(ADDRESS), 73192 - 96(PHONE) |
| a4-en-bank-statement | en | a4_bank_statement_photo | 4284×5712 | 45.0% | 40.5% | 50.6% | 9.4% | 5/5 | no | 135236 | 5527 |  |
| a4-en-commercial-lease | en | a4_lease_photo_handwriting | 1840×2592 | 10.2% | 6.4% | 12.2% | 45.8% | 4/6 | no | 54721 | 11474 | missed: Weimann Inc(COMPANY), 84784 Godfrey Grove(ADDRESS) |
| a4-en-patient-information | en | a4_medical_form_photo | 5712×4284 | 35.1% | 33.7% | 44.6% | 62.5% | 5/6 | no | 129688 | 5300 | missed: Jessica Smith(PERSON) |
