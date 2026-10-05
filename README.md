# Docudis

English · [中文](README.zh-CN.md)

Docudis removes personal details from your documents before you share them with an AI assistant. It is a free app for Android and iPhone, built with Flutter.

Paste text, pick a file (PDF, Word .docx, TXT, Markdown, CSV) or take a photo of a paper document. Docudis finds names, email addresses, phone numbers, ID and card numbers, IBANs, addresses and dates of birth, and replaces each one with a label such as `[PERSON_1]` or `[IBAN_1]`. Amounts and other dates stay readable, so the AI can still follow the text. Then copy the protected text, share it as a file, or send it straight to your AI app.

Every feature is free, without limits, and needs no account. Interface in English, French, Spanish and Chinese. Website: [docudis.com](https://docudis.com). The app for Windows and macOS is [docudis-desktop](https://github.com/stonetech-pxia/docudis-desktop).

## Status

Docudis for Android is in testing on Google Play, and the iPhone app is being prepared for the App Store. Store links will appear here and on [docudis.com](https://docudis.com) once they are public.

## Privacy

- Detection runs on the device: rules from [docudis-core](https://github.com/stonetech-pxia/docudis-core), a name-recognition model from [docudis-ner](https://github.com/stonetech-pxia/docudis-ner) that ships inside the app, and Google ML Kit for text recognition, language identification and entity extraction. Your documents are never uploaded, and Docudis has no server that receives them.
- Google ML Kit downloads its entity-extraction model on first use and sends Google diagnostic and usage information (device model, OS and app version, performance metrics, error codes, a per-installation identifier). It does not send your text or images.
- Your latest 100 documents are kept in the app's private storage; "Clear data on this device" on the Account tab deletes them. They are excluded from cloud backups (iCloud, Android) and, on Android, from device transfer.
- No ads, no advertising identifiers, no analytics of our own.
- Privacy policies: [Android](https://docudis.com/privacy/), [iPhone](https://docudis.com/privacy/ios/).

Automatic detection is not perfect. Read the protected copy before you share it, especially for sensitive documents. The masked text is pseudonymised, not anonymous: the table kept on your device can restore it.

## Build from source

Flutter 3.47 (Dart 3.13), Riverpod 3, ML Kit, ONNX Runtime. Bundle ID / package name: `com.stonetech.docudis`. Platform setup: [SETUP.md](SETUP.md) (Android), [SETUP_IOS.md](SETUP_IOS.md) (iOS).

```bash
flutter pub get
(cd packages/docudis_engine && flutter pub get)
(cd packages/docudis_pdf && flutter pub get)
tool/fetch_models.sh
flutter run
```

The Android build compiles docudis-core and docudis-ner (Rust) for `arm64-v8a`, `armeabi-v7a` and `x86_64`; it needs the Android NDK, the Rust Android targets and `cargo-ndk`. Both are pinned in [tool/docudis_core_version.json](tool/docudis_core_version.json) and [tool/docudis_ner_version.json](tool/docudis_ner_version.json). Android releases are App Bundles: the NER model ships as an install-time Play Asset Delivery pack.

```bash
flutter build appbundle --release
```

```bash
flutter build ipa --release
```

No Firebase, store products, API keys or `--dart-define` are needed.

```bash
flutter analyze
```

```bash
flutter test
```

The design of the anonymization is in [docs/anonymization-design.md](docs/anonymization-design.md). More developer notes, in Chinese: [README.zh-CN.md](README.zh-CN.md).

## License

[GNU AGPL-3.0](LICENSE), Copyright 2026 Pengda Xia (stonetech), with an additional permission to distribute it with Google ML Kit, the Google Play services client libraries and the ML Kit frameworks for iOS; see [NOTICE](NOTICE). Files that carry their own license header (for example the parts derived from DocCloak.Core) keep that license. Account > Open-source licenses in the app lists every third-party component.

Using Docudis unmodified inside your company puts no obligation on you under the AGPL. The obligations apply only if you distribute Docudis to others, or modify it and offer it to users over a network.

## Security and contributing

Report security problems privately: [SECURITY.md](SECURITY.md). Issues are welcome, but never put real personal data in them. This repository does not accept pull requests for now; see [CONTRIBUTING.md](CONTRIBUTING.md).
