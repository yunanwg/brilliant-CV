# Brilliant CV 仓库全面审计报告（2026-07）

> **范围**：代码质量、DevOps/发布工程、测试与 TDD、文档与社区治理，外加 Typst 语言与生态最佳实践研究。
> **方法**：11 个并行审计/研究 agent（6 个仓库维度审计 + 3 个 web 生态研究 + 1 个完整性批评员 + 2 个补充重跑），全部结论经结构化汇总、交叉去重；关键事实（含全部 P0 级缺陷）由主审逐一亲手验证或由 agent 实际编译复现。审计基于 `main` @ `029041f`（v4.0.1）。
> **说明**：本报告为一次性审计工作文档，不属于用户文档站内容（`docs/web/` 之外，不参与 MkDocs 构建，也被 `typst.toml` exclude 排除在 Universe 发布之外）。

---

## 1. 执行摘要

**总体判断：这是一个工程质量显著高于同类水平的单维护者 Typst 模板项目**——四层测试体系（units/components/regression/panics）+ 像素级确定性 Docker 工具链、带迁移指引的 panic 式 schema 守卫、自动生成的 API 文档、零积压的 issue 管理（审计时 0 open issues / 0 open PRs）在 Typst 模板类包中几乎无出其右者，与 cetz/touying 等旗舰包相比测试基础设施甚至更强。**测试与文档基础设施不需要再投入——这是本次审计明确的"不要折腾"结论。**

真正的问题集中在三处：

1. **一批被"所有 profile 都设置了所有可选键"掩盖的真实渲染缺陷**，其中 3 个已实际出现在随包发布的官方示例 PDF 中（description 重复渲染、字面量 "Date" 占位符泄漏、key-list 被静默忽略），另有 2 个潜伏崩溃路径（`eval()` 默认值类型错误、`cv-publication` 默认参数类型错误）。
2. **发布流水线存在已造成过真实事故的顺序缺陷**：GitHub Release 在包校验之前创建。v3.0.0 已因此成为"幽灵版本"——GitHub Release 存在，但 typst/packages 从未收到对应 PR（2.0.0→4.0.1 每个版本都有对应 PR，唯独 3.0.0 缺失，项目直接跳到 v3.1.0）。同时 `just bump/release` 使用 BSD 专用 `sed -i ''`，在 GNU sed 下已复现直接失败。
3. **两项下次发版即会被 typst/package-check 机器人拦截的 Universe 合规问题**（README 引用 thumbnail.png 违反 manifest 规则、description 措辞/长度不合规），以及一个法律暴露面（随包向 Universe 分发真实 UCLA 官方校徽）。

另有一个需要**维护者做一次战略决策**的议题：AI/关键词注入功能。约 6 条独立发现全部收敛于同一个决策点（见第 8 节）。

**缺陷统计（去重后）**：critical 1、high 4、medium 13、low 约 20、info 若干。全部 critical/high 均为 confirmed（亲手验证或实际复现）。

---

## 2. 值得保留的优势（先说清楚哪些不要动）

这些是审计确认的真实资产，后续改进不应破坏：

| 优势 | 证据 |
|---|---|
| **四层测试分类学 + 像素确定性** | units/components/regression/panics 职责清晰；单一 Docker 工具链（typst 0.15.1 / tytanic 0.4.1 / typstyle 0.15.0 全部 pin 到明确 release URL），CI 与本地一致，`max-delta=1, max-deviations=0` 真正拦得住 1pt 级回归 |
| **panic 式 schema 迁移守卫** | `_check-v3-legacy` / `_check-v2-inject-legacy` 报错信息逐字段指出 v4 替代写法，配套 panic fixture 双入口（cv/letter）测试，是破坏性迁移的教科书式做法 |
| **回归驱动的维护流程** | 代码注释直接引用 issue 编号（#172/#173/#181/#187），AGENTS.md 的"修 bug 必带回归测试"方针经抽查确实被执行 |
| **CJK/i18n 设计** | `title_highlight` 三模式、`display_name`、按 locale 的 `date_width`、grapheme-cluster 正确的标题切分（#187 修复后），profile_zh 是完整可用的而非 stub |
| **发布产物泄漏断言** | release workflow 用 typst.toml 的 exclude 驱动 rsync 并断言无泄漏（commit d896548），单一事实源做得对 |
| **社区运营纪律** | 0 积压；标签/里程碑真实使用；发布说明手写、逐 PR 归纳、致谢外部贡献者；wontfix 均附理由 |
| **AGENTS.md/CLAUDE.md/copilot-instructions 三合一** | 经由 symlink 统一，无三份手工同步的漂移风险 |
| **文档准确性** | api-reference.md 与现源码重新生成逐字节一致；components.md 全部 20 张组件图对应真实 tytanic ref；"40+ tests" 宣称保守属实（38 tytanic + 11 panic fixtures） |
| **极简 API 哲学校准正确** | 竞品调研确认：用户抱怨集中在细粒度布局旋钮（#189/#190/#191），而 fork（typst-neat-cv）的动机也是这类；用 recipes 文档而非新参数应对是对的 |

