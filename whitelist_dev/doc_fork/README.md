# doc_fork

这是当前 `komorebi` fork 的自维护文档入口。

## 目的

这套文档不试图替代上游 `README.md` 和 `docs/`，而是补充本 fork 在实际使用、排障、配置取舍和代码调查中的结论，重点覆盖：

- 上游文档与当前代码行为不完全一致的地方
- 本 fork 实际采用的默认配置与工作流
- 针对 `whitelist_mode` / `force_manage` 的专项分析
- AHK、`whkd`、双显示器、多工作区等高频问题
- 归档性质的计划/测试记录，避免与当前结论混淆

## 与上游文档的关系

建议把这里的文档理解为“fork 视角下的覆盖层”：

- 上游 `docs/`：命令与功能的原始说明
- `whitelist_dev/doc_fork/`：结合当前 fork、源码核对和本地实测后的维护文档

当两者不一致时，优先参考：

1. 当前仓库源码
2. `whitelist_dev/doc_fork/` 中的结论性文档
3. 上游 `docs/`

## 文档分类

### 工作流与使用建议

- `autohotkey.md`：AHK 的当前支持状态、适用场景、限制与迁移建议
- `autostart.md`：启动项、后台启动、AHP/whkd 的使用建议
- `multi-monitor-setup.md`：多显示器、多工作区、焦点与 monitor/workspace 的实际语义
- `troubleshooting.md`：结合当前 fork 的常见问题与排障路径
- `example-configurations.md`：示例配置的 fork 说明、默认项与建议改法

### 内部分析

- `project-analysis.md`：面向源码的项目分析更新版
- `advanced-usage-guide.md`：基于实际使用的高级功能与组合工作流整理

### 历史与归档

- `implementation-plan-archive.md`：旧实现计划与设计记录归档
- `compile-test-report-archive.md`：旧编译/测试结果归档与环境说明

## 推荐阅读顺序

如果你是第一次看这套 fork 文档，建议按这个顺序阅读：

1. `index.md`
2. `project-analysis.md`
3. `autohotkey.md`
4. `multi-monitor-setup.md`
5. `troubleshooting.md`
6. `example-configurations.md`

## 当前维护原则

- 尽量记录“代码当前真实行为”，而不是只复述旧文档
- 明确区分：上游通用结论 / fork 特定结论 / 本地实测结论
- 尽量把会随版本变化的内容写清楚来源和上下文
- 历史文档不删除，但会转为 archive，避免误导
