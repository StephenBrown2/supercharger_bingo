// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $SitesTable extends Sites with TableInfo<$SitesTable, Site> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SitesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _siteIdMeta = const VerificationMeta('siteId');
  @override
  late final GeneratedColumn<int> siteId = GeneratedColumn<int>(
    'site_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _locationIdMeta = const VerificationMeta(
    'locationId',
  );
  @override
  late final GeneratedColumn<String> locationId = GeneratedColumn<String>(
    'location_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
  late final GeneratedColumnWithTypeConverter<SiteStatus, String> status =
      GeneratedColumn<String>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: Constant(SiteStatus.plan.name),
      ).withConverter<SiteStatus>($SitesTable.$converterstatus);
  static const VerificationMeta _latitudeMeta = const VerificationMeta(
    'latitude',
  );
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
    'latitude',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _longitudeMeta = const VerificationMeta(
    'longitude',
  );
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
    'longitude',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _cityMeta = const VerificationMeta('city');
  @override
  late final GeneratedColumn<String> city = GeneratedColumn<String>(
    'city',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  @override
  late final GeneratedColumn<String> state = GeneratedColumn<String>(
    'state',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _countryMeta = const VerificationMeta(
    'country',
  );
  @override
  late final GeneratedColumn<String> country = GeneratedColumn<String>(
    'country',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Unknown'),
  );
  static const VerificationMeta _regionMeta = const VerificationMeta('region');
  @override
  late final GeneratedColumn<String> region = GeneratedColumn<String>(
    'region',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Unknown'),
  );
  static const VerificationMeta _timezoneMeta = const VerificationMeta(
    'timezone',
  );
  @override
  late final GeneratedColumn<String> timezone = GeneratedColumn<String>(
    'timezone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _stallCountMeta = const VerificationMeta(
    'stallCount',
  );
  @override
  late final GeneratedColumn<int> stallCount = GeneratedColumn<int>(
    'stall_count',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dateOpenedMeta = const VerificationMeta(
    'dateOpened',
  );
  @override
  late final GeneratedColumn<DateTime> dateOpened = GeneratedColumn<DateTime>(
    'date_opened',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _hasCheckinsMeta = const VerificationMeta(
    'hasCheckins',
  );
  @override
  late final GeneratedColumn<bool> hasCheckins = GeneratedColumn<bool>(
    'has_checkins',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("has_checkins" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _visitedMeta = const VerificationMeta(
    'visited',
  );
  @override
  late final GeneratedColumn<bool> visited = GeneratedColumn<bool>(
    'visited',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("visited" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _lastSyncedMeta = const VerificationMeta(
    'lastSynced',
  );
  @override
  late final GeneratedColumn<DateTime> lastSynced = GeneratedColumn<DateTime>(
    'last_synced',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    siteId,
    locationId,
    name,
    status,
    latitude,
    longitude,
    city,
    state,
    country,
    region,
    timezone,
    stallCount,
    dateOpened,
    hasCheckins,
    visited,
    lastSynced,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sites';
  @override
  VerificationContext validateIntegrity(
    Insertable<Site> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('site_id')) {
      context.handle(
        _siteIdMeta,
        siteId.isAcceptableOrUnknown(data['site_id']!, _siteIdMeta),
      );
    } else if (isInserting) {
      context.missing(_siteIdMeta);
    }
    if (data.containsKey('location_id')) {
      context.handle(
        _locationIdMeta,
        locationId.isAcceptableOrUnknown(data['location_id']!, _locationIdMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('latitude')) {
      context.handle(
        _latitudeMeta,
        latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta),
      );
    }
    if (data.containsKey('longitude')) {
      context.handle(
        _longitudeMeta,
        longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta),
      );
    }
    if (data.containsKey('city')) {
      context.handle(
        _cityMeta,
        city.isAcceptableOrUnknown(data['city']!, _cityMeta),
      );
    }
    if (data.containsKey('state')) {
      context.handle(
        _stateMeta,
        state.isAcceptableOrUnknown(data['state']!, _stateMeta),
      );
    }
    if (data.containsKey('country')) {
      context.handle(
        _countryMeta,
        country.isAcceptableOrUnknown(data['country']!, _countryMeta),
      );
    }
    if (data.containsKey('region')) {
      context.handle(
        _regionMeta,
        region.isAcceptableOrUnknown(data['region']!, _regionMeta),
      );
    }
    if (data.containsKey('timezone')) {
      context.handle(
        _timezoneMeta,
        timezone.isAcceptableOrUnknown(data['timezone']!, _timezoneMeta),
      );
    }
    if (data.containsKey('stall_count')) {
      context.handle(
        _stallCountMeta,
        stallCount.isAcceptableOrUnknown(data['stall_count']!, _stallCountMeta),
      );
    }
    if (data.containsKey('date_opened')) {
      context.handle(
        _dateOpenedMeta,
        dateOpened.isAcceptableOrUnknown(data['date_opened']!, _dateOpenedMeta),
      );
    }
    if (data.containsKey('has_checkins')) {
      context.handle(
        _hasCheckinsMeta,
        hasCheckins.isAcceptableOrUnknown(
          data['has_checkins']!,
          _hasCheckinsMeta,
        ),
      );
    }
    if (data.containsKey('visited')) {
      context.handle(
        _visitedMeta,
        visited.isAcceptableOrUnknown(data['visited']!, _visitedMeta),
      );
    }
    if (data.containsKey('last_synced')) {
      context.handle(
        _lastSyncedMeta,
        lastSynced.isAcceptableOrUnknown(data['last_synced']!, _lastSyncedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Site map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Site(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      siteId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}site_id'],
      )!,
      locationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}location_id'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      status: $SitesTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}status'],
        )!,
      ),
      latitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}latitude'],
      )!,
      longitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}longitude'],
      )!,
      city: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}city'],
      ),
      state: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}state'],
      ),
      country: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}country'],
      )!,
      region: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}region'],
      )!,
      timezone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}timezone'],
      ),
      stallCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}stall_count'],
      ),
      dateOpened: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date_opened'],
      ),
      hasCheckins: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}has_checkins'],
      )!,
      visited: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}visited'],
      )!,
      lastSynced: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_synced'],
      ),
    );
  }

  @override
  $SitesTable createAlias(String alias) {
    return $SitesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<SiteStatus, String, String> $converterstatus =
      const EnumNameConverter<SiteStatus>(SiteStatus.values);
}

class Site extends DataClass implements Insertable<Site> {
  final int id;
  final int siteId;
  final String? locationId;
  final String name;
  final SiteStatus status;
  final double latitude;
  final double longitude;
  final String? city;
  final String? state;
  final String country;
  final String region;

  /// IANA timezone derived from coordinates at ingestion (SPEC Section 3).
  /// Drives the site-local "First" day boundary.
  final String? timezone;
  final int? stallCount;
  final DateTime? dateOpened;

  /// Whether this site has any check-ins from any user (false = first eligible)
  final bool hasCheckins;

  /// Whether the current user has visited this site
  final bool visited;
  final DateTime? lastSynced;
  const Site({
    required this.id,
    required this.siteId,
    this.locationId,
    required this.name,
    required this.status,
    required this.latitude,
    required this.longitude,
    this.city,
    this.state,
    required this.country,
    required this.region,
    this.timezone,
    this.stallCount,
    this.dateOpened,
    required this.hasCheckins,
    required this.visited,
    this.lastSynced,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['site_id'] = Variable<int>(siteId);
    if (!nullToAbsent || locationId != null) {
      map['location_id'] = Variable<String>(locationId);
    }
    map['name'] = Variable<String>(name);
    {
      map['status'] = Variable<String>(
        $SitesTable.$converterstatus.toSql(status),
      );
    }
    map['latitude'] = Variable<double>(latitude);
    map['longitude'] = Variable<double>(longitude);
    if (!nullToAbsent || city != null) {
      map['city'] = Variable<String>(city);
    }
    if (!nullToAbsent || state != null) {
      map['state'] = Variable<String>(state);
    }
    map['country'] = Variable<String>(country);
    map['region'] = Variable<String>(region);
    if (!nullToAbsent || timezone != null) {
      map['timezone'] = Variable<String>(timezone);
    }
    if (!nullToAbsent || stallCount != null) {
      map['stall_count'] = Variable<int>(stallCount);
    }
    if (!nullToAbsent || dateOpened != null) {
      map['date_opened'] = Variable<DateTime>(dateOpened);
    }
    map['has_checkins'] = Variable<bool>(hasCheckins);
    map['visited'] = Variable<bool>(visited);
    if (!nullToAbsent || lastSynced != null) {
      map['last_synced'] = Variable<DateTime>(lastSynced);
    }
    return map;
  }

  SitesCompanion toCompanion(bool nullToAbsent) {
    return SitesCompanion(
      id: Value(id),
      siteId: Value(siteId),
      locationId: locationId == null && nullToAbsent
          ? const Value.absent()
          : Value(locationId),
      name: Value(name),
      status: Value(status),
      latitude: Value(latitude),
      longitude: Value(longitude),
      city: city == null && nullToAbsent ? const Value.absent() : Value(city),
      state: state == null && nullToAbsent
          ? const Value.absent()
          : Value(state),
      country: Value(country),
      region: Value(region),
      timezone: timezone == null && nullToAbsent
          ? const Value.absent()
          : Value(timezone),
      stallCount: stallCount == null && nullToAbsent
          ? const Value.absent()
          : Value(stallCount),
      dateOpened: dateOpened == null && nullToAbsent
          ? const Value.absent()
          : Value(dateOpened),
      hasCheckins: Value(hasCheckins),
      visited: Value(visited),
      lastSynced: lastSynced == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSynced),
    );
  }

  factory Site.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Site(
      id: serializer.fromJson<int>(json['id']),
      siteId: serializer.fromJson<int>(json['siteId']),
      locationId: serializer.fromJson<String?>(json['locationId']),
      name: serializer.fromJson<String>(json['name']),
      status: $SitesTable.$converterstatus.fromJson(
        serializer.fromJson<String>(json['status']),
      ),
      latitude: serializer.fromJson<double>(json['latitude']),
      longitude: serializer.fromJson<double>(json['longitude']),
      city: serializer.fromJson<String?>(json['city']),
      state: serializer.fromJson<String?>(json['state']),
      country: serializer.fromJson<String>(json['country']),
      region: serializer.fromJson<String>(json['region']),
      timezone: serializer.fromJson<String?>(json['timezone']),
      stallCount: serializer.fromJson<int?>(json['stallCount']),
      dateOpened: serializer.fromJson<DateTime?>(json['dateOpened']),
      hasCheckins: serializer.fromJson<bool>(json['hasCheckins']),
      visited: serializer.fromJson<bool>(json['visited']),
      lastSynced: serializer.fromJson<DateTime?>(json['lastSynced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'siteId': serializer.toJson<int>(siteId),
      'locationId': serializer.toJson<String?>(locationId),
      'name': serializer.toJson<String>(name),
      'status': serializer.toJson<String>(
        $SitesTable.$converterstatus.toJson(status),
      ),
      'latitude': serializer.toJson<double>(latitude),
      'longitude': serializer.toJson<double>(longitude),
      'city': serializer.toJson<String?>(city),
      'state': serializer.toJson<String?>(state),
      'country': serializer.toJson<String>(country),
      'region': serializer.toJson<String>(region),
      'timezone': serializer.toJson<String?>(timezone),
      'stallCount': serializer.toJson<int?>(stallCount),
      'dateOpened': serializer.toJson<DateTime?>(dateOpened),
      'hasCheckins': serializer.toJson<bool>(hasCheckins),
      'visited': serializer.toJson<bool>(visited),
      'lastSynced': serializer.toJson<DateTime?>(lastSynced),
    };
  }

  Site copyWith({
    int? id,
    int? siteId,
    Value<String?> locationId = const Value.absent(),
    String? name,
    SiteStatus? status,
    double? latitude,
    double? longitude,
    Value<String?> city = const Value.absent(),
    Value<String?> state = const Value.absent(),
    String? country,
    String? region,
    Value<String?> timezone = const Value.absent(),
    Value<int?> stallCount = const Value.absent(),
    Value<DateTime?> dateOpened = const Value.absent(),
    bool? hasCheckins,
    bool? visited,
    Value<DateTime?> lastSynced = const Value.absent(),
  }) => Site(
    id: id ?? this.id,
    siteId: siteId ?? this.siteId,
    locationId: locationId.present ? locationId.value : this.locationId,
    name: name ?? this.name,
    status: status ?? this.status,
    latitude: latitude ?? this.latitude,
    longitude: longitude ?? this.longitude,
    city: city.present ? city.value : this.city,
    state: state.present ? state.value : this.state,
    country: country ?? this.country,
    region: region ?? this.region,
    timezone: timezone.present ? timezone.value : this.timezone,
    stallCount: stallCount.present ? stallCount.value : this.stallCount,
    dateOpened: dateOpened.present ? dateOpened.value : this.dateOpened,
    hasCheckins: hasCheckins ?? this.hasCheckins,
    visited: visited ?? this.visited,
    lastSynced: lastSynced.present ? lastSynced.value : this.lastSynced,
  );
  Site copyWithCompanion(SitesCompanion data) {
    return Site(
      id: data.id.present ? data.id.value : this.id,
      siteId: data.siteId.present ? data.siteId.value : this.siteId,
      locationId: data.locationId.present
          ? data.locationId.value
          : this.locationId,
      name: data.name.present ? data.name.value : this.name,
      status: data.status.present ? data.status.value : this.status,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      city: data.city.present ? data.city.value : this.city,
      state: data.state.present ? data.state.value : this.state,
      country: data.country.present ? data.country.value : this.country,
      region: data.region.present ? data.region.value : this.region,
      timezone: data.timezone.present ? data.timezone.value : this.timezone,
      stallCount: data.stallCount.present
          ? data.stallCount.value
          : this.stallCount,
      dateOpened: data.dateOpened.present
          ? data.dateOpened.value
          : this.dateOpened,
      hasCheckins: data.hasCheckins.present
          ? data.hasCheckins.value
          : this.hasCheckins,
      visited: data.visited.present ? data.visited.value : this.visited,
      lastSynced: data.lastSynced.present
          ? data.lastSynced.value
          : this.lastSynced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Site(')
          ..write('id: $id, ')
          ..write('siteId: $siteId, ')
          ..write('locationId: $locationId, ')
          ..write('name: $name, ')
          ..write('status: $status, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('city: $city, ')
          ..write('state: $state, ')
          ..write('country: $country, ')
          ..write('region: $region, ')
          ..write('timezone: $timezone, ')
          ..write('stallCount: $stallCount, ')
          ..write('dateOpened: $dateOpened, ')
          ..write('hasCheckins: $hasCheckins, ')
          ..write('visited: $visited, ')
          ..write('lastSynced: $lastSynced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    siteId,
    locationId,
    name,
    status,
    latitude,
    longitude,
    city,
    state,
    country,
    region,
    timezone,
    stallCount,
    dateOpened,
    hasCheckins,
    visited,
    lastSynced,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Site &&
          other.id == this.id &&
          other.siteId == this.siteId &&
          other.locationId == this.locationId &&
          other.name == this.name &&
          other.status == this.status &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.city == this.city &&
          other.state == this.state &&
          other.country == this.country &&
          other.region == this.region &&
          other.timezone == this.timezone &&
          other.stallCount == this.stallCount &&
          other.dateOpened == this.dateOpened &&
          other.hasCheckins == this.hasCheckins &&
          other.visited == this.visited &&
          other.lastSynced == this.lastSynced);
}

class SitesCompanion extends UpdateCompanion<Site> {
  final Value<int> id;
  final Value<int> siteId;
  final Value<String?> locationId;
  final Value<String> name;
  final Value<SiteStatus> status;
  final Value<double> latitude;
  final Value<double> longitude;
  final Value<String?> city;
  final Value<String?> state;
  final Value<String> country;
  final Value<String> region;
  final Value<String?> timezone;
  final Value<int?> stallCount;
  final Value<DateTime?> dateOpened;
  final Value<bool> hasCheckins;
  final Value<bool> visited;
  final Value<DateTime?> lastSynced;
  const SitesCompanion({
    this.id = const Value.absent(),
    this.siteId = const Value.absent(),
    this.locationId = const Value.absent(),
    this.name = const Value.absent(),
    this.status = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.city = const Value.absent(),
    this.state = const Value.absent(),
    this.country = const Value.absent(),
    this.region = const Value.absent(),
    this.timezone = const Value.absent(),
    this.stallCount = const Value.absent(),
    this.dateOpened = const Value.absent(),
    this.hasCheckins = const Value.absent(),
    this.visited = const Value.absent(),
    this.lastSynced = const Value.absent(),
  });
  SitesCompanion.insert({
    this.id = const Value.absent(),
    required int siteId,
    this.locationId = const Value.absent(),
    required String name,
    this.status = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.city = const Value.absent(),
    this.state = const Value.absent(),
    this.country = const Value.absent(),
    this.region = const Value.absent(),
    this.timezone = const Value.absent(),
    this.stallCount = const Value.absent(),
    this.dateOpened = const Value.absent(),
    this.hasCheckins = const Value.absent(),
    this.visited = const Value.absent(),
    this.lastSynced = const Value.absent(),
  }) : siteId = Value(siteId),
       name = Value(name);
  static Insertable<Site> custom({
    Expression<int>? id,
    Expression<int>? siteId,
    Expression<String>? locationId,
    Expression<String>? name,
    Expression<String>? status,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<String>? city,
    Expression<String>? state,
    Expression<String>? country,
    Expression<String>? region,
    Expression<String>? timezone,
    Expression<int>? stallCount,
    Expression<DateTime>? dateOpened,
    Expression<bool>? hasCheckins,
    Expression<bool>? visited,
    Expression<DateTime>? lastSynced,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (siteId != null) 'site_id': siteId,
      if (locationId != null) 'location_id': locationId,
      if (name != null) 'name': name,
      if (status != null) 'status': status,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (city != null) 'city': city,
      if (state != null) 'state': state,
      if (country != null) 'country': country,
      if (region != null) 'region': region,
      if (timezone != null) 'timezone': timezone,
      if (stallCount != null) 'stall_count': stallCount,
      if (dateOpened != null) 'date_opened': dateOpened,
      if (hasCheckins != null) 'has_checkins': hasCheckins,
      if (visited != null) 'visited': visited,
      if (lastSynced != null) 'last_synced': lastSynced,
    });
  }

  SitesCompanion copyWith({
    Value<int>? id,
    Value<int>? siteId,
    Value<String?>? locationId,
    Value<String>? name,
    Value<SiteStatus>? status,
    Value<double>? latitude,
    Value<double>? longitude,
    Value<String?>? city,
    Value<String?>? state,
    Value<String>? country,
    Value<String>? region,
    Value<String?>? timezone,
    Value<int?>? stallCount,
    Value<DateTime?>? dateOpened,
    Value<bool>? hasCheckins,
    Value<bool>? visited,
    Value<DateTime?>? lastSynced,
  }) {
    return SitesCompanion(
      id: id ?? this.id,
      siteId: siteId ?? this.siteId,
      locationId: locationId ?? this.locationId,
      name: name ?? this.name,
      status: status ?? this.status,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      city: city ?? this.city,
      state: state ?? this.state,
      country: country ?? this.country,
      region: region ?? this.region,
      timezone: timezone ?? this.timezone,
      stallCount: stallCount ?? this.stallCount,
      dateOpened: dateOpened ?? this.dateOpened,
      hasCheckins: hasCheckins ?? this.hasCheckins,
      visited: visited ?? this.visited,
      lastSynced: lastSynced ?? this.lastSynced,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (siteId.present) {
      map['site_id'] = Variable<int>(siteId.value);
    }
    if (locationId.present) {
      map['location_id'] = Variable<String>(locationId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(
        $SitesTable.$converterstatus.toSql(status.value),
      );
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (city.present) {
      map['city'] = Variable<String>(city.value);
    }
    if (state.present) {
      map['state'] = Variable<String>(state.value);
    }
    if (country.present) {
      map['country'] = Variable<String>(country.value);
    }
    if (region.present) {
      map['region'] = Variable<String>(region.value);
    }
    if (timezone.present) {
      map['timezone'] = Variable<String>(timezone.value);
    }
    if (stallCount.present) {
      map['stall_count'] = Variable<int>(stallCount.value);
    }
    if (dateOpened.present) {
      map['date_opened'] = Variable<DateTime>(dateOpened.value);
    }
    if (hasCheckins.present) {
      map['has_checkins'] = Variable<bool>(hasCheckins.value);
    }
    if (visited.present) {
      map['visited'] = Variable<bool>(visited.value);
    }
    if (lastSynced.present) {
      map['last_synced'] = Variable<DateTime>(lastSynced.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SitesCompanion(')
          ..write('id: $id, ')
          ..write('siteId: $siteId, ')
          ..write('locationId: $locationId, ')
          ..write('name: $name, ')
          ..write('status: $status, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('city: $city, ')
          ..write('state: $state, ')
          ..write('country: $country, ')
          ..write('region: $region, ')
          ..write('timezone: $timezone, ')
          ..write('stallCount: $stallCount, ')
          ..write('dateOpened: $dateOpened, ')
          ..write('hasCheckins: $hasCheckins, ')
          ..write('visited: $visited, ')
          ..write('lastSynced: $lastSynced')
          ..write(')'))
        .toString();
  }
}

class $VisitsTable extends Visits with TableInfo<$VisitsTable, Visit> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VisitsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _checkinIdMeta = const VerificationMeta(
    'checkinId',
  );
  @override
  late final GeneratedColumn<int> checkinId = GeneratedColumn<int>(
    'checkin_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _siteIdMeta = const VerificationMeta('siteId');
  @override
  late final GeneratedColumn<int> siteId = GeneratedColumn<int>(
    'site_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _checkinDateMeta = const VerificationMeta(
    'checkinDate',
  );
  @override
  late final GeneratedColumn<DateTime> checkinDate = GeneratedColumn<DateTime>(
    'checkin_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _checkinTimeMeta = const VerificationMeta(
    'checkinTime',
  );
  @override
  late final GeneratedColumn<DateTime> checkinTime = GeneratedColumn<DateTime>(
    'checkin_time',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isFirstMeta = const VerificationMeta(
    'isFirst',
  );
  @override
  late final GeneratedColumn<bool> isFirst = GeneratedColumn<bool>(
    'is_first',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_first" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  late final GeneratedColumnWithTypeConverter<CheckinMethod, String> method =
      GeneratedColumn<String>(
        'method',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: Constant(CheckinMethod.manual.name),
      ).withConverter<CheckinMethod>($VisitsTable.$convertermethod);
  static const VerificationMeta _notesPublicMeta = const VerificationMeta(
    'notesPublic',
  );
  @override
  late final GeneratedColumn<String> notesPublic = GeneratedColumn<String>(
    'notes_public',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _geoDistanceAccuracyMeta =
      const VerificationMeta('geoDistanceAccuracy');
  @override
  late final GeneratedColumn<int> geoDistanceAccuracy = GeneratedColumn<int>(
    'geo_distance_accuracy',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _geoDistanceMeta = const VerificationMeta(
    'geoDistance',
  );
  @override
  late final GeneratedColumn<int> geoDistance = GeneratedColumn<int>(
    'geo_distance',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _distinctUserSuperSeqMeta =
      const VerificationMeta('distinctUserSuperSeq');
  @override
  late final GeneratedColumn<int> distinctUserSuperSeq = GeneratedColumn<int>(
    'distinct_user_super_seq',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _importedAtMeta = const VerificationMeta(
    'importedAt',
  );
  @override
  late final GeneratedColumn<DateTime> importedAt = GeneratedColumn<DateTime>(
    'imported_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    checkinId,
    siteId,
    checkinDate,
    checkinTime,
    isFirst,
    method,
    notesPublic,
    geoDistanceAccuracy,
    geoDistance,
    distinctUserSuperSeq,
    importedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'visits';
  @override
  VerificationContext validateIntegrity(
    Insertable<Visit> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('checkin_id')) {
      context.handle(
        _checkinIdMeta,
        checkinId.isAcceptableOrUnknown(data['checkin_id']!, _checkinIdMeta),
      );
    } else if (isInserting) {
      context.missing(_checkinIdMeta);
    }
    if (data.containsKey('site_id')) {
      context.handle(
        _siteIdMeta,
        siteId.isAcceptableOrUnknown(data['site_id']!, _siteIdMeta),
      );
    } else if (isInserting) {
      context.missing(_siteIdMeta);
    }
    if (data.containsKey('checkin_date')) {
      context.handle(
        _checkinDateMeta,
        checkinDate.isAcceptableOrUnknown(
          data['checkin_date']!,
          _checkinDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_checkinDateMeta);
    }
    if (data.containsKey('checkin_time')) {
      context.handle(
        _checkinTimeMeta,
        checkinTime.isAcceptableOrUnknown(
          data['checkin_time']!,
          _checkinTimeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_checkinTimeMeta);
    }
    if (data.containsKey('is_first')) {
      context.handle(
        _isFirstMeta,
        isFirst.isAcceptableOrUnknown(data['is_first']!, _isFirstMeta),
      );
    }
    if (data.containsKey('notes_public')) {
      context.handle(
        _notesPublicMeta,
        notesPublic.isAcceptableOrUnknown(
          data['notes_public']!,
          _notesPublicMeta,
        ),
      );
    }
    if (data.containsKey('geo_distance_accuracy')) {
      context.handle(
        _geoDistanceAccuracyMeta,
        geoDistanceAccuracy.isAcceptableOrUnknown(
          data['geo_distance_accuracy']!,
          _geoDistanceAccuracyMeta,
        ),
      );
    }
    if (data.containsKey('geo_distance')) {
      context.handle(
        _geoDistanceMeta,
        geoDistance.isAcceptableOrUnknown(
          data['geo_distance']!,
          _geoDistanceMeta,
        ),
      );
    }
    if (data.containsKey('distinct_user_super_seq')) {
      context.handle(
        _distinctUserSuperSeqMeta,
        distinctUserSuperSeq.isAcceptableOrUnknown(
          data['distinct_user_super_seq']!,
          _distinctUserSuperSeqMeta,
        ),
      );
    }
    if (data.containsKey('imported_at')) {
      context.handle(
        _importedAtMeta,
        importedAt.isAcceptableOrUnknown(data['imported_at']!, _importedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_importedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Visit map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Visit(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      checkinId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}checkin_id'],
      )!,
      siteId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}site_id'],
      )!,
      checkinDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}checkin_date'],
      )!,
      checkinTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}checkin_time'],
      )!,
      isFirst: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_first'],
      )!,
      method: $VisitsTable.$convertermethod.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}method'],
        )!,
      ),
      notesPublic: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes_public'],
      ),
      geoDistanceAccuracy: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}geo_distance_accuracy'],
      ),
      geoDistance: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}geo_distance'],
      ),
      distinctUserSuperSeq: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}distinct_user_super_seq'],
      ),
      importedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}imported_at'],
      )!,
    );
  }