---

## 3. 代码质量（src/）

**总评**：约 1600 行的发布面，命名一致（kebab-case）、doc-comment 覆盖近乎完整、Typst 惯用法（state+context、show/set 规则）使用得当。核心问题是一类系统性盲区：**所有 5 个 shipped profile 都设置了每一个可选配置键，因此默认值/回退路径在测试和日常使用中从未被执行过**——恰恰是这些路径藏着真实缺陷。

### 3.1 已确认缺陷

| # | 严重度 | 位置 | 问题 |
|---|---|---|---|
| C1 | **high** | `src/cv.typ:688-696` | `cv-entry-continued` 多行日期分支：description 在表格单元格内渲染一次（有空值守卫）后，第 696 行又**无条件**渲染第二次。`profile_en` 的 "Data Scientist" 示例（`date: [2017 - 2020 #linebreak() 2021 - 2022]`）正中此路径——**官方英文示例 PDF 中两条 bullet 逐字重复**（已编译 + pdftotext 复现）。空 description 时第二次渲染仍会输出多余的 `v(before-entry-description-skip)` 间距 |
| C2 | **medium** | `src/cv.typ:442-449` | `eval(metadata.layout.at("before_entry_skip", default: 1pt))`——`eval()` 只接受字符串，默认值却是 length 字面量 `1pt`。用户省略该键时不是得到 1pt 而是 cryptic crash（"expected string, found length"）。同文件 406-409 行（`"1pt"`）、452 行（`"3.6cm"`）、lib.typ:90（`"9pt"`）都用了正确的字符串默认值，仅这两处笔误 |
| C3 | **medium** | `src/cv.typ:1064-1082` | `cv-publication` 的 `key-list: list()` 默认值——`list()` 返回的是 content 元素而非 array，`ref-full: false` 时 `for key in key-list` 会崩（"cannot loop over content"）。应为 `()`，doc-comment 类型标注 `(list)` 也应改为 `(array)` |
| C4 | **low** | `src/cv.typ:58-122` | `_make-header-info` 分隔符计数逻辑：`linebreak` 键重置 `n=0` 导致末项后多出悬挂 `|`；h-bar 发射不在 `v != ""` 守卫内，空字符串字段会产生前面没有内容的孤立分隔符。默认 profile 不触发，掩盖了问题 |
| C5 | **low** | `src/lib.typ:143` vs `letter()` | `cv()` 会 `cv-metadata.update(metadata)`，`letter()` 不会——在信件正文里使用任何 cv-* 组件（不显式传 metadata）会因 state 为 none 而 cryptic crash。一行补齐即可对称 |
| C6 | **low** | `src/cv.typ:527`, `src/letter.typ:14` | `metadata: metadata` 默认参数引用了未定义绑定，仅因所有调用点都显式传参而未爆——应改为 `metadata: none` + `cv-metadata.get()` 回退 |
| C7 | **low** | `src/cv.typ:656-663` | 多日期检测 `linebreak() in date.fields().children` 假设 content 一定是 sequence；叶子型 content（如 `date: [2020]`…经变换后）可能没有 `children` 字段——与 #187 同类的"假设 content 形状"缺陷模式，建议 `date.fields().at("children", default: ())` |
| C8 | **low** | 缺失 `[layout]` 时 | 裸 panic `dictionary does not contain key "layout"`，无任何指引——与同代码库 v3 守卫的友好报错风格不一致（已实际复现）。建议在 `cv()`/`letter()` 入口加显式存在性检查 + 友好报错 |

### 3.2 一致性小结（低优先级清扫清单）

- 样式闭包重复：`skill-type-style`/`skill-info-style` 在 `cv-skill` 与 `cv-skill-with-level` 间复制粘贴；footer-style 在 `_cv-footer`/`_letter-footer` 重复。
- API 不对称：`cv-skill*` 三件套不接受 `color:`/`metadata:`，硬编码 `_regular-colors`，静默忽略 `awesome_color`——与 `cv-entry`/`cv-honor` 行为不一致，应做决定并写入文档。
- `h-bar()` 被公开导出（template/cv.typ 在用）但无 `///` doc-comment，生成的 API 文档中缺失。
- `metadata.toml.schema.json` 漂移：缺 `font_size`（src 实际读取）、缺 `location`（5 个 profile 全在用、src 有专用图标）、`paper_size` 的 pattern 荒谬地允许十六进制色值、required 列表比代码实际要求更严。**建议 fix-or-delete，不建议为它建 CI 校验器**（advisory-only 定位，AGENTS.md 的事实源是 metadata.toml 注释）。

