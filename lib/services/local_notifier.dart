import 'dart:convert';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../core/secure_store.dart';

/// 通知偏好（Plan #49：开关 + 分类）
class NotificationPrefs {
  const NotificationPrefs({
    this.enabled = true,
    this.systemNotifications = true,
    this.quotaRecovered = true,
    this.checkinAvailable = true,
    this.dataStale = true,
  });

  final bool enabled;
  final bool systemNotifications;
  final bool quotaRecovered;
  final bool checkinAvailable;
  final bool dataStale;

  bool allows(String kind) {
    if (!enabled) return false;
    switch (kind) {
      case 'quotaRecovered':
        return quotaRecovered;
      case 'checkinAvailable':
        return checkinAvailable;
      case 'dataStale':
        return dataStale;
      default:
        return true;
    }
  }

  NotificationPrefs copyWith({
    bool? enabled,
    bool? systemNotifications,
    bool? quotaRecovered,
    bool? checkinAvailable,
    bool? dataStale,
  }) =>
      NotificationPrefs(
        enabled: enabled ?? this.enabled,
        systemNotifications: systemNotifications ?? this.systemNotifications,
        quotaRecovered: quotaRecovered ?? this.quotaRecovered,
        checkinAvailable: checkinAvailable ?? this.checkinAvailable,
        dataStale: dataStale ?? this.dataStale,
      );

  Map<String, dynamic> toJson() => {
        'enabled': enabled,
        'systemNotifications': systemNotifications,
        'quotaRecovered': quotaRecovered,
        'checkinAvailable': checkinAvailable,
        'dataStale': dataStale,
      };

  static NotificationPrefs fromJson(Map<String, dynamic> json) =>
      NotificationPrefs(
        enabled: json['enabled'] != false,
        systemNotifications: json['systemNotifications'] != false,
        quotaRecovered: json['quotaRecovered'] != false,
        checkinAvailable: json['checkinAvailable'] != false,
        dataStale: json['dataStale'] != false,
      );
}

/// 通知偏好存取（安全存储，JSON）
class NotificationPrefsStore {
  NotificationPrefsStore(this._secure);

  static const _kPrefs = 'notif:prefs';
  final SecureStore _secure;

  Future<NotificationPrefs> load() async {
    final raw = await _secure.read(_kPrefs);
    if (raw == null) return const NotificationPrefs();
    try {
      final json = jsonDecode(raw);
      if (json is Map<String, dynamic>) {
        return NotificationPrefs.fromJson(json);
      }
    } catch (_) {}
    return const NotificationPrefs();
  }

  Future<void> save(NotificationPrefs prefs) =>
      _secure.write(_kPrefs, jsonEncode(prefs.toJson()));
}

/// 系统本地通知封装：授权请求 + 分渠道展示。
/// 初始化失败或未授权时静默降级（App 内通知中心不受影响）。
class LocalNotifier {
  LocalNotifier();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _ready = false;

  Future<void> init() async {
    try {
      const android =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const darwin = DarwinInitializationSettings();
      const settings =
          InitializationSettings(android: android, iOS: darwin, macOS: darwin);
      await _plugin.initialize(settings: settings);
      _ready = true;
    } catch (_) {
      _ready = false;
    }
  }

  /// 请求通知权限（macOS / iOS 弹系统对话框；Android 13+ 需要）。
  Future<bool> requestPermission() async {
    if (!_ready) return false;
    try {
      final ios = _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      if (ios != null) {
        return await ios.requestPermissions() ?? false;
      }
      final macos = _plugin.resolvePlatformSpecificImplementation<
          MacOSFlutterLocalNotificationsPlugin>();
      if (macos != null) {
        return await macos.requestPermissions() ?? false;
      }
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (android != null) {
        return await android.requestNotificationsPermission() ?? false;
      }
    } catch (_) {}
    return false;
  }

  /// 发系统通知；kind 决定 Android 渠道。静默失败。
  Future<void> notify({
    required String kind,
    required String title,
    required String body,
  }) async {
    if (!_ready) return;
    try {
      const channelIds = {
        'quotaRecovered': 'quota_recovered',
        'checkinAvailable': 'checkin_available',
        'dataStale': 'data_stale',
      };
      final channelId = channelIds[kind] ?? 'general';
      const channelNames = {
        'quota_recovered': '额度恢复',
        'checkin_available': '签到提醒',
        'data_stale': '数据过期',
        'general': '通用',
      };
      final android = AndroidNotificationDetails(
        channelId,
        channelNames[channelId] ?? '通用',
        importance: Importance.high,
        priority: Priority.high,
      );
      const darwin = DarwinNotificationDetails();
      await _plugin.show(
        id: title.hashCode,
        title: title,
        body: body,
        notificationDetails:
            NotificationDetails(android: android, iOS: darwin, macOS: darwin),
      );
    } catch (_) {
      // 授权被拒 / 平台不支持：App 内通知中心兜底
    }
  }
}
