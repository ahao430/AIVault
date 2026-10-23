> **当前状态（2026-10-23）**：P0-P3 已全部实现并发布（含桌面小组件与 HyperOS 变体 +
> 自动刷新、终端 AI 助手多轮续跑、坚果云 WebDAV 预设、Komari 探针监控、工作台
> 订阅/探针管理与首页展示开关）。当前功能清单与截图见
> [README](./README.md)，逐版本变更见 [CHANGELOG](./CHANGELOG.md)。本文档保留为
> 设计基线，未实现条目见文末路线（P4：SFTP / 端口转发 / MiniMax 适配器 / 更多探针面板 / iOS 小组件）。

---
# AI 订阅管理 App

> 一个以 **AI 订阅与 API 账号管理** 为核心，同时提供 AI 工作台、远程 Agent 会话、SSH 管理能力的本地优先跨平台 App。
>
> 技术方案：**Flutter 跨平台 + 本地优先 + WebDAV 可选同步**
>
> MVP 重点：**订阅管理、额度查询、重置时间、批量预热/签到、Token/模型管理、临时模型测试**
>
> 增强能力：**AI 聊天、AI 画图、SSH、tmux Agent 远程会话、CC Switch/Magpie 导出**

---

# 1. 产品定位

## 1.1 产品定位

AI 订阅越来越多，用户通常同时拥有：

- Claude / OpenAI / 智谱等官方订阅
- 各种 AI API 中转站
- NewAPI / Sub2API 等自建或企业网关
- 多个账户
- 一个账户下多个 API Token
- 不同 Token 对应不同模型
- 不同供应商具有不同额度、余额和重置周期

现有桌面工具如 CC Switch、Magpie 更偏向：

> **快速切换 AI Provider / Agent 配置**

本 App 的定位则是：

> **AI 订阅与账号的移动端管理中心**

核心目标：

1. 随时查看所有 AI 订阅状态。
2. 查看额度、余额和重置时间。
3. 在额度恢复后手动或批量预热。
4. 对中转站执行签到。
5. 管理供应商、账号、Token 和模型。
6. 临时测试某个模型是否可用。
7. 手机随时继续电脑上的 Claude Code / Codex / OpenCode / Pi 会话。
8. 在手机上直接使用已配置的 AI 模型聊天和画图。
9. 配置通过 WebDAV 在不同设备之间同步。

---

# 2. 产品原则

## 2.1 订阅管理是第一核心

聊天、画图、SSH、Agent 都是增强能力。

首页第一优先级仍然是：

> **供应商 → 额度 / 余额 → 重置时间 → 快捷操作**

不能因为增加 AI 工作台和远程开发而把首页变成普通 AI Chat App。

---

## 2.2 本地优先

MVP 不依赖自建服务器。

核心数据：

- 供应商
- 账户
- Token
- 模型
- 额度快照
- 测试记录
- 聊天记录
- 画图历史
- SSH 主机
- Agent 会话配置

默认保存在本地。

---

## 2.3 手机完全独立

电脑端不需要与手机 App 做数据同步。

电脑相关能力通过：

> Tailscale + SSH + tmux

实现远程连接。

WebDAV 只用于：

> 用户自己的多个设备之间同步 App 数据。

---

# 3. 平台

使用：

**Flutter**

目标平台：

- iOS
- Android
- macOS
- Windows
- Linux（视 Flutter 实际支持情况）

MVP 优先：

> iOS / Android / macOS / Windows

---

# 4. 整体导航

底部固定三个 Tab：

```text
┌─────────────────────────┐
│                         │
│       当前页面           │
│                         │
├─────────────────────────┤
│                         │
│   首页    工作台    设置  │
└─────────────────────────┘
```

不再提供：

> 「聊天 + 画图合并工作台」和「聊天 + 画图独立 Tab」

两种导航模式。

原因：

随着功能增加，工作台已经包含：

- AI 聊天
- AI 画图
- 远程 Agent
- SSH

继续让每个功能占一个底部 Tab 会造成导航过度拥挤。

---

# 5. 首页

首页是 App 最核心的页面。

定位：

> **AI 资源综合看板**

但不是传统 Dashboard。

核心仍然是：

> **订阅列表卡片**

---

## 5.1 首页结构

```text
首页
│
├── 进行中的远程会话
│
├── 订阅列表
│
└── API / 中转站
```

---

## 5.2 远程会话区域

放在首页顶部。

只显示：

- 在线 SSH 主机
- 正在运行 / 最近使用的 Agent
- 少量重要会话

例如：

```text
远程开发                         查看全部 >

┌────────────────────────────┐
│ 🟢 Mac Studio               │
│ SSH 已连接                  │
│                            │
│ Claude Code                │
│ new-api · tmux:newapi      │
│ 正在运行                    │
│                            │
│ Codex                      │
│ goal-app · tmux:goal-app   │
│ 等待输入                    │
└────────────────────────────┘
```