---

## 4. 模板与配置（template/）

**总评**：5 个 profile 全部编译通过、资产路径全部正确。但**非英文 profile 的校对严谨度明显低于 canonical profile**，且有两个缺陷实际出现在 shipped 示例输出中。

### 4.1 已确认缺陷（均经实际编译 + PDF 文本提取验证）

| # | 严重度 | 位置 | 问题 |
|---|---|---|---|
| T1 | **high** | `template/profile_{fr,de,it,zh}/publications.typ` | 4 个非英文 profile 传了 3 项 `key-list` 但没设 `ref-full: false`（默认 true 时 key-list 被**静默忽略**、整个 .bib 全量渲染）——4 个 profile 的 PDF 都多印出一条未声明的第 4 篇文献（"Brown, E. (2023)…"），en 正确。新用户照抄示例学到的是错误用法 |
| T2 | **medium** | `template/profile_en/professional.typ:15-22` | "Director of Data Science" 的 `cv-entry-continued` 没传 `date:`，默认值 `"Date"` 直接以字面量渲染进旗舰示例 PDF 的日期栏。讽刺的是 fr/de/it/zh 的对应条目都正确传了日期 |
| T3 | **medium** | `template/assets/logos/ucla.png` | **真实的加州大学官方印章**（398KB，视觉确认），在全部 5 个 profile 的 education.typ 中配以真实校名使用，随包发布到 Universe。与 Apache-2.0 §6 的商标不授权条款直接冲突；同目录的 ABC/XYZ/PQR 虚构公司 logo 说明维护者本有正确直觉，只是没贯彻到教育条目 |
| T4 | **medium** | `template/profile_zh/metadata.toml:20-23` | 默认字体 Heiti SC 仅 macOS 有；Linux/Windows/typst.app 上只发**软警告**然后静默替换任意 CJK 字体（已复现），视觉标识随环境漂移。唯一的说明（Noto Sans CJK SC 替代方案）在托管文档站上——而 `typst init` 只分发 `template/` 目录，用户根本收不到 |
| T5 | **medium** | `template/cv.typ`（新用户打开的第一个文件） | 全文没有一个字提到需要安装 Roboto / Source Sans 3 / Font Awesome 7——而托管文档把字体安装列为 Step 2、troubleshooting 第一条就是 "Font Missing"，issue 史上 #11(2023)/#31/#57(2024)/#192(2026) 四次重复报告。**指引没有随 `typst init` 一起旅行**是这个三年顽疾的结构性原因 |
| T6 | **low** | `template/profile_{de,it}/education.typ:22` | 学士学位日期与硕士完全相同（均 "2018 - 2020"）——复制粘贴痕迹；en/fr/zh 均正确（2014 - 2018） |
| T7 | **low** | `template/profile_{fr,de,it,zh}/professional.typ` | 都只演示了一个 `cv-entry-continued`，唯一演示"同一雇主两段角色"完整模式的 profile 恰好是有 C1 bug 的英文版 |
| T8 | **low** | `template/letter.typ` | 信件正文是硬编码英文段落，无 per-profile 变体——`--input profile=zh` 只切换页眉页脚字符串。与 "multilingual …cover letters" 的宣称有落差；近期用文档说明定位即可，完整方案是 profile 级 letter_body 模块 |
| T9 | **medium** | 资产体积 | `typst init` 会拉取约 **2.4MB**：thumbnail.png 1.1MB（Universe 缩略图，但也在包内）+ avatar.png 694KB（卡通形象，非真人）+ ucla.png 398KB + signature.png 146KB（真实手写签名扫描件）。oxipng/降采样可砍掉大半。**优先级高于测试 ref PNG 优化**（后者 1.9MB 但永远不离开 git 仓库） |

### 4.2 隐私提示（文档缺口）

模板鼓励用户放入自己的头像和手写签名，但没有任何文档提醒：签名扫描件和照片属敏感信息，用户惯常把整个模板仓库 push 到公开 GitHub。一句"建议将 assets/ 中的个人文件加入私有路径或 .gitignore"的提示成本极低。

---

## 5. DevOps 与发布工程

