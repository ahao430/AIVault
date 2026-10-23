import 'package:dio/dio.dart';

// Komari 探针面板客户端。
//
// 端点（实测 + komari-monitor/komari 源码核对）：
// - GET /api/nodes               节点元数据（公开站点免鉴权）
// - GET /api/recent/{uuid}       节点最近状态记录数组（取 updated_at 最新一条）
// - 鉴权（可选）：Authorization: Bearer {API Key}，用于私有站点 / 完整数据
//
// 注意 updated_at 形如 2026-10-23T11:58:57.146902606+08:00
// （纳秒精度，9 位小数），Dart DateTime.parse 只接受 7 位以内，需先裁剪。

/// 单个探针节点：元数据 + 最近一次状态（离线时状态字段为 null）
class KomariNode {
  KomariNode({
    required this.uuid,
    required this.name,
    this.region,
    this.group,
    this.tags,
    this.os,
    this.arch,
    this.cpuName,
    this.virtualization,
    this.cpuCores,
    this.memTotal,
    this.swapTotal,
    this.diskTotal,
    this.trafficLimit,
    this.trafficLimitType,
    this.price,
    this.billingCycle,
    this.expiredAt,
    // 状态
    this.cpuUsage,
    this.load1,
    this.memUsed,
    this.swapUsed,
    this.diskUsed,
    this.netUp,
    this.netDown,
    this.netTotalUp,
    this.netTotalDown,
    this.uptime,
    this.processCount,
    this.tcpConns,
    this.udpConns,
    this.statusAt,
  });

  final String uuid;
  final String name;
  final String? region;
  final String? group;
  final String? tags;
  final String? os;
  final String? arch;
  final String? cpuName;
  final String? virtualization;
  final int? cpuCores;

  // 元数据总量（字节）
  final int? memTotal;
  final int? swapTotal;
  final int? diskTotal;
  final int? trafficLimit;
  final String? trafficLimitType;
  final int? price;
  final int? billingCycle; // 天数：30 / 365 …

  final DateTime? expiredAt;

  // 最近状态
  final double? cpuUsage; // 0-100
  final double? load1;
  final int? memUsed;
  final int? swapUsed;
  final int? diskUsed;
  final int? netUp; // B/s
  final int? netDown;
  final int? netTotalUp;
  final int? netTotalDown;
  final int? uptime; // 秒
  final int? processCount;
  final int? tcpConns;
  final int? udpConns;
  final DateTime? statusAt;

  /// 探针上报间隔约 10~60 秒，超过 2 分钟未上报视为离线
  bool get online {
    final at = statusAt;
    if (at == null) return false;
    return DateTime.now().difference(at) < const Duration(seconds: 120);
  }

  double? get memRatio =>
      (memUsed != null && memTotal != null && memTotal! > 0)
          ? memUsed! / memTotal!
          : null;

  double? get diskRatio =>
      (diskUsed != null && diskTotal != null && diskTotal! > 0)
          ? diskUsed! / diskTotal!
          : null;

  /// 流量用量比例：sum 型按 上行+下行 合计 / 限额，max 型按较大者
  double? get trafficRatio {
    final limit = trafficLimit;
    if (limit == null || limit <= 0) return null;
    if (trafficLimitType == 'max') {
      final used = [netTotalUp ?? 0, netTotalDown ?? 0].reduce((a, b) => a > b ? a : b);
      return used / limit;
    }
    return ((netTotalUp ?? 0) + (netTotalDown ?? 0)) / limit;
  }

