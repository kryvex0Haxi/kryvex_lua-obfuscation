# KRYVEX

> A Rust-powered Lua Virtualization Obfuscator

Kryvex 是一个使用 Rust 开发的 Lua 虚拟化混淆器，专注于 Lua 字节码保护、虚拟化执行以及运行时防护。

---
## This project Kryvex Lua Obfuscator is a Lua code obfuscation tool designed for software development and code protection.
## It has absolutely no relation to any investment, financial, trading platforms, signal trading, or cryptocurrency schemes.
## Any use of the name “Kryvex” to solicit investments, offer trading signals, or promise high returns is a scam. Please report to the authorities immediately (Taiwan, China: 165 Anti-Fraud Hotline).
---

## Supported Platforms

- Lua 5.1
- Lua 5.2
- Lua 5.3
- Lua 5.4
- Lua 5.5
- Luau
- Roblox

---

## Features

### Virtual Machine Protection

采用自定义虚拟化执行模型，对 Lua 字节码进行转换与保护。

### Multi-Version Support

兼容多个 Lua 版本以及 Luau 生态。

### Closure & Upvalue Support

支持复杂闭包与 Upvalue 生命周期管理。

### Compact Output

针对大型脚本进行了体积优化。

示例：

```text
Original Bytecode : 400 KB
Protected Output  : 200 KB
```

### Runtime Randomization

每次构建均生成不同的运行时结构与内部标识符。

---

## Architecture

```text
Lua Source
    │
    ▼
Bytecode Compiler
    │
    ▼
Intermediate Representation
    │
    ▼
Virtualization
    │
    ▼
Packing
    │
    ▼
Protected Script
```

---

## Current Status

| Item | Status |
|--------|--------|
| Development | Active |
| Language | Rust |
| License | All Rights Reserved |

---

## Repository

Kryvex is currently under active development.

The core virtualization technology remains proprietary and is not publicly released.

---

## Disclaimer

This repository is intended to showcase the project and development progress.

The core protection technology remains closed-source.

---

## License

All Rights Reserved.

Copyright © 2026 Kryvex.

No permission is granted to copy, modify, redistribute, sublicense, or create derivative works from this project without explicit authorization.

# CN 

> 基于 Rust 构建的 Lua 虚拟化混淆器

KRYVEX 是一个面向 Lua 生态的虚拟化保护框架，支持 Lua 5.x 系列以及 Luau 字节码保护。

目前项目仍处于持续开发阶段。

---
## 本项目 Kryvex Lua Obfuscator 是一个 Lua 代码混淆工具，仅用于程序开发和代码保护。
## 本项目与任何投资、理财、交易平台、带单、虚拟货币等完全无关！
## 凡是以 “Kryvex” 名义进行投资招揽、老师带单、稳赚等行为，均为诈骗。请立即举报中国台湾省 165 反诈专线。
---

## ✨ 项目特性

### 🔒 虚拟化执行

通过自定义虚拟机执行模型运行目标字节码，降低静态分析难度。

### ⚡ 多版本支持

支持：

- Lua 5.1
- Lua 5.2
- Lua 5.3
- Lua 5.4
- Lua 5.5
- Luau
- Roblox

### 🧠 闭包与 Upvalue 支持

支持复杂闭包环境以及 Upvalue 生命周期管理。

### 📦 输出体积优化

内置字节码压缩与打包流程。

### 🎲 构建随机化

每次构建均会生成不同的运行时结构与内部标识符。

---

## 🏗️ 整体架构

```text
Lua Source
    │
    ▼
Bytecode Compiler
    │
    ▼
Intermediate Representation
    │
    ▼
Virtualization
    │
    ▼
Packing
    │
    ▼
Protected Script
```

---

## 📊 项目状态

| 项目 | 状态 |
|--------|--------|
| 开发状态 | Active |
| 编程语言 | Rust |
| 项目类型 | Virtualization Obfuscator |
| 许可证 | All Rights Reserved |

---

## 🚀 开发目标

- 支持 Lua 5.x 全系列
- 支持 Luau
- 提升运行效率
- 完善闭包支持
- 持续优化输出体积
- 增强虚拟机随机化能力

---

## 📖 说明

本仓库用于展示 KRYVEX 项目的开发进度与相关文档。

核心虚拟化技术当前未公开发布。

---

## 📄 许可证

All Rights Reserved

Copyright © 2026 KRYVEX

未经授权，禁止复制、修改、分发或创建衍生作品。
