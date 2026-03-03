# Komorebi 白名单模式实施计划

## 目标

实现纯白名单模式：只有在白名单（`manage_rules`）中的窗口才会被 komorebi 管理。

## 设计原则

1. **向后兼容**: 默认关闭白名单模式，保持现有行为
2. **最小改动**: 复用现有的 `managed_override` 和 `MANAGE_IDENTIFIERS`
3. **渐进实施**: 分步骤实现，每步都编译验证
4. **配置优先**: 支持通过 JSON 配置文件设置

## 核心改动概述

### 改动点 1: 添加全局开关
- **文件**: `komorebi/src/lib.rs`
- **内容**: 添加 `WHITELIST_MODE_ENABLED` 全局变量

### 改动点 2: 添加命令枚举
- **文件**: `komorebi/src/core/mod.rs`
- **内容**: 在 `SocketMessage` 枚举中添加 `WhitelistMode(bool)`

### 改动点 3: 修改核心判断逻辑
- **文件**: `komorebi/src/window.rs`
- **内容**: 在 `window_is_eligible` 函数中添加白名单模式检查

### 改动点 4: 实现命令处理
- **文件**: `komorebi/src/process_command.rs`
- **内容**: 处理 `WhitelistMode` 命令

### 改动点 5: 配置文件支持
- **文件**: `komorebi/src/static_config.rs`
- **内容**: 在 `StaticConfig` 结构体中添加 `whitelist_mode` 字段

### 改动点 6: 状态查询支持
- **文件**: `komorebi/src/state.rs`
- **内容**: 在状态输出中包含白名单模式状态

### 改动点 7: CLI 命令支持
- **文件**: `komorebic/src/main.rs`
- **内容**: 添加 `whitelist-mode` 子命令

### 改动点 8: 更新示例配置
- **文件**: `docs/komorebi.example.json`
- **内容**: 添加白名单模式的说明和示例

## 详细实施步骤

---

## 步骤 1: 添加全局变量

### 目标
在 `lib.rs` 中添加白名单模式的全局开关。

### 文件
`komorebi/src/lib.rs`

### 具体操作

1. 找到全局变量定义区域（`MANAGE_IDENTIFIERS` 附近，约第 145 行）
2. 在 `MANAGE_IDENTIFIERS` 定义之后添加：

```rust
static ref WHITELIST_MODE_ENABLED: AtomicBool = AtomicBool::new(false);
```

3. 确保导入了 `AtomicBool`：

```rust
use std::sync::atomic::AtomicBool;
use std::sync::atomic::Ordering;
```

### 验证
- 运行 `cargo check -p komorebi` 确保编译通过
- 不需要运行程序

### 预期结果
编译成功，无错误。

---

## 步骤 2: 添加命令枚举

### 目标
在 `SocketMessage` 枚举中添加白名单模式切换命令。

### 文件
`komorebi/src/core/mod.rs`

### 具体操作

1. 找到 `SocketMessage` 枚举定义（约第 61 行）
2. 在合适的位置（建议在 `ManageRule` 附近，约第 232 行之后）添加：

```rust
/// Enable or disable whitelist mode
WhitelistMode(bool),
```

### 验证
- 运行 `cargo check -p komorebi` 确保编译通过
- 不需要运行程序

### 预期结果
编译成功，无错误。

---

## 步骤 3: 实现命令处理

### 目标
在 `process_command.rs` 中处理 `WhitelistMode` 命令。

### 文件
`komorebi/src/process_command.rs`

### 具体操作

1. 确保文件顶部导入了必要的模块：

```rust
use crate::WHITELIST_MODE_ENABLED;
use std::sync::atomic::Ordering;
```

2. 找到命令处理的 match 语句（约第 552 行，`ManageRule` 处理附近）
3. 添加新的 match 分支：

```rust
SocketMessage::WhitelistMode(enabled) => {
    WHITELIST_MODE_ENABLED.store(enabled, Ordering::SeqCst);

    let status = if enabled { "enabled" } else { "disabled" };
    tracing::info!("Whitelist mode {}", status);
}
```

### 验证
- 运行 `cargo check -p komorebi` 确保编译通过
- 不需要运行程序

### 预期结果
编译成功，无错误。

---

## 步骤 4: 修改核心判断逻辑（最关键）

### 目标
修改 `window_is_eligible` 函数，实现白名单模式的核心逻辑。

### 文件
`komorebi/src/window.rs`

### 具体操作

1. 确保文件顶部导入了必要的模块：

```rust
use crate::WHITELIST_MODE_ENABLED;
use std::sync::atomic::Ordering;
```

2. 找到 `window_is_eligible` 函数的最终返回语句（约第 1032-1042 行）：