**总评**：CI 分层合理（arm64 Docker 视觉门禁 + x86 native 编译冒烟）、最小权限声明做得对、GHA 层缓存有效。但**发布路径是全仓库风险最集中的地方**——有已发生的真实事故，也有 Linux 上必然复现的硬故障。

### 5.1 已确认缺陷

| # | 严重度 | 位置 | 问题 |
|---|---|---|---|
| D1 | **critical** | `release-and-publish.yaml:59-66` | **GitHub Release 在包校验/上游 PR 之前无条件创建**。实证事故：v3.0.0 tag 推送触发的 run 19966110700 十一秒即 failure（2025-12-05），但 Release 已在同一 run 内发布；typst/packages 中 2.0.0→4.0.1 共 16 个版本各有一个对应 PR，**唯独 3.0.0 为零**——公开的 GitHub Release 指向一个 Universe 上从不存在的版本，项目随后直接跳到 v3.1.0。应把 Release 创建移到最后一步，或先建 draft 待全部步骤成功后 publish |
| D2 | **high** | `justfile:147,150,153,156` | `sed -i ''` 是 BSD/macOS 语法；GNU sed 4.9 下实测 exit 2、文件原封不动——`just bump`→`just release` 整条打 tag 流水线在任何 Linux 环境下断裂。可移植写法：`sed -i.bak … && rm -f *.bak` |
| D3 | **high** | `justfile:134,138` + workflow 触发器 | `just release` 只跑 `just build`（裸编译），**从不跑 `just test`** 就 commit/tag/`git push origin main --tags`；tag 推送触发的 release workflow 与 main 推送触发的 test workflow 并发独立、互不依赖——视觉损坏的版本可以在测试红灯的同时被提交到 Universe。另外 `--tags` 会推送**所有**本地 tag 而非刚建的那个（应 `git push origin main "v$VERSION"`） |
| D4 | **medium** | `release-and-publish.yaml:161-245` | 上游 PR 创建步骤**没有任何 `if:` 条件**——`workflow_dispatch` 手动跑一个 `-test` 版本也会真实地 force-sync fork 并向 typst/packages（志愿者维护的第三方仓库）开 PR。version regex 明确允许 `-test` 却无短路 |
| D5 | **medium** | `compile.yaml:6-8` | 裸 `push:` + `pull_request:` 触发——同仓库分支的每个 PR commit 触发**两次**完全相同的运行（9+ 对相同 head_sha 的成对 run 已实证）；test.yaml 已正确限制 `branches: [main]`，同样的做法没有套用。全部 5 个 workflow 无一声明 `concurrency` 取消组，force-push 不取消在途运行 |
| D6 | **medium** | `compile.yaml:45` | `setup-typst@v3` 无版本输入 → 每次装"当时最新"的 typst——三方失谐：manifest 声称 0.14.0 / Docker 测 0.15.1 / compile 门禁漂移。**声明的 0.14.0 下限从未被任何测试执行过**。最便宜的正解：compile.yaml pin `typst-version: '0.14.0'` 把门禁变成下限证明（floor 提升是另一个独立的、需当作向后兼容破坏来对待的决策，见第 7 节）。顺带：setup-typst 当前主版本已是 v5（node24），v3 终将被 GitHub 弃用 |
| D7 | **medium** | `sponsors.yaml:18,23` | 每周无人值守的 cron 任务用的是与发布同一个 `PAT_TOKEN`（具备跨仓库 push + 向 typst/packages 开 PR 的权限），而它只需要往本仓库提交 README——默认 `GITHUB_TOKEN` + 已声明的 `contents: write` 即可。第三方 action（JamesIves@v1，可变 tag）在最低信任场景里继承了最大爆炸半径。另：全部 action 均 tag-pin 而非 SHA-pin，无 dependabot/renovate |
| D8 | **medium** | `documentation.yaml:4-6` | `mkdocs build --strict` 只在 push main 后运行——PR 里的文档破坏在 review 期间不可见，合并后才红；`force_orphan: true` 又使 gh-pages 无历史可回滚。给 PR 加 build-only 任务即可 |
| D9 | **low** | `.pre-commit-config.yaml:15-20` | delete-all-pdfs 钩子无视 pre-commit 传入的文件列表，`find . -name "*.pdf" -delete` 全仓库删除——超出其守卫定位的破坏半径；`**/*.pdf` 本已被 gitignore |
| D10 | **low** | `release-and-publish.yaml:9-13` | workflow_dispatch 默认版本硬编码 `4.0.0`（已过时）——手滑点 Run workflow 会重发旧版本 |
| D11 | **low** | `justfile:150,181` | bump/check-version 扫描范围不含 `tests/`——`tests/regression/cv-en/test.typ:6` 注释里的 `4.0.0` 已经漂移（现版本 4.0.1） |
| D12 | **low** | `tests/Dockerfile:18,36-38` | 基础镜像 `ubuntu:24.04` 未 pin digest；`fonts-noto-cjk` 无版本 pin——而 CJK 回归 ref 恰恰依赖它，未来重建镜像可能静默漂移 CJK ref。同文件其他所有工具/字体都 pin 了明确 release URL，唯独漏了承重的这个 |
| D13 | **low** | `justfile:52,303` | `open` 命令 macOS-only（仅便利/已弃用 recipe，低优先级） |

