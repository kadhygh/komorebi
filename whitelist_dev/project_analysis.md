# Komorebi 项目分析文档

## 1. 项目概述

**项目名称**: komorebi
**项目类型**: Windows 平铺式窗口管理器（Tiling Window Manager）
**开发语言**: Rust
**架构模式**: 守护进程 + 客户端

## 2. 核心架构

### 2.1 层级结构

```
Monitor（显示器）
  └── Workspace（工作区）
        └── Container（容器）
              └── Window（窗口）
```

- **Monitor**: 对应物理显示器
- **Workspace**: 类似虚拟桌面，每个显示器可以有多个工作区
- **Container**: 平铺布局的基本单元
- **Window**: 对 Windows HWND 句柄的封装

### 2.2 进程模型

```
用户/脚本
   ↓ 命令行
komorebic (CLI 客户端)
   ↓ Named Pipe 通信
komorebi (守护进程)
   ↑ WinEvent Hook
Windows OS
```

- **komorebi**: 常驻后台的守护进程，负责窗口管理
- **komorebic**: 命令行客户端，发送指令给守护进程
- **通信方式**: Windows Named Pipe
- **事件监听**: 通过 WinEvent Hook 监听系统窗口事件

### 2.3 事件驱动模型

komorebi 有两类事件来源：

1. **系统事件**: Windows 窗口事件 → WinEvent Hook → `process_event.rs` 处理
2. **用户命令**: CLI 命令 → Named Pipe → `process_command.rs` 处理

## 3. 关键文件结构

```
komorebi/
├── komorebi/src/
│   ├── main.rs                 # 入口，启动事件循环
│   ├── lib.rs                  # 全局变量定义
│   ├── window_manager.rs       # 核心管理器
│   ├── window.rs               # 窗口封装和判断逻辑
│   ├── process_command.rs      # 处理用户命令
│   ├── process_event.rs        # 处理系统事件
│   ├── static_config.rs        # 配置文件处理
│   ├── core/
│   │   ├── mod.rs              # SocketMessage 枚举定义
│   │   └── config_generation.rs # 配置生成
│   └── layout/                 # 布局算法
├── komorebic/src/
│   └── main.rs                 # CLI 工具入口
└── docs/
    └── komorebi.example.json   # 示例配置文件
```

## 4. 窗口管理机制分析

### 4.1 核心数据结构

```rust
// lib.rs 中的全局变量
IGNORE_IDENTIFIERS: Arc<Mutex<Vec<MatchingRule>>>      // 黑名单
MANAGE_IDENTIFIERS: Arc<Mutex<Vec<MatchingRule>>>      // 白名单
FLOATING_APPLICATIONS: Arc<Mutex<Vec<MatchingRule>>>   // 浮动窗口
LAYERED_WHITELIST: Arc<Mutex<Vec<MatchingRule>>>       // 分层窗口白名单
```

### 4.2 窗口判断逻辑

**核心函数**: `window.rs::window_is_eligible()` (第 893-1042 行)

**判断流程**:

1. **永久忽略类检查** (第 905-910 行)
   ```rust
   if permaignore_classes.contains(class) {
       return false;  // 在永久忽略列表中，直接拒绝
   }
   ```

2. **黑名单检查** (第 914-927 行)
   ```rust
   let should_ignore = if let Some(rule) = should_act(..., &ignore_identifiers, ...) {
       true
   } else {
       false
   };
   ```

3. **白名单覆盖检查** (第 929-942 行)
   ```rust
   let managed_override = if let Some(rule) = should_act(..., &manage_identifiers, ...) {
       true  // 在白名单中
   } else {
       false
   };
   ```

4. **黑名单与白名单组合判断** (第 956-958 行)
   ```rust
   if should_ignore && !managed_override {
       return false;  // 在黑名单中且不在白名单中，不管理
   }
   ```

5. **最终判断** (第 1032-1042 行)
   ```rust
   if (窗口符合基本条件) || managed_override {
       return true;  // 符合条件或在白名单中，管理
   }
   ```

### 4.3 当前逻辑总结

**现有行为**:
- 默认：符合条件的窗口（有标题栏、窗口边框等）会被管理
- 黑名单：`IGNORE_IDENTIFIERS` 中的窗口不管理
- 白名单覆盖：`MANAGE_IDENTIFIERS` 中的窗口强制管理，即使在黑名单中

**关键变量**:
- `managed_override`: 表示窗口是否在 `MANAGE_IDENTIFIERS` 白名单中
- 这是**原有变量**，不是新增的

## 5. 配置系统

### 5.1 配置文件结构

**配置文件**: `komorebi.json` (位于 `%USERPROFILE%` 或 `%KOMOREBI_CONFIG_HOME%`)

**核心结构**: `static_config.rs::StaticConfig` (第 455 行开始)

**相关字段**:
```rust
pub struct StaticConfig {
    pub ignore_rules: Option<Vec<MatchingRule>>,      // 黑名单规则
    pub manage_rules: Option<Vec<MatchingRule>>,      // 白名单规则
    pub floating_applications: Option<Vec<MatchingRule>>,
    // ... 其他配置
}
```

### 5.2 配置加载

**加载位置**: `static_config.rs::apply()` (第 1071-1093 行)

