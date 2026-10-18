# Changelog

## 0.4.0（2026-10-18）

- Android 发版流水线：GitHub Actions 按 ABI 拆分 APK（arm64-v8a / armeabi-v7a / x86_64，
  无 universal 大包），固定 keystore 签名（Secrets 注入 + apksigner 校验），
  Release 附 update-info.json
- 应用内更新（设置 → 检查更新）：读 GitHub Release 元数据、按设备 ABI 自动选包、
  下载进度、系统安装器接管；同一签名覆盖安装不丢数据
- 构建适配：阿里云镜像兜底（beforeProject 全局注入，CI 不受影响）、
  core library desugaring、库插件 compileSdk 抬升

## 0.3.1（2026-10-18）

- 性能：首页聚合流消除 N+1 查询（tokens / models 一次拉取内存分组）；
  watch 流加 120ms 变更去抖（批量刷新逐条插快照不再触发全量重载风暴）
- 数据治理：快照表清理（每 provider × 类型保留最近 100 条，批量刷新后自动执行）
- 新增 NewAPI「本月已用」采集与展示（Plan #43）、Agent 聊天视图（Plan #34 完整版）
- pubspec 补充项目描述

## 0.3.0（2026-10-18）

### 订阅管理（P0）
- 供应商 / Token / 模型三级数据模型，官方订阅与中转站适配器（NewAPI / Sub2API / 通用 OpenAI 兼容 / 智谱 / OpenAI / Claude 占位）
- 额度 / 余额 / 重置时间看板，置顶 / 隐藏 / 手动拖拽排序
- 批量签到 / 批量预热（额度满 100% 才执行，状态未知即跳过）
- 模型临时测试与 9 类失败原因分类、模型测试历史
- API Key / 系统令牌只存系统安全存储

### 数据与同步（P1）
- 任务中心：批量操作后台化，进度 / 取消 / 重试失败项 / 结果明细
- 额度历史（sparkline 走势 + 快照明细）
- JSON 导入导出（默认脱敏，按 id 合并导入）
- CC Switch / Magpie 导入链接（Token 层，含密钥安全警告）
- WebDAV 同步（推送 / 拉取 / 冲突检测，密钥同步独立开关）
- 通知中心：额度恢复 / 签到可用 / 数据过期检测，当日去重；系统本地通知（分类开关 + 授权请求，未授权时 App 内兜底）
- App 锁：PIN（SHA-256 + 盐）+ 生物识别优先；启动锁 / 切后台锁可配置

### AI 工作台（P2）
- AI 聊天：流式输出（SSE，支持跨 chunk 半行与 UTF-8 截断）、Markdown 渲染、推理模型 reasoning 折叠、停止生成、会话内切换模型、消息复制 / 删除 / 重新生成、导出长图
- AI 画图：单次生成任务、参考图（edits multipart）、b64/url 双响应、历史网格、图片详情（放大 / 另存 / 复制 Prompt）

### 远程开发（P3）
- SSH 主机管理（dartssh2，Key / 密码认证，host key TOFU 校验防中间人）
- tmux 会话列表与 Agent 识别（Claude Code / Codex / OpenCode / Pi）
- tmux pane 交互（capture-pane / send-keys / 自动刷新）↔ 完整 xterm 终端（pty + ANSI / TUI / tmux attach，快捷键条含粘滞 Ctrl）
- 首页远程状态区、首次使用五步引导

### 已知限制
- SSH / pty / 生物识别真实链路需真机验证（自动化覆盖不到）
- macOS 桌面端无图片剪贴板复制（以另存为替代）
- 官方订阅额度查询未接入（需各厂商 OAuth，已留适配器接口）
- 桌面 Widget（WidgetKit / Glance）未实现