  @override
  $VisitsTable createAlias(String alias) {
    return $VisitsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<CheckinMethod, String, String> $convertermethod =
      const EnumNameConverter<CheckinMethod>(CheckinMethod.values);
}

class Visit extends DataClass implements Insertable<Visit> {
  final int id;
  final int checkinId;
  final int siteId;
  final DateTime checkinDate;
  final DateTime checkinTime;
  final bool isFirst;
  final CheckinMethod method;
  final String? notesPublic;
  final int? geoDistanceAccuracy;
  final int? geoDistance;
  final int? distinctUserSuperSeq;
  final DateTime importedAt;
  const Visit({
    required this.id,
    required this.checkinId,
    required this.siteId,
    required this.checkinDate,
    required this.checkinTime,
    required this.isFirst,
    required this.method,
    this.notesPublic,
    this.geoDistanceAccuracy,
    this.geoDistance,
    this.distinctUserSuperSeq,
    required this.importedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['checkin_id'] = Variable<int>(checkinId);
    map['site_id'] = Variable<int>(siteId);
    map['checkin_date'] = Variable<DateTime>(checkinDate);
    map['checkin_time'] = Variable<DateTime>(checkinTime);
    map['is_first'] = Variable<bool>(isFirst);
    {
      map['method'] = Variable<String>(
        $VisitsTable.$convertermethod.toSql(method),
      );
    }
    if (!nullToAbsent || notesPublic != null) {
      map['notes_public'] = Variable<String>(notesPublic);
    }
    if (!nullToAbsent || geoDistanceAccuracy != null) {
      map['geo_distance_accuracy'] = Variable<int>(geoDistanceAccuracy);
    }
    if (!nullToAbsent || geoDistance != null) {
      map['geo_distance'] = Variable<int>(geoDistance);
    }
    if (!nullToAbsent || distinctUserSuperSeq != null) {
      map['distinct_user_super_seq'] = Variable<int>(distinctUserSuperSeq);
    }
    map['imported_at'] = Variable<DateTime>(importedAt);
    return map;
  }

  VisitsCompanion toCompanion(bool nullToAbsent) {
    return VisitsCompanion(
      id: Value(id),
      checkinId: Value(checkinId),
      siteId: Value(siteId),
      checkinDate: Value(checkinDate),
      checkinTime: Value(checkinTime),
      isFirst: Value(isFirst),
      method: Value(method),
      notesPublic: notesPublic == null && nullToAbsent
          ? const Value.absent()
          : Value(notesPublic),
      geoDistanceAccuracy: geoDistanceAccuracy == null && nullToAbsent
          ? const Value.absent()
          : Value(geoDistanceAccuracy),
      geoDistance: geoDistance == null && nullToAbsent
          ? const Value.absent()
          : Value(geoDistance),
      distinctUserSuperSeq: distinctUserSuperSeq == null && nullToAbsent
          ? const Value.absent()
          : Value(distinctUserSuperSeq),
      importedAt: Value(importedAt),
    );
  }

  factory Visit.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Visit(
      id: serializer.fromJson<int>(json['id']),
      checkinId: serializer.fromJson<int>(json['checkinId']),
      siteId: serializer.fromJson<int>(json['siteId']),
      checkinDate: serializer.fromJson<DateTime>(json['checkinDate']),
      checkinTime: serializer.fromJson<DateTime>(json['checkinTime']),
      isFirst: serializer.fromJson<bool>(json['isFirst']),
      method: $VisitsTable.$convertermethod.fromJson(
        serializer.fromJson<String>(json['method']),
      ),
      notesPublic: serializer.fromJson<String?>(json['notesPublic']),
      geoDistanceAccuracy: serializer.fromJson<int?>(
        json['geoDistanceAccuracy'],
      ),
      geoDistance: serializer.fromJson<int?>(json['geoDistance']),
      distinctUserSuperSeq: serializer.fromJson<int?>(
        json['distinctUserSuperSeq'],
      ),
      importedAt: serializer.fromJson<DateTime>(json['importedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'checkinId': serializer.toJson<int>(checkinId),
      'siteId': serializer.toJson<int>(siteId),
      'checkinDate': serializer.toJson<DateTime>(checkinDate),
      'checkinTime': serializer.toJson<DateTime>(checkinTime),
      'isFirst': serializer.toJson<bool>(isFirst),
      'method': serializer.toJson<String>(
        $VisitsTable.$convertermethod.toJson(method),
      ),
      'notesPublic': serializer.toJson<String?>(notesPublic),
      'geoDistanceAccuracy': serializer.toJson<int?>(geoDistanceAccuracy),
      'geoDistance': serializer.toJson<int?>(geoDistance),
      'distinctUserSuperSeq': serializer.toJson<int?>(distinctUserSuperSeq),
      'importedAt': serializer.toJson<DateTime>(importedAt),
    };
  }

  Visit copyWith({
    int? id,
    int? checkinId,
    int? siteId,
    DateTime? checkinDate,
    DateTime? checkinTime,
    bool? isFirst,
    CheckinMethod? method,
    Value<String?> notesPublic = const Value.absent(),
    Value<int?> geoDistanceAccuracy = const Value.absent(),
    Value<int?> geoDistance = const Value.absent(),
    Value<int?> distinctUserSuperSeq = const Value.absent(),
    DateTime? importedAt,
  }) => Visit(
    id: id ?? this.id,
    checkinId: checkinId ?? this.checkinId,
    siteId: siteId ?? this.siteId,
    checkinDate: checkinDate ?? this.checkinDate,
    checkinTime: checkinTime ?? this.checkinTime,
    isFirst: isFirst ?? this.isFirst,
    method: method ?? this.method,
    notesPublic: notesPublic.present ? notesPublic.value : this.notesPublic,
    geoDistanceAccuracy: geoDistanceAccuracy.present
        ? geoDistanceAccuracy.value
        : this.geoDistanceAccuracy,
    geoDistance: geoDistance.present ? geoDistance.value : this.geoDistance,
    distinctUserSuperSeq: distinctUserSuperSeq.present
        ? distinctUserSuperSeq.value
        : this.distinctUserSuperSeq,
    importedAt: importedAt ?? this.importedAt,
  );
  Visit copyWithCompanion(VisitsCompanion data) {
    return Visit(
      id: data.id.present ? data.id.value : this.id,
      checkinId: data.checkinId.present ? data.checkinId.value : this.checkinId,
      siteId: data.siteId.present ? data.siteId.value : this.siteId,
      checkinDate: data.checkinDate.present
          ? data.checkinDate.value
          : this.checkinDate,
      checkinTime: data.checkinTime.present
          ? data.checkinTime.value
          : this.checkinTime,
      isFirst: data.isFirst.present ? data.isFirst.value : this.isFirst,
      method: data.method.present ? data.method.value : this.method,
      notesPublic: data.notesPublic.present
          ? data.notesPublic.value
          : this.notesPublic,
      geoDistanceAccuracy: data.geoDistanceAccuracy.present
          ? data.geoDistanceAccuracy.value
          : this.geoDistanceAccuracy,
      geoDistance: data.geoDistance.present
          ? data.geoDistance.value
          : this.geoDistance,
      distinctUserSuperSeq: data.distinctUserSuperSeq.present
          ? data.distinctUserSuperSeq.value
          : this.distinctUserSuperSeq,
      importedAt: data.importedAt.present
          ? data.importedAt.value
          : this.importedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Visit(')
          ..write('id: $id, ')
          ..write('checkinId: $checkinId, ')
          ..write('siteId: $siteId, ')
          ..write('checkinDate: $checkinDate, ')
          ..write('checkinTime: $checkinTime, ')
          ..write('isFirst: $isFirst, ')
          ..write('method: $method, ')
          ..write('notesPublic: $notesPublic, ')
          ..write('geoDistanceAccuracy: $geoDistanceAccuracy, ')
          ..write('geoDistance: $geoDistance, ')
          ..write('distinctUserSuperSeq: $distinctUserSuperSeq, ')
          ..write('importedAt: $importedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    checkinId,
    siteId,
    checkinDate,
    checkinTime,
    isFirst,
    method,
    notesPublic,
    geoDistanceAccuracy,
    geoDistance,
    distinctUserSuperSeq,
    importedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Visit &&
          other.id == this.id &&
          other.checkinId == this.checkinId &&
          other.siteId == this.siteId &&
          other.checkinDate == this.checkinDate &&
          other.checkinTime == this.checkinTime &&
          other.isFirst == this.isFirst &&
          other.method == this.method &&
          other.notesPublic == this.notesPublic &&
          other.geoDistanceAccuracy == this.geoDistanceAccuracy &&
          other.geoDistance == this.geoDistance &&
          other.distinctUserSuperSeq == this.distinctUserSuperSeq &&
          other.importedAt == this.importedAt);
}

class VisitsCompanion extends UpdateCompanion<Visit> {
  final Value<int> id;
  final Value<int> checkinId;
  final Value<int> siteId;
  final Value<DateTime> checkinDate;
  final Value<DateTime> checkinTime;
  final Value<bool> isFirst;
  final Value<CheckinMethod> method;
  final Value<String?> notesPublic;
  final Value<int?> geoDistanceAccuracy;
  final Value<int?> geoDistance;
  final Value<int?> distinctUserSuperSeq;
  final Value<DateTime> importedAt;
  const VisitsCompanion({
    this.id = const Value.absent(),
    this.checkinId = const Value.absent(),
    this.siteId = const Value.absent(),
    this.checkinDate = const Value.absent(),
    this.checkinTime = const Value.absent(),
    this.isFirst = const Value.absent(),
    this.method = const Value.absent(),
    this.notesPublic = const Value.absent(),
    this.geoDistanceAccuracy = const Value.absent(),
    this.geoDistance = const Value.absent(),
    this.distinctUserSuperSeq = const Value.absent(),
    this.importedAt = const Value.absent(),
  });
  VisitsCompanion.insert({
    this.id = const Value.absent(),
    required int checkinId,
    required int siteId,
    required DateTime checkinDate,
    required DateTime checkinTime,
    this.isFirst = const Value.absent(),
    this.method = const Value.absent(),
    this.notesPublic = const Value.absent(),
    this.geoDistanceAccuracy = const Value.absent(),
    this.geoDistance = const Value.absent(),
    this.distinctUserSuperSeq = const Value.absent(),
    required DateTime importedAt,
  }) : checkinId = Value(checkinId),
       siteId = Value(siteId),
       checkinDate = Value(checkinDate),
       checkinTime = Value(checkinTime),
       importedAt = Value(importedAt);
  static Insertable<Visit> custom({
    Expression<int>? id,
    Expression<int>? checkinId,
    Expression<int>? siteId,
    Expression<DateTime>? checkinDate,
    Expression<DateTime>? checkinTime,
    Expression<bool>? isFirst,
    Expression<String>? method,
    Expression<String>? notesPublic,
    Expression<int>? geoDistanceAccuracy,
    Expression<int>? geoDistance,
    Expression<int>? distinctUserSuperSeq,
    Expression<DateTime>? importedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (checkinId != null) 'checkin_id': checkinId,
      if (siteId != null) 'site_id': siteId,
      if (checkinDate != null) 'checkin_date': checkinDate,
      if (checkinTime != null) 'checkin_time': checkinTime,
      if (isFirst != null) 'is_first': isFirst,
      if (method != null) 'method': method,
      if (notesPublic != null) 'notes_public': notesPublic,
      if (geoDistanceAccuracy != null)
        'geo_distance_accuracy': geoDistanceAccuracy,
      if (geoDistance != null) 'geo_distance': geoDistance,
      if (distinctUserSuperSeq != null)
        'distinct_user_super_seq': distinctUserSuperSeq,
      if (importedAt != null) 'imported_at': importedAt,
    });
  }

  VisitsCompanion copyWith({
    Value<int>? id,
    Value<int>? checkinId,
    Value<int>? siteId,
    Value<DateTime>? checkinDate,
    Value<DateTime>? checkinTime,
    Value<bool>? isFirst,
    Value<CheckinMethod>? method,
    Value<String?>? notesPublic,
    Value<int?>? geoDistanceAccuracy,
    Value<int?>? geoDistance,
    Value<int?>? distinctUserSuperSeq,
    Value<DateTime>? importedAt,
  }) {
    return VisitsCompanion(
      id: id ?? this.id,
      checkinId: checkinId ?? this.checkinId,
      siteId: siteId ?? this.siteId,
      checkinDate: checkinDate ?? this.checkinDate,
      checkinTime: checkinTime ?? this.checkinTime,
      isFirst: isFirst ?? this.isFirst,
      method: method ?? this.method,
      notesPublic: notesPublic ?? this.notesPublic,
      geoDistanceAccuracy: geoDistanceAccuracy ?? this.geoDistanceAccuracy,
      geoDistance: geoDistance ?? this.geoDistance,
      distinctUserSuperSeq: distinctUserSuperSeq ?? this.distinctUserSuperSeq,
      importedAt: importedAt ?? this.importedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (checkinId.present) {
      map['checkin_id'] = Variable<int>(checkinId.value);
    }
    if (siteId.present) {
      map['site_id'] = Variable<int>(siteId.value);
    }
    if (checkinDate.present) {
      map['checkin_date'] = Variable<DateTime>(checkinDate.value);
    }
    if (checkinTime.present) {
      map['checkin_time'] = Variable<DateTime>(checkinTime.value);
    }
    if (isFirst.present) {
      map['is_first'] = Variable<bool>(isFirst.value);
    }
    if (method.present) {
      map['method'] = Variable<String>(
        $VisitsTable.$convertermethod.toSql(method.value),
      );
    }
    if (notesPublic.present) {
      map['notes_public'] = Variable<String>(notesPublic.value);
    }
    if (geoDistanceAccuracy.present) {
      map['geo_distance_accuracy'] = Variable<int>(geoDistanceAccuracy.value);
    }
    if (geoDistance.present) {
      map['geo_distance'] = Variable<int>(geoDistance.value);
    }
    if (distinctUserSuperSeq.present) {
      map['distinct_user_super_seq'] = Variable<int>(
        distinctUserSuperSeq.value,
      );
    }
    if (importedAt.present) {
      map['imported_at'] = Variable<DateTime>(importedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VisitsCompanion(')
          ..write('id: $id, ')
          ..write('checkinId: $checkinId, ')
          ..write('siteId: $siteId, ')
          ..write('checkinDate: $checkinDate, ')
          ..write('checkinTime: $checkinTime, ')
          ..write('isFirst: $isFirst, ')
          ..write('method: $method, ')
          ..write('notesPublic: $notesPublic, ')
          ..write('geoDistanceAccuracy: $geoDistanceAccuracy, ')
          ..write('geoDistance: $geoDistance, ')
          ..write('distinctUserSuperSeq: $distinctUserSuperSeq, ')
          ..write('importedAt: $importedAt')
          ..write(')'))
        .toString();
  }
}

class $PendingCheckinsTable extends PendingCheckins
    with TableInfo<$PendingCheckinsTable, PendingCheckin> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PendingCheckinsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _siteIdMeta = const VerificationMeta('siteId');
  @override
  late final GeneratedColumn<int> siteId = GeneratedColumn<int>(
    'site_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _checkinDateMeta = const VerificationMeta(
    'checkinDate',
  );
  @override
  late final GeneratedColumn<DateTime> checkinDate = GeneratedColumn<DateTime>(
    'checkin_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
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
  static const VerificationMeta _latitudeMeta = const VerificationMeta(
    'latitude',
  );
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
    'latitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _longitudeMeta = const VerificationMeta(
    'longitude',
  );
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
    'longitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _accuracyMeta = const VerificationMeta(
    'accuracy',
  );
  @override
  late final GeneratedColumn<double> accuracy = GeneratedColumn<double>(
    'accuracy',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesPublicMeta = const VerificationMeta(
    'notesPublic',
  );
  @override
  late final GeneratedColumn<String> notesPublic = GeneratedColumn<String>(
    'notes_public',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<PendingStatus, String> status =
      GeneratedColumn<String>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: Constant(PendingStatus.pending.name),
      ).withConverter<PendingStatus>($PendingCheckinsTable.$converterstatus);
  static const VerificationMeta _attemptsMeta = const VerificationMeta(
    'attempts',
  );
  @override
  late final GeneratedColumn<int> attempts = GeneratedColumn<int>(
    'attempts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastAttemptAtMeta = const VerificationMeta(
    'lastAttemptAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastAttemptAt =
      GeneratedColumn<DateTime>(
        'last_attempt_at',
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    siteId,
    checkinDate,
    createdAt,
    latitude,
    longitude,
    accuracy,
    notesPublic,
    status,
    attempts,
    lastAttemptAt,
    lastError,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pending_checkins';
  @override
  VerificationContext validateIntegrity(
    Insertable<PendingCheckin> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('site_id')) {
      context.handle(
        _siteIdMeta,
        siteId.isAcceptableOrUnknown(data['site_id']!, _siteIdMeta),
      );
    } else if (isInserting) {
      context.missing(_siteIdMeta);
    }
    if (data.containsKey('checkin_date')) {
      context.handle(
        _checkinDateMeta,
        checkinDate.isAcceptableOrUnknown(
          data['checkin_date']!,
          _checkinDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_checkinDateMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('latitude')) {
      context.handle(
        _latitudeMeta,
        latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta),
      );
    }
    if (data.containsKey('longitude')) {
      context.handle(
        _longitudeMeta,
        longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta),
      );
    }
    if (data.containsKey('accuracy')) {
      context.handle(
        _accuracyMeta,
        accuracy.isAcceptableOrUnknown(data['accuracy']!, _accuracyMeta),
      );
    }
    if (data.containsKey('notes_public')) {
      context.handle(
        _notesPublicMeta,
        notesPublic.isAcceptableOrUnknown(
          data['notes_public']!,
          _notesPublicMeta,
        ),
      );
    }
    if (data.containsKey('attempts')) {
      context.handle(
        _attemptsMeta,
        attempts.isAcceptableOrUnknown(data['attempts']!, _attemptsMeta),
      );
    }
    if (data.containsKey('last_attempt_at')) {
      context.handle(
        _lastAttemptAtMeta,
        lastAttemptAt.isAcceptableOrUnknown(
          data['last_attempt_at']!,
          _lastAttemptAtMeta,
        ),
      );
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PendingCheckin map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PendingCheckin(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      siteId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}site_id'],
      )!,
      checkinDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}checkin_date'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      latitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}latitude'],
      ),
      longitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}longitude'],
      ),
      accuracy: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}accuracy'],
      ),
      notesPublic: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes_public'],
      ),
      status: $PendingCheckinsTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}status'],
        )!,
      ),
      attempts: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempts'],
      )!,
      lastAttemptAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_attempt_at'],
      ),
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
    );
  }

  @override
  $PendingCheckinsTable createAlias(String alias) {
    return $PendingCheckinsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<PendingStatus, String, String> $converterstatus =
      const EnumNameConverter<PendingStatus>(PendingStatus.values);
}

