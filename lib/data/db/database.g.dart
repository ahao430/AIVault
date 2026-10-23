// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $ProvidersTable extends Providers
    with TableInfo<$ProvidersTable, Provider> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProvidersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<ProviderType, int> type =
      GeneratedColumn<int>(
        'type',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<ProviderType>($ProvidersTable.$convertertype);
  @override
  late final GeneratedColumnWithTypeConverter<AdapterKind, String> adapterKind =
      GeneratedColumn<String>(
        'adapter_kind',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<AdapterKind>($ProvidersTable.$converteradapterKind);
  static const VerificationMeta _baseUrlMeta = const VerificationMeta(
    'baseUrl',
  );
  @override
  late final GeneratedColumn<String> baseUrl = GeneratedColumn<String>(
    'base_url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _accountLabelMeta = const VerificationMeta(
    'accountLabel',
  );
  @override
  late final GeneratedColumn<String> accountLabel = GeneratedColumn<String>(
    'account_label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _systemTokenRefMeta = const VerificationMeta(
    'systemTokenRef',
  );
  @override
  late final GeneratedColumn<String> systemTokenRef = GeneratedColumn<String>(
    'system_token_ref',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _systemUserIdMeta = const VerificationMeta(
    'systemUserId',
  );
  @override
  late final GeneratedColumn<String> systemUserId = GeneratedColumn<String>(
    'system_user_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _checkinDisabledMeta = const VerificationMeta(
    'checkinDisabled',
  );
  @override
  late final GeneratedColumn<bool> checkinDisabled = GeneratedColumn<bool>(
    'checkin_disabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("checkin_disabled" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _pinnedMeta = const VerificationMeta('pinned');
  @override
  late final GeneratedColumn<bool> pinned = GeneratedColumn<bool>(
    'pinned',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("pinned" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _hiddenMeta = const VerificationMeta('hidden');
  @override
  late final GeneratedColumn<bool> hidden = GeneratedColumn<bool>(
    'hidden',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("hidden" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    type,
    adapterKind,
    baseUrl,
    accountLabel,
    systemTokenRef,
    systemUserId,
    checkinDisabled,
    pinned,
    sortOrder,
    hidden,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'providers';
  @override
  VerificationContext validateIntegrity(
    Insertable<Provider> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('base_url')) {
      context.handle(
        _baseUrlMeta,
        baseUrl.isAcceptableOrUnknown(data['base_url']!, _baseUrlMeta),
      );
    }
    if (data.containsKey('account_label')) {
      context.handle(
        _accountLabelMeta,
        accountLabel.isAcceptableOrUnknown(
          data['account_label']!,
          _accountLabelMeta,
        ),
      );
    }
    if (data.containsKey('system_token_ref')) {
      context.handle(
        _systemTokenRefMeta,
        systemTokenRef.isAcceptableOrUnknown(
          data['system_token_ref']!,
          _systemTokenRefMeta,
        ),
      );
    }
    if (data.containsKey('system_user_id')) {
      context.handle(
        _systemUserIdMeta,
        systemUserId.isAcceptableOrUnknown(
          data['system_user_id']!,
          _systemUserIdMeta,
        ),
      );
    }
    if (data.containsKey('checkin_disabled')) {
      context.handle(
        _checkinDisabledMeta,
        checkinDisabled.isAcceptableOrUnknown(
          data['checkin_disabled']!,
          _checkinDisabledMeta,
        ),
      );
    }
    if (data.containsKey('pinned')) {
      context.handle(
        _pinnedMeta,
        pinned.isAcceptableOrUnknown(data['pinned']!, _pinnedMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('hidden')) {
      context.handle(
        _hiddenMeta,
        hidden.isAcceptableOrUnknown(data['hidden']!, _hiddenMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Provider map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Provider(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      type: $ProvidersTable.$convertertype.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}type'],
        )!,
      ),
      adapterKind: $ProvidersTable.$converteradapterKind.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}adapter_kind'],
        )!,
      ),
      baseUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}base_url'],
      )!,
      accountLabel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_label'],
      )!,
      systemTokenRef: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}system_token_ref'],
      ),
      systemUserId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}system_user_id'],
      ),
      checkinDisabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}checkin_disabled'],
      )!,
      pinned: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}pinned'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      hidden: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}hidden'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $ProvidersTable createAlias(String alias) {
    return $ProvidersTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<ProviderType, int, int> $convertertype =
      const EnumIndexConverter<ProviderType>(ProviderType.values);
  static JsonTypeConverter2<AdapterKind, String, String> $converteradapterKind =
      const EnumNameConverter<AdapterKind>(AdapterKind.values);
}

class Provider extends DataClass implements Insertable<Provider> {
  final String id;
  final String name;
  final ProviderType type;
  final AdapterKind adapterKind;
  final String baseUrl;

  /// 账户标识，例如「个人账号」「公司账号」
  final String accountLabel;

  /// 中转站系统/管理访问令牌在 Secure Storage 中的引用 key（NewAPI 签到、余额用）
  final String? systemTokenRef;

  /// NewAPI 系的部分版本接口要求 New-Api-User 头（用户 ID），明文非敏感
  final String? systemUserId;

