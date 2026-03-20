# Changelog

## v3.0.1 - 2026-03-19

- 修复 `hyperref` 元数据重复设置导致的警告
- 重写进度条与页脚布局，消除主示例中的严重溢出噪声
- 调整 `\hlmath` 实现，避免依赖不可用粗体数学字形
- 移除增强模块中未实际使用的 `tcolorbox` 主线依赖
- 将 `cxReferences` 改为更稳的 body-capturing 环境
- 恢复 `endpage=true` 的可靠自动结束页行为，并加入防重逻辑
- 重写 `main.tex`，补齐完整章节与主要功能覆盖
- 补充 `README.md`、测试目录、CI 样例与许可证文件
- 同步 `Design.md` 与当前实现状态

## v3.0.2 - 2026-03-20

- 重组仓库目录，根目录仅保留入口与发布级文件
- 将内部主题与功能模块统一收纳到 `theme/`
- 将完整示例移入 `examples/`，将设计文档与变更记录移入 `docs/`
- 同步 `beamerthemeCX.sty`、README 与 CI 到新目录结构

## v3.0 - 2025-07-09

- 初始工业级中文 Beamer 主题设计文档与主实现骨架
