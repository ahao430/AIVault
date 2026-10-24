import 'package:drift/drift.dart';

/// 供应商类型：官方订阅 / API 中转站
enum ProviderType { official, relay }

/// 适配器种类，决定使用哪个 ProviderAdapter 实现。
///
/// 官方订阅的 Coding Plan 通常同时暴露 OpenAI 与 Anthropic 两种请求格式，
/// 端点地址不同，故按「厂商 + 格式」拆分为两个适配器；textEnum 存储，
/// 追加新值不影响旧数据。
enum AdapterKind {
  generic,
  newapi,
  sub2api,
  zhipu,
  claude,
  openai,
  zhipuAnthropic,
  deepseek,
  deepseekAnthropic,
  kimi,
  opencode,
  moonshot,
}

/// 额度快照类型
enum QuotaKind { windowQuota, weeklyQuota, balance, usage, subscription }

/// 供应商（同一供应商的不同账户视为不同实例）
class Providers extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  IntColumn get type => intEnum<ProviderType>()();
  TextColumn get adapterKind => textEnum<AdapterKind>()();
  TextColumn get baseUrl => text().withDefault(const Constant(''))();

  /// 账户标识，例如「个人账号」「公司账号」
  TextColumn get accountLabel => text().withDefault(const Constant(''))();

  /// 中转站系统/管理访问令牌在 Secure Storage 中的引用 key（NewAPI 签到、余额用）
  TextColumn get systemTokenRef => text().nullable()();

  /// NewAPI 系的部分版本接口要求 New-Api-User 头（用户 ID），明文非敏感
  TextColumn get systemUserId => text().nullable()();

  /// 余额展示币种覆盖：'' = 跟随适配器默认（NewAPI 系为 $）；
  /// 站点按人民币计价（quota 兑换的是 ¥）时设为 'CNY'
  TextColumn get balanceCurrency => text().withDefault(const Constant(''))();

  /// 站点未开启签到功能时置 true：隐藏签到入口并跳过批量签到
  BoolColumn get checkinDisabled => boolean().withDefault(const Constant(false))();

  BoolColumn get pinned => boolean().withDefault(const Constant(false))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  BoolColumn get hidden => boolean().withDefault(const Constant(false))();

  /// 是否参与桌面小组件轮播（与首页展示 hidden 相互独立）
  BoolColumn get showOnWidget => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// API Token（供应商下的第二级结构，一个账户可拥有多个）