```rust
let mut manage_identifiers = MANAGE_IDENTIFIERS.lock();

if let Some(rules) = &mut self.manage_rules {
    populate_rules(rules, &mut manage_identifiers, &mut regex_identifiers)?;
}
```

### 5.3 配置生成

**Quickstart 命令**: `komorebic/src/main.rs::Quickstart` (第 1705-1797 行)
- 从 `docs/komorebi.example.json` 读取模板
- 写入到用户配置目录
- 生成 `komorebi.json`, `komorebi.bar.json`, `applications.json`, `whkdrc`

**GenerateStaticConfig 命令**: `process_command.rs` (第 2258-2262 行)
- 从当前运行状态生成配置
- 通过 `impl From<&WindowManager> for StaticConfig` 实现

### 5.4 配置示例

```json
{
  "$schema": "https://raw.githubusercontent.com/LGUG2Z/komorebi/v0.1.41/schema.json",
  "ignore_rules": [
    {
      "kind": "exe",
      "id": "explorer.exe",
      "matching_strategy": "equals"
    }
  ],
  "manage_rules": [
    {
      "kind": "exe",
      "id": "notepad.exe",
      "matching_strategy": "equals"
    }
  ]
}
```

## 6. 命令系统

### 6.1 命令定义

**位置**: `core/mod.rs::SocketMessage` (第 61 行开始)

**相关命令**:
```rust
pub enum SocketMessage {
    ManageRule(ApplicationIdentifier, String),        // 添加白名单规则
    IgnoreRule(ApplicationIdentifier, String),        // 添加黑名单规则
    ManageFocusedWindow,                              // 管理当前窗口
    UnmanageFocusedWindow,                            // 取消管理当前窗口
    // ... 其他命令
}
```

### 6.2 命令处理

**位置**: `process_command.rs::process_command()` (第 552 行开始)

**ManageRule 处理**:
```rust
SocketMessage::ManageRule(identifier, ref id) => {
    let mut manage_identifiers = MANAGE_IDENTIFIERS.lock();

    // 检查是否已存在
    let mut should_push = true;
    for m in &*manage_identifiers {
        if let MatchingRule::Simple(m) = m && m.id.eq(id) {
            should_push = false;
        }
    }

    if should_push {
        manage_identifiers.push(MatchingRule::Simple(IdWithIdentifier {
            kind: identifier,
            id: id.clone(),
            matching_strategy: Option::from(MatchingStrategy::Equals),
        }));
    }
}
```

## 7. 用户需求分析

### 7.1 目标

实现**纯白名单模式**：只有在白名单中的窗口才会被 komorebi 管理。

### 7.2 与现有机制的区别

| 特性 | 现有机制 | 白名单模式 |
|------|---------|-----------|
| 默认行为 | 符合条件的窗口都管理 | 不管理任何窗口 |
| 黑名单作用 | 排除特定窗口 | 无作用 |
| 白名单作用 | 覆盖黑名单 | 唯一的管理依据 |
| 启动时行为 | 管理所有符合条件的窗口 | 只管理白名单中的窗口 |

### 7.3 用户反馈的问题

> "之前尝试过，安装完成后一启动所有的窗口就都被管理了"

**问题分析**:
- 之前的实现可能没有正确应用白名单逻辑
- 启动时的窗口判断没有检查白名单模式开关
- 需要确保在 `window_is_eligible` 函数中正确实现白名单模式

## 8. 技术要点

### 8.1 全局状态管理

使用 `lazy_static` + `Arc<Mutex<T>>` 模式：
```rust
lazy_static! {
    static ref MANAGE_IDENTIFIERS: Arc<Mutex<Vec<MatchingRule>>> =
        Arc::new(Mutex::new(vec![]));
}
```

### 8.2 匹配规则

**MatchingRule 类型**:
```rust
pub enum MatchingRule {
    Simple(IdWithIdentifier),
    Composite(Vec<IdWithIdentifier>),
}

pub struct IdWithIdentifier {
    pub kind: ApplicationIdentifier,      // exe, class, title, path
    pub id: String,
    pub matching_strategy: Option<MatchingStrategy>,  // equals, contains, regex
}
```

### 8.3 向后兼容性

**重要原则**:
- 默认行为不能改变（白名单模式默认关闭）
- 现有配置文件必须继续工作
- 不能破坏现有的 API 和命令

## 9. 实施关键点

### 9.1 最小改动原则

- 复用现有的 `managed_override` 变量
- 复用现有的 `MANAGE_IDENTIFIERS` 全局变量
- 只添加一个开关来改变判断逻辑

### 9.2 关键修改点

1. **添加全局开关**: `WHITELIST_MODE_ENABLED`
2. **修改判断逻辑**: 在 `window_is_eligible` 函数的返回前添加检查
3. **配置文件支持**: 在 `StaticConfig` 中添加 `whitelist_mode` 字段
4. **命令支持**: 添加 `WhitelistMode(bool)` 命令用于运行时切换

### 9.3 测试策略

1. **编译验证**: 前期只需要确保代码能编译通过
2. **功能测试**: 所有代码完成后，准备测试配置文件
3. **安全测试**: 使用测试配置启动，只管理白名单中的窗口

---

**文档版本**: v1.0
**创建日期**: 2026-03-03
**分析范围**: komorebi v0.1.41
