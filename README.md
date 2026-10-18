# AIVault

AI 订阅与 API 账号管理为中心的本地优先跨平台 App —— 随时查看所有 AI 订阅的额度、余额、重置时间，批量预热 / 签到，管理 Token 与模型，并临时测试模型可用性。

技术方案：**Flutter（iOS / Android / macOS / Windows）+ SQLite（drift）+ 本地优先 + WebDAV 可选同步（P1）**

产品设计基线见 [Plan.md](./Plan.md)。

## 当前范围（MVP P0 + P1 第一批）

- 供应商 / Token / 模型 三级数据模型（同一供应商的不同账户视为不同实例）
- 首页订阅卡片：额度进度 + 重置倒计时、余额、置顶 / 隐藏、批量签到 / 批量预热
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