class PendingCheckin extends DataClass implements Insertable<PendingCheckin> {
  final int id;
  final int siteId;
  final DateTime checkinDate;
  final DateTime createdAt;
  final double? latitude;
  final double? longitude;
  final double? accuracy;
  final String? notesPublic;
  final PendingStatus status;
  final int attempts;
  final DateTime? lastAttemptAt;
  final String? lastError;
  const PendingCheckin({
    required this.id,
    required this.siteId,
    required this.checkinDate,
    required this.createdAt,
    this.latitude,
    this.longitude,
    this.accuracy,
    this.notesPublic,
    required this.status,
    required this.attempts,
    this.lastAttemptAt,
    this.lastError,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['site_id'] = Variable<int>(siteId);
    map['checkin_date'] = Variable<DateTime>(checkinDate);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || latitude != null) {
      map['latitude'] = Variable<double>(latitude);
    }
    if (!nullToAbsent || longitude != null) {
      map['longitude'] = Variable<double>(longitude);
    }
    if (!nullToAbsent || accuracy != null) {
      map['accuracy'] = Variable<double>(accuracy);
    }
    if (!nullToAbsent || notesPublic != null) {
      map['notes_public'] = Variable<String>(notesPublic);
    }
    {
      map['status'] = Variable<String>(
        $PendingCheckinsTable.$converterstatus.toSql(status),
      );
    }
    map['attempts'] = Variable<int>(attempts);
    if (!nullToAbsent || lastAttemptAt != null) {
      map['last_attempt_at'] = Variable<DateTime>(lastAttemptAt);
    }
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    return map;
  }

  PendingCheckinsCompanion toCompanion(bool nullToAbsent) {
    return PendingCheckinsCompanion(
      id: Value(id),
      siteId: Value(siteId),
      checkinDate: Value(checkinDate),
      createdAt: Value(createdAt),
      latitude: latitude == null && nullToAbsent
          ? const Value.absent()
          : Value(latitude),
      longitude: longitude == null && nullToAbsent
          ? const Value.absent()
          : Value(longitude),
      accuracy: accuracy == null && nullToAbsent
          ? const Value.absent()
          : Value(accuracy),
      notesPublic: notesPublic == null && nullToAbsent
          ? const Value.absent()
          : Value(notesPublic),
      status: Value(status),
      attempts: Value(attempts),
      lastAttemptAt: lastAttemptAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastAttemptAt),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
    );
  }

  factory PendingCheckin.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PendingCheckin(
      id: serializer.fromJson<int>(json['id']),
      siteId: serializer.fromJson<int>(json['siteId']),
      checkinDate: serializer.fromJson<DateTime>(json['checkinDate']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      latitude: serializer.fromJson<double?>(json['latitude']),
      longitude: serializer.fromJson<double?>(json['longitude']),
      accuracy: serializer.fromJson<double?>(json['accuracy']),
      notesPublic: serializer.fromJson<String?>(json['notesPublic']),
      status: $PendingCheckinsTable.$converterstatus.fromJson(
        serializer.fromJson<String>(json['status']),
      ),
      attempts: serializer.fromJson<int>(json['attempts']),
      lastAttemptAt: serializer.fromJson<DateTime?>(json['lastAttemptAt']),
      lastError: serializer.fromJson<String?>(json['lastError']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'siteId': serializer.toJson<int>(siteId),
      'checkinDate': serializer.toJson<DateTime>(checkinDate),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'latitude': serializer.toJson<double?>(latitude),
      'longitude': serializer.toJson<double?>(longitude),
      'accuracy': serializer.toJson<double?>(accuracy),
      'notesPublic': serializer.toJson<String?>(notesPublic),
      'status': serializer.toJson<String>(
        $PendingCheckinsTable.$converterstatus.toJson(status),
      ),
      'attempts': serializer.toJson<int>(attempts),
      'lastAttemptAt': serializer.toJson<DateTime?>(lastAttemptAt),
      'lastError': serializer.toJson<String?>(lastError),
    };
  }

  PendingCheckin copyWith({
    int? id,
    int? siteId,
    DateTime? checkinDate,
    DateTime? createdAt,
    Value<double?> latitude = const Value.absent(),
    Value<double?> longitude = const Value.absent(),
    Value<double?> accuracy = const Value.absent(),
    Value<String?> notesPublic = const Value.absent(),
    PendingStatus? status,
    int? attempts,
    Value<DateTime?> lastAttemptAt = const Value.absent(),
    Value<String?> lastError = const Value.absent(),
  }) => PendingCheckin(
    id: id ?? this.id,
    siteId: siteId ?? this.siteId,
    checkinDate: checkinDate ?? this.checkinDate,
    createdAt: createdAt ?? this.createdAt,
    latitude: latitude.present ? latitude.value : this.latitude,
    longitude: longitude.present ? longitude.value : this.longitude,
    accuracy: accuracy.present ? accuracy.value : this.accuracy,
    notesPublic: notesPublic.present ? notesPublic.value : this.notesPublic,
    status: status ?? this.status,
    attempts: attempts ?? this.attempts,
    lastAttemptAt: lastAttemptAt.present
        ? lastAttemptAt.value
        : this.lastAttemptAt,
    lastError: lastError.present ? lastError.value : this.lastError,
  );
  PendingCheckin copyWithCompanion(PendingCheckinsCompanion data) {
    return PendingCheckin(
      id: data.id.present ? data.id.value : this.id,
      siteId: data.siteId.present ? data.siteId.value : this.siteId,
      checkinDate: data.checkinDate.present
          ? data.checkinDate.value
          : this.checkinDate,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      accuracy: data.accuracy.present ? data.accuracy.value : this.accuracy,
      notesPublic: data.notesPublic.present
          ? data.notesPublic.value
          : this.notesPublic,
      status: data.status.present ? data.status.value : this.status,
      attempts: data.attempts.present ? data.attempts.value : this.attempts,
      lastAttemptAt: data.lastAttemptAt.present
          ? data.lastAttemptAt.value
          : this.lastAttemptAt,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PendingCheckin(')
          ..write('id: $id, ')
          ..write('siteId: $siteId, ')
          ..write('checkinDate: $checkinDate, ')
          ..write('createdAt: $createdAt, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('accuracy: $accuracy, ')
          ..write('notesPublic: $notesPublic, ')
          ..write('status: $status, ')
          ..write('attempts: $attempts, ')
          ..write('lastAttemptAt: $lastAttemptAt, ')
          ..write('lastError: $lastError')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    siteId,
    checkinDate,
    createdAt,
    latitude,
    longitude,
    accuracy,
    notesPublic,
    status,
    attempts,
    lastAttemptAt,
    lastError,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PendingCheckin &&
          other.id == this.id &&
          other.siteId == this.siteId &&
          other.checkinDate == this.checkinDate &&
          other.createdAt == this.createdAt &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.accuracy == this.accuracy &&
          other.notesPublic == this.notesPublic &&
          other.status == this.status &&
          other.attempts == this.attempts &&
          other.lastAttemptAt == this.lastAttemptAt &&
          other.lastError == this.lastError);
}

class PendingCheckinsCompanion extends UpdateCompanion<PendingCheckin> {
  final Value<int> id;
  final Value<int> siteId;
  final Value<DateTime> checkinDate;
  final Value<DateTime> createdAt;
  final Value<double?> latitude;
  final Value<double?> longitude;
  final Value<double?> accuracy;
  final Value<String?> notesPublic;
  final Value<PendingStatus> status;
  final Value<int> attempts;
  final Value<DateTime?> lastAttemptAt;
  final Value<String?> lastError;
  const PendingCheckinsCompanion({
    this.id = const Value.absent(),
    this.siteId = const Value.absent(),
    this.checkinDate = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.accuracy = const Value.absent(),
    this.notesPublic = const Value.absent(),
    this.status = const Value.absent(),
    this.attempts = const Value.absent(),
    this.lastAttemptAt = const Value.absent(),
    this.lastError = const Value.absent(),
  });
  PendingCheckinsCompanion.insert({
    this.id = const Value.absent(),
    required int siteId,
    required DateTime checkinDate,
    required DateTime createdAt,
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.accuracy = const Value.absent(),
    this.notesPublic = const Value.absent(),
    this.status = const Value.absent(),
    this.attempts = const Value.absent(),
    this.lastAttemptAt = const Value.absent(),
    this.lastError = const Value.absent(),
  }) : siteId = Value(siteId),
       checkinDate = Value(checkinDate),
       createdAt = Value(createdAt);
  static Insertable<PendingCheckin> custom({
    Expression<int>? id,
    Expression<int>? siteId,
    Expression<DateTime>? checkinDate,
    Expression<DateTime>? createdAt,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<double>? accuracy,
    Expression<String>? notesPublic,
    Expression<String>? status,
    Expression<int>? attempts,
    Expression<DateTime>? lastAttemptAt,
    Expression<String>? lastError,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (siteId != null) 'site_id': siteId,
      if (checkinDate != null) 'checkin_date': checkinDate,
      if (createdAt != null) 'created_at': createdAt,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (accuracy != null) 'accuracy': accuracy,
      if (notesPublic != null) 'notes_public': notesPublic,
      if (status != null) 'status': status,
      if (attempts != null) 'attempts': attempts,
      if (lastAttemptAt != null) 'last_attempt_at': lastAttemptAt,
      if (lastError != null) 'last_error': lastError,
    });
  }

  PendingCheckinsCompanion copyWith({
    Value<int>? id,
    Value<int>? siteId,
    Value<DateTime>? checkinDate,
    Value<DateTime>? createdAt,
    Value<double?>? latitude,
    Value<double?>? longitude,
    Value<double?>? accuracy,
    Value<String?>? notesPublic,
    Value<PendingStatus>? status,
    Value<int>? attempts,
    Value<DateTime?>? lastAttemptAt,
    Value<String?>? lastError,
  }) {
    return PendingCheckinsCompanion(
      id: id ?? this.id,
      siteId: siteId ?? this.siteId,
      checkinDate: checkinDate ?? this.checkinDate,
      createdAt: createdAt ?? this.createdAt,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      accuracy: accuracy ?? this.accuracy,
      notesPublic: notesPublic ?? this.notesPublic,
      status: status ?? this.status,
      attempts: attempts ?? this.attempts,
      lastAttemptAt: lastAttemptAt ?? this.lastAttemptAt,
      lastError: lastError ?? this.lastError,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (siteId.present) {
      map['site_id'] = Variable<int>(siteId.value);
    }
    if (checkinDate.present) {
      map['checkin_date'] = Variable<DateTime>(checkinDate.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (accuracy.present) {
      map['accuracy'] = Variable<double>(accuracy.value);
    }
    if (notesPublic.present) {
      map['notes_public'] = Variable<String>(notesPublic.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(
        $PendingCheckinsTable.$converterstatus.toSql(status.value),
      );
    }
    if (attempts.present) {
      map['attempts'] = Variable<int>(attempts.value);
    }
    if (lastAttemptAt.present) {
      map['last_attempt_at'] = Variable<DateTime>(lastAttemptAt.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PendingCheckinsCompanion(')
          ..write('id: $id, ')
          ..write('siteId: $siteId, ')
          ..write('checkinDate: $checkinDate, ')
          ..write('createdAt: $createdAt, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('accuracy: $accuracy, ')
          ..write('notesPublic: $notesPublic, ')
          ..write('status: $status, ')
          ..write('attempts: $attempts, ')
          ..write('lastAttemptAt: $lastAttemptAt, ')
          ..write('lastError: $lastError')
          ..write(')'))
        .toString();
  }
}

class $SiteCheckinsTable extends SiteCheckins
    with TableInfo<$SiteCheckinsTable, SiteCheckin> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SiteCheckinsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _checkinIdMeta = const VerificationMeta(
    'checkinId',
  );
  @override
  late final GeneratedColumn<int> checkinId = GeneratedColumn<int>(
    'checkin_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _siteIdMeta = const VerificationMeta('siteId');
  @override
  late final GeneratedColumn<int> siteId = GeneratedColumn<int>(
    'site_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _odUserIdMeta = const VerificationMeta(
    'odUserId',
  );
  @override
  late final GeneratedColumn<int> odUserId = GeneratedColumn<int>(
    'od_user_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
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
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _checkinDateMeta = const VerificationMeta(
    'checkinDate',
  );
  @override
  late final GeneratedColumn<DateTime> checkinDate = GeneratedColumn<DateTime>(
    'checkin_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _checkinTimeMeta = const VerificationMeta(
    'checkinTime',
  );
  @override
  late final GeneratedColumn<DateTime> checkinTime = GeneratedColumn<DateTime>(
    'checkin_time',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isFirstAtSuperchargerMeta =
      const VerificationMeta('isFirstAtSupercharger');
  @override
  late final GeneratedColumn<bool> isFirstAtSupercharger =
      GeneratedColumn<bool>(
        'is_first_at_supercharger',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_first_at_supercharger" IN (0, 1))',
        ),
        defaultValue: const Constant(false),
      );
  static const VerificationMeta _daysAfterOpenMeta = const VerificationMeta(
    'daysAfterOpen',
  );
  @override
  late final GeneratedColumn<int> daysAfterOpen = GeneratedColumn<int>(
    'days_after_open',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncedAtMeta = const VerificationMeta(
    'syncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> syncedAt = GeneratedColumn<DateTime>(
    'synced_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    checkinId,
    siteId,
    odUserId,
    username,
    displayName,
    checkinDate,
    checkinTime,
    isFirstAtSupercharger,
    daysAfterOpen,
    syncedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'site_checkins';
  @override
  VerificationContext validateIntegrity(
    Insertable<SiteCheckin> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('checkin_id')) {
      context.handle(
        _checkinIdMeta,
        checkinId.isAcceptableOrUnknown(data['checkin_id']!, _checkinIdMeta),
      );
    } else if (isInserting) {
      context.missing(_checkinIdMeta);
    }
    if (data.containsKey('site_id')) {
      context.handle(
        _siteIdMeta,
        siteId.isAcceptableOrUnknown(data['site_id']!, _siteIdMeta),
      );
    } else if (isInserting) {
      context.missing(_siteIdMeta);
    }
    if (data.containsKey('od_user_id')) {
      context.handle(
        _odUserIdMeta,
        odUserId.isAcceptableOrUnknown(data['od_user_id']!, _odUserIdMeta),
      );
    } else if (isInserting) {
      context.missing(_odUserIdMeta);
    }
    if (data.containsKey('username')) {
      context.handle(
        _usernameMeta,
        username.isAcceptableOrUnknown(data['username']!, _usernameMeta),
      );
    } else if (isInserting) {
      context.missing(_usernameMeta);
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
    if (data.containsKey('checkin_date')) {
      context.handle(
        _checkinDateMeta,
        checkinDate.isAcceptableOrUnknown(
          data['checkin_date']!,
          _checkinDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_checkinDateMeta);
    }
    if (data.containsKey('checkin_time')) {
      context.handle(
        _checkinTimeMeta,
        checkinTime.isAcceptableOrUnknown(
          data['checkin_time']!,
          _checkinTimeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_checkinTimeMeta);
    }
    if (data.containsKey('is_first_at_supercharger')) {
      context.handle(
        _isFirstAtSuperchargerMeta,
        isFirstAtSupercharger.isAcceptableOrUnknown(
          data['is_first_at_supercharger']!,
          _isFirstAtSuperchargerMeta,
        ),
      );
    }
    if (data.containsKey('days_after_open')) {
      context.handle(
        _daysAfterOpenMeta,
        daysAfterOpen.isAcceptableOrUnknown(
          data['days_after_open']!,
          _daysAfterOpenMeta,
        ),
      );
    }
    if (data.containsKey('synced_at')) {
      context.handle(
        _syncedAtMeta,
        syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_syncedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SiteCheckin map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SiteCheckin(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      checkinId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}checkin_id'],
      )!,
      siteId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}site_id'],
      )!,
      odUserId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}od_user_id'],
      )!,
      username: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}username'],
      )!,
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      ),
      checkinDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}checkin_date'],
      )!,
      checkinTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}checkin_time'],
      )!,
      isFirstAtSupercharger: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_first_at_supercharger'],
      )!,
      daysAfterOpen: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}days_after_open'],
      ),
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}synced_at'],
      )!,
    );
  }

  @override
  $SiteCheckinsTable createAlias(String alias) {
    return $SiteCheckinsTable(attachedDatabase, alias);
  }
}

