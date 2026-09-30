# Google Play 商店页文案

2026-09-17 起草。上架语言：en-US（默认）、fr-FR、zh-CN。
字数上限：应用名 30、简短说明 80、完整说明 4000（Play 按字符计，中文一个字算 1）。改完跑一次
文末的检查命令。

写作约束（改文案时保持）：

- 不承诺"100% 识别"，完整说明里明确写"自动检测不完美，分享前请看一遍"。
- 不写"遮住日期 / 金额"：默认只遮出生日期，金额和其他日期保持可见（2026-09-18 决定，见设计文档"占位符要对下游模型说真话"）。
  截图样例里的日期和金额同样保持原文。
- 不写无条件的"完全离线"：ML Kit 语言模型由 Google Play 服务首次使用时下载。文档内容不上传这一点可以放心写。
- 不提已隐藏的功能：还原、历史、检查检测结果。系统文字选择菜单 / 快捷设置开关暂不介绍。
- 完整说明明确写出所有功能免费开放且不限次数。
- 其他 AI 应用的名称只在完整说明里作为兼容说明出现一次，不放进应用名和简短说明（Play 元数据政策）。

截图标题与 `test/store/store_screenshots.dart` 的 `_captions` 保持一致。

---

## en-US

### App name

Docudis: Anonymize for AI

### Short description

Hide names, emails, IBANs and addresses before you paste a document into AI.

### Full description

Docudis removes personal details from your documents before you share them with an AI assistant.

Paste text, upload a document or scan a photo. Docudis finds names, email addresses, phone numbers, ID and card numbers, IBANs, addresses, dates of birth and company names, and replaces each one with a label such as [PERSON_1] or [IBAN_1]. The AI can still follow the text: amounts and other dates stay readable, so it can work with totals and deadlines. The private parts stay with you.

HOW IT WORKS
• Paste text, pick a file (PDF, Word .docx, TXT, Markdown, CSV) or take a photo of a paper document
• Tap Anonymize
• Copy the protected text, share it as a file, or send it straight to your AI app

PRIVATE BY DESIGN
• Detection runs on your phone. Your documents are never uploaded, and Docudis has no server that receives them.
• No account, no sign-in, no ads.
• Your latest 100 documents are kept on this device only. Clear them at any time from the Account tab.
• On first use, Google Play services downloads an on-device language model for dates, amounts and addresses. Your text is not sent.

WHO IT'S FOR
Anyone who uses ChatGPT, Claude, Gemini or another AI assistant with other people's information: lawyers, HR teams, consultants, accountants, recruiters and support staff.

LANGUAGES
Names, organizations and addresses are recognized in English, French, Chinese and Spanish. Emails, phone numbers, IBANs and card numbers are recognized in many more languages.

GOOD TO KNOW
Automatic detection is not perfect. Read the protected copy before you share it, especially for sensitive documents.

FREE TO USE
Every feature is free without limits: pasted text, documents, photos, redacted files with their layout kept, “Always hide” and “Never hide”.

Questions or feedback: stonetechdigital@gmail.com

---

## fr-FR

### Nom de l'application

Docudis : anonymiser pour l'IA

### Description courte

Masquez noms, e-mails, IBAN et adresses avant de coller un document dans l'IA.

### Description complète

Docudis retire les données personnelles de vos documents avant que vous les partagiez avec un assistant IA.

Collez du texte, importez un document ou scannez une photo. Docudis repère les noms, adresses e-mail, numéros de téléphone, numéros d'identité et de carte, IBAN, adresses postales, dates de naissance et noms d'entreprise, et remplace chacun par une étiquette comme [PERSON_1] ou [IBAN_1]. L'IA comprend toujours le texte : les montants et les autres dates restent lisibles, pour qu'elle puisse travailler sur les totaux et les échéances. Vos données restent chez vous.

COMMENT ÇA MARCHE
• Collez du texte, choisissez un fichier (PDF, Word .docx, TXT, Markdown, CSV) ou photographiez un document papier
• Touchez Anonymiser
• Copiez le texte protégé, partagez-le en fichier ou envoyez-le directement à votre app d'IA

