# SETUP（iOS）

Docudis 的全部功能免费开放，不需要 Firebase 或额外的商店配置。

## 1. 准备工具

- macOS、Xcode 16+、Flutter 3.47+
- CocoaPods
- 真机发布时使用 Apple Developer 团队；模拟器调试不需要发布签名

先获取 Flutter 依赖和模型：

```bash
flutter pub get
tool/fetch_models.sh
```

## 2. CocoaPods

`ios/Podfile` 使用 iOS 16.0。首次构建或依赖变化后运行：

```bash
cd ios
pod install --repo-update
```

ML Kit 没有 arm64 模拟器 slice；`ios/mlkit_sim_arm64.rb` 会在 `pod install` 后生成模拟器副本。NER 模型由 Xcode 的 “Bundle NER model” 构建步骤打进应用；缺少模型时应用仍可使用规则检测。

## 3. Xcode 签名与 App Group

用 Xcode 打开 `ios/Runner.xcworkspace`：

1. Runner target → Signing & Capabilities：选择 Team，Bundle Identifier 保持 `com.stonetech.docudis`。
2. ShareExtension target：选择同一 Team，Bundle Identifier 保持 `com.stonetech.docudis.ShareExtension`。
3. 在开发者后台注册 App Group `group.com.stonetech.docudis`，并让两个 App ID 都启用 App Groups。
4. 两个 target 的 entitlements 已声明该 App Group。

首页粘贴按钮使用系统 `UIPasteControl`。其语言来自 `Info.plist` 的 `CFBundleLocalizations`，新增界面语言时要与 `lib/l10n` 同步。

## 4. 构建与验证

```bash
flutter analyze
flutter test
flutter run
flutter build ipa --release
```

真机或 TestFlight 至少验证：

- 粘贴、文件、相机、相册输入
- PDF、Word 和图片的打码文件分享
- Share Extension 与 App Group 数据传递
- “总是遮住”“从不遮住”、历史和还原
- Apple Silicon 模拟器及真机上的 OCR 与 NER