---

## 6. 测试与 TDD

**总评**：结构和确定性工程是同类最佳水平（见第 2 节），无需改造。以下是覆盖缺口与工效摩擦。

### 6.1 覆盖缺口（按 ROI 排序）

1. **cv-publication 零隔离测试**——唯一没有 component/unit 覆盖的公开组件；`ref-full: true` 分支在所有 profile 中被注释掉，**从未被 CI 编译过**（这正是 T1/C3 能存活的原因）。补 2 个 component fixture + 一个 2 条目 .bib，约 30 分钟。
2. **`datetime.today()` 无机器守卫**——tests/README 的"永不在 fixture 中使用"只是散文；letter() 默认参数就是 `datetime.today().display()`，新贡献者忘记覆盖 `date:` 会埋下"第二天才爆"的 ref 定时炸弹。3 行 grep 守卫（加进 `tests/panics/run.sh` 或 CI step）。
3. **profile 键集 parity 无守卫**——5 份 metadata.toml 手工同步，profile_en（docs 事实源）加字段后其他 4 份静默漂移无任何报警。同样是 3 行 shell 检查的量级。
4. **doc-comment ```example 从不编译**——generate-api-reference.py 纯字符串提取；示例引用未定义的 `_metadata`，参数改名后坏例子会静默发布到 Universe 文档。轻量方案：先加 PUBLIC_FUNCTIONS 与实际导出集合的相等性断言；重方案（提取+注入 fixture+编译）在 tidy 迁移评估（第 9 节）之后再决定，避免重复建设。
5. **注入功能无正向断言**——2pt 白字对像素 diff 不可见，"注入悄悄失效"完全检测不到；唯一的行为保证是 compile smoke。*注意：是否补 pdftotext 断言取决于第 8 节的功能去留决策，决策前不要投入。*
6. **枚举出的未测分支**：cv-honor 仅 title 分支、带照片的双栏 header（可用纯色合成图避 flap）、`header_align` center/right、us-letter 纸型及其 margin 分支、组件级 `color:` 覆盖、footer 无页码分支、skill level 0。每个约 10 行 fixture。

### 6.2 工效与卫生

- **x86_64 Linux 贡献者被整个视觉测试层锁在门外**（arm64-only 是刻意的像素确定性设计）——**只应做文档化**（"x86 请跑 `just test-fast`，push 后由 CI 验证/再生 ref"），不要做宽容差 x86 通道（自相矛盾）。
- `just test-fast` 依赖 `just link`（utpm）但 units/panics 全部用根相对导入、根本不需要 link——白白给最受限的贡献者加了一个工具链要求，可直接去掉前置。
- 死 fixture：`tests/common.typ:70` 的 `metadata-with-display-name` 无人引用，注释还宣称了不存在的覆盖。fix-or-delete。
- 14/21 个 component ref 目录缺 tytanic 的 `/diff/ /out/` .gitignore——建议直接在根 .gitignore 加 `tests/**/diff/`、`tests/**/out/`。
- ref PNG 未过 oxipng（tytanic 官方建议）——顺手做可以，但优先级低于 shipped assets 瘦身（T9）。

---

## 7. 文档与社区治理

**总评**：文档准确性经抽查表现出色（见第 2 节）。缺口集中在"通用 OSS 脚手架未按本仓库实际形态裁剪"。

| # | 严重度 | 问题 | 建议 |
|---|---|---|---|
| G1 | **medium** | **无 CHANGELOG.md**——一个有 v1→v4 四代破坏性迁移的模板包，版本间增量只能翻 GitHub Releases。conventional commits 已被严格执行，git-cliff 生成几乎零成本 | git-cliff 生成 + docs nav 挂链接。注意竞品调研的"全生态第一家"说法是虚荣框架，价值就是朴素的一份变更清单 |
| G2 | **medium** | **issue 模板是 GitHub 默认脚手架原样**——含 "Browser [e.g. chrome, safari]" 这类网页应用字段，却不收 Typst 版本/包版本/profile 名/报错粘贴框——单维护者 triage 每单都要来回补问 | 换 YAML issue form，必填字段：typst 版本、brilliant-cv 版本、profile、错误输出 |
| G3 | **medium** | **双文档管线解析同一批 `///` 注释**：PDF 侧用真 tidy（活作用域、示例真编译）、web 侧是 376 行自研 regex Python（不编译、静默丢弃不匹配块、PUBLIC_FUNCTIONS 硬编码无同步检查）。且 `docs/pdf/docs.typ` 不在任何 CI 中编译——恰恰是签名变更时最会坏的文件 | 短期：CI 加一行 `typst compile docs/pdf/docs.typ` 冒烟 + PUBLIC_FUNCTIONS 相等性断言；中期：评估用 tidy 数据模型驱动 api-reference.md，退役自研解析器（先做 spike 确认 markdown 形态可行） |
| G4 | **low** | CONTRIBUTING.md:26 宣称 typos/pre-commit "已在 README 提及"——README 全文无此二词（实际在 getting-started.md） | 一行修正 |
| G5 | **low** | migration.md 的 v2 导入示例 Before/After 是同一行 `4.0.1`（无演示价值） | Before 改成真实旧版本号 |
| G6 | **low** | **中文用户零文档**——zh 是 first-class profile，migration.md 里已有完整的中文 worked example，却没有一个中文 quickstart | **复用不翻译**：把 migration.md 现成的 zh 示例节选成 getting-started 的 "中文快速上手" 小节，纯拼装工作 |
| G7 | **info** | SECURITY.md / CODE_OF_CONDUCT.md / PR 模板缺失 | **明确判定为低 ROI，不建议做**（无运行时依赖面、低贡献者流量）。唯一例外：`dependabot.yml` 的 github-actions 生态项——几分钟成本换 action 升级信号 |
| G8 | **info** | 维护者自建 AI bot（cove-by-yunan / "Spark"）自主开 issue、建里程碑，披露仅存在于一次性测试 issue #157 | CONTRIBUTING 或 bot 签名里加一行"哪些操作是自动化的"透明度说明，成本一句话 |
| G9 | **info** | 外部 PR 平均 2-6 周批量随版本合入（抽样 12-39 天，全部最终合入、零烂尾） | 无需改流程；给新贡献者一句"收到，会随下个 release 批量处理"的快速 ack 即可消除误解 |