  /// 站点未开启签到功能时置 true：隐藏签到入口并跳过批量签到
  final bool checkinDisabled;
  final bool pinned;
  final int sortOrder;
  final bool hidden;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Provider({
    required this.id,
    required this.name,
    required this.type,
    required this.adapterKind,
    required this.baseUrl,
    required this.accountLabel,
    this.systemTokenRef,
    this.systemUserId,
    required this.checkinDisabled,
    required this.pinned,
    required this.sortOrder,
    required this.hidden,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    {
      map['type'] = Variable<int>($ProvidersTable.$convertertype.toSql(type));
    }
    {
      map['adapter_kind'] = Variable<String>(
        $ProvidersTable.$converteradapterKind.toSql(adapterKind),
      );
    }
    map['base_url'] = Variable<String>(baseUrl);
    map['account_label'] = Variable<String>(accountLabel);
    if (!nullToAbsent || systemTokenRef != null) {
      map['system_token_ref'] = Variable<String>(systemTokenRef);
    }
    if (!nullToAbsent || systemUserId != null) {
      map['system_user_id'] = Variable<String>(systemUserId);
    }
    map['checkin_disabled'] = Variable<bool>(checkinDisabled);
    map['pinned'] = Variable<bool>(pinned);
    map['sort_order'] = Variable<int>(sortOrder);
    map['hidden'] = Variable<bool>(hidden);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ProvidersCompanion toCompanion(bool nullToAbsent) {
    return ProvidersCompanion(
      id: Value(id),
      name: Value(name),
      type: Value(type),
      adapterKind: Value(adapterKind),
      baseUrl: Value(baseUrl),
      accountLabel: Value(accountLabel),
      systemTokenRef: systemTokenRef == null && nullToAbsent
          ? const Value.absent()
          : Value(systemTokenRef),
      systemUserId: systemUserId == null && nullToAbsent
          ? const Value.absent()
          : Value(systemUserId),
      checkinDisabled: Value(checkinDisabled),
      pinned: Value(pinned),
      sortOrder: Value(sortOrder),
      hidden: Value(hidden),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Provider.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Provider(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      type: $ProvidersTable.$convertertype.fromJson(
        serializer.fromJson<int>(json['type']),
      ),
      adapterKind: $ProvidersTable.$converteradapterKind.fromJson(
        serializer.fromJson<String>(json['adapterKind']),
      ),
      baseUrl: serializer.fromJson<String>(json['baseUrl']),
      accountLabel: serializer.fromJson<String>(json['accountLabel']),
      systemTokenRef: serializer.fromJson<String?>(json['systemTokenRef']),
      systemUserId: serializer.fromJson<String?>(json['systemUserId']),
      checkinDisabled: serializer.fromJson<bool>(json['checkinDisabled']),
      pinned: serializer.fromJson<bool>(json['pinned']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      hidden: serializer.fromJson<bool>(json['hidden']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'type': serializer.toJson<int>(
        $ProvidersTable.$convertertype.toJson(type),
      ),
      'adapterKind': serializer.toJson<String>(
        $ProvidersTable.$converteradapterKind.toJson(adapterKind),
      ),
      'baseUrl': serializer.toJson<String>(baseUrl),
      'accountLabel': serializer.toJson<String>(accountLabel),
      'systemTokenRef': serializer.toJson<String?>(systemTokenRef),
      'systemUserId': serializer.toJson<String?>(systemUserId),
      'checkinDisabled': serializer.toJson<bool>(checkinDisabled),
      'pinned': serializer.toJson<bool>(pinned),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'hidden': serializer.toJson<bool>(hidden),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Provider copyWith({
    String? id,
    String? name,
    ProviderType? type,
    AdapterKind? adapterKind,
    String? baseUrl,
    String? accountLabel,
    Value<String?> systemTokenRef = const Value.absent(),
    Value<String?> systemUserId = const Value.absent(),
    bool? checkinDisabled,
    bool? pinned,
    int? sortOrder,
    bool? hidden,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Provider(
    id: id ?? this.id,
    name: name ?? this.name,
    type: type ?? this.type,
    adapterKind: adapterKind ?? this.adapterKind,
    baseUrl: baseUrl ?? this.baseUrl,
    accountLabel: accountLabel ?? this.accountLabel,
    systemTokenRef: systemTokenRef.present
        ? systemTokenRef.value
        : this.systemTokenRef,
    systemUserId: systemUserId.present ? systemUserId.value : this.systemUserId,
    checkinDisabled: checkinDisabled ?? this.checkinDisabled,
    pinned: pinned ?? this.pinned,
    sortOrder: sortOrder ?? this.sortOrder,
    hidden: hidden ?? this.hidden,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Provider copyWithCompanion(ProvidersCompanion data) {
    return Provider(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      type: data.type.present ? data.type.value : this.type,
      adapterKind: data.adapterKind.present
          ? data.adapterKind.value
          : this.adapterKind,
      baseUrl: data.baseUrl.present ? data.baseUrl.value : this.baseUrl,
      accountLabel: data.accountLabel.present
          ? data.accountLabel.value
          : this.accountLabel,
      systemTokenRef: data.systemTokenRef.present
          ? data.systemTokenRef.value
          : this.systemTokenRef,
      systemUserId: data.systemUserId.present
          ? data.systemUserId.value
          : this.systemUserId,
      checkinDisabled: data.checkinDisabled.present
          ? data.checkinDisabled.value
          : this.checkinDisabled,
      pinned: data.pinned.present ? data.pinned.value : this.pinned,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      hidden: data.hidden.present ? data.hidden.value : this.hidden,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Provider(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('adapterKind: $adapterKind, ')
          ..write('baseUrl: $baseUrl, ')
          ..write('accountLabel: $accountLabel, ')
          ..write('systemTokenRef: $systemTokenRef, ')
          ..write('systemUserId: $systemUserId, ')
          ..write('checkinDisabled: $checkinDisabled, ')
          ..write('pinned: $pinned, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('hidden: $hidden, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    type,
    adapterKind,
    baseUrl,
    accountLabel,
    systemTokenRef,
    systemUserId,
    checkinDisabled,
    pinned,
    sortOrder,
    hidden,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Provider &&
          other.id == this.id &&
          other.name == this.name &&
          other.type == this.type &&
          other.adapterKind == this.adapterKind &&
          other.baseUrl == this.baseUrl &&
          other.accountLabel == this.accountLabel &&
          other.systemTokenRef == this.systemTokenRef &&
          other.systemUserId == this.systemUserId &&
          other.checkinDisabled == this.checkinDisabled &&
          other.pinned == this.pinned &&
          other.sortOrder == this.sortOrder &&
          other.hidden == this.hidden &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ProvidersCompanion extends UpdateCompanion<Provider> {
  final Value<String> id;
  final Value<String> name;
  final Value<ProviderType> type;
  final Value<AdapterKind> adapterKind;
  final Value<String> baseUrl;
  final Value<String> accountLabel;
  final Value<String?> systemTokenRef;
  final Value<String?> systemUserId;
  final Value<bool> checkinDisabled;
  final Value<bool> pinned;
  final Value<int> sortOrder;
  final Value<bool> hidden;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const ProvidersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.type = const Value.absent(),
    this.adapterKind = const Value.absent(),
    this.baseUrl = const Value.absent(),
    this.accountLabel = const Value.absent(),
    this.systemTokenRef = const Value.absent(),
    this.systemUserId = const Value.absent(),
    this.checkinDisabled = const Value.absent(),
    this.pinned = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.hidden = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProvidersCompanion.insert({
    required String id,
    required String name,
    required ProviderType type,
    required AdapterKind adapterKind,
    this.baseUrl = const Value.absent(),
    this.accountLabel = const Value.absent(),
    this.systemTokenRef = const Value.absent(),
    this.systemUserId = const Value.absent(),
    this.checkinDisabled = const Value.absent(),
    this.pinned = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.hidden = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       type = Value(type),
       adapterKind = Value(adapterKind),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Provider> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<int>? type,
    Expression<String>? adapterKind,
    Expression<String>? baseUrl,
    Expression<String>? accountLabel,
    Expression<String>? systemTokenRef,
    Expression<String>? systemUserId,
    Expression<bool>? checkinDisabled,
    Expression<bool>? pinned,
    Expression<int>? sortOrder,
    Expression<bool>? hidden,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (adapterKind != null) 'adapter_kind': adapterKind,
      if (baseUrl != null) 'base_url': baseUrl,
      if (accountLabel != null) 'account_label': accountLabel,
      if (systemTokenRef != null) 'system_token_ref': systemTokenRef,
      if (systemUserId != null) 'system_user_id': systemUserId,
      if (checkinDisabled != null) 'checkin_disabled': checkinDisabled,
      if (pinned != null) 'pinned': pinned,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (hidden != null) 'hidden': hidden,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProvidersCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<ProviderType>? type,
    Value<AdapterKind>? adapterKind,
    Value<String>? baseUrl,
    Value<String>? accountLabel,
    Value<String?>? systemTokenRef,
    Value<String?>? systemUserId,
    Value<bool>? checkinDisabled,
    Value<bool>? pinned,
    Value<int>? sortOrder,
    Value<bool>? hidden,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return ProvidersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      adapterKind: adapterKind ?? this.adapterKind,
      baseUrl: baseUrl ?? this.baseUrl,
      accountLabel: accountLabel ?? this.accountLabel,
      systemTokenRef: systemTokenRef ?? this.systemTokenRef,
      systemUserId: systemUserId ?? this.systemUserId,
      checkinDisabled: checkinDisabled ?? this.checkinDisabled,
      pinned: pinned ?? this.pinned,
      sortOrder: sortOrder ?? this.sortOrder,
      hidden: hidden ?? this.hidden,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (type.present) {
      map['type'] = Variable<int>(
        $ProvidersTable.$convertertype.toSql(type.value),
      );
    }
    if (adapterKind.present) {
      map['adapter_kind'] = Variable<String>(
        $ProvidersTable.$converteradapterKind.toSql(adapterKind.value),
      );
    }
    if (baseUrl.present) {
      map['base_url'] = Variable<String>(baseUrl.value);
    }
    if (accountLabel.present) {
      map['account_label'] = Variable<String>(accountLabel.value);
    }
    if (systemTokenRef.present) {
      map['system_token_ref'] = Variable<String>(systemTokenRef.value);
    }
    if (systemUserId.present) {
      map['system_user_id'] = Variable<String>(systemUserId.value);
    }
    if (checkinDisabled.present) {
      map['checkin_disabled'] = Variable<bool>(checkinDisabled.value);
    }
    if (pinned.present) {
      map['pinned'] = Variable<bool>(pinned.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (hidden.present) {
      map['hidden'] = Variable<bool>(hidden.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProvidersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('adapterKind: $adapterKind, ')
          ..write('baseUrl: $baseUrl, ')
          ..write('accountLabel: $accountLabel, ')
          ..write('systemTokenRef: $systemTokenRef, ')
          ..write('systemUserId: $systemUserId, ')
          ..write('checkinDisabled: $checkinDisabled, ')
          ..write('pinned: $pinned, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('hidden: $hidden, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TokensTable extends Tokens with TableInfo<$TokensTable, Token> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TokensTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _providerIdMeta = const VerificationMeta(
    'providerId',
  );
  @override
  late final GeneratedColumn<String> providerId = GeneratedColumn<String>(
    'provider_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES providers (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _secretRefMeta = const VerificationMeta(
    'secretRef',
  );
  @override
  late final GeneratedColumn<String> secretRef = GeneratedColumn<String>(
    'secret_ref',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    providerId,
    name,
    secretRef,
    note,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tokens';
  @override
  VerificationContext validateIntegrity(
    Insertable<Token> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('provider_id')) {
      context.handle(
        _providerIdMeta,
        providerId.isAcceptableOrUnknown(data['provider_id']!, _providerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_providerIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    }
    if (data.containsKey('secret_ref')) {
      context.handle(
        _secretRefMeta,
        secretRef.isAcceptableOrUnknown(data['secret_ref']!, _secretRefMeta),
      );
    } else if (isInserting) {
      context.missing(_secretRefMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Token map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Token(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      providerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}provider_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      secretRef: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}secret_ref'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $TokensTable createAlias(String alias) {
    return $TokensTable(attachedDatabase, alias);
  }
}

class Token extends DataClass implements Insertable<Token> {
  final String id;
  final String providerId;
  final String name;

  /// API Key 在 Secure Storage 中的引用 key，数据库不保存明文
  final String secretRef;
  final String note;
  final DateTime createdAt;
  const Token({
    required this.id,
    required this.providerId,
    required this.name,
    required this.secretRef,
    required this.note,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['provider_id'] = Variable<String>(providerId);
    map['name'] = Variable<String>(name);
    map['secret_ref'] = Variable<String>(secretRef);
    map['note'] = Variable<String>(note);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  TokensCompanion toCompanion(bool nullToAbsent) {
    return TokensCompanion(
      id: Value(id),
      providerId: Value(providerId),
      name: Value(name),
      secretRef: Value(secretRef),
      note: Value(note),
      createdAt: Value(createdAt),
    );
  }

  factory Token.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Token(
      id: serializer.fromJson<String>(json['id']),
      providerId: serializer.fromJson<String>(json['providerId']),
      name: serializer.fromJson<String>(json['name']),
      secretRef: serializer.fromJson<String>(json['secretRef']),
      note: serializer.fromJson<String>(json['note']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'providerId': serializer.toJson<String>(providerId),
      'name': serializer.toJson<String>(name),
      'secretRef': serializer.toJson<String>(secretRef),
      'note': serializer.toJson<String>(note),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Token copyWith({
    String? id,
    String? providerId,
    String? name,
    String? secretRef,
    String? note,
    DateTime? createdAt,
  }) => Token(
    id: id ?? this.id,
    providerId: providerId ?? this.providerId,
    name: name ?? this.name,
    secretRef: secretRef ?? this.secretRef,
    note: note ?? this.note,
    createdAt: createdAt ?? this.createdAt,
  );
  Token copyWithCompanion(TokensCompanion data) {
    return Token(
      id: data.id.present ? data.id.value : this.id,
      providerId: data.providerId.present
          ? data.providerId.value
          : this.providerId,
      name: data.name.present ? data.name.value : this.name,
      secretRef: data.secretRef.present ? data.secretRef.value : this.secretRef,
      note: data.note.present ? data.note.value : this.note,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Token(')
          ..write('id: $id, ')
          ..write('providerId: $providerId, ')
          ..write('name: $name, ')
          ..write('secretRef: $secretRef, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, providerId, name, secretRef, note, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Token &&
          other.id == this.id &&
          other.providerId == this.providerId &&
          other.name == this.name &&
          other.secretRef == this.secretRef &&
          other.note == this.note &&
          other.createdAt == this.createdAt);
}

class TokensCompanion extends UpdateCompanion<Token> {
  final Value<String> id;
  final Value<String> providerId;
  final Value<String> name;
  final Value<String> secretRef;
  final Value<String> note;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const TokensCompanion({
    this.id = const Value.absent(),
    this.providerId = const Value.absent(),
    this.name = const Value.absent(),
    this.secretRef = const Value.absent(),
    this.note = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TokensCompanion.insert({
    required String id,
    required String providerId,
    this.name = const Value.absent(),
    required String secretRef,
    this.note = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       providerId = Value(providerId),
       secretRef = Value(secretRef),
       createdAt = Value(createdAt);
  static Insertable<Token> custom({
    Expression<String>? id,
    Expression<String>? providerId,
    Expression<String>? name,
    Expression<String>? secretRef,
    Expression<String>? note,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (providerId != null) 'provider_id': providerId,
      if (name != null) 'name': name,
      if (secretRef != null) 'secret_ref': secretRef,
      if (note != null) 'note': note,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TokensCompanion copyWith({
    Value<String>? id,
    Value<String>? providerId,
    Value<String>? name,
    Value<String>? secretRef,
    Value<String>? note,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return TokensCompanion(
      id: id ?? this.id,
      providerId: providerId ?? this.providerId,
      name: name ?? this.name,
      secretRef: secretRef ?? this.secretRef,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (providerId.present) {
      map['provider_id'] = Variable<String>(providerId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (secretRef.present) {
      map['secret_ref'] = Variable<String>(secretRef.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TokensCompanion(')
          ..write('id: $id, ')
          ..write('providerId: $providerId, ')
          ..write('name: $name, ')
          ..write('secretRef: $secretRef, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProviderModelsTable extends ProviderModels
    with TableInfo<$ProviderModelsTable, ProviderModel> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProviderModelsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tokenIdMeta = const VerificationMeta(
    'tokenId',
  );
  @override
  late final GeneratedColumn<String> tokenId = GeneratedColumn<String>(
    'token_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tokens (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _modelIdMeta = const VerificationMeta(
    'modelId',
  );
  @override
  late final GeneratedColumn<String> modelId = GeneratedColumn<String>(
    'model_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _enabledMeta = const VerificationMeta(
    'enabled',
  );
  @override
  late final GeneratedColumn<bool> enabled = GeneratedColumn<bool>(
    'enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _lastTestAtMeta = const VerificationMeta(
    'lastTestAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastTestAt = GeneratedColumn<DateTime>(
    'last_test_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastTestStatusMeta = const VerificationMeta(
    'lastTestStatus',
  );
  @override
  late final GeneratedColumn<String> lastTestStatus = GeneratedColumn<String>(
    'last_test_status',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastTestLatencyMsMeta = const VerificationMeta(
    'lastTestLatencyMs',
  );
  @override
  late final GeneratedColumn<int> lastTestLatencyMs = GeneratedColumn<int>(
    'last_test_latency_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    tokenId,
    modelId,
    displayName,
    enabled,
    lastTestAt,
    lastTestStatus,
    lastTestLatencyMs,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'provider_models';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProviderModel> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('token_id')) {
      context.handle(
        _tokenIdMeta,
        tokenId.isAcceptableOrUnknown(data['token_id']!, _tokenIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tokenIdMeta);
    }
    if (data.containsKey('model_id')) {
      context.handle(
        _modelIdMeta,
        modelId.isAcceptableOrUnknown(data['model_id']!, _modelIdMeta),
      );
    } else if (isInserting) {
      context.missing(_modelIdMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    }
    if (data.containsKey('enabled')) {
      context.handle(
        _enabledMeta,
        enabled.isAcceptableOrUnknown(data['enabled']!, _enabledMeta),
      );
    }
    if (data.containsKey('last_test_at')) {
      context.handle(
        _lastTestAtMeta,
        lastTestAt.isAcceptableOrUnknown(
          data['last_test_at']!,
          _lastTestAtMeta,
        ),
      );
    }
    if (data.containsKey('last_test_status')) {
      context.handle(
        _lastTestStatusMeta,
        lastTestStatus.isAcceptableOrUnknown(
          data['last_test_status']!,
          _lastTestStatusMeta,
        ),
      );
    }
    if (data.containsKey('last_test_latency_ms')) {
      context.handle(
        _lastTestLatencyMsMeta,
        lastTestLatencyMs.isAcceptableOrUnknown(
          data['last_test_latency_ms']!,
          _lastTestLatencyMsMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProviderModel map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProviderModel(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      tokenId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}token_id'],
      )!,
      modelId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}model_id'],
      )!,
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      )!,
      enabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}enabled'],
      )!,
      lastTestAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_test_at'],
      ),
      lastTestStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_test_status'],
      ),
      lastTestLatencyMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_test_latency_ms'],
      ),
    );
  }

  @override
  $ProviderModelsTable createAlias(String alias) {
    return $ProviderModelsTable(attachedDatabase, alias);
  }
}

class ProviderModel extends DataClass implements Insertable<ProviderModel> {
  final String id;
  final String tokenId;
  final String modelId;
  final String displayName;
  final bool enabled;
  final DateTime? lastTestAt;

  /// 最近一次测试结果：success / failed / null = 未测试
  final String? lastTestStatus;
  final int? lastTestLatencyMs;
  const ProviderModel({
    required this.id,
    required this.tokenId,
    required this.modelId,
    required this.displayName,
    required this.enabled,
    this.lastTestAt,
    this.lastTestStatus,
    this.lastTestLatencyMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['token_id'] = Variable<String>(tokenId);
    map['model_id'] = Variable<String>(modelId);
    map['display_name'] = Variable<String>(displayName);
    map['enabled'] = Variable<bool>(enabled);
    if (!nullToAbsent || lastTestAt != null) {
      map['last_test_at'] = Variable<DateTime>(lastTestAt);
    }
    if (!nullToAbsent || lastTestStatus != null) {
      map['last_test_status'] = Variable<String>(lastTestStatus);
    }
    if (!nullToAbsent || lastTestLatencyMs != null) {
      map['last_test_latency_ms'] = Variable<int>(lastTestLatencyMs);
    }
    return map;
  }

  ProviderModelsCompanion toCompanion(bool nullToAbsent) {
    return ProviderModelsCompanion(
      id: Value(id),
      tokenId: Value(tokenId),
      modelId: Value(modelId),
      displayName: Value(displayName),
      enabled: Value(enabled),
      lastTestAt: lastTestAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastTestAt),
      lastTestStatus: lastTestStatus == null && nullToAbsent
          ? const Value.absent()
          : Value(lastTestStatus),
      lastTestLatencyMs: lastTestLatencyMs == null && nullToAbsent
          ? const Value.absent()
          : Value(lastTestLatencyMs),
    );
  }

  factory ProviderModel.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProviderModel(
      id: serializer.fromJson<String>(json['id']),
      tokenId: serializer.fromJson<String>(json['tokenId']),
      modelId: serializer.fromJson<String>(json['modelId']),
      displayName: serializer.fromJson<String>(json['displayName']),
      enabled: serializer.fromJson<bool>(json['enabled']),
      lastTestAt: serializer.fromJson<DateTime?>(json['lastTestAt']),
      lastTestStatus: serializer.fromJson<String?>(json['lastTestStatus']),
      lastTestLatencyMs: serializer.fromJson<int?>(json['lastTestLatencyMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'tokenId': serializer.toJson<String>(tokenId),
      'modelId': serializer.toJson<String>(modelId),
      'displayName': serializer.toJson<String>(displayName),
      'enabled': serializer.toJson<bool>(enabled),
      'lastTestAt': serializer.toJson<DateTime?>(lastTestAt),
      'lastTestStatus': serializer.toJson<String?>(lastTestStatus),
      'lastTestLatencyMs': serializer.toJson<int?>(lastTestLatencyMs),
    };
  }

  ProviderModel copyWith({
    String? id,
    String? tokenId,
    String? modelId,
    String? displayName,
    bool? enabled,
    Value<DateTime?> lastTestAt = const Value.absent(),
    Value<String?> lastTestStatus = const Value.absent(),
    Value<int?> lastTestLatencyMs = const Value.absent(),
  }) => ProviderModel(
    id: id ?? this.id,
    tokenId: tokenId ?? this.tokenId,
    modelId: modelId ?? this.modelId,
    displayName: displayName ?? this.displayName,
    enabled: enabled ?? this.enabled,
    lastTestAt: lastTestAt.present ? lastTestAt.value : this.lastTestAt,
    lastTestStatus: lastTestStatus.present
        ? lastTestStatus.value
        : this.lastTestStatus,
    lastTestLatencyMs: lastTestLatencyMs.present
        ? lastTestLatencyMs.value
        : this.lastTestLatencyMs,
  );
  ProviderModel copyWithCompanion(ProviderModelsCompanion data) {
    return ProviderModel(
      id: data.id.present ? data.id.value : this.id,
      tokenId: data.tokenId.present ? data.tokenId.value : this.tokenId,
      modelId: data.modelId.present ? data.modelId.value : this.modelId,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      enabled: data.enabled.present ? data.enabled.value : this.enabled,
      lastTestAt: data.lastTestAt.present
          ? data.lastTestAt.value
          : this.lastTestAt,
      lastTestStatus: data.lastTestStatus.present
          ? data.lastTestStatus.value
          : this.lastTestStatus,
      lastTestLatencyMs: data.lastTestLatencyMs.present
          ? data.lastTestLatencyMs.value
          : this.lastTestLatencyMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProviderModel(')
          ..write('id: $id, ')
          ..write('tokenId: $tokenId, ')
          ..write('modelId: $modelId, ')
          ..write('displayName: $displayName, ')
          ..write('enabled: $enabled, ')
          ..write('lastTestAt: $lastTestAt, ')
          ..write('lastTestStatus: $lastTestStatus, ')
          ..write('lastTestLatencyMs: $lastTestLatencyMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    tokenId,
    modelId,
    displayName,
    enabled,
    lastTestAt,
    lastTestStatus,
    lastTestLatencyMs,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProviderModel &&
          other.id == this.id &&
          other.tokenId == this.tokenId &&
          other.modelId == this.modelId &&
          other.displayName == this.displayName &&
          other.enabled == this.enabled &&
          other.lastTestAt == this.lastTestAt &&
          other.lastTestStatus == this.lastTestStatus &&
          other.lastTestLatencyMs == this.lastTestLatencyMs);
}

class ProviderModelsCompanion extends UpdateCompanion<ProviderModel> {
  final Value<String> id;
  final Value<String> tokenId;
  final Value<String> modelId;
  final Value<String> displayName;
  final Value<bool> enabled;
  final Value<DateTime?> lastTestAt;
  final Value<String?> lastTestStatus;
  final Value<int?> lastTestLatencyMs;
  final Value<int> rowid;
  const ProviderModelsCompanion({
    this.id = const Value.absent(),
    this.tokenId = const Value.absent(),
    this.modelId = const Value.absent(),
    this.displayName = const Value.absent(),
    this.enabled = const Value.absent(),
    this.lastTestAt = const Value.absent(),
    this.lastTestStatus = const Value.absent(),
    this.lastTestLatencyMs = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProviderModelsCompanion.insert({
    required String id,
    required String tokenId,
    required String modelId,
    this.displayName = const Value.absent(),
    this.enabled = const Value.absent(),
    this.lastTestAt = const Value.absent(),
    this.lastTestStatus = const Value.absent(),
    this.lastTestLatencyMs = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       tokenId = Value(tokenId),
       modelId = Value(modelId);
  static Insertable<ProviderModel> custom({
    Expression<String>? id,
    Expression<String>? tokenId,
    Expression<String>? modelId,
    Expression<String>? displayName,
    Expression<bool>? enabled,
    Expression<DateTime>? lastTestAt,
    Expression<String>? lastTestStatus,
    Expression<int>? lastTestLatencyMs,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tokenId != null) 'token_id': tokenId,
      if (modelId != null) 'model_id': modelId,
      if (displayName != null) 'display_name': displayName,
      if (enabled != null) 'enabled': enabled,
      if (lastTestAt != null) 'last_test_at': lastTestAt,
      if (lastTestStatus != null) 'last_test_status': lastTestStatus,
      if (lastTestLatencyMs != null) 'last_test_latency_ms': lastTestLatencyMs,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProviderModelsCompanion copyWith({
    Value<String>? id,
    Value<String>? tokenId,
    Value<String>? modelId,
    Value<String>? displayName,
    Value<bool>? enabled,
    Value<DateTime?>? lastTestAt,
    Value<String?>? lastTestStatus,
    Value<int?>? lastTestLatencyMs,
    Value<int>? rowid,
  }) {
    return ProviderModelsCompanion(
      id: id ?? this.id,
      tokenId: tokenId ?? this.tokenId,
      modelId: modelId ?? this.modelId,
      displayName: displayName ?? this.displayName,
      enabled: enabled ?? this.enabled,
      lastTestAt: lastTestAt ?? this.lastTestAt,
      lastTestStatus: lastTestStatus ?? this.lastTestStatus,
      lastTestLatencyMs: lastTestLatencyMs ?? this.lastTestLatencyMs,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (tokenId.present) {
      map['token_id'] = Variable<String>(tokenId.value);
    }
    if (modelId.present) {
      map['model_id'] = Variable<String>(modelId.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (enabled.present) {
      map['enabled'] = Variable<bool>(enabled.value);
    }
    if (lastTestAt.present) {
      map['last_test_at'] = Variable<DateTime>(lastTestAt.value);
    }
    if (lastTestStatus.present) {
      map['last_test_status'] = Variable<String>(lastTestStatus.value);
    }
    if (lastTestLatencyMs.present) {
      map['last_test_latency_ms'] = Variable<int>(lastTestLatencyMs.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProviderModelsCompanion(')
          ..write('id: $id, ')
          ..write('tokenId: $tokenId, ')
          ..write('modelId: $modelId, ')
          ..write('displayName: $displayName, ')
          ..write('enabled: $enabled, ')
          ..write('lastTestAt: $lastTestAt, ')
          ..write('lastTestStatus: $lastTestStatus, ')
          ..write('lastTestLatencyMs: $lastTestLatencyMs, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $QuotaSnapshotsTable extends QuotaSnapshots
    with TableInfo<$QuotaSnapshotsTable, QuotaSnapshot> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $QuotaSnapshotsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _providerIdMeta = const VerificationMeta(
    'providerId',
  );
  @override
  late final GeneratedColumn<String> providerId = GeneratedColumn<String>(
    'provider_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES providers (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _timestampMeta = const VerificationMeta(
    'timestamp',
  );
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
    'timestamp',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<QuotaKind, int> kind =
      GeneratedColumn<int>(
        'kind',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<QuotaKind>($QuotaSnapshotsTable.$converterkind);
  static const VerificationMeta _ratioMeta = const VerificationMeta('ratio');
  @override
  late final GeneratedColumn<double> ratio = GeneratedColumn<double>(
    'ratio',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _remainingMeta = const VerificationMeta(
    'remaining',
  );
  @override
  late final GeneratedColumn<double> remaining = GeneratedColumn<double>(
    'remaining',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _totalMeta = const VerificationMeta('total');
  @override
  late final GeneratedColumn<double> total = GeneratedColumn<double>(
    'total',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _currencyMeta = const VerificationMeta(
    'currency',
  );
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _resetAtMeta = const VerificationMeta(
    'resetAt',
  );
  @override
  late final GeneratedColumn<DateTime> resetAt = GeneratedColumn<DateTime>(
    'reset_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('unknown'),
  );
  static const VerificationMeta _successMeta = const VerificationMeta(
    'success',
  );
  @override
  late final GeneratedColumn<bool> success = GeneratedColumn<bool>(
    'success',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("success" IN (0, 1))',
    ),
  );
  static const VerificationMeta _messageMeta = const VerificationMeta(
    'message',
  );
  @override
  late final GeneratedColumn<String> message = GeneratedColumn<String>(
    'message',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    providerId,
    timestamp,
    kind,
    ratio,
    remaining,
    total,
    amount,
    currency,
    resetAt,
    source,
    success,
    message,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'quota_snapshots';
  @override
  VerificationContext validateIntegrity(
    Insertable<QuotaSnapshot> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('provider_id')) {
      context.handle(
        _providerIdMeta,
        providerId.isAcceptableOrUnknown(data['provider_id']!, _providerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_providerIdMeta);
    }
    if (data.containsKey('timestamp')) {
      context.handle(
        _timestampMeta,
        timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta),
      );
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    if (data.containsKey('ratio')) {
      context.handle(
        _ratioMeta,
        ratio.isAcceptableOrUnknown(data['ratio']!, _ratioMeta),
      );
    }
    if (data.containsKey('remaining')) {
      context.handle(
        _remainingMeta,
        remaining.isAcceptableOrUnknown(data['remaining']!, _remainingMeta),
      );
    }
    if (data.containsKey('total')) {
      context.handle(
        _totalMeta,
        total.isAcceptableOrUnknown(data['total']!, _totalMeta),
      );
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    }
    if (data.containsKey('reset_at')) {
      context.handle(
        _resetAtMeta,
        resetAt.isAcceptableOrUnknown(data['reset_at']!, _resetAtMeta),
      );
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    }
    if (data.containsKey('success')) {
      context.handle(
        _successMeta,
        success.isAcceptableOrUnknown(data['success']!, _successMeta),
      );
    } else if (isInserting) {
      context.missing(_successMeta);
    }
    if (data.containsKey('message')) {
      context.handle(
        _messageMeta,
        message.isAcceptableOrUnknown(data['message']!, _messageMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  QuotaSnapshot map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return QuotaSnapshot(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      providerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}provider_id'],
      )!,
      timestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}timestamp'],
      )!,
      kind: $QuotaSnapshotsTable.$converterkind.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}kind'],
        )!,
      ),
      ratio: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}ratio'],
      ),
      remaining: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}remaining'],
      ),
      total: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}total'],
      ),
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      ),
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      ),
      resetAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}reset_at'],
      ),
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      success: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}success'],
      )!,
      message: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}message'],
      ),
    );
  }

  @override
  $QuotaSnapshotsTable createAlias(String alias) {
    return $QuotaSnapshotsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<QuotaKind, int, int> $converterkind =
      const EnumIndexConverter<QuotaKind>(QuotaKind.values);
}

class QuotaSnapshot extends DataClass implements Insertable<QuotaSnapshot> {
  final int id;
  final String providerId;
  final DateTime timestamp;
  final QuotaKind kind;

  /// 剩余比例 0.0 ~ 1.0（额度类）
  final double? ratio;
  final double? remaining;
  final double? total;

  /// 余额金额 + 币种
  final double? amount;
  final String? currency;
  final DateTime? resetAt;

  /// 数据来源：official / estimated / unknown
  final String source;
  final bool success;
  final String? message;
  const QuotaSnapshot({
    required this.id,
    required this.providerId,
    required this.timestamp,
    required this.kind,
    this.ratio,
    this.remaining,
    this.total,
    this.amount,
    this.currency,
    this.resetAt,
    required this.source,
    required this.success,
    this.message,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['provider_id'] = Variable<String>(providerId);
    map['timestamp'] = Variable<DateTime>(timestamp);
    {
      map['kind'] = Variable<int>(
        $QuotaSnapshotsTable.$converterkind.toSql(kind),
      );
    }
    if (!nullToAbsent || ratio != null) {
      map['ratio'] = Variable<double>(ratio);
    }
    if (!nullToAbsent || remaining != null) {
      map['remaining'] = Variable<double>(remaining);
    }
    if (!nullToAbsent || total != null) {
      map['total'] = Variable<double>(total);
    }
    if (!nullToAbsent || amount != null) {
      map['amount'] = Variable<double>(amount);
    }
    if (!nullToAbsent || currency != null) {
      map['currency'] = Variable<String>(currency);
    }
    if (!nullToAbsent || resetAt != null) {
      map['reset_at'] = Variable<DateTime>(resetAt);
    }
    map['source'] = Variable<String>(source);
    map['success'] = Variable<bool>(success);
    if (!nullToAbsent || message != null) {
      map['message'] = Variable<String>(message);
    }
    return map;
  }

  QuotaSnapshotsCompanion toCompanion(bool nullToAbsent) {
    return QuotaSnapshotsCompanion(
      id: Value(id),
      providerId: Value(providerId),
      timestamp: Value(timestamp),
      kind: Value(kind),
      ratio: ratio == null && nullToAbsent
          ? const Value.absent()
          : Value(ratio),
      remaining: remaining == null && nullToAbsent
          ? const Value.absent()
          : Value(remaining),
      total: total == null && nullToAbsent
          ? const Value.absent()
          : Value(total),
      amount: amount == null && nullToAbsent
          ? const Value.absent()
          : Value(amount),
      currency: currency == null && nullToAbsent
          ? const Value.absent()
          : Value(currency),
      resetAt: resetAt == null && nullToAbsent
          ? const Value.absent()
          : Value(resetAt),
      source: Value(source),
      success: Value(success),
      message: message == null && nullToAbsent
          ? const Value.absent()
          : Value(message),
    );
  }

  factory QuotaSnapshot.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return QuotaSnapshot(
      id: serializer.fromJson<int>(json['id']),
      providerId: serializer.fromJson<String>(json['providerId']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
      kind: $QuotaSnapshotsTable.$converterkind.fromJson(
        serializer.fromJson<int>(json['kind']),
      ),
      ratio: serializer.fromJson<double?>(json['ratio']),
      remaining: serializer.fromJson<double?>(json['remaining']),
      total: serializer.fromJson<double?>(json['total']),
      amount: serializer.fromJson<double?>(json['amount']),
      currency: serializer.fromJson<String?>(json['currency']),
      resetAt: serializer.fromJson<DateTime?>(json['resetAt']),
      source: serializer.fromJson<String>(json['source']),
      success: serializer.fromJson<bool>(json['success']),
      message: serializer.fromJson<String?>(json['message']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'providerId': serializer.toJson<String>(providerId),
      'timestamp': serializer.toJson<DateTime>(timestamp),
      'kind': serializer.toJson<int>(
        $QuotaSnapshotsTable.$converterkind.toJson(kind),
      ),
      'ratio': serializer.toJson<double?>(ratio),
      'remaining': serializer.toJson<double?>(remaining),
      'total': serializer.toJson<double?>(total),
      'amount': serializer.toJson<double?>(amount),
      'currency': serializer.toJson<String?>(currency),
      'resetAt': serializer.toJson<DateTime?>(resetAt),
      'source': serializer.toJson<String>(source),
      'success': serializer.toJson<bool>(success),
      'message': serializer.toJson<String?>(message),
    };
  }

  QuotaSnapshot copyWith({
    int? id,
    String? providerId,
    DateTime? timestamp,
    QuotaKind? kind,
    Value<double?> ratio = const Value.absent(),
    Value<double?> remaining = const Value.absent(),
    Value<double?> total = const Value.absent(),
    Value<double?> amount = const Value.absent(),
    Value<String?> currency = const Value.absent(),
    Value<DateTime?> resetAt = const Value.absent(),
    String? source,
    bool? success,
    Value<String?> message = const Value.absent(),
  }) => QuotaSnapshot(
    id: id ?? this.id,
    providerId: providerId ?? this.providerId,
    timestamp: timestamp ?? this.timestamp,
    kind: kind ?? this.kind,
    ratio: ratio.present ? ratio.value : this.ratio,
    remaining: remaining.present ? remaining.value : this.remaining,
    total: total.present ? total.value : this.total,
    amount: amount.present ? amount.value : this.amount,
    currency: currency.present ? currency.value : this.currency,
    resetAt: resetAt.present ? resetAt.value : this.resetAt,
    source: source ?? this.source,
    success: success ?? this.success,
    message: message.present ? message.value : this.message,
  );
  QuotaSnapshot copyWithCompanion(QuotaSnapshotsCompanion data) {
    return QuotaSnapshot(
      id: data.id.present ? data.id.value : this.id,
      providerId: data.providerId.present
          ? data.providerId.value
          : this.providerId,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      kind: data.kind.present ? data.kind.value : this.kind,
      ratio: data.ratio.present ? data.ratio.value : this.ratio,
      remaining: data.remaining.present ? data.remaining.value : this.remaining,
      total: data.total.present ? data.total.value : this.total,
      amount: data.amount.present ? data.amount.value : this.amount,
      currency: data.currency.present ? data.currency.value : this.currency,
      resetAt: data.resetAt.present ? data.resetAt.value : this.resetAt,
      source: data.source.present ? data.source.value : this.source,
      success: data.success.present ? data.success.value : this.success,
      message: data.message.present ? data.message.value : this.message,
    );
  }

  @override
  String toString() {
    return (StringBuffer('QuotaSnapshot(')
          ..write('id: $id, ')
          ..write('providerId: $providerId, ')
          ..write('timestamp: $timestamp, ')
          ..write('kind: $kind, ')
          ..write('ratio: $ratio, ')
          ..write('remaining: $remaining, ')
          ..write('total: $total, ')
          ..write('amount: $amount, ')
          ..write('currency: $currency, ')
          ..write('resetAt: $resetAt, ')
          ..write('source: $source, ')
          ..write('success: $success, ')
          ..write('message: $message')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    providerId,
    timestamp,
    kind,
    ratio,
    remaining,
    total,
    amount,
    currency,
    resetAt,
    source,
    success,
    message,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is QuotaSnapshot &&
          other.id == this.id &&
          other.providerId == this.providerId &&
          other.timestamp == this.timestamp &&
          other.kind == this.kind &&
          other.ratio == this.ratio &&
          other.remaining == this.remaining &&
          other.total == this.total &&
          other.amount == this.amount &&
          other.currency == this.currency &&
          other.resetAt == this.resetAt &&
          other.source == this.source &&
          other.success == this.success &&
          other.message == this.message);
}

class QuotaSnapshotsCompanion extends UpdateCompanion<QuotaSnapshot> {
  final Value<int> id;
  final Value<String> providerId;
  final Value<DateTime> timestamp;
  final Value<QuotaKind> kind;
  final Value<double?> ratio;
  final Value<double?> remaining;
  final Value<double?> total;
  final Value<double?> amount;
  final Value<String?> currency;
  final Value<DateTime?> resetAt;
  final Value<String> source;
  final Value<bool> success;
  final Value<String?> message;
  const QuotaSnapshotsCompanion({
    this.id = const Value.absent(),
    this.providerId = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.kind = const Value.absent(),
    this.ratio = const Value.absent(),
    this.remaining = const Value.absent(),
    this.total = const Value.absent(),
    this.amount = const Value.absent(),
    this.currency = const Value.absent(),
    this.resetAt = const Value.absent(),
    this.source = const Value.absent(),
    this.success = const Value.absent(),
    this.message = const Value.absent(),
  });
  QuotaSnapshotsCompanion.insert({
    this.id = const Value.absent(),
    required String providerId,
    required DateTime timestamp,
    required QuotaKind kind,
    this.ratio = const Value.absent(),
    this.remaining = const Value.absent(),
    this.total = const Value.absent(),
    this.amount = const Value.absent(),
    this.currency = const Value.absent(),
    this.resetAt = const Value.absent(),
    this.source = const Value.absent(),
    required bool success,
    this.message = const Value.absent(),
  }) : providerId = Value(providerId),
       timestamp = Value(timestamp),
       kind = Value(kind),
       success = Value(success);
  static Insertable<QuotaSnapshot> custom({
    Expression<int>? id,
    Expression<String>? providerId,
    Expression<DateTime>? timestamp,
    Expression<int>? kind,
    Expression<double>? ratio,
    Expression<double>? remaining,
    Expression<double>? total,
    Expression<double>? amount,
    Expression<String>? currency,
    Expression<DateTime>? resetAt,
    Expression<String>? source,
    Expression<bool>? success,
    Expression<String>? message,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (providerId != null) 'provider_id': providerId,
      if (timestamp != null) 'timestamp': timestamp,
      if (kind != null) 'kind': kind,
      if (ratio != null) 'ratio': ratio,
      if (remaining != null) 'remaining': remaining,
      if (total != null) 'total': total,
      if (amount != null) 'amount': amount,
      if (currency != null) 'currency': currency,
      if (resetAt != null) 'reset_at': resetAt,
      if (source != null) 'source': source,
      if (success != null) 'success': success,
      if (message != null) 'message': message,
    });
  }

  QuotaSnapshotsCompanion copyWith({
    Value<int>? id,
    Value<String>? providerId,
    Value<DateTime>? timestamp,
    Value<QuotaKind>? kind,
    Value<double?>? ratio,
    Value<double?>? remaining,
    Value<double?>? total,
    Value<double?>? amount,
    Value<String?>? currency,
    Value<DateTime?>? resetAt,
    Value<String>? source,
    Value<bool>? success,
    Value<String?>? message,
  }) {
    return QuotaSnapshotsCompanion(
      id: id ?? this.id,
      providerId: providerId ?? this.providerId,
      timestamp: timestamp ?? this.timestamp,
      kind: kind ?? this.kind,
      ratio: ratio ?? this.ratio,
      remaining: remaining ?? this.remaining,
      total: total ?? this.total,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      resetAt: resetAt ?? this.resetAt,
      source: source ?? this.source,
      success: success ?? this.success,
      message: message ?? this.message,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (providerId.present) {
      map['provider_id'] = Variable<String>(providerId.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    if (kind.present) {
      map['kind'] = Variable<int>(
        $QuotaSnapshotsTable.$converterkind.toSql(kind.value),
      );
    }
    if (ratio.present) {
      map['ratio'] = Variable<double>(ratio.value);
    }
    if (remaining.present) {
      map['remaining'] = Variable<double>(remaining.value);
    }
    if (total.present) {
      map['total'] = Variable<double>(total.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (resetAt.present) {
      map['reset_at'] = Variable<DateTime>(resetAt.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (success.present) {
      map['success'] = Variable<bool>(success.value);
    }
    if (message.present) {
      map['message'] = Variable<String>(message.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('QuotaSnapshotsCompanion(')
          ..write('id: $id, ')
          ..write('providerId: $providerId, ')
          ..write('timestamp: $timestamp, ')
          ..write('kind: $kind, ')
          ..write('ratio: $ratio, ')
          ..write('remaining: $remaining, ')
          ..write('total: $total, ')
          ..write('amount: $amount, ')
          ..write('currency: $currency, ')
          ..write('resetAt: $resetAt, ')
          ..write('source: $source, ')
          ..write('success: $success, ')
          ..write('message: $message')
          ..write(')'))
        .toString();
  }
}

class $ModelTestRecordsTable extends ModelTestRecords
    with TableInfo<$ModelTestRecordsTable, ModelTestRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ModelTestRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _tokenIdMeta = const VerificationMeta(
    'tokenId',
  );
  @override
  late final GeneratedColumn<String> tokenId = GeneratedColumn<String>(
    'token_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tokens (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _modelIdMeta = const VerificationMeta(
    'modelId',
  );
  @override
  late final GeneratedColumn<String> modelId = GeneratedColumn<String>(
    'model_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _successMeta = const VerificationMeta(
    'success',
  );
  @override
  late final GeneratedColumn<bool> success = GeneratedColumn<bool>(
    'success',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("success" IN (0, 1))',
    ),
  );
  static const VerificationMeta _errorTypeMeta = const VerificationMeta(
    'errorType',
  );
  @override
  late final GeneratedColumn<String> errorType = GeneratedColumn<String>(
    'error_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _httpStatusMeta = const VerificationMeta(
    'httpStatus',
  );
  @override
  late final GeneratedColumn<int> httpStatus = GeneratedColumn<int>(
    'http_status',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _latencyMsMeta = const VerificationMeta(
    'latencyMs',
  );
  @override
  late final GeneratedColumn<int> latencyMs = GeneratedColumn<int>(
    'latency_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _messageMeta = const VerificationMeta(
    'message',
  );
  @override
  late final GeneratedColumn<String> message = GeneratedColumn<String>(
    'message',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    tokenId,
    modelId,
    success,
    errorType,
    httpStatus,
    latencyMs,
    message,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'model_test_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<ModelTestRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('token_id')) {
      context.handle(
        _tokenIdMeta,
        tokenId.isAcceptableOrUnknown(data['token_id']!, _tokenIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tokenIdMeta);
    }
    if (data.containsKey('model_id')) {
      context.handle(
        _modelIdMeta,
        modelId.isAcceptableOrUnknown(data['model_id']!, _modelIdMeta),
      );
    } else if (isInserting) {
      context.missing(_modelIdMeta);
    }
    if (data.containsKey('success')) {
      context.handle(
        _successMeta,
        success.isAcceptableOrUnknown(data['success']!, _successMeta),
      );
    } else if (isInserting) {
      context.missing(_successMeta);
    }
    if (data.containsKey('error_type')) {
      context.handle(
        _errorTypeMeta,
        errorType.isAcceptableOrUnknown(data['error_type']!, _errorTypeMeta),
      );
    }
    if (data.containsKey('http_status')) {
      context.handle(
        _httpStatusMeta,
        httpStatus.isAcceptableOrUnknown(data['http_status']!, _httpStatusMeta),
      );
    }
    if (data.containsKey('latency_ms')) {
      context.handle(
        _latencyMsMeta,
        latencyMs.isAcceptableOrUnknown(data['latency_ms']!, _latencyMsMeta),
      );
    }
    if (data.containsKey('message')) {
      context.handle(
        _messageMeta,
        message.isAcceptableOrUnknown(data['message']!, _messageMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ModelTestRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ModelTestRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      tokenId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}token_id'],
      )!,
      modelId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}model_id'],
      )!,
      success: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}success'],
      )!,
      errorType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}error_type'],
      ),
      httpStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}http_status'],
      ),
      latencyMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}latency_ms'],
      ),
      message: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}message'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $ModelTestRecordsTable createAlias(String alias) {
    return $ModelTestRecordsTable(attachedDatabase, alias);
  }
}

class ModelTestRecord extends DataClass implements Insertable<ModelTestRecord> {
  final int id;
  final String tokenId;
  final String modelId;
  final bool success;

  /// 错误分类：auth/permission/notFound/insufficientBalance/rateLimited/upstream/timeout/protocol/unknown
  final String? errorType;
  final int? httpStatus;
  final int? latencyMs;
  final String? message;
  final DateTime createdAt;
  const ModelTestRecord({
    required this.id,
    required this.tokenId,
    required this.modelId,
    required this.success,
    this.errorType,
    this.httpStatus,
    this.latencyMs,
    this.message,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['token_id'] = Variable<String>(tokenId);
    map['model_id'] = Variable<String>(modelId);
    map['success'] = Variable<bool>(success);
    if (!nullToAbsent || errorType != null) {
      map['error_type'] = Variable<String>(errorType);
    }
    if (!nullToAbsent || httpStatus != null) {
      map['http_status'] = Variable<int>(httpStatus);
    }
    if (!nullToAbsent || latencyMs != null) {
      map['latency_ms'] = Variable<int>(latencyMs);
    }
    if (!nullToAbsent || message != null) {
      map['message'] = Variable<String>(message);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ModelTestRecordsCompanion toCompanion(bool nullToAbsent) {
    return ModelTestRecordsCompanion(
      id: Value(id),
      tokenId: Value(tokenId),
      modelId: Value(modelId),
      success: Value(success),
      errorType: errorType == null && nullToAbsent
          ? const Value.absent()
          : Value(errorType),
      httpStatus: httpStatus == null && nullToAbsent
          ? const Value.absent()
          : Value(httpStatus),
      latencyMs: latencyMs == null && nullToAbsent
          ? const Value.absent()
          : Value(latencyMs),
      message: message == null && nullToAbsent
          ? const Value.absent()
          : Value(message),
      createdAt: Value(createdAt),
    );
  }

  factory ModelTestRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ModelTestRecord(
      id: serializer.fromJson<int>(json['id']),
      tokenId: serializer.fromJson<String>(json['tokenId']),
      modelId: serializer.fromJson<String>(json['modelId']),
      success: serializer.fromJson<bool>(json['success']),
      errorType: serializer.fromJson<String?>(json['errorType']),
      httpStatus: serializer.fromJson<int?>(json['httpStatus']),
      latencyMs: serializer.fromJson<int?>(json['latencyMs']),
      message: serializer.fromJson<String?>(json['message']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'tokenId': serializer.toJson<String>(tokenId),
      'modelId': serializer.toJson<String>(modelId),
      'success': serializer.toJson<bool>(success),
      'errorType': serializer.toJson<String?>(errorType),
      'httpStatus': serializer.toJson<int?>(httpStatus),
      'latencyMs': serializer.toJson<int?>(latencyMs),
      'message': serializer.toJson<String?>(message),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  ModelTestRecord copyWith({
    int? id,
    String? tokenId,
    String? modelId,
    bool? success,
    Value<String?> errorType = const Value.absent(),
    Value<int?> httpStatus = const Value.absent(),
    Value<int?> latencyMs = const Value.absent(),
    Value<String?> message = const Value.absent(),
    DateTime? createdAt,
  }) => ModelTestRecord(
    id: id ?? this.id,
    tokenId: tokenId ?? this.tokenId,
    modelId: modelId ?? this.modelId,
    success: success ?? this.success,
    errorType: errorType.present ? errorType.value : this.errorType,
    httpStatus: httpStatus.present ? httpStatus.value : this.httpStatus,
    latencyMs: latencyMs.present ? latencyMs.value : this.latencyMs,
    message: message.present ? message.value : this.message,
    createdAt: createdAt ?? this.createdAt,
  );
  ModelTestRecord copyWithCompanion(ModelTestRecordsCompanion data) {
    return ModelTestRecord(
      id: data.id.present ? data.id.value : this.id,
      tokenId: data.tokenId.present ? data.tokenId.value : this.tokenId,
      modelId: data.modelId.present ? data.modelId.value : this.modelId,
      success: data.success.present ? data.success.value : this.success,
      errorType: data.errorType.present ? data.errorType.value : this.errorType,
      httpStatus: data.httpStatus.present
          ? data.httpStatus.value
          : this.httpStatus,
      latencyMs: data.latencyMs.present ? data.latencyMs.value : this.latencyMs,
      message: data.message.present ? data.message.value : this.message,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ModelTestRecord(')
          ..write('id: $id, ')
          ..write('tokenId: $tokenId, ')
          ..write('modelId: $modelId, ')
          ..write('success: $success, ')
          ..write('errorType: $errorType, ')
          ..write('httpStatus: $httpStatus, ')
          ..write('latencyMs: $latencyMs, ')
          ..write('message: $message, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    tokenId,
    modelId,
    success,
    errorType,
    httpStatus,
    latencyMs,
    message,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ModelTestRecord &&
          other.id == this.id &&
          other.tokenId == this.tokenId &&
          other.modelId == this.modelId &&
          other.success == this.success &&
          other.errorType == this.errorType &&
          other.httpStatus == this.httpStatus &&
          other.latencyMs == this.latencyMs &&
          other.message == this.message &&
          other.createdAt == this.createdAt);
}

class ModelTestRecordsCompanion extends UpdateCompanion<ModelTestRecord> {
  final Value<int> id;
  final Value<String> tokenId;
  final Value<String> modelId;
  final Value<bool> success;
  final Value<String?> errorType;
  final Value<int?> httpStatus;
  final Value<int?> latencyMs;
  final Value<String?> message;
  final Value<DateTime> createdAt;
  const ModelTestRecordsCompanion({
    this.id = const Value.absent(),
    this.tokenId = const Value.absent(),
    this.modelId = const Value.absent(),
    this.success = const Value.absent(),
    this.errorType = const Value.absent(),
    this.httpStatus = const Value.absent(),
    this.latencyMs = const Value.absent(),
    this.message = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  ModelTestRecordsCompanion.insert({
    this.id = const Value.absent(),
    required String tokenId,
    required String modelId,
    required bool success,
    this.errorType = const Value.absent(),
    this.httpStatus = const Value.absent(),
    this.latencyMs = const Value.absent(),
    this.message = const Value.absent(),
    required DateTime createdAt,
  }) : tokenId = Value(tokenId),
       modelId = Value(modelId),
       success = Value(success),
       createdAt = Value(createdAt);
  static Insertable<ModelTestRecord> custom({
    Expression<int>? id,
    Expression<String>? tokenId,
    Expression<String>? modelId,
    Expression<bool>? success,
    Expression<String>? errorType,
    Expression<int>? httpStatus,
    Expression<int>? latencyMs,
    Expression<String>? message,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tokenId != null) 'token_id': tokenId,
      if (modelId != null) 'model_id': modelId,
      if (success != null) 'success': success,
      if (errorType != null) 'error_type': errorType,
      if (httpStatus != null) 'http_status': httpStatus,
      if (latencyMs != null) 'latency_ms': latencyMs,
      if (message != null) 'message': message,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  ModelTestRecordsCompanion copyWith({
    Value<int>? id,
    Value<String>? tokenId,
    Value<String>? modelId,
    Value<bool>? success,
    Value<String?>? errorType,
    Value<int?>? httpStatus,
    Value<int?>? latencyMs,
    Value<String?>? message,
    Value<DateTime>? createdAt,
  }) {
    return ModelTestRecordsCompanion(
      id: id ?? this.id,
      tokenId: tokenId ?? this.tokenId,
      modelId: modelId ?? this.modelId,
      success: success ?? this.success,
      errorType: errorType ?? this.errorType,
      httpStatus: httpStatus ?? this.httpStatus,
      latencyMs: latencyMs ?? this.latencyMs,
      message: message ?? this.message,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (tokenId.present) {
      map['token_id'] = Variable<String>(tokenId.value);
    }
    if (modelId.present) {
      map['model_id'] = Variable<String>(modelId.value);
    }
    if (success.present) {
      map['success'] = Variable<bool>(success.value);
    }
    if (errorType.present) {
      map['error_type'] = Variable<String>(errorType.value);
    }
    if (httpStatus.present) {
      map['http_status'] = Variable<int>(httpStatus.value);
    }
    if (latencyMs.present) {
      map['latency_ms'] = Variable<int>(latencyMs.value);
    }
    if (message.present) {
      map['message'] = Variable<String>(message.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ModelTestRecordsCompanion(')
          ..write('id: $id, ')
          ..write('tokenId: $tokenId, ')
          ..write('modelId: $modelId, ')
          ..write('success: $success, ')
          ..write('errorType: $errorType, ')
          ..write('httpStatus: $httpStatus, ')
          ..write('latencyMs: $latencyMs, ')
          ..write('message: $message, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $CheckinRecordsTable extends CheckinRecords
    with TableInfo<$CheckinRecordsTable, CheckinRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CheckinRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _providerIdMeta = const VerificationMeta(
    'providerId',
  );
  @override
  late final GeneratedColumn<String> providerId = GeneratedColumn<String>(
    'provider_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES providers (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _successMeta = const VerificationMeta(
    'success',
  );
  @override
  late final GeneratedColumn<bool> success = GeneratedColumn<bool>(
    'success',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("success" IN (0, 1))',
    ),
  );
  static const VerificationMeta _messageMeta = const VerificationMeta(
    'message',
  );
  @override
  late final GeneratedColumn<String> message = GeneratedColumn<String>(
    'message',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    providerId,
    success,
    message,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'checkin_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<CheckinRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('provider_id')) {
      context.handle(
        _providerIdMeta,
        providerId.isAcceptableOrUnknown(data['provider_id']!, _providerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_providerIdMeta);
    }
    if (data.containsKey('success')) {
      context.handle(
        _successMeta,
        success.isAcceptableOrUnknown(data['success']!, _successMeta),
      );
    } else if (isInserting) {
      context.missing(_successMeta);
    }
    if (data.containsKey('message')) {
      context.handle(
        _messageMeta,
        message.isAcceptableOrUnknown(data['message']!, _messageMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CheckinRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CheckinRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      providerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}provider_id'],
      )!,
      success: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}success'],
      )!,
      message: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}message'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $CheckinRecordsTable createAlias(String alias) {
    return $CheckinRecordsTable(attachedDatabase, alias);
  }
}

class CheckinRecord extends DataClass implements Insertable<CheckinRecord> {
  final int id;
  final String providerId;
  final bool success;
  final String? message;
  final DateTime createdAt;
  const CheckinRecord({
    required this.id,
    required this.providerId,
    required this.success,
    this.message,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['provider_id'] = Variable<String>(providerId);
    map['success'] = Variable<bool>(success);
    if (!nullToAbsent || message != null) {
      map['message'] = Variable<String>(message);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  CheckinRecordsCompanion toCompanion(bool nullToAbsent) {
    return CheckinRecordsCompanion(
      id: Value(id),
      providerId: Value(providerId),
      success: Value(success),
      message: message == null && nullToAbsent
          ? const Value.absent()
          : Value(message),
      createdAt: Value(createdAt),
    );
  }

  factory CheckinRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CheckinRecord(
      id: serializer.fromJson<int>(json['id']),
      providerId: serializer.fromJson<String>(json['providerId']),
      success: serializer.fromJson<bool>(json['success']),
      message: serializer.fromJson<String?>(json['message']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'providerId': serializer.toJson<String>(providerId),
      'success': serializer.toJson<bool>(success),
      'message': serializer.toJson<String?>(message),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  CheckinRecord copyWith({
    int? id,
    String? providerId,
    bool? success,
    Value<String?> message = const Value.absent(),
    DateTime? createdAt,
  }) => CheckinRecord(
    id: id ?? this.id,
    providerId: providerId ?? this.providerId,
    success: success ?? this.success,
    message: message.present ? message.value : this.message,
    createdAt: createdAt ?? this.createdAt,
  );
  CheckinRecord copyWithCompanion(CheckinRecordsCompanion data) {
    return CheckinRecord(
      id: data.id.present ? data.id.value : this.id,
      providerId: data.providerId.present
          ? data.providerId.value
          : this.providerId,
      success: data.success.present ? data.success.value : this.success,
      message: data.message.present ? data.message.value : this.message,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CheckinRecord(')
          ..write('id: $id, ')
          ..write('providerId: $providerId, ')
          ..write('success: $success, ')
          ..write('message: $message, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, providerId, success, message, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CheckinRecord &&
          other.id == this.id &&
          other.providerId == this.providerId &&
          other.success == this.success &&
          other.message == this.message &&
          other.createdAt == this.createdAt);
}

class CheckinRecordsCompanion extends UpdateCompanion<CheckinRecord> {
  final Value<int> id;
  final Value<String> providerId;
  final Value<bool> success;
  final Value<String?> message;
  final Value<DateTime> createdAt;
  const CheckinRecordsCompanion({
    this.id = const Value.absent(),
    this.providerId = const Value.absent(),
    this.success = const Value.absent(),
    this.message = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  CheckinRecordsCompanion.insert({
    this.id = const Value.absent(),
    required String providerId,
    required bool success,
    this.message = const Value.absent(),
    required DateTime createdAt,
  }) : providerId = Value(providerId),
       success = Value(success),
       createdAt = Value(createdAt);
  static Insertable<CheckinRecord> custom({
    Expression<int>? id,
    Expression<String>? providerId,
    Expression<bool>? success,
    Expression<String>? message,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (providerId != null) 'provider_id': providerId,
      if (success != null) 'success': success,
      if (message != null) 'message': message,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  CheckinRecordsCompanion copyWith({
    Value<int>? id,
    Value<String>? providerId,
    Value<bool>? success,
    Value<String?>? message,
    Value<DateTime>? createdAt,
  }) {
    return CheckinRecordsCompanion(
      id: id ?? this.id,
      providerId: providerId ?? this.providerId,
      success: success ?? this.success,
      message: message ?? this.message,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (providerId.present) {
      map['provider_id'] = Variable<String>(providerId.value);
    }
    if (success.present) {
      map['success'] = Variable<bool>(success.value);
    }
    if (message.present) {
      map['message'] = Variable<String>(message.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CheckinRecordsCompanion(')
          ..write('id: $id, ')
          ..write('providerId: $providerId, ')
          ..write('success: $success, ')
          ..write('message: $message, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $PrewarmRecordsTable extends PrewarmRecords
    with TableInfo<$PrewarmRecordsTable, PrewarmRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PrewarmRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _providerIdMeta = const VerificationMeta(
    'providerId',
  );
  @override
  late final GeneratedColumn<String> providerId = GeneratedColumn<String>(
    'provider_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES providers (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _messageMeta = const VerificationMeta(
    'message',
  );
  @override
  late final GeneratedColumn<String> message = GeneratedColumn<String>(
    'message',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    providerId,
    status,
    message,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'prewarm_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<PrewarmRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('provider_id')) {
      context.handle(
        _providerIdMeta,
        providerId.isAcceptableOrUnknown(data['provider_id']!, _providerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_providerIdMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('message')) {
      context.handle(
        _messageMeta,
        message.isAcceptableOrUnknown(data['message']!, _messageMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PrewarmRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PrewarmRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      providerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}provider_id'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      message: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}message'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $PrewarmRecordsTable createAlias(String alias) {
    return $PrewarmRecordsTable(attachedDatabase, alias);
  }
}

class PrewarmRecord extends DataClass implements Insertable<PrewarmRecord> {
  final int id;
  final String providerId;

  /// executed / skipped / failed
  final String status;
  final String? message;
  final DateTime createdAt;
  const PrewarmRecord({
    required this.id,
    required this.providerId,
    required this.status,
    this.message,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['provider_id'] = Variable<String>(providerId);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || message != null) {
      map['message'] = Variable<String>(message);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  PrewarmRecordsCompanion toCompanion(bool nullToAbsent) {
    return PrewarmRecordsCompanion(
      id: Value(id),
      providerId: Value(providerId),
      status: Value(status),
      message: message == null && nullToAbsent
          ? const Value.absent()
          : Value(message),
      createdAt: Value(createdAt),
    );
  }

  factory PrewarmRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PrewarmRecord(
      id: serializer.fromJson<int>(json['id']),
      providerId: serializer.fromJson<String>(json['providerId']),
      status: serializer.fromJson<String>(json['status']),
      message: serializer.fromJson<String?>(json['message']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'providerId': serializer.toJson<String>(providerId),
      'status': serializer.toJson<String>(status),
      'message': serializer.toJson<String?>(message),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  PrewarmRecord copyWith({
    int? id,
    String? providerId,
    String? status,
    Value<String?> message = const Value.absent(),
    DateTime? createdAt,
  }) => PrewarmRecord(
    id: id ?? this.id,
    providerId: providerId ?? this.providerId,
    status: status ?? this.status,
    message: message.present ? message.value : this.message,
    createdAt: createdAt ?? this.createdAt,
  );
  PrewarmRecord copyWithCompanion(PrewarmRecordsCompanion data) {
    return PrewarmRecord(
      id: data.id.present ? data.id.value : this.id,
      providerId: data.providerId.present
          ? data.providerId.value
          : this.providerId,
      status: data.status.present ? data.status.value : this.status,
      message: data.message.present ? data.message.value : this.message,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PrewarmRecord(')
          ..write('id: $id, ')
          ..write('providerId: $providerId, ')
          ..write('status: $status, ')
          ..write('message: $message, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, providerId, status, message, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PrewarmRecord &&
          other.id == this.id &&
          other.providerId == this.providerId &&
          other.status == this.status &&
          other.message == this.message &&
          other.createdAt == this.createdAt);
}

class PrewarmRecordsCompanion extends UpdateCompanion<PrewarmRecord> {
  final Value<int> id;
  final Value<String> providerId;
  final Value<String> status;
  final Value<String?> message;
  final Value<DateTime> createdAt;
  const PrewarmRecordsCompanion({
    this.id = const Value.absent(),
    this.providerId = const Value.absent(),
    this.status = const Value.absent(),
    this.message = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  PrewarmRecordsCompanion.insert({
    this.id = const Value.absent(),
    required String providerId,
    required String status,
    this.message = const Value.absent(),
    required DateTime createdAt,
  }) : providerId = Value(providerId),
       status = Value(status),
       createdAt = Value(createdAt);
  static Insertable<PrewarmRecord> custom({
    Expression<int>? id,
    Expression<String>? providerId,
    Expression<String>? status,
    Expression<String>? message,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (providerId != null) 'provider_id': providerId,
      if (status != null) 'status': status,
      if (message != null) 'message': message,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  PrewarmRecordsCompanion copyWith({
    Value<int>? id,
    Value<String>? providerId,
    Value<String>? status,
    Value<String?>? message,
    Value<DateTime>? createdAt,
  }) {
    return PrewarmRecordsCompanion(
      id: id ?? this.id,
      providerId: providerId ?? this.providerId,
      status: status ?? this.status,
      message: message ?? this.message,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (providerId.present) {
      map['provider_id'] = Variable<String>(providerId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (message.present) {
      map['message'] = Variable<String>(message.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PrewarmRecordsCompanion(')
          ..write('id: $id, ')
          ..write('providerId: $providerId, ')
          ..write('status: $status, ')
          ..write('message: $message, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $WebdavConfigsTable extends WebdavConfigs
    with TableInfo<$WebdavConfigsTable, WebdavConfig> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WebdavConfigsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
    'url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _usernameMeta = const VerificationMeta(
    'username',
  );
  @override
  late final GeneratedColumn<String> username = GeneratedColumn<String>(
    'username',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _passwordRefMeta = const VerificationMeta(
    'passwordRef',
  );
  @override
  late final GeneratedColumn<String> passwordRef = GeneratedColumn<String>(
    'password_ref',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _remotePathMeta = const VerificationMeta(
    'remotePath',
  );
  @override
  late final GeneratedColumn<String> remotePath = GeneratedColumn<String>(
    'remote_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('/aivault'),
  );
  static const VerificationMeta _includeSecretsMeta = const VerificationMeta(
    'includeSecrets',
  );
  @override
  late final GeneratedColumn<bool> includeSecrets = GeneratedColumn<bool>(
    'include_secrets',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("include_secrets" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastSyncedAtMeta = const VerificationMeta(
    'lastSyncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
    'last_synced_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    url,
    username,
    passwordRef,
    remotePath,
    includeSecrets,
    deviceId,
    lastSyncedAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'webdav_configs';
  @override
  VerificationContext validateIntegrity(
    Insertable<WebdavConfig> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('url')) {
      context.handle(
        _urlMeta,
        url.isAcceptableOrUnknown(data['url']!, _urlMeta),
      );
    } else if (isInserting) {
      context.missing(_urlMeta);
    }
    if (data.containsKey('username')) {
      context.handle(
        _usernameMeta,
        username.isAcceptableOrUnknown(data['username']!, _usernameMeta),
      );
    } else if (isInserting) {
      context.missing(_usernameMeta);
    }
    if (data.containsKey('password_ref')) {
      context.handle(
        _passwordRefMeta,
        passwordRef.isAcceptableOrUnknown(
          data['password_ref']!,
          _passwordRefMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_passwordRefMeta);
    }
    if (data.containsKey('remote_path')) {
      context.handle(
        _remotePathMeta,
        remotePath.isAcceptableOrUnknown(data['remote_path']!, _remotePathMeta),
      );
    }
    if (data.containsKey('include_secrets')) {
      context.handle(
        _includeSecretsMeta,
        includeSecrets.isAcceptableOrUnknown(
          data['include_secrets']!,
          _includeSecretsMeta,
        ),
      );
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
        _lastSyncedAtMeta,
        lastSyncedAt.isAcceptableOrUnknown(
          data['last_synced_at']!,
          _lastSyncedAtMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WebdavConfig map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WebdavConfig(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      url: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}url'],
      )!,
      username: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}username'],
      )!,
      passwordRef: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}password_ref'],
      )!,
      remotePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remote_path'],
      )!,
      includeSecrets: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}include_secrets'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      lastSyncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_synced_at'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $WebdavConfigsTable createAlias(String alias) {
    return $WebdavConfigsTable(attachedDatabase, alias);
  }
}

class WebdavConfig extends DataClass implements Insertable<WebdavConfig> {
  final int id;
  final String url;
  final String username;

  /// WebDAV 密码在 Secure Storage 中的引用 key
  final String passwordRef;
  final String remotePath;

  /// 同步是否包含 API Key 等密钥（敏感信息单独控制，Plan #50）
  final bool includeSecrets;

  /// 本设备标识（用于同步元数据展示）
  final String deviceId;

  /// 上次成功同步时间
  final DateTime? lastSyncedAt;
  final DateTime updatedAt;
  const WebdavConfig({
    required this.id,
    required this.url,
    required this.username,
    required this.passwordRef,
    required this.remotePath,
    required this.includeSecrets,
    required this.deviceId,
    this.lastSyncedAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['url'] = Variable<String>(url);
    map['username'] = Variable<String>(username);
    map['password_ref'] = Variable<String>(passwordRef);
    map['remote_path'] = Variable<String>(remotePath);
    map['include_secrets'] = Variable<bool>(includeSecrets);
    map['device_id'] = Variable<String>(deviceId);
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  WebdavConfigsCompanion toCompanion(bool nullToAbsent) {
    return WebdavConfigsCompanion(
      id: Value(id),
      url: Value(url),
      username: Value(username),
      passwordRef: Value(passwordRef),
      remotePath: Value(remotePath),
      includeSecrets: Value(includeSecrets),
      deviceId: Value(deviceId),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory WebdavConfig.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WebdavConfig(
      id: serializer.fromJson<int>(json['id']),
      url: serializer.fromJson<String>(json['url']),
      username: serializer.fromJson<String>(json['username']),
      passwordRef: serializer.fromJson<String>(json['passwordRef']),
      remotePath: serializer.fromJson<String>(json['remotePath']),
      includeSecrets: serializer.fromJson<bool>(json['includeSecrets']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      lastSyncedAt: serializer.fromJson<DateTime?>(json['lastSyncedAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'url': serializer.toJson<String>(url),
      'username': serializer.toJson<String>(username),
      'passwordRef': serializer.toJson<String>(passwordRef),
      'remotePath': serializer.toJson<String>(remotePath),
      'includeSecrets': serializer.toJson<bool>(includeSecrets),
      'deviceId': serializer.toJson<String>(deviceId),
      'lastSyncedAt': serializer.toJson<DateTime?>(lastSyncedAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  WebdavConfig copyWith({
    int? id,
    String? url,
    String? username,
    String? passwordRef,
    String? remotePath,
    bool? includeSecrets,
    String? deviceId,
    Value<DateTime?> lastSyncedAt = const Value.absent(),
    DateTime? updatedAt,
  }) => WebdavConfig(
    id: id ?? this.id,
    url: url ?? this.url,
    username: username ?? this.username,
    passwordRef: passwordRef ?? this.passwordRef,
    remotePath: remotePath ?? this.remotePath,
    includeSecrets: includeSecrets ?? this.includeSecrets,
    deviceId: deviceId ?? this.deviceId,
    lastSyncedAt: lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  WebdavConfig copyWithCompanion(WebdavConfigsCompanion data) {
    return WebdavConfig(
      id: data.id.present ? data.id.value : this.id,
      url: data.url.present ? data.url.value : this.url,
      username: data.username.present ? data.username.value : this.username,
      passwordRef: data.passwordRef.present
          ? data.passwordRef.value
          : this.passwordRef,
      remotePath: data.remotePath.present
          ? data.remotePath.value
          : this.remotePath,
      includeSecrets: data.includeSecrets.present
          ? data.includeSecrets.value
          : this.includeSecrets,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WebdavConfig(')
          ..write('id: $id, ')
          ..write('url: $url, ')
          ..write('username: $username, ')
          ..write('passwordRef: $passwordRef, ')
          ..write('remotePath: $remotePath, ')
          ..write('includeSecrets: $includeSecrets, ')
          ..write('deviceId: $deviceId, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    url,
    username,
    passwordRef,
    remotePath,
    includeSecrets,
    deviceId,
    lastSyncedAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WebdavConfig &&
          other.id == this.id &&
          other.url == this.url &&
          other.username == this.username &&
          other.passwordRef == this.passwordRef &&
          other.remotePath == this.remotePath &&
          other.includeSecrets == this.includeSecrets &&
          other.deviceId == this.deviceId &&
          other.lastSyncedAt == this.lastSyncedAt &&
          other.updatedAt == this.updatedAt);
}

class WebdavConfigsCompanion extends UpdateCompanion<WebdavConfig> {
  final Value<int> id;
  final Value<String> url;
  final Value<String> username;
  final Value<String> passwordRef;
  final Value<String> remotePath;
  final Value<bool> includeSecrets;
  final Value<String> deviceId;
  final Value<DateTime?> lastSyncedAt;
  final Value<DateTime> updatedAt;
  const WebdavConfigsCompanion({
    this.id = const Value.absent(),
    this.url = const Value.absent(),
    this.username = const Value.absent(),
    this.passwordRef = const Value.absent(),
    this.remotePath = const Value.absent(),
    this.includeSecrets = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  WebdavConfigsCompanion.insert({
    this.id = const Value.absent(),
    required String url,
    required String username,
    required String passwordRef,
    this.remotePath = const Value.absent(),
    this.includeSecrets = const Value.absent(),
    required String deviceId,
    this.lastSyncedAt = const Value.absent(),
    required DateTime updatedAt,
  }) : url = Value(url),
       username = Value(username),
       passwordRef = Value(passwordRef),
       deviceId = Value(deviceId),
       updatedAt = Value(updatedAt);
  static Insertable<WebdavConfig> custom({
    Expression<int>? id,
    Expression<String>? url,
    Expression<String>? username,
    Expression<String>? passwordRef,
    Expression<String>? remotePath,
    Expression<bool>? includeSecrets,
    Expression<String>? deviceId,
    Expression<DateTime>? lastSyncedAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (url != null) 'url': url,
      if (username != null) 'username': username,
      if (passwordRef != null) 'password_ref': passwordRef,
      if (remotePath != null) 'remote_path': remotePath,
      if (includeSecrets != null) 'include_secrets': includeSecrets,
      if (deviceId != null) 'device_id': deviceId,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  WebdavConfigsCompanion copyWith({
    Value<int>? id,
    Value<String>? url,
    Value<String>? username,
    Value<String>? passwordRef,
    Value<String>? remotePath,
    Value<bool>? includeSecrets,
    Value<String>? deviceId,
    Value<DateTime?>? lastSyncedAt,
    Value<DateTime>? updatedAt,
  }) {
    return WebdavConfigsCompanion(
      id: id ?? this.id,
      url: url ?? this.url,
      username: username ?? this.username,
      passwordRef: passwordRef ?? this.passwordRef,
      remotePath: remotePath ?? this.remotePath,
      includeSecrets: includeSecrets ?? this.includeSecrets,
      deviceId: deviceId ?? this.deviceId,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (username.present) {
      map['username'] = Variable<String>(username.value);
    }
    if (passwordRef.present) {
      map['password_ref'] = Variable<String>(passwordRef.value);
    }
    if (remotePath.present) {
      map['remote_path'] = Variable<String>(remotePath.value);
    }
    if (includeSecrets.present) {
      map['include_secrets'] = Variable<bool>(includeSecrets.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WebdavConfigsCompanion(')
          ..write('id: $id, ')
          ..write('url: $url, ')
          ..write('username: $username, ')
          ..write('passwordRef: $passwordRef, ')
          ..write('remotePath: $remotePath, ')
          ..write('includeSecrets: $includeSecrets, ')
          ..write('deviceId: $deviceId, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $ConversationsTable extends Conversations
    with TableInfo<$ConversationsTable, Conversation> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ConversationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('新会话'),
  );
  static const VerificationMeta _providerIdMeta = const VerificationMeta(
    'providerId',
  );
  @override
  late final GeneratedColumn<String> providerId = GeneratedColumn<String>(
    'provider_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES providers (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _tokenIdMeta = const VerificationMeta(
    'tokenId',
  );
  @override
  late final GeneratedColumn<String> tokenId = GeneratedColumn<String>(
    'token_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tokens (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _modelMeta = const VerificationMeta('model');
  @override
  late final GeneratedColumn<String> model = GeneratedColumn<String>(
    'model',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    providerId,
    tokenId,
    model,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'conversations';
  @override
  VerificationContext validateIntegrity(
    Insertable<Conversation> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    }
    if (data.containsKey('provider_id')) {
      context.handle(
        _providerIdMeta,
        providerId.isAcceptableOrUnknown(data['provider_id']!, _providerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_providerIdMeta);
    }
    if (data.containsKey('token_id')) {
      context.handle(
        _tokenIdMeta,
        tokenId.isAcceptableOrUnknown(data['token_id']!, _tokenIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tokenIdMeta);
    }
    if (data.containsKey('model')) {
      context.handle(
        _modelMeta,
        model.isAcceptableOrUnknown(data['model']!, _modelMeta),
      );
    } else if (isInserting) {
      context.missing(_modelMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Conversation map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Conversation(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      providerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}provider_id'],
      )!,
      tokenId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}token_id'],
      )!,
      model: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}model'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $ConversationsTable createAlias(String alias) {
    return $ConversationsTable(attachedDatabase, alias);
  }
}

class Conversation extends DataClass implements Insertable<Conversation> {
  final String id;
  final String title;

  /// 会话使用的供应商 / 令牌 / 模型（模型可切换，随会话保存）
  final String providerId;
  final String tokenId;
  final String model;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Conversation({
    required this.id,
    required this.title,
    required this.providerId,
    required this.tokenId,
    required this.model,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['provider_id'] = Variable<String>(providerId);
    map['token_id'] = Variable<String>(tokenId);
    map['model'] = Variable<String>(model);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ConversationsCompanion toCompanion(bool nullToAbsent) {
    return ConversationsCompanion(
      id: Value(id),
      title: Value(title),
      providerId: Value(providerId),
      tokenId: Value(tokenId),
      model: Value(model),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Conversation.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Conversation(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      providerId: serializer.fromJson<String>(json['providerId']),
      tokenId: serializer.fromJson<String>(json['tokenId']),
      model: serializer.fromJson<String>(json['model']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'providerId': serializer.toJson<String>(providerId),
      'tokenId': serializer.toJson<String>(tokenId),
      'model': serializer.toJson<String>(model),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Conversation copyWith({
    String? id,
    String? title,
    String? providerId,
    String? tokenId,
    String? model,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Conversation(
    id: id ?? this.id,
    title: title ?? this.title,
    providerId: providerId ?? this.providerId,
    tokenId: tokenId ?? this.tokenId,
    model: model ?? this.model,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Conversation copyWithCompanion(ConversationsCompanion data) {
    return Conversation(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      providerId: data.providerId.present
          ? data.providerId.value
          : this.providerId,
      tokenId: data.tokenId.present ? data.tokenId.value : this.tokenId,
      model: data.model.present ? data.model.value : this.model,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Conversation(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('providerId: $providerId, ')
          ..write('tokenId: $tokenId, ')
          ..write('model: $model, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, title, providerId, tokenId, model, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Conversation &&
          other.id == this.id &&
          other.title == this.title &&
          other.providerId == this.providerId &&
          other.tokenId == this.tokenId &&
          other.model == this.model &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ConversationsCompanion extends UpdateCompanion<Conversation> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> providerId;
  final Value<String> tokenId;
  final Value<String> model;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const ConversationsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.providerId = const Value.absent(),
    this.tokenId = const Value.absent(),
    this.model = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ConversationsCompanion.insert({
    required String id,
    this.title = const Value.absent(),
    required String providerId,
    required String tokenId,
    required String model,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       providerId = Value(providerId),
       tokenId = Value(tokenId),
       model = Value(model),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Conversation> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? providerId,
    Expression<String>? tokenId,
    Expression<String>? model,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (providerId != null) 'provider_id': providerId,
      if (tokenId != null) 'token_id': tokenId,
      if (model != null) 'model': model,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ConversationsCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String>? providerId,
    Value<String>? tokenId,
    Value<String>? model,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return ConversationsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      providerId: providerId ?? this.providerId,
      tokenId: tokenId ?? this.tokenId,
      model: model ?? this.model,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (providerId.present) {
      map['provider_id'] = Variable<String>(providerId.value);
    }
    if (tokenId.present) {
      map['token_id'] = Variable<String>(tokenId.value);
    }
    if (model.present) {
      map['model'] = Variable<String>(model.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ConversationsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('providerId: $providerId, ')
          ..write('tokenId: $tokenId, ')
          ..write('model: $model, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MessagesTable extends Messages with TableInfo<$MessagesTable, Message> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MessagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _conversationIdMeta = const VerificationMeta(
    'conversationId',
  );
  @override
  late final GeneratedColumn<String> conversationId = GeneratedColumn<String>(
    'conversation_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES conversations (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _metadataMeta = const VerificationMeta(
    'metadata',
  );
  @override
  late final GeneratedColumn<String> metadata = GeneratedColumn<String>(
    'metadata',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    conversationId,
    role,
    content,
    createdAt,
    metadata,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'messages';
  @override
  VerificationContext validateIntegrity(
    Insertable<Message> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('conversation_id')) {
      context.handle(
        _conversationIdMeta,
        conversationId.isAcceptableOrUnknown(
          data['conversation_id']!,
          _conversationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_conversationIdMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('metadata')) {
      context.handle(
        _metadataMeta,
        metadata.isAcceptableOrUnknown(data['metadata']!, _metadataMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Message map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Message(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      conversationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}conversation_id'],
      )!,
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      metadata: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}metadata'],
      ),
    );
  }

  @override
  $MessagesTable createAlias(String alias) {
    return $MessagesTable(attachedDatabase, alias);
  }
}

class Message extends DataClass implements Insertable<Message> {
  final String id;
  final String conversationId;

  /// user / assistant
  final String role;
  final String content;
  final DateTime createdAt;

  /// JSON：错误信息、模型、耗时等
  final String? metadata;
  const Message({
    required this.id,
    required this.conversationId,
    required this.role,
    required this.content,
    required this.createdAt,
    this.metadata,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['conversation_id'] = Variable<String>(conversationId);
    map['role'] = Variable<String>(role);
    map['content'] = Variable<String>(content);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || metadata != null) {
      map['metadata'] = Variable<String>(metadata);
    }
    return map;
  }

  MessagesCompanion toCompanion(bool nullToAbsent) {
    return MessagesCompanion(
      id: Value(id),
      conversationId: Value(conversationId),
      role: Value(role),
      content: Value(content),
      createdAt: Value(createdAt),
      metadata: metadata == null && nullToAbsent
          ? const Value.absent()
          : Value(metadata),
    );
  }

  factory Message.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Message(
      id: serializer.fromJson<String>(json['id']),
      conversationId: serializer.fromJson<String>(json['conversationId']),
      role: serializer.fromJson<String>(json['role']),
      content: serializer.fromJson<String>(json['content']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      metadata: serializer.fromJson<String?>(json['metadata']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'conversationId': serializer.toJson<String>(conversationId),
      'role': serializer.toJson<String>(role),
      'content': serializer.toJson<String>(content),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'metadata': serializer.toJson<String?>(metadata),
    };
  }

  Message copyWith({
    String? id,
    String? conversationId,
    String? role,
    String? content,
    DateTime? createdAt,
    Value<String?> metadata = const Value.absent(),
  }) => Message(
    id: id ?? this.id,
    conversationId: conversationId ?? this.conversationId,
    role: role ?? this.role,
    content: content ?? this.content,
    createdAt: createdAt ?? this.createdAt,
    metadata: metadata.present ? metadata.value : this.metadata,
  );
  Message copyWithCompanion(MessagesCompanion data) {
    return Message(
      id: data.id.present ? data.id.value : this.id,
      conversationId: data.conversationId.present
          ? data.conversationId.value
          : this.conversationId,
      role: data.role.present ? data.role.value : this.role,
      content: data.content.present ? data.content.value : this.content,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      metadata: data.metadata.present ? data.metadata.value : this.metadata,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Message(')
          ..write('id: $id, ')
          ..write('conversationId: $conversationId, ')
          ..write('role: $role, ')
          ..write('content: $content, ')
          ..write('createdAt: $createdAt, ')
          ..write('metadata: $metadata')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, conversationId, role, content, createdAt, metadata);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Message &&
          other.id == this.id &&
          other.conversationId == this.conversationId &&
          other.role == this.role &&
          other.content == this.content &&
          other.createdAt == this.createdAt &&
          other.metadata == this.metadata);
}

class MessagesCompanion extends UpdateCompanion<Message> {
  final Value<String> id;
  final Value<String> conversationId;
  final Value<String> role;
  final Value<String> content;
  final Value<DateTime> createdAt;
  final Value<String?> metadata;
  final Value<int> rowid;
  const MessagesCompanion({
    this.id = const Value.absent(),
    this.conversationId = const Value.absent(),
    this.role = const Value.absent(),
    this.content = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.metadata = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MessagesCompanion.insert({
    required String id,
    required String conversationId,
    required String role,
    required String content,
    required DateTime createdAt,
    this.metadata = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       conversationId = Value(conversationId),
       role = Value(role),
       content = Value(content),
       createdAt = Value(createdAt);
  static Insertable<Message> custom({
    Expression<String>? id,
    Expression<String>? conversationId,
    Expression<String>? role,
    Expression<String>? content,
    Expression<DateTime>? createdAt,
    Expression<String>? metadata,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (conversationId != null) 'conversation_id': conversationId,
      if (role != null) 'role': role,
      if (content != null) 'content': content,
      if (createdAt != null) 'created_at': createdAt,
      if (metadata != null) 'metadata': metadata,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MessagesCompanion copyWith({
    Value<String>? id,
    Value<String>? conversationId,
    Value<String>? role,
    Value<String>? content,
    Value<DateTime>? createdAt,
    Value<String?>? metadata,
    Value<int>? rowid,
  }) {
    return MessagesCompanion(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      role: role ?? this.role,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      metadata: metadata ?? this.metadata,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (conversationId.present) {
      map['conversation_id'] = Variable<String>(conversationId.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (metadata.present) {
      map['metadata'] = Variable<String>(metadata.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MessagesCompanion(')
          ..write('id: $id, ')
          ..write('conversationId: $conversationId, ')
          ..write('role: $role, ')
          ..write('content: $content, ')
          ..write('createdAt: $createdAt, ')
          ..write('metadata: $metadata, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ImageTasksTable extends ImageTasks
    with TableInfo<$ImageTasksTable, ImageTask> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ImageTasksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _providerIdMeta = const VerificationMeta(
    'providerId',
  );
  @override
  late final GeneratedColumn<String> providerId = GeneratedColumn<String>(
    'provider_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES providers (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _tokenIdMeta = const VerificationMeta(
    'tokenId',
  );
  @override
  late final GeneratedColumn<String> tokenId = GeneratedColumn<String>(
    'token_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tokens (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _modelMeta = const VerificationMeta('model');
  @override
  late final GeneratedColumn<String> model = GeneratedColumn<String>(
    'model',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _promptMeta = const VerificationMeta('prompt');
  @override
  late final GeneratedColumn<String> prompt = GeneratedColumn<String>(
    'prompt',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _referencePathsMeta = const VerificationMeta(
    'referencePaths',
  );
  @override
  late final GeneratedColumn<String> referencePaths = GeneratedColumn<String>(
    'reference_paths',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _resultPathMeta = const VerificationMeta(
    'resultPath',
  );
  @override
  late final GeneratedColumn<String> resultPath = GeneratedColumn<String>(
    'result_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _errorMessageMeta = const VerificationMeta(
    'errorMessage',
  );
  @override
  late final GeneratedColumn<String> errorMessage = GeneratedColumn<String>(
    'error_message',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _paramsMeta = const VerificationMeta('params');
  @override
  late final GeneratedColumn<String> params = GeneratedColumn<String>(
    'params',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    providerId,
    tokenId,
    model,
    prompt,
    referencePaths,
    resultPath,
    status,
    errorMessage,
    params,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'image_tasks';
  @override
  VerificationContext validateIntegrity(
    Insertable<ImageTask> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('provider_id')) {
      context.handle(
        _providerIdMeta,
        providerId.isAcceptableOrUnknown(data['provider_id']!, _providerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_providerIdMeta);
    }
    if (data.containsKey('token_id')) {
      context.handle(
        _tokenIdMeta,
        tokenId.isAcceptableOrUnknown(data['token_id']!, _tokenIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tokenIdMeta);
    }
    if (data.containsKey('model')) {
      context.handle(
        _modelMeta,
        model.isAcceptableOrUnknown(data['model']!, _modelMeta),
      );
    } else if (isInserting) {
      context.missing(_modelMeta);
    }
    if (data.containsKey('prompt')) {
      context.handle(
        _promptMeta,
        prompt.isAcceptableOrUnknown(data['prompt']!, _promptMeta),
      );
    } else if (isInserting) {
      context.missing(_promptMeta);
    }
    if (data.containsKey('reference_paths')) {
      context.handle(
        _referencePathsMeta,
        referencePaths.isAcceptableOrUnknown(
          data['reference_paths']!,
          _referencePathsMeta,
        ),
      );
    }
    if (data.containsKey('result_path')) {
      context.handle(
        _resultPathMeta,
        resultPath.isAcceptableOrUnknown(data['result_path']!, _resultPathMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('error_message')) {
      context.handle(
        _errorMessageMeta,
        errorMessage.isAcceptableOrUnknown(
          data['error_message']!,
          _errorMessageMeta,
        ),
      );
    }
    if (data.containsKey('params')) {
      context.handle(
        _paramsMeta,
        params.isAcceptableOrUnknown(data['params']!, _paramsMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ImageTask map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ImageTask(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      providerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}provider_id'],
      )!,
      tokenId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}token_id'],
      )!,
      model: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}model'],
      )!,
      prompt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}prompt'],
      )!,
      referencePaths: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reference_paths'],
      )!,
      resultPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}result_path'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      errorMessage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}error_message'],
      ),
      params: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}params'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $ImageTasksTable createAlias(String alias) {
    return $ImageTasksTable(attachedDatabase, alias);
  }
}

class ImageTask extends DataClass implements Insertable<ImageTask> {
  final String id;
  final String providerId;
  final String tokenId;
  final String model;
  final String prompt;

  /// 参考图相对路径（\n 分隔，位于 app 图片目录内）
  final String referencePaths;

  /// 生成结果相对路径（成功后写入）
  final String? resultPath;

  /// pending / running / success / failed
  final String status;
  final String? errorMessage;

  /// 参数（尺寸等），简单 k:v
  final String? params;
  final DateTime createdAt;
  final DateTime updatedAt;
  const ImageTask({
    required this.id,
    required this.providerId,
    required this.tokenId,
    required this.model,
    required this.prompt,
    required this.referencePaths,
    this.resultPath,
    required this.status,
    this.errorMessage,
    this.params,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['provider_id'] = Variable<String>(providerId);
    map['token_id'] = Variable<String>(tokenId);
    map['model'] = Variable<String>(model);
    map['prompt'] = Variable<String>(prompt);
    map['reference_paths'] = Variable<String>(referencePaths);
    if (!nullToAbsent || resultPath != null) {
      map['result_path'] = Variable<String>(resultPath);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || errorMessage != null) {
      map['error_message'] = Variable<String>(errorMessage);
    }
    if (!nullToAbsent || params != null) {
      map['params'] = Variable<String>(params);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ImageTasksCompanion toCompanion(bool nullToAbsent) {
    return ImageTasksCompanion(
      id: Value(id),
      providerId: Value(providerId),
      tokenId: Value(tokenId),
      model: Value(model),
      prompt: Value(prompt),
      referencePaths: Value(referencePaths),
      resultPath: resultPath == null && nullToAbsent
          ? const Value.absent()
          : Value(resultPath),
      status: Value(status),
      errorMessage: errorMessage == null && nullToAbsent
          ? const Value.absent()
          : Value(errorMessage),
      params: params == null && nullToAbsent
          ? const Value.absent()
          : Value(params),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory ImageTask.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ImageTask(
      id: serializer.fromJson<String>(json['id']),
      providerId: serializer.fromJson<String>(json['providerId']),
      tokenId: serializer.fromJson<String>(json['tokenId']),
      model: serializer.fromJson<String>(json['model']),
      prompt: serializer.fromJson<String>(json['prompt']),
      referencePaths: serializer.fromJson<String>(json['referencePaths']),
      resultPath: serializer.fromJson<String?>(json['resultPath']),
      status: serializer.fromJson<String>(json['status']),
      errorMessage: serializer.fromJson<String?>(json['errorMessage']),
      params: serializer.fromJson<String?>(json['params']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'providerId': serializer.toJson<String>(providerId),
      'tokenId': serializer.toJson<String>(tokenId),
      'model': serializer.toJson<String>(model),
      'prompt': serializer.toJson<String>(prompt),
      'referencePaths': serializer.toJson<String>(referencePaths),
      'resultPath': serializer.toJson<String?>(resultPath),
      'status': serializer.toJson<String>(status),
      'errorMessage': serializer.toJson<String?>(errorMessage),
      'params': serializer.toJson<String?>(params),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  ImageTask copyWith({
    String? id,
    String? providerId,
    String? tokenId,
    String? model,
    String? prompt,
    String? referencePaths,
    Value<String?> resultPath = const Value.absent(),
    String? status,
    Value<String?> errorMessage = const Value.absent(),
    Value<String?> params = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => ImageTask(
    id: id ?? this.id,
    providerId: providerId ?? this.providerId,
    tokenId: tokenId ?? this.tokenId,
    model: model ?? this.model,
    prompt: prompt ?? this.prompt,
    referencePaths: referencePaths ?? this.referencePaths,
    resultPath: resultPath.present ? resultPath.value : this.resultPath,
    status: status ?? this.status,
    errorMessage: errorMessage.present ? errorMessage.value : this.errorMessage,
    params: params.present ? params.value : this.params,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  ImageTask copyWithCompanion(ImageTasksCompanion data) {
    return ImageTask(
      id: data.id.present ? data.id.value : this.id,
      providerId: data.providerId.present
          ? data.providerId.value
          : this.providerId,
      tokenId: data.tokenId.present ? data.tokenId.value : this.tokenId,
      model: data.model.present ? data.model.value : this.model,
      prompt: data.prompt.present ? data.prompt.value : this.prompt,
      referencePaths: data.referencePaths.present
          ? data.referencePaths.value
          : this.referencePaths,
      resultPath: data.resultPath.present
          ? data.resultPath.value
          : this.resultPath,
      status: data.status.present ? data.status.value : this.status,
      errorMessage: data.errorMessage.present
          ? data.errorMessage.value
          : this.errorMessage,
      params: data.params.present ? data.params.value : this.params,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ImageTask(')
          ..write('id: $id, ')
          ..write('providerId: $providerId, ')
          ..write('tokenId: $tokenId, ')
          ..write('model: $model, ')
          ..write('prompt: $prompt, ')
          ..write('referencePaths: $referencePaths, ')
          ..write('resultPath: $resultPath, ')
          ..write('status: $status, ')
          ..write('errorMessage: $errorMessage, ')
          ..write('params: $params, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    providerId,
    tokenId,
    model,
    prompt,
    referencePaths,
    resultPath,
    status,
    errorMessage,
    params,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ImageTask &&
          other.id == this.id &&
          other.providerId == this.providerId &&
          other.tokenId == this.tokenId &&
          other.model == this.model &&
          other.prompt == this.prompt &&
          other.referencePaths == this.referencePaths &&
          other.resultPath == this.resultPath &&
          other.status == this.status &&
          other.errorMessage == this.errorMessage &&
          other.params == this.params &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ImageTasksCompanion extends UpdateCompanion<ImageTask> {
  final Value<String> id;
  final Value<String> providerId;
  final Value<String> tokenId;
  final Value<String> model;
  final Value<String> prompt;
  final Value<String> referencePaths;
  final Value<String?> resultPath;
  final Value<String> status;
  final Value<String?> errorMessage;
  final Value<String?> params;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const ImageTasksCompanion({
    this.id = const Value.absent(),
    this.providerId = const Value.absent(),
    this.tokenId = const Value.absent(),
    this.model = const Value.absent(),
    this.prompt = const Value.absent(),
    this.referencePaths = const Value.absent(),
    this.resultPath = const Value.absent(),
    this.status = const Value.absent(),
    this.errorMessage = const Value.absent(),
    this.params = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ImageTasksCompanion.insert({
    required String id,
    required String providerId,
    required String tokenId,
    required String model,
    required String prompt,
    this.referencePaths = const Value.absent(),
    this.resultPath = const Value.absent(),
    required String status,
    this.errorMessage = const Value.absent(),
    this.params = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       providerId = Value(providerId),
       tokenId = Value(tokenId),
       model = Value(model),
       prompt = Value(prompt),
       status = Value(status),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<ImageTask> custom({
    Expression<String>? id,
    Expression<String>? providerId,
    Expression<String>? tokenId,
    Expression<String>? model,
    Expression<String>? prompt,
    Expression<String>? referencePaths,
    Expression<String>? resultPath,
    Expression<String>? status,
    Expression<String>? errorMessage,
    Expression<String>? params,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (providerId != null) 'provider_id': providerId,
      if (tokenId != null) 'token_id': tokenId,
      if (model != null) 'model': model,
      if (prompt != null) 'prompt': prompt,
      if (referencePaths != null) 'reference_paths': referencePaths,
      if (resultPath != null) 'result_path': resultPath,
      if (status != null) 'status': status,
      if (errorMessage != null) 'error_message': errorMessage,
      if (params != null) 'params': params,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ImageTasksCompanion copyWith({
    Value<String>? id,
    Value<String>? providerId,
    Value<String>? tokenId,
    Value<String>? model,
    Value<String>? prompt,
    Value<String>? referencePaths,
    Value<String?>? resultPath,
    Value<String>? status,
    Value<String?>? errorMessage,
    Value<String?>? params,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return ImageTasksCompanion(
      id: id ?? this.id,
      providerId: providerId ?? this.providerId,
      tokenId: tokenId ?? this.tokenId,
      model: model ?? this.model,
      prompt: prompt ?? this.prompt,
      referencePaths: referencePaths ?? this.referencePaths,
      resultPath: resultPath ?? this.resultPath,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      params: params ?? this.params,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (providerId.present) {
      map['provider_id'] = Variable<String>(providerId.value);
    }
    if (tokenId.present) {
      map['token_id'] = Variable<String>(tokenId.value);
    }
    if (model.present) {
      map['model'] = Variable<String>(model.value);
    }
    if (prompt.present) {
      map['prompt'] = Variable<String>(prompt.value);
    }
    if (referencePaths.present) {
      map['reference_paths'] = Variable<String>(referencePaths.value);
    }
    if (resultPath.present) {
      map['result_path'] = Variable<String>(resultPath.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (errorMessage.present) {
      map['error_message'] = Variable<String>(errorMessage.value);
    }
    if (params.present) {
      map['params'] = Variable<String>(params.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ImageTasksCompanion(')
          ..write('id: $id, ')
          ..write('providerId: $providerId, ')
          ..write('tokenId: $tokenId, ')
          ..write('model: $model, ')
          ..write('prompt: $prompt, ')
          ..write('referencePaths: $referencePaths, ')
          ..write('resultPath: $resultPath, ')
          ..write('status: $status, ')
          ..write('errorMessage: $errorMessage, ')
          ..write('params: $params, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SshHostsTable extends SshHosts with TableInfo<$SshHostsTable, SshHost> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SshHostsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hostMeta = const VerificationMeta('host');
  @override
  late final GeneratedColumn<String> host = GeneratedColumn<String>(
    'host',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _portMeta = const VerificationMeta('port');
  @override
  late final GeneratedColumn<int> port = GeneratedColumn<int>(
    'port',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(22),
  );
  static const VerificationMeta _usernameMeta = const VerificationMeta(
    'username',
  );
  @override
  late final GeneratedColumn<String> username = GeneratedColumn<String>(
    'username',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _authTypeMeta = const VerificationMeta(
    'authType',
  );
  @override
  late final GeneratedColumn<String> authType = GeneratedColumn<String>(
    'auth_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _secretRefMeta = const VerificationMeta(
    'secretRef',
  );
  @override
  late final GeneratedColumn<String> secretRef = GeneratedColumn<String>(
    'secret_ref',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _passphraseRefMeta = const VerificationMeta(
    'passphraseRef',
  );
  @override
  late final GeneratedColumn<String> passphraseRef = GeneratedColumn<String>(
    'passphrase_ref',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _hostKeyFingerprintMeta =
      const VerificationMeta('hostKeyFingerprint');
  @override
  late final GeneratedColumn<String> hostKeyFingerprint =
      GeneratedColumn<String>(
        'host_key_fingerprint',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _isTailscaleMeta = const VerificationMeta(
    'isTailscale',
  );
  @override
  late final GeneratedColumn<bool> isTailscale = GeneratedColumn<bool>(
    'is_tailscale',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_tailscale" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _lastConnectedAtMeta = const VerificationMeta(
    'lastConnectedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastConnectedAt =
      GeneratedColumn<DateTime>(
        'last_connected_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    host,
    port,
    username,
    authType,
    secretRef,
    passphraseRef,
    hostKeyFingerprint,
    isTailscale,
    lastConnectedAt,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ssh_hosts';
  @override
  VerificationContext validateIntegrity(
    Insertable<SshHost> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('host')) {
      context.handle(
        _hostMeta,
        host.isAcceptableOrUnknown(data['host']!, _hostMeta),
      );
    } else if (isInserting) {
      context.missing(_hostMeta);
    }
    if (data.containsKey('port')) {
      context.handle(
        _portMeta,
        port.isAcceptableOrUnknown(data['port']!, _portMeta),
      );
    }
    if (data.containsKey('username')) {
      context.handle(
        _usernameMeta,
        username.isAcceptableOrUnknown(data['username']!, _usernameMeta),
      );
    } else if (isInserting) {
      context.missing(_usernameMeta);
    }
    if (data.containsKey('auth_type')) {
      context.handle(
        _authTypeMeta,
        authType.isAcceptableOrUnknown(data['auth_type']!, _authTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_authTypeMeta);
    }
    if (data.containsKey('secret_ref')) {
      context.handle(
        _secretRefMeta,
        secretRef.isAcceptableOrUnknown(data['secret_ref']!, _secretRefMeta),
      );
    } else if (isInserting) {
      context.missing(_secretRefMeta);
    }
    if (data.containsKey('passphrase_ref')) {
      context.handle(
        _passphraseRefMeta,
        passphraseRef.isAcceptableOrUnknown(
          data['passphrase_ref']!,
          _passphraseRefMeta,
        ),
      );
    }
    if (data.containsKey('host_key_fingerprint')) {
      context.handle(
        _hostKeyFingerprintMeta,
        hostKeyFingerprint.isAcceptableOrUnknown(
          data['host_key_fingerprint']!,
          _hostKeyFingerprintMeta,
        ),
      );
    }
    if (data.containsKey('is_tailscale')) {
      context.handle(
        _isTailscaleMeta,
        isTailscale.isAcceptableOrUnknown(
          data['is_tailscale']!,
          _isTailscaleMeta,
        ),
      );
    }
    if (data.containsKey('last_connected_at')) {
      context.handle(
        _lastConnectedAtMeta,
        lastConnectedAt.isAcceptableOrUnknown(
          data['last_connected_at']!,
          _lastConnectedAtMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SshHost map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SshHost(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      host: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}host'],
      )!,
      port: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}port'],
      )!,
      username: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}username'],
      )!,
      authType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}auth_type'],
      )!,
      secretRef: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}secret_ref'],
      )!,
      passphraseRef: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}passphrase_ref'],
      ),
      hostKeyFingerprint: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}host_key_fingerprint'],
      ),
      isTailscale: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_tailscale'],
      )!,
      lastConnectedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_connected_at'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $SshHostsTable createAlias(String alias) {
    return $SshHostsTable(attachedDatabase, alias);
  }
}

class SshHost extends DataClass implements Insertable<SshHost> {
  final String id;
  final String name;
  final String host;
  final int port;
  final String username;

  /// key / password
  final String authType;

  /// 私钥或密码在 Secure Storage 中的引用 key
  final String secretRef;

  /// 私钥口令引用（仅 key 认证可能需要，可空）
  final String? passphraseRef;

  /// 首次连接接受的 host key 指纹（SHA256:...）
  final String? hostKeyFingerprint;

  /// Tailscale 内网主机：连接失败时提示先打开本机 Tailscale
  final bool isTailscale;

  /// 私钥原文仅用于表单展示时的暂存说明，不存明文
  final DateTime? lastConnectedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  const SshHost({
    required this.id,
    required this.name,
    required this.host,
    required this.port,
    required this.username,
    required this.authType,
    required this.secretRef,
    this.passphraseRef,
    this.hostKeyFingerprint,
    required this.isTailscale,
    this.lastConnectedAt,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['host'] = Variable<String>(host);
    map['port'] = Variable<int>(port);
    map['username'] = Variable<String>(username);
    map['auth_type'] = Variable<String>(authType);
    map['secret_ref'] = Variable<String>(secretRef);
    if (!nullToAbsent || passphraseRef != null) {
      map['passphrase_ref'] = Variable<String>(passphraseRef);
    }
    if (!nullToAbsent || hostKeyFingerprint != null) {
      map['host_key_fingerprint'] = Variable<String>(hostKeyFingerprint);
    }
    map['is_tailscale'] = Variable<bool>(isTailscale);
    if (!nullToAbsent || lastConnectedAt != null) {
      map['last_connected_at'] = Variable<DateTime>(lastConnectedAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  SshHostsCompanion toCompanion(bool nullToAbsent) {
    return SshHostsCompanion(
      id: Value(id),
      name: Value(name),
      host: Value(host),
      port: Value(port),
      username: Value(username),
      authType: Value(authType),
      secretRef: Value(secretRef),
      passphraseRef: passphraseRef == null && nullToAbsent
          ? const Value.absent()
          : Value(passphraseRef),
      hostKeyFingerprint: hostKeyFingerprint == null && nullToAbsent
          ? const Value.absent()
          : Value(hostKeyFingerprint),
      isTailscale: Value(isTailscale),
      lastConnectedAt: lastConnectedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastConnectedAt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory SshHost.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SshHost(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      host: serializer.fromJson<String>(json['host']),
      port: serializer.fromJson<int>(json['port']),
      username: serializer.fromJson<String>(json['username']),
      authType: serializer.fromJson<String>(json['authType']),
      secretRef: serializer.fromJson<String>(json['secretRef']),
      passphraseRef: serializer.fromJson<String?>(json['passphraseRef']),
      hostKeyFingerprint: serializer.fromJson<String?>(
        json['hostKeyFingerprint'],
      ),
      isTailscale: serializer.fromJson<bool>(json['isTailscale']),
      lastConnectedAt: serializer.fromJson<DateTime?>(json['lastConnectedAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'host': serializer.toJson<String>(host),
      'port': serializer.toJson<int>(port),
      'username': serializer.toJson<String>(username),
      'authType': serializer.toJson<String>(authType),
      'secretRef': serializer.toJson<String>(secretRef),
      'passphraseRef': serializer.toJson<String?>(passphraseRef),
      'hostKeyFingerprint': serializer.toJson<String?>(hostKeyFingerprint),
      'isTailscale': serializer.toJson<bool>(isTailscale),
      'lastConnectedAt': serializer.toJson<DateTime?>(lastConnectedAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  SshHost copyWith({
    String? id,
    String? name,
    String? host,
    int? port,
    String? username,
    String? authType,
    String? secretRef,
    Value<String?> passphraseRef = const Value.absent(),
    Value<String?> hostKeyFingerprint = const Value.absent(),
    bool? isTailscale,
    Value<DateTime?> lastConnectedAt = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => SshHost(
    id: id ?? this.id,
    name: name ?? this.name,
    host: host ?? this.host,
    port: port ?? this.port,
    username: username ?? this.username,
    authType: authType ?? this.authType,
    secretRef: secretRef ?? this.secretRef,
    passphraseRef: passphraseRef.present
        ? passphraseRef.value
        : this.passphraseRef,
    hostKeyFingerprint: hostKeyFingerprint.present
        ? hostKeyFingerprint.value
        : this.hostKeyFingerprint,
    isTailscale: isTailscale ?? this.isTailscale,
    lastConnectedAt: lastConnectedAt.present
        ? lastConnectedAt.value
        : this.lastConnectedAt,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  SshHost copyWithCompanion(SshHostsCompanion data) {
    return SshHost(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      host: data.host.present ? data.host.value : this.host,
      port: data.port.present ? data.port.value : this.port,
      username: data.username.present ? data.username.value : this.username,
      authType: data.authType.present ? data.authType.value : this.authType,
      secretRef: data.secretRef.present ? data.secretRef.value : this.secretRef,
      passphraseRef: data.passphraseRef.present
          ? data.passphraseRef.value
          : this.passphraseRef,
      hostKeyFingerprint: data.hostKeyFingerprint.present
          ? data.hostKeyFingerprint.value
          : this.hostKeyFingerprint,
      isTailscale: data.isTailscale.present
          ? data.isTailscale.value
          : this.isTailscale,
      lastConnectedAt: data.lastConnectedAt.present
          ? data.lastConnectedAt.value
          : this.lastConnectedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SshHost(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('host: $host, ')
          ..write('port: $port, ')
          ..write('username: $username, ')
          ..write('authType: $authType, ')
          ..write('secretRef: $secretRef, ')
          ..write('passphraseRef: $passphraseRef, ')
          ..write('hostKeyFingerprint: $hostKeyFingerprint, ')
          ..write('isTailscale: $isTailscale, ')
          ..write('lastConnectedAt: $lastConnectedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    host,
    port,
    username,
    authType,
    secretRef,
    passphraseRef,
    hostKeyFingerprint,
    isTailscale,
    lastConnectedAt,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SshHost &&
          other.id == this.id &&
          other.name == this.name &&
          other.host == this.host &&
          other.port == this.port &&
          other.username == this.username &&
          other.authType == this.authType &&
          other.secretRef == this.secretRef &&
          other.passphraseRef == this.passphraseRef &&
          other.hostKeyFingerprint == this.hostKeyFingerprint &&
          other.isTailscale == this.isTailscale &&
          other.lastConnectedAt == this.lastConnectedAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class SshHostsCompanion extends UpdateCompanion<SshHost> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> host;
  final Value<int> port;
  final Value<String> username;
  final Value<String> authType;
  final Value<String> secretRef;
  final Value<String?> passphraseRef;
  final Value<String?> hostKeyFingerprint;
  final Value<bool> isTailscale;
  final Value<DateTime?> lastConnectedAt;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const SshHostsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.host = const Value.absent(),
    this.port = const Value.absent(),
    this.username = const Value.absent(),
    this.authType = const Value.absent(),
    this.secretRef = const Value.absent(),
    this.passphraseRef = const Value.absent(),
    this.hostKeyFingerprint = const Value.absent(),
    this.isTailscale = const Value.absent(),
    this.lastConnectedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SshHostsCompanion.insert({
    required String id,
    required String name,
    required String host,
    this.port = const Value.absent(),
    required String username,
    required String authType,
    required String secretRef,
    this.passphraseRef = const Value.absent(),
    this.hostKeyFingerprint = const Value.absent(),
    this.isTailscale = const Value.absent(),
    this.lastConnectedAt = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       host = Value(host),
       username = Value(username),
       authType = Value(authType),
       secretRef = Value(secretRef),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<SshHost> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? host,
    Expression<int>? port,
    Expression<String>? username,
    Expression<String>? authType,
    Expression<String>? secretRef,
    Expression<String>? passphraseRef,
    Expression<String>? hostKeyFingerprint,
    Expression<bool>? isTailscale,
    Expression<DateTime>? lastConnectedAt,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (host != null) 'host': host,
      if (port != null) 'port': port,
      if (username != null) 'username': username,
      if (authType != null) 'auth_type': authType,
      if (secretRef != null) 'secret_ref': secretRef,
      if (passphraseRef != null) 'passphrase_ref': passphraseRef,
      if (hostKeyFingerprint != null)
        'host_key_fingerprint': hostKeyFingerprint,
      if (isTailscale != null) 'is_tailscale': isTailscale,
      if (lastConnectedAt != null) 'last_connected_at': lastConnectedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SshHostsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? host,
    Value<int>? port,
    Value<String>? username,
    Value<String>? authType,
    Value<String>? secretRef,
    Value<String?>? passphraseRef,
    Value<String?>? hostKeyFingerprint,
    Value<bool>? isTailscale,
    Value<DateTime?>? lastConnectedAt,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return SshHostsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      host: host ?? this.host,
      port: port ?? this.port,
      username: username ?? this.username,
      authType: authType ?? this.authType,
      secretRef: secretRef ?? this.secretRef,
      passphraseRef: passphraseRef ?? this.passphraseRef,
      hostKeyFingerprint: hostKeyFingerprint ?? this.hostKeyFingerprint,
      isTailscale: isTailscale ?? this.isTailscale,
      lastConnectedAt: lastConnectedAt ?? this.lastConnectedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (host.present) {
      map['host'] = Variable<String>(host.value);
    }
    if (port.present) {
      map['port'] = Variable<int>(port.value);
    }
    if (username.present) {
      map['username'] = Variable<String>(username.value);
    }
    if (authType.present) {
      map['auth_type'] = Variable<String>(authType.value);
    }
    if (secretRef.present) {
      map['secret_ref'] = Variable<String>(secretRef.value);
    }
    if (passphraseRef.present) {
      map['passphrase_ref'] = Variable<String>(passphraseRef.value);
    }
    if (hostKeyFingerprint.present) {
      map['host_key_fingerprint'] = Variable<String>(hostKeyFingerprint.value);
    }
    if (isTailscale.present) {
      map['is_tailscale'] = Variable<bool>(isTailscale.value);
    }
    if (lastConnectedAt.present) {
      map['last_connected_at'] = Variable<DateTime>(lastConnectedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SshHostsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('host: $host, ')
          ..write('port: $port, ')
          ..write('username: $username, ')
          ..write('authType: $authType, ')
          ..write('secretRef: $secretRef, ')
          ..write('passphraseRef: $passphraseRef, ')
          ..write('hostKeyFingerprint: $hostKeyFingerprint, ')
          ..write('isTailscale: $isTailscale, ')
          ..write('lastConnectedAt: $lastConnectedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $NotificationsTable extends Notifications
    with TableInfo<$NotificationsTable, Notification> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NotificationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _providerIdMeta = const VerificationMeta(
    'providerId',
  );
  @override
  late final GeneratedColumn<String> providerId = GeneratedColumn<String>(
    'provider_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _readMeta = const VerificationMeta('read');
  @override
  late final GeneratedColumn<bool> read = GeneratedColumn<bool>(
    'read',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("read" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    kind,
    providerId,
    title,
    body,
    read,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'notifications';
  @override
  VerificationContext validateIntegrity(
    Insertable<Notification> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('provider_id')) {
      context.handle(
        _providerIdMeta,
        providerId.isAcceptableOrUnknown(data['provider_id']!, _providerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_providerIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
    } else if (isInserting) {
      context.missing(_bodyMeta);
    }
    if (data.containsKey('read')) {
      context.handle(
        _readMeta,
        read.isAcceptableOrUnknown(data['read']!, _readMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Notification map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Notification(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      providerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}provider_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body'],
      )!,
      read: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}read'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $NotificationsTable createAlias(String alias) {
    return $NotificationsTable(attachedDatabase, alias);
  }
}

class Notification extends DataClass implements Insertable<Notification> {
  final int id;

  /// quotaRecovered / checkinAvailable / dataStale
  final String kind;
  final String providerId;
  final String title;
  final String body;
  final bool read;
  final DateTime createdAt;
  const Notification({
    required this.id,
    required this.kind,
    required this.providerId,
    required this.title,
    required this.body,
    required this.read,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['kind'] = Variable<String>(kind);
    map['provider_id'] = Variable<String>(providerId);
    map['title'] = Variable<String>(title);
    map['body'] = Variable<String>(body);
    map['read'] = Variable<bool>(read);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  NotificationsCompanion toCompanion(bool nullToAbsent) {
    return NotificationsCompanion(
      id: Value(id),
      kind: Value(kind),
      providerId: Value(providerId),
      title: Value(title),
      body: Value(body),
      read: Value(read),
      createdAt: Value(createdAt),
    );
  }

  factory Notification.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Notification(
      id: serializer.fromJson<int>(json['id']),
      kind: serializer.fromJson<String>(json['kind']),
      providerId: serializer.fromJson<String>(json['providerId']),
      title: serializer.fromJson<String>(json['title']),
      body: serializer.fromJson<String>(json['body']),
      read: serializer.fromJson<bool>(json['read']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'kind': serializer.toJson<String>(kind),
      'providerId': serializer.toJson<String>(providerId),
      'title': serializer.toJson<String>(title),
      'body': serializer.toJson<String>(body),
      'read': serializer.toJson<bool>(read),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Notification copyWith({
    int? id,
    String? kind,
    String? providerId,
    String? title,
    String? body,
    bool? read,
    DateTime? createdAt,
  }) => Notification(
    id: id ?? this.id,
    kind: kind ?? this.kind,
    providerId: providerId ?? this.providerId,
    title: title ?? this.title,
    body: body ?? this.body,
    read: read ?? this.read,
    createdAt: createdAt ?? this.createdAt,
  );
  Notification copyWithCompanion(NotificationsCompanion data) {
    return Notification(
      id: data.id.present ? data.id.value : this.id,
      kind: data.kind.present ? data.kind.value : this.kind,
      providerId: data.providerId.present
          ? data.providerId.value
          : this.providerId,
      title: data.title.present ? data.title.value : this.title,
      body: data.body.present ? data.body.value : this.body,
      read: data.read.present ? data.read.value : this.read,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Notification(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('providerId: $providerId, ')
          ..write('title: $title, ')
          ..write('body: $body, ')
          ..write('read: $read, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, kind, providerId, title, body, read, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Notification &&
          other.id == this.id &&
          other.kind == this.kind &&
          other.providerId == this.providerId &&
          other.title == this.title &&
          other.body == this.body &&
          other.read == this.read &&
          other.createdAt == this.createdAt);
}

class NotificationsCompanion extends UpdateCompanion<Notification> {
  final Value<int> id;
  final Value<String> kind;
  final Value<String> providerId;
  final Value<String> title;
  final Value<String> body;
  final Value<bool> read;
  final Value<DateTime> createdAt;
  const NotificationsCompanion({
    this.id = const Value.absent(),
    this.kind = const Value.absent(),
    this.providerId = const Value.absent(),
    this.title = const Value.absent(),
    this.body = const Value.absent(),
    this.read = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  NotificationsCompanion.insert({
    this.id = const Value.absent(),
    required String kind,
    required String providerId,
    required String title,
    required String body,
    this.read = const Value.absent(),
    required DateTime createdAt,
  }) : kind = Value(kind),
       providerId = Value(providerId),
       title = Value(title),
       body = Value(body),
       createdAt = Value(createdAt);
  static Insertable<Notification> custom({
    Expression<int>? id,
    Expression<String>? kind,
    Expression<String>? providerId,
    Expression<String>? title,
    Expression<String>? body,
    Expression<bool>? read,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (kind != null) 'kind': kind,
      if (providerId != null) 'provider_id': providerId,
      if (title != null) 'title': title,
      if (body != null) 'body': body,
      if (read != null) 'read': read,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  NotificationsCompanion copyWith({
    Value<int>? id,
    Value<String>? kind,
    Value<String>? providerId,
    Value<String>? title,
    Value<String>? body,
    Value<bool>? read,
    Value<DateTime>? createdAt,
  }) {
    return NotificationsCompanion(
      id: id ?? this.id,
      kind: kind ?? this.kind,
      providerId: providerId ?? this.providerId,
      title: title ?? this.title,
      body: body ?? this.body,
      read: read ?? this.read,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (providerId.present) {
      map['provider_id'] = Variable<String>(providerId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (read.present) {
      map['read'] = Variable<bool>(read.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NotificationsCompanion(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('providerId: $providerId, ')
          ..write('title: $title, ')
          ..write('body: $body, ')
          ..write('read: $read, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $MonitorSitesTable extends MonitorSites
    with TableInfo<$MonitorSitesTable, MonitorSite> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MonitorSitesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _baseUrlMeta = const VerificationMeta(
    'baseUrl',
  );
  @override
  late final GeneratedColumn<String> baseUrl = GeneratedColumn<String>(
    'base_url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('komari'),
  );
  static const VerificationMeta _apiTokenRefMeta = const VerificationMeta(
    'apiTokenRef',
  );
  @override
  late final GeneratedColumn<String> apiTokenRef = GeneratedColumn<String>(
    'api_token_ref',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _showOnHomeMeta = const VerificationMeta(
    'showOnHome',
  );
  @override
  late final GeneratedColumn<bool> showOnHome = GeneratedColumn<bool>(
    'show_on_home',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("show_on_home" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastDataMeta = const VerificationMeta(
    'lastData',
  );
  @override
  late final GeneratedColumn<String> lastData = GeneratedColumn<String>(
    'last_data',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastFetchedAtMeta = const VerificationMeta(
    'lastFetchedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastFetchedAt =
      GeneratedColumn<DateTime>(
        'last_fetched_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _lastErrorMeta = const VerificationMeta(
    'lastError',
  );
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    baseUrl,
    kind,
    apiTokenRef,
    showOnHome,
    sortOrder,
    lastData,
    lastFetchedAt,
    lastError,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'monitor_sites';
  @override
  VerificationContext validateIntegrity(
    Insertable<MonitorSite> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('base_url')) {
      context.handle(
        _baseUrlMeta,
        baseUrl.isAcceptableOrUnknown(data['base_url']!, _baseUrlMeta),
      );
    } else if (isInserting) {
      context.missing(_baseUrlMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    }
    if (data.containsKey('api_token_ref')) {
      context.handle(
        _apiTokenRefMeta,
        apiTokenRef.isAcceptableOrUnknown(
          data['api_token_ref']!,
          _apiTokenRefMeta,
        ),
      );
    }
    if (data.containsKey('show_on_home')) {
      context.handle(
        _showOnHomeMeta,
        showOnHome.isAcceptableOrUnknown(
          data['show_on_home']!,
          _showOnHomeMeta,
        ),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('last_data')) {
      context.handle(
        _lastDataMeta,
        lastData.isAcceptableOrUnknown(data['last_data']!, _lastDataMeta),
      );
    }
    if (data.containsKey('last_fetched_at')) {
      context.handle(
        _lastFetchedAtMeta,
        lastFetchedAt.isAcceptableOrUnknown(
          data['last_fetched_at']!,
          _lastFetchedAtMeta,
        ),
      );
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MonitorSite map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MonitorSite(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      baseUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}base_url'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      apiTokenRef: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}api_token_ref'],
      ),
      showOnHome: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}show_on_home'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      lastData: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_data'],
      ),
      lastFetchedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_fetched_at'],
      ),
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $MonitorSitesTable createAlias(String alias) {
    return $MonitorSitesTable(attachedDatabase, alias);
  }
}

class MonitorSite extends DataClass implements Insertable<MonitorSite> {
  final int id;
  final String name;
  final String baseUrl;

  /// 面板类型：komari（预留扩展哪吒等其他面板）
  final String kind;

  /// 管理员 API Key 在 Secure Storage 中的引用 key
  /// （公开站点无需令牌；私有站点或需要完整数据时填写）
  final String? apiTokenRef;

  /// 是否在首页探针区展示
  final bool showOnHome;
  final int sortOrder;

  /// 最近一次抓取的节点数据 JSON（离线时展示缓存）
  final String? lastData;
  final DateTime? lastFetchedAt;
  final String? lastError;
  final DateTime createdAt;
  final DateTime updatedAt;
  const MonitorSite({
    required this.id,
    required this.name,
    required this.baseUrl,
    required this.kind,
    this.apiTokenRef,
    required this.showOnHome,
    required this.sortOrder,
    this.lastData,
    this.lastFetchedAt,
    this.lastError,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['base_url'] = Variable<String>(baseUrl);
    map['kind'] = Variable<String>(kind);
    if (!nullToAbsent || apiTokenRef != null) {
      map['api_token_ref'] = Variable<String>(apiTokenRef);
    }
    map['show_on_home'] = Variable<bool>(showOnHome);
    map['sort_order'] = Variable<int>(sortOrder);
    if (!nullToAbsent || lastData != null) {
      map['last_data'] = Variable<String>(lastData);
    }
    if (!nullToAbsent || lastFetchedAt != null) {
      map['last_fetched_at'] = Variable<DateTime>(lastFetchedAt);
    }
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  MonitorSitesCompanion toCompanion(bool nullToAbsent) {
    return MonitorSitesCompanion(
      id: Value(id),
      name: Value(name),
      baseUrl: Value(baseUrl),
      kind: Value(kind),
      apiTokenRef: apiTokenRef == null && nullToAbsent
          ? const Value.absent()
          : Value(apiTokenRef),
      showOnHome: Value(showOnHome),
      sortOrder: Value(sortOrder),
      lastData: lastData == null && nullToAbsent
          ? const Value.absent()
          : Value(lastData),
      lastFetchedAt: lastFetchedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastFetchedAt),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory MonitorSite.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MonitorSite(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      baseUrl: serializer.fromJson<String>(json['baseUrl']),
      kind: serializer.fromJson<String>(json['kind']),
      apiTokenRef: serializer.fromJson<String?>(json['apiTokenRef']),
      showOnHome: serializer.fromJson<bool>(json['showOnHome']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      lastData: serializer.fromJson<String?>(json['lastData']),
      lastFetchedAt: serializer.fromJson<DateTime?>(json['lastFetchedAt']),
      lastError: serializer.fromJson<String?>(json['lastError']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'baseUrl': serializer.toJson<String>(baseUrl),
      'kind': serializer.toJson<String>(kind),
      'apiTokenRef': serializer.toJson<String?>(apiTokenRef),
      'showOnHome': serializer.toJson<bool>(showOnHome),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'lastData': serializer.toJson<String?>(lastData),
      'lastFetchedAt': serializer.toJson<DateTime?>(lastFetchedAt),
      'lastError': serializer.toJson<String?>(lastError),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  MonitorSite copyWith({
    int? id,
    String? name,
    String? baseUrl,
    String? kind,
    Value<String?> apiTokenRef = const Value.absent(),
    bool? showOnHome,
    int? sortOrder,
    Value<String?> lastData = const Value.absent(),
    Value<DateTime?> lastFetchedAt = const Value.absent(),
    Value<String?> lastError = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => MonitorSite(
    id: id ?? this.id,
    name: name ?? this.name,
    baseUrl: baseUrl ?? this.baseUrl,
    kind: kind ?? this.kind,
    apiTokenRef: apiTokenRef.present ? apiTokenRef.value : this.apiTokenRef,
    showOnHome: showOnHome ?? this.showOnHome,
    sortOrder: sortOrder ?? this.sortOrder,
    lastData: lastData.present ? lastData.value : this.lastData,
    lastFetchedAt: lastFetchedAt.present
        ? lastFetchedAt.value
        : this.lastFetchedAt,
    lastError: lastError.present ? lastError.value : this.lastError,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  MonitorSite copyWithCompanion(MonitorSitesCompanion data) {
    return MonitorSite(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      baseUrl: data.baseUrl.present ? data.baseUrl.value : this.baseUrl,
      kind: data.kind.present ? data.kind.value : this.kind,
      apiTokenRef: data.apiTokenRef.present
          ? data.apiTokenRef.value
          : this.apiTokenRef,
      showOnHome: data.showOnHome.present
          ? data.showOnHome.value
          : this.showOnHome,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      lastData: data.lastData.present ? data.lastData.value : this.lastData,
      lastFetchedAt: data.lastFetchedAt.present
          ? data.lastFetchedAt.value
          : this.lastFetchedAt,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MonitorSite(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('baseUrl: $baseUrl, ')
          ..write('kind: $kind, ')
          ..write('apiTokenRef: $apiTokenRef, ')
          ..write('showOnHome: $showOnHome, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('lastData: $lastData, ')
          ..write('lastFetchedAt: $lastFetchedAt, ')
          ..write('lastError: $lastError, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    baseUrl,
    kind,
    apiTokenRef,
    showOnHome,
    sortOrder,
    lastData,
    lastFetchedAt,
    lastError,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MonitorSite &&
          other.id == this.id &&
          other.name == this.name &&
          other.baseUrl == this.baseUrl &&
          other.kind == this.kind &&
          other.apiTokenRef == this.apiTokenRef &&
          other.showOnHome == this.showOnHome &&
          other.sortOrder == this.sortOrder &&
          other.lastData == this.lastData &&
          other.lastFetchedAt == this.lastFetchedAt &&
          other.lastError == this.lastError &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class MonitorSitesCompanion extends UpdateCompanion<MonitorSite> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> baseUrl;
  final Value<String> kind;
  final Value<String?> apiTokenRef;
  final Value<bool> showOnHome;
  final Value<int> sortOrder;
  final Value<String?> lastData;
  final Value<DateTime?> lastFetchedAt;
  final Value<String?> lastError;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const MonitorSitesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.baseUrl = const Value.absent(),
    this.kind = const Value.absent(),
    this.apiTokenRef = const Value.absent(),
    this.showOnHome = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.lastData = const Value.absent(),
    this.lastFetchedAt = const Value.absent(),
    this.lastError = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  MonitorSitesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String baseUrl,
    this.kind = const Value.absent(),
    this.apiTokenRef = const Value.absent(),
    this.showOnHome = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.lastData = const Value.absent(),
    this.lastFetchedAt = const Value.absent(),
    this.lastError = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : name = Value(name),
       baseUrl = Value(baseUrl),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<MonitorSite> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? baseUrl,
    Expression<String>? kind,
    Expression<String>? apiTokenRef,
    Expression<bool>? showOnHome,
    Expression<int>? sortOrder,
    Expression<String>? lastData,
    Expression<DateTime>? lastFetchedAt,
    Expression<String>? lastError,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (baseUrl != null) 'base_url': baseUrl,
      if (kind != null) 'kind': kind,
      if (apiTokenRef != null) 'api_token_ref': apiTokenRef,
      if (showOnHome != null) 'show_on_home': showOnHome,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (lastData != null) 'last_data': lastData,
      if (lastFetchedAt != null) 'last_fetched_at': lastFetchedAt,
      if (lastError != null) 'last_error': lastError,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  MonitorSitesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? baseUrl,
    Value<String>? kind,
    Value<String?>? apiTokenRef,
    Value<bool>? showOnHome,
    Value<int>? sortOrder,
    Value<String?>? lastData,
    Value<DateTime?>? lastFetchedAt,
    Value<String?>? lastError,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return MonitorSitesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      baseUrl: baseUrl ?? this.baseUrl,
      kind: kind ?? this.kind,
      apiTokenRef: apiTokenRef ?? this.apiTokenRef,
      showOnHome: showOnHome ?? this.showOnHome,
      sortOrder: sortOrder ?? this.sortOrder,
      lastData: lastData ?? this.lastData,
      lastFetchedAt: lastFetchedAt ?? this.lastFetchedAt,
      lastError: lastError ?? this.lastError,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (baseUrl.present) {
      map['base_url'] = Variable<String>(baseUrl.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (apiTokenRef.present) {
      map['api_token_ref'] = Variable<String>(apiTokenRef.value);
    }
    if (showOnHome.present) {
      map['show_on_home'] = Variable<bool>(showOnHome.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (lastData.present) {
      map['last_data'] = Variable<String>(lastData.value);
    }
    if (lastFetchedAt.present) {
      map['last_fetched_at'] = Variable<DateTime>(lastFetchedAt.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MonitorSitesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('baseUrl: $baseUrl, ')
          ..write('kind: $kind, ')
          ..write('apiTokenRef: $apiTokenRef, ')
          ..write('showOnHome: $showOnHome, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('lastData: $lastData, ')
          ..write('lastFetchedAt: $lastFetchedAt, ')
          ..write('lastError: $lastError, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ProvidersTable providers = $ProvidersTable(this);
  late final $TokensTable tokens = $TokensTable(this);
  late final $ProviderModelsTable providerModels = $ProviderModelsTable(this);
  late final $QuotaSnapshotsTable quotaSnapshots = $QuotaSnapshotsTable(this);
  late final $ModelTestRecordsTable modelTestRecords = $ModelTestRecordsTable(
    this,
  );
  late final $CheckinRecordsTable checkinRecords = $CheckinRecordsTable(this);
  late final $PrewarmRecordsTable prewarmRecords = $PrewarmRecordsTable(this);
  late final $WebdavConfigsTable webdavConfigs = $WebdavConfigsTable(this);
  late final $ConversationsTable conversations = $ConversationsTable(this);
  late final $MessagesTable messages = $MessagesTable(this);
  late final $ImageTasksTable imageTasks = $ImageTasksTable(this);
  late final $SshHostsTable sshHosts = $SshHostsTable(this);
  late final $NotificationsTable notifications = $NotificationsTable(this);
  late final $MonitorSitesTable monitorSites = $MonitorSitesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    providers,
    tokens,
    providerModels,
    quotaSnapshots,
    modelTestRecords,
    checkinRecords,
    prewarmRecords,
    webdavConfigs,
    conversations,
    messages,
    imageTasks,
    sshHosts,
    notifications,
    monitorSites,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'providers',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('tokens', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'tokens',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('provider_models', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'providers',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('quota_snapshots', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'tokens',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('model_test_records', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'providers',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('checkin_records', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'providers',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('prewarm_records', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'providers',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('conversations', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'tokens',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('conversations', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'conversations',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('messages', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'providers',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('image_tasks', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'tokens',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('image_tasks', kind: UpdateKind.delete)],
    ),
  ]);
  @override
  DriftDatabaseOptions get options =>
      const DriftDatabaseOptions(storeDateTimeAsText: true);
}

typedef $$ProvidersTableCreateCompanionBuilder =
    ProvidersCompanion Function({
      required String id,
      required String name,
      required ProviderType type,
      required AdapterKind adapterKind,
      Value<String> baseUrl,
      Value<String> accountLabel,
      Value<String?> systemTokenRef,
      Value<String?> systemUserId,
      Value<bool> checkinDisabled,
      Value<bool> pinned,
      Value<int> sortOrder,
      Value<bool> hidden,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$ProvidersTableUpdateCompanionBuilder =
    ProvidersCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<ProviderType> type,
      Value<AdapterKind> adapterKind,
      Value<String> baseUrl,
      Value<String> accountLabel,
      Value<String?> systemTokenRef,
      Value<String?> systemUserId,
      Value<bool> checkinDisabled,
      Value<bool> pinned,
      Value<int> sortOrder,
      Value<bool> hidden,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$ProvidersTableReferences
    extends BaseReferences<_$AppDatabase, $ProvidersTable, Provider> {
  $$ProvidersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$TokensTable, List<Token>> _tokensRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.tokens,
    aliasName: $_aliasNameGenerator(db.providers.id, db.tokens.providerId),
  );

  $$TokensTableProcessedTableManager get tokensRefs {
    final manager = $$TokensTableTableManager(
      $_db,
      $_db.tokens,
    ).filter((f) => f.providerId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_tokensRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$QuotaSnapshotsTable, List<QuotaSnapshot>>
  _quotaSnapshotsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.quotaSnapshots,
    aliasName: $_aliasNameGenerator(
      db.providers.id,
      db.quotaSnapshots.providerId,
    ),
  );

  $$QuotaSnapshotsTableProcessedTableManager get quotaSnapshotsRefs {
    final manager = $$QuotaSnapshotsTableTableManager(
      $_db,
      $_db.quotaSnapshots,
    ).filter((f) => f.providerId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_quotaSnapshotsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$CheckinRecordsTable, List<CheckinRecord>>
  _checkinRecordsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.checkinRecords,
    aliasName: $_aliasNameGenerator(
      db.providers.id,
      db.checkinRecords.providerId,
    ),
  );

  $$CheckinRecordsTableProcessedTableManager get checkinRecordsRefs {
    final manager = $$CheckinRecordsTableTableManager(
      $_db,
      $_db.checkinRecords,
    ).filter((f) => f.providerId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_checkinRecordsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PrewarmRecordsTable, List<PrewarmRecord>>
  _prewarmRecordsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.prewarmRecords,
    aliasName: $_aliasNameGenerator(
      db.providers.id,
      db.prewarmRecords.providerId,
    ),
  );

  $$PrewarmRecordsTableProcessedTableManager get prewarmRecordsRefs {
    final manager = $$PrewarmRecordsTableTableManager(
      $_db,
      $_db.prewarmRecords,
    ).filter((f) => f.providerId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_prewarmRecordsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ConversationsTable, List<Conversation>>
  _conversationsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.conversations,
    aliasName: $_aliasNameGenerator(
      db.providers.id,
      db.conversations.providerId,
    ),
  );

  $$ConversationsTableProcessedTableManager get conversationsRefs {
    final manager = $$ConversationsTableTableManager(
      $_db,
      $_db.conversations,
    ).filter((f) => f.providerId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_conversationsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ImageTasksTable, List<ImageTask>>
  _imageTasksRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.imageTasks,
    aliasName: $_aliasNameGenerator(db.providers.id, db.imageTasks.providerId),
  );

  $$ImageTasksTableProcessedTableManager get imageTasksRefs {
    final manager = $$ImageTasksTableTableManager(
      $_db,
      $_db.imageTasks,
    ).filter((f) => f.providerId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_imageTasksRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ProvidersTableFilterComposer
    extends Composer<_$AppDatabase, $ProvidersTable> {
  $$ProvidersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<ProviderType, ProviderType, int> get type =>
      $composableBuilder(
        column: $table.type,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<AdapterKind, AdapterKind, String>
  get adapterKind => $composableBuilder(
    column: $table.adapterKind,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get baseUrl => $composableBuilder(
    column: $table.baseUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get accountLabel => $composableBuilder(
    column: $table.accountLabel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get systemTokenRef => $composableBuilder(
    column: $table.systemTokenRef,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get systemUserId => $composableBuilder(
    column: $table.systemUserId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get checkinDisabled => $composableBuilder(
    column: $table.checkinDisabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get pinned => $composableBuilder(
    column: $table.pinned,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get hidden => $composableBuilder(
    column: $table.hidden,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> tokensRefs(
    Expression<bool> Function($$TokensTableFilterComposer f) f,
  ) {
    final $$TokensTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tokens,
      getReferencedColumn: (t) => t.providerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TokensTableFilterComposer(
            $db: $db,
            $table: $db.tokens,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> quotaSnapshotsRefs(
    Expression<bool> Function($$QuotaSnapshotsTableFilterComposer f) f,
  ) {
    final $$QuotaSnapshotsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.quotaSnapshots,
      getReferencedColumn: (t) => t.providerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QuotaSnapshotsTableFilterComposer(
            $db: $db,
            $table: $db.quotaSnapshots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> checkinRecordsRefs(
    Expression<bool> Function($$CheckinRecordsTableFilterComposer f) f,
  ) {
    final $$CheckinRecordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.checkinRecords,
      getReferencedColumn: (t) => t.providerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CheckinRecordsTableFilterComposer(
            $db: $db,
            $table: $db.checkinRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> prewarmRecordsRefs(
    Expression<bool> Function($$PrewarmRecordsTableFilterComposer f) f,
  ) {
    final $$PrewarmRecordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.prewarmRecords,
      getReferencedColumn: (t) => t.providerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PrewarmRecordsTableFilterComposer(
            $db: $db,
            $table: $db.prewarmRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> conversationsRefs(
    Expression<bool> Function($$ConversationsTableFilterComposer f) f,
  ) {
    final $$ConversationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.conversations,
      getReferencedColumn: (t) => t.providerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ConversationsTableFilterComposer(
            $db: $db,
            $table: $db.conversations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> imageTasksRefs(
    Expression<bool> Function($$ImageTasksTableFilterComposer f) f,
  ) {
    final $$ImageTasksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.imageTasks,
      getReferencedColumn: (t) => t.providerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImageTasksTableFilterComposer(
            $db: $db,
            $table: $db.imageTasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ProvidersTableOrderingComposer
    extends Composer<_$AppDatabase, $ProvidersTable> {
  $$ProvidersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get adapterKind => $composableBuilder(
    column: $table.adapterKind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get baseUrl => $composableBuilder(
    column: $table.baseUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get accountLabel => $composableBuilder(
    column: $table.accountLabel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get systemTokenRef => $composableBuilder(
    column: $table.systemTokenRef,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get systemUserId => $composableBuilder(
    column: $table.systemUserId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get checkinDisabled => $composableBuilder(
    column: $table.checkinDisabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get pinned => $composableBuilder(
    column: $table.pinned,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get hidden => $composableBuilder(
    column: $table.hidden,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProvidersTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProvidersTable> {
  $$ProvidersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ProviderType, int> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumnWithTypeConverter<AdapterKind, String> get adapterKind =>
      $composableBuilder(
        column: $table.adapterKind,
        builder: (column) => column,
      );

  GeneratedColumn<String> get baseUrl =>
      $composableBuilder(column: $table.baseUrl, builder: (column) => column);

  GeneratedColumn<String> get accountLabel => $composableBuilder(
    column: $table.accountLabel,
    builder: (column) => column,
  );

  GeneratedColumn<String> get systemTokenRef => $composableBuilder(
    column: $table.systemTokenRef,
    builder: (column) => column,
  );

  GeneratedColumn<String> get systemUserId => $composableBuilder(
    column: $table.systemUserId,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get checkinDisabled => $composableBuilder(
    column: $table.checkinDisabled,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get pinned =>
      $composableBuilder(column: $table.pinned, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<bool> get hidden =>
      $composableBuilder(column: $table.hidden, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> tokensRefs<T extends Object>(
    Expression<T> Function($$TokensTableAnnotationComposer a) f,
  ) {
    final $$TokensTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tokens,
      getReferencedColumn: (t) => t.providerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TokensTableAnnotationComposer(
            $db: $db,
            $table: $db.tokens,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> quotaSnapshotsRefs<T extends Object>(
    Expression<T> Function($$QuotaSnapshotsTableAnnotationComposer a) f,
  ) {
    final $$QuotaSnapshotsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.quotaSnapshots,
      getReferencedColumn: (t) => t.providerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QuotaSnapshotsTableAnnotationComposer(
            $db: $db,
            $table: $db.quotaSnapshots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> checkinRecordsRefs<T extends Object>(
    Expression<T> Function($$CheckinRecordsTableAnnotationComposer a) f,
  ) {
    final $$CheckinRecordsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.checkinRecords,
      getReferencedColumn: (t) => t.providerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CheckinRecordsTableAnnotationComposer(
            $db: $db,
            $table: $db.checkinRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> prewarmRecordsRefs<T extends Object>(
    Expression<T> Function($$PrewarmRecordsTableAnnotationComposer a) f,
  ) {
    final $$PrewarmRecordsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.prewarmRecords,
      getReferencedColumn: (t) => t.providerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PrewarmRecordsTableAnnotationComposer(
            $db: $db,
            $table: $db.prewarmRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> conversationsRefs<T extends Object>(
    Expression<T> Function($$ConversationsTableAnnotationComposer a) f,
  ) {
    final $$ConversationsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.conversations,
      getReferencedColumn: (t) => t.providerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ConversationsTableAnnotationComposer(
            $db: $db,
            $table: $db.conversations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> imageTasksRefs<T extends Object>(
    Expression<T> Function($$ImageTasksTableAnnotationComposer a) f,
  ) {
    final $$ImageTasksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.imageTasks,
      getReferencedColumn: (t) => t.providerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImageTasksTableAnnotationComposer(
            $db: $db,
            $table: $db.imageTasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ProvidersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProvidersTable,
          Provider,
          $$ProvidersTableFilterComposer,
          $$ProvidersTableOrderingComposer,
          $$ProvidersTableAnnotationComposer,
          $$ProvidersTableCreateCompanionBuilder,
          $$ProvidersTableUpdateCompanionBuilder,
          (Provider, $$ProvidersTableReferences),
          Provider,
          PrefetchHooks Function({
            bool tokensRefs,
            bool quotaSnapshotsRefs,
            bool checkinRecordsRefs,
            bool prewarmRecordsRefs,
            bool conversationsRefs,
            bool imageTasksRefs,
          })
        > {
  $$ProvidersTableTableManager(_$AppDatabase db, $ProvidersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProvidersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProvidersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProvidersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<ProviderType> type = const Value.absent(),
                Value<AdapterKind> adapterKind = const Value.absent(),
                Value<String> baseUrl = const Value.absent(),
                Value<String> accountLabel = const Value.absent(),
                Value<String?> systemTokenRef = const Value.absent(),
                Value<String?> systemUserId = const Value.absent(),
                Value<bool> checkinDisabled = const Value.absent(),
                Value<bool> pinned = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<bool> hidden = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProvidersCompanion(
                id: id,
                name: name,
                type: type,
                adapterKind: adapterKind,
                baseUrl: baseUrl,
                accountLabel: accountLabel,
                systemTokenRef: systemTokenRef,
                systemUserId: systemUserId,
                checkinDisabled: checkinDisabled,
                pinned: pinned,
                sortOrder: sortOrder,
                hidden: hidden,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required ProviderType type,
                required AdapterKind adapterKind,
                Value<String> baseUrl = const Value.absent(),
                Value<String> accountLabel = const Value.absent(),
                Value<String?> systemTokenRef = const Value.absent(),
                Value<String?> systemUserId = const Value.absent(),
                Value<bool> checkinDisabled = const Value.absent(),
                Value<bool> pinned = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<bool> hidden = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => ProvidersCompanion.insert(
                id: id,
                name: name,
                type: type,
                adapterKind: adapterKind,
                baseUrl: baseUrl,
                accountLabel: accountLabel,
                systemTokenRef: systemTokenRef,
                systemUserId: systemUserId,
                checkinDisabled: checkinDisabled,
                pinned: pinned,
                sortOrder: sortOrder,
                hidden: hidden,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ProvidersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                tokensRefs = false,
                quotaSnapshotsRefs = false,
                checkinRecordsRefs = false,
                prewarmRecordsRefs = false,
                conversationsRefs = false,
                imageTasksRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (tokensRefs) db.tokens,
                    if (quotaSnapshotsRefs) db.quotaSnapshots,
                    if (checkinRecordsRefs) db.checkinRecords,
                    if (prewarmRecordsRefs) db.prewarmRecords,
                    if (conversationsRefs) db.conversations,
                    if (imageTasksRefs) db.imageTasks,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (tokensRefs)
                        await $_getPrefetchedData<
                          Provider,
                          $ProvidersTable,
                          Token
                        >(
                          currentTable: table,
                          referencedTable: $$ProvidersTableReferences
                              ._tokensRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProvidersTableReferences(
                                db,
                                table,
                                p0,
                              ).tokensRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.providerId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (quotaSnapshotsRefs)
                        await $_getPrefetchedData<
                          Provider,
                          $ProvidersTable,
                          QuotaSnapshot
                        >(
                          currentTable: table,
                          referencedTable: $$ProvidersTableReferences
                              ._quotaSnapshotsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProvidersTableReferences(
                                db,
                                table,
                                p0,
                              ).quotaSnapshotsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.providerId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (checkinRecordsRefs)
                        await $_getPrefetchedData<
                          Provider,
                          $ProvidersTable,
                          CheckinRecord
                        >(
                          currentTable: table,
                          referencedTable: $$ProvidersTableReferences
                              ._checkinRecordsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProvidersTableReferences(
                                db,
                                table,
                                p0,
                              ).checkinRecordsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.providerId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (prewarmRecordsRefs)
                        await $_getPrefetchedData<
                          Provider,
                          $ProvidersTable,
                          PrewarmRecord
                        >(
                          currentTable: table,
                          referencedTable: $$ProvidersTableReferences
                              ._prewarmRecordsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProvidersTableReferences(
                                db,
                                table,
                                p0,
                              ).prewarmRecordsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.providerId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (conversationsRefs)
                        await $_getPrefetchedData<
                          Provider,
                          $ProvidersTable,
                          Conversation
                        >(
                          currentTable: table,
                          referencedTable: $$ProvidersTableReferences
                              ._conversationsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProvidersTableReferences(
                                db,
                                table,
                                p0,
                              ).conversationsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.providerId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (imageTasksRefs)
                        await $_getPrefetchedData<
                          Provider,
                          $ProvidersTable,
                          ImageTask
                        >(
                          currentTable: table,
                          referencedTable: $$ProvidersTableReferences
                              ._imageTasksRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProvidersTableReferences(
                                db,
                                table,
                                p0,
                              ).imageTasksRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.providerId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ProvidersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProvidersTable,
      Provider,
      $$ProvidersTableFilterComposer,
      $$ProvidersTableOrderingComposer,
      $$ProvidersTableAnnotationComposer,
      $$ProvidersTableCreateCompanionBuilder,
      $$ProvidersTableUpdateCompanionBuilder,
      (Provider, $$ProvidersTableReferences),
      Provider,
      PrefetchHooks Function({
        bool tokensRefs,
        bool quotaSnapshotsRefs,
        bool checkinRecordsRefs,
        bool prewarmRecordsRefs,
        bool conversationsRefs,
        bool imageTasksRefs,
      })
    >;
typedef $$TokensTableCreateCompanionBuilder =
    TokensCompanion Function({
      required String id,
      required String providerId,
      Value<String> name,
      required String secretRef,
      Value<String> note,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$TokensTableUpdateCompanionBuilder =
    TokensCompanion Function({
      Value<String> id,
      Value<String> providerId,
      Value<String> name,
      Value<String> secretRef,
      Value<String> note,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$TokensTableReferences
    extends BaseReferences<_$AppDatabase, $TokensTable, Token> {
  $$TokensTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ProvidersTable _providerIdTable(_$AppDatabase db) => db.providers
      .createAlias($_aliasNameGenerator(db.tokens.providerId, db.providers.id));

  $$ProvidersTableProcessedTableManager get providerId {
    final $_column = $_itemColumn<String>('provider_id')!;

    final manager = $$ProvidersTableTableManager(
      $_db,
      $_db.providers,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_providerIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$ProviderModelsTable, List<ProviderModel>>
  _providerModelsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.providerModels,
    aliasName: $_aliasNameGenerator(db.tokens.id, db.providerModels.tokenId),
  );

  $$ProviderModelsTableProcessedTableManager get providerModelsRefs {
    final manager = $$ProviderModelsTableTableManager(
      $_db,
      $_db.providerModels,
    ).filter((f) => f.tokenId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_providerModelsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ModelTestRecordsTable, List<ModelTestRecord>>
  _modelTestRecordsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.modelTestRecords,
    aliasName: $_aliasNameGenerator(db.tokens.id, db.modelTestRecords.tokenId),
  );

  $$ModelTestRecordsTableProcessedTableManager get modelTestRecordsRefs {
    final manager = $$ModelTestRecordsTableTableManager(
      $_db,
      $_db.modelTestRecords,
    ).filter((f) => f.tokenId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _modelTestRecordsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ConversationsTable, List<Conversation>>
  _conversationsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.conversations,
    aliasName: $_aliasNameGenerator(db.tokens.id, db.conversations.tokenId),
  );

  $$ConversationsTableProcessedTableManager get conversationsRefs {
    final manager = $$ConversationsTableTableManager(
      $_db,
      $_db.conversations,
    ).filter((f) => f.tokenId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_conversationsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ImageTasksTable, List<ImageTask>>
  _imageTasksRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.imageTasks,
    aliasName: $_aliasNameGenerator(db.tokens.id, db.imageTasks.tokenId),
  );

  $$ImageTasksTableProcessedTableManager get imageTasksRefs {
    final manager = $$ImageTasksTableTableManager(
      $_db,
      $_db.imageTasks,
    ).filter((f) => f.tokenId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_imageTasksRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TokensTableFilterComposer
    extends Composer<_$AppDatabase, $TokensTable> {
  $$TokensTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get secretRef => $composableBuilder(
    column: $table.secretRef,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ProvidersTableFilterComposer get providerId {
    final $$ProvidersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.providerId,
      referencedTable: $db.providers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProvidersTableFilterComposer(
            $db: $db,
            $table: $db.providers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> providerModelsRefs(
    Expression<bool> Function($$ProviderModelsTableFilterComposer f) f,
  ) {
    final $$ProviderModelsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.providerModels,
      getReferencedColumn: (t) => t.tokenId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProviderModelsTableFilterComposer(
            $db: $db,
            $table: $db.providerModels,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> modelTestRecordsRefs(
    Expression<bool> Function($$ModelTestRecordsTableFilterComposer f) f,
  ) {
    final $$ModelTestRecordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.modelTestRecords,
      getReferencedColumn: (t) => t.tokenId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ModelTestRecordsTableFilterComposer(
            $db: $db,
            $table: $db.modelTestRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> conversationsRefs(
    Expression<bool> Function($$ConversationsTableFilterComposer f) f,
  ) {
    final $$ConversationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.conversations,
      getReferencedColumn: (t) => t.tokenId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ConversationsTableFilterComposer(
            $db: $db,
            $table: $db.conversations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> imageTasksRefs(
    Expression<bool> Function($$ImageTasksTableFilterComposer f) f,
  ) {
    final $$ImageTasksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.imageTasks,
      getReferencedColumn: (t) => t.tokenId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImageTasksTableFilterComposer(
            $db: $db,
            $table: $db.imageTasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TokensTableOrderingComposer
    extends Composer<_$AppDatabase, $TokensTable> {
  $$TokensTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get secretRef => $composableBuilder(
    column: $table.secretRef,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProvidersTableOrderingComposer get providerId {
    final $$ProvidersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.providerId,
      referencedTable: $db.providers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProvidersTableOrderingComposer(
            $db: $db,
            $table: $db.providers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TokensTableAnnotationComposer
    extends Composer<_$AppDatabase, $TokensTable> {
  $$TokensTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get secretRef =>
      $composableBuilder(column: $table.secretRef, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$ProvidersTableAnnotationComposer get providerId {
    final $$ProvidersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.providerId,
      referencedTable: $db.providers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProvidersTableAnnotationComposer(
            $db: $db,
            $table: $db.providers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> providerModelsRefs<T extends Object>(
    Expression<T> Function($$ProviderModelsTableAnnotationComposer a) f,
  ) {
    final $$ProviderModelsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.providerModels,
      getReferencedColumn: (t) => t.tokenId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProviderModelsTableAnnotationComposer(
            $db: $db,
            $table: $db.providerModels,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> modelTestRecordsRefs<T extends Object>(
    Expression<T> Function($$ModelTestRecordsTableAnnotationComposer a) f,
  ) {
    final $$ModelTestRecordsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.modelTestRecords,
      getReferencedColumn: (t) => t.tokenId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ModelTestRecordsTableAnnotationComposer(
            $db: $db,
            $table: $db.modelTestRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> conversationsRefs<T extends Object>(
    Expression<T> Function($$ConversationsTableAnnotationComposer a) f,
  ) {
    final $$ConversationsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.conversations,
      getReferencedColumn: (t) => t.tokenId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ConversationsTableAnnotationComposer(
            $db: $db,
            $table: $db.conversations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> imageTasksRefs<T extends Object>(
    Expression<T> Function($$ImageTasksTableAnnotationComposer a) f,
  ) {
    final $$ImageTasksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.imageTasks,
      getReferencedColumn: (t) => t.tokenId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImageTasksTableAnnotationComposer(
            $db: $db,
            $table: $db.imageTasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TokensTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TokensTable,
          Token,
          $$TokensTableFilterComposer,
          $$TokensTableOrderingComposer,
          $$TokensTableAnnotationComposer,
          $$TokensTableCreateCompanionBuilder,
          $$TokensTableUpdateCompanionBuilder,
          (Token, $$TokensTableReferences),
          Token,
          PrefetchHooks Function({
            bool providerId,
            bool providerModelsRefs,
            bool modelTestRecordsRefs,
            bool conversationsRefs,
            bool imageTasksRefs,
          })
        > {
  $$TokensTableTableManager(_$AppDatabase db, $TokensTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TokensTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TokensTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TokensTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> providerId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> secretRef = const Value.absent(),
                Value<String> note = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TokensCompanion(
                id: id,
                providerId: providerId,
                name: name,
                secretRef: secretRef,
                note: note,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String providerId,
                Value<String> name = const Value.absent(),
                required String secretRef,
                Value<String> note = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => TokensCompanion.insert(
                id: id,
                providerId: providerId,
                name: name,
                secretRef: secretRef,
                note: note,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$TokensTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                providerId = false,
                providerModelsRefs = false,
                modelTestRecordsRefs = false,
                conversationsRefs = false,
                imageTasksRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (providerModelsRefs) db.providerModels,
                    if (modelTestRecordsRefs) db.modelTestRecords,
                    if (conversationsRefs) db.conversations,
                    if (imageTasksRefs) db.imageTasks,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (providerId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.providerId,
                                    referencedTable: $$TokensTableReferences
                                        ._providerIdTable(db),
                                    referencedColumn: $$TokensTableReferences
                                        ._providerIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (providerModelsRefs)
                        await $_getPrefetchedData<
                          Token,
                          $TokensTable,
                          ProviderModel
                        >(
                          currentTable: table,
                          referencedTable: $$TokensTableReferences
                              ._providerModelsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TokensTableReferences(
                                db,
                                table,
                                p0,
                              ).providerModelsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.tokenId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (modelTestRecordsRefs)
                        await $_getPrefetchedData<
                          Token,
                          $TokensTable,
                          ModelTestRecord
                        >(
                          currentTable: table,
                          referencedTable: $$TokensTableReferences
                              ._modelTestRecordsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TokensTableReferences(
                                db,
                                table,
                                p0,
                              ).modelTestRecordsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.tokenId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (conversationsRefs)
                        await $_getPrefetchedData<
                          Token,
                          $TokensTable,
                          Conversation
                        >(
                          currentTable: table,
                          referencedTable: $$TokensTableReferences
                              ._conversationsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TokensTableReferences(
                                db,
                                table,
                                p0,
                              ).conversationsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.tokenId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (imageTasksRefs)
                        await $_getPrefetchedData<
                          Token,
                          $TokensTable,
                          ImageTask
                        >(
                          currentTable: table,
                          referencedTable: $$TokensTableReferences
                              ._imageTasksRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TokensTableReferences(
                                db,
                                table,
                                p0,
                              ).imageTasksRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.tokenId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$TokensTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TokensTable,
      Token,
      $$TokensTableFilterComposer,
      $$TokensTableOrderingComposer,
      $$TokensTableAnnotationComposer,
      $$TokensTableCreateCompanionBuilder,
      $$TokensTableUpdateCompanionBuilder,
      (Token, $$TokensTableReferences),
      Token,
      PrefetchHooks Function({
        bool providerId,
        bool providerModelsRefs,
        bool modelTestRecordsRefs,
        bool conversationsRefs,
        bool imageTasksRefs,
      })
    >;
typedef $$ProviderModelsTableCreateCompanionBuilder =
    ProviderModelsCompanion Function({
      required String id,
      required String tokenId,
      required String modelId,
      Value<String> displayName,
      Value<bool> enabled,
      Value<DateTime?> lastTestAt,
      Value<String?> lastTestStatus,
      Value<int?> lastTestLatencyMs,
      Value<int> rowid,
    });
typedef $$ProviderModelsTableUpdateCompanionBuilder =
    ProviderModelsCompanion Function({
      Value<String> id,
      Value<String> tokenId,
      Value<String> modelId,
      Value<String> displayName,
      Value<bool> enabled,
      Value<DateTime?> lastTestAt,
      Value<String?> lastTestStatus,
      Value<int?> lastTestLatencyMs,
      Value<int> rowid,
    });

final class $$ProviderModelsTableReferences
    extends BaseReferences<_$AppDatabase, $ProviderModelsTable, ProviderModel> {
  $$ProviderModelsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $TokensTable _tokenIdTable(_$AppDatabase db) => db.tokens.createAlias(
    $_aliasNameGenerator(db.providerModels.tokenId, db.tokens.id),
  );

  $$TokensTableProcessedTableManager get tokenId {
    final $_column = $_itemColumn<String>('token_id')!;

    final manager = $$TokensTableTableManager(
      $_db,
      $_db.tokens,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_tokenIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ProviderModelsTableFilterComposer
    extends Composer<_$AppDatabase, $ProviderModelsTable> {
  $$ProviderModelsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get modelId => $composableBuilder(
    column: $table.modelId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastTestAt => $composableBuilder(
    column: $table.lastTestAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastTestStatus => $composableBuilder(
    column: $table.lastTestStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastTestLatencyMs => $composableBuilder(
    column: $table.lastTestLatencyMs,
    builder: (column) => ColumnFilters(column),
  );

  $$TokensTableFilterComposer get tokenId {
    final $$TokensTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tokenId,
      referencedTable: $db.tokens,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TokensTableFilterComposer(
            $db: $db,
            $table: $db.tokens,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProviderModelsTableOrderingComposer
    extends Composer<_$AppDatabase, $ProviderModelsTable> {
  $$ProviderModelsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get modelId => $composableBuilder(
    column: $table.modelId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastTestAt => $composableBuilder(
    column: $table.lastTestAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastTestStatus => $composableBuilder(
    column: $table.lastTestStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastTestLatencyMs => $composableBuilder(
    column: $table.lastTestLatencyMs,
    builder: (column) => ColumnOrderings(column),
  );

  $$TokensTableOrderingComposer get tokenId {
    final $$TokensTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tokenId,
      referencedTable: $db.tokens,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TokensTableOrderingComposer(
            $db: $db,
            $table: $db.tokens,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProviderModelsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProviderModelsTable> {
  $$ProviderModelsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get modelId =>
      $composableBuilder(column: $table.modelId, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get enabled =>
      $composableBuilder(column: $table.enabled, builder: (column) => column);

  GeneratedColumn<DateTime> get lastTestAt => $composableBuilder(
    column: $table.lastTestAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastTestStatus => $composableBuilder(
    column: $table.lastTestStatus,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastTestLatencyMs => $composableBuilder(
    column: $table.lastTestLatencyMs,
    builder: (column) => column,
  );

  $$TokensTableAnnotationComposer get tokenId {
    final $$TokensTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tokenId,
      referencedTable: $db.tokens,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TokensTableAnnotationComposer(
            $db: $db,
            $table: $db.tokens,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProviderModelsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProviderModelsTable,
          ProviderModel,
          $$ProviderModelsTableFilterComposer,
          $$ProviderModelsTableOrderingComposer,
          $$ProviderModelsTableAnnotationComposer,
          $$ProviderModelsTableCreateCompanionBuilder,
          $$ProviderModelsTableUpdateCompanionBuilder,
          (ProviderModel, $$ProviderModelsTableReferences),
          ProviderModel,
          PrefetchHooks Function({bool tokenId})
        > {
  $$ProviderModelsTableTableManager(
    _$AppDatabase db,
    $ProviderModelsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProviderModelsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProviderModelsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProviderModelsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> tokenId = const Value.absent(),
                Value<String> modelId = const Value.absent(),
                Value<String> displayName = const Value.absent(),
                Value<bool> enabled = const Value.absent(),
                Value<DateTime?> lastTestAt = const Value.absent(),
                Value<String?> lastTestStatus = const Value.absent(),
                Value<int?> lastTestLatencyMs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProviderModelsCompanion(
                id: id,
                tokenId: tokenId,
                modelId: modelId,
                displayName: displayName,
                enabled: enabled,
                lastTestAt: lastTestAt,
                lastTestStatus: lastTestStatus,
                lastTestLatencyMs: lastTestLatencyMs,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String tokenId,
                required String modelId,
                Value<String> displayName = const Value.absent(),
                Value<bool> enabled = const Value.absent(),
                Value<DateTime?> lastTestAt = const Value.absent(),
                Value<String?> lastTestStatus = const Value.absent(),
                Value<int?> lastTestLatencyMs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProviderModelsCompanion.insert(
                id: id,
                tokenId: tokenId,
                modelId: modelId,
                displayName: displayName,
                enabled: enabled,
                lastTestAt: lastTestAt,
                lastTestStatus: lastTestStatus,
                lastTestLatencyMs: lastTestLatencyMs,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ProviderModelsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({tokenId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (tokenId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.tokenId,
                                referencedTable: $$ProviderModelsTableReferences
                                    ._tokenIdTable(db),
                                referencedColumn:
                                    $$ProviderModelsTableReferences
                                        ._tokenIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ProviderModelsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProviderModelsTable,
      ProviderModel,
      $$ProviderModelsTableFilterComposer,
      $$ProviderModelsTableOrderingComposer,
      $$ProviderModelsTableAnnotationComposer,
      $$ProviderModelsTableCreateCompanionBuilder,
      $$ProviderModelsTableUpdateCompanionBuilder,
      (ProviderModel, $$ProviderModelsTableReferences),
      ProviderModel,
      PrefetchHooks Function({bool tokenId})
    >;
typedef $$QuotaSnapshotsTableCreateCompanionBuilder =
    QuotaSnapshotsCompanion Function({
      Value<int> id,
      required String providerId,
      required DateTime timestamp,
      required QuotaKind kind,
      Value<double?> ratio,
      Value<double?> remaining,
      Value<double?> total,
      Value<double?> amount,
      Value<String?> currency,
      Value<DateTime?> resetAt,
      Value<String> source,
      required bool success,
      Value<String?> message,
    });
typedef $$QuotaSnapshotsTableUpdateCompanionBuilder =
    QuotaSnapshotsCompanion Function({
      Value<int> id,
      Value<String> providerId,
      Value<DateTime> timestamp,
      Value<QuotaKind> kind,
      Value<double?> ratio,
      Value<double?> remaining,
      Value<double?> total,
      Value<double?> amount,
      Value<String?> currency,
      Value<DateTime?> resetAt,
      Value<String> source,
      Value<bool> success,
      Value<String?> message,
    });

final class $$QuotaSnapshotsTableReferences
    extends BaseReferences<_$AppDatabase, $QuotaSnapshotsTable, QuotaSnapshot> {
  $$QuotaSnapshotsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ProvidersTable _providerIdTable(_$AppDatabase db) =>
      db.providers.createAlias(
        $_aliasNameGenerator(db.quotaSnapshots.providerId, db.providers.id),
      );

  $$ProvidersTableProcessedTableManager get providerId {
    final $_column = $_itemColumn<String>('provider_id')!;

    final manager = $$ProvidersTableTableManager(
      $_db,
      $_db.providers,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_providerIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$QuotaSnapshotsTableFilterComposer
    extends Composer<_$AppDatabase, $QuotaSnapshotsTable> {
  $$QuotaSnapshotsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<QuotaKind, QuotaKind, int> get kind =>
      $composableBuilder(
        column: $table.kind,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<double> get ratio => $composableBuilder(
    column: $table.ratio,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get remaining => $composableBuilder(
    column: $table.remaining,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get total => $composableBuilder(
    column: $table.total,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get resetAt => $composableBuilder(
    column: $table.resetAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get success => $composableBuilder(
    column: $table.success,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get message => $composableBuilder(
    column: $table.message,
    builder: (column) => ColumnFilters(column),
  );

  $$ProvidersTableFilterComposer get providerId {
    final $$ProvidersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.providerId,
      referencedTable: $db.providers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProvidersTableFilterComposer(
            $db: $db,
            $table: $db.providers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$QuotaSnapshotsTableOrderingComposer
    extends Composer<_$AppDatabase, $QuotaSnapshotsTable> {
  $$QuotaSnapshotsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get ratio => $composableBuilder(
    column: $table.ratio,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get remaining => $composableBuilder(
    column: $table.remaining,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get total => $composableBuilder(
    column: $table.total,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get resetAt => $composableBuilder(
    column: $table.resetAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get success => $composableBuilder(
    column: $table.success,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get message => $composableBuilder(
    column: $table.message,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProvidersTableOrderingComposer get providerId {
    final $$ProvidersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.providerId,
      referencedTable: $db.providers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProvidersTableOrderingComposer(
            $db: $db,
            $table: $db.providers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$QuotaSnapshotsTableAnnotationComposer
    extends Composer<_$AppDatabase, $QuotaSnapshotsTable> {
  $$QuotaSnapshotsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumnWithTypeConverter<QuotaKind, int> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<double> get ratio =>
      $composableBuilder(column: $table.ratio, builder: (column) => column);

  GeneratedColumn<double> get remaining =>
      $composableBuilder(column: $table.remaining, builder: (column) => column);

  GeneratedColumn<double> get total =>
      $composableBuilder(column: $table.total, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<DateTime> get resetAt =>
      $composableBuilder(column: $table.resetAt, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<bool> get success =>
      $composableBuilder(column: $table.success, builder: (column) => column);

  GeneratedColumn<String> get message =>
      $composableBuilder(column: $table.message, builder: (column) => column);

  $$ProvidersTableAnnotationComposer get providerId {
    final $$ProvidersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.providerId,
      referencedTable: $db.providers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProvidersTableAnnotationComposer(
            $db: $db,
            $table: $db.providers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$QuotaSnapshotsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $QuotaSnapshotsTable,
          QuotaSnapshot,
          $$QuotaSnapshotsTableFilterComposer,
          $$QuotaSnapshotsTableOrderingComposer,
          $$QuotaSnapshotsTableAnnotationComposer,
          $$QuotaSnapshotsTableCreateCompanionBuilder,
          $$QuotaSnapshotsTableUpdateCompanionBuilder,
          (QuotaSnapshot, $$QuotaSnapshotsTableReferences),
          QuotaSnapshot,
          PrefetchHooks Function({bool providerId})
        > {
  $$QuotaSnapshotsTableTableManager(
    _$AppDatabase db,
    $QuotaSnapshotsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$QuotaSnapshotsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$QuotaSnapshotsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$QuotaSnapshotsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> providerId = const Value.absent(),
                Value<DateTime> timestamp = const Value.absent(),
                Value<QuotaKind> kind = const Value.absent(),
                Value<double?> ratio = const Value.absent(),
                Value<double?> remaining = const Value.absent(),
                Value<double?> total = const Value.absent(),
                Value<double?> amount = const Value.absent(),
                Value<String?> currency = const Value.absent(),
                Value<DateTime?> resetAt = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<bool> success = const Value.absent(),
                Value<String?> message = const Value.absent(),
              }) => QuotaSnapshotsCompanion(
                id: id,
                providerId: providerId,
                timestamp: timestamp,
                kind: kind,
                ratio: ratio,
                remaining: remaining,
                total: total,
                amount: amount,
                currency: currency,
                resetAt: resetAt,
                source: source,
                success: success,
                message: message,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String providerId,
                required DateTime timestamp,
                required QuotaKind kind,
                Value<double?> ratio = const Value.absent(),
                Value<double?> remaining = const Value.absent(),
                Value<double?> total = const Value.absent(),
                Value<double?> amount = const Value.absent(),
                Value<String?> currency = const Value.absent(),
                Value<DateTime?> resetAt = const Value.absent(),
                Value<String> source = const Value.absent(),
                required bool success,
                Value<String?> message = const Value.absent(),
              }) => QuotaSnapshotsCompanion.insert(
                id: id,
                providerId: providerId,
                timestamp: timestamp,
                kind: kind,
                ratio: ratio,
                remaining: remaining,
                total: total,
                amount: amount,
                currency: currency,
                resetAt: resetAt,
                source: source,
                success: success,
                message: message,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$QuotaSnapshotsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({providerId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (providerId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.providerId,
                                referencedTable: $$QuotaSnapshotsTableReferences
                                    ._providerIdTable(db),
                                referencedColumn:
                                    $$QuotaSnapshotsTableReferences
                                        ._providerIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$QuotaSnapshotsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $QuotaSnapshotsTable,
      QuotaSnapshot,
      $$QuotaSnapshotsTableFilterComposer,
      $$QuotaSnapshotsTableOrderingComposer,
      $$QuotaSnapshotsTableAnnotationComposer,
      $$QuotaSnapshotsTableCreateCompanionBuilder,
      $$QuotaSnapshotsTableUpdateCompanionBuilder,
      (QuotaSnapshot, $$QuotaSnapshotsTableReferences),
      QuotaSnapshot,
      PrefetchHooks Function({bool providerId})
    >;
typedef $$ModelTestRecordsTableCreateCompanionBuilder =
    ModelTestRecordsCompanion Function({
      Value<int> id,
      required String tokenId,
      required String modelId,
      required bool success,
      Value<String?> errorType,
      Value<int?> httpStatus,
      Value<int?> latencyMs,
      Value<String?> message,
      required DateTime createdAt,
    });
typedef $$ModelTestRecordsTableUpdateCompanionBuilder =
    ModelTestRecordsCompanion Function({
      Value<int> id,
      Value<String> tokenId,
      Value<String> modelId,
      Value<bool> success,
      Value<String?> errorType,
      Value<int?> httpStatus,
      Value<int?> latencyMs,
      Value<String?> message,
      Value<DateTime> createdAt,
    });

final class $$ModelTestRecordsTableReferences
    extends
        BaseReferences<_$AppDatabase, $ModelTestRecordsTable, ModelTestRecord> {
  $$ModelTestRecordsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $TokensTable _tokenIdTable(_$AppDatabase db) => db.tokens.createAlias(
    $_aliasNameGenerator(db.modelTestRecords.tokenId, db.tokens.id),
  );

  $$TokensTableProcessedTableManager get tokenId {
    final $_column = $_itemColumn<String>('token_id')!;

    final manager = $$TokensTableTableManager(
      $_db,
      $_db.tokens,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_tokenIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ModelTestRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $ModelTestRecordsTable> {
  $$ModelTestRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get modelId => $composableBuilder(
    column: $table.modelId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get success => $composableBuilder(
    column: $table.success,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get errorType => $composableBuilder(
    column: $table.errorType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get httpStatus => $composableBuilder(
    column: $table.httpStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get latencyMs => $composableBuilder(
    column: $table.latencyMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get message => $composableBuilder(
    column: $table.message,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$TokensTableFilterComposer get tokenId {
    final $$TokensTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tokenId,
      referencedTable: $db.tokens,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TokensTableFilterComposer(
            $db: $db,
            $table: $db.tokens,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ModelTestRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $ModelTestRecordsTable> {
  $$ModelTestRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get modelId => $composableBuilder(
    column: $table.modelId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get success => $composableBuilder(
    column: $table.success,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get errorType => $composableBuilder(
    column: $table.errorType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get httpStatus => $composableBuilder(
    column: $table.httpStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get latencyMs => $composableBuilder(
    column: $table.latencyMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get message => $composableBuilder(
    column: $table.message,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$TokensTableOrderingComposer get tokenId {
    final $$TokensTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tokenId,
      referencedTable: $db.tokens,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TokensTableOrderingComposer(
            $db: $db,
            $table: $db.tokens,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ModelTestRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ModelTestRecordsTable> {
  $$ModelTestRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get modelId =>
      $composableBuilder(column: $table.modelId, builder: (column) => column);

  GeneratedColumn<bool> get success =>
      $composableBuilder(column: $table.success, builder: (column) => column);

  GeneratedColumn<String> get errorType =>
      $composableBuilder(column: $table.errorType, builder: (column) => column);

  GeneratedColumn<int> get httpStatus => $composableBuilder(
    column: $table.httpStatus,
    builder: (column) => column,
  );

  GeneratedColumn<int> get latencyMs =>
      $composableBuilder(column: $table.latencyMs, builder: (column) => column);

  GeneratedColumn<String> get message =>
      $composableBuilder(column: $table.message, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$TokensTableAnnotationComposer get tokenId {
    final $$TokensTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tokenId,
      referencedTable: $db.tokens,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TokensTableAnnotationComposer(
            $db: $db,
            $table: $db.tokens,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ModelTestRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ModelTestRecordsTable,
          ModelTestRecord,
          $$ModelTestRecordsTableFilterComposer,
          $$ModelTestRecordsTableOrderingComposer,
          $$ModelTestRecordsTableAnnotationComposer,
          $$ModelTestRecordsTableCreateCompanionBuilder,
          $$ModelTestRecordsTableUpdateCompanionBuilder,
          (ModelTestRecord, $$ModelTestRecordsTableReferences),
          ModelTestRecord,
          PrefetchHooks Function({bool tokenId})
        > {
  $$ModelTestRecordsTableTableManager(
    _$AppDatabase db,
    $ModelTestRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ModelTestRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ModelTestRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ModelTestRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> tokenId = const Value.absent(),
                Value<String> modelId = const Value.absent(),
                Value<bool> success = const Value.absent(),
                Value<String?> errorType = const Value.absent(),
                Value<int?> httpStatus = const Value.absent(),
                Value<int?> latencyMs = const Value.absent(),
                Value<String?> message = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => ModelTestRecordsCompanion(
                id: id,
                tokenId: tokenId,
                modelId: modelId,
                success: success,
                errorType: errorType,
                httpStatus: httpStatus,
                latencyMs: latencyMs,
                message: message,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String tokenId,
                required String modelId,
                required bool success,
                Value<String?> errorType = const Value.absent(),
                Value<int?> httpStatus = const Value.absent(),
                Value<int?> latencyMs = const Value.absent(),
                Value<String?> message = const Value.absent(),
                required DateTime createdAt,
              }) => ModelTestRecordsCompanion.insert(
                id: id,
                tokenId: tokenId,
                modelId: modelId,
                success: success,
                errorType: errorType,
                httpStatus: httpStatus,
                latencyMs: latencyMs,
                message: message,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ModelTestRecordsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({tokenId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (tokenId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.tokenId,
                                referencedTable:
                                    $$ModelTestRecordsTableReferences
                                        ._tokenIdTable(db),
                                referencedColumn:
                                    $$ModelTestRecordsTableReferences
                                        ._tokenIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ModelTestRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ModelTestRecordsTable,
      ModelTestRecord,
      $$ModelTestRecordsTableFilterComposer,
      $$ModelTestRecordsTableOrderingComposer,
      $$ModelTestRecordsTableAnnotationComposer,
      $$ModelTestRecordsTableCreateCompanionBuilder,
      $$ModelTestRecordsTableUpdateCompanionBuilder,
      (ModelTestRecord, $$ModelTestRecordsTableReferences),
      ModelTestRecord,
      PrefetchHooks Function({bool tokenId})
    >;
typedef $$CheckinRecordsTableCreateCompanionBuilder =
    CheckinRecordsCompanion Function({
      Value<int> id,
      required String providerId,
      required bool success,
      Value<String?> message,
      required DateTime createdAt,
    });
typedef $$CheckinRecordsTableUpdateCompanionBuilder =
    CheckinRecordsCompanion Function({
      Value<int> id,
      Value<String> providerId,
      Value<bool> success,
      Value<String?> message,
      Value<DateTime> createdAt,
    });

final class $$CheckinRecordsTableReferences
    extends BaseReferences<_$AppDatabase, $CheckinRecordsTable, CheckinRecord> {
  $$CheckinRecordsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ProvidersTable _providerIdTable(_$AppDatabase db) =>
      db.providers.createAlias(
        $_aliasNameGenerator(db.checkinRecords.providerId, db.providers.id),
      );

  $$ProvidersTableProcessedTableManager get providerId {
    final $_column = $_itemColumn<String>('provider_id')!;

    final manager = $$ProvidersTableTableManager(
      $_db,
      $_db.providers,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_providerIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CheckinRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $CheckinRecordsTable> {
  $$CheckinRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get success => $composableBuilder(
    column: $table.success,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get message => $composableBuilder(
    column: $table.message,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ProvidersTableFilterComposer get providerId {
    final $$ProvidersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.providerId,
      referencedTable: $db.providers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProvidersTableFilterComposer(
            $db: $db,
            $table: $db.providers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CheckinRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $CheckinRecordsTable> {
  $$CheckinRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get success => $composableBuilder(
    column: $table.success,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get message => $composableBuilder(
    column: $table.message,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProvidersTableOrderingComposer get providerId {
    final $$ProvidersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.providerId,
      referencedTable: $db.providers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProvidersTableOrderingComposer(
            $db: $db,
            $table: $db.providers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CheckinRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CheckinRecordsTable> {
  $$CheckinRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<bool> get success =>
      $composableBuilder(column: $table.success, builder: (column) => column);

  GeneratedColumn<String> get message =>
      $composableBuilder(column: $table.message, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$ProvidersTableAnnotationComposer get providerId {
    final $$ProvidersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.providerId,
      referencedTable: $db.providers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProvidersTableAnnotationComposer(
            $db: $db,
            $table: $db.providers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CheckinRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CheckinRecordsTable,
          CheckinRecord,
          $$CheckinRecordsTableFilterComposer,
          $$CheckinRecordsTableOrderingComposer,
          $$CheckinRecordsTableAnnotationComposer,
          $$CheckinRecordsTableCreateCompanionBuilder,
          $$CheckinRecordsTableUpdateCompanionBuilder,
          (CheckinRecord, $$CheckinRecordsTableReferences),
          CheckinRecord,
          PrefetchHooks Function({bool providerId})
        > {
  $$CheckinRecordsTableTableManager(
    _$AppDatabase db,
    $CheckinRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CheckinRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CheckinRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CheckinRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> providerId = const Value.absent(),
                Value<bool> success = const Value.absent(),
                Value<String?> message = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => CheckinRecordsCompanion(
                id: id,
                providerId: providerId,
                success: success,
                message: message,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String providerId,
                required bool success,
                Value<String?> message = const Value.absent(),
                required DateTime createdAt,
              }) => CheckinRecordsCompanion.insert(
                id: id,
                providerId: providerId,
                success: success,
                message: message,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CheckinRecordsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({providerId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (providerId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.providerId,
                                referencedTable: $$CheckinRecordsTableReferences
                                    ._providerIdTable(db),
                                referencedColumn:
                                    $$CheckinRecordsTableReferences
                                        ._providerIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$CheckinRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CheckinRecordsTable,
      CheckinRecord,
      $$CheckinRecordsTableFilterComposer,
      $$CheckinRecordsTableOrderingComposer,
      $$CheckinRecordsTableAnnotationComposer,
      $$CheckinRecordsTableCreateCompanionBuilder,
      $$CheckinRecordsTableUpdateCompanionBuilder,
      (CheckinRecord, $$CheckinRecordsTableReferences),
      CheckinRecord,
      PrefetchHooks Function({bool providerId})
    >;
typedef $$PrewarmRecordsTableCreateCompanionBuilder =
    PrewarmRecordsCompanion Function({
      Value<int> id,
      required String providerId,
      required String status,
      Value<String?> message,
      required DateTime createdAt,
    });
typedef $$PrewarmRecordsTableUpdateCompanionBuilder =
    PrewarmRecordsCompanion Function({
      Value<int> id,
      Value<String> providerId,
      Value<String> status,
      Value<String?> message,
      Value<DateTime> createdAt,
    });

final class $$PrewarmRecordsTableReferences
    extends BaseReferences<_$AppDatabase, $PrewarmRecordsTable, PrewarmRecord> {
  $$PrewarmRecordsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ProvidersTable _providerIdTable(_$AppDatabase db) =>
      db.providers.createAlias(
        $_aliasNameGenerator(db.prewarmRecords.providerId, db.providers.id),
      );

  $$ProvidersTableProcessedTableManager get providerId {
    final $_column = $_itemColumn<String>('provider_id')!;

    final manager = $$ProvidersTableTableManager(
      $_db,
      $_db.providers,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_providerIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PrewarmRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $PrewarmRecordsTable> {
  $$PrewarmRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get message => $composableBuilder(
    column: $table.message,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ProvidersTableFilterComposer get providerId {
    final $$ProvidersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.providerId,
      referencedTable: $db.providers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProvidersTableFilterComposer(
            $db: $db,
            $table: $db.providers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PrewarmRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $PrewarmRecordsTable> {
  $$PrewarmRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get message => $composableBuilder(
    column: $table.message,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProvidersTableOrderingComposer get providerId {
    final $$ProvidersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.providerId,
      referencedTable: $db.providers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProvidersTableOrderingComposer(
            $db: $db,
            $table: $db.providers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PrewarmRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PrewarmRecordsTable> {
  $$PrewarmRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get message =>
      $composableBuilder(column: $table.message, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$ProvidersTableAnnotationComposer get providerId {
    final $$ProvidersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.providerId,
      referencedTable: $db.providers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProvidersTableAnnotationComposer(
            $db: $db,
            $table: $db.providers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PrewarmRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PrewarmRecordsTable,
          PrewarmRecord,
          $$PrewarmRecordsTableFilterComposer,
          $$PrewarmRecordsTableOrderingComposer,
          $$PrewarmRecordsTableAnnotationComposer,
          $$PrewarmRecordsTableCreateCompanionBuilder,
          $$PrewarmRecordsTableUpdateCompanionBuilder,
          (PrewarmRecord, $$PrewarmRecordsTableReferences),
          PrewarmRecord,
          PrefetchHooks Function({bool providerId})
        > {
  $$PrewarmRecordsTableTableManager(
    _$AppDatabase db,
    $PrewarmRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PrewarmRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PrewarmRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PrewarmRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> providerId = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> message = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => PrewarmRecordsCompanion(
                id: id,
                providerId: providerId,
                status: status,
                message: message,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String providerId,
                required String status,
                Value<String?> message = const Value.absent(),
                required DateTime createdAt,
              }) => PrewarmRecordsCompanion.insert(
                id: id,
                providerId: providerId,
                status: status,
                message: message,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PrewarmRecordsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({providerId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (providerId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.providerId,
                                referencedTable: $$PrewarmRecordsTableReferences
                                    ._providerIdTable(db),
                                referencedColumn:
                                    $$PrewarmRecordsTableReferences
                                        ._providerIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$PrewarmRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PrewarmRecordsTable,
      PrewarmRecord,
      $$PrewarmRecordsTableFilterComposer,
      $$PrewarmRecordsTableOrderingComposer,
      $$PrewarmRecordsTableAnnotationComposer,
      $$PrewarmRecordsTableCreateCompanionBuilder,
      $$PrewarmRecordsTableUpdateCompanionBuilder,
      (PrewarmRecord, $$PrewarmRecordsTableReferences),
      PrewarmRecord,
      PrefetchHooks Function({bool providerId})
    >;
typedef $$WebdavConfigsTableCreateCompanionBuilder =
    WebdavConfigsCompanion Function({
      Value<int> id,
      required String url,
      required String username,
      required String passwordRef,
      Value<String> remotePath,
      Value<bool> includeSecrets,
      required String deviceId,
      Value<DateTime?> lastSyncedAt,
      required DateTime updatedAt,
    });
typedef $$WebdavConfigsTableUpdateCompanionBuilder =
    WebdavConfigsCompanion Function({
      Value<int> id,
      Value<String> url,
      Value<String> username,
      Value<String> passwordRef,
      Value<String> remotePath,
      Value<bool> includeSecrets,
      Value<String> deviceId,
      Value<DateTime?> lastSyncedAt,
      Value<DateTime> updatedAt,
    });

class $$WebdavConfigsTableFilterComposer
    extends Composer<_$AppDatabase, $WebdavConfigsTable> {
  $$WebdavConfigsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get username => $composableBuilder(
    column: $table.username,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get passwordRef => $composableBuilder(
    column: $table.passwordRef,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get remotePath => $composableBuilder(
    column: $table.remotePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get includeSecrets => $composableBuilder(
    column: $table.includeSecrets,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WebdavConfigsTableOrderingComposer
    extends Composer<_$AppDatabase, $WebdavConfigsTable> {
  $$WebdavConfigsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get username => $composableBuilder(
    column: $table.username,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get passwordRef => $composableBuilder(
    column: $table.passwordRef,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get remotePath => $composableBuilder(
    column: $table.remotePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get includeSecrets => $composableBuilder(
    column: $table.includeSecrets,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WebdavConfigsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WebdavConfigsTable> {
  $$WebdavConfigsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<String> get username =>
      $composableBuilder(column: $table.username, builder: (column) => column);

  GeneratedColumn<String> get passwordRef => $composableBuilder(
    column: $table.passwordRef,
    builder: (column) => column,
  );

  GeneratedColumn<String> get remotePath => $composableBuilder(
    column: $table.remotePath,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get includeSecrets => $composableBuilder(
    column: $table.includeSecrets,
    builder: (column) => column,
  );

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$WebdavConfigsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WebdavConfigsTable,
          WebdavConfig,
          $$WebdavConfigsTableFilterComposer,
          $$WebdavConfigsTableOrderingComposer,
          $$WebdavConfigsTableAnnotationComposer,
          $$WebdavConfigsTableCreateCompanionBuilder,
          $$WebdavConfigsTableUpdateCompanionBuilder,
          (
            WebdavConfig,
            BaseReferences<_$AppDatabase, $WebdavConfigsTable, WebdavConfig>,
          ),
          WebdavConfig,
          PrefetchHooks Function()
        > {
  $$WebdavConfigsTableTableManager(_$AppDatabase db, $WebdavConfigsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WebdavConfigsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WebdavConfigsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WebdavConfigsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> url = const Value.absent(),
                Value<String> username = const Value.absent(),
                Value<String> passwordRef = const Value.absent(),
                Value<String> remotePath = const Value.absent(),
                Value<bool> includeSecrets = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<DateTime?> lastSyncedAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => WebdavConfigsCompanion(
                id: id,
                url: url,
                username: username,
                passwordRef: passwordRef,
                remotePath: remotePath,
                includeSecrets: includeSecrets,
                deviceId: deviceId,
                lastSyncedAt: lastSyncedAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String url,
                required String username,
                required String passwordRef,
                Value<String> remotePath = const Value.absent(),
                Value<bool> includeSecrets = const Value.absent(),
                required String deviceId,
                Value<DateTime?> lastSyncedAt = const Value.absent(),
                required DateTime updatedAt,
              }) => WebdavConfigsCompanion.insert(
                id: id,
                url: url,
                username: username,
                passwordRef: passwordRef,
                remotePath: remotePath,
                includeSecrets: includeSecrets,
                deviceId: deviceId,
                lastSyncedAt: lastSyncedAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WebdavConfigsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WebdavConfigsTable,
      WebdavConfig,
      $$WebdavConfigsTableFilterComposer,
      $$WebdavConfigsTableOrderingComposer,
      $$WebdavConfigsTableAnnotationComposer,
      $$WebdavConfigsTableCreateCompanionBuilder,
      $$WebdavConfigsTableUpdateCompanionBuilder,
      (
        WebdavConfig,
        BaseReferences<_$AppDatabase, $WebdavConfigsTable, WebdavConfig>,
      ),
      WebdavConfig,
      PrefetchHooks Function()
    >;
typedef $$ConversationsTableCreateCompanionBuilder =
    ConversationsCompanion Function({
      required String id,
      Value<String> title,
      required String providerId,
      required String tokenId,
      required String model,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$ConversationsTableUpdateCompanionBuilder =
    ConversationsCompanion Function({
      Value<String> id,
      Value<String> title,
      Value<String> providerId,
      Value<String> tokenId,
      Value<String> model,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$ConversationsTableReferences
    extends BaseReferences<_$AppDatabase, $ConversationsTable, Conversation> {
  $$ConversationsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ProvidersTable _providerIdTable(_$AppDatabase db) =>
      db.providers.createAlias(
        $_aliasNameGenerator(db.conversations.providerId, db.providers.id),
      );

  $$ProvidersTableProcessedTableManager get providerId {
    final $_column = $_itemColumn<String>('provider_id')!;

    final manager = $$ProvidersTableTableManager(
      $_db,
      $_db.providers,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_providerIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $TokensTable _tokenIdTable(_$AppDatabase db) => db.tokens.createAlias(
    $_aliasNameGenerator(db.conversations.tokenId, db.tokens.id),
  );

  $$TokensTableProcessedTableManager get tokenId {
    final $_column = $_itemColumn<String>('token_id')!;

    final manager = $$TokensTableTableManager(
      $_db,
      $_db.tokens,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_tokenIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$MessagesTable, List<Message>> _messagesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.messages,
    aliasName: $_aliasNameGenerator(
      db.conversations.id,
      db.messages.conversationId,
    ),
  );

  $$MessagesTableProcessedTableManager get messagesRefs {
    final manager = $$MessagesTableTableManager(
      $_db,
      $_db.messages,
    ).filter((f) => f.conversationId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_messagesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ConversationsTableFilterComposer
    extends Composer<_$AppDatabase, $ConversationsTable> {
  $$ConversationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get model => $composableBuilder(
    column: $table.model,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ProvidersTableFilterComposer get providerId {
    final $$ProvidersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.providerId,
      referencedTable: $db.providers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProvidersTableFilterComposer(
            $db: $db,
            $table: $db.providers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TokensTableFilterComposer get tokenId {
    final $$TokensTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tokenId,
      referencedTable: $db.tokens,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TokensTableFilterComposer(
            $db: $db,
            $table: $db.tokens,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> messagesRefs(
    Expression<bool> Function($$MessagesTableFilterComposer f) f,
  ) {
    final $$MessagesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.messages,
      getReferencedColumn: (t) => t.conversationId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MessagesTableFilterComposer(
            $db: $db,
            $table: $db.messages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ConversationsTableOrderingComposer
    extends Composer<_$AppDatabase, $ConversationsTable> {
  $$ConversationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get model => $composableBuilder(
    column: $table.model,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProvidersTableOrderingComposer get providerId {
    final $$ProvidersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.providerId,
      referencedTable: $db.providers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProvidersTableOrderingComposer(
            $db: $db,
            $table: $db.providers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TokensTableOrderingComposer get tokenId {
    final $$TokensTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tokenId,
      referencedTable: $db.tokens,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TokensTableOrderingComposer(
            $db: $db,
            $table: $db.tokens,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ConversationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ConversationsTable> {
  $$ConversationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get model =>
      $composableBuilder(column: $table.model, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$ProvidersTableAnnotationComposer get providerId {
    final $$ProvidersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.providerId,
      referencedTable: $db.providers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProvidersTableAnnotationComposer(
            $db: $db,
            $table: $db.providers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TokensTableAnnotationComposer get tokenId {
    final $$TokensTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tokenId,
      referencedTable: $db.tokens,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TokensTableAnnotationComposer(
            $db: $db,
            $table: $db.tokens,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> messagesRefs<T extends Object>(
    Expression<T> Function($$MessagesTableAnnotationComposer a) f,
  ) {
    final $$MessagesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.messages,
      getReferencedColumn: (t) => t.conversationId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MessagesTableAnnotationComposer(
            $db: $db,
            $table: $db.messages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ConversationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ConversationsTable,
          Conversation,
          $$ConversationsTableFilterComposer,
          $$ConversationsTableOrderingComposer,
          $$ConversationsTableAnnotationComposer,
          $$ConversationsTableCreateCompanionBuilder,
          $$ConversationsTableUpdateCompanionBuilder,
          (Conversation, $$ConversationsTableReferences),
          Conversation,
          PrefetchHooks Function({
            bool providerId,
            bool tokenId,
            bool messagesRefs,
          })
        > {
  $$ConversationsTableTableManager(_$AppDatabase db, $ConversationsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ConversationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ConversationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ConversationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> providerId = const Value.absent(),
                Value<String> tokenId = const Value.absent(),
                Value<String> model = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ConversationsCompanion(
                id: id,
                title: title,
                providerId: providerId,
                tokenId: tokenId,
                model: model,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String> title = const Value.absent(),
                required String providerId,
                required String tokenId,
                required String model,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => ConversationsCompanion.insert(
                id: id,
                title: title,
                providerId: providerId,
                tokenId: tokenId,
                model: model,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ConversationsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({providerId = false, tokenId = false, messagesRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [if (messagesRefs) db.messages],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (providerId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.providerId,
                                    referencedTable:
                                        $$ConversationsTableReferences
                                            ._providerIdTable(db),
                                    referencedColumn:
                                        $$ConversationsTableReferences
                                            ._providerIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (tokenId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.tokenId,
                                    referencedTable:
                                        $$ConversationsTableReferences
                                            ._tokenIdTable(db),
                                    referencedColumn:
                                        $$ConversationsTableReferences
                                            ._tokenIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (messagesRefs)
                        await $_getPrefetchedData<
                          Conversation,
                          $ConversationsTable,
                          Message
                        >(
                          currentTable: table,
                          referencedTable: $$ConversationsTableReferences
                              ._messagesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ConversationsTableReferences(
                                db,
                                table,
                                p0,
                              ).messagesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.conversationId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ConversationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ConversationsTable,
      Conversation,
      $$ConversationsTableFilterComposer,
      $$ConversationsTableOrderingComposer,
      $$ConversationsTableAnnotationComposer,
      $$ConversationsTableCreateCompanionBuilder,
      $$ConversationsTableUpdateCompanionBuilder,
      (Conversation, $$ConversationsTableReferences),
      Conversation,
      PrefetchHooks Function({bool providerId, bool tokenId, bool messagesRefs})
    >;
typedef $$MessagesTableCreateCompanionBuilder =
    MessagesCompanion Function({
      required String id,
      required String conversationId,
      required String role,
      required String content,
      required DateTime createdAt,
      Value<String?> metadata,
      Value<int> rowid,
    });
typedef $$MessagesTableUpdateCompanionBuilder =
    MessagesCompanion Function({
      Value<String> id,
      Value<String> conversationId,
      Value<String> role,
      Value<String> content,
      Value<DateTime> createdAt,
      Value<String?> metadata,
      Value<int> rowid,
    });

final class $$MessagesTableReferences
    extends BaseReferences<_$AppDatabase, $MessagesTable, Message> {
  $$MessagesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ConversationsTable _conversationIdTable(_$AppDatabase db) =>
      db.conversations.createAlias(
        $_aliasNameGenerator(db.messages.conversationId, db.conversations.id),
      );

  $$ConversationsTableProcessedTableManager get conversationId {
    final $_column = $_itemColumn<String>('conversation_id')!;

    final manager = $$ConversationsTableTableManager(
      $_db,
      $_db.conversations,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_conversationIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$MessagesTableFilterComposer
    extends Composer<_$AppDatabase, $MessagesTable> {
  $$MessagesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get metadata => $composableBuilder(
    column: $table.metadata,
    builder: (column) => ColumnFilters(column),
  );

  $$ConversationsTableFilterComposer get conversationId {
    final $$ConversationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.conversationId,
      referencedTable: $db.conversations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ConversationsTableFilterComposer(
            $db: $db,
            $table: $db.conversations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MessagesTableOrderingComposer
    extends Composer<_$AppDatabase, $MessagesTable> {
  $$MessagesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get metadata => $composableBuilder(
    column: $table.metadata,
    builder: (column) => ColumnOrderings(column),
  );

  $$ConversationsTableOrderingComposer get conversationId {
    final $$ConversationsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.conversationId,
      referencedTable: $db.conversations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ConversationsTableOrderingComposer(
            $db: $db,
            $table: $db.conversations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MessagesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MessagesTable> {
  $$MessagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get metadata =>
      $composableBuilder(column: $table.metadata, builder: (column) => column);

  $$ConversationsTableAnnotationComposer get conversationId {
    final $$ConversationsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.conversationId,
      referencedTable: $db.conversations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ConversationsTableAnnotationComposer(
            $db: $db,
            $table: $db.conversations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MessagesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MessagesTable,
          Message,
          $$MessagesTableFilterComposer,
          $$MessagesTableOrderingComposer,
          $$MessagesTableAnnotationComposer,
          $$MessagesTableCreateCompanionBuilder,
          $$MessagesTableUpdateCompanionBuilder,
          (Message, $$MessagesTableReferences),
          Message,
          PrefetchHooks Function({bool conversationId})
        > {
  $$MessagesTableTableManager(_$AppDatabase db, $MessagesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MessagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MessagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MessagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> conversationId = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String?> metadata = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MessagesCompanion(
                id: id,
                conversationId: conversationId,
                role: role,
                content: content,
                createdAt: createdAt,
                metadata: metadata,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String conversationId,
                required String role,
                required String content,
                required DateTime createdAt,
                Value<String?> metadata = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MessagesCompanion.insert(
                id: id,
                conversationId: conversationId,
                role: role,
                content: content,
                createdAt: createdAt,
                metadata: metadata,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$MessagesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({conversationId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (conversationId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.conversationId,
                                referencedTable: $$MessagesTableReferences
                                    ._conversationIdTable(db),
                                referencedColumn: $$MessagesTableReferences
                                    ._conversationIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$MessagesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MessagesTable,
      Message,
      $$MessagesTableFilterComposer,
      $$MessagesTableOrderingComposer,
      $$MessagesTableAnnotationComposer,
      $$MessagesTableCreateCompanionBuilder,
      $$MessagesTableUpdateCompanionBuilder,
      (Message, $$MessagesTableReferences),
      Message,
      PrefetchHooks Function({bool conversationId})
    >;
typedef $$ImageTasksTableCreateCompanionBuilder =
    ImageTasksCompanion Function({
      required String id,
      required String providerId,
      required String tokenId,
      required String model,
      required String prompt,
      Value<String> referencePaths,
      Value<String?> resultPath,
      required String status,
      Value<String?> errorMessage,
      Value<String?> params,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$ImageTasksTableUpdateCompanionBuilder =
    ImageTasksCompanion Function({
      Value<String> id,
      Value<String> providerId,
      Value<String> tokenId,
      Value<String> model,
      Value<String> prompt,
      Value<String> referencePaths,
      Value<String?> resultPath,
      Value<String> status,
      Value<String?> errorMessage,
      Value<String?> params,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$ImageTasksTableReferences
    extends BaseReferences<_$AppDatabase, $ImageTasksTable, ImageTask> {
  $$ImageTasksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ProvidersTable _providerIdTable(_$AppDatabase db) =>
      db.providers.createAlias(
        $_aliasNameGenerator(db.imageTasks.providerId, db.providers.id),
      );

  $$ProvidersTableProcessedTableManager get providerId {
    final $_column = $_itemColumn<String>('provider_id')!;

    final manager = $$ProvidersTableTableManager(
      $_db,
      $_db.providers,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_providerIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $TokensTable _tokenIdTable(_$AppDatabase db) => db.tokens.createAlias(
    $_aliasNameGenerator(db.imageTasks.tokenId, db.tokens.id),
  );

  $$TokensTableProcessedTableManager get tokenId {
    final $_column = $_itemColumn<String>('token_id')!;

    final manager = $$TokensTableTableManager(
      $_db,
      $_db.tokens,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_tokenIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ImageTasksTableFilterComposer
    extends Composer<_$AppDatabase, $ImageTasksTable> {
  $$ImageTasksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get model => $composableBuilder(
    column: $table.model,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get prompt => $composableBuilder(
    column: $table.prompt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get referencePaths => $composableBuilder(
    column: $table.referencePaths,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get resultPath => $composableBuilder(
    column: $table.resultPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get params => $composableBuilder(
    column: $table.params,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ProvidersTableFilterComposer get providerId {
    final $$ProvidersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.providerId,
      referencedTable: $db.providers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProvidersTableFilterComposer(
            $db: $db,
            $table: $db.providers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TokensTableFilterComposer get tokenId {
    final $$TokensTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tokenId,
      referencedTable: $db.tokens,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TokensTableFilterComposer(
            $db: $db,
            $table: $db.tokens,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ImageTasksTableOrderingComposer
    extends Composer<_$AppDatabase, $ImageTasksTable> {
  $$ImageTasksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get model => $composableBuilder(
    column: $table.model,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get prompt => $composableBuilder(
    column: $table.prompt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get referencePaths => $composableBuilder(
    column: $table.referencePaths,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get resultPath => $composableBuilder(
    column: $table.resultPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get params => $composableBuilder(
    column: $table.params,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProvidersTableOrderingComposer get providerId {
    final $$ProvidersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.providerId,
      referencedTable: $db.providers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProvidersTableOrderingComposer(
            $db: $db,
            $table: $db.providers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TokensTableOrderingComposer get tokenId {
    final $$TokensTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tokenId,
      referencedTable: $db.tokens,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TokensTableOrderingComposer(
            $db: $db,
            $table: $db.tokens,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ImageTasksTableAnnotationComposer
    extends Composer<_$AppDatabase, $ImageTasksTable> {
  $$ImageTasksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get model =>
      $composableBuilder(column: $table.model, builder: (column) => column);

  GeneratedColumn<String> get prompt =>
      $composableBuilder(column: $table.prompt, builder: (column) => column);

  GeneratedColumn<String> get referencePaths => $composableBuilder(
    column: $table.referencePaths,
    builder: (column) => column,
  );

  GeneratedColumn<String> get resultPath => $composableBuilder(
    column: $table.resultPath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => column,
  );

  GeneratedColumn<String> get params =>
      $composableBuilder(column: $table.params, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$ProvidersTableAnnotationComposer get providerId {
    final $$ProvidersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.providerId,
      referencedTable: $db.providers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProvidersTableAnnotationComposer(
            $db: $db,
            $table: $db.providers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TokensTableAnnotationComposer get tokenId {
    final $$TokensTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tokenId,
      referencedTable: $db.tokens,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TokensTableAnnotationComposer(
            $db: $db,
            $table: $db.tokens,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ImageTasksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ImageTasksTable,
          ImageTask,
          $$ImageTasksTableFilterComposer,
          $$ImageTasksTableOrderingComposer,
          $$ImageTasksTableAnnotationComposer,
          $$ImageTasksTableCreateCompanionBuilder,
          $$ImageTasksTableUpdateCompanionBuilder,
          (ImageTask, $$ImageTasksTableReferences),
          ImageTask,
          PrefetchHooks Function({bool providerId, bool tokenId})
        > {
  $$ImageTasksTableTableManager(_$AppDatabase db, $ImageTasksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ImageTasksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ImageTasksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ImageTasksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> providerId = const Value.absent(),
                Value<String> tokenId = const Value.absent(),
                Value<String> model = const Value.absent(),
                Value<String> prompt = const Value.absent(),
                Value<String> referencePaths = const Value.absent(),
                Value<String?> resultPath = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> errorMessage = const Value.absent(),
                Value<String?> params = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ImageTasksCompanion(
                id: id,
                providerId: providerId,
                tokenId: tokenId,
                model: model,
                prompt: prompt,
                referencePaths: referencePaths,
                resultPath: resultPath,
                status: status,
                errorMessage: errorMessage,
                params: params,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String providerId,
                required String tokenId,
                required String model,
                required String prompt,
                Value<String> referencePaths = const Value.absent(),
                Value<String?> resultPath = const Value.absent(),
                required String status,
                Value<String?> errorMessage = const Value.absent(),
                Value<String?> params = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => ImageTasksCompanion.insert(
                id: id,
                providerId: providerId,
                tokenId: tokenId,
                model: model,
                prompt: prompt,
                referencePaths: referencePaths,
                resultPath: resultPath,
                status: status,
                errorMessage: errorMessage,
                params: params,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ImageTasksTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({providerId = false, tokenId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (providerId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.providerId,
                                referencedTable: $$ImageTasksTableReferences
                                    ._providerIdTable(db),
                                referencedColumn: $$ImageTasksTableReferences
                                    ._providerIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (tokenId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.tokenId,
                                referencedTable: $$ImageTasksTableReferences
                                    ._tokenIdTable(db),
                                referencedColumn: $$ImageTasksTableReferences
                                    ._tokenIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ImageTasksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ImageTasksTable,
      ImageTask,
      $$ImageTasksTableFilterComposer,
      $$ImageTasksTableOrderingComposer,
      $$ImageTasksTableAnnotationComposer,
      $$ImageTasksTableCreateCompanionBuilder,
      $$ImageTasksTableUpdateCompanionBuilder,
      (ImageTask, $$ImageTasksTableReferences),
      ImageTask,
      PrefetchHooks Function({bool providerId, bool tokenId})
    >;
typedef $$SshHostsTableCreateCompanionBuilder =
    SshHostsCompanion Function({
      required String id,
      required String name,
      required String host,
      Value<int> port,
      required String username,
      required String authType,
      required String secretRef,
      Value<String?> passphraseRef,
      Value<String?> hostKeyFingerprint,
      Value<bool> isTailscale,
      Value<DateTime?> lastConnectedAt,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$SshHostsTableUpdateCompanionBuilder =
    SshHostsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> host,
      Value<int> port,
      Value<String> username,
      Value<String> authType,
      Value<String> secretRef,
      Value<String?> passphraseRef,
      Value<String?> hostKeyFingerprint,
      Value<bool> isTailscale,
      Value<DateTime?> lastConnectedAt,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$SshHostsTableFilterComposer
    extends Composer<_$AppDatabase, $SshHostsTable> {
  $$SshHostsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get host => $composableBuilder(
    column: $table.host,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get port => $composableBuilder(
    column: $table.port,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get username => $composableBuilder(
    column: $table.username,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get authType => $composableBuilder(
    column: $table.authType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get secretRef => $composableBuilder(
    column: $table.secretRef,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get passphraseRef => $composableBuilder(
    column: $table.passphraseRef,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hostKeyFingerprint => $composableBuilder(
    column: $table.hostKeyFingerprint,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isTailscale => $composableBuilder(
    column: $table.isTailscale,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastConnectedAt => $composableBuilder(
    column: $table.lastConnectedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SshHostsTableOrderingComposer
    extends Composer<_$AppDatabase, $SshHostsTable> {
  $$SshHostsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get host => $composableBuilder(
    column: $table.host,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get port => $composableBuilder(
    column: $table.port,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get username => $composableBuilder(
    column: $table.username,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get authType => $composableBuilder(
    column: $table.authType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get secretRef => $composableBuilder(
    column: $table.secretRef,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get passphraseRef => $composableBuilder(
    column: $table.passphraseRef,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hostKeyFingerprint => $composableBuilder(
    column: $table.hostKeyFingerprint,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isTailscale => $composableBuilder(
    column: $table.isTailscale,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastConnectedAt => $composableBuilder(
    column: $table.lastConnectedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SshHostsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SshHostsTable> {
  $$SshHostsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get host =>
      $composableBuilder(column: $table.host, builder: (column) => column);

  GeneratedColumn<int> get port =>
      $composableBuilder(column: $table.port, builder: (column) => column);

  GeneratedColumn<String> get username =>
      $composableBuilder(column: $table.username, builder: (column) => column);

  GeneratedColumn<String> get authType =>
      $composableBuilder(column: $table.authType, builder: (column) => column);

  GeneratedColumn<String> get secretRef =>
      $composableBuilder(column: $table.secretRef, builder: (column) => column);

  GeneratedColumn<String> get passphraseRef => $composableBuilder(
    column: $table.passphraseRef,
    builder: (column) => column,
  );

  GeneratedColumn<String> get hostKeyFingerprint => $composableBuilder(
    column: $table.hostKeyFingerprint,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isTailscale => $composableBuilder(
    column: $table.isTailscale,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastConnectedAt => $composableBuilder(
    column: $table.lastConnectedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$SshHostsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SshHostsTable,
          SshHost,
          $$SshHostsTableFilterComposer,
          $$SshHostsTableOrderingComposer,
          $$SshHostsTableAnnotationComposer,
          $$SshHostsTableCreateCompanionBuilder,
          $$SshHostsTableUpdateCompanionBuilder,
          (SshHost, BaseReferences<_$AppDatabase, $SshHostsTable, SshHost>),
          SshHost,
          PrefetchHooks Function()
        > {
  $$SshHostsTableTableManager(_$AppDatabase db, $SshHostsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SshHostsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SshHostsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SshHostsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> host = const Value.absent(),
                Value<int> port = const Value.absent(),
                Value<String> username = const Value.absent(),
                Value<String> authType = const Value.absent(),
                Value<String> secretRef = const Value.absent(),
                Value<String?> passphraseRef = const Value.absent(),
                Value<String?> hostKeyFingerprint = const Value.absent(),
                Value<bool> isTailscale = const Value.absent(),
                Value<DateTime?> lastConnectedAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SshHostsCompanion(
                id: id,
                name: name,
                host: host,
                port: port,
                username: username,
                authType: authType,
                secretRef: secretRef,
                passphraseRef: passphraseRef,
                hostKeyFingerprint: hostKeyFingerprint,
                isTailscale: isTailscale,
                lastConnectedAt: lastConnectedAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String host,
                Value<int> port = const Value.absent(),
                required String username,
                required String authType,
                required String secretRef,
                Value<String?> passphraseRef = const Value.absent(),
                Value<String?> hostKeyFingerprint = const Value.absent(),
                Value<bool> isTailscale = const Value.absent(),
                Value<DateTime?> lastConnectedAt = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => SshHostsCompanion.insert(
                id: id,
                name: name,
                host: host,
                port: port,
                username: username,
                authType: authType,
                secretRef: secretRef,
                passphraseRef: passphraseRef,
                hostKeyFingerprint: hostKeyFingerprint,
                isTailscale: isTailscale,
                lastConnectedAt: lastConnectedAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SshHostsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SshHostsTable,
      SshHost,
      $$SshHostsTableFilterComposer,
      $$SshHostsTableOrderingComposer,
      $$SshHostsTableAnnotationComposer,
      $$SshHostsTableCreateCompanionBuilder,
      $$SshHostsTableUpdateCompanionBuilder,
      (SshHost, BaseReferences<_$AppDatabase, $SshHostsTable, SshHost>),
      SshHost,
      PrefetchHooks Function()
    >;
typedef $$NotificationsTableCreateCompanionBuilder =
    NotificationsCompanion Function({
      Value<int> id,
      required String kind,
      required String providerId,
      required String title,
      required String body,
      Value<bool> read,
      required DateTime createdAt,
    });
typedef $$NotificationsTableUpdateCompanionBuilder =
    NotificationsCompanion Function({
      Value<int> id,
      Value<String> kind,
      Value<String> providerId,
      Value<String> title,
      Value<String> body,
      Value<bool> read,
      Value<DateTime> createdAt,
    });

class $$NotificationsTableFilterComposer
    extends Composer<_$AppDatabase, $NotificationsTable> {
  $$NotificationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get providerId => $composableBuilder(
    column: $table.providerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get read => $composableBuilder(
    column: $table.read,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$NotificationsTableOrderingComposer
    extends Composer<_$AppDatabase, $NotificationsTable> {
  $$NotificationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get providerId => $composableBuilder(
    column: $table.providerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get read => $composableBuilder(
    column: $table.read,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$NotificationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $NotificationsTable> {
  $$NotificationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get providerId => $composableBuilder(
    column: $table.providerId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<bool> get read =>
      $composableBuilder(column: $table.read, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$NotificationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $NotificationsTable,
          Notification,
          $$NotificationsTableFilterComposer,
          $$NotificationsTableOrderingComposer,
          $$NotificationsTableAnnotationComposer,
          $$NotificationsTableCreateCompanionBuilder,
          $$NotificationsTableUpdateCompanionBuilder,
          (
            Notification,
            BaseReferences<_$AppDatabase, $NotificationsTable, Notification>,
          ),
          Notification,
          PrefetchHooks Function()
        > {
  $$NotificationsTableTableManager(_$AppDatabase db, $NotificationsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NotificationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NotificationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NotificationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String> providerId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<bool> read = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => NotificationsCompanion(
                id: id,
                kind: kind,
                providerId: providerId,
                title: title,
                body: body,
                read: read,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String kind,
                required String providerId,
                required String title,
                required String body,
                Value<bool> read = const Value.absent(),
                required DateTime createdAt,
              }) => NotificationsCompanion.insert(
                id: id,
                kind: kind,
                providerId: providerId,
                title: title,
                body: body,
                read: read,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$NotificationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $NotificationsTable,
      Notification,
      $$NotificationsTableFilterComposer,
      $$NotificationsTableOrderingComposer,
      $$NotificationsTableAnnotationComposer,
      $$NotificationsTableCreateCompanionBuilder,
      $$NotificationsTableUpdateCompanionBuilder,
      (
        Notification,
        BaseReferences<_$AppDatabase, $NotificationsTable, Notification>,
      ),
      Notification,
      PrefetchHooks Function()
    >;
typedef $$MonitorSitesTableCreateCompanionBuilder =
    MonitorSitesCompanion Function({
      Value<int> id,
      required String name,
      required String baseUrl,
      Value<String> kind,
      Value<String?> apiTokenRef,
      Value<bool> showOnHome,
      Value<int> sortOrder,
      Value<String?> lastData,
      Value<DateTime?> lastFetchedAt,
      Value<String?> lastError,
      required DateTime createdAt,
      required DateTime updatedAt,
    });
typedef $$MonitorSitesTableUpdateCompanionBuilder =
    MonitorSitesCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> baseUrl,
      Value<String> kind,
      Value<String?> apiTokenRef,
      Value<bool> showOnHome,
      Value<int> sortOrder,
      Value<String?> lastData,
      Value<DateTime?> lastFetchedAt,
      Value<String?> lastError,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

class $$MonitorSitesTableFilterComposer
    extends Composer<_$AppDatabase, $MonitorSitesTable> {
  $$MonitorSitesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get baseUrl => $composableBuilder(
    column: $table.baseUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get apiTokenRef => $composableBuilder(
    column: $table.apiTokenRef,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get showOnHome => $composableBuilder(
    column: $table.showOnHome,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastData => $composableBuilder(
    column: $table.lastData,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastFetchedAt => $composableBuilder(
    column: $table.lastFetchedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MonitorSitesTableOrderingComposer
    extends Composer<_$AppDatabase, $MonitorSitesTable> {
  $$MonitorSitesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get baseUrl => $composableBuilder(
    column: $table.baseUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get apiTokenRef => $composableBuilder(
    column: $table.apiTokenRef,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get showOnHome => $composableBuilder(
    column: $table.showOnHome,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastData => $composableBuilder(
    column: $table.lastData,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastFetchedAt => $composableBuilder(
    column: $table.lastFetchedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MonitorSitesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MonitorSitesTable> {
  $$MonitorSitesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get baseUrl =>
      $composableBuilder(column: $table.baseUrl, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get apiTokenRef => $composableBuilder(
    column: $table.apiTokenRef,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get showOnHome => $composableBuilder(
    column: $table.showOnHome,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<String> get lastData =>
      $composableBuilder(column: $table.lastData, builder: (column) => column);

  GeneratedColumn<DateTime> get lastFetchedAt => $composableBuilder(
    column: $table.lastFetchedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$MonitorSitesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MonitorSitesTable,
          MonitorSite,
          $$MonitorSitesTableFilterComposer,
          $$MonitorSitesTableOrderingComposer,
          $$MonitorSitesTableAnnotationComposer,
          $$MonitorSitesTableCreateCompanionBuilder,
          $$MonitorSitesTableUpdateCompanionBuilder,
          (
            MonitorSite,
            BaseReferences<_$AppDatabase, $MonitorSitesTable, MonitorSite>,
          ),
          MonitorSite,
          PrefetchHooks Function()
        > {
  $$MonitorSitesTableTableManager(_$AppDatabase db, $MonitorSitesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MonitorSitesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MonitorSitesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MonitorSitesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> baseUrl = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String?> apiTokenRef = const Value.absent(),
                Value<bool> showOnHome = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<String?> lastData = const Value.absent(),
                Value<DateTime?> lastFetchedAt = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => MonitorSitesCompanion(
                id: id,
                name: name,
                baseUrl: baseUrl,
                kind: kind,
                apiTokenRef: apiTokenRef,
                showOnHome: showOnHome,
                sortOrder: sortOrder,
                lastData: lastData,
                lastFetchedAt: lastFetchedAt,
                lastError: lastError,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required String baseUrl,
                Value<String> kind = const Value.absent(),
                Value<String?> apiTokenRef = const Value.absent(),
                Value<bool> showOnHome = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<String?> lastData = const Value.absent(),
                Value<DateTime?> lastFetchedAt = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
              }) => MonitorSitesCompanion.insert(
                id: id,
                name: name,
                baseUrl: baseUrl,
                kind: kind,
                apiTokenRef: apiTokenRef,
                showOnHome: showOnHome,
                sortOrder: sortOrder,
                lastData: lastData,
                lastFetchedAt: lastFetchedAt,
                lastError: lastError,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MonitorSitesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MonitorSitesTable,
      MonitorSite,
      $$MonitorSitesTableFilterComposer,
      $$MonitorSitesTableOrderingComposer,
      $$MonitorSitesTableAnnotationComposer,
      $$MonitorSitesTableCreateCompanionBuilder,
      $$MonitorSitesTableUpdateCompanionBuilder,
      (
        MonitorSite,
        BaseReferences<_$AppDatabase, $MonitorSitesTable, MonitorSite>,
      ),
      MonitorSite,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ProvidersTableTableManager get providers =>
      $$ProvidersTableTableManager(_db, _db.providers);
  $$TokensTableTableManager get tokens =>
      $$TokensTableTableManager(_db, _db.tokens);
  $$ProviderModelsTableTableManager get providerModels =>
      $$ProviderModelsTableTableManager(_db, _db.providerModels);
  $$QuotaSnapshotsTableTableManager get quotaSnapshots =>
      $$QuotaSnapshotsTableTableManager(_db, _db.quotaSnapshots);
  $$ModelTestRecordsTableTableManager get modelTestRecords =>
      $$ModelTestRecordsTableTableManager(_db, _db.modelTestRecords);
  $$CheckinRecordsTableTableManager get checkinRecords =>
      $$CheckinRecordsTableTableManager(_db, _db.checkinRecords);
  $$PrewarmRecordsTableTableManager get prewarmRecords =>
      $$PrewarmRecordsTableTableManager(_db, _db.prewarmRecords);
  $$WebdavConfigsTableTableManager get webdavConfigs =>
      $$WebdavConfigsTableTableManager(_db, _db.webdavConfigs);
  $$ConversationsTableTableManager get conversations =>
      $$ConversationsTableTableManager(_db, _db.conversations);
  $$MessagesTableTableManager get messages =>
      $$MessagesTableTableManager(_db, _db.messages);
  $$ImageTasksTableTableManager get imageTasks =>
      $$ImageTasksTableTableManager(_db, _db.imageTasks);
  $$SshHostsTableTableManager get sshHosts =>
      $$SshHostsTableTableManager(_db, _db.sshHosts);
  $$NotificationsTableTableManager get notifications =>
      $$NotificationsTableTableManager(_db, _db.notifications);
  $$MonitorSitesTableTableManager get monitorSites =>
      $$MonitorSitesTableTableManager(_db, _db.monitorSites);
}
