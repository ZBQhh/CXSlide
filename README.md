# CXSlide

工业级中文 Beamer 演示主题，面向学术报告、课程授课、技术答辩与研究组汇报场景。

## 当前状态

- 主题主线可编译，`main.tex` 与 `main-minimal.tex` 已验证通过
- 完整示例覆盖列表、区块、数学、布局、代码、overlay、增强工具、参考文献、附录、Q&A
- `endpage=true` 已实现为可靠的自动结束页注入
- `article` 接口已预留，但当前版本显式未实现
- 仓库附带 smoke tests，覆盖主示例、主题变体与主要输出模式

## 文件结构

- [beamerthemeCX.sty](C:\Users\25890\Desktop\Beamers\beamerthemeCX.sty): 主题入口
- [beamercolorthemeCX.sty](C:\Users\25890\Desktop\Beamers\beamercolorthemeCX.sty): 颜色主题
- [beamerfontthemeCX.sty](C:\Users\25890\Desktop\Beamers\beamerfontthemeCX.sty): 字体主题
- [beamerinnerthemeCX.sty](C:\Users\25890\Desktop\Beamers\beamerinnerthemeCX.sty): 列表、区块、目录
- [beamerouterthemeCX.sty](C:\Users\25890\Desktop\Beamers\beamerouterthemeCX.sty): 页眉、页脚、进度条
- [cxslide-*.def](C:\Users\25890\Desktop\Beamers): 功能模块
- [main-minimal.tex](C:\Users\25890\Desktop\Beamers\main-minimal.tex): 最小示例
- [main.tex](C:\Users\25890\Desktop\Beamers\main.tex): 完整示例
- [Design.md](C:\Users\25890\Desktop\Beamers\Design.md): 设计文档
- [test](C:\Users\25890\Desktop\Beamers\test): 测试样例

## 依赖

- TeX Live 2023+ 或兼容发行版
- XeLaTeX
- `ctexbeamer`
- `expl3`
- `xparse`
- `unicode-math`
- `graphicx`
- `tabularray`
- `listings`
- `etoolbox`
- `appendixnumberbeamer`
- `tikz`

## 快速开始

最小示例：

```latex
\documentclass[aspectratio=169, UTF8]{ctexbeamer}
\usetheme[
  palette   = ivory,
  progress  = bar,
  footstyle = full,
  secpage   = true,
  endpage   = true
]{CX}

\title{标题}
\subtitle{副标题}
\author{作者}
\institute{单位}
\date{\today}

\begin{document}

\begin{frame}[plain, noframenumbering]
  \titlepage
\end{frame}

\section{引言}

\begin{frame}{示例}
  \begin{itemize}
    \item 第一项
    \item \alert{强调项}
  \end{itemize}
\end{frame}

\end{document}
```

编译命令：

```powershell
latexmk -xelatex .\main.tex
latexmk -xelatex .\main-minimal.tex
```

## 选项速查

### 正交轴

- `palette`: `steel`, `forest`, `ember`, `graphite`, `ocean`, `ivory`, `chalk`, `dusk`, `clinical`, `terra`, `sakura`, `mono`
- `output`: `present`, `handout`, `notes`, `trans`, `article`

### 独立开关

- `compact`
- `progress=bar|miniframes|none`
- `secpage=true|false`
- `titlepage=standard|minimal|none`
- `endpage=true|false`
- `footstyle=full|minimal|none`
- `blockcorner=round|sharp`

## 已知约束

- `article` 当前会显式报错，避免误用
- `ratio` 是接口预留项，实际画布比例仍由 `\documentclass[aspectratio=...]` 控制
- `[fragile]` 帧仍应谨慎与复杂 overlay 混用
- 中文字体仍依赖 CTeX/系统可用字体配置

## 测试

本仓库提供基础测试样例：

```powershell
latexmk -xelatex .\test\test-basic.tex
latexmk -xelatex .\test\test-theme-variants.tex
latexmk -xelatex .\test\test-media-layout.tex
latexmk -xelatex .\test\test-palettes-all.tex
latexmk -xelatex .\test\test-output-modes.tex
latexmk -xelatex .\test\test-output-handout.tex
latexmk -xelatex .\test\test-output-notes.tex
latexmk -xelatex .\test\test-output-trans.tex
```

CI 配置见 [.github/workflows/build.yml](C:\Users\25890\Desktop\Beamers\.github\workflows\build.yml)。