  Map<String, dynamic> toJson() => {
        'uuid': uuid,
        'name': name,
        'region': region,
        'group': group,
        'os': os,
        'arch': arch,
        'cpuName': cpuName,
        'virtualization': virtualization,
        'cpuCores': cpuCores,
        'memTotal': memTotal,
        'swapTotal': swapTotal,
        'diskTotal': diskTotal,
        'trafficLimit': trafficLimit,
        'trafficLimitType': trafficLimitType,
        'price': price,
        'billingCycle': billingCycle,
        'expiredAt': expiredAt?.toIso8601String(),
        'cpuUsage': cpuUsage,
        'load1': load1,
        'memUsed': memUsed,
        'swapUsed': swapUsed,
        'diskUsed': diskUsed,
        'netUp': netUp,
        'netDown': netDown,
        'netTotalUp': netTotalUp,
        'netTotalDown': netTotalDown,
        'uptime': uptime,
        'processCount': processCount,
        'tcpConns': tcpConns,
        'udpConns': udpConns,
        'statusAt': statusAt?.toIso8601String(),
      };

  static KomariNode fromJson(Map<String, dynamic> j) => KomariNode(
        uuid: j['uuid'] as String? ?? '',
        name: j['name'] as String? ?? '',
        region: j['region'] as String?,
        group: j['group'] as String?,
        os: j['os'] as String?,
        arch: j['arch'] as String?,
        cpuName: j['cpuName'] as String?,
        virtualization: j['virtualization'] as String?,
        cpuCores: j['cpuCores'] as int?,
        memTotal: j['memTotal'] as int?,
        swapTotal: j['swapTotal'] as int?,
        diskTotal: j['diskTotal'] as int?,
        trafficLimit: j['trafficLimit'] as int?,
        trafficLimitType: j['trafficLimitType'] as String?,
        price: j['price'] as int?,
        billingCycle: j['billingCycle'] as int?,
        expiredAt: j['expiredAt'] == null
            ? null
            : DateTime.parse(j['expiredAt'] as String),
        cpuUsage: (j['cpuUsage'] as num?)?.toDouble(),
        load1: (j['load1'] as num?)?.toDouble(),
        memUsed: j['memUsed'] as int?,
        swapUsed: j['swapUsed'] as int?,
        diskUsed: j['diskUsed'] as int?,
        netUp: j['netUp'] as int?,
        netDown: j['netDown'] as int?,
        netTotalUp: j['netTotalUp'] as int?,
        netTotalDown: j['netTotalDown'] as int?,
        uptime: j['uptime'] as int?,
        processCount: j['processCount'] as int?,
        tcpConns: j['tcpConns'] as int?,
        udpConns: j['udpConns'] as int?,
        statusAt: j['statusAt'] == null
            ? null
            : DateTime.parse(j['statusAt'] as String),
      );
}

/// 裁剪 ISO8601 时间的小数秒到 6 位（Komari 返回纳秒精度）
DateTime? parseKomariTime(dynamic v) {
  if (v is! String || v.isEmpty) return null;
  final trimmed = v.replaceFirstMapped(
      RegExp(r'\.(\d+)'), (m) => '.${m.group(1)!.substring(0, m.group(1)!.length.clamp(0, 6))}');
  return DateTime.tryParse(trimmed);
}

int _i(dynamic v) => v is int
    ? v
    : v is num
        ? v.toInt()
        : 0;

/// 解析 GET /api/nodes 响应 → 节点元数据（无状态）
List<KomariNode> parseKomariNodes(Map<String, dynamic> body) {
  final status = body['status'] as String?;
  if (status != null && status != 'success') {
    throw Exception('Komari: ${body['message'] ?? status}');
  }
  final list = body['data'];
  if (list is! List) return const [];
  return [
    for (final e in list)
      if (e is Map<String, dynamic>)
        KomariNode(
          uuid: e['uuid'] as String? ?? '',
          name: e['name'] as String? ?? '',
          region: e['region'] as String?,
          group: e['group'] as String?,
          tags: e['tags'] as String?,
          os: e['os'] as String?,
          arch: e['arch'] as String?,
          cpuName: e['cpu_name'] as String?,
          virtualization: e['virtualization'] as String?,
          cpuCores: e['cpu_cores'] as int?,
          memTotal: _i(e['mem_total']),
          swapTotal: _i(e['swap_total']),
          diskTotal: _i(e['disk_total']),
          trafficLimit: e['traffic_limit'] is num
              ? (e['traffic_limit'] as num).toInt()
              : null,
          trafficLimitType: e['traffic_limit_type'] as String?,
          price: e['price'] is num ? (e['price'] as num).toInt() : null,
          billingCycle:
              e['billing_cycle'] is num ? (e['billing_cycle'] as num).toInt() : null,
          expiredAt: parseKomariTime(e['expired_at']),
        ),
  ];
}