```rust
if (allow_wsl2_gui || allow_titlebar_removed || style.contains(WindowStyle::CAPTION) && ex_style.contains(ExtendedWindowStyle::WINDOWEDGE))
    && !ex_style.contains(ExtendedWindowStyle::DLGMODALFRAME)
    && (allow_layered || !ex_style.contains(ExtendedWindowStyle::LAYERED))
    || managed_override
{
    return true;
}
```

3. 将这段代码修改为：

```rust
if (allow_wsl2_gui || allow_titlebar_removed || style.contains(WindowStyle::CAPTION) && ex_style.contains(ExtendedWindowStyle::WINDOWEDGE))
    && !ex_style.contains(ExtendedWindowStyle::DLGMODALFRAME)
    && (allow_layered || !ex_style.contains(ExtendedWindowStyle::LAYERED))
    || managed_override
{
    // 如果启用了白名单模式，只有在白名单中的窗口才返回 true
    if WHITELIST_MODE_ENABLED.load(Ordering::SeqCst) {
        return managed_override;
    }
    return true;
}
```

### 逻辑说明

**修改前的逻辑**:
- 符合条件的窗口 → 返回 true（管理）
- 在白名单中的窗口 → 返回 true（管理）

**修改后的逻辑**:
- 白名单模式关闭：保持原有行为
- 白名单模式开启：只有 `managed_override == true`（在白名单中）才返回 true

### 验证
- 运行 `cargo check -p komorebi` 确保编译通过
- 不需要运行程序

### 预期结果
编译成功，无错误。这是解决"启动时所有窗口都被管理"问题的关键。

---

## 步骤 5: 配置文件支持

### 目标
在 `StaticConfig` 中添加 `whitelist_mode` 字段，支持从配置文件加载。

### 文件
`komorebi/src/static_config.rs`

### 具体操作

#### 5.1 添加字段到 StaticConfig

1. 找到 `StaticConfig` 结构体定义（约第 455 行）
2. 在合适的位置（建议在 `manage_rules` 附近，约第 590 行之后）添加：

```rust
/// Enable whitelist mode (only manage windows in manage_rules)
#[serde(skip_serializing_if = "Option::is_none")]
#[cfg_attr(feature = "schemars", schemars(extend("default" = false)))]
pub whitelist_mode: Option<bool>,
```

#### 5.2 在配置加载时应用设置

1. 找到 `impl StaticConfig` 的 `apply` 方法（约第 1000 行开始）
2. 在 `manage_identifiers` 相关代码之后（约第 1073 行之后）添加：

```rust
// 应用白名单模式设置
if let Some(whitelist_mode) = self.whitelist_mode {
    WHITELIST_MODE_ENABLED.store(whitelist_mode, Ordering::SeqCst);
    tracing::info!("Whitelist mode: {}", if whitelist_mode { "enabled" } else { "disabled" });
}
```

3. 确保文件顶部导入了必要的模块：

```rust
use crate::WHITELIST_MODE_ENABLED;
use std::sync::atomic::Ordering;
```

#### 5.3 在配置生成时包含白名单模式

1. 找到 `impl From<&WindowManager> for StaticConfig`（约第 801 行）
2. 在返回的 `Self` 结构体中添加字段（建议在 `manage_rules` 附近）：

```rust
whitelist_mode: Some(WHITELIST_MODE_ENABLED.load(Ordering::SeqCst)),
```

### 验证
- 运行 `cargo check -p komorebi` 确保编译通过
- 不需要运行程序

### 预期结果
编译成功，无错误。

---

## 步骤 6: 状态查询支持

### 目标
在状态输出中包含白名单模式的状态，方便调试。

### 文件
`komorebi/src/state.rs`

### 具体操作

1. 找到 `State` 结构体定义
2. 添加字段：

```rust
/// Whitelist mode enabled
pub whitelist_mode: bool,
```

3. 找到 `State` 的构造位置（通常在 `impl` 块中）
4. 添加字段赋值：

```rust
whitelist_mode: WHITELIST_MODE_ENABLED.load(Ordering::SeqCst),
```

5. 确保文件顶部导入了必要的模块：

```rust
use crate::WHITELIST_MODE_ENABLED;
use std::sync::atomic::Ordering;
```

### 验证
- 运行 `cargo check -p komorebi` 确保编译通过
- 不需要运行程序

### 预期结果
编译成功，无错误。

---

## 步骤 7: CLI 命令支持

### 目标
在 `komorebic` CLI 工具中添加 `whitelist-mode` 命令。

### 文件
`komorebic/src/main.rs`

### 具体操作

#### 7.1 添加子命令枚举