不把所有历史 tmux 会话全部放到首页。

---

# 6. 订阅列表

订阅列表是首页主体。

支持：

- 排序
- 置顶
- 隐藏
- 手动刷新
- 单个预热
- 批量预热
- 单个签到
- 批量签到

---

## 6.1 供应商卡片

```text
┌────────────────────────────┐
│ ⭐ 智谱 AI                  │
│                            │
│ 5 小时额度                 │
│ ████████████████ 100%      │
│                            │
│ ♻ 4小时58分钟后重置         │
│                            │
│ ♨ 额度已满，可预热          │
│                            │
│              [立即预热]     │
└────────────────────────────┘
```

中转站：

```text
┌────────────────────────────┐
│ 某某中转站                  │
│                            │
│ ¥128.50                    │
│ 余额                        │
│                            │
│ 3 个令牌 · 28 个模型       │
│                            │
│ ● 今日可签到                │
│                            │
│ [签到]                     │
└────────────────────────────┘
```

---

# 7. 批量操作

首页订阅区域提供：

> **批量签到 / 预热**

可以设计成统一按钮：

```text
批量操作

[签到全部] [预热全部]
```

或者：

```text
批量操作
┌──────────────────────────┐
│ ✓ 批量签到                │
│ ♨ 批量预热                │
└──────────────────────────┘
```

---

## 7.1 批量签到规则

只处理：

> 开启签到能力 + 当前允许签到的供应商。

已经签到：

> 跳过。

签到失败：

> 单独记录失败原因。

最终展示：

```text
批量签到完成

成功  5
跳过  2
失败  1

[查看结果]
```

---

# 8. 批量预热

预热是核心功能。

必须遵循：

> **只有额度达到 100% 才执行预热。**

否则不执行，避免浪费 Token。

---

## 8.1 预热判断

```text
查询额度
    │
    ├── 100%
    │     ↓
    │   执行预热
    │
    ├── <100%
    │     ↓
    │   跳过
    │
    └── 查询失败 / 状态未知
          ↓
        跳过
```

不能因为查询失败就盲目执行预热。

---

## 8.2 预热状态

支持：

- 未预热
- 预热中
- 预热成功
- 预热失败
- 已跳过
- 等待额度恢复

---

# 9. 供应商模型

供应商与账户必须区分。

核心规则：

> **同一个供应商下的不同账户，视为不同供应商实例。**

例如：

```text
Claude - 个人账号
Claude - 公司账号
Claude - 备用账号
```

虽然都是 Claude，但因为账户不同：

> 三个独立供应商实例。

---

## 9.1 供应商

```text
Provider
│
├── 基础信息
├── 账户信息
├── 额度能力
├── 签到能力
├── 预热能力
│
└── Tokens
      ├── Token A
      ├── Token B
      └── Token C
```

---

# 10. Token 二级结构

一个账户可以拥有多个 Token。

这是供应商下面的第二级结构。

```text
智谱 AI
│
├── Token A
│   ├── glm-5.2
│   ├── glm-5.3-flash
│   └── deepseek-v4
│
├── Token B
│   ├── glm-5.2
│   └── glm-4
│
└── Token C
    └── glm-5.3-flash
```

同一个账户：

> Base URL 通常相同。

但不同 Token：

> 模型权限可以完全不同。

---

# 11. 官方订阅

官方订阅作为独立 Provider 类型。

例如：

- Claude
- ChatGPT
- 智谱
- 其他官方订阅

官方订阅不强制要求用户填写普通 API Base URL。

某些官方服务可能：

- Web 登录
- API Base URL 不同
- 官方订阅额度查询接口不同
- 需要网页授权

这些由官方适配器处理。

---

# 12. 官方订阅网页登录授权

MVP 可以预留能力。

目标：

> 尽量减少用户手动复制 Cookie / Token。

优先采用：

- OAuth
- 官方授权页面
- 系统浏览器授权
- App 内 WebView（如果官方允许）

不允许通过非官方方式绕过登录安全机制。

不同官方供应商独立适配。

---

# 13. 中转站

支持：

- 普通 API 中转站
- NewAPI
- Sub2API
- 自建网关

一个中转站通常：

```text
Provider
│
├── Base URL
│
├── Token A
├── Token B
└── Token C
```

中转站的 Base URL 通常相同。

---

# 14. NewAPI / Sub2API 专属能力

对于支持管理接口的中转站，可以提供：

### 余额查询

使用：

> 系统 Token / 管理 Token

而不是普通用户 Token。

---

### 一键签到

如果中转站提供签到能力：

```text
[今日签到]
```

支持批量签到。

---

### 余额查询

显示：

- 当前余额
- 更新时间
- 币种
- 查询状态

---

# 15. 供应商详情

点击首页供应商进入。