---

## 8. 战略议题：AI/关键词注入功能的去留（一次决策收敛六条发现）

**现状**：`[injection]` 在**全部 5 个 profile 中默认开启**、无独立开关（删键即关）；README/Universe 以 "AI & ATS friendly" + `ai-injection` 关键词营销；实现为 2pt 白字 `place()`（`src/utils/injection.typ:19`），已验证注入文本确实落入 CV 与求职信的 PDF 文本层。

**汇聚到同一决策点的事实**：

1. **维护者自己已公开表示低信心**：issue #185 回复原文——"honestly personally I haven't used it for a while, as with SOTA models nowadays prompt injection doesn't seem to be that effective"（仍认可关键词注入一半的价值）。
2. **检测面在收紧**（web 调研，2025-2026）：ManpowerGroup 报告约 10% 被扫简历含隐藏文本、Greenhouse 报告约 1% 含白字信息，专用检测工具已出现（PhantomLint, arXiv 2508.17884）；ATS 侧隐藏文本可能直接判负。
3. **与 Typst 平台方向结构性冲突**：0.14 起 tagged PDF 默认、0.15 支持 PDF/UA-1——"仅供机器阅读的隐藏层"几乎是 PDF/UA 标记规则的定义性反例；屏幕阅读器会朗读注入内容、复制粘贴会带出。
4. **第三方视角**：`custom_ai_prompt_text` 本质是对招聘方 LLM 的 prompt injection payload，可能触及招聘平台 ToS——这是声誉/责任维度，不只是"有没有效"。
5. **技术面**：白字硬编码假设白色页面背景；`place()` 在 body 起点无条件叠放；空 parts 仍发射空 place。
6. **竞品对照**：品类领导者 RenderCV（17k+ stars）走的是完全相反的路线——公开 ATS 可解析性测试报告（真实商用解析器实测），以"可验证的诚实"为卖点。

**建议的决策框架（二选一，不要维持现状）**：