1. 找到 `SubCommand` 枚举定义（约第 100 行开始）
2. 在合适的位置（建议在 `ManageRule` 附近）添加：

```rust
/// Enable or disable whitelist mode
#[clap(arg_required_else_help = true)]
WhitelistMode(WhitelistMode),
```

#### 7.2 定义命令参数结构

在文件的合适位置（通常在其他命令参数结构附近）添加：

```rust
#[derive(clap::Parser, Debug)]
pub struct WhitelistMode {
    /// Enable or disable whitelist mode
    #[clap(value_parser = clap::value_parser!(bool))]
    pub enable: bool,
}
```

#### 7.3 添加命令处理

1. 找到命令处理的 match 语句（约第 1500 行开始）
2. 添加新的 match 分支：

```rust
SubCommand::WhitelistMode(args) => {
    send_message(&SocketMessage::WhitelistMode(args.enable))?;
}
```

### 验证
- 运行 `cargo check -p komorebic` 确保编译通过
- 不需要运行程序

### 预期结果
编译成功，无错误。

---

## 步骤 8: 更新示例配置

### 目标
在示例配置文件中添加白名单模式的说明和示例。

### 文件
`docs/komorebi.example.json`

### 具体操作

在 JSON 文件的合适位置（建议在顶部）添加注释和配置：

```json
{
  "$schema": "https://raw.githubusercontent.com/LGUG2Z/komorebi/v0.1.41/schema.json",

  // 白名单模式：启用后只管理 manage_rules 中的窗口
  // 默认为 false，保持向后兼容
  // "whitelist_mode": false,

  // 白名单规则：这些窗口会被强制管理
  // 当 whitelist_mode 为 true 时，只有这些窗口会被管理
  // "manage_rules": [
  //   {
  //     "kind": "exe",
  //     "id": "notepad.exe",
  //     "matching_strategy": "equals"
  //   },
  //   {
  //     "kind": "title",
  //     "id": "Visual Studio Code",
  //     "matching_strategy": "contains"
  //   }
  // ],

  "app_specific_configuration_path": "$Env:USERPROFILE/applications.json",
  // ... 其他配置
}
```

### 验证
- 检查 JSON 语法是否正确
- 不需要编译或运行

### 预期结果
JSON 格式正确，注释清晰。

---

## 步骤 9: 完整编译测试

### 目标
确保所有改动都能正确编译。

### 操作

```bash
# 编译整个项目
cargo build --release

# 或者分别编译各个包
cargo build --release -p komorebi
cargo build --release -p komorebic
```

### 验证
- 编译成功，无错误
- 生成可执行文件

### 预期结果
- `target/release/komorebi.exe` 生成成功
- `target/release/komorebic.exe` 生成成功

---

## 步骤 10: 功能测试

### 目标
测试白名单模式是否正常工作。

### 前置准备

1. 备份当前配置：
```bash
cp %USERPROFILE%/komorebi.json %USERPROFILE%/komorebi.json.backup
```

2. 创建测试配置文件 `%USERPROFILE%/komorebi.json`：

```json
{
  "$schema": "https://raw.githubusercontent.com/LGUG2Z/komorebi/v0.1.41/schema.json",
  "whitelist_mode": true,
  "manage_rules": [
    {
      "kind": "exe",
      "id": "notepad.exe",
      "matching_strategy": "equals"
    }
  ],
  "default_workspace_padding": 20,
  "default_container_padding": 20,
  "border": true,
  "monitors": [
    {
      "workspaces": [
        {"name": "I", "layout": "BSP"}
      ]
    }
  ]
}
```

### 测试步骤

#### 测试 1: 启动时只管理白名单窗口

1. 关闭当前运行的 komorebi（如果有）：
```bash
komorebic stop
```

2. 打开几个不同的应用（如浏览器、资源管理器等）

3. 启动新编译的 komorebi：
```bash
komorebic start
```

4. **预期结果**：
   - 现有窗口不应该被管理（不会被平铺）
   - 只有记事本窗口会被管理

5. 打开记事本：
```bash
notepad.exe
```

6. **预期结果**：
   - 记事本窗口应该被平铺管理
   - 其他窗口仍然不受影响

#### 测试 2: 运行时切换白名单模式

1. 禁用白名单模式：
```bash
komorebic whitelist-mode false
```

2. 打开一个新的浏览器窗口

3. **预期结果**：
   - 浏览器窗口应该被管理（恢复默认行为）

4. 重新启用白名单模式：
```bash
komorebic whitelist-mode true
```

5. 打开一个新的资源管理器窗口

6. **预期结果**：
   - 资源管理器窗口不应该被管理

#### 测试 3: 查询状态

```bash
komorebic state
```