class SiteCheckin extends DataClass implements Insertable<SiteCheckin> {
  final int id;
  final int checkinId;
  final int siteId;
  final int odUserId;
  final String username;
  final String? displayName;
  final DateTime checkinDate;
  final DateTime checkinTime;
  final bool isFirstAtSupercharger;
  final int? daysAfterOpen;
  final DateTime syncedAt;
  const SiteCheckin({
    required this.id,
    required this.checkinId,
    required this.siteId,
    required this.odUserId,
    required this.username,
    this.displayName,
    required this.checkinDate,
    required this.checkinTime,
    required this.isFirstAtSupercharger,
    this.daysAfterOpen,
    required this.syncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['checkin_id'] = Variable<int>(checkinId);
    map['site_id'] = Variable<int>(siteId);
    map['od_user_id'] = Variable<int>(odUserId);
    map['username'] = Variable<String>(username);
    if (!nullToAbsent || displayName != null) {
      map['display_name'] = Variable<String>(displayName);
    }
    map['checkin_date'] = Variable<DateTime>(checkinDate);
    map['checkin_time'] = Variable<DateTime>(checkinTime);
    map['is_first_at_supercharger'] = Variable<bool>(isFirstAtSupercharger);
    if (!nullToAbsent || daysAfterOpen != null) {
      map['days_after_open'] = Variable<int>(daysAfterOpen);
    }
    map['synced_at'] = Variable<DateTime>(syncedAt);
    return map;
  }

  SiteCheckinsCompanion toCompanion(bool nullToAbsent) {
    return SiteCheckinsCompanion(
      id: Value(id),
      checkinId: Value(checkinId),
      siteId: Value(siteId),
      odUserId: Value(odUserId),
      username: Value(username),
      displayName: displayName == null && nullToAbsent
          ? const Value.absent()
          : Value(displayName),
      checkinDate: Value(checkinDate),
      checkinTime: Value(checkinTime),
      isFirstAtSupercharger: Value(isFirstAtSupercharger),
      daysAfterOpen: daysAfterOpen == null && nullToAbsent
          ? const Value.absent()
          : Value(daysAfterOpen),
      syncedAt: Value(syncedAt),
    );
  }

  factory SiteCheckin.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SiteCheckin(
      id: serializer.fromJson<int>(json['id']),
      checkinId: serializer.fromJson<int>(json['checkinId']),
      siteId: serializer.fromJson<int>(json['siteId']),
      odUserId: serializer.fromJson<int>(json['odUserId']),
      username: serializer.fromJson<String>(json['username']),
      displayName: serializer.fromJson<String?>(json['displayName']),
      checkinDate: serializer.fromJson<DateTime>(json['checkinDate']),
      checkinTime: serializer.fromJson<DateTime>(json['checkinTime']),
      isFirstAtSupercharger: serializer.fromJson<bool>(
        json['isFirstAtSupercharger'],
      ),
      daysAfterOpen: serializer.fromJson<int?>(json['daysAfterOpen']),
      syncedAt: serializer.fromJson<DateTime>(json['syncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'checkinId': serializer.toJson<int>(checkinId),
      'siteId': serializer.toJson<int>(siteId),
      'odUserId': serializer.toJson<int>(odUserId),
      'username': serializer.toJson<String>(username),
      'displayName': serializer.toJson<String?>(displayName),
      'checkinDate': serializer.toJson<DateTime>(checkinDate),
      'checkinTime': serializer.toJson<DateTime>(checkinTime),
      'isFirstAtSupercharger': serializer.toJson<bool>(isFirstAtSupercharger),
      'daysAfterOpen': serializer.toJson<int?>(daysAfterOpen),
      'syncedAt': serializer.toJson<DateTime>(syncedAt),
    };
  }

  SiteCheckin copyWith({
    int? id,
    int? checkinId,
    int? siteId,
    int? odUserId,
    String? username,
    Value<String?> displayName = const Value.absent(),
    DateTime? checkinDate,
    DateTime? checkinTime,
    bool? isFirstAtSupercharger,
    Value<int?> daysAfterOpen = const Value.absent(),
    DateTime? syncedAt,
  }) => SiteCheckin(
    id: id ?? this.id,
    checkinId: checkinId ?? this.checkinId,
    siteId: siteId ?? this.siteId,
    odUserId: odUserId ?? this.odUserId,
    username: username ?? this.username,
    displayName: displayName.present ? displayName.value : this.displayName,
    checkinDate: checkinDate ?? this.checkinDate,
    checkinTime: checkinTime ?? this.checkinTime,
    isFirstAtSupercharger: isFirstAtSupercharger ?? this.isFirstAtSupercharger,
    daysAfterOpen: daysAfterOpen.present
        ? daysAfterOpen.value
        : this.daysAfterOpen,
    syncedAt: syncedAt ?? this.syncedAt,
  );
  SiteCheckin copyWithCompanion(SiteCheckinsCompanion data) {
    return SiteCheckin(
      id: data.id.present ? data.id.value : this.id,
      checkinId: data.checkinId.present ? data.checkinId.value : this.checkinId,
      siteId: data.siteId.present ? data.siteId.value : this.siteId,
      odUserId: data.odUserId.present ? data.odUserId.value : this.odUserId,
      username: data.username.present ? data.username.value : this.username,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      checkinDate: data.checkinDate.present
          ? data.checkinDate.value
          : this.checkinDate,
      checkinTime: data.checkinTime.present
          ? data.checkinTime.value
          : this.checkinTime,
      isFirstAtSupercharger: data.isFirstAtSupercharger.present
          ? data.isFirstAtSupercharger.value
          : this.isFirstAtSupercharger,
      daysAfterOpen: data.daysAfterOpen.present
          ? data.daysAfterOpen.value
          : this.daysAfterOpen,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SiteCheckin(')
          ..write('id: $id, ')
          ..write('checkinId: $checkinId, ')
          ..write('siteId: $siteId, ')
          ..write('odUserId: $odUserId, ')
          ..write('username: $username, ')
          ..write('displayName: $displayName, ')
          ..write('checkinDate: $checkinDate, ')
          ..write('checkinTime: $checkinTime, ')
          ..write('isFirstAtSupercharger: $isFirstAtSupercharger, ')
          ..write('daysAfterOpen: $daysAfterOpen, ')
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    checkinId,
    siteId,
    odUserId,
    username,
    displayName,
    checkinDate,
    checkinTime,
    isFirstAtSupercharger,
    daysAfterOpen,
    syncedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SiteCheckin &&
          other.id == this.id &&
          other.checkinId == this.checkinId &&
          other.siteId == this.siteId &&
          other.odUserId == this.odUserId &&
          other.username == this.username &&
          other.displayName == this.displayName &&
          other.checkinDate == this.checkinDate &&
          other.checkinTime == this.checkinTime &&
          other.isFirstAtSupercharger == this.isFirstAtSupercharger &&
          other.daysAfterOpen == this.daysAfterOpen &&
          other.syncedAt == this.syncedAt);
}

class SiteCheckinsCompanion extends UpdateCompanion<SiteCheckin> {
  final Value<int> id;
  final Value<int> checkinId;
  final Value<int> siteId;
  final Value<int> odUserId;
  final Value<String> username;
  final Value<String?> displayName;
  final Value<DateTime> checkinDate;
  final Value<DateTime> checkinTime;
  final Value<bool> isFirstAtSupercharger;
  final Value<int?> daysAfterOpen;
  final Value<DateTime> syncedAt;
  const SiteCheckinsCompanion({
    this.id = const Value.absent(),
    this.checkinId = const Value.absent(),
    this.siteId = const Value.absent(),
    this.odUserId = const Value.absent(),
    this.username = const Value.absent(),
    this.displayName = const Value.absent(),
    this.checkinDate = const Value.absent(),
    this.checkinTime = const Value.absent(),
    this.isFirstAtSupercharger = const Value.absent(),
    this.daysAfterOpen = const Value.absent(),
    this.syncedAt = const Value.absent(),
  });
  SiteCheckinsCompanion.insert({
    this.id = const Value.absent(),
    required int checkinId,
    required int siteId,
    required int odUserId,
    required String username,
    this.displayName = const Value.absent(),
    required DateTime checkinDate,
    required DateTime checkinTime,
    this.isFirstAtSupercharger = const Value.absent(),
    this.daysAfterOpen = const Value.absent(),
    required DateTime syncedAt,
  }) : checkinId = Value(checkinId),
       siteId = Value(siteId),
       odUserId = Value(odUserId),
       username = Value(username),
       checkinDate = Value(checkinDate),
       checkinTime = Value(checkinTime),
       syncedAt = Value(syncedAt);
  static Insertable<SiteCheckin> custom({
    Expression<int>? id,
    Expression<int>? checkinId,
    Expression<int>? siteId,
    Expression<int>? odUserId,
    Expression<String>? username,
    Expression<String>? displayName,
    Expression<DateTime>? checkinDate,
    Expression<DateTime>? checkinTime,
    Expression<bool>? isFirstAtSupercharger,
    Expression<int>? daysAfterOpen,
    Expression<DateTime>? syncedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (checkinId != null) 'checkin_id': checkinId,
      if (siteId != null) 'site_id': siteId,
      if (odUserId != null) 'od_user_id': odUserId,
      if (username != null) 'username': username,
      if (displayName != null) 'display_name': displayName,
      if (checkinDate != null) 'checkin_date': checkinDate,
      if (checkinTime != null) 'checkin_time': checkinTime,
      if (isFirstAtSupercharger != null)
        'is_first_at_supercharger': isFirstAtSupercharger,
      if (daysAfterOpen != null) 'days_after_open': daysAfterOpen,
      if (syncedAt != null) 'synced_at': syncedAt,
    });
  }

  SiteCheckinsCompanion copyWith({
    Value<int>? id,
    Value<int>? checkinId,
    Value<int>? siteId,
    Value<int>? odUserId,
    Value<String>? username,
    Value<String?>? displayName,
    Value<DateTime>? checkinDate,
    Value<DateTime>? checkinTime,
    Value<bool>? isFirstAtSupercharger,
    Value<int?>? daysAfterOpen,
    Value<DateTime>? syncedAt,
  }) {
    return SiteCheckinsCompanion(
      id: id ?? this.id,
      checkinId: checkinId ?? this.checkinId,
      siteId: siteId ?? this.siteId,
      odUserId: odUserId ?? this.odUserId,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      checkinDate: checkinDate ?? this.checkinDate,
      checkinTime: checkinTime ?? this.checkinTime,
      isFirstAtSupercharger:
          isFirstAtSupercharger ?? this.isFirstAtSupercharger,
      daysAfterOpen: daysAfterOpen ?? this.daysAfterOpen,
      syncedAt: syncedAt ?? this.syncedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (checkinId.present) {
      map['checkin_id'] = Variable<int>(checkinId.value);
    }
    if (siteId.present) {
      map['site_id'] = Variable<int>(siteId.value);
    }
    if (odUserId.present) {
      map['od_user_id'] = Variable<int>(odUserId.value);
    }
    if (username.present) {
      map['username'] = Variable<String>(username.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (checkinDate.present) {
      map['checkin_date'] = Variable<DateTime>(checkinDate.value);
    }
    if (checkinTime.present) {
      map['checkin_time'] = Variable<DateTime>(checkinTime.value);
    }
    if (isFirstAtSupercharger.present) {
      map['is_first_at_supercharger'] = Variable<bool>(
        isFirstAtSupercharger.value,
      );
    }
    if (daysAfterOpen.present) {
      map['days_after_open'] = Variable<int>(daysAfterOpen.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<DateTime>(syncedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SiteCheckinsCompanion(')
          ..write('id: $id, ')
          ..write('checkinId: $checkinId, ')
          ..write('siteId: $siteId, ')
          ..write('odUserId: $odUserId, ')
          ..write('username: $username, ')
          ..write('displayName: $displayName, ')
          ..write('checkinDate: $checkinDate, ')
          ..write('checkinTime: $checkinTime, ')
          ..write('isFirstAtSupercharger: $isFirstAtSupercharger, ')
          ..write('daysAfterOpen: $daysAfterOpen, ')
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }
}

class $UserSettingsTableTable extends UserSettingsTable
    with TableInfo<$UserSettingsTableTable, UserSettingsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserSettingsTableTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _odUserIdMeta = const VerificationMeta(
    'odUserId',
  );
  @override
  late final GeneratedColumn<int> odUserId = GeneratedColumn<int>(
    'od_user_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _usernameMeta = const VerificationMeta(
    'username',
  );
  @override
  late final GeneratedColumn<String> username = GeneratedColumn<String>(
    'username',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isAuthenticatedMeta = const VerificationMeta(
    'isAuthenticated',
  );
  @override
  late final GeneratedColumn<bool> isAuthenticated = GeneratedColumn<bool>(
    'is_authenticated',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_authenticated" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _firstLoginAtMeta = const VerificationMeta(
    'firstLoginAt',
  );
  @override
  late final GeneratedColumn<DateTime> firstLoginAt = GeneratedColumn<DateTime>(
    'first_login_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastLoginAtMeta = const VerificationMeta(
    'lastLoginAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastLoginAt = GeneratedColumn<DateTime>(
    'last_login_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastXlsxSyncAtMeta = const VerificationMeta(
    'lastXlsxSyncAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastXlsxSyncAt =
      GeneratedColumn<DateTime>(
        'last_xlsx_sync_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  @override
  late final GeneratedColumnWithTypeConverter<PollingInterval, String>
  pollingInterval =
      GeneratedColumn<String>(
        'polling_interval',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: Constant(PollingInterval.hours24.name),
      ).withConverter<PollingInterval>(
        $UserSettingsTableTable.$converterpollingInterval,
      );
  static const VerificationMeta _notificationRadiusKmMeta =
      const VerificationMeta('notificationRadiusKm');
  @override
  late final GeneratedColumn<double> notificationRadiusKm =
      GeneratedColumn<double>(
        'notification_radius_km',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
        defaultValue: const Constant(100.0),
      );
  @override
  late final GeneratedColumnWithTypeConverter<MapFilter, String> mapFilter =
      GeneratedColumn<String>(
        'map_filter',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: Constant(MapFilter.openUnvisited.name),
      ).withConverter<MapFilter>($UserSettingsTableTable.$convertermapFilter);
  static const VerificationMeta _showVisitedOnMapMeta = const VerificationMeta(
    'showVisitedOnMap',
  );
  @override
  late final GeneratedColumn<bool> showVisitedOnMap = GeneratedColumn<bool>(
    'show_visited_on_map',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("show_visited_on_map" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _checkinRadiusKmMeta = const VerificationMeta(
    'checkinRadiusKm',
  );
  @override
  late final GeneratedColumn<double> checkinRadiusKm = GeneratedColumn<double>(
    'checkin_radius_km',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(5000.0),
  );
  @override
  late final GeneratedColumnWithTypeConverter<UnitSystem, String> unitSystem =
      GeneratedColumn<String>(
        'unit_system',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: Constant(UnitSystem.metric.name),
      ).withConverter<UnitSystem>($UserSettingsTableTable.$converterunitSystem);
  static const VerificationMeta _lastLatitudeMeta = const VerificationMeta(
    'lastLatitude',
  );
  @override
  late final GeneratedColumn<double> lastLatitude = GeneratedColumn<double>(
    'last_latitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastLongitudeMeta = const VerificationMeta(
    'lastLongitude',
  );
  @override
  late final GeneratedColumn<double> lastLongitude = GeneratedColumn<double>(
    'last_longitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastSitesSyncAtMeta = const VerificationMeta(
    'lastSitesSyncAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastSitesSyncAt =
      GeneratedColumn<DateTime>(
        'last_sites_sync_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _lastCheckinHistorySyncAtMeta =
      const VerificationMeta('lastCheckinHistorySyncAt');
  @override
  late final GeneratedColumn<DateTime> lastCheckinHistorySyncAt =
      GeneratedColumn<DateTime>(
        'last_checkin_history_sync_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    odUserId,
    username,
    displayName,
    isAuthenticated,
    firstLoginAt,
    lastLoginAt,
    lastXlsxSyncAt,
    pollingInterval,
    notificationRadiusKm,
    mapFilter,
    showVisitedOnMap,
    checkinRadiusKm,
    unitSystem,
    lastLatitude,
    lastLongitude,
    lastSitesSyncAt,
    lastCheckinHistorySyncAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserSettingsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('od_user_id')) {
      context.handle(
        _odUserIdMeta,
        odUserId.isAcceptableOrUnknown(data['od_user_id']!, _odUserIdMeta),
      );
    }
    if (data.containsKey('username')) {
      context.handle(
        _usernameMeta,
        username.isAcceptableOrUnknown(data['username']!, _usernameMeta),
      );
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
    if (data.containsKey('is_authenticated')) {
      context.handle(
        _isAuthenticatedMeta,
        isAuthenticated.isAcceptableOrUnknown(
          data['is_authenticated']!,
          _isAuthenticatedMeta,
        ),
      );
    }
    if (data.containsKey('first_login_at')) {
      context.handle(
        _firstLoginAtMeta,
        firstLoginAt.isAcceptableOrUnknown(
          data['first_login_at']!,
          _firstLoginAtMeta,
        ),
      );
    }
    if (data.containsKey('last_login_at')) {
      context.handle(
        _lastLoginAtMeta,
        lastLoginAt.isAcceptableOrUnknown(
          data['last_login_at']!,
          _lastLoginAtMeta,
        ),
      );
    }
    if (data.containsKey('last_xlsx_sync_at')) {
      context.handle(
        _lastXlsxSyncAtMeta,
        lastXlsxSyncAt.isAcceptableOrUnknown(
          data['last_xlsx_sync_at']!,
          _lastXlsxSyncAtMeta,
        ),
      );
    }
    if (data.containsKey('notification_radius_km')) {
      context.handle(
        _notificationRadiusKmMeta,
        notificationRadiusKm.isAcceptableOrUnknown(
          data['notification_radius_km']!,
          _notificationRadiusKmMeta,
        ),
      );
    }
    if (data.containsKey('show_visited_on_map')) {
      context.handle(
        _showVisitedOnMapMeta,
        showVisitedOnMap.isAcceptableOrUnknown(
          data['show_visited_on_map']!,
          _showVisitedOnMapMeta,
        ),
      );
    }
    if (data.containsKey('checkin_radius_km')) {
      context.handle(
        _checkinRadiusKmMeta,
        checkinRadiusKm.isAcceptableOrUnknown(
          data['checkin_radius_km']!,
          _checkinRadiusKmMeta,
        ),
      );
    }
    if (data.containsKey('last_latitude')) {
      context.handle(
        _lastLatitudeMeta,
        lastLatitude.isAcceptableOrUnknown(
          data['last_latitude']!,
          _lastLatitudeMeta,
        ),
      );
    }
    if (data.containsKey('last_longitude')) {
      context.handle(
        _lastLongitudeMeta,
        lastLongitude.isAcceptableOrUnknown(
          data['last_longitude']!,
          _lastLongitudeMeta,
        ),
      );
    }
    if (data.containsKey('last_sites_sync_at')) {
      context.handle(
        _lastSitesSyncAtMeta,
        lastSitesSyncAt.isAcceptableOrUnknown(
          data['last_sites_sync_at']!,
          _lastSitesSyncAtMeta,
        ),
      );
    }
    if (data.containsKey('last_checkin_history_sync_at')) {
      context.handle(
        _lastCheckinHistorySyncAtMeta,
        lastCheckinHistorySyncAt.isAcceptableOrUnknown(
          data['last_checkin_history_sync_at']!,
          _lastCheckinHistorySyncAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserSettingsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserSettingsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      odUserId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}od_user_id'],
      ),
      username: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}username'],
      ),
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      ),
      isAuthenticated: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_authenticated'],
      )!,
      firstLoginAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}first_login_at'],
      ),
      lastLoginAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_login_at'],
      ),
      lastXlsxSyncAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_xlsx_sync_at'],
      ),
      pollingInterval: $UserSettingsTableTable.$converterpollingInterval
          .fromSql(
            attachedDatabase.typeMapping.read(
              DriftSqlType.string,
              data['${effectivePrefix}polling_interval'],
            )!,
          ),
      notificationRadiusKm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}notification_radius_km'],
      )!,
      mapFilter: $UserSettingsTableTable.$convertermapFilter.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}map_filter'],
        )!,
      ),
      showVisitedOnMap: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}show_visited_on_map'],
      )!,
      checkinRadiusKm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}checkin_radius_km'],
      )!,
      unitSystem: $UserSettingsTableTable.$converterunitSystem.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}unit_system'],
        )!,
      ),
      lastLatitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}last_latitude'],
      ),
      lastLongitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}last_longitude'],
      ),
      lastSitesSyncAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_sites_sync_at'],
      ),
      lastCheckinHistorySyncAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_checkin_history_sync_at'],
      ),
    );
  }

  @override
  $UserSettingsTableTable createAlias(String alias) {
    return $UserSettingsTableTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<PollingInterval, String, String>
  $converterpollingInterval = const EnumNameConverter<PollingInterval>(
    PollingInterval.values,
  );
  static JsonTypeConverter2<MapFilter, String, String> $convertermapFilter =
      const EnumNameConverter<MapFilter>(MapFilter.values);
  static JsonTypeConverter2<UnitSystem, String, String> $converterunitSystem =
      const EnumNameConverter<UnitSystem>(UnitSystem.values);
}

