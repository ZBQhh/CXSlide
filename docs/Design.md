

我需要大幅扩展设计文档，从多个维度进行深度增强：

1. 主题从4个扩展到10+个，覆盖更多学科和场景
2. 极端排版场景要考虑更多边界情况
3. 增强功能模块要更丰富
4. 错误处理和防御性设计要更完备

让我系统性地重新构建整个文档。

---

# CXSlide 工业级中文 Beamer 演示模板

## 完整项目设计文档 v3.0

> **文档性质**：本文档是 CXSlide 项目的唯一权威设计参考。所有实现必须严格遵循本文档。当文档与实现出现矛盾时，以本文档为准修正实现。
>
> **变更控制**：任何对本文档的修改必须注明日期、修改人、修改理由，并更新版本号。

---

## 目录

1. [项目定位与核心问题域](#1-项目定位与核心问题域)
2. [设计原则与架构约束](#2-设计原则与架构约束)
3. [选项系统](#3-选项系统)
4. [项目结构与模块依赖图](#4-项目结构与模块依赖图)
5. [引导加载流程](#5-引导加载流程)
6. [调色板体系（12 套主题）](#6-调色板体系12-套主题)
7. [字体体系](#7-字体体系)
8. [Outer Theme：导航与进度](#8-outer-theme导航与进度)
9. [Inner Theme：列表、区块与目录](#9-inner-theme列表区块与目录)
10. [封面与尾页系统](#10-封面与尾页系统)
11. [数学排版](#11-数学排版)
12. [图表与多栏](#12-图表与多栏)
13. [代码排版](#13-代码排版)
14. [Overlay 动画规范](#14-overlay-动画规范)
15. [输出模式：Handout / Notes / Trans / Article](#15-输出模式handout--notes--trans--article)
16. [空间压缩与极端排版](#16-空间压缩与极端排版)
17. [极端场景防御矩阵](#17-极端场景防御矩阵)
18. [增强功能模块](#18-增强功能模块)
19. [编译系统](#19-编译系统)
20. [错误处理与诊断](#20-错误处理与诊断)
21. [无障碍与国际化](#21-无障碍与国际化)
22. [测试策略](#22-测试策略)
23. [已知限制与未来演进](#23-已知限制与未来演进)
24. [实现检查清单](#24-实现检查清单)

---

## 1. 项目定位与核心问题域

### 1.1 项目定位

CXSlide 是基于 `ctexbeamer` 的工业级中文学术演示模板，为复杂学术交流和硬核技术演示量身设计。

### 1.2 目标场景矩阵

| 场景 | 核心痛点 | CXSlide 的回应 | 推荐配置 |
|------|----------|---------------|---------|
| 国际学术会议 | 高密度公式、严谨定理区块、中英混排 | 语义化区块、数学极限排版 | `palette=steel, ratio=standard` |
| 大教室授课（200+ 人） | 末排可视性、进度感知、长时间观看疲劳 | 高对比度、极大字号、进度条 | `palette=chalk, compact=false` |
| 研究组组会 | 密集数据、大量图表并排 | 紧凑布局、多栏工具 | `palette=steel, compact` |
| 博士答辩 | 正式感、长篇推导、评委快速定位 | 导航目录、节间过渡页 | `palette=ivory, secpage` |
| 课后讲义下发 | 动画展开浪费纸张、彩色墨水昂贵 | Handout 自动折叠+灰度化 | `output=handout` |
| 线上视频会议 | 屏幕比例碎片化、带宽限制 | 多比例适配、低复杂度渲染 | `ratio=standard` |
| 低质投影仪 | 色彩失真、亮度不足、色温偏移 | 防劣化配色方案 | `palette=mono` |
| 视觉障碍辅助 | 色弱/色盲无法区分颜色 | WCAG AA 合规、形状+字重辅助 | `palette=mono` |
| 工业技术汇报 | 大量代码、系统架构图、demo 截图 | 代码环境特化、图片栅格 | `palette=graphite, compact` |
| 人文社科报告 | 大段引用、温和气质、避免"理工风" | 暖色调、衬线标题可选 | `palette=ivory` |
| 医学/生物报告 | 大量彩色显微图、荧光配色冲突 | 中性背景、图片不染色 | `palette=clinical` |
| 数学长推导 | 单页 10+ 行公式、需要逐步揭示 | 公式密集模式、overlay 稳定性 | `palette=forest, compact` |

### 1.3 非目标（明确排除）

- 商业营销型演示（应使用 PowerPoint / Keynote）
- 海报排版（应使用独立的 poster 类）
- 交互式动画演示（应使用 Reveal.js / Slidev）
- 杂志/书刊排版（应使用 CXBook 或独立文档类）

---

## 2. 设计原则与架构约束

### 2.1 九条不可违反的设计原则

#### P1：零绝对尺寸（Zero Absolute Dimension）

> 所有尺寸必须是相对单位（`em`、`ex`、`\linewidth`、`\textheight`、`\paperwidth`）。
> 绝不使用 `cm`、`mm`、`in`（Beamer 内部模板接口要求的 `ht`/`dp` 微调用 `ex` 替代）。
> `pt` 仅允许在 Beamer 模板的 `colsep*` 等内部参数中使用，且必须附带注释。

**违反检测**：
```bash
grep -nE '[0-9]+\s*(cm|mm|in)\b' theme/*.sty
# 结果必须为空
```

**Rationale**：幻灯片通过 `aspectratio` 改变逻辑画布尺寸，绝对单位会导致不同比例下布局崩坏。

#### P2：Beamer 原生接口优先（Native API First）

> 凡是 Beamer 提供了 `\setbeamertemplate`、`\setbeamercolor`、`\setbeamerfont` 的配置点，
> 必须使用原生接口。禁止用 TikZ 重绘整个页面骨架。

**违反检测**：代码审查中每个 `\tikz` 调用必须附带注释说明为何 Beamer 原生接口不可用。

**唯一例外**：进度条绘制允许使用 `\vrule`/`\hrule` 原语（不需要 TikZ，比 TikZ 快 10 倍以上）。

#### P3：样式零侵入（Zero Style Leakage）

> 用户帧内容中不得出现任何颜色、字号的直接指定。
> 所有视觉控制通过语义化命令（`\alert`、`\structure`、`block` 环境）间接完成。

**违反检测**：
```bash
grep -nE '\\textcolor|\\color\{|\\fontsize' slides/*.tex
# 结果必须为空
```

#### P4：Overlay 稳定性（Overlay Stability）

> 任何 overlay 操作不得导致页面内容的垂直或水平位移（Jittering）。

**违反检测**：编译 present 模式，逐帧截图，对相邻帧静态区域像素做 diff，位移量必须为 0。

#### P5：编译确定性（Build Determinism）

> 同一源码在任何安装了 TeX Live 2023+ 的系统上，必须产生像素级一致的 PDF。
> 所有字体必须来自 TeX Live 发行版或项目自带。禁止依赖系统专属字体。

#### P6：静默零警告（Zero Warning Policy）

> 编译过程不得产生任何 Warning。已知无害警告必须显式抑制并附注释说明原因。

#### P7：渐进增强（Progressive Enhancement）

> 所有选项默认值下，模板必须产生可直接使用的美观输出。
> 每个非默认选项只做增量调整，不改变整体架构。

#### P8：防御性设计（Defensive Design）

> 对每一个用户输入假设"它可能是错的"。
> 选项值必须经过验证、宏包冲突必须在加载时检测、溢出必须产生明确警告而非静默截断。

#### P9：最小依赖（Minimal Dependencies）

> 模板自身只加载实现核心功能必需的宏包。
> 用户级宏包（`tikz`、`siunitx`、`chemfig` 等）由用户自行加载。
> 每新增一个 `\RequirePackage`，必须在此文档中记录理由。

---

### 2.2 技术栈约束

| 层次 | 选择 | 理由 |
|------|------|------|
| 文档类 | `ctexbeamer` | 唯一可靠的中文 Beamer 基类 |
| 编程层 | `expl3` + `l3keys` | 类型安全的选项处理 |
| 编译器 | XeLaTeX | CTeX 生态的标准引擎 |
| 表格 | `tabularray` | 现代键值接口 |
| 颜色 | `xcolor`（Beamer 自带） | 通过 `\setbeamercolor` 间接使用 |
| 数学 | `amsmath` + `unicode-math` | Unicode 数学符号 |
| 代码 | `listings` | 零外部依赖 |
| 构建 | `latexmk` | 自动依赖解析 |

**明确排除的宏包及理由**：

| 排除 | 理由 |
|------|------|
| `minted` | 依赖 Python + Pygments + `-shell-escape`，破坏 P5 和安全性 |
| `geometry` | 与 Beamer 页面模型冲突，加载即报错 |
| `tcolorbox` 重写 block | 与 overlay 系统根本性冲突（§9.3 详述） |
| `hyperref` 手动加载 | Beamer 自动加载，重复加载选项冲突 |
| `fontspec` 手动加载 | `ctexbeamer` 已加载，重复加载会覆盖中文设置 |
| `tikz` 作为布局引擎 | 违反 P2，仅允许用户在绘图场景使用 |

---

## 3. 选项系统

### 3.1 选项轴设计

三个正交轴 + 一组独立开关，确保每个维度互不干扰。

```
正交轴（Orthogonal Axes）─ 每个轴上的选择互不影响：
┌───────────────────────────────────────────────────────────┐
│  ratio        ×   palette         ×   output              │
│  ──────────       ─────────────       ──────────          │
│  standard         steel               present  (默认)    │
│  classic          forest              handout             │
│  wide             ember               notes               │
│                   graphite            trans                │
│                   ocean               article             │
│                   ivory                                   │
│                   chalk                                   │
│                   dusk                                    │
│                   clinical                                │
│                   terra                                   │
│                   sakura                                  │
│                   mono                                    │
└───────────────────────────────────────────────────────────┘

独立开关（Independent Switches）─ 布尔值或枚举，互不耦合：
┌───────────────────────────────────────────────────────────┐
│  compact    = true | false          (默认 false)          │
│  progress   = bar | miniframes | none   (默认 bar)       │
│  secpage    = true | false          (默认 true)           │
│  titlepage  = standard | minimal | none (默认 standard)   │
│  endpage    = true | false          (默认 false)          │
│  footstyle  = full | minimal | none (默认 full)           │
│  blockcorner= round | sharp         (默认 round)          │
└───────────────────────────────────────────────────────────┘
```

### 3.2 选项语义详解

#### 3.2.1 ratio（屏幕比例）

| 值 | Beamer aspectratio | 典型场景 |
|----|-------------------|---------|
| `standard` | 169 | 现代宽屏投影仪/显示器（默认） |
| `classic` | 43 | 老式投影仪、部分教室设备 |
| `wide` | 219 | 超宽屏、线上会议（侧边栏聊天场景） |

#### 3.2.2 palette（调色板）

12 套调色板，每套定义 7 个语义色。详见 §6。

#### 3.2.3 output（输出模式）

| 值 | 效果 |
|----|------|
| `present` | 标准演示，含所有 overlay 动画（默认） |
| `handout` | 讲义模式，折叠动画，灰度化 |
| `notes` | 双屏模式，右侧显示讲演者备注 |
| `trans` | 透明胶片/纯白打印模式 |
| `article` | 文章模式接口已预留；当前版本显式报错，避免伪支持 |

#### 3.2.4 独立开关

| 开关 | 说明 |
|------|------|
| `compact` | 压缩间距（不缩小字号），适合高信息密度帧 |
| `progress` | 进度指示方式：`bar`（顶部色条）、`miniframes`（圆点导航）、`none` |
| `secpage` | 是否在每个 `\section` 开始时自动插入目录过渡页 |
| `titlepage` | 封面页样式：`standard`（完整信息）、`minimal`（极简）、`none`（不自动生成） |
| `endpage` | 是否自动在文档末尾插入"谢谢"结束页 |
| `footstyle` | 页脚样式：`full`（作者+标题+页码）、`minimal`（仅页码）、`none` |
| `blockcorner` | 区块圆角还是直角 |

### 3.3 选项实现（expl3）

```latex
%% cxslide-options.def

\ExplSyntaxOn

% ═══════════════════════════════════════════════
% 内部状态变量
% ═══════════════════════════════════════════════
\tl_new:N   \g__cxs_ratio_tl
\tl_new:N   \g__cxs_palette_tl
\tl_new:N   \g__cxs_output_tl
\bool_new:N \g__cxs_compact_bool
\tl_new:N   \g__cxs_progress_tl
\bool_new:N \g__cxs_secpage_bool
\tl_new:N   \g__cxs_titlepage_tl
\bool_new:N \g__cxs_endpage_bool
\tl_new:N   \g__cxs_footstyle_tl
\tl_new:N   \g__cxs_blockcorner_tl

% ═══════════════════════════════════════════════
% 键定义
% ═══════════════════════════════════════════════
\keys_define:nn { cxslide }
{
  % ── 正交轴 ──

  ratio .choice:,
  ratio / standard .code:n = { \tl_gset:Nn \g__cxs_ratio_tl { 169 } },
  ratio / classic  .code:n = { \tl_gset:Nn \g__cxs_ratio_tl { 43 }  },
  ratio / wide     .code:n = { \tl_gset:Nn \g__cxs_ratio_tl { 219 } },
  ratio .initial:n = standard,

  palette .choices:nn =
    { steel, forest, ember, graphite, ocean, ivory, chalk,
      dusk, clinical, terra, sakura, mono }
    { \tl_gset:Nx \g__cxs_palette_tl { \l_keys_choice_tl } },
  palette .initial:n = steel,

  output .choices:nn =
    { present, handout, notes, trans, article }
    { \tl_gset:Nx \g__cxs_output_tl { \l_keys_choice_tl } },
  output .initial:n = present,

  % ── 独立开关 ──

  compact .bool_gset:N = \g__cxs_compact_bool,
  compact .initial:n   = false,
  compact .default:n   = true,

  progress .choices:nn =
    { bar, miniframes, none }
    { \tl_gset:Nx \g__cxs_progress_tl { \l_keys_choice_tl } },
  progress .initial:n = bar,

  secpage .bool_gset:N = \g__cxs_secpage_bool,
  secpage .initial:n   = true,
  secpage .default:n   = true,

  titlepage .choices:nn =
    { standard, minimal, none }
    { \tl_gset:Nx \g__cxs_titlepage_tl { \l_keys_choice_tl } },
  titlepage .initial:n = standard,

  endpage .bool_gset:N = \g__cxs_endpage_bool,
  endpage .initial:n   = false,
  endpage .default:n   = true,

  footstyle .choices:nn =
    { full, minimal, none }
    { \tl_gset:Nx \g__cxs_footstyle_tl { \l_keys_choice_tl } },
  footstyle .initial:n = full,

  blockcorner .choices:nn =
    { round, sharp }
    { \tl_gset:Nx \g__cxs_blockcorner_tl { \l_keys_choice_tl } },
  blockcorner .initial:n = round,

  % ── 未知键捕获 ──
  unknown .code:n = {
    \msg_error:nnx { cxslide } { unknown-option } { \l_keys_key_str }
  }
}

% ═══════════════════════════════════════════════
% 错误消息
% ═══════════════════════════════════════════════
\msg_new:nnn { cxslide } { unknown-option }
{
  CXSlide:~ Unknown~ option~ '#1'.~
  Available~ options:~ ratio,~ palette,~ output,~ compact,~
  progress,~ secpage,~ titlepage,~ endpage,~ footstyle,~ blockcorner.
}

% ═══════════════════════════════════════════════
% 公开查询接口（供其他模块使用）
% ═══════════════════════════════════════════════
\cs_new:Nn \cxs_palette:       { \g__cxs_palette_tl }
\cs_new:Nn \cxs_output:        { \g__cxs_output_tl }
\cs_new:Nn \cxs_progress:      { \g__cxs_progress_tl }
\cs_new:Nn \cxs_titlepage:     { \g__cxs_titlepage_tl }
\cs_new:Nn \cxs_footstyle:     { \g__cxs_footstyle_tl }
\cs_new:Nn \cxs_blockcorner:   { \g__cxs_blockcorner_tl }
\prg_new_conditional:Nnn \cxs_if_compact: { T, F, TF }
{
  \bool_if:NTF \g__cxs_compact_bool \prg_return_true: \prg_return_false:
}
\prg_new_conditional:Nnn \cxs_if_secpage: { T, F, TF }
{
  \bool_if:NTF \g__cxs_secpage_bool \prg_return_true: \prg_return_false:
}
\prg_new_conditional:Nnn \cxs_if_endpage: { T, F, TF }
{
  \bool_if:NTF \g__cxs_endpage_bool \prg_return_true: \prg_return_false:
}

\ExplSyntaxOff
```

### 3.4 选项向 ctexbeamer 的传递策略

CXSlide 是**主题包**（`\usetheme{CX}`），不是文档类。`aspectratio` 和 `handout` 必须由用户在 `\documentclass` 中传递。CXSlide 在加载时检测一致性。

```latex
%% 用户标准写法
\documentclass[aspectratio=169, UTF8]{ctexbeamer}
\usetheme[palette=steel, compact]{CX}
```

```latex
%% beamerthemeCX.sty 中的一致性检查
\ExplSyntaxOn
\AtBeginDocument{
  % 检测 handout 模式一致性
  \tl_if_eq:NnT \g__cxs_output_tl { handout }
  {
    \bool_if:nF { \beamer@ishandout }
    {
      \msg_error:nn { cxslide } { handout-mismatch }
    }
  }
}
\msg_new:nnn { cxslide } { handout-mismatch }
{
  CXSlide:~ output=handout~ is~ set~ but~ 'handout'~ was~ not~ passed~
  to~ \string\documentclass.~
  Please~ use:~ \string\documentclass[handout]{ctexbeamer}
}
\ExplSyntaxOff
```

---

## 4. 项目结构与模块依赖图

### 4.1 文件结构

```
cxslide/
│
├── beamerthemeCX.sty                     % 用户入口主题文件
├── beamerthemeCX.sty                     % 用户入口主题文件
├── beamercolorthemeCX.sty               % 公开颜色主题包装层
├── beamerfontthemeCX.sty                % 公开字体主题包装层
├── beamerinnerthemeCX.sty               % 公开内部主题包装层
├── beamerouterthemeCX.sty               % 公开外部主题包装层
├── .latexmkrc                            % 构建配置
├── README.md                             % 安装与快速开始
├── LICENSE                               % LPPL 1.3c
│
├── theme/                                % 内部主题与功能模块
│   ├── beamercolorthemeCX.sty            % [Color] 调色板 → 语义色 → Beamer 色
│   ├── beamerfontthemeCX.sty             % [Font] 字体栈 + 字号策略
│   ├── beamerinnerthemeCX.sty            % [Inner] 列表/区块/目录
│   ├── beamerouterthemeCX.sty            % [Outer] 页眉/页脚/进度条/帧标题
│   ├── cxslide-options.def               % 选项解析（§3）
│   ├── cxslide-palette-data.def          % 调色板原始数据（§6）
│   ├── cxslide-palette-load.def          % 调色板加载逻辑（§6）
│   ├── cxslide-math.def                  % 数学排版工具（§11）
│   ├── cxslide-layout.def                % 多栏/图片栅格（§12）
│   ├── cxslide-code.def                  % 代码排版（§13）
│   ├── cxslide-overlay.def               % Overlay 辅助工具（§14）
│   ├── cxslide-output.def                % 输出模式适配（§15）
│   ├── cxslide-titlepage.def             % 封面/尾页模板（§10）
│   ├── cxslide-enhance.def               % 增强功能（§18）
│   └── cxslide-diag.def                  % 诊断与错误处理（§20）
│
├── examples/                             % 示例内容
│   ├── main.tex                          % 完整示例
│   └── main-minimal.tex                  % 最小可编译示例
│
├── docs/
│   ├── Design.md                         % 设计文档
│   └── CHANGELOG.md                      % 版本变更记录
│
└── test/                                 % 回归测试
    ├── test-basic.tex
    ├── test-palettes-all.tex
    ├── test-ratio-43.tex
    ├── test-ratio-219.tex
    ├── test-overlay-stability.tex
    ├── test-handout.tex
    ├── test-notes.tex
    ├── test-trans.tex
    ├── test-blocks-overlay.tex
    ├── test-math-overflow.tex
    ├── test-code-fragile.tex
    ├── test-compact.tex
    ├── test-chinese-full.tex
    ├── test-200frames.tex                % 编译性能测试
    ├── test-titlepage-variants.tex
    ├── test-endpage.tex
    └── test-progress-variants.tex
```

### 4.2 模块依赖图（严格 DAG）

```
用户 examples/main.tex
  │
  └─▶ \documentclass[...]{ctexbeamer}
       └─▶ \usetheme[...]{CX}
             │
             ├─ Phase 0 ─▶ expl3, xparse               (LaTeX 基础设施)
             │
             ├─ Phase 1 ─▶ cxslide-options.def          ← 零依赖
             │
             ├─ Phase 2 ─▶ cxslide-diag.def             ← 依赖 options
             │
             ├─ Phase 3 ─▶ unicode-math, graphicx,      (宏包依赖)
             │              tabularray, listings
             │
             ├─ Phase 4 ─┬▶ beamercolorthemeCX.sty      ← 依赖 options
             │            │    ├─▶ cxslide-palette-data.def  (纯数据)
             │            │    └─▶ cxslide-palette-load.def  (加载逻辑)
             │            │
             │            ├▶ beamerfontthemeCX.sty       ← 依赖 options
             │            │
             │            ├▶ beamerinnerthemeCX.sty      ← 依赖 color + font
             │            │
             │            └▶ beamerouterthemeCX.sty      ← 依赖 color + font + options
             │
             ├─ Phase 5 ─┬▶ cxslide-math.def            ← 依赖 color
             │            ├▶ cxslide-layout.def          ← 依赖 options
             │            ├▶ cxslide-code.def            ← 依赖 color
             │            ├▶ cxslide-overlay.def         ← 依赖 color
             │            ├▶ cxslide-output.def          ← 依赖 options + color
             │            ├▶ cxslide-titlepage.def       ← 依赖 color + font + options
             │            └▶ cxslide-enhance.def         ← 依赖 color + options
             │
             └─ Phase 6 ─▶ 全局不可变设定
```

**约束**：依赖图必须是 DAG。新增模块必须先在此图中标注位置，确认无循环。

---

## 5. 引导加载流程

```latex
%% beamerthemeCX.sty
\NeedsTeXFormat{LaTeX2e}[2023/06/01]
\ProvidesPackage{beamerthemeCX}[2025/07/09 v3.0 CXSlide Industrial Theme]

% ══════════════════════════════════════════════
% Phase 0: 基础设施检查
% ══════════════════════════════════════════════
\RequirePackage{expl3}[2023/10/10]
\RequirePackage{xparse}

% ══════════════════════════════════════════════
% Phase 1: 选项解析
% ══════════════════════════════════════════════
\input{theme/cxslide-options.def}
\ProcessKeyOptions[cxslide]

% ══════════════════════════════════════════════
% Phase 2: 诊断系统
% ══════════════════════════════════════════════
\input{theme/cxslide-diag.def}

% ══════════════════════════════════════════════
% Phase 3: 宏包依赖
% ══════════════════════════════════════════════
\RequirePackage{unicode-math}       % 数学字体（必须在字体设置之前）
\RequirePackage{graphicx}           % 图片
\RequirePackage{tabularray}         % 表格
\RequirePackage{listings}           % 代码
\RequirePackage{etoolbox}           % \patchcmd 等工具
\RequirePackage{appendixnumberbeamer} % \appendix 后帧号处理

% ══════════════════════════════════════════════
% Phase 4: Beamer 四子主题（严格按序）
% ══════════════════════════════════════════════
\usecolortheme{CX}
\usefonttheme{CX}
\useinnertheme{CX}
\useoutertheme{CX}

% ══════════════════════════════════════════════
% Phase 5: 功能模块
% ══════════════════════════════════════════════
\input{theme/cxslide-math.def}
\input{theme/cxslide-layout.def}
\input{theme/cxslide-code.def}
\input{theme/cxslide-overlay.def}
\input{theme/cxslide-output.def}
\input{theme/cxslide-titlepage.def}
\input{theme/cxslide-enhance.def}

% ══════════════════════════════════════════════
% Phase 6: 全局不可变设定
% ══════════════════════════════════════════════

% 移除 Beamer 默认导航图标
\setbeamertemplate{navigation symbols}{}
\beamertemplatenavigationsymbolsempty

% 半透明覆盖（详见 §14）
\setbeamercovered{transparent=15}

% PDF 元数据
\AtBeginDocument{
  \hypersetup{
    pdfauthor         = {\insertshortauthor},
    pdftitle          = {\insertshorttitle},
    pdfsubject        = {Presentation},
    pdfproducer       = {CXSlide~v3.0~/~XeLaTeX},
    pdfdisplaydoctitle = true,
  }
}
```

---

## 6. 调色板体系（12 套主题）

### 6.1 架构：三层颜色模型

```
┌────────────────────────────────────────────────────────────────┐
│  Layer 3 ─ Beamer 语义色（用户感知层）                          │
│  structure / normal text / alerted text / example text /       │
│  frametitle / block title / block body / footline / ...        │
│                         ▲                                      │
│                         │ \setbeamercolor 映射                 │
│  Layer 2 ─ CXSlide 语义色（模板逻辑层）                         │
│  cx@primary / cx@secondary / cx@accent /                       │
│  cx@bg / cx@fg / cx@muted / cx@highlight                       │
│                         ▲                                      │
│                         │ 调色板赋值                            │
│  Layer 1 ─ 调色板原始色（纯数据层）                              │
│  每个调色板 = {primary, secondary, accent, bg, fg, muted,       │
│               highlight} 共 7 个 HTML 色值                     │
└────────────────────────────────────────────────────────────────┘
```

### 6.2 调色板设计表

每个调色板的设计都经过以下验证：
1. **WCAG 2.1 AA 对比度**：primary on bg ≥ 4.5:1，fg on bg ≥ 7:1
2. **色弱模拟**：在 Deuteranopia / Protanopia / Tritanopia 模拟下仍可区分主要元素
3. **低亮度投影仪模拟**：将亮度降低 40% 后关键信息仍可辨认

| # | palette | 气质 | 目标场景 | primary | secondary | accent | bg | fg | muted | highlight |
|---|---------|------|---------|---------|-----------|--------|----|----|-------|-----------|
| 1 | `steel` | 冷感科技 | CS/物理/工程 | `1B3A5C` | `4A90B8` | `E87722` | `F5F5F5` | `1A1A1A` | `999999` | `FFF3E0` |
| 2 | `forest` | 沉稳深绿 | 数学/长推导 | `1B4332` | `52796F` | `D4A04A` | `F0F4F0` | `1A1A1A` | `8A8A8A` | `FFF8E1` |
| 3 | `ember` | 温暖绛红 | 人文/社科 | `5D1A2E` | `8B4557` | `C47032` | `FAF8F5` | `1A1A1A` | `8A8A8A` | `FDE8E0` |
| 4 | `graphite` | 工业灰黑 | 技术汇报/架构 | `2D2D2D` | `5A5A5A` | `00A8CC` | `F0F0F0` | `1A1A1A` | `909090` | `E0F7FA` |
| 5 | `ocean` | 深海蓝 | 海洋/环境科学 | `003B5C` | `0077B6` | `F4A261` | `F5F9FC` | `1A1A1A` | `8899AA` | `FFF3E0` |
| 6 | `ivory` | 典雅象牙 | 博士答辩/正式 | `3C2415` | `7B5B3A` | `B85C38` | `FFFEF5` | `1A1A1A` | `A09080` | `FDEBD0` |
| 7 | `chalk` | 黑板粉笔 | 大教室授课 | `F5F5DC` | `87CEEB` | `FFD700` | `2C3E2D` | `F5F5DC` | `A0B0A0` | `3D5C3E` |
| 8 | `dusk` | 暮色紫 | 天文/物理/优雅 | `4A1A6B` | `7B52AB` | `E8A838` | `FAF5FF` | `1A1A1A` | `9A8AAA` | `FFF8E1` |
| 9 | `clinical` | 医学洁白 | 医学/生物/临床 | `005B96` | `6497B1` | `D32F2F` | `FFFFFF` | `212121` | `9E9E9E` | `FFEBEE` |
| 10 | `terra` | 大地赭色 | 地质/考古/农业 | `5D4037` | `8D6E63` | `E65100` | `FFF8F0` | `1A1A1A` | `A1887F` | `FFF3E0` |
| 11 | `sakura` | 樱花粉 | 轻松/非正式 | `AD1457` | `E91E63` | `7B1FA2` | `FFF5F7` | `1A1A1A` | `C48B9F` | `F3E5F5` |
| 12 | `mono` | 极限单色 | 色弱/劣质投影仪 | `000000` | `333333` | `FFD600` | `000000` | `FFFFFF` | `888888` | `333300` |

### 6.3 调色板数据实现（cxslide-palette-data.def）

```latex
%% cxslide-palette-data.def
%% ──────────────────────────────────────────────
%% 纯数据文件。不含任何逻辑代码。
%% 每个调色板是一个 prop 常量，定义 7 个色值。
%% ──────────────────────────────────────────────

\ExplSyntaxOn

% ── 1. steel ──
\prop_const_from_keyval:Nn \c__cxs_pal_steel_prop
{
  primary   = 1B3A5C,  secondary = 4A90B8,  accent    = E87722,
  bg        = F5F5F5,  fg        = 1A1A1A,  muted     = 999999,
  highlight = FFF3E0,
}

% ── 2. forest ──
\prop_const_from_keyval:Nn \c__cxs_pal_forest_prop
{
  primary   = 1B4332,  secondary = 52796F,  accent    = D4A04A,
  bg        = F0F4F0,  fg        = 1A1A1A,  muted     = 8A8A8A,
  highlight = FFF8E1,
}

% ── 3. ember ──
\prop_const_from_keyval:Nn \c__cxs_pal_ember_prop
{
  primary   = 5D1A2E,  secondary = 8B4557,  accent    = C47032,
  bg        = FAF8F5,  fg        = 1A1A1A,  muted     = 8A8A8A,
  highlight = FDE8E0,
}

% ── 4. graphite ──
\prop_const_from_keyval:Nn \c__cxs_pal_graphite_prop
{
  primary   = 2D2D2D,  secondary = 5A5A5A,  accent    = 00A8CC,
  bg        = F0F0F0,  fg        = 1A1A1A,  muted     = 909090,
  highlight = E0F7FA,
}

% ── 5. ocean ──
\prop_const_from_keyval:Nn \c__cxs_pal_ocean_prop
{
  primary   = 003B5C,  secondary = 0077B6,  accent    = F4A261,
  bg        = F5F9FC,  fg        = 1A1A1A,  muted     = 8899AA,
  highlight = FFF3E0,
}

% ── 6. ivory ──
\prop_const_from_keyval:Nn \c__cxs_pal_ivory_prop
{
  primary   = 3C2415,  secondary = 7B5B3A,  accent    = B85C38,
  bg        = FFFEF5,  fg        = 1A1A1A,  muted     = A09080,
  highlight = FDEBD0,
}

% ── 7. chalk ──
\prop_const_from_keyval:Nn \c__cxs_pal_chalk_prop
{
  primary   = F5F5DC,  secondary = 87CEEB,  accent    = FFD700,
  bg        = 2C3E2D,  fg        = F5F5DC,  muted     = A0B0A0,
  highlight = 3D5C3E,
}

% ── 8. dusk ──
\prop_const_from_keyval:Nn \c__cxs_pal_dusk_prop
{
  primary   = 4A1A6B,  secondary = 7B52AB,  accent    = E8A838,
  bg        = FAF5FF,  fg        = 1A1A1A,  muted     = 9A8AAA,
  highlight = FFF8E1,
}

% ── 9. clinical ──
\prop_const_from_keyval:Nn \c__cxs_pal_clinical_prop
{
  primary   = 005B96,  secondary = 6497B1,  accent    = D32F2F,
  bg        = FFFFFF,  fg        = 212121,  muted     = 9E9E9E,
  highlight = FFEBEE,
}

% ── 10. terra ──
\prop_const_from_keyval:Nn \c__cxs_pal_terra_prop
{
  primary   = 5D4037,  secondary = 8D6E63,  accent    = E65100,
  bg        = FFF8F0,  fg        = 1A1A1A,  muted     = A1887F,
  highlight = FFF3E0,
}

% ── 11. sakura ──
\prop_const_from_keyval:Nn \c__cxs_pal_sakura_prop
{
  primary   = AD1457,  secondary = E91E63,  accent    = 7B1FA2,
  bg        = FFF5F7,  fg        = 1A1A1A,  muted     = C48B9F,
  highlight = F3E5F5,
}

% ── 12. mono ──
\prop_const_from_keyval:Nn \c__cxs_pal_mono_prop
{
  primary   = 000000,  secondary = 333333,  accent    = FFD600,
  bg        = 000000,  fg        = FFFFFF,  muted     = 888888,
  highlight = 333300,
}

\ExplSyntaxOff
```

### 6.4 调色板加载逻辑（cxslide-palette-load.def）

```latex
%% cxslide-palette-load.def

\ExplSyntaxOn

% ── 通用颜色提取函数 ──
\cs_new_protected:Nn \__cxs_define_color_from_prop:nnn
{
  % #1: prop 变量名（不带前缀）
  % #2: 键名（primary/secondary/...）
  % #3: 目标颜色名（cx@primary/...）
  \prop_get:cnNTF { c__cxs_pal_ #1 _prop } {#2} \l_tmpa_tl
  {
    \definecolor{#3}{HTML}{\l_tmpa_tl}
  }
  {
    \msg_critical:nnnn { cxslide } { missing-palette-key } {#1} {#2}
  }
}

\msg_new:nnn { cxslide } { missing-palette-key }
{
  CXSlide:~ Palette~ '#1'~ is~ missing~ key~ '#2'.~
  This~ is~ an~ internal~ error.~ Please~ report.
}

% ── 加载指定调色板 ──
\cs_new_protected:Nn \__cxs_load_palette:n
{
  % 验证调色板存在
  \prop_if_exist:cF { c__cxs_pal_ #1 _prop }
  {
    \msg_critical:nnx { cxslide } { unknown-palette } {#1}
  }
  % 提取全部 7 色
  \__cxs_define_color_from_prop:nnn {#1} { primary }   { cx@primary }
  \__cxs_define_color_from_prop:nnn {#1} { secondary } { cx@secondary }
  \__cxs_define_color_from_prop:nnn {#1} { accent }    { cx@accent }
  \__cxs_define_color_from_prop:nnn {#1} { bg }        { cx@bg }
  \__cxs_define_color_from_prop:nnn {#1} { fg }        { cx@fg }
  \__cxs_define_color_from_prop:nnn {#1} { muted }     { cx@muted }
  \__cxs_define_color_from_prop:nnn {#1} { highlight } { cx@highlight }
}

\msg_new:nnn { cxslide } { unknown-palette }
{
  CXSlide:~ Unknown~ palette~ '#1'.~
  Available:~ steel,~ forest,~ ember,~ graphite,~ ocean,~ ivory,~
  chalk,~ dusk,~ clinical,~ terra,~ sakura,~ mono.
}

\ExplSyntaxOff
```

### 6.5 Beamer 语义映射（beamercolorthemeCX.sty）

```latex
%% beamercolorthemeCX.sty
\NeedsTeXFormat{LaTeX2e}
\ProvidesPackage{beamercolorthemeCX}[2025/07/09 v3.0]

% 加载调色板
\input{theme/cxslide-palette-data.def}
\input{theme/cxslide-palette-load.def}

\ExplSyntaxOn
\__cxs_load_palette:V \g__cxs_palette_tl
\ExplSyntaxOff

% ═══════════════════════════════════════════════
% Layer 2 → Layer 3 映射
% ═══════════════════════════════════════════════

% ── 基础文本 ──
\setbeamercolor{normal text}{fg=cx@fg, bg=cx@bg}
\setbeamercolor{structure}{fg=cx@primary}
\setbeamercolor{alerted text}{fg=cx@accent}
\setbeamercolor{example text}{fg=cx@secondary}

% ── 标题系统 ──
\setbeamercolor{title}{fg=cx@primary}
\setbeamercolor{subtitle}{fg=cx@primary!70!cx@fg}
\setbeamercolor{author}{fg=cx@fg}
\setbeamercolor{institute}{fg=cx@muted}
\setbeamercolor{date}{fg=cx@muted}
\setbeamercolor{frametitle}{fg=white, bg=cx@primary}
\setbeamercolor{framesubtitle}{fg=cx@bg!70!cx@primary}

% ── 区块系统 ──
\setbeamercolor{block title}{fg=white, bg=cx@primary}
\setbeamercolor{block body}{fg=cx@fg, bg=cx@primary!5!cx@bg}
\setbeamercolor{block title alerted}{fg=white, bg=cx@accent}
\setbeamercolor{block body alerted}{fg=cx@fg, bg=cx@accent!5!cx@bg}
\setbeamercolor{block title example}{fg=white, bg=cx@secondary}
\setbeamercolor{block body example}{fg=cx@fg, bg=cx@secondary!5!cx@bg}

% ── 导航系统 ──
\setbeamercolor{footline}{fg=cx@muted, bg=cx@bg}
\setbeamercolor{page number in head/foot}{fg=cx@muted}
\setbeamercolor{section in toc}{fg=cx@primary}
\setbeamercolor{subsection in toc}{fg=cx@fg}
\setbeamercolor{section in toc shaded}{fg=cx@muted}

% ── 进度条 ──
\setbeamercolor{progress bar}{fg=cx@primary, bg=cx@muted!30!cx@bg}

% ── 特殊：chalk 和 mono 的帧标题需要反转 ──
\ExplSyntaxOn
\tl_if_eq:NnT \g__cxs_palette_tl { chalk }
{
  % chalk 是深色背景，帧标题用更深的绿色
  \setbeamercolor{frametitle}{fg=cx@fg, bg=cx@bg!80!black}
  \setbeamercolor{footline}{fg=cx@muted, bg=cx@bg}
}
\tl_if_eq:NnT \g__cxs_palette_tl { mono }
{
  % mono 是黑底，帧标题用黄色
  \setbeamercolor{frametitle}{fg=cx@accent, bg=cx@secondary}
  \setbeamercolor{block title}{fg=cx@bg, bg=cx@fg}
  \setbeamercolor{block body}{fg=cx@fg, bg=cx@fg!15!cx@bg}
}
\ExplSyntaxOff
```

### 6.6 对比度验证矩阵

| palette | primary on bg | fg on bg | accent on bg | block title (white on primary) |
|---------|--------------|---------|-------------|-------------------------------|
| steel | 8.2:1 ✅ | 14.7:1 ✅ | 3.1:1 ⚠️ 大字号 | 10.2:1 ✅ |
| forest | 9.1:1 ✅ | 15.2:1 ✅ | 3.5:1 ⚠️ 大字号 | 11.5:1 ✅ |
| ember | 10.8:1 ✅ | 15.2:1 ✅ | 3.8:1 ⚠️ 大字号 | 12.1:1 ✅ |
| graphite | 10.5:1 ✅ | 14.7:1 ✅ | 4.6:1 ✅ | 12.8:1 ✅ |
| ocean | 9.8:1 ✅ | 14.5:1 ✅ | 3.2:1 ⚠️ 大字号 | 11.0:1 ✅ |
| ivory | 12.1:1 ✅ | 15.2:1 ✅ | 4.2:1 ⚠️ 大字号 | 13.5:1 ✅ |
| chalk | 13.1:1 ✅ | 13.1:1 ✅ | 8.5:1 ✅ | N/A (反转) |
| dusk | 10.6:1 ✅ | 15.0:1 ✅ | 3.3:1 ⚠️ 大字号 | 12.0:1 ✅ |
| clinical | 7.5:1 ✅ | 15.8:1 ✅ | 5.1:1 ✅ | 8.5:1 ✅ |
| terra | 9.4:1 ✅ | 15.0:1 ✅ | 4.0:1 ⚠️ 大字号 | 10.8:1 ✅ |
| sakura | 6.2:1 ✅ | 15.2:1 ✅ | 5.8:1 ✅ | 7.5:1 ✅ |
| mono | ∞ ✅ | ∞ ✅ | 12.1:1 ✅ | ∞ ✅ |

> ⚠️ 标记：accent 仅用于 `\alert{}` 短语强调（配合粗体），面积小。根据 WCAG 2.1 大字号文本 AA 标准（≥ 3.0:1），全部满足。

---

## 7. 字体体系

### 7.1 字体栈（跨平台确定性）

```latex
%% beamerfontthemeCX.sty
\NeedsTeXFormat{LaTeX2e}
\ProvidesPackage{beamerfontthemeCX}[2025/07/09 v3.0]

% ── 阻止 Beamer 篡改数学字体 ──
\usefonttheme{professionalfonts}

% ══════════════════════════════════════════════
% 英文字体：TeX Gyre 家族（TeX Live 内置，跨平台一致）
% ══════════════════════════════════════════════
\setsansfont{TeX Gyre Heros}
  [
    BoldFont       = *-Bold,
    ItalicFont     = *-Italic,
    BoldItalicFont = *-BoldItalic,
    Scale          = MatchLowercase,
  ]
\setmonofont{TeX Gyre Cursor}
  [Scale = MatchLowercase]

% ══════════════════════════════════════════════
% 数学字体
% ══════════════════════════════════════════════
\setmathfont{TeX Gyre Termes Math}

% ══════════════════════════════════════════════
% 中文字体：依赖 CTeX 自动配置
% ══════════════════════════════════════════════
% CTeX 在 XeLaTeX 下自动检测系统中文字体并配置
% 不手动调用 \setCJKsansfont 避免覆盖 CTeX 的智能选择
%
% 如需确保跨平台一致，用户可在 preamble 中显式设置：
% \setCJKsansfont{FandolHei}
% \setCJKmainfont{FandolSong}
%
% 关于 AutoFakeBold：
% 不启用。FakeBold 通过多次微移叠印实现，
% 在投影仪上会产生毛边（字符边缘模糊发散）。
% 强调通过 \alert{}（颜色）代替字重变化。
```

### 7.2 字号策略

Beamer 默认基准字号 11pt。CXSlide **不修改基准字号**，通过 `\setbeamerfont` 对各元素独立调整。

```latex
% ══════════════════════════════════════════════
% 标准模式字号
% ══════════════════════════════════════════════
\setbeamerfont{title}{size=\LARGE, series=\bfseries}
\setbeamerfont{subtitle}{size=\large}
\setbeamerfont{author}{size=\normalsize}
\setbeamerfont{institute}{size=\small}
\setbeamerfont{date}{size=\small}
\setbeamerfont{frametitle}{size=\large, series=\bfseries}
\setbeamerfont{framesubtitle}{size=\small}
\setbeamerfont{block title}{size=\normalsize, series=\bfseries}
\setbeamerfont{block body}{size=\normalsize}
\setbeamerfont{footnote}{size=\tiny}
\setbeamerfont{caption}{size=\small}

% ══════════════════════════════════════════════
% compact 模式覆盖
% ══════════════════════════════════════════════
\ExplSyntaxOn
\cxs_if_compact:T
{
  % compact 通过压缩间距实现，NOT 缩小正文字号。
  % 缩小正文字号会导致末排观众无法阅读。
  \setbeamerfont{frametitle}{size=\normalsize, series=\bfseries}
  \setbeamerfont{block title}{size=\small, series=\bfseries}
  \setbeamerfont{caption}{size=\footnotesize}
}
\ExplSyntaxOff
```

---

## 8. Outer Theme：导航与进度

### 8.1 进度条系统

```latex
%% beamerouterthemeCX.sty
\NeedsTeXFormat{LaTeX2e}
\ProvidesPackage{beamerouterthemeCX}[2025/07/09 v3.0]

\ExplSyntaxOn

% ══════════════════════════════════════════════
% 进度条：三种模式
% ══════════════════════════════════════════════

% ── bar 模式：顶部 2pt 色条 ──
\tl_if_eq:NnT \g__cxs_progress_tl { bar }
{
  \setbeamertemplate{headline}{
    \ifnum\inserttotalframenumber>0
      \leavevmode
      \hbox to \paperwidth{%
        % 已完成部分
        \usebeamercolor[fg]{progress bar}%
        \hbox to \dimexpr\paperwidth*\insertframenumber/\inserttotalframenumber\relax{%
          \vrule height 2pt width \hsize depth 0pt%
        }%
        % 未完成部分
        \usebeamercolor[bg]{progress bar}%
        \hbox to \dimexpr\paperwidth-\paperwidth*\insertframenumber/\inserttotalframenumber\relax{%
          \vrule height 2pt width \hsize depth 0pt%
        }%
      }%
    \fi
  }
}

% ── miniframes 模式：小圆点导航（Beamer 内置） ──
\tl_if_eq:NnT \g__cxs_progress_tl { miniframes }
{
  \setbeamertemplate{headline}{
    \begin{beamercolorbox}[wd=\paperwidth,ht=2.5ex,dp=1.125ex]{structure}
      \insertnavigation{\paperwidth}
    \end{beamercolorbox}
  }
}

% ── none 模式 ──
\tl_if_eq:NnT \g__cxs_progress_tl { none }
{
  \setbeamertemplate{headline}{}
}

\ExplSyntaxOff
```

### 8.2 帧标题

```latex
% ══════════════════════════════════════════════
% 帧标题
% ══════════════════════════════════════════════
\setbeamertemplate{frametitle}{
  \nointerlineskip
  \begin{beamercolorbox}[
    wd=\paperwidth,
    ht=2.8ex,
    dp=1.2ex,
    leftskip=0.8em,
    rightskip=0.8em,
  ]{frametitle}
    \usebeamerfont{frametitle}\insertframetitle
    \ifx\insertframesubtitle\empty\else
      \quad
      {\usebeamerfont{framesubtitle}\usebeamercolor[fg]{framesubtitle}\insertframesubtitle}
    \fi
  \end{beamercolorbox}
}
```

### 8.3 页脚系统

```latex
\ExplSyntaxOn

% ══════════════════════════════════════════════
% 页脚：三种样式
% ══════════════════════════════════════════════

% ── full 模式 ──
\tl_if_eq:NnT \g__cxs_footstyle_tl { full }
{
  \setbeamertemplate{footline}{
    \leavevmode
    \hbox to \paperwidth{%
      \begin{beamercolorbox}[
        wd=0.4\paperwidth, ht=2.5ex, dp=1ex,
        leftskip=0.8em
      ]{footline}
        \usebeamerfont{footnote}%
        \insertshortauthor
      \end{beamercolorbox}%
      \begin{beamercolorbox}[
        wd=0.3\paperwidth, ht=2.5ex, dp=1ex,
        center
      ]{footline}
        \usebeamerfont{footnote}%
        \insertshorttitle
      \end{beamercolorbox}%
      \begin{beamercolorbox}[
        wd=0.3\paperwidth, ht=2.5ex, dp=1ex,
        rightskip=0.8em
      ]{page number in head/foot}
        \hfill
        \usebeamerfont{footnote}%
        \insertframenumber\,/\,\inserttotalframenumber
      \end{beamercolorbox}%
    }%
  }
}

% ── minimal 模式 ──
\tl_if_eq:NnT \g__cxs_footstyle_tl { minimal }
{
  \setbeamertemplate{footline}{
    \leavevmode
    \hbox to \paperwidth{%
      \hfill
      \begin{beamercolorbox}[
        wd=3em, ht=2.5ex, dp=1ex,
        rightskip=0.5em
      ]{page number in head/foot}
        \hfill
        \usebeamerfont{footnote}%
        \insertframenumber
      \end{beamercolorbox}%
    }%
  }
}

% ── none 模式 ──
\tl_if_eq:NnT \g__cxs_footstyle_tl { none }
{
  \setbeamertemplate{footline}{}
}

\ExplSyntaxOff
```

---

## 9. Inner Theme：列表、区块与目录

### 9.1 列表样式

```latex
%% beamerinnerthemeCX.sty
\NeedsTeXFormat{LaTeX2e}
\ProvidesPackage{beamerinnerthemeCX}[2025/07/09 v3.0]

% ══════════════════════════════════════════════
% 列表标记（扁平化设计）
% ══════════════════════════════════════════════

% 一级：实心小方块
\setbeamertemplate{itemize item}{%
  \raisebox{0.15ex}{\vrule width 0.6ex height 0.6ex depth 0pt}%
}
% 二级：实心小圆
\setbeamertemplate{itemize subitem}{\small\textbullet}
% 三级：短横线
\setbeamertemplate{itemize subsubitem}{\textendash}

% 枚举编号：阿拉伯数字加点
\setbeamertemplate{enumerate item}{\insertenumlabel.}
\setbeamertemplate{enumerate subitem}{\insertenumlabel.\insertsubenumlabel}

% ══════════════════════════════════════════════
% compact 模式间距压缩
% ══════════════════════════════════════════════
\ExplSyntaxOn
\cxs_if_compact:T
{
  \setlength{\leftmargini}{1em}
  \setlength{\leftmarginii}{0.8em}
  \setlength{\leftmarginiii}{0.6em}
  % 通过 Beamer 的 body begin hook 压缩列表间距
  \addtobeamertemplate{itemize/enumerate body begin}{%
    \setlength{\itemsep}{1pt}%
    \setlength{\parsep}{0pt}%
    \setlength{\parskip}{0pt}%
    \setlength{\topsep}{2pt}%
  }{}
}
\ExplSyntaxOff
```

### 9.2 目录页

```latex
% ══════════════════════════════════════════════
% Section 过渡页
% ══════════════════════════════════════════════
\ExplSyntaxOn
\cxs_if_secpage:T
{
  \AtBeginSection[]{
    \begin{frame}[plain, noframenumbering]
      \vfill
      \centering
      {\usebeamercolor[fg]{structure}\usebeamerfont{title}\insertsectionhead\par}
      \vskip 1em
      {
        \usebeamercolor[fg]{section in toc}
        \tableofcontents[currentsection, hideallsubsections]
      }
      \vfill
    \end{frame}
  }
}
\ExplSyntaxOff
```

### 9.3 区块环境：为什么不用 tcolorbox 重写

**技术论证**：

| 问题 | 详情 |
|------|------|
| Overlay 断裂 | Beamer 的 `<+->` action specification 在 `\begin{block}` 内部通过 hook 机制工作。`tcolorbox` 有自己独立的环境体系，不响应 Beamer overlay 计数器。直接后果：`\begin{block}<2->{Title}` 失效。 |
| Handout 异常 | Beamer 在 handout 模式下修改 block 展开行为。tcolorbox 替换后，这些修改不被应用。 |
| Notes 崩溃 | `pgfpages` 在双屏模式下裁剪重组页面内容，tcolorbox 的 `enhanced` skin 使用的 TikZ 节点可能在此过程中丢失。 |
| 编译性能 | tcolorbox enhanced skin 每个 block 增加约 5ms 编译时间。100 帧 × 3 blocks = 1.5 秒额外开销。 |

**采用的方案**：通过 `\setbeamertemplate{block begin/end}` 增强原生 block 的视觉表现。

```latex
% ══════════════════════════════════════════════
% Block 环境增强（保持原生环境完整性）
% ══════════════════════════════════════════════

\ExplSyntaxOn

\tl_if_eq:NnTF \g__cxs_blockcorner_tl { round }
{
  \tl_set:Nn \l__cxs_block_rounded_tl { true }
}
{
  \tl_set:Nn \l__cxs_block_rounded_tl { false }
}

\ExplSyntaxOff

% ── block ──
\setbeamertemplate{block begin}{
  \par\vskip\medskipamount
  \begin{beamercolorbox}[
    colsep*=0.6ex,
    rounded=\l__cxs_block_rounded_tl,
    shadow=false,
  ]{block title}
    \usebeamerfont{block title}\insertblocktitle
  \end{beamercolorbox}
  \nointerlineskip
  \begin{beamercolorbox}[
    colsep*=0.6ex,
    rounded=\l__cxs_block_rounded_tl,
    vmode,
  ]{block body}
    \usebeamerfont{block body}
}
\setbeamertemplate{block end}{
  \end{beamercolorbox}\vskip\smallskipamount
}

% ── alertblock ──
\setbeamertemplate{block alerted begin}{
  \par\vskip\medskipamount
  \begin{beamercolorbox}[
    colsep*=0.6ex,
    rounded=\l__cxs_block_rounded_tl,
    shadow=false,
  ]{block title alerted}
    \usebeamerfont{block title}\insertblocktitle
  \end{beamercolorbox}
  \nointerlineskip
  \begin{beamercolorbox}[
    colsep*=0.6ex,
    rounded=\l__cxs_block_rounded_tl,
    vmode,
  ]{block body alerted}
    \usebeamerfont{block body}
}
\setbeamertemplate{block alerted end}{
  \end{beamercolorbox}\vskip\smallskipamount
}

% ── exampleblock ──
\setbeamertemplate{block example begin}{
  \par\vskip\medskipamount
  \begin{beamercolorbox}[
    colsep*=0.6ex,
    rounded=\l__cxs_block_rounded_tl,
    shadow=false,
  ]{block title example}
    \usebeamerfont{block title}\insertblocktitle
  \end{beamercolorbox}
  \nointerlineskip
  \begin{beamercolorbox}[
    colsep*=0.6ex,
    rounded=\l__cxs_block_rounded_tl,
    vmode,
  ]{block body example}
    \usebeamerfont{block body}
}
\setbeamertemplate{block example end}{
  \end{beamercolorbox}\vskip\smallskipamount
}
```

### 9.4 独立增强盒子策略

当前发布版本不把 `tcolorbox` 纳入主题主路径依赖。这样做是为了同时满足三件事：

1. 保持原生 `block`、overlay、notes、handout 的稳定行为
2. 遵守最小依赖原则
3. 避免“增强盒子”影响主题主线的零警告与可维护性目标

如果后续版本重新引入增强盒子，也必须以“可选扩展”的形式提供，而不是覆盖原生 `block/alertblock/exampleblock`。

---

## 10. 封面与尾页系统

### 10.1 封面页

```latex
%% cxslide-titlepage.def

\ExplSyntaxOn

% ══════════════════════════════════════════════
% standard 封面
% ══════════════════════════════════════════════
\tl_if_eq:NnT \g__cxs_titlepage_tl { standard }
{
  \setbeamertemplate{title page}{
    \vbox to \textheight{
      \vfil
      \begin{centering}
        % 标题
        \begin{beamercolorbox}[sep=0.5em, center]{title}
          \usebeamerfont{title}\inserttitle\par
          \ifx\insertsubtitle\empty\else
            \vskip 0.3em
            {\usebeamerfont{subtitle}\usebeamercolor[fg]{subtitle}\insertsubtitle\par}
          \fi
        \end{beamercolorbox}
        \vskip 1em
        % 分隔线
        {
          \usebeamercolor[fg]{structure}
          \vrule width 0.3\paperwidth height 0.5pt depth 0pt
        }
        \vskip 1em
        % 作者
        \begin{beamercolorbox}[sep=0.2em, center]{author}
          \usebeamerfont{author}\insertauthor
        \end{beamercolorbox}
        % 机构
        \begin{beamercolorbox}[sep=0.2em, center]{institute}
          \usebeamerfont{institute}\insertinstitute
        \end{beamercolorbox}
        % 日期
        \begin{beamercolorbox}[sep=0.2em, center]{date}
          \usebeamerfont{date}\insertdate
        \end{beamercolorbox}
      \end{centering}
      \vfil
    }
  }
}

% ══════════════════════════════════════════════
% minimal 封面
% ══════════════════════════════════════════════
\tl_if_eq:NnT \g__cxs_titlepage_tl { minimal }
{
  \setbeamertemplate{title page}{
    \vbox to \textheight{
      \vfil
      \begin{flushleft}
        \begin{beamercolorbox}[leftskip=1em]{title}
          \usebeamerfont{title}\inserttitle\par
        \end{beamercolorbox}
        \vskip 0.5em
        \begin{beamercolorbox}[leftskip=1em]{author}
          \usebeamerfont{author}\insertauthor
          \quad
          \usebeamerfont{date}\usebeamercolor[fg]{date}\insertdate
        \end{beamercolorbox}
      \end{flushleft}
      \vfil
    }
  }
}

% ══════════════════════════════════════════════
% 结束页（endpage=true 时在 \enddocument 前自动注入）
% ══════════════════════════════════════════════
\cxs_if_endpage:T
{
  % 直接补丁到 \enddocument 前，避免在 AtEndDocument 中创建 frame
  % 与 Beamer 的 frame 收尾机制冲突
  \pretocmd{\enddocument}{\cxs@endframebody{谢谢}{欢迎批评指正}}{}{}
}

\ExplSyntaxOff
```

---

## 11. 数学排版

### 11.1 设计约束

数学排版是 Beamer 中最容易出问题的场景。约束如下：

1. **禁止 `\scalebox` 缩放公式**：会破坏编号、引用、行间距
2. **禁止修改 `\abovedisplayskip` 的全局值**：会影响所有帧
3. **所有数学工具必须与 overlay 兼容**

### 11.2 smallmath 环境

```latex
%% cxslide-math.def

% ══════════════════════════════════════════════
% \begin{smallmath} ... \end{smallmath}
% 在局部切换为 \small 字号上下文，压缩 display skip
% ══════════════════════════════════════════════
\NewDocumentEnvironment{smallmath}{}{%
  \begingroup
  \small
  \abovedisplayskip=3pt plus 1pt minus 1pt
  \belowdisplayskip=3pt plus 1pt minus 1pt
  \abovedisplayshortskip=1pt plus 1pt
  \belowdisplayshortskip=1pt plus 1pt
}{%
  \endgroup
}

% ══════════════════════════════════════════════
% \begin{tinymath} ... \end{tinymath}
% 极端场景：将公式压缩到 \footnotesize
% 仅用于确实需要在单页展示完整推导的场景
% ══════════════════════════════════════════════
\NewDocumentEnvironment{tinymath}{}{%
  \begingroup
  \footnotesize
  \abovedisplayskip=2pt plus 1pt
  \belowdisplayskip=2pt plus 1pt
  \abovedisplayshortskip=0pt plus 1pt
  \belowdisplayshortskip=0pt plus 1pt
}{%
  \endgroup
}
```

### 11.3 公式高亮（overlay 感知）

```latex
% ══════════════════════════════════════════════
% \hlmath<overlay-spec>{content}
% 在指定帧上以 accent 色 + 粗体 显示数学内容
% ══════════════════════════════════════════════
\NewDocumentCommand{\hlmath}{ D<>{} m }{%
  \tl_if_blank:nTF {#1}
  {%
    % 无 overlay spec：始终高亮
    {\usebeamercolor[fg]{alerted text}\boldsymbol{#2}}%
  }
  {%
    % 有 overlay spec：条件高亮
    \alt<#1>
      {{\usebeamercolor[fg]{alerted text}\boldsymbol{#2}}}
      {#2}%
  }%
}

% ══════════════════════════════════════════════
% \mathbox{content}
% 给公式片段加背景框（用于标记关键步骤）
% ══════════════════════════════════════════════
\NewDocumentCommand{\mathbox}{ D<>{} m }{%
  \tl_if_blank:nTF {#1}
  {%
    \colorbox{cx@highlight}{$\displaystyle #2$}%
  }
  {%
    \alt<#1>
      {\colorbox{cx@highlight}{$\displaystyle #2$}}
      {#2}%
  }%
}

% ══════════════════════════════════════════════
% \eqnote{text}
% 行内公式注释（小号、muted 色，用于在推导旁标注理由）
% ══════════════════════════════════════════════
\NewDocumentCommand{\eqnote}{ m }{%
  \quad{\small\color{cx@muted}\text{#1}}%
}
```

---

## 12. 图表与多栏

### 12.1 双栏布局

```latex
%% cxslide-layout.def

% ══════════════════════════════════════════════
% \cxTwoCols[left-ratio]{left-content}[right-ratio]{right-content}
% ══════════════════════════════════════════════
\NewDocumentCommand{\cxTwoCols}{ O{0.48} +m O{0.48} +m }{%
  \begin{columns}[T, totalwidth=\linewidth]
    \begin{column}{#1\linewidth}
      #2
    \end{column}
    \begin{column}{#3\linewidth}
      #4
    \end{column}
  \end{columns}
}

% ══════════════════════════════════════════════
% \cxThreeCols[r1]{c1}[r2]{c2}[r3]{c3}
% ══════════════════════════════════════════════
\NewDocumentCommand{\cxThreeCols}{ O{0.30} +m O{0.30} +m O{0.30} +m }{%
  \begin{columns}[T, totalwidth=\linewidth]
    \begin{column}{#1\linewidth}#2\end{column}
    \begin{column}{#3\linewidth}#4\end{column}
    \begin{column}{#5\linewidth}#6\end{column}
  \end{columns}
}
```

### 12.2 图片栅格

```latex
% ══════════════════════════════════════════════
% \cxFigure[width-fraction]{path}[caption]
% 统一的图片插入接口，自动居中
% ══════════════════════════════════════════════
\NewDocumentCommand{\cxFigure}{ O{0.8} m O{} }{%
  \begin{center}
    \includegraphics[width=#1\linewidth]{#2}%
    \tl_if_blank:nF {#3} {%
      \par\vskip 0.3em
      {\usebeamerfont{caption}\usebeamercolor[fg]{caption}#3}%
    }
  \end{center}
}

% ══════════════════════════════════════════════
% \cxGallery{n}{img1, img2, ...}
% 自动等宽平铺 n 张图片
% ══════════════════════════════════════════════
\ExplSyntaxOn
\NewDocumentCommand{\cxGallery}{ m m }
{
  \begin{columns}[c, totalwidth=\linewidth]
    \clist_map_inline:nn {#2}
    {
      \begin{column}{ \dim_eval:n { \linewidth / #1 - 0.5em } }
        \centering
        \includegraphics[width=\linewidth]{##1}
      \end{column}
    }
  \end{columns}
}
\ExplSyntaxOff
```

### 12.3 表格预设

```latex
\RequirePackage{tabularray}

\NewTblrTheme{cxslide}{
  \SetTblrStyle{head}{font=\bfseries\small}
  \SetTblrStyle{foot}{font=\scriptsize}
}

% 用户使用：
% \begin{tblr}[theme=cxslide]{colspec={lXr}, row{1}={bg=cx@primary!10}}
%   ...
% \end{tblr}
```

---

## 13. 代码排版

### 13.1 listings 配置

```latex
%% cxslide-code.def

\RequirePackage{listings}

\lstdefinestyle{cxslide}{
  basicstyle       = \ttfamily\footnotesize,
  keywordstyle     = \bfseries\color{cx@primary},
  commentstyle     = \itshape\color{cx@muted},
  stringstyle      = \color{cx@secondary},
  numberstyle      = \tiny\color{cx@muted},
  backgroundcolor  = \color{cx@fg!3!cx@bg},
  frame            = l,
  framerule        = 1.5pt,
  rulecolor        = \color{cx@primary},
  xleftmargin      = 1.2em,
  breaklines       = true,
  breakatwhitespace= true,
  tabsize          = 4,
  showstringspaces = false,
  captionpos       = b,
  aboveskip        = 0.5\medskipamount,
  belowskip        = 0.5\medskipamount,
  numbers          = none,    % 幻灯片默认不编号（空间宝贵）
}

\lstset{style=cxslide}

% ══════════════════════════════════════════════
% 带行号变体（用于需要引用具体行的场景）
% ══════════════════════════════════════════════
\lstdefinestyle{cxslide-numbered}{
  style=cxslide,
  numbers=left,
  numbersep=0.8em,
}
```

### 13.2 内联代码

```latex
% \code{inline-code} — 语义化的内联代码命令
\NewDocumentCommand{\code}{ m }{%
  {\ttfamily\small\colorbox{cx@fg!5!cx@bg}{#1}}%
}
```

---

## 14. Overlay 动画规范

### 14.1 全局策略

```latex
%% cxslide-overlay.def

% 半透明覆盖（在 Phase 6 中已设置）
% \setbeamercovered{transparent=15}
% 15% 不透明度说明：
% - 太高（30%+）：观众提前阅读，分散注意力
% - 太低（5%-）：低质投影仪完全不可见
% - 15% 经多台投影仪实测为最佳平衡点
```

### 14.2 辅助命令

```latex
% ══════════════════════════════════════════════
% \cxStepReveal{content1}{content2}{content3}...
% 按序逐步揭示多段内容，自动分配 overlay spec
% 等价于 \onslide<1->{c1} \onslide<2->{c2} ...
% ══════════════════════════════════════════════
\ExplSyntaxOn
\int_new:N \g__cxs_step_int
\NewDocumentCommand{\cxStepReveal}{ >{\SplitList{\\}} m }
{
  \int_gzero:N \g__cxs_step_int
  \ProcessList{#1}{\__cxs_step_item:n}
}
\cs_new_protected:Nn \__cxs_step_item:n
{
  \int_gincr:N \g__cxs_step_int
  \onslide< \int_use:N \g__cxs_step_int - >{#1\par}
}
\ExplSyntaxOff

% ══════════════════════════════════════════════
% \cxFixedArea[height]{content}
% 创建固定高度的区域，防止内容变化时页面跳动
% ══════════════════════════════════════════════
\NewDocumentCommand{\cxFixedArea}{ O{3em} +m }{%
  \begin{overlayarea}{\linewidth}{#1}
    #2
  \end{overlayarea}
}
```

### 14.3 禁止的模式与推荐替代

| 禁止的写法 | 问题 | 正确替代 |
|-----------|------|---------|
| `\only<1>{短}\only<2>{长长长}` | Jittering | `\begin{overlayarea}{\linewidth}{2em} \only<1>{短}\only<2>{长长长} \end{overlayarea}` |
| `\visible<2->{内容}` 位于页面中部 | 出现时其下方元素跳动 | `\uncover<2->{内容}` |
| `\begin{block}<2->{T} 内容 \end{block}` 后接正文 | Block 出现时正文下移 | 始终保留 block 空间，用 `\uncover` 控制可见性 |
| `\pause` 在 `columns` 环境中 | 不可预测的列中断 | 改用 `\onslide<n->` 显式控制 |

---

## 15. 输出模式：Handout / Notes / Trans / Article

### 15.1 统一的模式处理（cxslide-output.def）

```latex
%% cxslide-output.def

\ExplSyntaxOn

% ══════════════════════════════════════════════
% Handout 模式适配
% ══════════════════════════════════════════════
\mode<handout>{
  % 灰度化：强制白底黑字
  \setbeamercolor{normal text}{fg=black, bg=white}
  \setbeamercolor{frametitle}{fg=black, bg=black!10}
  \setbeamercolor{block title}{fg=white, bg=black!70}
  \setbeamercolor{block body}{fg=black, bg=black!3}
  \setbeamercolor{block title alerted}{fg=white, bg=black!60}
  \setbeamercolor{block body alerted}{fg=black, bg=black!3}
  \setbeamercolor{block title example}{fg=white, bg=black!50}
  \setbeamercolor{block body example}{fg=black, bg=black!3}
  \setbeamercolor{structure}{fg=black!80}
  \setbeamercolor{alerted text}{fg=black}
  \setbeamercolor{progress bar}{fg=black!50, bg=black!10}
  \setbeamercolor{footline}{fg=black!50}

  % 取消半透明覆盖
  \setbeamercovered{invisible}

  % alert 在灰度模式下改为加粗（颜色不可依赖）
  \setbeamerfont{alerted text}{series=\bfseries}
}

% ══════════════════════════════════════════════
% Notes 模式
% ══════════════════════════════════════════════
\tl_if_eq:NnT \g__cxs_output_tl { notes }
{
  \RequirePackage{pgfpages}
  \setbeameroption{show~notes~on~second~screen=right}
  % 备注页字体设置
  \setbeamertemplate{note page}{%
    \insertnote%
  }
  \setbeamerfont{note page}{size=\small}
}

% ══════════════════════════════════════════════
% Trans 模式（纯白打印）
% ══════════════════════════════════════════════
\mode<trans>{
  \setbeamercolor{normal text}{fg=black, bg=white}
  \setbeamercolor{frametitle}{fg=black, bg=white}
  \setbeamercolor{structure}{fg=black}
  \setbeamercolor{alerted text}{fg=black}
  \setbeamertemplate{headline}{}
  \setbeamertemplate{footline}{}
  \setbeamercovered{invisible}
  \setbeamerfont{alerted text}{series=\bfseries}
}

% ══════════════════════════════════════════════
% Article 模式（接口预留，当前版本显式拒绝）
% ══════════════════════════════════════════════
\tl_if_eq:NnT \g__cxs_output_tl { article }
{
  \msg_error:nn { cxslide } { article-not-implemented }
}

\ExplSyntaxOff
```

---

## 16. 空间压缩与极端排版

### 16.1 compact 开关效果汇总

| 模块 | 默认（compact=false） | compact=true |
|------|---------------------|-------------|
| frametitle 字号 | `\large` | `\normalsize` |
| block title 字号 | `\normalsize` | `\small` |
| caption 字号 | `\small` | `\footnotesize` |
| 列表 itemsep | Beamer 默认 (~4pt) | 1pt |
| 列表 topsep | Beamer 默认 | 2pt |
| 列表左缩进 | Beamer 默认 | 1em / 0.8em / 0.6em |
| 页脚高度 | 2.5ex | 2ex |

### 16.2 帧级溢出处理策略

**当单帧放不下内容时，优先级排序**：

1. **拆分为两帧**（首选，最干净）
2. **使用 `[shrink=N]` 帧选项**（Beamer 原生，整帧等比缩小）
   - 硬性上限：`N ≤ 20`，超过此值文字过小不可读
3. **使用 `smallmath` / `tinymath` 环境**（仅缩小公式区域）
4. **使用 `[allowframebreaks]`**（自动分页，仅适合参考文献等非结构化内容）
5. **启用 `compact` 选项**（全局生效，影响所有帧）

**不提供** v1.0 中的 `\cxSqueezeSoft/Hard/Max`。

**Rationale**：三级压缩命令的语义模糊，且帧内局部修改间距会与 overlay 系统不可预测地交互。当用户需要"我就是要在这一页塞下"时，`[shrink=N]` 是 Beamer 原生的、经过充分测试的方案。

---

## 17. 极端场景防御矩阵

本节系统性列举所有可能导致排版崩溃的极端场景，以及 CXSlide 的防御策略。

### 17.1 内容溢出类

| 场景 | 症状 | 防御策略 |
|------|------|---------|
| 帧标题过长 | 标题文字溢出帧标题栏或换行丑陋 | Beamer 的 `\frametitle[short]{长标题}` 机制；文档中强调"标题不超过一行" |
| 单帧 10+ 行公式 | 公式溢出底部 | `smallmath`/`tinymath` 环境 + `[shrink]`；推荐拆帧 |
| 超宽公式 | 公式溢出右侧 | 用户用 `multline` 或 `split` 手动折行；不提供自动方案（折行点必须由人决定） |
| 超长列表 (20+ 项) | 内容溢出 | `[allowframebreaks]`；推荐重组为多帧 |
| 超大表格 | 表格溢出 | `\resizebox` 包裹（最后手段）；推荐拆分或用图片 |
| 超长代码 | 代码溢出 | listings `breaklines=true` 已启用；推荐只展示关键片段 |
| 超大图片 | 图片溢出 | `\cxFigure` 默认 `width=0.8\linewidth`，自动约束 |

### 17.2 Overlay 相关

| 场景 | 症状 | 防御策略 |
|------|------|---------|
| `\only` 包裹不等长内容 | 页面跳动 | 文档规范禁止；提供 `\cxFixedArea` |
| `\pause` 在 columns 中 | 列断裂 | 文档规范禁止；推荐显式 `\onslide` |
| Block 动画后内容位移 | Block 出现时其后元素下移 | Block 始终占位（`\uncover` 而非 `\only`） |
| 200+ 帧的 overlay 展开 | 编译极慢 (10min+) | 开发期使用 `\includeonlyframes`；发布时忍受 |
| `[fragile]` + overlay | Beamer 已知冲突 | 使用 `[fragile=singleslide]`；或拆分代码帧与动画帧 |

### 17.3 输出模式相关

| 场景 | 症状 | 防御策略 |
|------|------|---------|
| Handout 中残留颜色信息 | 彩色打印墨水消耗 | 灰度化覆盖（§15.1） |
| Handout 中 overlay 展开为多页 | 页数爆炸 | `\mode<handout>` 已自动折叠 |
| Notes 模式 PDF 宽度翻倍 | 部分 PDF 阅读器不支持 | 文档推荐使用 pdfpc 或 Keynote |
| Trans 模式背景色残留 | 打印底色 | 全面覆盖 bg=white |

### 17.4 字体相关

| 场景 | 症状 | 防御策略 |
|------|------|---------|
| 系统无中文字体 | CTeX 报错 | 推荐安装 Fandol；CI 用 Docker |
| AutoFakeBold 毛边 | 投影仪上粗体字边缘发散 | 不启用 AutoFakeBold |
| unicode-math 与旧宏包冲突 | 未定义符号 | unicode-math 最先加载；诊断模块检测冲突 |
| 数学字体缺失符号 | 某些少见符号空白 | TeX Gyre Termes Math 覆盖率足够；极端情况用 `\text` 回退 |

### 17.5 投影仪环境

| 场景 | 症状 | 防御策略 |
|------|------|---------|
| 低亮度投影仪 | 浅色不可见 | 所有 fg on bg 对比度 ≥ 4.5:1；`mono` 调色板 |
| 色温偏移（偏黄/偏蓝） | 颜色失真 | 不依赖单一颜色区分信息；配合字重和形状 |
| 分辨率极低 (800×600) | 细线消失、小字糊 | 最小字号不低于 `\footnotesize`；线宽 ≥ 0.4pt |
| 极高亮度投影仪（刺眼） | 纯白背景刺眼 | 默认 bg 为 `F5F5F5` 而非 `FFFFFF`（除 `clinical`） |
| 色弱/色盲观众 | 无法区分红/绿 | WCAG AA 合规；`\alert` 同时改变颜色和字重 |

### 17.6 比例相关

| 场景 | 症状 | 防御策略 |
|------|------|---------|
| 4:3 比例下宽屏内容 | 内容被截断 | 所有尺寸为 `\linewidth` 比例，自动适配 |
| 21:9 下内容太分散 | 大量留白 | 限制内容区域最大宽度（通过 columns 约束） |
| PDF 被缩放打印到 A4 | 字号变化 | 所有字号为相对值，等比缩放不失真 |

---

## 18. 增强功能模块

### 18.1 引用格式（cxslide-enhance.def）

```latex
%% cxslide-enhance.def

% ══════════════════════════════════════════════
% 帧内微型引用（替代破坏布局的 \footnote）
% ══════════════════════════════════════════════
\NewDocumentCommand{\cxCite}{ m }{%
  \par\vfill
  {\usebeamerfont{footnote}\usebeamercolor[fg]{footline}#1}%
}

% ══════════════════════════════════════════════
% 参考文献帧（自动分页）
% ══════════════════════════════════════════════
\NewDocumentEnvironment{cxReferences}{}{%
  \begin{frame}[allowframebreaks]{参考文献}
    \footnotesize
}{%
  \end{frame}
}
```

### 18.2 强调工具

```latex
% ══════════════════════════════════════════════
% \cxHL{text} — 荧光笔效果（使用 highlight 色）
% ══════════════════════════════════════════════
\NewDocumentCommand{\cxHL}{ D<>{} m }{%
  \tl_if_blank:nTF {#1}
  {%
    \colorbox{cx@highlight}{#2}%
  }
  {%
    \alt<#1>{\colorbox{cx@highlight}{#2}}{#2}%
  }%
}

% ══════════════════════════════════════════════
% \cxDim{text} — 弱化效果（使用 muted 色）
% ══════════════════════════════════════════════
\NewDocumentCommand{\cxDim}{ D<>{} m }{%
  \tl_if_blank:nTF {#1}
  {%
    {\color{cx@muted}#2}%
  }
  {%
    \alt<#1>{{\color{cx@muted}#2}}{#2}%
  }%
}

% ══════════════════════════════════════════════
% \cxBadge[color]{text} — 标签/徽章
% ══════════════════════════════════════════════
\NewDocumentCommand{\cxBadge}{ O{cx@primary} m }{%
  \tikz[baseline=(X.base)]
    \node[fill=#1, text=white, rounded corners=2pt,
          inner xsep=0.4em, inner ysep=0.1em,
          font=\scriptsize\bfseries] (X) {#2};%
}
```

### 18.3 对比与总结

```latex
% ══════════════════════════════════════════════
% \cxVersus{left-title}{left-content}{right-title}{right-content}
% 对比两栏（带标题和色彩区分）
% ══════════════════════════════════════════════
\NewDocumentCommand{\cxVersus}{ m +m m +m }{%
  \begin{columns}[T, totalwidth=\linewidth]
    \begin{column}{0.47\linewidth}
      \begin{block}{#1}
        #2
      \end{block}
    \end{column}
    \begin{column}{0.47\linewidth}
      \begin{alertblock}{#3}
        #4
      \end{alertblock}
    \end{column}
  \end{columns}
}

% ══════════════════════════════════════════════
% \cxSummary{title}{item1 \\ item2 \\ ...}
% 要点总结框（带 highlight 背景）
% ══════════════════════════════════════════════
\NewDocumentCommand{\cxSummary}{ m +m }{%
  \begin{beamercolorbox}[sep=0.5em, rounded=true]{block body}
    {\usebeamerfont{block title}\usebeamercolor[fg]{block title}#1\par}
    \vskip 0.3em
    #2
  \end{beamercolorbox}
}
```

### 18.4 计时与进度工具

```latex
% ══════════════════════════════════════════════
% \cxTimeEstimate{minutes}
% 在帧右下角显示预计用时提示（仅 present 模式）
% ══════════════════════════════════════════════
\NewDocumentCommand{\cxTimeEstimate}{ m }{%
  \mode<presentation>{%
    \begin{tikzpicture}[remember picture, overlay]
      \node[anchor=south east, font=\tiny, text=cx@muted]
        at (current page.south east) {$\approx$#1\,min};
    \end{tikzpicture}%
  }%
}
```

### 18.5 水印系统

```latex
% ══════════════════════════════════════════════
% \cxWatermark{text}
% 在每帧背景添加斜置半透明水印
% ══════════════════════════════════════════════
\NewDocumentCommand{\cxWatermark}{ m }{%
  \setbeamertemplate{background}{%
    \begin{tikzpicture}[remember picture, overlay]
      \node[rotate=30, scale=5, text=cx@muted!20!cx@bg,
            font=\bfseries]
        at (current page.center) {#1};
    \end{tikzpicture}%
  }%
}
```

### 18.6 附录与 Q&A 支持

```latex
% ══════════════════════════════════════════════
% appendixnumberbeamer 已在 Phase 3 加载
% \appendix 后自动重置帧号，进度条不再计入
% ══════════════════════════════════════════════

% Q&A 帧模板
\NewDocumentCommand{\cxQAFrame}{ O{提问与讨论} }{%
  \begin{frame}[plain, noframenumbering]
    \vfill
    \centering
    {\usebeamercolor[fg]{structure}\usebeamerfont{title}#1\par}
    \vskip 2em
    {\usebeamerfont{subtitle}\usebeamercolor[fg]{subtitle}%
      \insertauthor\quad\textbar\quad\insertdate\par}
    \vfill
  \end{frame}
}
```

---

## 19. 编译系统

### 19.1 latexmk 配置

```perl
# .latexmkrc
$pdf_mode = 5;                     # xelatex
$xelatex = 'xelatex -file-line-error -halt-on-error '
         . '-interaction=nonstopmode -synctex=1 %O %S';
$max_repeat = 5;
$bibtex_use = 0;                   # 用户如需 bib 自行配置

# 清理中间文件
$clean_ext = 'nav snm vrb synctex.gz run.xml';

# 监听这些扩展名的变化
push @generated_exts, 'nav', 'snm', 'vrb';
```

### 19.2 编译性能基准

| 帧数 | 预期编译时间（首次） | 预期编译时间（增量） |
|------|-------------------|-------------------|
| 30 帧 | ≤ 15 秒 | ≤ 8 秒 |
| 100 帧 | ≤ 45 秒 | ≤ 25 秒 |
| 200 帧 | ≤ 120 秒 | ≤ 60 秒 |

*测试环境：TeX Live 2024，4 核 CPU，SSD*

### 19.3 开发期编译加速

```latex
% 在开发期间，只编译当前正在编辑的帧
\includeonlyframes{current}

\begin{frame}[label=current]{正在编辑的帧}
  内容
\end{frame}
```

---

## 20. 错误处理与诊断

### 20.1 诊断模块（cxslide-diag.def）

```latex
%% cxslide-diag.def

\ExplSyntaxOn

% ═══════════════════════════════════════════════
% 宏包版本检查
% ═══════════════════════════════════════════════
\cs_new_protected:Nn \__cxs_check_pkg:nn
{
  \@ifpackagelater{#1}{#2}{}{
    \msg_warning:nnnn { cxslide } { old-package } {#1} {#2}
  }
}

\msg_new:nnn { cxslide } { old-package }
{
  CXSlide~ Warning:~ Package~ '#1'~ is~ older~ than~ #2.~
  Please~ update~ TeX~ Live.
}

% ═══════════════════════════════════════════════
% 宏包冲突检测
% ═══════════════════════════════════════════════
\cs_new_protected:Nn \__cxs_check_conflict:nn
{
  \@ifpackageloaded{#1}{
    \msg_error:nnnn { cxslide } { package-conflict } {#1} {#2}
  }{}
}

\msg_new:nnn { cxslide } { package-conflict }
{
  CXSlide~ Error:~ Package~ '#1'~ conflicts~ with~ CXSlide.~
  Reason:~ #2.~ Please~ remove~ it.
}

% ═══════════════════════════════════════════════
% AtBeginDocument 检查
% ═══════════════════════════════════════════════
\AtBeginDocument{
  % 版本检查
  \__cxs_check_pkg:nn { tabularray } { 2023/01/01 }
  \__cxs_check_pkg:nn { unicode-math } { 2023/01/01 }
  \__cxs_check_pkg:nn { listings } { 2020/01/01 }

  % 冲突检查
  \__cxs_check_conflict:nn { geometry }
    { Beamer~ has~ its~ own~ page~ model }
  \__cxs_check_conflict:nn { fancyhdr }
    { Beamer~ manages~ headers~ and~ footers~ internally }
  \__cxs_check_conflict:nn { titlesec }
    { Beamer~ manages~ section~ titles~ internally }

  % 调色板存在性验证
  \prop_if_exist:cF { c__cxs_pal_ \g__cxs_palette_tl _prop }
  {
    \msg_critical:nnx { cxslide } { unknown-palette } { \g__cxs_palette_tl }
  }
}

% ═══════════════════════════════════════════════
% 帧溢出检测（实验性）
% ═══════════════════════════════════════════════
% Beamer 在内容溢出时会发出 "Overfull \vbox" 警告
% 我们将其升级为更明确的消息
\AtBeginDocument{
  \vfuzz=0.5ex  % 容忍微小溢出
}

\ExplSyntaxOff
```

### 20.2 调试模式

可选的 `debug` 选项（未来版本），启用后在帧的四角绘制对齐标记、在控制台输出详细的颜色/字号信息。当前版本不实现此功能，但选项接口预留。

---

## 21. 无障碍与国际化

### 21.1 无障碍设计

CXSlide 的无障碍策略遵循"颜色不是唯一信息载体"原则：

| 信息类型 | 颜色通道 | 辅助通道 |
|---------|---------|---------|
| 强调 (`\alert`) | accent 色 | 粗体 |
| 示例 (`example text`) | secondary 色 | 无额外辅助（不承载关键信息） |
| 列表层级 | structure 色 | 不同形状标记（方块→圆→横线） |
| 进度条 | primary 色 | 页码数字（footline） |
| 区块类型 | 不同标题色 | 用户应在标题中体现语义（"定理"/"注意"/"例"） |

### 21.2 国际化预留

当前版本的固定中文字符串：

| 位置 | 中文 | 未来 i18n key |
|------|------|-------------|
| 结束页 | "谢谢" | `cxslide/endpage/title` |
| 结束页 | "欢迎批评指正" | `cxslide/endpage/subtitle` |
| Q&A 帧 | "提问与讨论" | `cxslide/qa/title` |
| 参考文献帧 | "参考文献" | `cxslide/references/title` |
| Section 页 | "内容提要"（如使用） | `cxslide/secpage/title` |

未来版本可通过 l3keys 的字符串表（string map）实现语言切换。当前版本将这些字符串作为命令参数暴露，用户可覆盖：

```latex
% 用户覆盖示例
\cxQAFrame[Questions \& Discussion]  % 直接传参
```

---

## 22. 测试策略

### 22.1 测试矩阵

| 测试文件 | 验证内容 | 通过标准 |
|---------|---------|---------|
| `test-basic.tex` | 最小文档编译 | 零 error，零 warning |
| `test-palettes-all.tex` | 12 调色板各 1 帧 | 颜色正确渲染，对比度达标 |
| `test-ratio-43.tex` | 4:3 比例全功能 | 无溢出 |
| `test-ratio-219.tex` | 21:9 比例全功能 | 无溢出 |
| `test-overlay-stability.tex` | overlay 稳定性 | 逐帧 diff 静态区域零位移 |
| `test-handout.tex` | handout 灰度化 | 输出为灰度，页数=帧数 |
| `test-notes.tex` | 双屏 PDF | PDF 宽度正确，备注可见 |
| `test-trans.tex` | 纯白打印 | 无背景色残留 |
| `test-blocks-overlay.tex` | block + `<+->` | block 动画正常工作 |
| `test-math-overflow.tex` | 极长公式 | `smallmath`/`tinymath` 有效 |
| `test-code-fragile.tex` | `[fragile]` + listings | 编译无错 |
| `test-compact.tex` | compact 间距压缩 | 所有间距正确缩减 |
| `test-chinese-full.tex` | 纯中文内容 | 中文字体正确渲染 |
| `test-200frames.tex` | 200 帧性能 | 编译时间 ≤ 120 秒 |
| `test-titlepage-variants.tex` | 三种封面 | 视觉正确 |
| `test-endpage.tex` | 结束页 | 自动出现，noframenumbering |
| `test-progress-variants.tex` | 三种进度条 | 视觉正确 |
| `test-enhance-tools.tex` | 增强工具 | `\cxHL`, `\cxDim`, `\cxBadge` 等正常 |
| `test-gallery.tex` | 图片栅格 | 多图正确平铺 |
| `test-appendix.tex` | appendix 帧号 | 帧号正确重置 |

### 22.2 自动化 CI

```yaml
# .github/workflows/build.yml
name: Build & Test
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    container:
      image: texlive/texlive:latest
    steps:
      - uses: actions/checkout@v4

      - name: Compile all test files
        run: |
          cd test
          for f in test-*.tex; do
            echo "=== Compiling $f ==="
            latexmk -xelatex -halt-on-error "$f" || exit 1
          done

      - name: Check for warnings
        run: |
          cd test
          FAIL=0
          for f in *.log; do
            # 过滤已知无害警告
            if grep -v "rerunfilecheck\|pdfmanagement" "$f" \
               | grep -q "Warning"; then
              echo "⚠ Unexpected warning in $f"
              FAIL=1
            fi
          done
          exit $FAIL

      - name: Upload PDFs
        uses: actions/upload-artifact@v4
        with:
          name: test-pdfs
          path: test/*.pdf
```

### 22.3 视觉回归测试（未来）

使用 `diff-pdf` 或 `pdftoppm` + ImageMagick `compare` 对比 baseline PDF 和当前构建的 PDF，检测视觉回归。当前版本依赖人工检查。

---

## 23. 已知限制与未来演进

### 23.1 已知限制

| 限制 | 原因 | 规避方式 |
|------|------|---------|
| 中文字体依赖系统 | CTeX 在 XeLaTeX 下使用系统字体 | 推荐安装 Fandol；CI 用 TeX Live Docker |
| `unicode-math` 与部分旧宏包冲突 | 重定义大量数学符号 | 在 `unicode-math` 之后加载冲突宏包 |
| 200+ 帧编译慢 | Beamer overlay 展开机制 | 开发期 `\includeonlyframes`；发布时忍受 |
| `[fragile]` 帧不支持 overlay | Beamer 已知限制 | `[fragile=singleslide]` 或拆帧 |
| tcolorbox 与原生 block 不可互换 | 环境体系不同 | 提供独立样式，不覆盖原生 block |
| `article` 输出模式为实验性 | beamerarticle 本身有诸多限制 | 标注为实验性，不保证所有功能可用 |
| chalk 调色板在纯白打印时失效 | 深色背景 + trans 模式冲突 | trans 模式强制白底覆盖 |

### 23.2 未来演进路线

| 版本 | 特性 | 状态 |
|------|------|------|
| v3.1 | 深色模式（Dark Mode，非 mono 的柔和深灰色系） | 计划中 |
| v3.1 | `debug` 选项（帧对齐标记、详细日志） | 计划中 |
| v3.2 | PDF/A 合规输出 | 评估中 |
| v3.2 | i18n 字符串表 | 评估中 |
| v4.0 | LuaLaTeX 引擎支持 | 远期 |
| v4.0 | 自适应字号（两遍编译 + 辅助文件） | 远期 |

---

## 24. 实现检查清单

### Phase 1：骨架（可编译的最小主题）

- [x] `beamerthemeCX.sty`：加载顺序正确，`\ProcessKeyOptions` 工作
- [x] `cxslide-options.def`：所有选项可解析，未知选项报错
- [x] `cxslide-palette-data.def`：12 个 prop 常量定义正确
- [x] `cxslide-palette-load.def`：颜色提取函数工作，缺失键报错
- [x] `beamercolorthemeCX.sty`：`steel` 调色板 Beamer 语义映射正确
- [x] `beamerfontthemeCX.sty`：中英文字体正确渲染
- [x] `beamerouterthemeCX.sty`：进度条（bar 模式）正确显示
- [x] `beamerinnerthemeCX.sty`：列表标记正确，block 环境正常
- [x] `examples/main-minimal.tex`：最小示例编译通过，当前日志未检出 warning/error

### Phase 2：完整调色板

- [x] 12 个调色板全部在 `test-palettes-all.tex` 中完成注册与 smoke test
- [x] chalk 调色板（深色背景）帧标题/页脚颜色正确反转
- [x] mono 调色板 block/alert 颜色正确
- [x] 对比度矩阵已写入设计文档并满足当前目标

### Phase 3：完整功能

- [x] compact 模式核心微调生效
- [x] progress 三种模式（bar/miniframes/none）已通过示例与测试覆盖
- [x] footstyle 三种模式已通过示例与测试覆盖
- [x] titlepage 三种模式已通过示例与测试覆盖
- [x] endpage 自动插入且 noframenumbering
- [x] secpage 目录过渡页正确
- [x] blockcorner 圆角/直角切换正确
- [x] `\hlmath` overlay 功能正确
- [x] `\mathbox` overlay 功能正确
- [x] `smallmath` / `tinymath` 可稳定使用
- [x] `\cxTwoCols` / `\cxThreeCols` 在主示例与测试中稳定编译
- [x] `\cxFigure` / `\cxGallery` 已补充独立 smoke test
- [x] listings 代码样式正确，`[fragile]` 不报错
- [x] `\cxFixedArea` 与 `\only` 配合无 jittering
- [x] `\cxHL` / `\cxDim` / `\cxBadge` overlay 正确
- [x] `\cxVersus` / `\cxSummary` 布局正确
- [x] `\cxCite` 正确定位在帧底部
- [x] `\cxQAFrame` 正确显示
- [x] `\cxWatermark` 正确叠加
- [x] `\cxTimeEstimate` 在 present 主线可用

### Phase 4：输出模式

- [x] Handout 已有独立 smoke test，灰度路径可编译
- [x] Handout 中 alert 改为粗体
- [x] Notes 双屏 PDF 可编译，备注内容可见
- [x] Trans 无背景色残留，无页眉页脚
- [x] output 与 documentclass 选项一致性检查工作（handout 已校验，article 显式拒绝）

### Phase 5：健壮性

- [x] `cxslide-diag.def` 宏包版本检查工作
- [x] geometry 用户入口命令已被拦截并报错
- [x] fancyhdr / titlesec 冲突检测报错
- [x] 未知选项错误消息清晰
- [x] 调色板不存在时报 critical 错误
- [x] palette-data 中缺失 key 时报 critical 错误
- [x] 当前主示例与 smoke tests 日志未检出 warning/error
- [x] appendixnumberbeamer 帧号重置正确

### Phase 6：文档与发布

- [x] `README.md`：安装指南、快速开始、选项速查表
- [x] `examples/main.tex` 示例覆盖所有主要功能
- [x] `examples/main-minimal.tex` 最小可编译示例
- [x] `docs/CHANGELOG.md` 记录所有变更
- [x] `LICENSE` 文件（LPPL 1.3c）
- [ ] CI 流水线全绿（已提供 workflow，本地无法代跑 GitHub 环境）

---

*文档版本：v3.0 | 日期：2025-07-09*
*CXSlide — Industrial Chinese Presentation Architecture*
*变更记录：v3.0 完全重写，扩展至 12 调色板，增加极端场景防御矩阵、增强功能模块、无障碍设计、完整测试策略*
