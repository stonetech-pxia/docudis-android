# 匿名规则分类与个性化加载

规则仍按 `rules/universal.json` 和地区文件存放；文件布局负责地域加载，
`scope` 和每条规则的 `classification` 负责展示、筛选和用户配置。正则表达式、
置信度和校验器的含义不变。

## 两个互不替代的维度

- `scope.jurisdictions` / `scope.languages` 描述规则包适用于哪里、什么语言。
  国家与语言分开；法语文档不等于法国证件。
- `classification.category` / `subtype` 描述规则识别什么。
- `classification.verticals` 描述规则与哪些使用领域相关。它不能代替数据类别。

例如法国 NIR 是 `identity/social_security_number`，适用司法辖区为 `FR`，同时与
`healthcare`、`employment` 有关。它仍是基础保护，不会因为用户没有选择医疗领域
而被关闭。

## 数据结构

```json
{
  "schemaVersion": 2,
  "region": "fr",
  "scope": {
    "jurisdictions": ["FR"],
    "languages": ["fr"]
  },
  "rules": [
    {
      "id": "regex:fr:nir",
      "entityType": "SSN",
      "domains": ["identity", "medical", "hr"],
      "classification": {
        "category": "identity",
        "subtype": "social_security_number",
        "applicability": "baseline",
        "verticals": ["healthcare", "employment"],
        "protectionLevel": "essential",
        "defaultAction": "hide",
        "provenance": "doccloak",
        "status": "active"
      }
    }
  ]
}
```

`domains` 是为兼容 DocCloak 源格式保留的旧标签；新代码不得用它决定加载或 UI
分组。

## 分类字段

- `category`：唯一主分类；一条规则只能属于一类。
- `subtype`：稳定的细类，不改变匿名文本中的占位符类型。
- `applicability`：`baseline` 始终进入配置；`specialized` 只在领域匹配时进入。
- `verticals`：`healthcare`、`legal`、`finance`、`employment`、`insurance`、
  `technology`、`utilities`，可以多选。
- `protectionLevel`：`essential`、`recommended`、`optional`，供产品展示风险；不参与
  区间冲突优先级。
- `defaultAction`：`hide`、`detectOnly` 或 `contextual`。金额默认仅检测；日期根据是否
  为出生日期决定。
- `provenance`：原始 DocCloak、经 Docudis 修改或 Docudis 新增。
- `status`：有效、实验中或已弃用。

## 选择语义

`RuleSelection` 保存用户意图，而不是保存一次解析后的全部规则 ID：

1. 只加载所选司法辖区的地区包，并始终加载 `universal`。
2. 加载全部 `baseline` 规则。
3. `specialized` 规则至少有一个 `verticals` 与用户选择相交时加载。
4. 可用 `categories` 进一步限制信息类别。
5. `enabledRuleIds` 和 `disabledRuleIds` 是用户对单条规则的最终覆盖；禁用优先。

不传 `RuleSelection` 时保留旧行为，确保此次结构迁移不改变现有检测结果。

```dart
final detector = RegexDetector.bundled(
  selection: const RuleSelection(
    jurisdictions: {'FR'},
    verticals: {RuleVertical.healthcare},
  ),
);
```

配置应保存“法国 + 医疗 + 用户覆盖”等意图。新增一条法国医疗规则后，旧用户会在
下一版自动获得它；只有逐条调整才保存规则 ID。
