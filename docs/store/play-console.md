# Play Console 上架操作单

Docudis 作为免费工具发布，所有功能无需账户即可使用。

## 1. 托管隐私政策

将 `docs/store/privacy-policy/index.html` 发布到公开且稳定的网址，例如 `https://stonetech-pxia.github.io/docudis-site/privacy/`，然后在 Play Console → 政策和计划 → 应用内容 → 隐私政策中填写该网址。

## 2. 应用内容问卷

| 项目 | 答案 |
| --- | --- |
| 广告 | 不含广告 |
| 应用访问权限 | 所有功能无需登录或特殊访问权限 |
| 内容分级 | 实用工具；暴力、性、毒品、赌博、用户互动和位置分享均为否 |
| 目标受众 | 18 岁及以上；不会无意中吸引儿童 |
| 新闻、政府、金融、健康应用 | 否 |
| 数据安全 | 见下一节 |

## 3. 数据安全表

文档、照片和识别出的个人信息只在本机处理，不属于 Play 定义的“收集”。当前需要申报的 SDK 数据：

| 数据类型 | 收集 | 分享 | 用途 | 来源 |
| --- | --- | --- | --- | --- |
| 设备或其他 ID | 是 | 否 | 分析、应用功能 | ML Kit 的按安装标识 |
| 应用信息和性能 → 诊断 | 是 | 否 | 分析 | ML Kit 的设备、系统、性能、输入大小和错误信息 |

- 传输加密：是。
- 数据删除请求：通过 `stonetechdigital@gmail.com`；应用内文档可在账户页直接清除。
- 崩溃日志：当前未接入 Crashlytics；以后加入时同步更新隐私政策和数据安全表。

## 4. 封闭测试

1. 测试 → 封闭测试 → 创建轨道。
2. 添加满足 Play 要求的测试者，上传 release AAB 并提交审核。
3. 测试者通过参与链接加入并从 Play 安装。
4. 按 `docs/mvp-launch-checklist.md` 完成真机回归并记录反馈。
5. 达到 Play 要求的测试时长后申请正式版访问权限。

## 5. 商店页

- 应用名、简短说明和完整说明从 `listing.md` 复制。
- 图标：`design/store/play/icon-512.png`。
- 置顶大图和截图：`design/store/play/<语言>/`。
- 应用类别：工具；联系邮箱：`stonetechdigital@gmail.com`。
- 发布前运行 `docs/store/check_listing.py` 检查字数，并确认隐私政策与当前依赖一致。