class Tokens extends Table {
  TextColumn get id => text()();
  TextColumn get providerId => text()
      .references(Providers, #id, onDelete: KeyAction.cascade)();
  TextColumn get name => text().withDefault(const Constant(''))();

  /// API Key 在 Secure Storage 中的引用 key，数据库不保存明文
  TextColumn get secretRef => text()();
  TextColumn get note => text().withDefault(const Constant(''))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Token 可用模型（模型权限随 Token 不同）
class ProviderModels extends Table {
  TextColumn get id => text()();
  TextColumn get tokenId => text()
      .references(Tokens, #id, onDelete: KeyAction.cascade)();
  TextColumn get modelId => text()();
  TextColumn get displayName => text().withDefault(const Constant(''))();
  BoolColumn get enabled => boolean().withDefault(const Constant(true))();
  DateTimeColumn get lastTestAt => dateTime().nullable()();

  /// 最近一次测试结果：success / failed / null = 未测试
  TextColumn get lastTestStatus => text().nullable()();
  IntColumn get lastTestLatencyMs => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => ['UNIQUE(token_id, model_id)'];
}

/// 额度快照（保留历史，查询失败时沿用上一次成功数据）
class QuotaSnapshots extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get providerId => text()
      .references(Providers, #id, onDelete: KeyAction.cascade)();
  DateTimeColumn get timestamp => dateTime()();
  IntColumn get kind => intEnum<QuotaKind>()();

  /// 剩余比例 0.0 ~ 1.0（额度类）
  RealColumn get ratio => real().nullable()();
  RealColumn get remaining => real().nullable()();
  RealColumn get total => real().nullable()();

  /// 余额金额 + 币种
  RealColumn get amount => real().nullable()();
  TextColumn get currency => text().nullable()();
  DateTimeColumn get resetAt => dateTime().nullable()();

  /// 数据来源：official / estimated / unknown
  TextColumn get source => text().withDefault(const Constant('unknown'))();
  BoolColumn get success => boolean()();
  TextColumn get message => text().nullable()();
}

/// 模型测试记录（用户主动触发，不做持续健康检测）
class ModelTestRecords extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get tokenId => text()
      .references(Tokens, #id, onDelete: KeyAction.cascade)();
  TextColumn get modelId => text()();
  BoolColumn get success => boolean()();

  /// 错误分类：auth/permission/notFound/insufficientBalance/rateLimited/upstream/timeout/protocol/unknown
  TextColumn get errorType => text().nullable()();
  IntColumn get httpStatus => integer().nullable()();
  IntColumn get latencyMs => integer().nullable()();
  TextColumn get message => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
}

/// 签到记录
class CheckinRecords extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get providerId => text()
      .references(Providers, #id, onDelete: KeyAction.cascade)();
  BoolColumn get success => boolean()();
  TextColumn get message => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
}

/// 预热记录
class PrewarmRecords extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get providerId => text()
      .references(Providers, #id, onDelete: KeyAction.cascade)();

  /// executed / skipped / failed
  TextColumn get status => text()();
  TextColumn get message => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
}

/// WebDAV 同步配置（单行，id 恒为 1；密码存安全存储，这里只存引用）
class WebdavConfigs extends Table {
  IntColumn get id => integer().withDefault(const Constant(1))();
  TextColumn get url => text()();
  TextColumn get username => text()();

  /// WebDAV 密码在 Secure Storage 中的引用 key
  TextColumn get passwordRef => text()();
  TextColumn get remotePath =>
      text().withDefault(const Constant('/aivault'))();

  /// 同步是否包含 API Key 等密钥（敏感信息单独控制，Plan #50）
  BoolColumn get includeSecrets =>
      boolean().withDefault(const Constant(true))();

  /// 本设备标识（用于同步元数据展示）
  TextColumn get deviceId => text()();

  /// 上次成功同步时间
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// AI 聊天会话（Plan #23）。只保存本地。
class Conversations extends Table {
  TextColumn get id => text()();
  TextColumn get title => text().withDefault(const Constant('新会话'))();

  /// 会话使用的供应商 / 令牌 / 模型（模型可切换，随会话保存）
  TextColumn get providerId => text()
      .references(Providers, #id, onDelete: KeyAction.cascade)();
  TextColumn get tokenId =>
      text().references(Tokens, #id, onDelete: KeyAction.cascade)();
  TextColumn get model => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// 聊天消息
class Messages extends Table {
  TextColumn get id => text()();
  TextColumn get conversationId => text()
      .references(Conversations, #id, onDelete: KeyAction.cascade)();

  /// user / assistant
  TextColumn get role => text()();
  TextColumn get content => text()();
  DateTimeColumn get createdAt => dateTime()();

  /// JSON：错误信息、模型、耗时等
  TextColumn get metadata => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// AI 画图任务（Plan #26/#27）：单次生成任务，历史只保存本地。
class ImageTasks extends Table {
  TextColumn get id => text()();
  TextColumn get providerId => text()
      .references(Providers, #id, onDelete: KeyAction.cascade)();
  TextColumn get tokenId =>
      text().references(Tokens, #id, onDelete: KeyAction.cascade)();
  TextColumn get model => text()();
  TextColumn get prompt => text()();

  /// 参考图相对路径（\n 分隔，位于 app 图片目录内）
  TextColumn get referencePaths => text().withDefault(const Constant(''))();

  /// 生成结果相对路径（成功后写入）
  TextColumn get resultPath => text().nullable()();

  /// pending / running / success / failed
  TextColumn get status => text()();
  TextColumn get errorMessage => text().nullable()();

  /// 参数（尺寸等），简单 k:v
  TextColumn get params => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// SSH 主机（Plan #38）。密码 / 私钥只存系统安全存储，数据库存引用。
/// hostKeyFingerprint 用于 TOFU 校验（Plan #39：不能默认无条件信任）。
class SshHosts extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get host => text()();
  IntColumn get port => integer().withDefault(const Constant(22))();
  TextColumn get username => text()();

  /// key / password
  TextColumn get authType => text()();

  /// 私钥或密码在 Secure Storage 中的引用 key
  TextColumn get secretRef => text()();

  /// 私钥口令引用（仅 key 认证可能需要，可空）
  TextColumn get passphraseRef => text().nullable()();

  /// 首次连接接受的 host key 指纹（SHA256:...）
  TextColumn get hostKeyFingerprint => text().nullable()();

  /// Tailscale 内网主机：连接失败时提示先打开本机 Tailscale
  BoolColumn get isTailscale => boolean().withDefault(const Constant(false))();

  /// 私钥原文仅用于表单展示时的暂存说明，不存明文
  DateTimeColumn get lastConnectedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// 监控探针站点（Komari 等面板）。API Token 存安全存储，数据库只存引用。
class MonitorSites extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get baseUrl => text()();

  /// 面板类型：komari（预留扩展哪吒等其他面板）
  TextColumn get kind => text().withDefault(const Constant('komari'))();

  /// 管理员 API Key 在 Secure Storage 中的引用 key
  /// （公开站点无需令牌；私有站点或需要完整数据时填写）
  TextColumn get apiTokenRef => text().nullable()();

  /// 是否在首页探针区展示
  BoolColumn get showOnHome => boolean().withDefault(const Constant(true))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  /// 最近一次抓取的节点数据 JSON（离线时展示缓存）
  TextColumn get lastData => text().nullable()();
  DateTimeColumn get lastFetchedAt => dateTime().nullable()();
  TextColumn get lastError => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
}

/// 通用键值设置（首页板块顺序等；值存 JSON 文本）
class AppSettings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

/// 工作台书签：常用网址，点击在应用内 WebView 打开
class Bookmarks extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get url => text()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// App 内通知（Plan #49）：只在真正需要用户行动时提醒。
class Notifications extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// quotaRecovered / checkinAvailable / dataStale
  TextColumn get kind => text()();
  TextColumn get providerId => text()();
  TextColumn get title => text()();
  TextColumn get body => text()();
  BoolColumn get read => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
}

/// 工作台 Webhook / API 调试：保存的请求模板
class WebhookRequests extends Table {
  TextColumn get id => text()();

  /// 显示名
  TextColumn get name => text()();
  TextColumn get method => text()(); // GET/POST/PUT/DELETE/OPTIONS/PATCH/HEAD
  TextColumn get url => text()();

  /// 路径参数 / 变量（JSON：[{"key":"id","value":"123"}]，替换 URL
  /// 与 body 中的 {key} 占位符）
  TextColumn get variables => text().withDefault(const Constant('[]'))();

  /// Query 参数（JSON：[{"key":"k","value":"v"}]，值一律字符串）
  TextColumn get query => text().withDefault(const Constant('[]'))();

  /// Headers（JSON：[{"key":"Content-Type","value":"application/json"}]）
  TextColumn get headers => text().withDefault(const Constant('[]'))();

  /// Body（JSON：{"type":"none|json|form|text","raw":"...","fields":[{"key":"a","value":"1","fieldType":"string"}]}）
  TextColumn get body => text().withDefault(const Constant('{"type":"none"}'))();

  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Webhook 请求历史（含请求快照与响应摘要，上限可配置）
class WebhookHistory extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// 来源的保存请求 id（临时执行时为空）
  TextColumn get requestId => text().nullable()();
  TextColumn get name => text()();
  TextColumn get method => text()();

  /// 实际发出的完整 URL（变量已替换、query 已拼接）
  TextColumn get url => text()();
  TextColumn get requestBody => text().nullable()();

  /// HTTP 状态码；网络失败 / 超时为空
  IntColumn get statusCode => integer().nullable()();
  BoolColumn get ok => boolean().withDefault(const Constant(false))();

  /// 响应正文预览（截断存储，上限 8KB）
  TextColumn get responsePreview => text().nullable()();
  IntColumn get durationMs => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
}
