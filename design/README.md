# Docudis 设计稿

- 在线画布（可编辑 / 导出 PNG、PDF）：https://claude.ai/artifact/JA2XU28pDbdoCzdQHZB7rX
- 选定方向：**F · Clay**（`mockups/DirectionClay.dc.html`）
- `mockups/` 里是画布的源文件：每个 `*.dc.html` 是一个画板，`canvas.json` 是布局。

## Clay 设计 token

| 用途 | 值 |
| --- | --- |
| 页面背景（沙色） | `#F5EFE8` |
| 卡片表面（奶油） | `#FFFCF8` |
| 主色（陶土橙） | `#C8623A`，按下 `#A84E2C` |
| 次色（鼠尾草绿） | `#6B7F62`，浅底 `#E3E9DC` / 文字 `#4E6644` |
| 第三色（棕褐） | `#B8926A` |
| 正文 | `#2A2420`，弱化 `#6B5F55`，说明 `#8A7B6F`，占位 `#A89A8E` |
| 分割线 | `#E8DFD4` |
| 标题字体 | Sora 600 / 700 |
| 正文字体 | Karla 400 / 500 / 700 |
| 卡片圆角 | 22px；图标块 `16px 16px 16px 6px` |
| 阴影 | `0 10px 30px rgba(120, 90, 60, 0.10)` |
| 主按钮 | 高 52px，最小点击区 44px |

页面第一行的 Home / Review / Result / Restore / Style sheet 仍是早期 Harbor 风格，等修改意见确定后统一换成 Clay。

## 实现

- 主题与 token：`lib/theme/clay_theme.dart`（颜色、字体、实体高亮色、`ThemeData`）；通用组件：`lib/theme/clay_widgets.dart`。
- 字体文件在 `assets/fonts/`（Sora、Karla 的可变字体，OFL 许可证同目录）。两款都是可变字体，
  文字样式必须同时设置 `fontWeight` 和 `fontVariations`，`Clay.heading()` / `Clay.body()` 已封装。
- 每个页面的渲染截图由 `test/clay_screens_test.dart` 生成到 `test/goldens/`（`flutter test --update-goldens test/clay_screens_test.dart`）。
  测试环境没有系统等宽字体，截图里 `[PERSON_1]` 之类的占位符显示为色块，真机上正常。
- 2026-09-23 起截图基准（含 `test/goldens/store/` 和导出的 `design/store/play/`）在 macOS 上生成，以 Mac 为准；
  Windows 上字体光栅化不同，会差 1–3%。中文商店截图需要 `NOTO_SANS_SC` 指向 Google Fonts 的
  `NotoSansSC[wght].ttf`，没有时这几张测试会被跳过。