```text
供应商详情

‹ 智谱 AI

🟢 正常

账号：xxx

额度
████████████ 100%

4小时58分钟后重置

[刷新额度] [立即预热]

令牌                         ＋

┌──────────────────────────┐
│ Token A                  │
│ sk-xxxx                  │
│                    📋    │
│                          │
│ 12 个模型                │
│ ▼ 查看模型               │
└──────────────────────────┘

┌──────────────────────────┐
│ Token B                  │
│ sk-yyyy                  │
│                    📋    │
│                          │
│ 5 个模型                 │
│ ▼ 查看模型               │
└──────────────────────────┘
```

---

# 16. Token 模型列表

展开 Token：

```text
Token A

12 个模型

glm-5.2                 [测试]
最近：成功 · 10:32

glm-5.3-flash           [测试]
最近：成功 · 10:31

deepseek-v4              [测试]
最近：失败 · 09:12
```

---

# 17. 模型测试

不是持续健康检测。

定位：

> **用户临时测试某个模型是否可用。**

每个模型提供：

> `[测试]`

测试记录：

```text
模型
glm-5.2

最近测试
● 成功   10:32
● 成功   09:15
● 失败   昨天 23:11
```

记录：

- 时间
- 成功 / 失败
- 延迟
- HTTP 状态
- 错误类型
- 简短错误信息

这自然形成一个：

> **轻量模型可用性历史**

但不做持续健康度监控。

---

# 18. 模型测试分类

尽可能区分：

- 成功
- 认证失败
- 无权限
- 模型不存在
- 余额不足
- 限流
- 上游错误
- 超时
- 协议不兼容
- 未知错误

不能简单显示：

> 模型不可用

因为失败原因可能根本不是模型本身。

---

# 19. Token 详情

```text
Token A

所属：
智谱 AI

API Key
sk-****************    📋

Base URL
https://xxx/v1          📋

模型
12 个

最近测试
glm-5.2      ✓
glm-5.3      ✓
deepseek-v4  ✕

快捷操作

[复制令牌]

[导出到 CC Switch]

[导出到 Magpie]
```

---

# 20. CC Switch / Magpie 导出

导出能力放在：

> **Token 层**

不是供应商层。

原因：

一个供应商可以有多个 Token，而真正导出的凭证是具体 Token。

---

## 20.1 CC Switch

生成 CC Switch 可识别的导入链接。

流程：

```text
Token
 ↓
导出到 CC Switch
 ↓
选择目标配置
 ↓
生成链接
 ↓
复制到剪贴板
```

---

## 20.2 Magpie

同样生成 Magpie 可识别的导入链接。

```text
Token
 ↓
导出到 Magpie
 ↓
生成链接
 ↓
复制
```

---

## 20.3 安全

链接可能包含 API Key。

必须明确提示：

> 此链接可能包含 API Key，请勿发送给他人或公开发布。

不设计本 App 自己的二维码 / 分享协议。

当前阶段：

> **不做本 App 设备二维码分享。**

因为个人设备之间使用 WebDAV 更合理。

---

# 21. 工作台

底部第二个 Tab：

> 工作台

不直接展开所有功能。

采用功能入口卡片。

```text
工作台

┌─────────────┐ ┌─────────────┐
│             │ │             │
│    💬       │ │    🎨       │
│  AI 聊天    │ │  AI 画图    │
│             │ │             │
└─────────────┘ └─────────────┘

┌─────────────────────────────┐
│                             │
│       🖥 远程开发            │
│       SSH / Agent / tmux    │
│                             │
└─────────────────────────────┘
```

以后可以继续增加其他工具。

---

# 22. AI 聊天

聊天是连续会话。

支持：

- 新建会话
- 会话历史
- 删除
- 重命名
- 模型选择
- Token / Provider 选择
- 流式输出
- 停止生成
- 复制消息
- 导出长图

聊天历史：

> **只保存本地**

---

# 23. Chat 数据结构

```text
Conversation
│
├── id
├── title
├── providerId
├── tokenId
├── model
├── createdAt
├── updatedAt
│
└── Messages
      ├── role
      ├── content
      ├── createdAt
      └── metadata
```

---

# 24. 聊天富内容渲染

支持：

### P0

- Markdown
- 标题
- 列表
- 表格
- 引用
- 链接
- 代码块
- 语法高亮
- 代码复制

### 增强能力

- LaTeX
- Mermaid
- PlantUML
- ECharts
- Ant Design Charts

其中：

> Markdown / LaTeX / Mermaid / PlantUML 使用已有通用规范。

ECharts / Ant Design Charts：

> 使用官方配置规范，但 App 自定义 AI 输出围栏协议。

例如：

````markdown
```echarts
{
  "title": {
    "text": "调用量"
  },
  "xAxis": {},
  "yAxis": {},
  "series": []
}
```
````

AI 是否使用这些格式：

> 通过聊天请求中的系统提示词 /能力声明告知模型。

不是模型天然知道 App 支持这些自定义格式。

---

# 25. 聊天导出

支持：

