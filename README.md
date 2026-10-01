# Docudis

Docudis 是完全免费的 Flutter 应用，在 Android 和 iOS 设备上本地识别并匿名化文本、PDF、Word 文档和图片。所有功能对所有用户开放。

- Bundle ID / 包名：`com.stonetech.docudis`
- 技术栈：Flutter 3.47 / Dart 3.13、Riverpod 3、ML Kit、ONNX Runtime
- 界面语言：English、Español、Français、中文（默认跟随系统）
- 隐私：文档处理在设备上完成，不上传原文

Android 配置见 [SETUP.md](SETUP.md)，iOS 配置见 [SETUP_IOS.md](SETUP_IOS.md)。

## 目录结构

```text
lib/
  main.dart              加载本机偏好并启动应用
  app.dart               MaterialApp、主题和本地化
  preferences.dart       SharedPreferences provider
  home/                  首页、账户设置和自定义词典
  anonymize/             输入、OCR、模型、存储、还原和分享
  l10n/                  四种语言的 ARB 与生成代码
packages/
  docudis_engine/        迁移期 Dart 参考引擎与 Core 数据快照
  docudis_pdf/           PDF 处理
tool/
  docudis_core_version.json  固定的 Core revision、ABI 与数据摘要
  prepare_docudis_core.sh   Gradle 调用的 Android native 构建入口
```

匿名化设计见 [docs/anonymization-design.md](docs/anonymization-design.md)，模型获取方式见 [assets/models/README.md](assets/models/README.md)，基准测试位于 `benchmark/`。
Rust Core 位于独立的
[`docudis-core`](https://github.com/stonetech-pxia/docudis-core) 仓库。
`packages/docudis_engine` 在差分迁移期仍是参考实现；其中规则与名单只是固定
Core revision 的生成快照，不能在本仓库独立编辑。运行
`DOCUDIS_CORE_SOURCE=/path/to/docudis-core ./tool/verify_core_snapshot.sh`
可检查 revision、摘要和漂移。

## 运行

```bash
flutter pub get
(cd packages/docudis_engine && flutter pub get)
(cd packages/docudis_pdf && flutter pub get)
python3 tool/fetch_models.py
flutter run
```

`flutter analyze` 也会分析 `packages/*`，因此全新 clone 需要先解析这两个包的依赖。

Android Gradle 构建会自动为 `arm64-v8a`、`armeabi-v7a` 与 `x86_64`
准备 `libdocudis_capi.so`，需要 Android NDK、Rust Android targets 和
`cargo-ndk`。开发中的本地 Core checkout 可以通过 `DOCUDIS_CORE_SOURCE`
指定，但其 HEAD 必须等于 `tool/docudis_core_version.json` 的固定 revision。

Rust 差分路径默认关闭。真机/模拟器验证时通过
`--dart-define=DOCUDIS_RUST_DIFFERENTIAL=true` 打开；任何加载错误、ABI
不兼容、调用异常或结果差异都会返回 Dart 结果，诊断不记录原文、检测值或映射。

Android 发布必须使用 App Bundle。NER 模型通过 Play Asset Delivery 的 install-time asset pack 交付；普通 release APK 不包含模型。Debug 构建会把模型同步到普通 assets。

```bash
flutter build appbundle --release
flutter build ipa --release
```

应用不需要 Firebase、商店商品、API 密钥或 `--dart-define`。

## 检查与测试

```bash
flutter analyze
flutter test
```

修改 `lib/l10n/*.arb` 后运行：

```bash
flutter gen-l10n
```

## 本机配置

发布签名等机器专属文件不要提交：

- `android/key.properties`
- Android release keystore
- Xcode 自动签名产生的本机配置
- `assets/models/**/*.onnx` 和 tokenizer 文件（由模型脚本下载）