- **方案 A（保留但诚实化，工作量 S-M）**：默认改为 opt-in（5 个 profile 的 `injected_keywords_list` 注释掉）；README/docs 加风险披露段（检测率、诚实关键词建议）；技术加固（PDF /Artifact 标记使其对辅助技术不可见、空值守卫、去白色硬编码）；此后再考虑补 pdftotext 正向断言。
- **方案 B（弃用，工作量 M）**：按 AGENTS.md 自身哲学做 panic-with-migration-message 式弃用（下个 major），从 Universe 关键词与 README 撤下营销位。prompt 注入一半（维护者已不信）先行弃用、关键词注入一半可保留为方案 A，也是合理的拆分。

**明确不建议**：在此决策落地前投入任何"为注入功能建验证基础设施"（ATS 报告、pdftotext 断言管线）——那是为一个可能被弃用的功能修城墙，负 ROI。RenderCV 式 parseability 报告只有在选择方案 A 且想正面竞争 ATS 叙事时才值得排期（届时现有 Docker 测试栈可低成本复用）。

---

## 9. Typst 生态与平台趋势（web 调研要点）

- **Universe 合规（下次发版硬性关卡）**：
  - manifest.md 明文规定 thumbnail "must not be referenced anywhere in the package"——`README.md:3` 的 `<img src="thumbnail.png">` 违反（thumbnail 会被自动从发布包剥离，README 里是死引用）。改为 raw.githubusercontent 绝对 URL。
  - description 约 79 字符、含 "Typst" 一词、带 "and more" 填充——三处触碰 Universe 措辞规范（≤60 字符、非 Typst 主题包不提 Typst、免冠词）。建议类似 "Modular, multilingual CV and cover letter template"。
  - **typst/packages 的 PR 现在由 typst/package-check 机器人自动审查**——上述两项大概率被自动拦截；release workflow 自动开的 PR 无人盯梢，bot 反馈会悬空。
- **模板目录许可**：licensing.md 建议模板目录用免署名许可（MIT-0/0BSD/CC0）——用户填完自己的 CV 公开发布时不应背负 Apache-2.0 的 NOTICE 义务。建议 SPDX AND 表达式：src/ 保持 Apache-2.0，template/ 转 MIT-0，README 说明分区。
- **平台版本**：当前 stable 0.15.1（2026-07-17）。0.15 带来变量字体、实验性 HTML 导出、多文献库、`--pdf-standard` 多目标（含 PDF/UA-1）。`first-line-indent` 语义变化（set 规则字典合并）值得在 bump 前跑一遍 ref diff。1.0 将通过 edition 机制引入破坏性变更（关注 typst/typst 跟踪 issue，9-12 个月视野）。
- **HTML 导出：不要做**。仍为实验特性、官方不建议生产使用、无竞品已发货——路线图上标"观察"。
- **工具链现状确认**：tytanic 0.4.1 / typstyle 0.15.0 均为当前版本，无漂移；tidy 0.4.3 是 API 文档生态标准（本仓库 PDF 侧已在用）；setup-typst 最新 v5.1.0。
- **typst.app 用户**：Font Awesome 7 未预装（需手动上传 OTF）、Heiti SC 不可上传（专有）——zh profile 的 web 用户是最可能受挫的群体，需要文档化的 Noto Sans CJK SC 路径（与 T4/T5 同一个修复主题："让指引随 typst init 旅行"）。

---

## 10. ROI 排序的改进路线图

### P0 — 立即（合计约 1 个工作日，全部 S 级工作量）

| 项 | 动作 | 覆盖发现 |
|---|---|---|
| P0-1 | 修 3 个 shipped 示例可见缺陷：删 `cv.typ:696` 重复渲染（+补多行日期 continued 的 tytanic ref）；profile_en Director 补 `date:`；4 个 profile 补 `ref-full: false` | C1, T2, T1 |
| P0-2 | 修 2 个潜伏崩溃：`cv.typ:442-449` 默认值改 `"1pt"`；`key-list` 默认改 `()` | C2, C3 |
| P0-3 | 发布流水线保险：GitHub Release 移至最后/draft-then-publish；PR 步骤加 tag+非 test 守卫；`--tags` 改单 tag 推送 | D1, D4, D3(部分) |
| P0-4 | `sed -i ''` → 可移植形式 | D2 |
| P0-5 | Universe 合规二连：README thumbnail 引用改绝对 URL、description 重写 | 第 9 节 |
| P0-6 | ucla.png 换成虚构校徽（与 ABC/XYZ/PQR 同风格） | T3 |

### P1 — 短期（1-2 周内，每项 S-M）