### 复制

- 复制单条消息
- 复制代码
- 复制公式源码
- 复制图表配置

### 长图

整个会话：

> 导出成长图。

要求：

- Markdown 已渲染
- 代码已渲染
- 公式已渲染
- Mermaid / PlantUML 已渲染
- 图表已渲染

再进行最终排版。

---

# 26. AI 画图

画图是：

> **单次生成任务**

不是连续聊天。

```text
AI 画图

模型
GPT Image 2 ▼

提示词

┌───────────────────────┐
│ 描述你想生成的图片... │
│                       │
└───────────────────────┘

参考图

[＋ 添加参考图]

[生成图片]

历史
```

---

# 27. 画图历史

每个任务保存：

- Prompt
- 模型
- 时间
- 参考图
- 生成结果
- 参数
- 尺寸
- 生成状态

---

# 28. 图片详情

```text
图片详情

[生成结果]

提示词
一只坐在窗边的橘猫……

参考图
[缩略图] [缩略图]

模型
GPT Image 2

时间
2026-10-16 10:32

[复制图片]
[保存 / 下载]
```

支持：

- 预览
- 放大
- 复制图片
- 下载 / 保存
- 查看 Prompt
- 查看参考图

历史：

> 本地保存。

---

# 29. 远程开发

工作台入口：

> 远程开发

内部包含：

```text
远程开发
│
├── Agent 会话
├── SSH 主机
└── SSH 终端
```

---

# 30. 远程 Agent 定位

不做通用 Agent Server。

不做复杂公网中继。

不做 Agent API 深度集成。

只要求：

1. 手机和电脑使用 Tailscale。
2. 电脑开启 SSH。
3. 电脑使用 tmux 启动 Agent。

支持：

- Claude Code
- Codex
- OpenCode
- Pi

---

# 31. 远程 Agent 架构

```text
Flutter App
     │
     │ Tailscale
     ↓
    SSH
     │
     ↓
   tmux
     │
     ├── Claude Code
     ├── Codex
     ├── OpenCode
     └── Pi
```

手机：

> 通过 SSH 操作 tmux。

底层依然是：

> 终端。

手机展示：

> 聊天式 UI。

---

# 32. 首次使用引导

```text
开始远程开发

① 手机和电脑登录同一个 Tailscale

② 电脑开启 SSH

③ 安装 tmux

④ 使用 tmux 启动
   Claude Code / Codex /
   OpenCode / Pi

⑤ 在 App 中添加电脑

[开始配置]
```

---

# 33. Agent 会话列表

```text
进行中的 Agent

Mac Studio

┌─────────────────────────┐
│ Claude Code             │
│ ~/workspace/new-api     │
│ tmux: newapi            │
│ 🟢 运行中               │
└─────────────────────────┘

┌─────────────────────────┐
│ Codex                   │
│ ~/workspace/goal-app    │
│ tmux: goal-app          │
│ 🟡 等待输入             │
└─────────────────────────┘
```

---

# 34. Agent 聊天页面

复用普通聊天组件。

```text
Claude Code

Mac Studio · new-api
tmux:newapi · 🟢

────────────────────────

Agent：

已经完成以下修改：

src/xxx.ts
src/yyy.ts

────────────────────────

你：

继续处理测试问题

────────────────────────

Agent：

正在执行测试……

────────────────────────

输入指令...             ↑

[终端]
```

---

# 35. 终端兜底

聊天式解析无法可靠处理所有终端内容。

所以必须提供：

> **终端视图**

例如：

```text
[聊天] [终端]
```

遇到：

- 复杂 TUI
- 权限确认
- 终端界面重绘
- 聊天解析失败
- 需要手动操作终端

可以直接切换终端。

---

# 36. tmux 操作

底层支持：

```text
tmux list-sessions
tmux capture-pane
tmux send-keys
```

核心能力：

- 获取 Session 列表
- 识别 Agent
- 恢复 Session
- 获取输出
- 发送输入
- 断线重连

注意：

> tmux Session 存在 ≠ Agent 一定正在运行。

状态判断需要谨慎。

---

# 37. SSH 管理

SSH 不独立占底部 Tab。

作为远程开发的基础能力。

```text
SSH 主机

Mac Studio
🟢 已连接

Ubuntu Server
🟢 已连接

Home Server
🟡 最近连接：昨天
```

---

# 38. SSH 主机数据

```text
SshHost
│
├── id
├── name
├── host
├── port
├── username
├── authType
├── privateKey
├── password
├── createdAt
└── updatedAt
```

敏感信息不直接存普通数据库字段。

---

# 39. SSH 添加

支持：

- Host
- Port
- Username
- SSH Key
- Password
- Tailscale 地址 / MagicDNS

优先：

> SSH Key。

第一次连接：

> 校验 SSH Host Key。

不能默认无条件信任所有主机。

---

# 40. SSH 终端

需要真正的 Terminal Emulator。

