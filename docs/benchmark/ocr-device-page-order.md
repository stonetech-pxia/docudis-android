# OCR benchmark (device)

- Recognizer: Google ML Kit (chinese, devanagiri; page order)
- Platform: android BP4A.251205.006.S948BXXS4AZHL, Google ML Kit on-device text recognition
- Cases: 15, errors: 0
- Overall: strict CER 14.6%, normalized CER 10.3%, WER 24.0%, line F1 37.1%, critical-span recall 73.2%, exact 2/15, 24 ms/MP, reliability **D**

Strict CER preserves whitespace after line-ending canonicalization. Normalized CER and WER collapse whitespace but remain case-, punctuation-, diacritic-, symbol-, and digit-sensitive. CER counts Unicode code points (`String.runes`), not grapheme clusters. Line F1 uses exact normalized line matches.

## By language

| Group | Cases | Strict CER | Normalized CER | WER | Line F1 | Critical recall | Exact | Errors | ms/MP | Grade |
|---|---|---|---|---|---|---|---|---|---|---|
| zh-Hans | 2 | 9.2% | 9.2% | 45.5% | 36.4% | 57.1% | 0/2 | 0 | 38 | D |
| en | 10 | 15.2% | 10.7% | 23.1% | 36.4% | 68.6% | 2/10 | 0 | 22 | D |
| fr | 1 | 9.3% | 5.8% | 30.4% | 33.3% | 100.0% | 0/1 | 0 | 44 | C |
| multi | 1 | 5.5% | 5.5% | 50.0% | 33.3% | 100.0% | 0/1 | 0 | 45 | C |
| hi | 1 | 1.8% | 1.8% | 10.5% | 66.7% | 100.0% | 0/1 | 0 | 34 | B |

## By category

| Group | Cases | Strict CER | Normalized CER | WER | Line F1 | Critical recall | Exact | Errors | ms/MP | Grade |
|---|---|---|---|---|---|---|---|---|---|---|
| clean_print | 1 | 13.0% | 13.0% | 100.0% | 0.0% | 50.0% | 0/1 | 0 | 39 | D |
| perspective | 1 | 0.0% | 0.0% | 0.0% | 100.0% | 100.0% | 1/1 | 0 | 42 | A |
| low_contrast | 1 | 9.3% | 5.8% | 30.4% | 33.3% | 100.0% | 0/1 | 0 | 44 | C |
| mixed_script_glare | 1 | 5.5% | 5.5% | 50.0% | 33.3% | 100.0% | 0/1 | 0 | 45 | C |
| dense_label | 1 | 0.0% | 0.0% | 0.0% | 100.0% | 100.0% | 1/1 | 0 | 44 | A |
| handwriting | 1 | 2.2% | 2.2% | 10.5% | 50.0% | 80.0% | 0/1 | 0 | 41 | B |
| screen_glare | 1 | 1.7% | 1.7% | 28.6% | 66.7% | 50.0% | 0/1 | 0 | 49 | B |
| devanagari | 1 | 1.8% | 1.8% | 10.5% | 66.7% | 100.0% | 0/1 | 0 | 34 | B |
| real_receipt_photo | 1 | 12.8% | 11.7% | 48.8% | 23.1% | 75.0% | 0/1 | 0 | 35 | D |
| real_business_card_perspective | 1 | 39.5% | 38.8% | 47.6% | 30.8% | 60.0% | 0/1 | 0 | 46 | D |
| real_bilingual_card_photo | 1 | 6.7% | 6.7% | 14.3% | 80.0% | 66.7% | 0/1 | 0 | 36 | C |
| real_contact_card | 1 | 42.9% | 42.9% | 60.6% | 72.7% | 60.0% | 0/1 | 0 | 106 | D |
| a4_bank_statement_photo | 1 | 17.4% | 11.3% | 21.1% | 38.5% | 100.0% | 0/1 | 0 | 18 | D |
| a4_lease_photo_handwriting | 1 | 12.3% | 7.2% | 18.6% | 18.2% | 0.0% | 0/1 | 0 | 45 | C |
| a4_medical_form_photo | 1 | 13.3% | 9.1% | 24.1% | 20.8% | 66.7% | 0/1 | 0 | 11 | D |