class UserSettingsTableData extends DataClass
    implements Insertable<UserSettingsTableData> {
  final int id;
  final int? odUserId;
  final String? username;
  final String? displayName;
  final bool isAuthenticated;
  final DateTime? firstLoginAt;
  final DateTime? lastLoginAt;
  final DateTime? lastXlsxSyncAt;
  final PollingInterval pollingInterval;
  final double notificationRadiusKm;
  final MapFilter mapFilter;
  final bool showVisitedOnMap;
  final double checkinRadiusKm;
  final UnitSystem unitSystem;
  final double? lastLatitude;
  final double? lastLongitude;
  final DateTime? lastSitesSyncAt;
  final DateTime? lastCheckinHistorySyncAt;
  const UserSettingsTableData({
    required this.id,
    this.odUserId,
    this.username,
    this.displayName,
    required this.isAuthenticated,
    this.firstLoginAt,
    this.lastLoginAt,
    this.lastXlsxSyncAt,
    required this.pollingInterval,
    required this.notificationRadiusKm,
    required this.mapFilter,
    required this.showVisitedOnMap,
    required this.checkinRadiusKm,
    required this.unitSystem,
    this.lastLatitude,
    this.lastLongitude,
    this.lastSitesSyncAt,
    this.lastCheckinHistorySyncAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || odUserId != null) {
      map['od_user_id'] = Variable<int>(odUserId);
    }
    if (!nullToAbsent || username != null) {
      map['username'] = Variable<String>(username);
    }
    if (!nullToAbsent || displayName != null) {
      map['display_name'] = Variable<String>(displayName);
    }
    map['is_authenticated'] = Variable<bool>(isAuthenticated);
    if (!nullToAbsent || firstLoginAt != null) {
      map['first_login_at'] = Variable<DateTime>(firstLoginAt);
    }
    if (!nullToAbsent || lastLoginAt != null) {
      map['last_login_at'] = Variable<DateTime>(lastLoginAt);
    }
    if (!nullToAbsent || lastXlsxSyncAt != null) {
      map['last_xlsx_sync_at'] = Variable<DateTime>(lastXlsxSyncAt);
    }
    {
      map['polling_interval'] = Variable<String>(
        $UserSettingsTableTable.$converterpollingInterval.toSql(
          pollingInterval,
        ),
      );
    }
    map['notification_radius_km'] = Variable<double>(notificationRadiusKm);
    {
      map['map_filter'] = Variable<String>(
        $UserSettingsTableTable.$convertermapFilter.toSql(mapFilter),
      );
    }
    map['show_visited_on_map'] = Variable<bool>(showVisitedOnMap);
    map['checkin_radius_km'] = Variable<double>(checkinRadiusKm);
    {
      map['unit_system'] = Variable<String>(
        $UserSettingsTableTable.$converterunitSystem.toSql(unitSystem),
      );
    }
    if (!nullToAbsent || lastLatitude != null) {
      map['last_latitude'] = Variable<double>(lastLatitude);
    }
    if (!nullToAbsent || lastLongitude != null) {
      map['last_longitude'] = Variable<double>(lastLongitude);
    }
    if (!nullToAbsent || lastSitesSyncAt != null) {
      map['last_sites_sync_at'] = Variable<DateTime>(lastSitesSyncAt);
    }
    if (!nullToAbsent || lastCheckinHistorySyncAt != null) {
      map['last_checkin_history_sync_at'] = Variable<DateTime>(
        lastCheckinHistorySyncAt,
      );
    }
    return map;
  }

  UserSettingsTableCompanion toCompanion(bool nullToAbsent) {
    return UserSettingsTableCompanion(
      id: Value(id),
      odUserId: odUserId == null && nullToAbsent
          ? const Value.absent()
          : Value(odUserId),
      username: username == null && nullToAbsent
          ? const Value.absent()
          : Value(username),
      displayName: displayName == null && nullToAbsent
          ? const Value.absent()
          : Value(displayName),
      isAuthenticated: Value(isAuthenticated),
      firstLoginAt: firstLoginAt == null && nullToAbsent
          ? const Value.absent()
          : Value(firstLoginAt),
      lastLoginAt: lastLoginAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastLoginAt),
      lastXlsxSyncAt: lastXlsxSyncAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastXlsxSyncAt),
      pollingInterval: Value(pollingInterval),
      notificationRadiusKm: Value(notificationRadiusKm),
      mapFilter: Value(mapFilter),
      showVisitedOnMap: Value(showVisitedOnMap),
      checkinRadiusKm: Value(checkinRadiusKm),
      unitSystem: Value(unitSystem),
      lastLatitude: lastLatitude == null && nullToAbsent
          ? const Value.absent()
          : Value(lastLatitude),
      lastLongitude: lastLongitude == null && nullToAbsent
          ? const Value.absent()
          : Value(lastLongitude),
      lastSitesSyncAt: lastSitesSyncAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSitesSyncAt),
      lastCheckinHistorySyncAt: lastCheckinHistorySyncAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastCheckinHistorySyncAt),
    );
  }

  factory UserSettingsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserSettingsTableData(
      id: serializer.fromJson<int>(json['id']),
      odUserId: serializer.fromJson<int?>(json['odUserId']),
      username: serializer.fromJson<String?>(json['username']),
      displayName: serializer.fromJson<String?>(json['displayName']),
      isAuthenticated: serializer.fromJson<bool>(json['isAuthenticated']),
      firstLoginAt: serializer.fromJson<DateTime?>(json['firstLoginAt']),
      lastLoginAt: serializer.fromJson<DateTime?>(json['lastLoginAt']),
      lastXlsxSyncAt: serializer.fromJson<DateTime?>(json['lastXlsxSyncAt']),
      pollingInterval: $UserSettingsTableTable.$converterpollingInterval
          .fromJson(serializer.fromJson<String>(json['pollingInterval'])),
      notificationRadiusKm: serializer.fromJson<double>(
        json['notificationRadiusKm'],
      ),
      mapFilter: $UserSettingsTableTable.$convertermapFilter.fromJson(
        serializer.fromJson<String>(json['mapFilter']),
      ),
      showVisitedOnMap: serializer.fromJson<bool>(json['showVisitedOnMap']),
      checkinRadiusKm: serializer.fromJson<double>(json['checkinRadiusKm']),
      unitSystem: $UserSettingsTableTable.$converterunitSystem.fromJson(
        serializer.fromJson<String>(json['unitSystem']),
      ),
      lastLatitude: serializer.fromJson<double?>(json['lastLatitude']),
      lastLongitude: serializer.fromJson<double?>(json['lastLongitude']),
      lastSitesSyncAt: serializer.fromJson<DateTime?>(json['lastSitesSyncAt']),
      lastCheckinHistorySyncAt: serializer.fromJson<DateTime?>(
        json['lastCheckinHistorySyncAt'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'odUserId': serializer.toJson<int?>(odUserId),
      'username': serializer.toJson<String?>(username),
      'displayName': serializer.toJson<String?>(displayName),
      'isAuthenticated': serializer.toJson<bool>(isAuthenticated),
      'firstLoginAt': serializer.toJson<DateTime?>(firstLoginAt),
      'lastLoginAt': serializer.toJson<DateTime?>(lastLoginAt),
      'lastXlsxSyncAt': serializer.toJson<DateTime?>(lastXlsxSyncAt),
      'pollingInterval': serializer.toJson<String>(
        $UserSettingsTableTable.$converterpollingInterval.toJson(
          pollingInterval,
        ),
      ),
      'notificationRadiusKm': serializer.toJson<double>(notificationRadiusKm),
      'mapFilter': serializer.toJson<String>(
        $UserSettingsTableTable.$convertermapFilter.toJson(mapFilter),
      ),
      'showVisitedOnMap': serializer.toJson<bool>(showVisitedOnMap),
      'checkinRadiusKm': serializer.toJson<double>(checkinRadiusKm),
      'unitSystem': serializer.toJson<String>(
        $UserSettingsTableTable.$converterunitSystem.toJson(unitSystem),
      ),
      'lastLatitude': serializer.toJson<double?>(lastLatitude),
      'lastLongitude': serializer.toJson<double?>(lastLongitude),
      'lastSitesSyncAt': serializer.toJson<DateTime?>(lastSitesSyncAt),
      'lastCheckinHistorySyncAt': serializer.toJson<DateTime?>(
        lastCheckinHistorySyncAt,
      ),
    };
  }

  UserSettingsTableData copyWith({
    int? id,
    Value<int?> odUserId = const Value.absent(),
    Value<String?> username = const Value.absent(),
    Value<String?> displayName = const Value.absent(),
    bool? isAuthenticated,
    Value<DateTime?> firstLoginAt = const Value.absent(),
    Value<DateTime?> lastLoginAt = const Value.absent(),
    Value<DateTime?> lastXlsxSyncAt = const Value.absent(),
    PollingInterval? pollingInterval,
    double? notificationRadiusKm,
    MapFilter? mapFilter,
    bool? showVisitedOnMap,
    double? checkinRadiusKm,
    UnitSystem? unitSystem,
    Value<double?> lastLatitude = const Value.absent(),
    Value<double?> lastLongitude = const Value.absent(),
    Value<DateTime?> lastSitesSyncAt = const Value.absent(),
    Value<DateTime?> lastCheckinHistorySyncAt = const Value.absent(),
  }) => UserSettingsTableData(
    id: id ?? this.id,
    odUserId: odUserId.present ? odUserId.value : this.odUserId,
    username: username.present ? username.value : this.username,
    displayName: displayName.present ? displayName.value : this.displayName,
    isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    firstLoginAt: firstLoginAt.present ? firstLoginAt.value : this.firstLoginAt,
    lastLoginAt: lastLoginAt.present ? lastLoginAt.value : this.lastLoginAt,
    lastXlsxSyncAt: lastXlsxSyncAt.present
        ? lastXlsxSyncAt.value
        : this.lastXlsxSyncAt,
    pollingInterval: pollingInterval ?? this.pollingInterval,
    notificationRadiusKm: notificationRadiusKm ?? this.notificationRadiusKm,
    mapFilter: mapFilter ?? this.mapFilter,
    showVisitedOnMap: showVisitedOnMap ?? this.showVisitedOnMap,
    checkinRadiusKm: checkinRadiusKm ?? this.checkinRadiusKm,
    unitSystem: unitSystem ?? this.unitSystem,
    lastLatitude: lastLatitude.present ? lastLatitude.value : this.lastLatitude,
    lastLongitude: lastLongitude.present
        ? lastLongitude.value
        : this.lastLongitude,
    lastSitesSyncAt: lastSitesSyncAt.present
        ? lastSitesSyncAt.value
        : this.lastSitesSyncAt,
    lastCheckinHistorySyncAt: lastCheckinHistorySyncAt.present
        ? lastCheckinHistorySyncAt.value
        : this.lastCheckinHistorySyncAt,
  );
  UserSettingsTableData copyWithCompanion(UserSettingsTableCompanion data) {
    return UserSettingsTableData(
      id: data.id.present ? data.id.value : this.id,
      odUserId: data.odUserId.present ? data.odUserId.value : this.odUserId,
      username: data.username.present ? data.username.value : this.username,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      isAuthenticated: data.isAuthenticated.present
          ? data.isAuthenticated.value
          : this.isAuthenticated,
      firstLoginAt: data.firstLoginAt.present
          ? data.firstLoginAt.value
          : this.firstLoginAt,
      lastLoginAt: data.lastLoginAt.present
          ? data.lastLoginAt.value
          : this.lastLoginAt,
      lastXlsxSyncAt: data.lastXlsxSyncAt.present
          ? data.lastXlsxSyncAt.value
          : this.lastXlsxSyncAt,
      pollingInterval: data.pollingInterval.present
          ? data.pollingInterval.value
          : this.pollingInterval,
      notificationRadiusKm: data.notificationRadiusKm.present
          ? data.notificationRadiusKm.value
          : this.notificationRadiusKm,
      mapFilter: data.mapFilter.present ? data.mapFilter.value : this.mapFilter,
      showVisitedOnMap: data.showVisitedOnMap.present
          ? data.showVisitedOnMap.value
          : this.showVisitedOnMap,
      checkinRadiusKm: data.checkinRadiusKm.present
          ? data.checkinRadiusKm.value
          : this.checkinRadiusKm,
      unitSystem: data.unitSystem.present
          ? data.unitSystem.value
          : this.unitSystem,
      lastLatitude: data.lastLatitude.present
          ? data.lastLatitude.value
          : this.lastLatitude,
      lastLongitude: data.lastLongitude.present
          ? data.lastLongitude.value
          : this.lastLongitude,
      lastSitesSyncAt: data.lastSitesSyncAt.present
          ? data.lastSitesSyncAt.value
          : this.lastSitesSyncAt,
      lastCheckinHistorySyncAt: data.lastCheckinHistorySyncAt.present
          ? data.lastCheckinHistorySyncAt.value
          : this.lastCheckinHistorySyncAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserSettingsTableData(')
          ..write('id: $id, ')
          ..write('odUserId: $odUserId, ')
          ..write('username: $username, ')
          ..write('displayName: $displayName, ')
          ..write('isAuthenticated: $isAuthenticated, ')
          ..write('firstLoginAt: $firstLoginAt, ')
          ..write('lastLoginAt: $lastLoginAt, ')
          ..write('lastXlsxSyncAt: $lastXlsxSyncAt, ')
          ..write('pollingInterval: $pollingInterval, ')
          ..write('notificationRadiusKm: $notificationRadiusKm, ')
          ..write('mapFilter: $mapFilter, ')
          ..write('showVisitedOnMap: $showVisitedOnMap, ')
          ..write('checkinRadiusKm: $checkinRadiusKm, ')
          ..write('unitSystem: $unitSystem, ')
          ..write('lastLatitude: $lastLatitude, ')
          ..write('lastLongitude: $lastLongitude, ')
          ..write('lastSitesSyncAt: $lastSitesSyncAt, ')
          ..write('lastCheckinHistorySyncAt: $lastCheckinHistorySyncAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    odUserId,
    username,
    displayName,
    isAuthenticated,
    firstLoginAt,
    lastLoginAt,
    lastXlsxSyncAt,
    pollingInterval,
    notificationRadiusKm,
    mapFilter,
    showVisitedOnMap,
    checkinRadiusKm,
    unitSystem,
    lastLatitude,
    lastLongitude,
    lastSitesSyncAt,
    lastCheckinHistorySyncAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserSettingsTableData &&
          other.id == this.id &&
          other.odUserId == this.odUserId &&
          other.username == this.username &&
          other.displayName == this.displayName &&
          other.isAuthenticated == this.isAuthenticated &&
          other.firstLoginAt == this.firstLoginAt &&
          other.lastLoginAt == this.lastLoginAt &&
          other.lastXlsxSyncAt == this.lastXlsxSyncAt &&
          other.pollingInterval == this.pollingInterval &&
          other.notificationRadiusKm == this.notificationRadiusKm &&
          other.mapFilter == this.mapFilter &&
          other.showVisitedOnMap == this.showVisitedOnMap &&
          other.checkinRadiusKm == this.checkinRadiusKm &&
          other.unitSystem == this.unitSystem &&
          other.lastLatitude == this.lastLatitude &&
          other.lastLongitude == this.lastLongitude &&
          other.lastSitesSyncAt == this.lastSitesSyncAt &&
          other.lastCheckinHistorySyncAt == this.lastCheckinHistorySyncAt);
}

class UserSettingsTableCompanion
    extends UpdateCompanion<UserSettingsTableData> {
  final Value<int> id;
  final Value<int?> odUserId;
  final Value<String?> username;
  final Value<String?> displayName;
  final Value<bool> isAuthenticated;
  final Value<DateTime?> firstLoginAt;
  final Value<DateTime?> lastLoginAt;
  final Value<DateTime?> lastXlsxSyncAt;
  final Value<PollingInterval> pollingInterval;
  final Value<double> notificationRadiusKm;
  final Value<MapFilter> mapFilter;
  final Value<bool> showVisitedOnMap;
  final Value<double> checkinRadiusKm;
  final Value<UnitSystem> unitSystem;
  final Value<double?> lastLatitude;
  final Value<double?> lastLongitude;
  final Value<DateTime?> lastSitesSyncAt;
  final Value<DateTime?> lastCheckinHistorySyncAt;
  const UserSettingsTableCompanion({
    this.id = const Value.absent(),
    this.odUserId = const Value.absent(),
    this.username = const Value.absent(),
    this.displayName = const Value.absent(),
    this.isAuthenticated = const Value.absent(),
    this.firstLoginAt = const Value.absent(),
    this.lastLoginAt = const Value.absent(),
    this.lastXlsxSyncAt = const Value.absent(),
    this.pollingInterval = const Value.absent(),
    this.notificationRadiusKm = const Value.absent(),
    this.mapFilter = const Value.absent(),
    this.showVisitedOnMap = const Value.absent(),
    this.checkinRadiusKm = const Value.absent(),
    this.unitSystem = const Value.absent(),
    this.lastLatitude = const Value.absent(),
    this.lastLongitude = const Value.absent(),
    this.lastSitesSyncAt = const Value.absent(),
    this.lastCheckinHistorySyncAt = const Value.absent(),
  });
  UserSettingsTableCompanion.insert({
    this.id = const Value.absent(),
    this.odUserId = const Value.absent(),
    this.username = const Value.absent(),
    this.displayName = const Value.absent(),
    this.isAuthenticated = const Value.absent(),
    this.firstLoginAt = const Value.absent(),
    this.lastLoginAt = const Value.absent(),
    this.lastXlsxSyncAt = const Value.absent(),
    this.pollingInterval = const Value.absent(),
    this.notificationRadiusKm = const Value.absent(),
    this.mapFilter = const Value.absent(),
    this.showVisitedOnMap = const Value.absent(),
    this.checkinRadiusKm = const Value.absent(),
    this.unitSystem = const Value.absent(),
    this.lastLatitude = const Value.absent(),
    this.lastLongitude = const Value.absent(),
    this.lastSitesSyncAt = const Value.absent(),
    this.lastCheckinHistorySyncAt = const Value.absent(),
  });
  static Insertable<UserSettingsTableData> custom({
    Expression<int>? id,
    Expression<int>? odUserId,
    Expression<String>? username,
    Expression<String>? displayName,
    Expression<bool>? isAuthenticated,
    Expression<DateTime>? firstLoginAt,
    Expression<DateTime>? lastLoginAt,
    Expression<DateTime>? lastXlsxSyncAt,
    Expression<String>? pollingInterval,
    Expression<double>? notificationRadiusKm,
    Expression<String>? mapFilter,
    Expression<bool>? showVisitedOnMap,
    Expression<double>? checkinRadiusKm,
    Expression<String>? unitSystem,
    Expression<double>? lastLatitude,
    Expression<double>? lastLongitude,
    Expression<DateTime>? lastSitesSyncAt,
    Expression<DateTime>? lastCheckinHistorySyncAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (odUserId != null) 'od_user_id': odUserId,
      if (username != null) 'username': username,
      if (displayName != null) 'display_name': displayName,
      if (isAuthenticated != null) 'is_authenticated': isAuthenticated,
      if (firstLoginAt != null) 'first_login_at': firstLoginAt,
      if (lastLoginAt != null) 'last_login_at': lastLoginAt,
      if (lastXlsxSyncAt != null) 'last_xlsx_sync_at': lastXlsxSyncAt,
      if (pollingInterval != null) 'polling_interval': pollingInterval,
      if (notificationRadiusKm != null)
        'notification_radius_km': notificationRadiusKm,
      if (mapFilter != null) 'map_filter': mapFilter,
      if (showVisitedOnMap != null) 'show_visited_on_map': showVisitedOnMap,
      if (checkinRadiusKm != null) 'checkin_radius_km': checkinRadiusKm,
      if (unitSystem != null) 'unit_system': unitSystem,
      if (lastLatitude != null) 'last_latitude': lastLatitude,
      if (lastLongitude != null) 'last_longitude': lastLongitude,
      if (lastSitesSyncAt != null) 'last_sites_sync_at': lastSitesSyncAt,
      if (lastCheckinHistorySyncAt != null)
        'last_checkin_history_sync_at': lastCheckinHistorySyncAt,
    });
  }

  UserSettingsTableCompanion copyWith({
    Value<int>? id,
    Value<int?>? odUserId,
    Value<String?>? username,
    Value<String?>? displayName,
    Value<bool>? isAuthenticated,
    Value<DateTime?>? firstLoginAt,
    Value<DateTime?>? lastLoginAt,
    Value<DateTime?>? lastXlsxSyncAt,
    Value<PollingInterval>? pollingInterval,
    Value<double>? notificationRadiusKm,
    Value<MapFilter>? mapFilter,
    Value<bool>? showVisitedOnMap,
    Value<double>? checkinRadiusKm,
    Value<UnitSystem>? unitSystem,
    Value<double?>? lastLatitude,
    Value<double?>? lastLongitude,
    Value<DateTime?>? lastSitesSyncAt,
    Value<DateTime?>? lastCheckinHistorySyncAt,
  }) {
    return UserSettingsTableCompanion(
      id: id ?? this.id,
      odUserId: odUserId ?? this.odUserId,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      firstLoginAt: firstLoginAt ?? this.firstLoginAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      lastXlsxSyncAt: lastXlsxSyncAt ?? this.lastXlsxSyncAt,
      pollingInterval: pollingInterval ?? this.pollingInterval,
      notificationRadiusKm: notificationRadiusKm ?? this.notificationRadiusKm,
      mapFilter: mapFilter ?? this.mapFilter,
      showVisitedOnMap: showVisitedOnMap ?? this.showVisitedOnMap,
      checkinRadiusKm: checkinRadiusKm ?? this.checkinRadiusKm,
      unitSystem: unitSystem ?? this.unitSystem,
      lastLatitude: lastLatitude ?? this.lastLatitude,
      lastLongitude: lastLongitude ?? this.lastLongitude,
      lastSitesSyncAt: lastSitesSyncAt ?? this.lastSitesSyncAt,
      lastCheckinHistorySyncAt:
          lastCheckinHistorySyncAt ?? this.lastCheckinHistorySyncAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (odUserId.present) {
      map['od_user_id'] = Variable<int>(odUserId.value);
    }
    if (username.present) {
      map['username'] = Variable<String>(username.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (isAuthenticated.present) {
      map['is_authenticated'] = Variable<bool>(isAuthenticated.value);
    }
    if (firstLoginAt.present) {
      map['first_login_at'] = Variable<DateTime>(firstLoginAt.value);
    }
    if (lastLoginAt.present) {
      map['last_login_at'] = Variable<DateTime>(lastLoginAt.value);
    }
    if (lastXlsxSyncAt.present) {
      map['last_xlsx_sync_at'] = Variable<DateTime>(lastXlsxSyncAt.value);
    }
    if (pollingInterval.present) {
      map['polling_interval'] = Variable<String>(
        $UserSettingsTableTable.$converterpollingInterval.toSql(
          pollingInterval.value,
        ),
      );
    }
    if (notificationRadiusKm.present) {
      map['notification_radius_km'] = Variable<double>(
        notificationRadiusKm.value,
      );
    }
    if (mapFilter.present) {
      map['map_filter'] = Variable<String>(
        $UserSettingsTableTable.$convertermapFilter.toSql(mapFilter.value),
      );
    }
    if (showVisitedOnMap.present) {
      map['show_visited_on_map'] = Variable<bool>(showVisitedOnMap.value);
    }
    if (checkinRadiusKm.present) {
      map['checkin_radius_km'] = Variable<double>(checkinRadiusKm.value);
    }
    if (unitSystem.present) {
      map['unit_system'] = Variable<String>(
        $UserSettingsTableTable.$converterunitSystem.toSql(unitSystem.value),
      );
    }
    if (lastLatitude.present) {
      map['last_latitude'] = Variable<double>(lastLatitude.value);
    }
    if (lastLongitude.present) {
      map['last_longitude'] = Variable<double>(lastLongitude.value);
    }
    if (lastSitesSyncAt.present) {
      map['last_sites_sync_at'] = Variable<DateTime>(lastSitesSyncAt.value);
    }
    if (lastCheckinHistorySyncAt.present) {
      map['last_checkin_history_sync_at'] = Variable<DateTime>(
        lastCheckinHistorySyncAt.value,
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserSettingsTableCompanion(')
          ..write('id: $id, ')
          ..write('odUserId: $odUserId, ')
          ..write('username: $username, ')
          ..write('displayName: $displayName, ')
          ..write('isAuthenticated: $isAuthenticated, ')
          ..write('firstLoginAt: $firstLoginAt, ')
          ..write('lastLoginAt: $lastLoginAt, ')
          ..write('lastXlsxSyncAt: $lastXlsxSyncAt, ')
          ..write('pollingInterval: $pollingInterval, ')
          ..write('notificationRadiusKm: $notificationRadiusKm, ')
          ..write('mapFilter: $mapFilter, ')
          ..write('showVisitedOnMap: $showVisitedOnMap, ')
          ..write('checkinRadiusKm: $checkinRadiusKm, ')
          ..write('unitSystem: $unitSystem, ')
          ..write('lastLatitude: $lastLatitude, ')
          ..write('lastLongitude: $lastLongitude, ')
          ..write('lastSitesSyncAt: $lastSitesSyncAt, ')
          ..write('lastCheckinHistorySyncAt: $lastCheckinHistorySyncAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $SitesTable sites = $SitesTable(this);
  late final $VisitsTable visits = $VisitsTable(this);
  late final $PendingCheckinsTable pendingCheckins = $PendingCheckinsTable(
    this,
  );
  late final $SiteCheckinsTable siteCheckins = $SiteCheckinsTable(this);
  late final $UserSettingsTableTable userSettingsTable =
      $UserSettingsTableTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    sites,
    visits,
    pendingCheckins,
    siteCheckins,
    userSettingsTable,
  ];
}

typedef $$SitesTableCreateCompanionBuilder =
    SitesCompanion Function({
      Value<int> id,
      required int siteId,
      Value<String?> locationId,
      required String name,
      Value<SiteStatus> status,
      Value<double> latitude,
      Value<double> longitude,
      Value<String?> city,
      Value<String?> state,
      Value<String> country,
      Value<String> region,
      Value<String?> timezone,
      Value<int?> stallCount,
      Value<DateTime?> dateOpened,
      Value<bool> hasCheckins,
      Value<bool> visited,
      Value<DateTime?> lastSynced,
    });
typedef $$SitesTableUpdateCompanionBuilder =
    SitesCompanion Function({
      Value<int> id,
      Value<int> siteId,
      Value<String?> locationId,
      Value<String> name,
      Value<SiteStatus> status,
      Value<double> latitude,
      Value<double> longitude,
      Value<String?> city,
      Value<String?> state,
      Value<String> country,
      Value<String> region,
      Value<String?> timezone,
      Value<int?> stallCount,
      Value<DateTime?> dateOpened,
      Value<bool> hasCheckins,
      Value<bool> visited,
      Value<DateTime?> lastSynced,
    });

class $$SitesTableFilterComposer extends Composer<_$AppDatabase, $SitesTable> {
  $$SitesTableFilterComposer({
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

  ColumnFilters<int> get siteId => $composableBuilder(
    column: $table.siteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get locationId => $composableBuilder(
    column: $table.locationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<SiteStatus, SiteStatus, String> get status =>
      $composableBuilder(
        column: $table.status,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get city => $composableBuilder(
    column: $table.city,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get country => $composableBuilder(
    column: $table.country,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get region => $composableBuilder(
    column: $table.region,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get timezone => $composableBuilder(
    column: $table.timezone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get stallCount => $composableBuilder(
    column: $table.stallCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dateOpened => $composableBuilder(
    column: $table.dateOpened,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get hasCheckins => $composableBuilder(
    column: $table.hasCheckins,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get visited => $composableBuilder(
    column: $table.visited,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSynced => $composableBuilder(
    column: $table.lastSynced,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SitesTableOrderingComposer
    extends Composer<_$AppDatabase, $SitesTable> {
  $$SitesTableOrderingComposer({
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

  ColumnOrderings<int> get siteId => $composableBuilder(
    column: $table.siteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get locationId => $composableBuilder(
    column: $table.locationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get city => $composableBuilder(
    column: $table.city,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get country => $composableBuilder(
    column: $table.country,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get region => $composableBuilder(
    column: $table.region,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get timezone => $composableBuilder(
    column: $table.timezone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get stallCount => $composableBuilder(
    column: $table.stallCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dateOpened => $composableBuilder(
    column: $table.dateOpened,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get hasCheckins => $composableBuilder(
    column: $table.hasCheckins,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get visited => $composableBuilder(
    column: $table.visited,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSynced => $composableBuilder(
    column: $table.lastSynced,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SitesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SitesTable> {
  $$SitesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get siteId =>
      $composableBuilder(column: $table.siteId, builder: (column) => column);

  GeneratedColumn<String> get locationId => $composableBuilder(
    column: $table.locationId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumnWithTypeConverter<SiteStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<String> get city =>
      $composableBuilder(column: $table.city, builder: (column) => column);

  GeneratedColumn<String> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  GeneratedColumn<String> get country =>
      $composableBuilder(column: $table.country, builder: (column) => column);

  GeneratedColumn<String> get region =>
      $composableBuilder(column: $table.region, builder: (column) => column);

  GeneratedColumn<String> get timezone =>
      $composableBuilder(column: $table.timezone, builder: (column) => column);

  GeneratedColumn<int> get stallCount => $composableBuilder(
    column: $table.stallCount,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get dateOpened => $composableBuilder(
    column: $table.dateOpened,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get hasCheckins => $composableBuilder(
    column: $table.hasCheckins,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get visited =>
      $composableBuilder(column: $table.visited, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSynced => $composableBuilder(
    column: $table.lastSynced,
    builder: (column) => column,
  );
}

class $$SitesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SitesTable,
          Site,
          $$SitesTableFilterComposer,
          $$SitesTableOrderingComposer,
          $$SitesTableAnnotationComposer,
          $$SitesTableCreateCompanionBuilder,
          $$SitesTableUpdateCompanionBuilder,
          (Site, BaseReferences<_$AppDatabase, $SitesTable, Site>),
          Site,
          PrefetchHooks Function()
        > {
  $$SitesTableTableManager(_$AppDatabase db, $SitesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SitesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SitesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SitesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> siteId = const Value.absent(),
                Value<String?> locationId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<SiteStatus> status = const Value.absent(),
                Value<double> latitude = const Value.absent(),
                Value<double> longitude = const Value.absent(),
                Value<String?> city = const Value.absent(),
                Value<String?> state = const Value.absent(),
                Value<String> country = const Value.absent(),
                Value<String> region = const Value.absent(),
                Value<String?> timezone = const Value.absent(),
                Value<int?> stallCount = const Value.absent(),
                Value<DateTime?> dateOpened = const Value.absent(),
                Value<bool> hasCheckins = const Value.absent(),
                Value<bool> visited = const Value.absent(),
                Value<DateTime?> lastSynced = const Value.absent(),
              }) => SitesCompanion(
                id: id,
                siteId: siteId,
                locationId: locationId,
                name: name,
                status: status,
                latitude: latitude,
                longitude: longitude,
                city: city,
                state: state,
                country: country,
                region: region,
                timezone: timezone,
                stallCount: stallCount,
                dateOpened: dateOpened,
                hasCheckins: hasCheckins,
                visited: visited,
                lastSynced: lastSynced,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int siteId,
                Value<String?> locationId = const Value.absent(),
                required String name,
                Value<SiteStatus> status = const Value.absent(),
                Value<double> latitude = const Value.absent(),
                Value<double> longitude = const Value.absent(),
                Value<String?> city = const Value.absent(),
                Value<String?> state = const Value.absent(),
                Value<String> country = const Value.absent(),
                Value<String> region = const Value.absent(),
                Value<String?> timezone = const Value.absent(),
                Value<int?> stallCount = const Value.absent(),
                Value<DateTime?> dateOpened = const Value.absent(),
                Value<bool> hasCheckins = const Value.absent(),
                Value<bool> visited = const Value.absent(),
                Value<DateTime?> lastSynced = const Value.absent(),
              }) => SitesCompanion.insert(
                id: id,
                siteId: siteId,
                locationId: locationId,
                name: name,
                status: status,
                latitude: latitude,
                longitude: longitude,
                city: city,
                state: state,
                country: country,
                region: region,
                timezone: timezone,
                stallCount: stallCount,
                dateOpened: dateOpened,
                hasCheckins: hasCheckins,
                visited: visited,
                lastSynced: lastSynced,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SitesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SitesTable,
      Site,
      $$SitesTableFilterComposer,
      $$SitesTableOrderingComposer,
      $$SitesTableAnnotationComposer,
      $$SitesTableCreateCompanionBuilder,
      $$SitesTableUpdateCompanionBuilder,
      (Site, BaseReferences<_$AppDatabase, $SitesTable, Site>),
      Site,
      PrefetchHooks Function()
    >;
typedef $$VisitsTableCreateCompanionBuilder =
    VisitsCompanion Function({
      Value<int> id,
      required int checkinId,
      required int siteId,
      required DateTime checkinDate,
      required DateTime checkinTime,
      Value<bool> isFirst,
      Value<CheckinMethod> method,
      Value<String?> notesPublic,
      Value<int?> geoDistanceAccuracy,
      Value<int?> geoDistance,
      Value<int?> distinctUserSuperSeq,
      required DateTime importedAt,
    });
typedef $$VisitsTableUpdateCompanionBuilder =
    VisitsCompanion Function({
      Value<int> id,
      Value<int> checkinId,
      Value<int> siteId,
      Value<DateTime> checkinDate,
      Value<DateTime> checkinTime,
      Value<bool> isFirst,
      Value<CheckinMethod> method,
      Value<String?> notesPublic,
      Value<int?> geoDistanceAccuracy,
      Value<int?> geoDistance,
      Value<int?> distinctUserSuperSeq,
      Value<DateTime> importedAt,
    });

class $$VisitsTableFilterComposer
    extends Composer<_$AppDatabase, $VisitsTable> {
  $$VisitsTableFilterComposer({
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

  ColumnFilters<int> get checkinId => $composableBuilder(
    column: $table.checkinId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get siteId => $composableBuilder(
    column: $table.siteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get checkinDate => $composableBuilder(
    column: $table.checkinDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get checkinTime => $composableBuilder(
    column: $table.checkinTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isFirst => $composableBuilder(
    column: $table.isFirst,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<CheckinMethod, CheckinMethod, String>
  get method => $composableBuilder(
    column: $table.method,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get notesPublic => $composableBuilder(
    column: $table.notesPublic,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get geoDistanceAccuracy => $composableBuilder(
    column: $table.geoDistanceAccuracy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get geoDistance => $composableBuilder(
    column: $table.geoDistance,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get distinctUserSuperSeq => $composableBuilder(
    column: $table.distinctUserSuperSeq,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get importedAt => $composableBuilder(
    column: $table.importedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$VisitsTableOrderingComposer
    extends Composer<_$AppDatabase, $VisitsTable> {
  $$VisitsTableOrderingComposer({
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

  ColumnOrderings<int> get checkinId => $composableBuilder(
    column: $table.checkinId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get siteId => $composableBuilder(
    column: $table.siteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get checkinDate => $composableBuilder(
    column: $table.checkinDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get checkinTime => $composableBuilder(
    column: $table.checkinTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isFirst => $composableBuilder(
    column: $table.isFirst,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get method => $composableBuilder(
    column: $table.method,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notesPublic => $composableBuilder(
    column: $table.notesPublic,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get geoDistanceAccuracy => $composableBuilder(
    column: $table.geoDistanceAccuracy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get geoDistance => $composableBuilder(
    column: $table.geoDistance,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get distinctUserSuperSeq => $composableBuilder(
    column: $table.distinctUserSuperSeq,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get importedAt => $composableBuilder(
    column: $table.importedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$VisitsTableAnnotationComposer
    extends Composer<_$AppDatabase, $VisitsTable> {
  $$VisitsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get checkinId =>
      $composableBuilder(column: $table.checkinId, builder: (column) => column);

  GeneratedColumn<int> get siteId =>
      $composableBuilder(column: $table.siteId, builder: (column) => column);

  GeneratedColumn<DateTime> get checkinDate => $composableBuilder(
    column: $table.checkinDate,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get checkinTime => $composableBuilder(
    column: $table.checkinTime,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isFirst =>
      $composableBuilder(column: $table.isFirst, builder: (column) => column);

  GeneratedColumnWithTypeConverter<CheckinMethod, String> get method =>
      $composableBuilder(column: $table.method, builder: (column) => column);

  GeneratedColumn<String> get notesPublic => $composableBuilder(
    column: $table.notesPublic,
    builder: (column) => column,
  );

  GeneratedColumn<int> get geoDistanceAccuracy => $composableBuilder(
    column: $table.geoDistanceAccuracy,
    builder: (column) => column,
  );

  GeneratedColumn<int> get geoDistance => $composableBuilder(
    column: $table.geoDistance,
    builder: (column) => column,
  );

  GeneratedColumn<int> get distinctUserSuperSeq => $composableBuilder(
    column: $table.distinctUserSuperSeq,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get importedAt => $composableBuilder(
    column: $table.importedAt,
    builder: (column) => column,
  );
}

class $$VisitsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $VisitsTable,
          Visit,
          $$VisitsTableFilterComposer,
          $$VisitsTableOrderingComposer,
          $$VisitsTableAnnotationComposer,
          $$VisitsTableCreateCompanionBuilder,
          $$VisitsTableUpdateCompanionBuilder,
          (Visit, BaseReferences<_$AppDatabase, $VisitsTable, Visit>),
          Visit,
          PrefetchHooks Function()
        > {
  $$VisitsTableTableManager(_$AppDatabase db, $VisitsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VisitsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VisitsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VisitsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> checkinId = const Value.absent(),
                Value<int> siteId = const Value.absent(),
                Value<DateTime> checkinDate = const Value.absent(),
                Value<DateTime> checkinTime = const Value.absent(),
                Value<bool> isFirst = const Value.absent(),
                Value<CheckinMethod> method = const Value.absent(),
                Value<String?> notesPublic = const Value.absent(),
                Value<int?> geoDistanceAccuracy = const Value.absent(),
                Value<int?> geoDistance = const Value.absent(),
                Value<int?> distinctUserSuperSeq = const Value.absent(),
                Value<DateTime> importedAt = const Value.absent(),
              }) => VisitsCompanion(
                id: id,
                checkinId: checkinId,
                siteId: siteId,
                checkinDate: checkinDate,
                checkinTime: checkinTime,
                isFirst: isFirst,
                method: method,
                notesPublic: notesPublic,
                geoDistanceAccuracy: geoDistanceAccuracy,
                geoDistance: geoDistance,
                distinctUserSuperSeq: distinctUserSuperSeq,
                importedAt: importedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int checkinId,
                required int siteId,
                required DateTime checkinDate,
                required DateTime checkinTime,
                Value<bool> isFirst = const Value.absent(),
                Value<CheckinMethod> method = const Value.absent(),
                Value<String?> notesPublic = const Value.absent(),
                Value<int?> geoDistanceAccuracy = const Value.absent(),
                Value<int?> geoDistance = const Value.absent(),
                Value<int?> distinctUserSuperSeq = const Value.absent(),
                required DateTime importedAt,
              }) => VisitsCompanion.insert(
                id: id,
                checkinId: checkinId,
                siteId: siteId,
                checkinDate: checkinDate,
                checkinTime: checkinTime,
                isFirst: isFirst,
                method: method,
                notesPublic: notesPublic,
                geoDistanceAccuracy: geoDistanceAccuracy,
                geoDistance: geoDistance,
                distinctUserSuperSeq: distinctUserSuperSeq,
                importedAt: importedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$VisitsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $VisitsTable,
      Visit,
      $$VisitsTableFilterComposer,
      $$VisitsTableOrderingComposer,
      $$VisitsTableAnnotationComposer,
      $$VisitsTableCreateCompanionBuilder,
      $$VisitsTableUpdateCompanionBuilder,
      (Visit, BaseReferences<_$AppDatabase, $VisitsTable, Visit>),
      Visit,
      PrefetchHooks Function()
    >;
typedef $$PendingCheckinsTableCreateCompanionBuilder =
    PendingCheckinsCompanion Function({
      Value<int> id,
      required int siteId,
      required DateTime checkinDate,
      required DateTime createdAt,
      Value<double?> latitude,
      Value<double?> longitude,
      Value<double?> accuracy,
      Value<String?> notesPublic,
      Value<PendingStatus> status,
      Value<int> attempts,
      Value<DateTime?> lastAttemptAt,
      Value<String?> lastError,
    });
typedef $$PendingCheckinsTableUpdateCompanionBuilder =
    PendingCheckinsCompanion Function({
      Value<int> id,
      Value<int> siteId,
      Value<DateTime> checkinDate,
      Value<DateTime> createdAt,
      Value<double?> latitude,
      Value<double?> longitude,
      Value<double?> accuracy,
      Value<String?> notesPublic,
      Value<PendingStatus> status,
      Value<int> attempts,
      Value<DateTime?> lastAttemptAt,
      Value<String?> lastError,
    });

class $$PendingCheckinsTableFilterComposer
    extends Composer<_$AppDatabase, $PendingCheckinsTable> {
  $$PendingCheckinsTableFilterComposer({
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

  ColumnFilters<int> get siteId => $composableBuilder(
    column: $table.siteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get checkinDate => $composableBuilder(
    column: $table.checkinDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get accuracy => $composableBuilder(
    column: $table.accuracy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notesPublic => $composableBuilder(
    column: $table.notesPublic,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<PendingStatus, PendingStatus, String>
  get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastAttemptAt => $composableBuilder(
    column: $table.lastAttemptAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PendingCheckinsTableOrderingComposer
    extends Composer<_$AppDatabase, $PendingCheckinsTable> {
  $$PendingCheckinsTableOrderingComposer({
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

  ColumnOrderings<int> get siteId => $composableBuilder(
    column: $table.siteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get checkinDate => $composableBuilder(
    column: $table.checkinDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get accuracy => $composableBuilder(
    column: $table.accuracy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notesPublic => $composableBuilder(
    column: $table.notesPublic,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastAttemptAt => $composableBuilder(
    column: $table.lastAttemptAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PendingCheckinsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PendingCheckinsTable> {
  $$PendingCheckinsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get siteId =>
      $composableBuilder(column: $table.siteId, builder: (column) => column);

  GeneratedColumn<DateTime> get checkinDate => $composableBuilder(
    column: $table.checkinDate,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<double> get accuracy =>
      $composableBuilder(column: $table.accuracy, builder: (column) => column);

  GeneratedColumn<String> get notesPublic => $composableBuilder(
    column: $table.notesPublic,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<PendingStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get attempts =>
      $composableBuilder(column: $table.attempts, builder: (column) => column);

  GeneratedColumn<DateTime> get lastAttemptAt => $composableBuilder(
    column: $table.lastAttemptAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);
}

class $$PendingCheckinsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PendingCheckinsTable,
          PendingCheckin,
          $$PendingCheckinsTableFilterComposer,
          $$PendingCheckinsTableOrderingComposer,
          $$PendingCheckinsTableAnnotationComposer,
          $$PendingCheckinsTableCreateCompanionBuilder,
          $$PendingCheckinsTableUpdateCompanionBuilder,
          (
            PendingCheckin,
            BaseReferences<
              _$AppDatabase,
              $PendingCheckinsTable,
              PendingCheckin
            >,
          ),
          PendingCheckin,
          PrefetchHooks Function()
        > {
  $$PendingCheckinsTableTableManager(
    _$AppDatabase db,
    $PendingCheckinsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PendingCheckinsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PendingCheckinsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PendingCheckinsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> siteId = const Value.absent(),
                Value<DateTime> checkinDate = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<double?> latitude = const Value.absent(),
                Value<double?> longitude = const Value.absent(),
                Value<double?> accuracy = const Value.absent(),
                Value<String?> notesPublic = const Value.absent(),
                Value<PendingStatus> status = const Value.absent(),
                Value<int> attempts = const Value.absent(),
                Value<DateTime?> lastAttemptAt = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
              }) => PendingCheckinsCompanion(
                id: id,
                siteId: siteId,
                checkinDate: checkinDate,
                createdAt: createdAt,
                latitude: latitude,
                longitude: longitude,
                accuracy: accuracy,
                notesPublic: notesPublic,
                status: status,
                attempts: attempts,
                lastAttemptAt: lastAttemptAt,
                lastError: lastError,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int siteId,
                required DateTime checkinDate,
                required DateTime createdAt,
                Value<double?> latitude = const Value.absent(),
                Value<double?> longitude = const Value.absent(),
                Value<double?> accuracy = const Value.absent(),
                Value<String?> notesPublic = const Value.absent(),
                Value<PendingStatus> status = const Value.absent(),
                Value<int> attempts = const Value.absent(),
                Value<DateTime?> lastAttemptAt = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
              }) => PendingCheckinsCompanion.insert(
                id: id,
                siteId: siteId,
                checkinDate: checkinDate,
                createdAt: createdAt,
                latitude: latitude,
                longitude: longitude,
                accuracy: accuracy,
                notesPublic: notesPublic,
                status: status,
                attempts: attempts,
                lastAttemptAt: lastAttemptAt,
                lastError: lastError,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PendingCheckinsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PendingCheckinsTable,
      PendingCheckin,
      $$PendingCheckinsTableFilterComposer,
      $$PendingCheckinsTableOrderingComposer,
      $$PendingCheckinsTableAnnotationComposer,
      $$PendingCheckinsTableCreateCompanionBuilder,
      $$PendingCheckinsTableUpdateCompanionBuilder,
      (
        PendingCheckin,
        BaseReferences<_$AppDatabase, $PendingCheckinsTable, PendingCheckin>,
      ),
      PendingCheckin,
      PrefetchHooks Function()
    >;
typedef $$SiteCheckinsTableCreateCompanionBuilder =
    SiteCheckinsCompanion Function({
      Value<int> id,
      required int checkinId,
      required int siteId,
      required int odUserId,
      required String username,
      Value<String?> displayName,
      required DateTime checkinDate,
      required DateTime checkinTime,
      Value<bool> isFirstAtSupercharger,
      Value<int?> daysAfterOpen,
      required DateTime syncedAt,
    });
typedef $$SiteCheckinsTableUpdateCompanionBuilder =
    SiteCheckinsCompanion Function({
      Value<int> id,
      Value<int> checkinId,
      Value<int> siteId,
      Value<int> odUserId,
      Value<String> username,
      Value<String?> displayName,
      Value<DateTime> checkinDate,
      Value<DateTime> checkinTime,
      Value<bool> isFirstAtSupercharger,
      Value<int?> daysAfterOpen,
      Value<DateTime> syncedAt,
    });

class $$SiteCheckinsTableFilterComposer
    extends Composer<_$AppDatabase, $SiteCheckinsTable> {
  $$SiteCheckinsTableFilterComposer({
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

  ColumnFilters<int> get checkinId => $composableBuilder(
    column: $table.checkinId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get siteId => $composableBuilder(
    column: $table.siteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get odUserId => $composableBuilder(
    column: $table.odUserId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get username => $composableBuilder(
    column: $table.username,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get checkinDate => $composableBuilder(
    column: $table.checkinDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get checkinTime => $composableBuilder(
    column: $table.checkinTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isFirstAtSupercharger => $composableBuilder(
    column: $table.isFirstAtSupercharger,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get daysAfterOpen => $composableBuilder(
    column: $table.daysAfterOpen,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SiteCheckinsTableOrderingComposer
    extends Composer<_$AppDatabase, $SiteCheckinsTable> {
  $$SiteCheckinsTableOrderingComposer({
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

  ColumnOrderings<int> get checkinId => $composableBuilder(
    column: $table.checkinId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get siteId => $composableBuilder(
    column: $table.siteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get odUserId => $composableBuilder(
    column: $table.odUserId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get username => $composableBuilder(
    column: $table.username,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get checkinDate => $composableBuilder(
    column: $table.checkinDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get checkinTime => $composableBuilder(
    column: $table.checkinTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isFirstAtSupercharger => $composableBuilder(
    column: $table.isFirstAtSupercharger,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get daysAfterOpen => $composableBuilder(
    column: $table.daysAfterOpen,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SiteCheckinsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SiteCheckinsTable> {
  $$SiteCheckinsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get checkinId =>
      $composableBuilder(column: $table.checkinId, builder: (column) => column);

  GeneratedColumn<int> get siteId =>
      $composableBuilder(column: $table.siteId, builder: (column) => column);

  GeneratedColumn<int> get odUserId =>
      $composableBuilder(column: $table.odUserId, builder: (column) => column);

  GeneratedColumn<String> get username =>
      $composableBuilder(column: $table.username, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get checkinDate => $composableBuilder(
    column: $table.checkinDate,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get checkinTime => $composableBuilder(
    column: $table.checkinTime,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isFirstAtSupercharger => $composableBuilder(
    column: $table.isFirstAtSupercharger,
    builder: (column) => column,
  );

  GeneratedColumn<int> get daysAfterOpen => $composableBuilder(
    column: $table.daysAfterOpen,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);
}

class $$SiteCheckinsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SiteCheckinsTable,
          SiteCheckin,
          $$SiteCheckinsTableFilterComposer,
          $$SiteCheckinsTableOrderingComposer,
          $$SiteCheckinsTableAnnotationComposer,
          $$SiteCheckinsTableCreateCompanionBuilder,
          $$SiteCheckinsTableUpdateCompanionBuilder,
          (
            SiteCheckin,
            BaseReferences<_$AppDatabase, $SiteCheckinsTable, SiteCheckin>,
          ),
          SiteCheckin,
          PrefetchHooks Function()
        > {
  $$SiteCheckinsTableTableManager(_$AppDatabase db, $SiteCheckinsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SiteCheckinsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SiteCheckinsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SiteCheckinsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> checkinId = const Value.absent(),
                Value<int> siteId = const Value.absent(),
                Value<int> odUserId = const Value.absent(),
                Value<String> username = const Value.absent(),
                Value<String?> displayName = const Value.absent(),
                Value<DateTime> checkinDate = const Value.absent(),
                Value<DateTime> checkinTime = const Value.absent(),
                Value<bool> isFirstAtSupercharger = const Value.absent(),
                Value<int?> daysAfterOpen = const Value.absent(),
                Value<DateTime> syncedAt = const Value.absent(),
              }) => SiteCheckinsCompanion(
                id: id,
                checkinId: checkinId,
                siteId: siteId,
                odUserId: odUserId,
                username: username,
                displayName: displayName,
                checkinDate: checkinDate,
                checkinTime: checkinTime,
                isFirstAtSupercharger: isFirstAtSupercharger,
                daysAfterOpen: daysAfterOpen,
                syncedAt: syncedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int checkinId,
                required int siteId,
                required int odUserId,
                required String username,
                Value<String?> displayName = const Value.absent(),
                required DateTime checkinDate,
                required DateTime checkinTime,
                Value<bool> isFirstAtSupercharger = const Value.absent(),
                Value<int?> daysAfterOpen = const Value.absent(),
                required DateTime syncedAt,
              }) => SiteCheckinsCompanion.insert(
                id: id,
                checkinId: checkinId,
                siteId: siteId,
                odUserId: odUserId,
                username: username,
                displayName: displayName,
                checkinDate: checkinDate,
                checkinTime: checkinTime,
                isFirstAtSupercharger: isFirstAtSupercharger,
                daysAfterOpen: daysAfterOpen,
                syncedAt: syncedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SiteCheckinsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SiteCheckinsTable,
      SiteCheckin,
      $$SiteCheckinsTableFilterComposer,
      $$SiteCheckinsTableOrderingComposer,
      $$SiteCheckinsTableAnnotationComposer,
      $$SiteCheckinsTableCreateCompanionBuilder,
      $$SiteCheckinsTableUpdateCompanionBuilder,
      (
        SiteCheckin,
        BaseReferences<_$AppDatabase, $SiteCheckinsTable, SiteCheckin>,
      ),
      SiteCheckin,
      PrefetchHooks Function()
    >;
typedef $$UserSettingsTableTableCreateCompanionBuilder =
    UserSettingsTableCompanion Function({
      Value<int> id,
      Value<int?> odUserId,
      Value<String?> username,
      Value<String?> displayName,
      Value<bool> isAuthenticated,
      Value<DateTime?> firstLoginAt,
      Value<DateTime?> lastLoginAt,
      Value<DateTime?> lastXlsxSyncAt,
      Value<PollingInterval> pollingInterval,
      Value<double> notificationRadiusKm,
      Value<MapFilter> mapFilter,
      Value<bool> showVisitedOnMap,
      Value<double> checkinRadiusKm,
      Value<UnitSystem> unitSystem,
      Value<double?> lastLatitude,
      Value<double?> lastLongitude,
      Value<DateTime?> lastSitesSyncAt,
      Value<DateTime?> lastCheckinHistorySyncAt,
    });
typedef $$UserSettingsTableTableUpdateCompanionBuilder =
    UserSettingsTableCompanion Function({
      Value<int> id,
      Value<int?> odUserId,
      Value<String?> username,
      Value<String?> displayName,
      Value<bool> isAuthenticated,
      Value<DateTime?> firstLoginAt,
      Value<DateTime?> lastLoginAt,
      Value<DateTime?> lastXlsxSyncAt,
      Value<PollingInterval> pollingInterval,
      Value<double> notificationRadiusKm,
      Value<MapFilter> mapFilter,
      Value<bool> showVisitedOnMap,
      Value<double> checkinRadiusKm,
      Value<UnitSystem> unitSystem,
      Value<double?> lastLatitude,
      Value<double?> lastLongitude,
      Value<DateTime?> lastSitesSyncAt,
      Value<DateTime?> lastCheckinHistorySyncAt,
    });

class $$UserSettingsTableTableFilterComposer
    extends Composer<_$AppDatabase, $UserSettingsTableTable> {
  $$UserSettingsTableTableFilterComposer({
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

  ColumnFilters<int> get odUserId => $composableBuilder(
    column: $table.odUserId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get username => $composableBuilder(
    column: $table.username,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isAuthenticated => $composableBuilder(
    column: $table.isAuthenticated,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get firstLoginAt => $composableBuilder(
    column: $table.firstLoginAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastLoginAt => $composableBuilder(
    column: $table.lastLoginAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastXlsxSyncAt => $composableBuilder(
    column: $table.lastXlsxSyncAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<PollingInterval, PollingInterval, String>
  get pollingInterval => $composableBuilder(
    column: $table.pollingInterval,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<double> get notificationRadiusKm => $composableBuilder(
    column: $table.notificationRadiusKm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<MapFilter, MapFilter, String> get mapFilter =>
      $composableBuilder(
        column: $table.mapFilter,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<bool> get showVisitedOnMap => $composableBuilder(
    column: $table.showVisitedOnMap,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get checkinRadiusKm => $composableBuilder(
    column: $table.checkinRadiusKm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<UnitSystem, UnitSystem, String>
  get unitSystem => $composableBuilder(
    column: $table.unitSystem,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<double> get lastLatitude => $composableBuilder(
    column: $table.lastLatitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lastLongitude => $composableBuilder(
    column: $table.lastLongitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSitesSyncAt => $composableBuilder(
    column: $table.lastSitesSyncAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastCheckinHistorySyncAt => $composableBuilder(
    column: $table.lastCheckinHistorySyncAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UserSettingsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $UserSettingsTableTable> {
  $$UserSettingsTableTableOrderingComposer({
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

  ColumnOrderings<int> get odUserId => $composableBuilder(
    column: $table.odUserId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get username => $composableBuilder(
    column: $table.username,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isAuthenticated => $composableBuilder(
    column: $table.isAuthenticated,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get firstLoginAt => $composableBuilder(
    column: $table.firstLoginAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastLoginAt => $composableBuilder(
    column: $table.lastLoginAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastXlsxSyncAt => $composableBuilder(
    column: $table.lastXlsxSyncAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pollingInterval => $composableBuilder(
    column: $table.pollingInterval,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get notificationRadiusKm => $composableBuilder(
    column: $table.notificationRadiusKm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mapFilter => $composableBuilder(
    column: $table.mapFilter,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get showVisitedOnMap => $composableBuilder(
    column: $table.showVisitedOnMap,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get checkinRadiusKm => $composableBuilder(
    column: $table.checkinRadiusKm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unitSystem => $composableBuilder(
    column: $table.unitSystem,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lastLatitude => $composableBuilder(
    column: $table.lastLatitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lastLongitude => $composableBuilder(
    column: $table.lastLongitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSitesSyncAt => $composableBuilder(
    column: $table.lastSitesSyncAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastCheckinHistorySyncAt => $composableBuilder(
    column: $table.lastCheckinHistorySyncAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UserSettingsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserSettingsTableTable> {
  $$UserSettingsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get odUserId =>
      $composableBuilder(column: $table.odUserId, builder: (column) => column);

  GeneratedColumn<String> get username =>
      $composableBuilder(column: $table.username, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isAuthenticated => $composableBuilder(
    column: $table.isAuthenticated,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get firstLoginAt => $composableBuilder(
    column: $table.firstLoginAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastLoginAt => $composableBuilder(
    column: $table.lastLoginAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastXlsxSyncAt => $composableBuilder(
    column: $table.lastXlsxSyncAt,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<PollingInterval, String>
  get pollingInterval => $composableBuilder(
    column: $table.pollingInterval,
    builder: (column) => column,
  );

  GeneratedColumn<double> get notificationRadiusKm => $composableBuilder(
    column: $table.notificationRadiusKm,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<MapFilter, String> get mapFilter =>
      $composableBuilder(column: $table.mapFilter, builder: (column) => column);

  GeneratedColumn<bool> get showVisitedOnMap => $composableBuilder(
    column: $table.showVisitedOnMap,
    builder: (column) => column,
  );

  GeneratedColumn<double> get checkinRadiusKm => $composableBuilder(
    column: $table.checkinRadiusKm,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<UnitSystem, String> get unitSystem =>
      $composableBuilder(
        column: $table.unitSystem,
        builder: (column) => column,
      );

  GeneratedColumn<double> get lastLatitude => $composableBuilder(
    column: $table.lastLatitude,
    builder: (column) => column,
  );

  GeneratedColumn<double> get lastLongitude => $composableBuilder(
    column: $table.lastLongitude,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastSitesSyncAt => $composableBuilder(
    column: $table.lastSitesSyncAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastCheckinHistorySyncAt => $composableBuilder(
    column: $table.lastCheckinHistorySyncAt,
    builder: (column) => column,
  );
}

class $$UserSettingsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserSettingsTableTable,
          UserSettingsTableData,
          $$UserSettingsTableTableFilterComposer,
          $$UserSettingsTableTableOrderingComposer,
          $$UserSettingsTableTableAnnotationComposer,
          $$UserSettingsTableTableCreateCompanionBuilder,
          $$UserSettingsTableTableUpdateCompanionBuilder,
          (
            UserSettingsTableData,
            BaseReferences<
              _$AppDatabase,
              $UserSettingsTableTable,
              UserSettingsTableData
            >,
          ),
          UserSettingsTableData,
          PrefetchHooks Function()
        > {
  $$UserSettingsTableTableTableManager(
    _$AppDatabase db,
    $UserSettingsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserSettingsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserSettingsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserSettingsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> odUserId = const Value.absent(),
                Value<String?> username = const Value.absent(),
                Value<String?> displayName = const Value.absent(),
                Value<bool> isAuthenticated = const Value.absent(),
                Value<DateTime?> firstLoginAt = const Value.absent(),
                Value<DateTime?> lastLoginAt = const Value.absent(),
                Value<DateTime?> lastXlsxSyncAt = const Value.absent(),
                Value<PollingInterval> pollingInterval = const Value.absent(),
                Value<double> notificationRadiusKm = const Value.absent(),
                Value<MapFilter> mapFilter = const Value.absent(),
                Value<bool> showVisitedOnMap = const Value.absent(),
                Value<double> checkinRadiusKm = const Value.absent(),
                Value<UnitSystem> unitSystem = const Value.absent(),
                Value<double?> lastLatitude = const Value.absent(),
                Value<double?> lastLongitude = const Value.absent(),
                Value<DateTime?> lastSitesSyncAt = const Value.absent(),
                Value<DateTime?> lastCheckinHistorySyncAt =
                    const Value.absent(),
              }) => UserSettingsTableCompanion(
                id: id,
                odUserId: odUserId,
                username: username,
                displayName: displayName,
                isAuthenticated: isAuthenticated,
                firstLoginAt: firstLoginAt,
                lastLoginAt: lastLoginAt,
                lastXlsxSyncAt: lastXlsxSyncAt,
                pollingInterval: pollingInterval,
                notificationRadiusKm: notificationRadiusKm,
                mapFilter: mapFilter,
                showVisitedOnMap: showVisitedOnMap,
                checkinRadiusKm: checkinRadiusKm,
                unitSystem: unitSystem,
                lastLatitude: lastLatitude,
                lastLongitude: lastLongitude,
                lastSitesSyncAt: lastSitesSyncAt,
                lastCheckinHistorySyncAt: lastCheckinHistorySyncAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> odUserId = const Value.absent(),
                Value<String?> username = const Value.absent(),
                Value<String?> displayName = const Value.absent(),
                Value<bool> isAuthenticated = const Value.absent(),
                Value<DateTime?> firstLoginAt = const Value.absent(),
                Value<DateTime?> lastLoginAt = const Value.absent(),
                Value<DateTime?> lastXlsxSyncAt = const Value.absent(),
                Value<PollingInterval> pollingInterval = const Value.absent(),
                Value<double> notificationRadiusKm = const Value.absent(),
                Value<MapFilter> mapFilter = const Value.absent(),
                Value<bool> showVisitedOnMap = const Value.absent(),
                Value<double> checkinRadiusKm = const Value.absent(),
                Value<UnitSystem> unitSystem = const Value.absent(),
                Value<double?> lastLatitude = const Value.absent(),
                Value<double?> lastLongitude = const Value.absent(),
                Value<DateTime?> lastSitesSyncAt = const Value.absent(),
                Value<DateTime?> lastCheckinHistorySyncAt =
                    const Value.absent(),
              }) => UserSettingsTableCompanion.insert(
                id: id,
                odUserId: odUserId,
                username: username,
                displayName: displayName,
                isAuthenticated: isAuthenticated,
                firstLoginAt: firstLoginAt,
                lastLoginAt: lastLoginAt,
                lastXlsxSyncAt: lastXlsxSyncAt,
                pollingInterval: pollingInterval,
                notificationRadiusKm: notificationRadiusKm,
                mapFilter: mapFilter,
                showVisitedOnMap: showVisitedOnMap,
                checkinRadiusKm: checkinRadiusKm,
                unitSystem: unitSystem,
                lastLatitude: lastLatitude,
                lastLongitude: lastLongitude,
                lastSitesSyncAt: lastSitesSyncAt,
                lastCheckinHistorySyncAt: lastCheckinHistorySyncAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UserSettingsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserSettingsTableTable,
      UserSettingsTableData,
      $$UserSettingsTableTableFilterComposer,
      $$UserSettingsTableTableOrderingComposer,
      $$UserSettingsTableTableAnnotationComposer,
      $$UserSettingsTableTableCreateCompanionBuilder,
      $$UserSettingsTableTableUpdateCompanionBuilder,
      (
        UserSettingsTableData,
        BaseReferences<
          _$AppDatabase,
          $UserSettingsTableTable,
          UserSettingsTableData
        >,
      ),
      UserSettingsTableData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$SitesTableTableManager get sites =>
      $$SitesTableTableManager(_db, _db.sites);
  $$VisitsTableTableManager get visits =>
      $$VisitsTableTableManager(_db, _db.visits);
  $$PendingCheckinsTableTableManager get pendingCheckins =>
      $$PendingCheckinsTableTableManager(_db, _db.pendingCheckins);
  $$SiteCheckinsTableTableManager get siteCheckins =>
      $$SiteCheckinsTableTableManager(_db, _db.siteCheckins);
  $$UserSettingsTableTableTableManager get userSettingsTable =>
      $$UserSettingsTableTableTableManager(_db, _db.userSettingsTable);
}