不能简单用文本输入框模拟。

支持：

- ANSI
- 光标控制
- Ctrl
- Tab
- Esc
- 方向键
- 全屏 TUI
- 复制粘贴
- tmux

---

# 41. 首页远程状态

首页只展示：

> **进行中的远程会话**

例如：

```text
远程开发

🟢 Mac Studio

Claude Code
new-api
运行中

Codex
goal-app
等待输入

查看全部 >
```

SSH 主机本身也可以展示在线状态。

---

# 42. 供应商排序

供应商支持：

- 置顶
- 排序
- 隐藏

默认排序建议：

```text
置顶
↓
官方订阅
↓
常用中转站
↓
其他中转站
```

但排序规则最终由用户控制。

特别是：

> 不常用的小中转站可以放到后面。

---

# 43. 额度模型

不要统一用一个「剩余百分比」。

根据能力展示不同指标。

| 类型 | 展示 |
|---|---|
| 5 小时额度 | 剩余比例 + 重置时间 |
| 周额度 | 剩余比例 + 重置时间 |
| API 余额 | 金额 + 币种 |
| API 用量 | 已用量 + 周期 |
| RPM | RPM |
| TPM | TPM |
| 订阅 | 价格 + 续费时间 |

---

# 44. 数据可信度

额度数据必须记录：

- 数据来源
- 查询时间
- 成功 / 失败
- 是否官方数据
- 是否估算
- 是否过期

查询失败：

> 保留上一次成功数据。

不要显示成 0。

---

# 45. 额度快照

保存额度历史：

```text
QuotaSnapshot

providerId
timestamp
remaining
total
resetAt
source
status
```

用途：

- 当前额度
- 重置倒计时
- 历史记录
- 异常变化判断
- 后续统计

---

# 46. 供应商适配器

这是整个 App 最重要的技术抽象之一。

统一接口：

```text
ProviderAdapter

├── getAccountInfo()
├── getQuota()
├── getBalance()
├── getModels()
├── testModel()
├── prewarm()
├── checkIn()
└── authorize()
```

每个能力独立声明是否支持。

例如：

```text
Claude
✓ quota
✓ authorization
✓ prewarm
✗ checkIn

NewAPI
✓ balance
✓ models
✓ testModel
✓ checkIn

某中转站
✓ balance
✓ testModel
✗ checkIn
```

不能因为某供应商支持模型调用，就默认认为它支持额度查询、签到等能力。

---

# 47. 适配器状态

记录：

- 适配器版本
- 最近成功时间
- 最近失败时间
- 错误原因
- 支持能力

供应商接口变化后：

> 可以独立更新适配器。

---

# 48. 任务中心

建议所有异步操作统一进入任务系统。

包括：

- 批量签到
- 批量预热
- 批量刷新额度
- 模型测试
- WebDAV 同步

任务：

```text
Task
│
├── pending
├── running
├── success
├── failed
├── skipped
└── cancelled
```

支持：

- 进度
- 失败原因
- 重试
- 取消
- 查看结果

---

# 49. 通知

重点不是制造通知，而是：

> **真正需要用户行动时提醒。**

例如：

- 额度已经恢复
- 可以预热
- 签到可用
- 订阅即将续费
- SSH Agent 任务完成
- Agent 等待用户输入
- Agent 等待确认
- WebDAV 同步失败

支持：

- 开关
- 分类
- 去重
- 合并通知

---

# 50. WebDAV

定位：

> **个人设备同步**

不是公网数据服务。

同步内容：

- Provider
- Account
- Token
- Model
- Quota Snapshot
- Chat History
- Image History
- SSH Host 配置

敏感信息：

> 单独控制是否同步。

---

# 51. WebDAV 冲突

必须考虑：

```text
手机修改
      │
      ├── 云端未修改 → 上传
      │
      └── 云端已修改
              ↓
          冲突检测
              ↓
       选择本地 / 云端
```

不能简单：

> 云端覆盖本地。

---

# 52. 不同步 SSH 私钥

默认：

> **SSH 私钥不进入 WebDAV。**

因为私钥属于最高敏感级别。

可以同步：

- Host
- Port
- Username
- Host Name
- 连接配置

私钥需要在每台设备重新导入。

---

# 53. 安全

敏感数据：

- API Key
- Token
- OAuth Credential
- SSH Password
- SSH Private Key
- WebDAV Password

使用：

> iOS Keychain / Android Keystore / macOS Keychain / Windows Credential Manager 等系统安全存储。

普通数据库只保存引用。

---

# 54. App 锁

建议支持：

- Face ID / Touch ID
- 指纹
- 系统生物识别
- PIN

可配置：

```text
启动 App 时
切后台后
查看 Token 时
复制 Token 时
```

---

# 55. 导入导出

支持本地：

> JSON 导入 / 导出。

用途：

- 数据备份
- 设备迁移
- 手工编辑
- 故障恢复

导出时：