## Per case

| Case | Language | Category | Size | Strict CER | Normalized CER | WER | Line F1 | Critical | Exact | ms | ms/MP | Notes |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| zh-clean-notice | zh-Hans | clean_print | 1055×1491 | 13.0% | 13.0% | 100.0% | 0.0% | 2/4 | no | 61 | 39 | missed: 星河数据科技有限公司(COMPANY), 138 2468 1357(PHONE) |
| en-perspective-invoice | en | perspective | 1086×1448 | 0.0% | 0.0% | 0.0% | 100.0% | 6/6 | yes | 66 | 42 |  |
| fr-low-contrast-receipt | fr | low_contrast | 1024×1536 | 9.3% | 5.8% | 30.4% | 33.3% | 4/4 | no | 69 | 44 |  |
| multi-screen-glare | multi | mixed_script_glare | 1536×1024 | 5.5% | 5.5% | 50.0% | 33.3% | 5/5 | no | 70 | 45 |  |
| shipping-label-dense | en | dense_label | 1448×1086 | 0.0% | 0.0% | 0.0% | 100.0% | 5/5 | yes | 68 | 44 |  |
| en-handwritten-note | en | handwriting | 1254×1254 | 2.2% | 2.2% | 10.5% | 50.0% | 4/5 | no | 64 | 41 | missed: 7391(SECRET) |
| en-screen-access | en | screen_glare | 1536×1024 | 1.7% | 1.7% | 28.6% | 66.7% | 2/4 | no | 76 | 49 | missed: ana.lopez@example.es(EMAIL), 192.168.1.24(IP) |
| hi-clean-notice | hi | devanagari | 1091×1442 | 1.8% | 1.8% | 10.5% | 66.7% | 4/4 | no | 53 | 34 |  |
| doc-en-prepaid-receipt | en | real_receipt_photo | 1280×2276 | 12.8% | 11.7% | 48.8% | 23.1% | 3/4 | no | 101 | 35 | missed: 119322644410(ID) |
| doc-en-traf-o-data-card | en | real_business_card_perspective | 1280×960 | 39.5% | 38.8% | 47.6% | 30.8% | 3/5 | no | 55 | 46 | missed: 19506 RICHMOND BEACH DR NW(ADDRESS), (206) 542 8591(PHONE) |
| doc-zh-boarding-confirmation-card | zh-Hans | real_bilingual_card_photo | 1280×960 | 6.7% | 6.7% | 14.3% | 80.0% | 2/3 | no | 44 | 36 | missed: 白云国际机场股份(COMPANY) |
| doc-en-ziartides-business-card | en | real_contact_card | 1023×598 | 42.9% | 42.9% | 60.6% | 72.7% | 3/5 | no | 65 | 106 | missed: 31-35 Archemou Str. Nicosia(ADDRESS), 43930(PHONE) |
| a4-en-bank-statement | en | a4_bank_statement_photo | 4284×5712 | 17.4% | 11.3% | 21.1% | 38.5% | 5/5 | no | 449 | 18 |  |
| a4-en-commercial-lease | en | a4_lease_photo_handwriting | 1840×2592 | 12.3% | 7.2% | 18.6% | 18.2% | 0/6 | no | 216 | 45 | missed: Mrs. Patti Fay MD(PERSON), 51323 Unique Village(ADDRESS), Weimann Inc(COMPANY), 84784 Godfrey Grove(ADDRESS), $9750(AMOUNT), $2317(AMOUNT) |
| a4-en-patient-information | en | a4_medical_form_photo | 5712×4284 | 13.3% | 9.1% | 24.1% | 20.8% | 4/6 | no | 276 | 11 | missed: Jessica Smith(PERSON), 1QOSXUU56G(ID) |
