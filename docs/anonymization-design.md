# Docudis 匿名化功能 · 设计决策

记录 2026-09-16 与产品负责人逐项确认的设计决策。功能实现以本文为准；设计稿（`design/`）与本文冲突处，以本文为准。

参考实现：[DocCloak](https://github.com/WLojek/DocCloak)（网页壳，AGPL-3.0，不引用代码）与
[DocCloak.Core](https://github.com/WLojek/DocCloak.Core)（引擎，Apache-2.0，移植其正则规则包并在 NOTICE 署名）。

## 定位

- 全程本地运行，无云端依赖，敏感数据不上传。
- 输入三种来源：粘贴文本、文件、手机拍照。
- 无论输入是什么，**输出只有纯文本**（`.txt`）。设计稿上传入口的 "formatting kept" 作废。
- 每次处理结果在 app 内备份，形成历史记录，可再次分享。保留最近 100 条。
  粘贴文本和照片以原文第一行命名（文件仍用文件名），每条可改名、单独删除；日期按手机地区的写法（英国手机 24/09/2026）。

## 输入与提取

| 来源 | v1 支持 | 提取方式 |
|---|---|---|
| 粘贴文本 | 是 | 直接使用 |
| txt / md / csv | 是 | 读文件 |
| 文字型 PDF | 是 | `pdfrx`（先验证文本提取；不可用则换 `syncfusion_flutter_pdf`） |
| docx | 是 | `archive` + `xml` 纯 Dart 解析 |
| jpg / png / heic 图片、拍照 | 是 | Google ML Kit 文字识别（端侧） |
| 扫描型 PDF | 是 | 逐页判断：有文字层直接取；没有的页用 `pdfrx` 渲染成 200 dpi 位图后走同一套 ML Kit OCR。同一份 PDF 可混合两种页 |
| doc / xlsx / pptx | 否 | 明确报"不支持" |

文件与相机用 `file_picker` + `image_picker`。

**系统文字选择菜单入口（2026-09-17）**：在任意 app 里选中文字，选择菜单出现"匿名化"，**绕过审查页，直接作用于选中的文字**：
可编辑的选区（输入框）原地替换成匿名化结果；只读选区（网页正文等）把结果复制到剪贴板。记录照常进历史，AI 回复仍可还原。
- Android：`ProcessTextActivity`（半透明，`ACTION_PROCESS_TEXT`，显示"匿名化中…"小卡片）通过 `ProcessText.kt` 调用 Dart：
  app 在运行就用 app 自己的引擎（`processTextProvider`），否则起一个无界面引擎跑 `processTextMain`（`lib/main.dart`）。
  无界面引擎处理完保留以便下次直接用（模型不必重载），app 一启动就销毁，避免两份模型同时在内存里。
  `EXTRA_PROCESS_TEXT_READONLY` 为 false 时用 `setResult` 把结果交回调用方（系统替换选区），为 true 时写剪贴板。
- **限制（2026-09-17 实测）**：Android 11 起，选择菜单里的第三方条目由**输入框所在的 app** 查询，
  该 app 必须在清单里声明 `PROCESS_TEXT` 查询或持有 `QUERY_ALL_PACKAGES`，否则一个第三方条目都不显示（ChatGPT / Claude 也一样），Docudis 这边无法改变。
  测试机上：Chrome、三星浏览器、三星笔记、Outlook 能看到"匿名化"（在 ⋮ 溢出菜单里）；**微信、WhatsApp、Telegram、Gmail、Google 信息看不到**。
  "匿名化"也**无法放到选择工具栏的第一排**：框架 `Editor` 把所有 `PROCESS_TEXT` 条目固定设为 `SHOW_AS_ACTION_NEVER`（只进 ⋮ 溢出菜单），
  非特权 app 的 intent-filter `priority` 会被系统压到 0，也无法靠前排序。第一排只有宿主 app 自己加的项（如 Chrome 的"问问 Gemini"）。
- **快捷设置开关"匿名化剪贴板"（2026-09-17）**：覆盖上述看不到菜单的 app。流程：复制 → 下拉快捷设置点开关 → 粘贴。
  `AnonymizeClipboardTileService` 启动同一个 `ProcessTextActivity`（`ACTION_CLIPBOARD`），等窗口拿到焦点后读剪贴板（Android 10+ 只允许前台 app 读），
  匿名化后写回剪贴板，同样不经审查、记录进历史。开关需要用户在快捷设置面板里手动添加一次。
- iOS：系统选择菜单不对第三方开放，对应做法是 Share Extension（选中文字 → 分享 → Docudis）。需要在 Xcode 里新增扩展 target（本机无 macOS，尚未做）。

OCR 脚本选择：默认跑**中文识别器**（同时识别汉字与拉丁字母）；系统语言为印地语时跑天城文识别器。
2026-09-17 在真机上按英法用例对比过拉丁识别器（`docs/benchmark/ocr-recognizer-comparison.md`）：13 个拉丁字母用例里
12 个输出完全相同，法文低对比度收据上拉丁识别器把"品名 + 金额"拆成两列、断开 `4,20 €`，CER 从 5.8% 涨到 29.8%，
关键信息召回从 4/4 掉到 3/4。**结论：主要用户为英法语后仍保持中文识别器为默认**，不做"拉丁 + 中文双跑取多者"。

中文识别器的误读（2026-09-26）：拉丁字母页面上，它会把一列短词读成一条竖排汉字行（银行对账单的股票代码列读成"里E里恩目星"），
模型把这行当成人名，整列被一个黑框盖住，这些汉字还会打开中文规则包。`ImageLayout.read` 先丢掉这种行：汉字不到全页字母 5% 时，
高度超过全页行高中位数 3 倍、同一个词里汉字和拉丁字母混排、或整行只有一个汉字加标点（徽标虚线读成的 ".的 ."）的汉字行不进入文本。正常高度的汉字行（英文信里的"王伟"）
和中文页面上的竖排行照常保留。

OCR 阅读顺序（2026-09-23 起）：不用 ML Kit 的 `result.text`（按块输出，表格一列一块，右对齐的日期排到很后面），
改由 `ImageLayout.read` 按行排：先按行的长度加权中位数斜率把页面转正，纵向重叠 ≥ 较矮一行高度一半的行归为一排，
排内从左到右用制表符连接，排与排用换行；文字和"字符区间 → 图上方框"在同一遍里生成，偏移天然对齐。扫描 PDF 页同样走这里。
真机 15 例（`docs/benchmark/ocr-device-page-order.md`，对照 `ocr-device.md`）：归一化 CER 53.3% → 10.3%，
三张 A4 分别 84.7 → 11.3、39.5 → 7.2、61.4 → 9.1；关键信息召回不变（73.2%）。把两种顺序的 OCR 文本跑检测引擎对比：
71 个关键项漏检 37 → 36，一处类型变错（名片上的人名标成 COMPANY，仍遮住）。
**代价**：左右并排的两栏（名片的姓名栏 / 地址栏）会被逐排交错，两张名片 CER 变差（7.4 → 42.9、22.5 → 38.8）；
信头"左地址、右日期"时日期会并进地址某一行，repair 的地址块补行规则按整行算地址占比，可能因此不补。
几何上两栏和表格分不开，暂不加启发式，等真实照片测试集再量。对比 ML Kit 原顺序：`--dart-define=OCR_ORDER=mlkit`。
同日真机实测三份上传图片后，`RegexDetector` 加了两条（仍不改 OCR 文本）：
- **o 当 0**：只含数字和 o/O、且至少一个数字的词（`o113`、`o6`）在一份等长副本里把 o/O 换成 0，规则在副本上匹配，
  偏移不变，检出值取原文。Georgia 这类旧式数字字体里 ML Kit 把 0 读成 o，电话整段露出。普通单词不受影响。
- **匹配不跨制表符**：制表符是格与格的分界（照片的栏、docx / 表格）。匹配本身含制表符就丢弃，有制表符的文本
  再用"制表符换成任何规则都不当空白的字符"的副本匹配一次，找回格内的那段（`27 rue des Tanneurs`）。标签在前一格
  不受影响，它在匹配之外（`BIC⇥BNPAFRPPXXX`）。

## 检测引擎

独立纯 Dart 包 `packages/docudis_engine`（无 Flutter 依赖，`dart test` 运行），`Detector` 接口可插拔。五路检测：

1. **词典**：全局自定义关键词，对所有文档生效，置信度 1.0。匹配忽略大小写和拉丁重音（词典里的 "Émilie" 能命中扫描件里的
   "EMILIE"），拉丁文按整词匹配（"Li" 不会命中 "delivery"），含汉字的词不设边界；词条里的空格匹配任意空白，换行处也能命中。
   词典一开始是空的，从"最近手动遮住的文字"里一键加入（2026-09-18）；2026-09-24 起词典页顶部也能直接输入（自己的姓名、
   公司、地址、IBAN 录一次）：真实用户测试里反复使用的人要的正是这个，而他的公司名本来就会被自动认出，永远进不了推荐。
   输入和推荐都直接加入词典。
   **"从不遮住"名单**（2026-09-24，引擎 `NeverHide`，存 `never_hide.json`，同样排除在备份外、不随清除数据删掉）：
   名单里的词像词典一样先在原文里找出位置（忽略大小写和拉丁重音，拉丁文按整词，词条里的空格对得上换行），整个落在这些位置里的
   检测（首尾空白和标点不算）一律丢掉，不管是哪个检测器找到的：信头上分两行写的 "Leeds" / "CITY COUNCIL" 和整个名称一样放过。
   第一版只比较整个检测值，在手机上没起作用，因为检测器认出来的正是这些碎片。
   用户自己的选择优先，词典项和手动遮住的不受影响；伸出这个位置的区间照样整段遮住（宁可多遮）；名单在裁决重叠之前过滤、
   在传播时也跳过，所以去掉一项不会让别的区间本该遮住的字露出来。只作用于之后的新处理。起因：真实用户测试里"Leeds City Council"
   被当成地址、连账单标题一起遮掉，Claude 看不出是市政税账单。推荐来自"最近手动恢复显示的"：
   记录里被用户点回原文的检测项（不算默认可见的金额和日期，也不算词典项和手动项）。
   推荐列表不另存，直接从本机保留的记录里读
   `source: manual` 且仍启用的检测项，按文档从新到旧去重，最多 100 条；太短的（拉丁文少于 3 个字符、汉字少于 2 个）不推荐；
   账户页只有一行"总是遮住"（几个词 · 几条推荐），点开词典页：词典条目、几条推荐（在越多文档里手动遮过的越靠前）和"所有"。
   词典存在 `<app support>/dictionary.json`，和记录一样排除在 Android 备份之外（SharedPreferences 会被备份，所以不用它）；
   "清除本机数据"不清词典，在词典页上逐条移除。
   账户页用同形状的卡片展示“总是遮住”“从不遮住”、语言和本机数据设置。
   **"只遮住这个列表"**（2026-09-24，用户决定：给想自己控制的人）：词典页上的开关，默认关，列表为空时锁住。打开后一次处理
   只跑词典这一路（`DetectionPipeline([DictionaryDetector(terms)])`），不跑模型、规则和 ML Kit，所以"从不遮住"也用不上；
   开关在 SharedPreferences（`list_only`），`AnonymizeService.process` 每次读，列表为空时照常全量检测，App 和系统文字选择菜单
   都走这里。记录带 `listOnly`，结果页据此常驻一条警示（审阅页修改后保留）；打开前弹窗讲清后果：只比对大小写和重音，写法不同
   就漏（列表里的 "Jean Dupont" 遮不住 "Mr Dupont"），别人的姓名、账号、档案号、出生日期都留在原文里。去掉最后一个词会关掉它；
   往空列表加第一个词时也先关掉（Android 备份会恢复开关却不恢复列表），免得它不经确认又开起来。
2. **规则**：移植 DocCloak.Core 的 `rules/universal.json` + 全部 19 个地区包（含 `cn.json`），保留其声明式格式
   （id、entityType、pattern、confidence、validate、examples、falsePositiveNotes）。全部打包，**按文本语言启用**：
   universal 总是开；其余地区包由 ML Kit 语言识别的结果决定（en → us/gb/ie，fr → fr/be/ch，es → es，de → de/at/ch…）；
   cn 在识别出中文、或文本含汉字且未识别为日文时开启（2026-09-17 修订，原为"主市场"总是开：主要用户改为英法语后，
   cn 的"6 位数字 = 邮编"规则会把英法文本里的发票号、订单号、数量标成地址；混合文本里语言识别常只报主语言，所以用汉字兜底），
   识别不出语言时退回 us/gb/fr/es。基准测试证明全开会让奥地利/瑞士的"4 位邮编+城市"和葡萄牙的 "R. 街道" 规则在英文正文里大量误报。
   **规则分类与个性化加载（2026-09-30）**：地区包增加独立的司法辖区和语言 `scope`；每条规则增加唯一主分类、细类、
   基础/专业范围、行业标签、保护级别、默认动作、来源和状态。基础规则跨行业保留，专业规则按医疗、法律、金融、就业、保险、
   技术或公用事业配置加载；用户可再按类别和规则 ID 覆盖。不传配置时继续加载原有完整规则集，不改变检测行为。结构和选择语义见
   [rule-classification.md](rule-classification.md)。
   Docudis 自己追加的规则以 "(Docudis addition)" 标注（目前：cn 的 年/月/日 日期）。
   **两条 universal 规则按英法市场改过（2026-09-17）**：
   - `postal_city` 原为"2-5 位数字 + 2-4 位数字 + 任意单词"，会把 `482913 for`、`350000 units`、`125000 unités`、
     `2024 en` 标成地址。改为要求城市名首字母大写、数字像邮编（5 位、`00-000`、`0000-000`、`000 00`）；
     只有 4 位的邮编（奥地利、瑞士、比利时、丹麦、挪威）交给各自地区包，因为英法正文里"年份 + 单词"太常见。
   - `currency_symbol_suffix` 的后置符号表加上 `€` 和 `£`：法语、德语、西班牙语把金额写成 `12 450,00 €`，
     原表只有 zł / kr / Kč 之类，欧元区最常见的写法反而漏检。
   两项改动后基准测试总体 F1 91% → 94%（精确率 91% → 96%，召回不降），法语 82% → 94%，中文不变。
   **单据编号（2026-09-17 决定）**：工单号、发票号这类编号应该遮住。`universal:labeled_id`（"Ref: 987654" 形式）
   只匹配带 `#` 或 `:` 的编号，所以英文 `ticket #845210` 会遮住，法文 `ticket 845210`、`Facture n° 202603` 检不出。
   用户决定暂不扩规则（放宽会把数量、年份也吃进去），基准数据里把法文那处记为**漏检**，缺口保持可见。
   **2026-09-18 按基准测试补规则**（桌面 XLM-R 总体 F1 90% → 95%，精确率 91% → 98%，召回 89% → 93%，速度不变；同日再补上基准数据的三处漏标
   `NW1 6XE`、`12 High Street`、`9月3日`，并给 `multi` 压力用例加上 fr/es 语言标签后：F1 98%，精确率 99%，召回 97%）：
   - `be:postal` / `ch:postal-city`（fr 文本会带上）要求城市名首字母大写：原来 "née le 3 avril 1987 à Bordeaux" 里的
     "1987 à Bordeaux" 被当成 4 位邮编 + 城市，且比日期长而压过 `date_word`。
   - `gb:phone_landline` 扩成常见分组写法（0161 276 1234、020 7946 0958），原来只认 5+6 位，这类号码落到 `long_number` 变成 ID。
   - 新增 `universal:currency_code_prefix`（"NZD 4.2 million"、"USD 1,250.50"，带 million/billion/k 等量词）、
     `fr:date_words`（含 "1er"）、`es:date_words`（"20 de mayo de 2024"）、`universal:institution_en`
     （Hospital / Infirmary / University / Institute 等结尾的机构名，模型把 "Manchester Royal Infirmary" 标成地点）。
   - **职务否决词表** `lib/src/rules/title_stoplist.dart`：模型区间若整个就是职务、称谓、部门名或标识符标签
     （Chair、CFO、Head of Operations、Madame、法务部、总部、NHS、SSN…）直接丢弃，人名拆词传播时也跳过这些词。
     起因是压力用例里一个被标成 PERSON 的 "Chair" 经传播复制了 122 次，误报的一半来自这条链。词典和手动区间不受影响。
     2026-09-24 加入法 / 西证件标签（SIRET、SIREN、URSSAF、NAF、NIR、IBAN、BIC、DNI、NIE、NUSS…）和西语职称 MIR：
     送进模型前全大写词改成首字母大写，"SIRET" 变成 "Siret"，模型当成地名或公司名遮掉，后面的号码就没了含义。
   - **名称类规则不再跨行**（49 条公司、街道、邮编+城市、大写金额规则，全部地区包）：字符类里的空白改为空格、制表符、不换行空格。
     OCR 输出每个字段一行，`us:company` 原来会从 "Rob ert Johnson" 一路吃到下一行的 "Acme Corp"，还以高置信度压过模型。
     改后 OCR 用例 67% → 89%，英文误报归零。电话、IBAN、长数字和私钥块规则不动（前者不会跨行，后者必须跨行）。
     OCR 的空格归一化和小写人名暂不处理（用户 2026-09-18 决定，等真机 OCR 输出再看）。
   - **真机 OCR 输出暴露的两处漏检（2026-09-19，S26 Ultra 上用西班牙语信件图片实测）**：不改 OCR 文本，只放宽规则，
     这样字符偏移不变，图片黑条和还原都不受影响。
     - `universal:email` 的 `@` 两侧各允许一个空格：ML Kit 把页眉里的邮箱读成 "citas@ sonrisasur-ejemplo.es"，整条邮箱原样露出。
       代价是手打的 "écrivez-moi @ exemple.fr" 会连前一个词一起遮住，属于过度遮盖。
     - `es:phone` 增加座机写法 3-2-2-2（954 21 07 63）和 2-3-2-2（91 234 56 78）。原来只认 3-3-3，座机落到 `long_number`，
       而 `long_number` 不跨行，正文里折行的 "954 21\n07 65" 就完全漏掉。`es:phone` 本来就用 `\s`，加了分组后折行也能接上。
     - `fr:phone` 的空格写法允许折到下一行（"06 12 34\n56 78"）；带点、带连字符和不带分隔符的写法仍然不跨行，
       否则 "01.02.20\n12.30"（日期 + 下一行的时间）会变成电话。英语区（us / gb / ie）的电话规则一直用 `\s`，本来就能跨行。
     - 没动的：`long_number` 仍不跨行（表格里上下相邻的两列数字会并成一个号码）；OCR 断词（"Rob ert"）、
       粘词（"laCuenta"）、邮箱点号后的空格暂未见到实例，不处理。
     - 顺带发现、未修：`long_number` 末尾的 `(?![.\d])` 会在句号前截短号码，"… 954 21 07 65." 只遮到 "954 21 07"，最后一组露出。
   - **`cn:address` 收紧**：原来前缀和尾部都是无界的汉字串，"陳大文先生將於臺北市信義區" 整句、
     "杭州市余杭区文一西路969号阿里巴巴西溪园区三号楼会议室" 整段都成了一个地址。现在前缀限 2 到 4 个汉字 + 省/市，
     区级字符类加上繁体 區/縣，尾部止于门牌号（可带 栋/室）或路/街/大道等词。正文里城市前最多带进两个字
     （"前往上海市…"），加"前面不能是汉字"的断言试过，会让正文里的地址完全匹配不到，不如带两个字。
     `cn:company` 有同样的前缀问题（"以及来自宁波恒远塑业有限公司"），公司名长度没规律，暂不动。
   仍然故意留着的缺口：`ticket 845210`（见上）；`cn:company` 会把公司名前面的"以及来自"一起吃进去。剩下的错误都是模型本身的：
   小写人名、OCR 断词、阿里巴巴 / El Corte Inglés / टाटा समूह 漏检、Russell McVeagh 标成人名，规则救不了。
   校验器：IBAN mod-97、Luhn、身份证校验码等。校验失败的命中直接丢掉；带字母的证件号（DNI、NIE、NINO）因此一错就整个露出，
   `long_number` 接不住（数字后面没有单词边界）。2026-09-23 补 `universal:named_national_id`：标签（DNI / NIE / NIF / CIF /
   NIR / NINO / SSN / CUPS / NHS number / National Insurance / Social Security / sécurité sociale）后面的值不管过不过校验都遮，
   报 `NUMBER`，置信度 0.88：压过同一串数字上的宽松电话规则（0.85，"NHS number 485 777 3456" 曾被 `us:phone` 标成电话），
   低于具体证件规则（0.9），所以过了校验的 DNI 仍是 `ID`，NIE 平手时保留 `ID`。CIF（公司税号，`es:cif` 只有 0.8）
改报 `NUMBER`：它不是个人证件，而且带连字符的 `B-97684512` 只有靠标签才认得出（回归集因此多遮 2 处）。
   标签可以在上一行末尾、值在下一行开头（照片里 "indicando su DNI" / "30567812W" 换了行）。没有标签、校验又错的 DNI 仍然漏，这是有意的：
   "20250101 y" 这种串不该被遮。同日加 `es:cups`（电费 / 燃气单上的供电点编码，ES + 16 位 + 两个校验字母，指向一户地址），
   带校验器，报 `NUMBER`。
3. **NER 模型**：`assets/models/xlmr_ner_docudis`，是 `Davlan/xlm-roberta-base-ner-hrl` 在自建英/法/西语料上的
   全量微调（2026-09-21 起用，量化 ONNX 约 278 MB，训练与导出见 docudis-ner 的 `training/README.md`）。
   覆盖中/英/法/西等 10 种语言并对印地语零样本可用，标签 PER / ORG / LOC / DATE，许可 AFL-3.0。
   微调前的原模型留在 `assets/models/xlmr_ner_hrl` 做对照。
   推理用 `flutter_onnxruntime`（CPU EP），分词用 `dart_sentencepiece_tokenizer`（读 HF `tokenizer.json`）。
   备选 distilbert（135 MB，快一倍，英/印地弱）保留在 `assets/models/distilbert_ner_hrl`，不打包。
   **模型必须可整体替换**：由描述文件定义（ONNX 路径、分词器类型 wordpiece/sentencepiece、词表、标签表、最大长度），
   换模型只换文件不改代码；同时接入 `dart_sentencepiece_tokenizer` 以便换入 XLM-R 类模型。
   **token 偏移由我们自己重算**（2026-09-24，`SentencePieceNerTokenizer.realign`）：该包 1.4.1 把规范化后的文本逐字对回原文，
   遇到被规范化改掉的字符（"º" → "o"、"½" → "1⁄2"、PDF 文本里的 "\r\n"）就再也对不上，之后每个 token 往前错一格。
   西语出院小结里错了 394 个字符：医生名字的标签落到 "Suspender enalapril 10…" 上，医嘱被整句遮掉，四个医护姓名漏检，
   错位的 "desayuno""días" 又被当成名字的一部分全文传播。现在按顺序在原文里找每个 token 的原样文字；
   找不到的（规范化改过的）铺在前后两个找到的 token 之间。
4. **ML Kit Entity Extraction**：补地址 / 日期 / 金额等。端侧运行，文本不上传；语言包由 Google Play 服务首次下载，
   未就绪时静默跳过。跨行的注释不要（2026-09-23）：ML Kit 把全文当一串读，工资单上 "4941A / URSSAF Midi-Pyrénées /
   Salarié" 被整块认成地址，连下一节的标题一起遮掉；真正的多行地址由规则逐行认。它把几乎任何数字串都叫电话（工号、病人号、
   SIRET，连带字母的 DNI "30567812W" 也算），所以不带 `+`、括号的 PHONE 一律改报 `NUMBER`，同 `RegexDetector.typeFor`；已知格式的电话由电话规则认，
   规则优先级更高。像法条引用的"地址"不要（2026-09-24）："Housing Act 1988, Section 19A"、"article L. 1232-2"、
   "loi n° 89-462"、"Ley 29/1994"；以法律命名的街道（"Rue de la Loi 16"）没有法律编号，照旧算地址。
   ML Kit 不在任何桌面基准里，这几条只能在真机上看（前两条 2026-09-23 真机验证过）。
5. **内置名单**（2026-09-18）：`BundledListDetector`，随包携带的知名公司名和中国地名，补模型对无后缀专有名词的漏检
   （阿里巴巴、El Corte Inglés、深圳）。数据来自 Wikidata（CC0），由 docudis-core 的 `scripts/fetch_bundled_lists.py` 生成
   `packages/docudis_engine/lists/*.json`，再由 `tool/embed_lists.dart` 嵌入为 Dart 常量（约 1.6 MB）：
   - 公司：business 的全部子类实体，国家在目标市场（英语：英美加澳新；法语：法比瑞；中文：中港台；西语：西班牙），
     维基站点链接数 ≥ 5（英语）或 ≥ 3（其他），取 en/fr/es/zh 标签和别名。约 17500 家、72000 条名称。
   - 中国地名：省、直辖市、自治区、特区、副省级和地级市、县级市，只取标签不取别名（别名多是古称）。
     去掉 市/省 后缀的裸名只给省级、副省级和人口 ≥ 300 万的地级市（大庆、安康、白银、朝阳这类两字裸名也是普通词），
     县级市一律带后缀。约 725 个、1400 条名称。
   - 过滤：单词形式的名字若是英法西小写词典词（hunspell，只算小写词条，Airbus/Google 这类大写词条不算）就丢掉（Apple、
     Orange、Total）；三字母以下全大写缩写丢掉（BMI、AMC）；两字中文公司名要求站点链接 ≥ 40（红旗、黑猫）；全小写拉丁名、
     域名、带冒号或斜杠的、和地名重合的公司名丢掉。2026-09-26 起按 app 实际匹配的样子判断：先去掉首尾标点再过滤
     （"'One'"、"One+"、"Anti-" 以前绕过了词典检查，app 里却按 One、Anti 匹配，把 "One Day Change" 这种表头遮掉），
     并丢掉和美国州名、常见国名重合的单词别名（KFC 的别名 "Kentucky"）。改过滤后用 `--stage refilter` 在现有
     companies.json 上重跑，不用重新查 Wikidata。试过让"公司名后面的大写词"只接模型区间、不接名单命中：三个基准的泄漏
     都变多（名单命中后接的 "of Nursing"、"of Ireland" 才是完整名字），没有采用。
   - 匹配：拉丁名按整词、区分大小写（"apple" 不是苹果公司）；中文任意位置子串。用哈希查表而不是每条一个正则：
     按首词 / 首字集合跳过大多数位置，150k 字符一遍几百毫秒。
   - 优先级与模型同级（`DetectionSource.bundledList` = 20）：更长的一方赢。所以模型的 "深圳华强科技" 不会被名单里的
     "深圳" 拆开；反过来模型把 "阿里巴巴西溪园区三号楼会议室" 整个标成地点时，名单里的 "阿里巴巴" 也让位。
   - 人名不做名单：模型在人名上已是最强项，而常见名字同时是普通词（May、Bill、Pierre、Blanc），名单只会增加误报。
   基准：西班牙语 `El Corte Inglés` 由名单补上（es 97% → 100%）；`阿里巴巴`、`深圳` 仍被模型更长的区间盖住。
   总体 F1 97%（名单之前 98%），差的那 1% 是两处模型标出的真实地点（"阿里巴巴西溪园区三号楼会议室"、"恒隆广场办公室"）
   不在基准标注里，被记为误报。

冲突裁决（来源优先级硬排）：**词典 > 带校验位的规则 > 高置信度规则（confidence ≥ 0.8，如邮箱、国际电话、ISO 日期）> 模型 = 内置名单 > 低置信度规则**。
高置信度规则压过模型是基准测试后加的：模型偶尔会吐出一段横跨数字和正文的垃圾 LOC 区间，若模型优先会把其中的邮箱/电话吞掉。
词典"最高"的意思是"一定被遮"，不是"重叠时一定赢"：词典命中若被一个更长、且本身会被替换的区间完整包住，就让位给它
（词典有 "Dupont"、模型标出 "Jean Dupont" → 整体 `[PERSON_1]`，而不是 "Jean `[CUSTOM_1]`"）。包住它的区间如果没启用
（默认可见的金额、日期），或者自己在别的重叠里输掉了，词典命中照常生效，不会漏。用户在修改页把词典命中点回原文，只影响当前文档。
裁决之后、传播之前补洞（`repairSpans`，2026-09-19；只在 `run` 里执行，用户点选后的 `merge` 不再跑）。起因：真实文档集的暴露
66 处里 40 处是"遮了一半"，露出来的部分都紧挨着一个已遮住的区间；手机上 ML Kit 把 15 位数字串的尾巴认成电话（model = 20），
压过了盖住整串的松散规则（rule = 10），头部 "2 88 03 44" 原样露出。规则：
1. 同类区间在重叠里输掉的一方不许露字：赢家长到盖住它（数字类只长过数字，人名 / 公司只长过字母，≤ 40 字，
   所以横跨半句话的垃圾模型区间仍然整段输掉）。赢家没有校验位而对方更长时，类型跟对方（电话 + 长数字串 → `NUMBER`）。
   生长不停在空格、逗号上；输家一直伸进下一个同类区间时（ML Kit 的 "12 rue des Tanneurs, 69007 Lyon" 盖住街道和邮编两条规则），
   中间那段若第 3 条会合并就留给第 3 条（2026-09-23）。之前赢家一路长到邻居门口、把 ", " 吃进去，第 3 条看见空缝不合并，
   输出成 `[ADDRESS_1][ADDRESS_2]`，而且 "12 rue des Tanneurs, " 和前文的 "12 rue des Tanneurs" 成了两个编号。
   只用规则时本来就是对的。
2. 全大写的人名 / 公司：右侧最多三个全大写词并入（"MARIA GADOR CANO" + "ENCISO"），左侧只并入大写的姓名小品词
   （DE、DEL、VAN…）。左侧不并入其他词：BORME 整句大写，"SIENDO SOCIO UNICO MARIA PEÑA" 会把正文吸进人名，再被人名拆词
   传播到全文（试过，多遮 +8）。数字：紧邻的数字组并入并改为 `NUMBER`，后面还跟着小数、日期、时间或更多数字的不动。
   地址：行内左侧的单元 / 门牌号并入（"Appartement 3, "、"Unit 14C "、"2 "）。
3. 同类相邻区间合并：人名 / 公司之间只隔一个空格或一个小品词；地址之间隔着要遮的东西（"BP 633"、"3ºA"）、没有小写正文词、
   且整体含数字。只隔逗号的 "街道, 城市" 不合并：没有字可遮，合并只会改变占位符结构（试过，合成集 F1 97 → 88，纯属记分口径）。
4. 地址块里没被遮住的整行（2026-09-21，`_addressBlockLines`）：上一行和下一行都已作为地址遮住、这一行本身只由地址
   词构成（大写词、数字、地址小品词，不含职务 / 部门词，不含正文，≤ 40 字）时，这一行单独成为一个地址区间。
   起因：多行信头里城市独占一行（"PO Box 4402 / Leicester / LE87 9AB"），它没有门牌号也没有邮编，规则认不出，
   微调后的模型也不再单独认它，结果整块只剩这一行露着。一次最多取两行（城市，加上换行截断的街道尾巴），
   **上下都必须是地址**是关键：公司名下面的部门 / 商号行（"Personal Lending Services"）上面是公司不是地址，不会被吃。
   每行各成一个区间，不跨行合并，信头的排版不变。邻行的判定是"这行印出来的东西有六成已作为地址遮住"，
   不是"行里有个地名"：简历里 "公司, 地名" 和 "…covering Bristol, Bath…" 之间的职务行差点被吃掉，就是这么挡住的。
   结果：回归集 48 份泄露 86 → 81 处；消费者集零可识别泄露 36 → 40 / 60，泄露率 4.8% → 4.3%；
   公开集、合成集、手写集逐实体零变化，多遮三套都没涨，反例仍是那 1 处 `C. Domicilio`。
地址沿行扩展（行内剩下的大写词、数字、地址小品词）不能停在小品词上（2026-09-23）："from St Luke's on 9 September"
的 "on" 曾被并进医院，句子读成 "from [ADDRESS_1] 9 September"。cedex / bis / ter / s/n 本来就在地址末尾，不受影响。
区间只在本行内生长，不越过任何其他区间（含已关闭的）；只有第 4 条跨行，而且它是新加一个区间，不是把旧区间撑过换行。
结果：真实文档集泄露率 9.5% → 7.2%（遮一半 40 → 24），合成集 1.5% → 0.9%，
多遮 73 → 68，三套 F1 不变，hard negatives 仍为 0。没修的：混合大小写的 "Roche, Jean" / "Hammond, Don"（分不清 "Thanks, Tom"）、
BORME 的 "CL xxx NUM.n" 街道写法（缺规则）、模型把 "姓名\n部门" 跨行标成公司。
模型区间跨行时（2026-09-23），若切成行后有一行是职务 / 部门（`titleStoplist`，"Priya Raman
Human Resources" 整个标成公司），
去掉那几行；没有这种行就保持原样，换行截断的姓名仍是一个人。
之后做传播（已检出的值在全文中每处出现都替换；只有人名会按单词拆开传播，"John Smith" → 后文的 "Smith"）与人名变体归组（"张三" / "张三先生" 同标签）。
置信度阈值内部固定，不暴露给用户（接口保留 `threshold` 参数）。

语言范围（MVP）：人名/机构/地址识别保证**中文、英文、法语、西班牙语**；印地语及其他语言只跑规则，不识别人名。
简体为主，繁体不保证；测试集放少量繁体样本观察。

## 类别（11 类，v1 全做）

PERSON、PHONE、EMAIL、ID（身份证 / 护照）、CREDIT_CARD / IBAN、ADDRESS、URL / IP、DATE、COMPANY、AMOUNT、CUSTOM（自定义关键词）。
2026-09-18 增加两个：NUMBER 和 BIRTH_DATE，见下一节。

## 占位符要对下游模型说真话（2026-09-18 决定）

匿名化文本是交给另一个大模型分析的，占位符的类型是产品的一部分：标错类型会误导它，遮掉它需要的信息会让它答不了题。

- **NUMBER：宁可笼统也不标错。** 低置信度规则（来源 `rule`：无校验位且 confidence < 0.8）命中的纯数字串
  （只含数字、空格、`.`、`/`、`-`），类型从 ID / CARD / OTHER 改报 `NUMBER`，占位符 `[NUMBER_1]`。
  受影响的如 `universal:long_number`、`fr:cni`（任意 12 位）、`fr:siret`、`gb:passport`（任意 9 位）、`gb:sort_code`、
  `gb:bank_account`、`es:nuss`、`us:passport` 命中纯数字时。带校验位的（IBAN、Luhn、NIR、DNI、NHS…）、
  高置信度格式（`us:ssn`、`fr:rcs`）和带字母的命中（`12AB34567`、带标签的 `labeled_id`）保留具体类型。
  实现在 `RegexDetector.typeFor`，规则包本身不改。`fr:siret` 有 Luhn 校验位但不加校验器，保持 NUMBER（用户决定）。
  **宽松电话规则同样降级**：来源为 `rule` 的电话规则命中不带 `+` 的纯数字时报 NUMBER（de / at / dk / se、it 和 nl 的座机规则）。
  `ie:phone` 置信度 0.8 → 0.75 归入此类：en 文本总会加载 ie 包，它的国内写法是"0 开头的任意 8 到 10 位"，
  公开集里把英国公司号 `09583892` 标成了 PHONE。`+353 …` 仍是 PHONE；fr / gb / es / us 的电话规则置信度 ≥ 0.8，不受影响。
  benchmark 计分里 NUMBER 对预期的 PHONE 也算命中。
- **金额默认不遮。** 检测照常运行，`Detection.enabled` 默认 false；用户可以打开。
- **日期只遮出生日期。** 日期前面紧跟出生标签（born / date of birth / DOB / né(e) le / NE(E) LE / naissance /
  nacido el / nacimiento；同一行内最多隔 20 个非数字字符，或标签独占上一行）才改类型为 `BIRTH_DATE` 并遮住，
  同一个日期在文中其他位置也一并遮住。其余日期和金额一样检出但默认关闭。不靠"年份很早"猜：学历年份、公司成立日期都会误判。
  小写 "ne le" 是普通法语（"je ne le ferai pas avant le…"），只认大写无重音的表单写法。关键词在 `rules/birth_date.dart`。
- **数字表格里的宽松数字默认不遮（2026-09-26）。** 一行里有两个以上"度量数"（带小数、带正负号或百分号的数）、
  又没有 account / tel / IBAN / n° / ref 这类编号词，就算一行数字；全文有三行以上时，宽松规则在这些行里找到的纯数字
  （NUMBER，比如被 `gb:bank_account`、`us:passport` 当成账号、护照号的成交量），以及 ML Kit 报成 NUMBER 的数（不带拨号前缀的
  "电话"，照片上的价格和成交量都是这样来的）检出但默认关闭。人名配电话、账号的表格
  没有小数，不算数字行，照常遮住。见 `DetectionPipeline.figureRows`。
- **公开投资产品不遮（2026-09-26，用户决定）。** 基金、ETF 和指数的名字（"Vanguard Total Stock Market ETF"、
  "iShares Core S&P 500 ETF"、MSCI）几百万人都持有，说明不了是谁，遮掉后对账单没法读。公司类检测里带 ETF / UCITS /
  SICAV / OPCVM / SPDR / iShares / S&P / MSCI / FTSE 等标记的（连同紧跟其后的大写词一起看，模型常在 "ETF" 前停下）
  直接丢掉，不进审查列表（ML Kit 标成地址的基金名也一样；区间停在词中间时先读完这个词，"Vanguard S" → "S&P 500 ETF"）；单独出现的基金公司名（"Vanguard"）仍按公司遮，用户手选和"总是隐藏"的词不受影响。
  同一次修改：表格里（区间的某一行有制表符）跨两行的模型区间一律按行切开，整格重复三次以上的列值（"Equity"）丢掉。
  见 `rules/public_products.dart`、`DetectionPipeline._withoutTitleLines`。
- 默认开关在 `DetectionPipeline.withDefaults`，只在 `run` 里执行；`merge`（用户点选后重新合并）不会重置用户的选择。
  关闭的检测不参与传播。放在流水线而不是 `RegexDetector`，因为日期和金额也来自模型（DATE）和 ML Kit。
- 商店文案不能写"遮住所有日期 / 金额"。`docs/store/listing.md` 三种语言已改成"出生日期"并说明金额和其他日期保持可读，
  截图样例里的日期和金额保持原文（结果页计数 9 → 7）。
- **"遮住全部金额" / "遮住全部日期"两个开关**（2026-09-18，用户先说不做，同日改为要做）：放在点选页顶部、提示语下面，
  只在文档检出了金额 / 日期时才显示。开关为开 = 该类型的检测全部启用；拨动即把该类型全部启用或全部关闭并立即存盘，
  和点击一样走 `reapply`。日期开关只管 `DATE`，出生日期（`BIRTH_DATE`）始终遮住；手动点回其中一个，开关自动变回关。

## 替换与还原

- 占位符：带类型和编号，**固定英文**，不随 UI 语言变化：`[PERSON_1]`、`[PHONE_2]`。同一文档内同值同标签。
  区间首尾的空格、逗号、分号留在正文里，不进占位符也不进映射（2026-09-23）：两个相邻占位符总有分隔，同一地址不因尾随逗号换编号。
  人名变体归组（"Smith" 并入 "John Smith"）看名字前面的称谓：Mme / Mrs / Sra… 与 M. / Mr / Sr… 冲突时不归组，
  "Mme Garnier" 和她丈夫 "M. Julien Garnier" 是两个人；没有称谓或称谓不分性别（Dr）时照旧归组。
  同样合得上两个不同的人时不归组（2026-09-24）："Ana García""Luis García" 之后单独的 "García" 另起一个编号，
  不再默认归给第一个人。人名拆词传播只传首字母大写的词：人名区间里的小写词是模型带进来的正文，不是名字。
- v1 只做占位符模式；数据模型保留 `mode` 字段，以便后续加"假数据"模式。
- **可逆**：保存"占位符 → 原值"映射表；提供 `restore(text, mapping)`，容忍 AI 改写后的占位符变形
  （如 `**[person 1]**`、`PERSON-1`），歧义时拒绝还原。
- 还原结果只展示 / 复制 / 分享，**不入历史**。
- **还原前判断回复属于哪份文档**（2026-09-24，引擎 `ReplyMatcher`）：每份文档都从 1 编号，`[PERSON_1]`、`[IBAN_1]` 几乎
  每份都有，光看标签分不出。贴进回复后和本机所有记录比证据：回复里每个标签前后的词在该文档里是否也围着同一个标签
  （"DNI [ID_1]" 对 "Nº de referencia: [ID_1]"），加上回复与该文档共有的词（按有多少份文档含它加权）。另一份文档
  缺的标签更少且证据不少于当前、或缺的不多且证据至少两倍时，挡住结果、指名那份文档并可一键改用它还原；文档从没有过的
  标签类型照旧挡住；AI 顺着编号多编出来的（`[PERSON_4]` 接在 `[PERSON_3]` 之后）只在结果下注明，不挡。测试者的 4 条回复
  对手机上 15 条记录共 60 次判断全对。几乎没有正文的短回复（"Thanks [PERSON_1]"）没有证据，只能靠页面上的文档名。

## 处理流程与数据模型

输入 → 自动检测 → 自动生成输出并展示 → 用户可在页面启用 / 禁用检测项、手动圈选 → **原地**重新生成（不产生新记录）。

**二次修改页面「改一改遮住的内容」（2026-09-17 决定）**：结果页顶栏铅笔进入，只有一种手势——**点击**。
页面显示原文，已启用的检测项直接显示成占位符（`[PERSON_1]`）；点占位符换回原文，点其他任意文字就把它遮住（类型统一为 `CUSTOM`，
不给类型选择器），每次点击立即 `reapply` 存盘，没有确认按钮（`ReviewController.apply` 改为"后到的请求替换前一个"，不再丢弃）。
取消了原来的类型芯片、区间详情弹窗和选中文字标记（`SelectableText` 换成 `RichText` + `TextPainter` 命中测试，
一个手势识别器而不是每个区间一个）。手动区间照样走 `DetectionPipeline.merge` 的传播，全文同值一起遮。

可点击的"块"由引擎的 `chunkText()`（`packages/docudis_engine/lib/src/chunker.dart`，纯规则、无分词模型）切出，
已检出区间是**硬边界**，块不跨占位符。三切一合：① 按 `\n` 切行（拍照时等于 ML Kit 的 OCR 行，所以提取层不必保留版面坐标）；
② 行内按制表符 / 连续空格 / `|` 切格，分开 `标签 : 值` 和发票的列；③ 格内按子句标点切，但数字里的 `,` `.`、邮箱与网址的 `.`、
`Ms.` 这类缩写点不算分隔；④ 把"本身就是一个值"的原子（大写词、数字组、邮箱 / 网址、CJK 串、货币符号）相邻合并，
中间最多跨 3 个 ≤3 字符的小写虚词（`14 rue de la Paix`、`Ludwig van Beethoven` 能合上，`Please call Sarah Meyer` 不会），
单块上限 60 字符。小写正文词各自成块，孤立标点不可点。
**已知取舍**：中文没有分词，CJK 只在标点处切，点一下遮一个子句；句首大写词会和紧随的人名合成一块（`Contact Laura Bennett`），
属于过度遮盖、不漏检；OCR 把词拆开的多余空格（`Rob ert   Johnson`）会被当成列间隔切断。

每条记录一个目录，不用数据库：

```
<app private dir>/records/<id>/
  meta.json          时间、来源类型、原文件名、语言、检测数量
  original.txt       提取后的纯文本原文（不存原始文件）
  detections.json    检测列表（含用户启用 / 禁用 / 手动添加）+ 映射表
  output.txt         匿名化后的文本
```

- 最多保留最近 100 条（按更新时间），每次新处理后删除更旧的记录；账户页"清除本机数据"一次清空全部记录和临时文件（选取的文件副本、照片）。（2026-09-17 修订，原为永久保留）
- 记录目录**排除出 Android 自动备份**（映射表不得随云备份上传）。v1 不加密，依赖应用沙箱；加密留 v2。
- 处理在 isolate 中运行。

## 分享

`share_plus`：分享 `.txt` 文件（主要用法，如发给 ChatGPT）；同时提供纯文本分享与复制到剪贴板。
文件命名：来源为文件用 `<原文件名>-anonymized.txt`；粘贴 / 拍照用 `docudis-<yyyyMMdd-HHmm>.txt`。

## 打包、平台与测试

- **模型交付（2026-09-16 起）**：模型不再是 Flutter asset。
  - 发布：Play Asset Delivery install-time 资源包 `android/model_pack`（`flutter build appbundle`），基础 APK 不含模型，避开 Play 的 150 MB 上限。
  - 开发：`flutter run` / debug APK 装不了资源包，app 模块的 debug source set 由 Gradle 任务把同一批文件同步进普通 assets。
    **`flutter build apk --release` 产物没有模型**，发布必须用 appbundle。
  - 两种情况下 Android 侧路径相同（`models/xlmr_ner_docudis/...`），`MainActivity` 里的 `model_assets` 通道用 1 MB 缓冲流式复制到
    app 私有目录，Dart 内存里从不出现整个 278 MB 文件（之前用 rootBundle 整块读入是首次运行内存峰值近 1 GB、被三星系统冻结的原因）。
    `.onnx` 以不压缩方式存放，方便取长度和跳过重复复制。
- 从 Hugging Face 下载的模型文件**不进 git**（见 `.gitignore`），获取方式见后续 README 说明。
- Android 优先；所用插件均为双平台，代码不排斥 iOS。
- 规则包的 `examples` 字段自动生成单元测试；universal / cn / en / fr 全覆盖，其余包只验证可编译。
- 功能完成后在真机上实测：处理速度、中文 / 繁体 / 拉丁 OCR 质量、模型识别质量，据此敲定最终模型。
- Android `minSdk = 26`（ML Kit Entity Extraction 的最低要求）。
- `android/app/build.gradle.kts` 强制 `onnxruntime-android` 为 1.30.0：插件自带的 1.23.0 在只有 SME、没有 SME2 的 SoC
  （Snapdragon 8 Elite Gen 5 / SM8850，Android 16，即测试机 Galaxy S26 Ultra）上创建会话即 SIGILL 崩溃
  （microsoft/onnxruntime#26377、#27884），1.28.0 起修复。升级 flutter_onnxruntime 时不要丢掉这条。
- 2026-09-16 真机基准（S26 Ultra）：F1 92%、92 ms/千字符，见 `docs/ner-benchmark-device.md`；桌面结果见 `docs/ner-benchmark-desktop.md`。
- 候选模型 XLM-R（`assets/models/xlmr_ner_hrl`，tjruesch 量化导出 278 MB，SentencePiece）同一天真机对比：F1 93%、180 ms/千字符，
  印地语从 82% 到 100%、英文 88% 到 91%，中文速度降到 B（342 ms/千字符），见 `docs/ner-benchmark-device-xlmr.md`。两套模型文件都可用，
  切换只改 `ModelLocator(assetDir:)` 和两个 `build.gradle.kts` 里的目录名（模型不是 Flutter asset，pubspec 里没有它）。
  **2026-09-16 定案：用 XLM-R**；**2026-09-21 换成自己微调的 `assets/models/xlmr_ner_docudis`**：
  消费者集泄露率 18.7% → 10.0%、公开记录 7.3% → 4.8%、多遮 131 → 85，代价是反例集多 1 处误报、
  手写集 F1 97 → 96（英语地址里的裸城市名变弱，见 `docs/HANDOFF-ner-finetune-2026-09-19.md` §3.5a）。
- **可复用基准测试**：数据集 `benchmark/ner_cases.json`（中/英/法/西/印地 + 德/日 + 混合，按类别：人名、机构、地点、地址、联系方式、证件、日期、混合、长文、噪声、反例）。
  - 桌面运行（Python onnxruntime 推理，同一套 Dart 引擎）：`cd packages/docudis_engine && PYTHON=/path/to/python dart run benchmark/run_benchmark.dart --out ../../docs/ner-benchmark-desktop.md`
  - 真机运行：`flutter test integration_test/ner_benchmark_test.dart -d <device>`，报告写到 app 私有目录 `ner-benchmark-device.md`。
  - 评级：可靠度按 F1（A ≥ 90%，B ≥ 75%，C ≥ 50%，D 以下）；速度按每千字符毫秒（A < 300，B < 1000，C < 3000，D 以上）。
  - 每次运行都产出三份文件到 `docs/benchmark/`：`<平台>-<模型>.md`（表格）、`.html`（逐条肉眼对比：原文高亮检测结果 vs 匿名化输出，可按语言/类别筛选、只看失败项）、`.json`（原始结果，不入库）。
    真机日志需用 `dart run benchmark/render_html.dart <log> <out.html> <out.md>` 渲染。
  - 边界测试：`--stress`（桌面）/ `--dart-define=NER_STRESS=true`（真机）追加 10k / 50k / 150k 字符的大文档（由 long/mixed 用例拼接，预期实体已知），记录总耗时和进程 RSS。
- **真实文档测试集（2026-09-18，英/法/西）**：手写的 `ner_cases.json` 每种语言只有几条句子，分数已经到顶（F1 97%），不代表真实水平。新增两套：
  - `benchmark/public_cases.json`：45 份公开记录，实体都是真的。法语 BODACC 商业公告 15 份（开放接口，结构化记录渲染成公告文本），
    西班牙语 BORME 公司登记公报 14 份（PDF 经 `pdftotext`），英语 The Gazette 公司清算公告 8 份（只取公司类，不取个人破产）和
    Enron 邮件 8 封（保留原始大小写、转发链、收件人列表）。来源、许可和重建方法见 `benchmark/public/README.md`。
    `tool/fetch_public_samples.py` 抓取，`tool/build_public_cases.py` 校验并组装。标注 881 条，由未接触检测流水线的标注者通读全文写成，
    规则见 `benchmark/public/ANNOTATION.md`（地址按原文整条标注）。重新抓取会换掉文档，`raw/` 和 `labels/` 视为冻结快照。
  - `benchmark/synthetic_cases.json`：发票、租约、工资单、医疗或保险信件、简历，英法西各 3 份共 45 份，模板 + 假数据，
    由 `tool/generate_synthetic_cases.py` 生成，填槽即标注所以标签精确；IBAN、法国 NIR、西班牙 DNI、NHS 号都带正确校验位。
    发票号、合同号、保单号、工号标为 ID 且带 `"sub": "reference"`，报告里单独计数（这类编号按 09-17 的决定暂不扩规则）。
  - 运行：`run_benchmark.dart --dataset ../../benchmark/<file>.json`。
  - **主指标改为泄漏率**：`tool/leak_report.py <dataset> <run.json>`。对每个预期实体的每处出现，看其字母数字字符是否全部被某个检测覆盖，
    不论类型和切分。隐藏 / 类型错但已隐藏 / 部分可见 / 完全泄漏，外加"零泄漏文档占比"和过度遮盖清单。逐条 F1 会把
    "地址被切成两段检出"或"公司被盖在 ADDRESS 占位符下"算成错误，而这两种情况都没有泄漏。
  - 首次结果（桌面 XLM-R）：公开记录泄漏率 42%（英 9.7%、法 42%、西 71%），合成文档 9.1%（英 2.3%、法 12%、西 13%），
    报告在 `docs/benchmark/leak-public.md` 和 `leak-synthetic.md`。成因几乎全是规则而不是模型，清单见报告。
  - **同日按这两套数据修规则**（全是规则问题，模型没动）：公开记录泄漏 42.0% → 13.2%（英 9.7 → 9.1、法 42 → 10、西 71 → 18），
    合成文档 9.1% → 1.3%，过度遮盖 98 → 73 和 28 → 4，手写基准 97/97/97 不变。改动：
    - 比利时/瑞士"4 位邮编 + 城市"规则吃掉法语日期的年份（"2025        Échéance"）：现在必须在行首或逗号、冒号、破折号之后，
      单个空格，城市每个词首字母大写，置信度降到 0.75 让日期规则赢。法/西/通用的 5 位邮编规则同样改为单空格 + 大写城市，
      且前面不能是两组三位数字（SIRET 尾号 "474 00098    Code NAF" 曾被当成邮编）。`es:postal` 0.75 → 0.8，否则输给只标城市的模型。
    - 比利时和瑞士法语的街道规则把"街名 + 法国 5 位邮编"当成"街名 + 门牌号"，比 `fr:street` 长一个字符，把门牌号和邮编两条规则都挤掉：
      门牌号限 4 位，街道词必须在词首（"Déplacement 1" 曾命中 "place"）。`fr:street` 支持 "7b"、"3 B" 门牌。
    - 金额：数字可以没有千位分隔符（`1000.00 EUR`、`445000 EUR`），新增货币单词后缀（`125000.00 euros`、`3.000,00 Euros`）。
    - 日期：`date_numeric` 校验日月范围后升到 0.85；新增两位年份 `date_numeric_short`（`4.09.24`，0.75），前面是 version / section /
      clause / punto 等词时跳过。
    - 公司规则（fr/es/gb/us）改成"首字母大写的词串 + 法律形式"，不再把公司前面的整句吞进去；后面紧跟冒号的是表单标签不是公司；
      西语支持 SOCIEDAD LIMITADA / SL / SA 等写法，英式支持 Limited。新增法语前置法律形式（`SAS BLENET-CHUL`）、
      表单标签后的公司名（fr/es/gb，值必须大写开头）、以行业名词开头的商号（fr/es，后面必须跟大写词）。
    - 新增 `universal:url`（带协议、www，或"域名 + 路径"；纯域名不算，多半是报刊名或文件名）、`fr:rcs`、`fr:court`（法院连同城市）、
      `es:hoja_registral`；`es:street` 重写（必须有门牌号，去掉单独的 "C."，加 C/、Carrer、Rambla、Gran Vía、楼层门号）。
    - `long_number` 数字之间最多一个分隔符，年份区间 "2017 - 2021" 和页码区间不再是证件号。
    - **误判防线**：`benchmark/hard_negatives.json` 18 段不含敏感信息的相似文本（年份后跟大写词、版本号、重量、空表单标签、区间、
      补空格的表格列）。修之前误报 20 处，修之后 0 处；已接进 `test/rules_test.dart`，任何规则命中即测试失败。
      `tool/run_all_benchmarks.sh` 一条命令跑四套数据并打印泄漏率、过度遮盖和反例误报。
    - 试过又撤掉：`universal:numbered_id`（"n° 202603"、"No. 31850"）。它和 09-17"发票号暂不扩规则"的决定冲突，
      且会把 BODACC 期号和公告号一并遮掉。
    - 剩余泄漏主要是模型对**全大写人名和公司名**的识别（BORME 姓在前全大写，BODACC 无法律形式的全大写商号），
      以及 BORME 特有的金额写法（`357.110,00E`、大写数字金额）。
  - **同日改口径（NUMBER / 金额 / 日期）**：泄漏报告只把**已启用**的检测算作遮住；金额和非出生日期（数据集里出生日期标成
    `BIRTH_DATE`：合成集 36 个、手写基准 1 个，公开集没有）像单据编号一样单独计数，报的是"用户想遮时能不能一键遮上"（被任意检测覆盖）；
    NUMBER 不算类型错；过度遮盖只数已启用的检测。benchmark 的 F1 按检测计分，NUMBER 归入证件族；DATE 和 BIRTH_DATE **严格区分**
    （开关完全由类型决定，把出生日期标成 DATE 就是漏遮，反过来就是多遮），出生日期 87 / 87（含压力用例）和 36 / 36 全部精确命中，
    没有误标的 BIRTH_DATE；手写基准 F1 不变（97），公开 83、合成 97。HTML 报告里默认不遮的检测画成点线、无底色。
    新口径下泄漏率：公开 14.4%（100 / 694；英 9.8、法 15.1、西 18.8），合成 1.7%（11 / 664）。分母去掉了几乎全被遮住的日期和金额，
    所以百分比比旧口径的 13.2% / 1.3% 高，泄漏的条目并没有增加：逐条对比"全部开启"和"默认开关"，没有任何非日期非金额实体因此暴露。
    可选项的检出：公开集金额 35 / 49、日期 131 / 133；合成集金额 117 / 117、日期 96 / 96；合成集 36 个出生日期全部遮住。
    NUMBER 占位符：公开 8 处（含 `ie:phone` 那 1 处，"类型错"从 23 降到 22）、合成 15 处；两套数据的电话仍全部遮住。
  - **全大写词转首字母大写再喂模型（同日）**：`NerDetector.titleCased`，4 个及以上大写字母组成的词（`LOPEZ CORCOLES` →
    `Lopez Corcoles`）只在送进分词器的那份文本里改写，每个词长度不变，所以 token 偏移仍然指向原文，检测值仍是原文写法。
    3 个字母以下的不动（SA、SL、RCS、NHS 多是缩写）；阈值改成 3 试过，公开集泄漏 10.1%，不如 4。
    公开记录泄漏 14.4% → **9.4%**（65 / 694；英 9.8 → 8.4、法 15.1 → 13.2、西 18.8 → 8.9），F1 83 → 85（召回 77 → 81）；
    合成 1.7% → 1.5%；手写基准 97 不变；反例集误报仍为 0；过度遮盖 73 → 74 和 4 → 3。
    逐条对比：公开集 39 个实体由泄漏变为遮住，4 个变差（`REST'OR`、`Roche, Jean-François Jules` 和两个 BORME 人名由全遮变成部分遮），
    合成集 2 好 1 差（`Brightwater Dental Practice`）。新增的过度遮盖主要是公报刊头（`BOLETÍN OFICIAL DEL REGISTRO MERCANTIL`）。
    改写本身 45 份文档共 3 ms。注意：这台机器连续跑 benchmark 会降速（同一份代码前后能差 10 倍，关掉本改动同样慢），速度等级只在冷机时可信。
- **OCR 可复用基准测试**：manifest 为 `benchmark/ocr_cases.json`，固定测试图片在 `benchmark/ocr/images/`。图片由内置图像生成能力制作后固定入库，均使用合成资料；正文和关键字段有精确 ground truth，不放入真实个人资料。
  - 真机运行：`flutter test integration_test/ocr_benchmark_test.dart -d <device>`。runner 按每条用例声明的 ML Kit script 识别，不依赖测试机的系统语言；图片 asset 会先复制到临时文件再交给 ML Kit。
  - 主准确率为归一化字符准确率（由 normalized CER 得出），同时报告 strict/normalized CER、WER、逐行 F1、整图精确匹配、关键字段召回、识别错误，以及每张图耗时；结果按语言和场景类别汇总。
  - 真机输出 Markdown/HTML 到 app support 目录，并在测试日志写出单行 `OCR_BENCHMARK_JSON {...}`，便于保存原始结果和在桌面重建报告。性能数字必须注明设备、系统与 ML Kit 版本；冷启动与连续识别结果不可混为一项。
  - 桌面重建报告：在 `packages/docudis_engine` 运行 `dart run benchmark/render_ocr_html.dart <log|json> ../../docs/benchmark/<name>.html ../../docs/benchmark/<name>.md`。
  - 桌面候选模型（只出预测 JSON，统一由 `dart run benchmark/score_ocr_predictions.dart <manifest> <predictions.json> <out-base>` 打分；预测里 `recognizedTextFormat: markdown` 会按 Markdown ground truth 同样的规则去格式）：
    - PP-OCRv6：`.dart_tool/ppocr-venv` 里跑 `tool/run_ppocrv6_benchmark.py --size tiny|small|medium [--pad 32] [--script-models]`。
    - OCR VLM（整页单提示词、无版面模型）：`.dart_tool/ocr-vlm-venv`（torch CUDA + transformers 5）里跑 `tool/run_vlm_ocr_benchmark.py --model glm-ocr|paddleocr-vl --model-path .dart_tool/ocr-models/<名> --output docs/benchmark/ocr-<名>-predictions.json`。
      transformers 版 PaddleOCR-VL 解码只有约 3 token/s，桌面耗时不可作速度对比。

## 代码位置

- `packages/docudis_engine/`：检测、替换、还原、规则包（纯 Dart）。
- `lib/anonymize/`：Flutter 侧的输入提取（文件 / OCR / 相机）、模型加载、存储、分享、Riverpod 状态。