> 默认脱敏。

如果包含 Token：

> 明确警告。

---

# 56. 二维码

当前 MVP：

> **不做本 App 自己的二维码同步协议。**

原因：

个人设备之间：

> WebDAV 更方便。

外部分享：

> 目前没有统一的 Base URL + Token 标准。

而 CC Switch / Magpie 已经有自己的导入链接机制。

因此：

> 优先支持 Token 层生成 CC Switch / Magpie 导入链接。

未来如果有明确需求，再增加 App 自有分享协议。

---

# 57. 本地数据库

建议：

> SQLite

Flutter 可以选择成熟 ORM / 数据库方案。

推荐核心表：

```text
providers
accounts
tokens
models
provider_models
quota_snapshots
model_test_records
checkin_records
prewarm_records
tasks

conversations
messages

image_tasks
image_assets

ssh_hosts
agent_sessions

app_settings
webdav_config
```

---

# 58. 关键关系

```text
Provider
   │
   └── Account
          │
          └── Token
                 │
                 └── Models

Provider
   │
   └── QuotaSnapshots

Token
   │
   └── ModelTestRecords

SSH Host
   │
   └── Agent Sessions
          │
          └── tmux Session
```

---

# 59. Provider 与 Token 的职责边界

### Provider

负责：

- 供应商
- 账户
- Base URL
- 额度
- 余额
- 订阅周期
- 签到
- 预热

### Token

负责：

- API Key
- 所属 Provider
- 模型权限
- Token 状态
- 模型测试
- Agent 导出

这样可以避免：

> 一个供应商多个 Token 时数据结构混乱。

---

# 60. 模型状态

模型可以记录：

- modelId
- displayName
- protocol
- capabilities
- enabled
- lastTestAt
- lastTestStatus

能力：

```text
text
vision
image
reasoning
embedding
rerank
```

---

# 61. Provider / Token / Model 的显示原则

首页：

> 不展示所有模型。

供应商详情：

> Token 列表。

Token 展开：

> 模型列表。

模型：

> 临时测试。

这样不会让首页变成巨大的模型管理页面。

---

# 62. MVP P0

第一阶段只做最核心的订阅管理闭环：

### 基础

- Flutter 工程
- SQLite
- Provider
- Account
- Token
- Model

### 首页

- 供应商卡片
- 排序
- 置顶
- 余额
- 额度
- 重置时间

### 供应商

- 官方订阅
- API 中转站
- Base URL
- Token 管理

### 核心动作

- 刷新额度
- 手动预热
- 批量预热
- 签到
- 批量签到
- 模型测试

### 安全

- Secure Storage
- App Lock

---

# 63. MVP P1

完善日常使用：

- 额度历史
- 模型测试历史
- 任务中心
- 通知
- WebDAV
- JSON 导入导出
- Provider 排序 / 隐藏
- CC Switch 导出
- Magpie 导出

---

# 64. MVP P2

AI 工作台：

### AI Chat

- 会话
- 流式聊天
- Markdown
- 代码高亮
- LaTeX
- 复制
- 长图

### AI Image

- Prompt
- 模型选择
- 参考图
- 图片生成
- 历史
- 复制
- 保存

---

# 65. P3

远程开发：

### SSH

- 主机管理
- SSH Key
- 密码
- Tailscale
- Terminal

### tmux

- Session 列表
- Session 恢复
- 输出读取
- 输入发送

### Agent

支持：

- Claude Code
- Codex
- OpenCode
- Pi

### Chat UI

复用 AI Chat：

> 终端作为底层，聊天作为上层交互。

---

# 66. P4

增强能力：

- PlantUML
- Mermaid
- ECharts
- Ant Design Charts
- 更完善的 Agent 状态解析
- 更好的终端与聊天转换
- 更多官方订阅适配器
- 更多中转站适配器
- SFTP
- SSH Port Forward
- 更多 Agent

---

# 67. 不做持续模型健康检测

明确排除：

> 自动每分钟 / 每小时检测所有模型。

模型测试只由：

> 用户主动点击测试。

保留最近几次结果：

> 作为简单的可用性历史。

这样不会产生大量无意义 Token 消耗。

---

# 68. 不做复杂 Agent Server

远程 Agent：

> 不部署自己的服务器。

依赖：

```text
Tailscale
+
SSH
+
tmux
```

这样：

- 架构简单
- 用户可控
- 不需要公网服务器
- 不需要账号体系
- 不需要中继服务
- 不需要维护电脑端后台服务

---

# 69. 产品核心闭环

最终 App 的核心闭环：

```text
              AI 订阅
                 │
                 ↓
          ┌──────────────┐
          │    首页       │
          │              │
          │ 额度 / 余额   │
          │ 重置时间      │
          │ 预热 / 签到   │
          └──────┬───────┘
                 │
        ┌────────┼────────┐
        ↓        ↓        ↓
     Provider   Token    Model
        │        │        │
        │        │      测试
        │        │
        ↓        ↓
      AI 工作台
        │
   ┌────┼─────┐
   ↓    ↓     ↓
 聊天  画图  远程开发
              │
          SSH + tmux
              │
      Claude/Codex/OpenCode/Pi
```

