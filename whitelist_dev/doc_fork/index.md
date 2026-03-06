# Fork 文档索引

本目录用于维护当前 `komorebi` fork 的中文文档。

## 为什么需要这套文档

在这次整理中，已经确认上游文档与当前代码/实测行为之间存在一些偏差，尤其集中在以下主题：

- AHK 仍可用，但在 CLI 中已经属于 legacy / EOL 路线
- `quickstart` 生成的默认配置与本 fork 的目标行为需要对齐
- 日志真实落点与部分文档描述不完全一致
- border 的 style / implementation 维度在高层说明里不够完整
- 多显示器场景下，`focus-workspace` 只作用于当前 focused monitor，容易引起误解

因此，这里的文档主要解决“当前 fork 该怎么用、该怎么看源码、该怎么排障”的问题。

## 目录

- `README.md`
  - 本目录用途、维护原则与阅读路径
- `autohotkey.md`
  - AHK 路线说明、EOL 状态、适合本 fork 的建议配置思路
- `autostart.md`
  - 启动方式、后台进程、自动启动策略
- `multi-monitor-setup.md`
  - monitor/workspace 焦点模型、多屏切换建议、热键设计建议
- `troubleshooting.md`
  - 日志、崩溃、卡顿、输入冲突、状态文件等排障汇总
- `example-configurations.md`
  - 示例 JSON 的 fork 化解读与推荐默认项
- `project-analysis.md`
  - 从架构、事件流、配置系统到热键支持的代码级分析
- `advanced-usage-guide.md`
  - 更偏实战的高级功能整理与使用建议
- `implementation-plan-archive.md`
  - 历史计划归档
- `compile-test-report-archive.md`
  - 历史测试报告归档

## 使用方式

- 想快速上手：先看 `autohotkey.md`、`multi-monitor-setup.md`
- 想知道当前代码到底怎么跑：看 `project-analysis.md`
- 想查问题：看 `troubleshooting.md`
- 想对照配置：看 `example-configurations.md`

## 说明

本目录中的文档默认面向以下场景：

- 当前仓库是一个 fork，而不是纯粹跟随上游的镜像
- 需要在不改动上游原文档的前提下，沉淀自己的维护结论
- 允许保留历史文件，但会逐步将其迁移到 archive 语义下