CONFIDENTIEL PAR CONCEPTION
• L'analyse se fait sur votre téléphone. Vos documents ne sont jamais envoyés, et Docudis n'a aucun serveur qui les reçoit.
• Pas de compte, pas de connexion, pas de publicité.
• Vos 100 derniers documents sont conservés uniquement sur cet appareil. Effacez-les à tout moment depuis l'onglet Compte.
• À la première utilisation, les services Google Play téléchargent un modèle de langue qui fonctionne sur l'appareil, pour les dates, montants et adresses. Votre texte n'est pas envoyé.

POUR QUI
Toute personne qui utilise ChatGPT, Claude, Gemini ou un autre assistant IA avec les informations d'autrui : avocats, RH, consultants, comptables, recruteurs, équipes support.

LANGUES
Les noms, organisations et adresses sont reconnus en français, anglais, chinois et espagnol. Les e-mails, téléphones, IBAN et numéros de carte sont reconnus dans bien d'autres langues.

À SAVOIR
La détection automatique n'est pas parfaite. Relisez la copie protégée avant de la partager, surtout pour les documents sensibles.

GRATUIT
Toutes les fonctionnalités sont gratuites et sans limite : textes, documents, photos, fichiers caviardés avec leur mise en page, « Toujours masquer » et « Ne jamais masquer ».

Questions ou remarques : stonetechdigital@gmail.com

---

## zh-CN

### 应用名称

Docudis：发给 AI 前先匿名

### 简短说明

把文档交给 AI 之前，自动遮住姓名、邮箱、电话、银行账号和地址。

### 完整说明

Docudis 在你把文档交给 AI 助手之前，先把里面的个人信息遮住。

粘贴文字、上传文档或拍一张照片。Docudis 会找出姓名、邮箱、电话、证件号和卡号、IBAN、地址、出生日期和公司名称，逐个替换成 [PERSON_1]、[IBAN_1] 这样的标签。金额和其他日期保持原样，AI 照样能算总额、看期限，隐私留在你自己手里。

怎么用
• 粘贴文字，选择文件（PDF、Word .docx、TXT、Markdown、CSV），或拍下纸质文件
• 点"匿名化"
• 复制处理后的文字、作为文件分享，或一键发送到常用的 AI 应用

隐私从设计开始
• 识别在手机上完成。文档不会上传，Docudis 也没有接收文档的服务器。
• 不用注册，不用登录，没有广告。
• 最近 100 份文档只保存在本机，随时可以在"账户"页一键清除。
• 首次使用时，Google Play 服务会下载一个在本机运行的语言模型，用来识别日期、金额和地址。你的文字不会被发送。

适合谁
经常把他人资料交给 ChatGPT、Claude、Gemini 等 AI 助手处理的人：律师、HR、顾问、会计、招聘和客服。

语言
姓名、机构和地址支持中文、英文、法文和西班牙文；邮箱、电话、IBAN 和卡号在更多语言里都能识别。

请注意
自动识别不能保证万无一失。分享之前请把处理后的内容看一遍，敏感文件尤其如此。

完全免费
所有功能全部免费、不限次数：粘贴文字、上传文档、拍照、分享保留版面的打码文件、「总是遮住」和「从不遮住」。

问题与反馈：stonetechdigital@gmail.com

---

## 截图顺序与标题

| # | 文件 | en | fr | zh |
|---|---|---|---|---|
| 1 | `1-result.png` | Remove personal details before you ask AI | Masquez vos données avant de parler à l'IA | 问 AI 之前，先把个人信息遮住 |
| 2 | `2-paste.png` | Paste text, upload a document or scan a photo | Collez, importez ou scannez | 粘贴文字、上传文档或拍照 |
| 3 | `3-send.png` | Send it straight to your AI app | Envoyez-le directement à votre app d'IA | 一键发送到常用的 AI 应用 |
| 4 | `4-home.png` | Everything happens on your phone | Tout se passe sur votre téléphone | 全部在手机上完成 |

上传文件在 `design/store/play/<语言>/`：四张截图、`feature-graphic.png`（1024×500），图标 `design/store/play/icon-512.png`。
重新生成：

```bash
flutter test --update-goldens test/store
```

`$PYTHON` 指向装了 Pillow 的 Python：

```bash
"$PYTHON" design/store/export_play_assets.py
```

字数检查：

```bash
"$PYTHON" docs/store/check_listing.py
```