---

# 70. 最终产品定位

这个 App 不应该被设计成：

> 「又一个 AI Chat App」

也不是：

> 「又一个 SSH 客户端」

更不是：

> 「又一个 Agent IDE」

核心应该始终是：

> **AI 订阅管理器 + AI 使用工作台**

其中：

**首页**

> 管理我的 AI 资源。

**工作台**

> 使用我的 AI 资源。

**远程开发**

> 继续我的电脑上的 AI 工作。

**设置**

> 管理我的数据、同步和安全。

最终形成：

> **看订阅 → 看额度 → 预热 / 签到 → 测模型 → 用模型 → 离开电脑后继续 Agent → 回到首页继续管理订阅。**

这就是整个 App 的完整 MVP 产品闭环。

---
补充：Widget计划
# Desktop Widget / 桌面小组件

## 1. 功能定位

桌面 Widget 是 AI 订阅管理的辅助入口，核心目标：

> **不打开 App，也能快速查看指定 AI 供应商的额度、余额和重置时间，并支持手动刷新真实额度和执行预热。**

Widget 不是独立应用，也不承担完整的 Provider 管理能力。

核心信息优先级：

1. 额度 / 余额
2. 重置时间
3. 数据更新时间
4. 手动刷新
5. 预热

---

# 2. 平台实现

Flutter 主 App 继续负责业务逻辑和 UI。

Widget 使用各平台原生 Widget Framework：

```text
Flutter App
│
├── iOS
│   └── WidgetKit + SwiftUI
│
└── Android
    └── Jetpack Glance
```

不针对不同 Android 厂商分别开发 Widget。

Android 使用标准 App Widget 机制，兼容主流 Android 厂商。

需要注意：

- Android 各厂商 Widget UI 基础能力基本遵循系统标准
- 部分 ROM 对后台运行、定时任务、电池优化存在差异
- Widget 不依赖高频后台运行保证核心功能
- 必要时增加厂商后台权限提示，但不针对每个厂商维护独立 Widget 实现

---

# 3. Widget 类型

MVP 支持三种尺寸。

## 3.1 小尺寸

显示单个供应商：

```text
┌─────────────────────┐
│ ✦ Claude        ↻   │
│                     │
│ 72%                 │
│ ███████░░░          │
│                     │
│ 2h 31m 后重置        │
└─────────────────────┘
```

适合最常用的一个订阅。

---

## 3.2 中尺寸

显示一个供应商的更多信息：

```text
┌──────────────────────────┐
│ ✦ 智谱 AI           ↻    │
│                          │
│ 5 小时额度       100%    │
│ ██████████████████       │
│                          │
│ 4h 52m 后重置             │
│                          │
│             [♨ 预热]      │
└──────────────────────────┘
```

---

## 3.3 大尺寸

显示多个指定供应商：

```text
┌──────────────────────────┐
│ AI Subscriptions     ↻   │
│                          │
│ Claude       72%  2h31m  │
│ ███████░░░               │
│                          │
│ 智谱         100% 4h52m  │
│ ████████████             │
│                          │
│ OpenAI       48%  1h12m  │
│ █████░░░░░               │
└──────────────────────────┘
```

---

# 4. Widget 可配置供应商

用户添加 Widget 时，可以选择显示对象。

```text
Widget 配置

供应商：
[ Claude ▼ ]

显示：
☑ 额度
☑ 重置时间
☑ 最后更新时间
☐ 余额
```

支持一个 App 添加多个 Widget。

例如：

```text
Widget 1 → Claude
Widget 2 → 智谱 AI
Widget 3 → 某中转站
```

大尺寸 Widget 可以配置多个 Provider。

---

# 5. 刷新机制

必须明确区分：

> **Widget 显示刷新**

和：

> **Provider 真实额度刷新**

两者不是同一个概念。

---

## 5.1 Widget 自动刷新

Widget 可以按照系统允许的刷新机制定期重新绘制。

但自动刷新：

> **不主动请求供应商 API。**

例如：

```text
Provider API 查询结果：

quota = 100%
resetAt = 20:00

        ↓

保存本地 Snapshot

        ↓

Widget 自动重新绘制

        ↓

根据 resetAt - 当前时间

显示：

4h 52m
4h 51m
4h 50m
```

这样：

- 不消耗 API Token
- 不依赖 App 高频后台运行
- 不受不同 Android ROM 后台策略影响核心数据
- 倒计时可以持续变化

---

# 6. 手动刷新

Widget 必须支持：

> **手动刷新真实额度。**

例如：

```text
┌─────────────────────┐
│ Claude          ↻   │
│                     │
│ 72%                 │
│ ███████░░░          │
│                     │
│ 2h31m 后重置         │
└─────────────────────┘
```