| 项 | 动作 | 覆盖发现 |
|---|---|---|
| P1-1 | **注入功能决策**（第 8 节方案 A 或 B）并执行 | ~6 条发现 |
| P1-2 | CI 卫生包：compile.yaml push 限 main + 全 workflow concurrency 组 + compile pin `typst-version: 0.14.0`（floor 证明）+ documentation.yaml 加 PR build-only + `typst compile docs/pdf/docs.typ` 冒烟 | D5, D6, D8, G3(短期) |
| P1-3 | `just release` 加 `just test` 门禁 | D3 |
| P1-4 | 三个 3 行守卫：datetime.today() grep、5-profile 键集 parity、PUBLIC_FUNCTIONS 相等性 | 6.1-2/3/4 |
| P1-5 | "指引随 init 旅行"：template/cv.typ+letter.typ 顶部字体注释块（含 typst.app 说明）、profile_zh 内联 Heiti SC/Noto 注释 | T4, T5, 三年 FontAwesome 顽疾 |
| P1-6 | shipped 资产瘦身（oxipng + 降采样，2.4MB → 目标 <800KB） | T9 |
| P1-7 | YAML issue forms | G2 |
| P1-8 | cv-publication 双分支 component 测试 + 小 .bib fixture | 6.1-1 |
| P1-9 | 内容小修：de/it 学士日期、fr/de/it/zh 补第二个 continued 角色、CONTRIBUTING/migration 两处一行修正、schema fix-or-delete（font_size/location/paper_size/required） | T6, T7, G4, G5, 3.2 |

### P2 — 中期（1-2 月）

| 项 | 动作 |
|---|---|
| P2-1 | git-cliff CHANGELOG + release 附每 profile 样例 PDF（Docker 测试构建已在编译，近零边际成本；竞品 modern-cv 已这么做） |
| P2-2 | sponsors.yaml 降权到 GITHUB_TOKEN + dependabot(github-actions) + action SHA-pin |
| P2-3 | tidy 迁移 spike：能否退役 376 行 Python 解析器 |
| P2-4 | 覆盖缺口清扫（照片双栏 header 合成图 fixture、header_align、us-letter、color: 覆盖、footer、skill 0 级）+ test-fast 去 utpm 依赖 + 死 fixture 清理 + 根 .gitignore 补 diff/out |
| P2-5 | zh quickstart（复用 migration.md 现成内容）+ 信件本地化定位说明 + 签名/头像隐私提示 |
| P2-6 | letter() 补 `cv-metadata.update` + `metadata: metadata` 默认参数清理 + 样式闭包去重 + skill 组件 accent 决策 + h-bar doc-comment + `[layout]` 友好报错 |
| P2-7 | Dockerfile：base image digest pin + Noto CJK 字体版本 pin |

### P3 — 观察/决策项（6-12 月视野）

- **compiler floor 决策**：P1-2 的 0.14 门禁若绿，维持 0.14.0 并获得已验证的下限；若想用 0.15 特性（PDF/UA-1 冒烟、变量字体），floor 提升按向后兼容破坏对待，走 minor/major + 迁移说明。
- **Typst 1.0 / edition 机制**：加入 roadmap checkpoint，盯 typst/typst 跟踪 issue。
- **HTML 导出**：观察，不建。
- **typst-community org / Discord**：info 级，不排期。

### 明确不做清单（负 ROI，防止未来误排期）

1. 注入决策前的 ATS parseability 报告 / pdftotext 断言基础设施
2. x86 宽容差视觉测试通道（违背像素确定性设计，只做文档说明）
3. metadata schema 的 CI 校验器（fix-or-delete 即可）
4. 文档站全量翻译（只做 zh quickstart 节选）
5. SECURITY.md / CODE_OF_CONDUCT / PR 模板（当前规模下是仪式性文件）
6. 测试 ref PNG 的 LFS 迁移（2MB 规模远未到；oxipng 顺手即可）

---

## 11. 附注

- **克隆限制**：审计基于 shallow clone（可见 50 commits）；更早历史（含 mintyfrankie/awesomeCV-Typst 时期）通过 GitHub API 与 web 侧证据补充。
- **GitHub 状态快照**（审计时刻）：0 open issues / 0 open PRs；99 个历史 issue；标签/里程碑真实使用；外部 PR 全部最终合入。
- **主要外部依据**：typst/packages docs（manifest/documentation/licensing/tips）、typst/package-check、Typst 0.15 changelog 与 accessible-PDF 博文、tidy/tytanic/typstyle/setup-typst 发布页、RenderCV ATS 报告、typst-neat-cv fork、issue #185/#192 等（完整 URL 见各 agent 原始输出，保存在会话工作目录）。