**预期结果**：
- 输出的 JSON 中应该包含 `"whitelist_mode": true` 或 `false`

#### 测试 4: 动态添加白名单规则

1. 添加浏览器到白名单：
```bash
komorebic manage-rule exe chrome.exe
```

2. 打开 Chrome 浏览器

3. **预期结果**：
   - Chrome 窗口应该被管理

### 测试后清理

```bash
# 停止 komorebi
komorebic stop

# 恢复原配置
cp %USERPROFILE%/komorebi.json.backup %USERPROFILE%/komorebi.json
```

---

## 常见问题排查

### 问题 1: 编译错误

**症状**: 编译时出现类型错误或未定义的符号

**排查**:
1. 检查是否正确导入了所有必要的模块
2. 检查 `AtomicBool` 和 `Ordering` 是否正确导入
3. 运行 `cargo clean` 后重新编译

### 问题 2: 启动时所有窗口仍被管理

**症状**: 启用白名单模式后，启动时所有窗口仍然被管理

**排查**:
1. 检查配置文件是否正确加载：
   ```bash
   komorebic state | grep whitelist_mode
   ```
2. 检查 `window_is_eligible` 函数的修改是否正确
3. 添加日志输出调试：
   ```rust
   tracing::info!("Whitelist mode: {}, managed_override: {}",
       WHITELIST_MODE_ENABLED.load(Ordering::SeqCst),
       managed_override);
   ```

### 问题 3: 白名单规则不生效

**症状**: 添加到白名单的窗口仍然不被管理

**排查**:
1. 检查匹配规则是否正确（exe 名称、匹配策略等）
2. 使用 `komorebic debug-window <hwnd>` 查看窗口信息
3. 检查窗口是否在 `IGNORE_IDENTIFIERS` 黑名单中

### 问题 4: 运行时切换不生效

**症状**: 使用 `komorebic whitelist-mode` 命令后没有效果

**排查**:
1. 检查命令是否正确发送：查看 komorebi 日志
2. 检查 `process_command.rs` 中的命令处理是否正确
3. 尝试重启 komorebi

---

## 回滚方案

如果测试失败需要回滚：

### 方案 1: 使用 Git 回滚

```bash
git checkout .
git clean -fd
```

### 方案 2: 使用备份的可执行文件

如果之前备份了原始的可执行文件：

```bash
# 恢复原始版本
cp komorebi.exe.backup target/release/komorebi.exe
cp komorebic.exe.backup target/release/komorebic.exe
```

### 方案 3: 重新编译原始版本

```bash
git stash
cargo build --release
```

---

## 成功标准

### 编译阶段
- ✅ 所有步骤都能成功编译
- ✅ 无编译警告（或只有预期的警告）
- ✅ 生成可执行文件

### 功能测试阶段
- ✅ 白名单模式关闭时，行为与原版本一致
- ✅ 白名单模式开启时，只管理白名单中的窗口
- ✅ 启动时不会管理非白名单窗口
- ✅ 可以通过配置文件设置白名单模式
- ✅ 可以通过命令行动态切换白名单模式
- ✅ 可以动态添加/删除白名单规则
- ✅ 状态查询能正确显示白名单模式状态

---

## 时间估算

| 步骤 | 预计时间 | 说明 |
|------|---------|------|
| 步骤 1-3 | 15 分钟 | 添加基础结构 |
| 步骤 4 | 10 分钟 | 修改核心逻辑 |
| 步骤 5-6 | 20 分钟 | 配置和状态支持 |
| 步骤 7 | 15 分钟 | CLI 命令 |
| 步骤 8 | 5 分钟 | 更新文档 |
| 步骤 9 | 10 分钟 | 编译测试 |
| 步骤 10 | 30 分钟 | 功能测试 |
| **总计** | **约 2 小时** | 包含测试和调试 |

---

## 下一步行动

准备好后，我们将按照以下顺序执行：

1. ✅ 创建项目分析文档（已完成）
2. ✅ 创建实施计划文档（已完成）
3. ⏳ 执行步骤 1：添加全局变量
4. ⏳ 执行步骤 2：添加命令枚举
5. ⏳ 执行步骤 3：实现命令处理
6. ⏳ 执行步骤 4：修改核心判断逻辑
7. ⏳ 执行步骤 5：配置文件支持
8. ⏳ 执行步骤 6：状态查询支持
9. ⏳ 执行步骤 7：CLI 命令支持
10. ⏳ 执行步骤 8：更新示例配置
11. ⏳ 执行步骤 9：完整编译测试
12. ⏳ 执行步骤 10：功能测试

---

**文档版本**: v1.0
**创建日期**: 2026-03-03
**预计完成时间**: 2 小时