用户点击 `↻`：

```text
Widget
  ↓
Widget Action / App Intent
  ↓
Provider Adapter
  ↓
getQuota()
  ↓
更新 Quota Snapshot
  ↓
刷新 Widget
```

这是一次真正的网络请求。

---

# 7. Widget 预热

Widget 支持快捷预热。

例如：

```text
┌──────────────────────────┐
│ ✦ 智谱 AI           ↻    │
│                          │
│ 100%                     │
│ ██████████████████       │
│                          │
│ 4h52m 后重置              │
│                          │
│             [♨ 预热]      │
└──────────────────────────┘
```

点击预热后，必须复用 App 的预热判断逻辑。

```text
点击预热
   ↓
查询当前额度
   ↓
是否 = 100%？
   │
 ┌─┴─────────┐
 ↓           ↓
是           否
 ↓           ↓
执行预热      跳过
             │
             ↓
       不浪费 Token
```

如果额度查询失败：

> 不执行预热。

---

# 8. Widget 操作限制

Widget 不设计成完整的 App 页面。

不放置大量按钮。

推荐：

### 小 Widget

```text
[↻]
```

### 中 Widget

```text
[↻] [♨ 预热]
```

### 大 Widget

主要展示数据。

不增加：

- 签到
- 模型测试
- Token 管理
- Provider 设置
- 聊天
- 画图

这些操作点击 Widget 后进入 App。

---

# 9. Widget Deep Link

点击 Widget 主体：

> 进入对应 Provider 详情页。

例如：

```text
Widget
  ↓
点击 Claude
  ↓
打开 App
  ↓
Claude Provider Detail
```

不同区域可以进一步绑定不同页面：

```text
Provider 名称 → Provider 详情
额度区域     → 额度详情
预热按钮     → 预热操作
```

---

# 10. Widget 数据架构

Widget 不直接访问 App SQLite，也不直接保存 API Token。

采用：

> **Quota Snapshot → Shared Widget Storage → Widget**

架构：

```text
Provider Adapter
      ↓
Quota Manager
      ↓
SQLite
      ↓
Widget Snapshot
      ↓
┌───────────────────────┐
│ iOS App Group          │
│ Android Shared Storage │
└───────────────────────┘
      ↓
WidgetKit / Glance
```

Widget Snapshot 只保存必要的非敏感数据：

```text
providerId
providerName
quota
total
remaining
balance
currency
resetAt
status
lastUpdatedAt
```

---

# 11. Widget 不保存敏感数据

Widget 不保存：

- API Key
- Access Token
- OAuth Credential
- SSH Password
- SSH Private Key

真正的敏感凭证仍然保存在系统安全存储中：

- iOS Keychain
- Android Keystore
- macOS Keychain
- Windows Credential Manager

Widget 只使用：

> 非敏感额度快照。

---

# 12. Widget 与 App 数据同步

App 内额度刷新后：

```text
Provider Adapter
      ↓
Quota Snapshot
      ↓
SQLite
      ↓
Widget Snapshot
      ↓
Widget Reload
```

这样 App 和 Widget 始终使用同一份额度状态。

---

# 13. App 打开时刷新

用户打开 App 时，可以按照 Provider 刷新策略：

```text
打开 App
   ↓
检查需要刷新的 Provider
   ↓
刷新额度
   ↓
更新 Snapshot
   ↓
同步 Widget
```

避免 Widget 长时间展示过期数据。

---

# 14. 数据更新时间

Widget 应明确展示：

> 最后一次真实查询时间。

例如：

```text
100%

4h52m 后重置

更新于 3 分钟前
```

如果数据过旧：

```text
100%

4h52m 后重置

⚠ 数据已超过 2 小时未更新
```

避免用户误认为 Widget 数据实时。

---

# 15. MVP 实现优先级

## P1

实现：

- Android Widget
- iOS Widget
- 小 / 中尺寸
- 指定 Provider
- 额度展示
- 重置时间
- 本地倒计时
- 最后更新时间
- Widget 手动刷新
- Widget 跳转 Provider 详情

## P1 后续

增加：

- 预热按钮
- 多 Provider 大 Widget
- Widget 配置项
- Widget 多实例

## 后续版本

考虑：

- Widget 签到
- Widget 批量操作
- 更多快捷操作
- 更丰富的订阅信息

---

# 16. 设计原则总结

Widget 的核心原则：

```text
                Widget
                  │
        ┌─────────┴─────────┐
        │                   │
    自动刷新              手动操作
        │                   │
    本地重新绘制        真实请求 API
        │                   │
    不消耗 Token        查询额度 / 预热
```

最终用户体验：

> **桌面上随时看额度 → 看到额度恢复 → 点击刷新确认 → 点击预热。**

Widget 是 App「订阅管理」核心能力的延伸，而不是独立功能。
