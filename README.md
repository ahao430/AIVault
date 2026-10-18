# AIVault

AI 订阅与 API 账号管理为中心的本地优先跨平台 App —— 随时查看所有 AI 订阅的额度、余额、重置时间，批量预热 / 签到，管理 Token 与模型，并临时测试模型可用性。

技术方案：**Flutter（iOS / Android / macOS / Windows）+ SQLite（drift）+ 本地优先 + WebDAV 可选同步（P1）**

产品设计基线见 [Plan.md](./Plan.md)。

## 当前范围（MVP P0 + P1 第一批）

- 供应商 / Token / 模型 三级数据模型（同一供应商的不同账户视为不同实例）
- 首页订阅卡片：额度进度 + 重置倒计时、余额、本月已用（NewAPI 系，Plan #43）、置顶 / 隐藏、批量签到 / 批量预热
- 供应商编辑：官方订阅 / 中转站、适配器选择（NewAPI / Sub2API / 通用 OpenAI 兼容 / 智谱 / OpenAI / Claude）、Base URL、系统访问令牌
- Token 管理：API Key 加密存系统安全存储（Keychain / Keystore），数据库只存引用
- 模型列表同步 + 单模型临时测试（9 类失败原因分类：认证 / 权限 / 不存在 / 余额 / 限流 / 上游 / 超时 / 协议 / 未知）
- 预热规则：**只有额度达到 100% 才执行**；查询失败 / 状态未知一律跳过
- 额度快照：查询失败保留上一次成功数据，不显示为 0
- 任务中心：批量签到 / 预热 / 刷新作为后台任务执行，支持进度、取消、重试失败项、结果明细
- 额度历史：快照走势（sparkline）+ 明细列表
- 模型测试历史：单个模型的最近测试记录（延迟 / HTTP / 错误分类）
- JSON 导入导出：默认脱敏，可选包含密钥（明确警告）；按 id 合并导入
- CC Switch / Magpie 导出：Token 层生成导入链接（`ccswitch://v1/import` / `magpie://import`，含 API Key 安全警告）
- WebDAV 同步：个人设备间同步（推送 / 拉取 / 冲突检测，两边都改过时由用户选择保留哪份）；密钥是否随同步单独控制；WebDAV 密码只存系统安全存储
- 已隐藏供应商管理：恢复或彻底删除
- 通知中心（P1，Plan #49）：批量刷新后自动检测「额度已恢复可预热 / 今日可签到 / 数据超过 24 小时未更新」三类需用户行动的事件；额度恢复需前后状态对比（首次查询不打扰）；签到可用与数据过期按供应商+类型当日去重；首页铃铛 + 未读角标，点击跳转对应供应商；系统本地通知并行转发（flutter_local_notifications，Android 分渠道，未授权时静默降级 App 内）；通知偏好页支持总开关 / 系统通知开关 / 三类分类开关
- 终端快捷键条（Plan #40 移动端补全）：Esc / Tab / 方向键 / C-c + 粘滞 Ctrl，控制序列直写 pty，可隐藏
- 聊天导出长图（Plan #25）：最近 50 条消息离屏渲染（Markdown / 代码块已渲染）为 720px 宽 PNG，2x 像素密度，系统保存对话框
- App 锁（Plan #54）：PIN（4-6 位，SHA-256 + 盐哈希存安全存储）+ 生物识别优先（Touch ID / Face ID / 指纹，local_auth，允许系统密码兜底）；可配置「启动时锁定 / 切后台后锁定」；锁屏数字键盘（错误抖动、6 位自动提交）
- 首页拖拽排序（Plan #42）：长按卡片拖动，顺序即时持久化；置顶项仍优先
- AI 聊天（P2）：会话管理（新建 / 重命名 / 删除，历史只存本地）、OpenAI 兼容流式输出（SSE 解析支持跨 chunk 半行与 UTF-8 截断）、Markdown 渲染（gpt_markdown）、推理模型 reasoning 折叠显示、停止生成（保留已生成部分）、会话内切换模型、消息长按复制 / 删除、重新生成最后一条回答
- AI 画图（P2）：单次生成任务、参考图（/v1/images/edits multipart）、b64/url 双响应格式、画图类模型优先排序、尺寸选择、历史网格（prompt / 模型 / 时间 / 状态）、图片详情（放大预览 / 另存为 / 复制 Prompt）、图片文件随记录删除
- 远程开发（P3）：SSH 主机管理（dartssh2，Key/密码认证，凭证只存安全存储）、首次连接 host key TOFU 校验（指纹变化拒绝连接防中间人）、连接池与断开、tmux 会话列表（窗口数/创建时间/attached，会话名含冒号可解析）、会话 Agent 识别（Claude Code/Codex/OpenCode/Pi）、tmux pane 交互（capture-pane 输出 / send-keys 输入 / Ctrl+C / 自动刷新）、**完整 xterm 终端**（pty + xterm-256color，ANSI / 光标控制 / 全屏 TUI / tmux attach，桌面端 Ctrl 组合 / Tab / Esc / 方向键 / 右键复制粘贴）、pane 页聊天↔终端模式切换（Plan #35）、首页远程状态区（在线主机 + 最近连接，Plan #41）、首次使用五步引导（Plan #32）

## 目录结构

```
lib/
├── main.dart / app.dart          # 入口 + 底部三 Tab（首页 / 工作台 / 设置）
├── adapters/                     # ProviderAdapter 适配器（核心抽象）
│   ├── provider_adapter.dart     #   接口 + 能力声明 + 结果类型
│   ├── openai_compatible.dart    #   OpenAI 兼容：模型列表 / 模型测试 / 错误分类
│   ├── newapi.dart               #   NewAPI / Sub2API：余额查询 + 签到
│   └── registry.dart             #   适配器注册表 + 官方订阅适配器
├── core/                         # 安全存储封装、主题、格式化
├── data/
│   ├── db/                       # drift 表定义 + 数据库（SQLite）
│   └── repositories/             # 仓库层（聚合视图模型）
├── services/                     # 业务服务：刷新 / 签到 / 预热 / 批量 / 测试
├── state/                        # Riverpod providers
└── ui/                           # 首页 / 供应商详情与编辑 / 工作台 / 设置
```

## 开发

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs --force-jit   # 生成 drift 代码
flutter test                                                           # 单元测试
flutter run -d macos                                                   # 运行
flutter build macos --debug                                            # 构建
```

> 注：当前工具链（Dart 3.10）运行 build_runner 需带 `--force-jit`。

### macOS 权限与签名

`macos/Runner/*.entitlements` 已包含 `network.client`（访问 API）。

> 注意：`keychain-access-groups`（flutter_secure_storage 的 Keychain 共享）需要有效的
> 开发团队签名才能生效 —— 无签名团队时该 entitlement 会导致 macOS 以
> `Code Signature Invalid` 杀掉 App。当前 debug 构建未包含它；正式分发时请在 Xcode
> 中开启 Keychain Sharing（配合签名团队）后再构建。

## 迭代路线（见 Plan.md）

- **P1**：额度历史、任务中心、通知、WebDAV 同步、JSON 导入导出、CC Switch / Magpie 导出、桌面 Widget、App 锁
- **P2**：AI 聊天（Markdown / LaTeX / Mermaid）、AI 画图
- **P3**：远程开发（SSH / tmux / Claude Code / Codex / OpenCode / Pi）
- **P4**：ECharts、PlantUML、SFTP、端口转发、更多官方适配器
