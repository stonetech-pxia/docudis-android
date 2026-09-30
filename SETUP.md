# SETUP（Android）

Docudis 的全部功能免费开放，不需要 Firebase、计费后台、商店商品或运行时 API 密钥。

## 1. 准备工具

- Flutter 3.47+；`flutter doctor` 中 Flutter 与 Android toolchain 无红叉
- Android Studio 和 Android SDK
- 真机或 Android 模拟器
- Python 3（用于模型下载脚本）

接受 Android SDK 许可：

```bash
flutter doctor --android-licenses
```

## 2. 获取依赖与模型

```bash
flutter pub get
python3 tool/fetch_models.py
```

模型文件不提交到 Git。具体文件和下载源见 [assets/models/README.md](assets/models/README.md)。

## 3. 本机调试

```bash
flutter run
```

Debug 构建会把 NER 模型同步进普通 assets，因此可直接安装到真机或模拟器。

## 4. 发布签名

创建 release keystore，并在 `android/key.properties` 中填写：

```properties
storeFile=/absolute/path/to/docudis-upload.jks
storePassword=...
keyAlias=...
keyPassword=...
```

`android/key.properties` 与 keystore 都只保存在安全位置，不提交到仓库。没有该文件时，项目会回退到 debug 签名，便于本机验证，但不能用于商店发布。

## 5. 构建与验证

```bash
flutter analyze
flutter test
flutter build appbundle --release
```

发布必须使用 App Bundle：NER 模型通过 `android/model_pack` 作为 install-time asset pack 交付，普通 release APK 不包含模型。

上传到 Play Console 的测试轨道后，至少验证：

- 粘贴文本、文档、图片和拍照输入
- PDF、Word 和图片的打码文件可以直接分享
- “总是遮住”“从不遮住”和历史记录可用
- 清除本机数据、系统分享入口和 PROCESS_TEXT 菜单正常