/// 解析 GET /api/recent/{uuid} 响应 → 最新一条状态；
/// 记录顺序不保证（实测乱序），按 updated_at 取最大
KomariNode applyKomariRecent(KomariNode node, Map<String, dynamic> body) {
  final list = body['data'];
  Map<String, dynamic>? latest;
  DateTime? latestAt;
  if (list is List) {
    for (final e in list) {
      if (e is! Map<String, dynamic>) continue;
      final at = parseKomariTime(e['updated_at']);
      if (at != null && (latestAt == null || at.isAfter(latestAt))) {
        latestAt = at;
        latest = e;
      }
    }
  }
  if (latest == null) return node;

  Map<String, dynamic> pick(String key) {
    final v = latest![key];
    return v is Map<String, dynamic> ? v : const <String, dynamic>{};
  }

  final cpu = pick('cpu');
  final ram = pick('ram');
  final swap = pick('swap');
  final load = pick('load');
  final disk = pick('disk');
  final net = pick('network');
  final conn = pick('connections');

  return KomariNode(
    uuid: node.uuid,
    name: node.name,
    region: node.region,
    group: node.group,
    tags: node.tags,
    os: node.os,
    arch: node.arch,
    cpuName: node.cpuName,
    virtualization: node.virtualization,
    cpuCores: node.cpuCores,
    memTotal: node.memTotal ?? _i(ram['total']),
    swapTotal: node.swapTotal ?? _i(swap['total']),
    diskTotal: node.diskTotal ?? _i(disk['total']),
    trafficLimit: node.trafficLimit,
    trafficLimitType: node.trafficLimitType,
    price: node.price,
    billingCycle: node.billingCycle,
    expiredAt: node.expiredAt,
    cpuUsage: (cpu['usage'] as num?)?.toDouble(),
    load1: (load['load1'] as num?)?.toDouble(),
    memUsed: _i(ram['used']),
    swapUsed: _i(swap['used']),
    diskUsed: _i(disk['used']),
    netUp: _i(net['up']),
    netDown: _i(net['down']),
    netTotalUp: _i(net['totalUp']),
    netTotalDown: _i(net['totalDown']),
    uptime: _i(latest['uptime']),
    processCount: _i(latest['process']),
    tcpConns: _i(conn['tcp']),
    udpConns: _i(conn['udp']),
    statusAt: latestAt,
  );
}

class KomariClient {
  KomariClient({Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 20),
            ));

  final Dio _dio;

  static String normalizeBase(String url) {
    var base = url.trim();
    while (base.endsWith('/')) {
      base = base.substring(0, base.length - 1);
    }
    return base;
  }

  /// 拉取整站节点 + 最新状态。
  /// [token] 为空走公开接口；非空附加 Bearer（私有站点 / 完整数据）。
  Future<List<KomariNode>> fetchSite(String baseUrl, {String? token}) async {
    final base = normalizeBase(baseUrl);
    final headers = <String, dynamic>{};
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    final nodesResp = await _dio.get<Map<String, dynamic>>('$base/api/nodes',
        options: Options(headers: headers));
    final nodes = parseKomariNodes(nodesResp.data ?? const {});

    // 每个节点再拉一次 recent（节点数通常 < 20，并行请求）
    final withStatus = await Future.wait(nodes.map((n) async {
      try {
        final resp = await _dio.get<Map<String, dynamic>>(
            '$base/api/recent/${n.uuid}',
            options: Options(headers: headers));
        return applyKomariRecent(n, resp.data ?? const {});
      } on DioException {
        // 单节点状态失败不影响整站：保留元数据
        return n;
      }
    }));
    return withStatus;
  }
}
