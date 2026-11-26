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
  static const VerificationMeta _streetMeta = const VerificationMeta('street');
  @override
  late final GeneratedColumn<String> street = GeneratedColumn<String>(
    'street',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
  static const VerificationMeta _stallsV2Meta = const VerificationMeta(
    'stallsV2',
  );
  @override
  late final GeneratedColumn<int> stallsV2 = GeneratedColumn<int>(
    'stalls_v2',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _stallsV3Meta = const VerificationMeta(
    'stallsV3',
  );
  @override
  late final GeneratedColumn<int> stallsV3 = GeneratedColumn<int>(
    'stalls_v3',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _stallsV4Meta = const VerificationMeta(
    'stallsV4',
  );
  @override
  late final GeneratedColumn<int> stallsV4 = GeneratedColumn<int>(
    'stalls_v4',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _stallsUrbanMeta = const VerificationMeta(
    'stallsUrban',
  );
  @override
  late final GeneratedColumn<int> stallsUrban = GeneratedColumn<int>(
    'stalls_urban',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _stallsOtherMeta = const VerificationMeta(
    'stallsOther',
  );
  @override
  late final GeneratedColumn<int> stallsOther = GeneratedColumn<int>(
    'stalls_other',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _otherEvsMeta = const VerificationMeta(
    'otherEvs',
  );
  @override
  late final GeneratedColumn<bool> otherEvs = GeneratedColumn<bool>(
    'other_evs',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("other_evs" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
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
  static const VerificationMeta _firstOpenedMeta = const VerificationMeta(
    'firstOpened',
  );
  @override
  late final GeneratedColumn<DateTime> firstOpened = GeneratedColumn<DateTime>(
    'first_opened',
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
    street,
    city,
    state,
    country,
    region,
    timezone,
    stallCount,
    stallsV2,
    stallsV3,
    stallsV4,
    stallsUrban,
    stallsOther,
    otherEvs,
    dateOpened,
    firstOpened,
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
    if (data.containsKey('street')) {
      context.handle(
        _streetMeta,
        street.isAcceptableOrUnknown(data['street']!, _streetMeta),
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
    if (data.containsKey('stalls_v2')) {
      context.handle(
        _stallsV2Meta,
        stallsV2.isAcceptableOrUnknown(data['stalls_v2']!, _stallsV2Meta),
      );
    }
    if (data.containsKey('stalls_v3')) {
      context.handle(
        _stallsV3Meta,
        stallsV3.isAcceptableOrUnknown(data['stalls_v3']!, _stallsV3Meta),
      );
    }
    if (data.containsKey('stalls_v4')) {
      context.handle(
        _stallsV4Meta,
        stallsV4.isAcceptableOrUnknown(data['stalls_v4']!, _stallsV4Meta),
      );
    }
    if (data.containsKey('stalls_urban')) {
      context.handle(
        _stallsUrbanMeta,
        stallsUrban.isAcceptableOrUnknown(
          data['stalls_urban']!,
          _stallsUrbanMeta,
        ),
      );
    }
    if (data.containsKey('stalls_other')) {
      context.handle(
        _stallsOtherMeta,
        stallsOther.isAcceptableOrUnknown(
          data['stalls_other']!,
          _stallsOtherMeta,
        ),
      );
    }
    if (data.containsKey('other_evs')) {
      context.handle(
        _otherEvsMeta,
        otherEvs.isAcceptableOrUnknown(data['other_evs']!, _otherEvsMeta),
      );
    }
    if (data.containsKey('date_opened')) {
      context.handle(
        _dateOpenedMeta,
        dateOpened.isAcceptableOrUnknown(data['date_opened']!, _dateOpenedMeta),
      );
    }
    if (data.containsKey('first_opened')) {
      context.handle(
        _firstOpenedMeta,
        firstOpened.isAcceptableOrUnknown(
          data['first_opened']!,
          _firstOpenedMeta,
        ),
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
      street: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}street'],
      ),
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
      stallsV2: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}stalls_v2'],
      )!,
      stallsV3: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}stalls_v3'],
      )!,
      stallsV4: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}stalls_v4'],
      )!,
      stallsUrban: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}stalls_urban'],
      )!,
      stallsOther: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}stalls_other'],
      )!,
      otherEvs: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}other_evs'],
      )!,
      dateOpened: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date_opened'],
      ),
      firstOpened: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}first_opened'],
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
  final String? street;
  final String? city;
  final String? state;
  final String country;
  final String region;

  /// IANA timezone derived from coordinates at ingestion (SPEC Section 3).
  /// Drives the site-local "First" day boundary.
  final String? timezone;
  final int? stallCount;
  final int stallsV2;
  final int stallsV3;
  final int stallsV4;
  final int stallsUrban;
  final int stallsOther;

  /// Open to non-Tesla vehicles.
  final bool otherEvs;
  final DateTime? dateOpened;

  /// Earliest OPEN transition observed in supercharge.info change history.
  /// Unlike dateOpened, this survives a later closure and reopening.
  final DateTime? firstOpened;

  /// Cache of "community check-in count > 0" from the counts endpoint.
  /// Only undated operational sites use it as a conservative taken fallback.
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
    this.street,
    this.city,
    this.state,
    required this.country,
    required this.region,
    this.timezone,
    this.stallCount,
    required this.stallsV2,
    required this.stallsV3,
    required this.stallsV4,
    required this.stallsUrban,
    required this.stallsOther,
    required this.otherEvs,
    this.dateOpened,
    this.firstOpened,
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
    if (!nullToAbsent || street != null) {
      map['street'] = Variable<String>(street);
    }
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
    map['stalls_v2'] = Variable<int>(stallsV2);
    map['stalls_v3'] = Variable<int>(stallsV3);
    map['stalls_v4'] = Variable<int>(stallsV4);
    map['stalls_urban'] = Variable<int>(stallsUrban);
    map['stalls_other'] = Variable<int>(stallsOther);
    map['other_evs'] = Variable<bool>(otherEvs);
    if (!nullToAbsent || dateOpened != null) {
      map['date_opened'] = Variable<DateTime>(dateOpened);
    }
    if (!nullToAbsent || firstOpened != null) {
      map['first_opened'] = Variable<DateTime>(firstOpened);
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
      street: street == null && nullToAbsent
          ? const Value.absent()
          : Value(street),
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
      stallsV2: Value(stallsV2),
      stallsV3: Value(stallsV3),
      stallsV4: Value(stallsV4),
      stallsUrban: Value(stallsUrban),
      stallsOther: Value(stallsOther),
      otherEvs: Value(otherEvs),
      dateOpened: dateOpened == null && nullToAbsent
          ? const Value.absent()
          : Value(dateOpened),
      firstOpened: firstOpened == null && nullToAbsent
          ? const Value.absent()
          : Value(firstOpened),
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
      street: serializer.fromJson<String?>(json['street']),
      city: serializer.fromJson<String?>(json['city']),
      state: serializer.fromJson<String?>(json['state']),
      country: serializer.fromJson<String>(json['country']),
      region: serializer.fromJson<String>(json['region']),
      timezone: serializer.fromJson<String?>(json['timezone']),
      stallCount: serializer.fromJson<int?>(json['stallCount']),
      stallsV2: serializer.fromJson<int>(json['stallsV2']),
      stallsV3: serializer.fromJson<int>(json['stallsV3']),
      stallsV4: serializer.fromJson<int>(json['stallsV4']),
      stallsUrban: serializer.fromJson<int>(json['stallsUrban']),
      stallsOther: serializer.fromJson<int>(json['stallsOther']),
      otherEvs: serializer.fromJson<bool>(json['otherEvs']),
      dateOpened: serializer.fromJson<DateTime?>(json['dateOpened']),
      firstOpened: serializer.fromJson<DateTime?>(json['firstOpened']),
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
      'street': serializer.toJson<String?>(street),
      'city': serializer.toJson<String?>(city),
      'state': serializer.toJson<String?>(state),
      'country': serializer.toJson<String>(country),
      'region': serializer.toJson<String>(region),
      'timezone': serializer.toJson<String?>(timezone),
      'stallCount': serializer.toJson<int?>(stallCount),
      'stallsV2': serializer.toJson<int>(stallsV2),
      'stallsV3': serializer.toJson<int>(stallsV3),
      'stallsV4': serializer.toJson<int>(stallsV4),
      'stallsUrban': serializer.toJson<int>(stallsUrban),
      'stallsOther': serializer.toJson<int>(stallsOther),
      'otherEvs': serializer.toJson<bool>(otherEvs),
      'dateOpened': serializer.toJson<DateTime?>(dateOpened),
      'firstOpened': serializer.toJson<DateTime?>(firstOpened),
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
    Value<String?> street = const Value.absent(),
    Value<String?> city = const Value.absent(),
    Value<String?> state = const Value.absent(),
    String? country,
    String? region,
    Value<String?> timezone = const Value.absent(),
    Value<int?> stallCount = const Value.absent(),
    int? stallsV2,
    int? stallsV3,
    int? stallsV4,
    int? stallsUrban,
    int? stallsOther,
    bool? otherEvs,
    Value<DateTime?> dateOpened = const Value.absent(),
    Value<DateTime?> firstOpened = const Value.absent(),
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
    street: street.present ? street.value : this.street,
    city: city.present ? city.value : this.city,
    state: state.present ? state.value : this.state,
    country: country ?? this.country,
    region: region ?? this.region,
    timezone: timezone.present ? timezone.value : this.timezone,
    stallCount: stallCount.present ? stallCount.value : this.stallCount,
    stallsV2: stallsV2 ?? this.stallsV2,
    stallsV3: stallsV3 ?? this.stallsV3,
    stallsV4: stallsV4 ?? this.stallsV4,
    stallsUrban: stallsUrban ?? this.stallsUrban,
    stallsOther: stallsOther ?? this.stallsOther,
    otherEvs: otherEvs ?? this.otherEvs,
    dateOpened: dateOpened.present ? dateOpened.value : this.dateOpened,
    firstOpened: firstOpened.present ? firstOpened.value : this.firstOpened,
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
      street: data.street.present ? data.street.value : this.street,
      city: data.city.present ? data.city.value : this.city,
      state: data.state.present ? data.state.value : this.state,
      country: data.country.present ? data.country.value : this.country,
      region: data.region.present ? data.region.value : this.region,
      timezone: data.timezone.present ? data.timezone.value : this.timezone,
      stallCount: data.stallCount.present
          ? data.stallCount.value
          : this.stallCount,
      stallsV2: data.stallsV2.present ? data.stallsV2.value : this.stallsV2,
      stallsV3: data.stallsV3.present ? data.stallsV3.value : this.stallsV3,
      stallsV4: data.stallsV4.present ? data.stallsV4.value : this.stallsV4,
      stallsUrban: data.stallsUrban.present
          ? data.stallsUrban.value
          : this.stallsUrban,
      stallsOther: data.stallsOther.present
          ? data.stallsOther.value
          : this.stallsOther,
      otherEvs: data.otherEvs.present ? data.otherEvs.value : this.otherEvs,
      dateOpened: data.dateOpened.present
          ? data.dateOpened.value
          : this.dateOpened,
      firstOpened: data.firstOpened.present
          ? data.firstOpened.value
          : this.firstOpened,
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
          ..write('street: $street, ')
          ..write('city: $city, ')
          ..write('state: $state, ')
          ..write('country: $country, ')
          ..write('region: $region, ')
          ..write('timezone: $timezone, ')
          ..write('stallCount: $stallCount, ')
          ..write('stallsV2: $stallsV2, ')
          ..write('stallsV3: $stallsV3, ')
          ..write('stallsV4: $stallsV4, ')
          ..write('stallsUrban: $stallsUrban, ')
          ..write('stallsOther: $stallsOther, ')
          ..write('otherEvs: $otherEvs, ')
          ..write('dateOpened: $dateOpened, ')
          ..write('firstOpened: $firstOpened, ')
          ..write('hasCheckins: $hasCheckins, ')
          ..write('visited: $visited, ')
          ..write('lastSynced: $lastSynced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    siteId,
    locationId,
    name,
    status,
    latitude,
    longitude,
    street,
    city,
    state,
    country,
    region,
    timezone,
    stallCount,
    stallsV2,
    stallsV3,
    stallsV4,
    stallsUrban,
    stallsOther,
    otherEvs,
    dateOpened,
    firstOpened,
    hasCheckins,
    visited,
    lastSynced,
  ]);
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
          other.street == this.street &&
          other.city == this.city &&
          other.state == this.state &&
          other.country == this.country &&
          other.region == this.region &&
          other.timezone == this.timezone &&
          other.stallCount == this.stallCount &&
          other.stallsV2 == this.stallsV2 &&
          other.stallsV3 == this.stallsV3 &&
          other.stallsV4 == this.stallsV4 &&
          other.stallsUrban == this.stallsUrban &&
          other.stallsOther == this.stallsOther &&
          other.otherEvs == this.otherEvs &&
          other.dateOpened == this.dateOpened &&
          other.firstOpened == this.firstOpened &&
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
  final Value<String?> street;
  final Value<String?> city;
  final Value<String?> state;
  final Value<String> country;
  final Value<String> region;
  final Value<String?> timezone;
  final Value<int?> stallCount;
  final Value<int> stallsV2;
  final Value<int> stallsV3;
  final Value<int> stallsV4;
  final Value<int> stallsUrban;
  final Value<int> stallsOther;
  final Value<bool> otherEvs;
  final Value<DateTime?> dateOpened;
  final Value<DateTime?> firstOpened;
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
    this.street = const Value.absent(),
    this.city = const Value.absent(),
    this.state = const Value.absent(),
    this.country = const Value.absent(),
    this.region = const Value.absent(),
    this.timezone = const Value.absent(),
    this.stallCount = const Value.absent(),
    this.stallsV2 = const Value.absent(),
    this.stallsV3 = const Value.absent(),
    this.stallsV4 = const Value.absent(),
    this.stallsUrban = const Value.absent(),
    this.stallsOther = const Value.absent(),
    this.otherEvs = const Value.absent(),
    this.dateOpened = const Value.absent(),
    this.firstOpened = const Value.absent(),
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
    this.street = const Value.absent(),
    this.city = const Value.absent(),
    this.state = const Value.absent(),
    this.country = const Value.absent(),
    this.region = const Value.absent(),
    this.timezone = const Value.absent(),
    this.stallCount = const Value.absent(),
    this.stallsV2 = const Value.absent(),
    this.stallsV3 = const Value.absent(),
    this.stallsV4 = const Value.absent(),
    this.stallsUrban = const Value.absent(),
    this.stallsOther = const Value.absent(),
    this.otherEvs = const Value.absent(),
    this.dateOpened = const Value.absent(),
    this.firstOpened = const Value.absent(),
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
    Expression<String>? street,
    Expression<String>? city,
    Expression<String>? state,
    Expression<String>? country,
    Expression<String>? region,
    Expression<String>? timezone,
    Expression<int>? stallCount,
    Expression<int>? stallsV2,
    Expression<int>? stallsV3,
    Expression<int>? stallsV4,
    Expression<int>? stallsUrban,
    Expression<int>? stallsOther,
    Expression<bool>? otherEvs,
    Expression<DateTime>? dateOpened,
    Expression<DateTime>? firstOpened,
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
      if (street != null) 'street': street,
      if (city != null) 'city': city,
      if (state != null) 'state': state,
      if (country != null) 'country': country,
      if (region != null) 'region': region,
      if (timezone != null) 'timezone': timezone,
      if (stallCount != null) 'stall_count': stallCount,
      if (stallsV2 != null) 'stalls_v2': stallsV2,
      if (stallsV3 != null) 'stalls_v3': stallsV3,
      if (stallsV4 != null) 'stalls_v4': stallsV4,
      if (stallsUrban != null) 'stalls_urban': stallsUrban,
      if (stallsOther != null) 'stalls_other': stallsOther,
      if (otherEvs != null) 'other_evs': otherEvs,
      if (dateOpened != null) 'date_opened': dateOpened,
      if (firstOpened != null) 'first_opened': firstOpened,
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
    Value<String?>? street,
    Value<String?>? city,
    Value<String?>? state,
    Value<String>? country,
    Value<String>? region,
    Value<String?>? timezone,
    Value<int?>? stallCount,
    Value<int>? stallsV2,
    Value<int>? stallsV3,
    Value<int>? stallsV4,
    Value<int>? stallsUrban,
    Value<int>? stallsOther,
    Value<bool>? otherEvs,
    Value<DateTime?>? dateOpened,
    Value<DateTime?>? firstOpened,
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
      street: street ?? this.street,
      city: city ?? this.city,
      state: state ?? this.state,
      country: country ?? this.country,
      region: region ?? this.region,
      timezone: timezone ?? this.timezone,
      stallCount: stallCount ?? this.stallCount,
      stallsV2: stallsV2 ?? this.stallsV2,
      stallsV3: stallsV3 ?? this.stallsV3,
      stallsV4: stallsV4 ?? this.stallsV4,
      stallsUrban: stallsUrban ?? this.stallsUrban,
      stallsOther: stallsOther ?? this.stallsOther,
      otherEvs: otherEvs ?? this.otherEvs,
      dateOpened: dateOpened ?? this.dateOpened,
      firstOpened: firstOpened ?? this.firstOpened,
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
    if (street.present) {
      map['street'] = Variable<String>(street.value);
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
    if (stallsV2.present) {
      map['stalls_v2'] = Variable<int>(stallsV2.value);
    }
    if (stallsV3.present) {
      map['stalls_v3'] = Variable<int>(stallsV3.value);
    }
    if (stallsV4.present) {
      map['stalls_v4'] = Variable<int>(stallsV4.value);
    }
    if (stallsUrban.present) {
      map['stalls_urban'] = Variable<int>(stallsUrban.value);
    }
    if (stallsOther.present) {
      map['stalls_other'] = Variable<int>(stallsOther.value);
    }
    if (otherEvs.present) {
      map['other_evs'] = Variable<bool>(otherEvs.value);
    }
    if (dateOpened.present) {
      map['date_opened'] = Variable<DateTime>(dateOpened.value);
    }
    if (firstOpened.present) {
      map['first_opened'] = Variable<DateTime>(firstOpened.value);
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
          ..write('street: $street, ')
          ..write('city: $city, ')
          ..write('state: $state, ')
          ..write('country: $country, ')
          ..write('region: $region, ')
          ..write('timezone: $timezone, ')
          ..write('stallCount: $stallCount, ')
          ..write('stallsV2: $stallsV2, ')
          ..write('stallsV3: $stallsV3, ')
          ..write('stallsV4: $stallsV4, ')
          ..write('stallsUrban: $stallsUrban, ')
          ..write('stallsOther: $stallsOther, ')
          ..write('otherEvs: $otherEvs, ')
          ..write('dateOpened: $dateOpened, ')
          ..write('firstOpened: $firstOpened, ')
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
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
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
  @override
  late final GeneratedColumnWithTypeConverter<CheckinPrecision, String>
  checkinPrecision = GeneratedColumn<String>(
    'checkin_precision',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: Constant(CheckinPrecision.timestamp.name),
  ).withConverter<CheckinPrecision>($VisitsTable.$convertercheckinPrecision);
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
  static const VerificationMeta _notesPrivateMeta = const VerificationMeta(
    'notesPrivate',
  );
  @override
  late final GeneratedColumn<String> notesPrivate = GeneratedColumn<String>(
    'notes_private',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _vehicleIdMeta = const VerificationMeta(
    'vehicleId',
  );
  @override
  late final GeneratedColumn<String> vehicleId = GeneratedColumn<String>(
    'vehicle_id',
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
    checkinPrecision,
    isFirst,
    method,
    notesPublic,
    notesPrivate,
    vehicleId,
    geoDistanceAccuracy,
    geoDistance,
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
    if (data.containsKey('notes_private')) {
      context.handle(
        _notesPrivateMeta,
        notesPrivate.isAcceptableOrUnknown(
          data['notes_private']!,
          _notesPrivateMeta,
        ),
      );
    }
    if (data.containsKey('vehicle_id')) {
      context.handle(
        _vehicleIdMeta,
        vehicleId.isAcceptableOrUnknown(data['vehicle_id']!, _vehicleIdMeta),
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
      ),
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
      checkinPrecision: $VisitsTable.$convertercheckinPrecision.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}checkin_precision'],
        )!,
      ),
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
      notesPrivate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes_private'],
      ),
      vehicleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}vehicle_id'],
      ),
      geoDistanceAccuracy: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}geo_distance_accuracy'],
      ),
      geoDistance: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}geo_distance'],
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

  static JsonTypeConverter2<CheckinPrecision, String, String>
  $convertercheckinPrecision = const EnumNameConverter<CheckinPrecision>(
    CheckinPrecision.values,
  );
  static JsonTypeConverter2<CheckinMethod, String, String> $convertermethod =
      const EnumNameConverter<CheckinMethod>(CheckinMethod.values);
}

class Visit extends DataClass implements Insertable<Visit> {
  final int id;

  /// Server-assigned supercharging.life check-in id, kept as that integer.
  /// Null until the site assigns one. Several local rows can be null together.
  final int? checkinId;
  final int siteId;
  final DateTime checkinDate;
  final DateTime checkinTime;

  /// dateOnly when the source had a calendar date and no clock time.
  /// timestamp when check-in detail includes a time, as the live form sends.
  final CheckinPrecision checkinPrecision;
  final bool isFirst;
  final CheckinMethod method;
  final String? notesPublic;
  final String? notesPrivate;

  /// Local-only association with a Vehicle; never sent to supercharging.life.
  final String? vehicleId;
  final int? geoDistanceAccuracy;
  final int? geoDistance;
  final DateTime importedAt;
  const Visit({
    required this.id,
    this.checkinId,
    required this.siteId,
    required this.checkinDate,
    required this.checkinTime,
    required this.checkinPrecision,
    required this.isFirst,
    required this.method,
    this.notesPublic,
    this.notesPrivate,
    this.vehicleId,
    this.geoDistanceAccuracy,
    this.geoDistance,
    required this.importedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || checkinId != null) {
      map['checkin_id'] = Variable<int>(checkinId);
    }
    map['site_id'] = Variable<int>(siteId);
    map['checkin_date'] = Variable<DateTime>(checkinDate);
    map['checkin_time'] = Variable<DateTime>(checkinTime);
    {
      map['checkin_precision'] = Variable<String>(
        $VisitsTable.$convertercheckinPrecision.toSql(checkinPrecision),
      );
    }
    map['is_first'] = Variable<bool>(isFirst);
    {
      map['method'] = Variable<String>(
        $VisitsTable.$convertermethod.toSql(method),
      );
    }
    if (!nullToAbsent || notesPublic != null) {
      map['notes_public'] = Variable<String>(notesPublic);
    }
    if (!nullToAbsent || notesPrivate != null) {
      map['notes_private'] = Variable<String>(notesPrivate);
    }
    if (!nullToAbsent || vehicleId != null) {
      map['vehicle_id'] = Variable<String>(vehicleId);
    }
    if (!nullToAbsent || geoDistanceAccuracy != null) {
      map['geo_distance_accuracy'] = Variable<int>(geoDistanceAccuracy);
    }
    if (!nullToAbsent || geoDistance != null) {
      map['geo_distance'] = Variable<int>(geoDistance);
    }
    map['imported_at'] = Variable<DateTime>(importedAt);
    return map;
  }

  VisitsCompanion toCompanion(bool nullToAbsent) {
    return VisitsCompanion(
      id: Value(id),
      checkinId: checkinId == null && nullToAbsent
          ? const Value.absent()
          : Value(checkinId),
      siteId: Value(siteId),
      checkinDate: Value(checkinDate),
      checkinTime: Value(checkinTime),
      checkinPrecision: Value(checkinPrecision),
      isFirst: Value(isFirst),
      method: Value(method),
      notesPublic: notesPublic == null && nullToAbsent
          ? const Value.absent()
          : Value(notesPublic),
      notesPrivate: notesPrivate == null && nullToAbsent
          ? const Value.absent()
          : Value(notesPrivate),
      vehicleId: vehicleId == null && nullToAbsent
          ? const Value.absent()
          : Value(vehicleId),
      geoDistanceAccuracy: geoDistanceAccuracy == null && nullToAbsent
          ? const Value.absent()
          : Value(geoDistanceAccuracy),
      geoDistance: geoDistance == null && nullToAbsent
          ? const Value.absent()
          : Value(geoDistance),
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
      checkinId: serializer.fromJson<int?>(json['checkinId']),
      siteId: serializer.fromJson<int>(json['siteId']),
      checkinDate: serializer.fromJson<DateTime>(json['checkinDate']),
      checkinTime: serializer.fromJson<DateTime>(json['checkinTime']),
      checkinPrecision: $VisitsTable.$convertercheckinPrecision.fromJson(
        serializer.fromJson<String>(json['checkinPrecision']),
      ),
      isFirst: serializer.fromJson<bool>(json['isFirst']),
      method: $VisitsTable.$convertermethod.fromJson(
        serializer.fromJson<String>(json['method']),
      ),
      notesPublic: serializer.fromJson<String?>(json['notesPublic']),
      notesPrivate: serializer.fromJson<String?>(json['notesPrivate']),
      vehicleId: serializer.fromJson<String?>(json['vehicleId']),
      geoDistanceAccuracy: serializer.fromJson<int?>(
        json['geoDistanceAccuracy'],
      ),
      geoDistance: serializer.fromJson<int?>(json['geoDistance']),
      importedAt: serializer.fromJson<DateTime>(json['importedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'checkinId': serializer.toJson<int?>(checkinId),
      'siteId': serializer.toJson<int>(siteId),
      'checkinDate': serializer.toJson<DateTime>(checkinDate),
      'checkinTime': serializer.toJson<DateTime>(checkinTime),
      'checkinPrecision': serializer.toJson<String>(
        $VisitsTable.$convertercheckinPrecision.toJson(checkinPrecision),
      ),
      'isFirst': serializer.toJson<bool>(isFirst),
      'method': serializer.toJson<String>(
        $VisitsTable.$convertermethod.toJson(method),
      ),
      'notesPublic': serializer.toJson<String?>(notesPublic),
      'notesPrivate': serializer.toJson<String?>(notesPrivate),
      'vehicleId': serializer.toJson<String?>(vehicleId),
      'geoDistanceAccuracy': serializer.toJson<int?>(geoDistanceAccuracy),
      'geoDistance': serializer.toJson<int?>(geoDistance),
      'importedAt': serializer.toJson<DateTime>(importedAt),
    };
  }

  Visit copyWith({
    int? id,
    Value<int?> checkinId = const Value.absent(),
    int? siteId,
    DateTime? checkinDate,
    DateTime? checkinTime,
    CheckinPrecision? checkinPrecision,
    bool? isFirst,
    CheckinMethod? method,
    Value<String?> notesPublic = const Value.absent(),
    Value<String?> notesPrivate = const Value.absent(),
    Value<String?> vehicleId = const Value.absent(),
    Value<int?> geoDistanceAccuracy = const Value.absent(),
    Value<int?> geoDistance = const Value.absent(),
    DateTime? importedAt,
  }) => Visit(
    id: id ?? this.id,
    checkinId: checkinId.present ? checkinId.value : this.checkinId,
    siteId: siteId ?? this.siteId,
    checkinDate: checkinDate ?? this.checkinDate,
    checkinTime: checkinTime ?? this.checkinTime,
    checkinPrecision: checkinPrecision ?? this.checkinPrecision,
    isFirst: isFirst ?? this.isFirst,
    method: method ?? this.method,
    notesPublic: notesPublic.present ? notesPublic.value : this.notesPublic,
    notesPrivate: notesPrivate.present ? notesPrivate.value : this.notesPrivate,
    vehicleId: vehicleId.present ? vehicleId.value : this.vehicleId,
    geoDistanceAccuracy: geoDistanceAccuracy.present
        ? geoDistanceAccuracy.value
        : this.geoDistanceAccuracy,
    geoDistance: geoDistance.present ? geoDistance.value : this.geoDistance,
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
      checkinPrecision: data.checkinPrecision.present
          ? data.checkinPrecision.value
          : this.checkinPrecision,
      isFirst: data.isFirst.present ? data.isFirst.value : this.isFirst,
      method: data.method.present ? data.method.value : this.method,
      notesPublic: data.notesPublic.present
          ? data.notesPublic.value
          : this.notesPublic,
      notesPrivate: data.notesPrivate.present
          ? data.notesPrivate.value
          : this.notesPrivate,
      vehicleId: data.vehicleId.present ? data.vehicleId.value : this.vehicleId,
      geoDistanceAccuracy: data.geoDistanceAccuracy.present
          ? data.geoDistanceAccuracy.value
          : this.geoDistanceAccuracy,
      geoDistance: data.geoDistance.present
          ? data.geoDistance.value
          : this.geoDistance,
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
          ..write('checkinPrecision: $checkinPrecision, ')
          ..write('isFirst: $isFirst, ')
          ..write('method: $method, ')
          ..write('notesPublic: $notesPublic, ')
          ..write('notesPrivate: $notesPrivate, ')
          ..write('vehicleId: $vehicleId, ')
          ..write('geoDistanceAccuracy: $geoDistanceAccuracy, ')
          ..write('geoDistance: $geoDistance, ')
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
    checkinPrecision,
    isFirst,
    method,
    notesPublic,
    notesPrivate,
    vehicleId,
    geoDistanceAccuracy,
    geoDistance,
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
          other.checkinPrecision == this.checkinPrecision &&
          other.isFirst == this.isFirst &&
          other.method == this.method &&
          other.notesPublic == this.notesPublic &&
          other.notesPrivate == this.notesPrivate &&
          other.vehicleId == this.vehicleId &&
          other.geoDistanceAccuracy == this.geoDistanceAccuracy &&
          other.geoDistance == this.geoDistance &&
          other.importedAt == this.importedAt);
}

class VisitsCompanion extends UpdateCompanion<Visit> {
  final Value<int> id;
  final Value<int?> checkinId;
  final Value<int> siteId;
  final Value<DateTime> checkinDate;
  final Value<DateTime> checkinTime;
  final Value<CheckinPrecision> checkinPrecision;
  final Value<bool> isFirst;
  final Value<CheckinMethod> method;
  final Value<String?> notesPublic;
  final Value<String?> notesPrivate;
  final Value<String?> vehicleId;
  final Value<int?> geoDistanceAccuracy;
  final Value<int?> geoDistance;
  final Value<DateTime> importedAt;
  const VisitsCompanion({
    this.id = const Value.absent(),
    this.checkinId = const Value.absent(),
    this.siteId = const Value.absent(),
    this.checkinDate = const Value.absent(),
    this.checkinTime = const Value.absent(),
    this.checkinPrecision = const Value.absent(),
    this.isFirst = const Value.absent(),
    this.method = const Value.absent(),
    this.notesPublic = const Value.absent(),
    this.notesPrivate = const Value.absent(),
    this.vehicleId = const Value.absent(),
    this.geoDistanceAccuracy = const Value.absent(),
    this.geoDistance = const Value.absent(),
    this.importedAt = const Value.absent(),
  });
  VisitsCompanion.insert({
    this.id = const Value.absent(),
    this.checkinId = const Value.absent(),
    required int siteId,
    required DateTime checkinDate,
    required DateTime checkinTime,
    this.checkinPrecision = const Value.absent(),
    this.isFirst = const Value.absent(),
    this.method = const Value.absent(),
    this.notesPublic = const Value.absent(),
    this.notesPrivate = const Value.absent(),
    this.vehicleId = const Value.absent(),
    this.geoDistanceAccuracy = const Value.absent(),
    this.geoDistance = const Value.absent(),
    required DateTime importedAt,
  }) : siteId = Value(siteId),
       checkinDate = Value(checkinDate),
       checkinTime = Value(checkinTime),
       importedAt = Value(importedAt);
  static Insertable<Visit> custom({
    Expression<int>? id,
    Expression<int>? checkinId,
    Expression<int>? siteId,
    Expression<DateTime>? checkinDate,
    Expression<DateTime>? checkinTime,
    Expression<String>? checkinPrecision,
    Expression<bool>? isFirst,
    Expression<String>? method,
    Expression<String>? notesPublic,
    Expression<String>? notesPrivate,
    Expression<String>? vehicleId,
    Expression<int>? geoDistanceAccuracy,
    Expression<int>? geoDistance,
    Expression<DateTime>? importedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (checkinId != null) 'checkin_id': checkinId,
      if (siteId != null) 'site_id': siteId,
      if (checkinDate != null) 'checkin_date': checkinDate,
      if (checkinTime != null) 'checkin_time': checkinTime,
      if (checkinPrecision != null) 'checkin_precision': checkinPrecision,
      if (isFirst != null) 'is_first': isFirst,
      if (method != null) 'method': method,
      if (notesPublic != null) 'notes_public': notesPublic,
      if (notesPrivate != null) 'notes_private': notesPrivate,
      if (vehicleId != null) 'vehicle_id': vehicleId,
      if (geoDistanceAccuracy != null)
        'geo_distance_accuracy': geoDistanceAccuracy,
      if (geoDistance != null) 'geo_distance': geoDistance,
      if (importedAt != null) 'imported_at': importedAt,
    });
  }

  VisitsCompanion copyWith({
    Value<int>? id,
    Value<int?>? checkinId,
    Value<int>? siteId,
    Value<DateTime>? checkinDate,
    Value<DateTime>? checkinTime,
    Value<CheckinPrecision>? checkinPrecision,
    Value<bool>? isFirst,
    Value<CheckinMethod>? method,
    Value<String?>? notesPublic,
    Value<String?>? notesPrivate,
    Value<String?>? vehicleId,
    Value<int?>? geoDistanceAccuracy,
    Value<int?>? geoDistance,
    Value<DateTime>? importedAt,
  }) {
    return VisitsCompanion(
      id: id ?? this.id,
      checkinId: checkinId ?? this.checkinId,
      siteId: siteId ?? this.siteId,
      checkinDate: checkinDate ?? this.checkinDate,
      checkinTime: checkinTime ?? this.checkinTime,
      checkinPrecision: checkinPrecision ?? this.checkinPrecision,
      isFirst: isFirst ?? this.isFirst,
      method: method ?? this.method,
      notesPublic: notesPublic ?? this.notesPublic,
      notesPrivate: notesPrivate ?? this.notesPrivate,
      vehicleId: vehicleId ?? this.vehicleId,
      geoDistanceAccuracy: geoDistanceAccuracy ?? this.geoDistanceAccuracy,
      geoDistance: geoDistance ?? this.geoDistance,
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
    if (checkinPrecision.present) {
      map['checkin_precision'] = Variable<String>(
        $VisitsTable.$convertercheckinPrecision.toSql(checkinPrecision.value),
      );
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
    if (notesPrivate.present) {
      map['notes_private'] = Variable<String>(notesPrivate.value);
    }
    if (vehicleId.present) {
      map['vehicle_id'] = Variable<String>(vehicleId.value);
    }
    if (geoDistanceAccuracy.present) {
      map['geo_distance_accuracy'] = Variable<int>(geoDistanceAccuracy.value);
    }
    if (geoDistance.present) {
      map['geo_distance'] = Variable<int>(geoDistance.value);
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
          ..write('checkinPrecision: $checkinPrecision, ')
          ..write('isFirst: $isFirst, ')
          ..write('method: $method, ')
          ..write('notesPublic: $notesPublic, ')
          ..write('notesPrivate: $notesPrivate, ')
          ..write('vehicleId: $vehicleId, ')
          ..write('geoDistanceAccuracy: $geoDistanceAccuracy, ')
          ..write('geoDistance: $geoDistance, ')
          ..write('importedAt: $importedAt')
          ..write(')'))
        .toString();
  }
}

class $OutboxEntriesTable extends OutboxEntries
    with TableInfo<$OutboxEntriesTable, OutboxEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OutboxEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _visitIdMeta = const VerificationMeta(
    'visitId',
  );
  @override
  late final GeneratedColumn<int> visitId = GeneratedColumn<int>(
    'visit_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<OutboxState, String> state =
      GeneratedColumn<String>(
        'state',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: Constant(OutboxState.waiting.name),
      ).withConverter<OutboxState>($OutboxEntriesTable.$converterstate);
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
    visitId,
    state,
    latitude,
    longitude,
    accuracy,
    attempts,
    lastAttemptAt,
    lastError,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'outbox_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<OutboxEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('visit_id')) {
      context.handle(
        _visitIdMeta,
        visitId.isAcceptableOrUnknown(data['visit_id']!, _visitIdMeta),
      );
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
  Set<GeneratedColumn> get $primaryKey => {visitId};
  @override
  OutboxEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OutboxEntry(
      visitId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}visit_id'],
      )!,
      state: $OutboxEntriesTable.$converterstate.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}state'],
        )!,
      ),
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
  $OutboxEntriesTable createAlias(String alias) {
    return $OutboxEntriesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<OutboxState, String, String> $converterstate =
      const EnumNameConverter<OutboxState>(OutboxState.values);
}

class OutboxEntry extends DataClass implements Insertable<OutboxEntry> {
  final int visitId;
  final OutboxState state;
  final double? latitude;
  final double? longitude;
  final double? accuracy;
  final int attempts;
  final DateTime? lastAttemptAt;
  final String? lastError;
  const OutboxEntry({
    required this.visitId,
    required this.state,
    this.latitude,
    this.longitude,
    this.accuracy,
    required this.attempts,
    this.lastAttemptAt,
    this.lastError,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['visit_id'] = Variable<int>(visitId);
    {
      map['state'] = Variable<String>(
        $OutboxEntriesTable.$converterstate.toSql(state),
      );
    }
    if (!nullToAbsent || latitude != null) {
      map['latitude'] = Variable<double>(latitude);
    }
    if (!nullToAbsent || longitude != null) {
      map['longitude'] = Variable<double>(longitude);
    }
    if (!nullToAbsent || accuracy != null) {
      map['accuracy'] = Variable<double>(accuracy);
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

  OutboxEntriesCompanion toCompanion(bool nullToAbsent) {
    return OutboxEntriesCompanion(
      visitId: Value(visitId),
      state: Value(state),
      latitude: latitude == null && nullToAbsent
          ? const Value.absent()
          : Value(latitude),
      longitude: longitude == null && nullToAbsent
          ? const Value.absent()
          : Value(longitude),
      accuracy: accuracy == null && nullToAbsent
          ? const Value.absent()
          : Value(accuracy),
      attempts: Value(attempts),
      lastAttemptAt: lastAttemptAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastAttemptAt),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
    );
  }

  factory OutboxEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OutboxEntry(
      visitId: serializer.fromJson<int>(json['visitId']),
      state: $OutboxEntriesTable.$converterstate.fromJson(
        serializer.fromJson<String>(json['state']),
      ),
      latitude: serializer.fromJson<double?>(json['latitude']),
      longitude: serializer.fromJson<double?>(json['longitude']),
      accuracy: serializer.fromJson<double?>(json['accuracy']),
      attempts: serializer.fromJson<int>(json['attempts']),
      lastAttemptAt: serializer.fromJson<DateTime?>(json['lastAttemptAt']),
      lastError: serializer.fromJson<String?>(json['lastError']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'visitId': serializer.toJson<int>(visitId),
      'state': serializer.toJson<String>(
        $OutboxEntriesTable.$converterstate.toJson(state),
      ),
      'latitude': serializer.toJson<double?>(latitude),
      'longitude': serializer.toJson<double?>(longitude),
      'accuracy': serializer.toJson<double?>(accuracy),
      'attempts': serializer.toJson<int>(attempts),
      'lastAttemptAt': serializer.toJson<DateTime?>(lastAttemptAt),
      'lastError': serializer.toJson<String?>(lastError),
    };
  }

  OutboxEntry copyWith({
    int? visitId,
    OutboxState? state,
    Value<double?> latitude = const Value.absent(),
    Value<double?> longitude = const Value.absent(),
    Value<double?> accuracy = const Value.absent(),
    int? attempts,
    Value<DateTime?> lastAttemptAt = const Value.absent(),
    Value<String?> lastError = const Value.absent(),
  }) => OutboxEntry(
    visitId: visitId ?? this.visitId,
    state: state ?? this.state,
    latitude: latitude.present ? latitude.value : this.latitude,
    longitude: longitude.present ? longitude.value : this.longitude,
    accuracy: accuracy.present ? accuracy.value : this.accuracy,
    attempts: attempts ?? this.attempts,
    lastAttemptAt: lastAttemptAt.present
        ? lastAttemptAt.value
        : this.lastAttemptAt,
    lastError: lastError.present ? lastError.value : this.lastError,
  );
  OutboxEntry copyWithCompanion(OutboxEntriesCompanion data) {
    return OutboxEntry(
      visitId: data.visitId.present ? data.visitId.value : this.visitId,
      state: data.state.present ? data.state.value : this.state,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      accuracy: data.accuracy.present ? data.accuracy.value : this.accuracy,
      attempts: data.attempts.present ? data.attempts.value : this.attempts,
      lastAttemptAt: data.lastAttemptAt.present
          ? data.lastAttemptAt.value
          : this.lastAttemptAt,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OutboxEntry(')
          ..write('visitId: $visitId, ')
          ..write('state: $state, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('accuracy: $accuracy, ')
          ..write('attempts: $attempts, ')
          ..write('lastAttemptAt: $lastAttemptAt, ')
          ..write('lastError: $lastError')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    visitId,
    state,
    latitude,
    longitude,
    accuracy,
    attempts,
    lastAttemptAt,
    lastError,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OutboxEntry &&
          other.visitId == this.visitId &&
          other.state == this.state &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.accuracy == this.accuracy &&
          other.attempts == this.attempts &&
          other.lastAttemptAt == this.lastAttemptAt &&
          other.lastError == this.lastError);
}

class OutboxEntriesCompanion extends UpdateCompanion<OutboxEntry> {
  final Value<int> visitId;
  final Value<OutboxState> state;
  final Value<double?> latitude;
  final Value<double?> longitude;
  final Value<double?> accuracy;
  final Value<int> attempts;
  final Value<DateTime?> lastAttemptAt;
  final Value<String?> lastError;
  const OutboxEntriesCompanion({
    this.visitId = const Value.absent(),
    this.state = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.accuracy = const Value.absent(),
    this.attempts = const Value.absent(),
    this.lastAttemptAt = const Value.absent(),
    this.lastError = const Value.absent(),
  });
  OutboxEntriesCompanion.insert({
    this.visitId = const Value.absent(),
    this.state = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.accuracy = const Value.absent(),
    this.attempts = const Value.absent(),
    this.lastAttemptAt = const Value.absent(),
    this.lastError = const Value.absent(),
  });
  static Insertable<OutboxEntry> custom({
    Expression<int>? visitId,
    Expression<String>? state,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<double>? accuracy,
    Expression<int>? attempts,
    Expression<DateTime>? lastAttemptAt,
    Expression<String>? lastError,
  }) {
    return RawValuesInsertable({
      if (visitId != null) 'visit_id': visitId,
      if (state != null) 'state': state,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (accuracy != null) 'accuracy': accuracy,
      if (attempts != null) 'attempts': attempts,
      if (lastAttemptAt != null) 'last_attempt_at': lastAttemptAt,
      if (lastError != null) 'last_error': lastError,
    });
  }

  OutboxEntriesCompanion copyWith({
    Value<int>? visitId,
    Value<OutboxState>? state,
    Value<double?>? latitude,
    Value<double?>? longitude,
    Value<double?>? accuracy,
    Value<int>? attempts,
    Value<DateTime?>? lastAttemptAt,
    Value<String?>? lastError,
  }) {
    return OutboxEntriesCompanion(
      visitId: visitId ?? this.visitId,
      state: state ?? this.state,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      accuracy: accuracy ?? this.accuracy,
      attempts: attempts ?? this.attempts,
      lastAttemptAt: lastAttemptAt ?? this.lastAttemptAt,
      lastError: lastError ?? this.lastError,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (visitId.present) {
      map['visit_id'] = Variable<int>(visitId.value);
    }
    if (state.present) {
      map['state'] = Variable<String>(
        $OutboxEntriesTable.$converterstate.toSql(state.value),
      );
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
    return (StringBuffer('OutboxEntriesCompanion(')
          ..write('visitId: $visitId, ')
          ..write('state: $state, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('accuracy: $accuracy, ')
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

  /// Same server-assigned supercharging.life check-in id as [Visits.checkinId].
  final int checkinId;
  final int siteId;
  final int odUserId;
  final String username;
  final String? displayName;
  final DateTime checkinDate;
  final DateTime checkinTime;
  final bool isFirstAtSupercharger;
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
  @override
  late final GeneratedColumnWithTypeConverter<AuthProvider?, String>
  authProvider =
      GeneratedColumn<String>(
        'auth_provider',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<AuthProvider?>(
        $UserSettingsTableTable.$converterauthProvidern,
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
  static const VerificationMeta _setupCompletedAtMeta = const VerificationMeta(
    'setupCompletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> setupCompletedAt =
      GeneratedColumn<DateTime>(
        'setup_completed_at',
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
  static const VerificationMeta _clusterMarkersMeta = const VerificationMeta(
    'clusterMarkers',
  );
  @override
  late final GeneratedColumn<bool> clusterMarkers = GeneratedColumn<bool>(
    'cluster_markers',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("cluster_markers" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
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
        defaultValue: Constant(UnitSystem.imperial.name),
      ).withConverter<UnitSystem>($UserSettingsTableTable.$converterunitSystem);
  @override
  late final GeneratedColumnWithTypeConverter<AppAppearance, String>
  appAppearance =
      GeneratedColumn<String>(
        'app_appearance',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: Constant(AppAppearance.system.name),
      ).withConverter<AppAppearance>(
        $UserSettingsTableTable.$converterappAppearance,
      );
  static const VerificationMeta _includeVisitedNearbyMeta =
      const VerificationMeta('includeVisitedNearby');
  @override
  late final GeneratedColumn<bool> includeVisitedNearby = GeneratedColumn<bool>(
    'include_visited_nearby',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("include_visited_nearby" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _includeVehicleInPrivateNoteMeta =
      const VerificationMeta('includeVehicleInPrivateNote');
  @override
  late final GeneratedColumn<bool> includeVehicleInPrivateNote =
      GeneratedColumn<bool>(
        'include_vehicle_in_private_note',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("include_vehicle_in_private_note" IN (0, 1))',
        ),
        defaultValue: const Constant(false),
      );
  static const VerificationMeta _notifyNewSitesMeta = const VerificationMeta(
    'notifyNewSites',
  );
  @override
  late final GeneratedColumn<bool> notifyNewSites = GeneratedColumn<bool>(
    'notify_new_sites',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("notify_new_sites" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _notifyFirstEligibleMeta =
      const VerificationMeta('notifyFirstEligible');
  @override
  late final GeneratedColumn<bool> notifyFirstEligible = GeneratedColumn<bool>(
    'notify_first_eligible',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("notify_first_eligible" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _nearestSiteLiveUpdateMeta =
      const VerificationMeta('nearestSiteLiveUpdate');
  @override
  late final GeneratedColumn<bool> nearestSiteLiveUpdate =
      GeneratedColumn<bool>(
        'nearest_site_live_update',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("nearest_site_live_update" IN (0, 1))',
        ),
        defaultValue: const Constant(false),
      );
  static const VerificationMeta _nearestSiteIncludeConstructionMeta =
      const VerificationMeta('nearestSiteIncludeConstruction');
  @override
  late final GeneratedColumn<bool> nearestSiteIncludeConstruction =
      GeneratedColumn<bool>(
        'nearest_site_include_construction',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("nearest_site_include_construction" IN (0, 1))',
        ),
        defaultValue: const Constant(false),
      );
  static const VerificationMeta _nearestSiteShowDirectionMeta =
      const VerificationMeta('nearestSiteShowDirection');
  @override
  late final GeneratedColumn<bool> nearestSiteShowDirection =
      GeneratedColumn<bool>(
        'nearest_site_show_direction',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("nearest_site_show_direction" IN (0, 1))',
        ),
        defaultValue: const Constant(true),
      );
  static const VerificationMeta _lastNotifiedChangeIdMeta =
      const VerificationMeta('lastNotifiedChangeId');
  @override
  late final GeneratedColumn<int> lastNotifiedChangeId = GeneratedColumn<int>(
    'last_notified_change_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
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
  static const VerificationMeta _mapLatitudeMeta = const VerificationMeta(
    'mapLatitude',
  );
  @override
  late final GeneratedColumn<double> mapLatitude = GeneratedColumn<double>(
    'map_latitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _mapLongitudeMeta = const VerificationMeta(
    'mapLongitude',
  );
  @override
  late final GeneratedColumn<double> mapLongitude = GeneratedColumn<double>(
    'map_longitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _mapZoomMeta = const VerificationMeta(
    'mapZoom',
  );
  @override
  late final GeneratedColumn<double> mapZoom = GeneratedColumn<double>(
    'map_zoom',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    odUserId,
    username,
    displayName,
    authProvider,
    firstLoginAt,
    lastLoginAt,
    setupCompletedAt,
    lastXlsxSyncAt,
    pollingInterval,
    notificationRadiusKm,
    mapFilter,
    showVisitedOnMap,
    clusterMarkers,
    checkinRadiusKm,
    unitSystem,
    appAppearance,
    includeVisitedNearby,
    includeVehicleInPrivateNote,
    notifyNewSites,
    notifyFirstEligible,
    nearestSiteLiveUpdate,
    nearestSiteIncludeConstruction,
    nearestSiteShowDirection,
    lastNotifiedChangeId,
    lastLatitude,
    lastLongitude,
    lastSitesSyncAt,
    lastCheckinHistorySyncAt,
    mapLatitude,
    mapLongitude,
    mapZoom,
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
    if (data.containsKey('setup_completed_at')) {
      context.handle(
        _setupCompletedAtMeta,
        setupCompletedAt.isAcceptableOrUnknown(
          data['setup_completed_at']!,
          _setupCompletedAtMeta,
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
    if (data.containsKey('cluster_markers')) {
      context.handle(
        _clusterMarkersMeta,
        clusterMarkers.isAcceptableOrUnknown(
          data['cluster_markers']!,
          _clusterMarkersMeta,
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
    if (data.containsKey('include_visited_nearby')) {
      context.handle(
        _includeVisitedNearbyMeta,
        includeVisitedNearby.isAcceptableOrUnknown(
          data['include_visited_nearby']!,
          _includeVisitedNearbyMeta,
        ),
      );
    }
    if (data.containsKey('include_vehicle_in_private_note')) {
      context.handle(
        _includeVehicleInPrivateNoteMeta,
        includeVehicleInPrivateNote.isAcceptableOrUnknown(
          data['include_vehicle_in_private_note']!,
          _includeVehicleInPrivateNoteMeta,
        ),
      );
    }
    if (data.containsKey('notify_new_sites')) {
      context.handle(
        _notifyNewSitesMeta,
        notifyNewSites.isAcceptableOrUnknown(
          data['notify_new_sites']!,
          _notifyNewSitesMeta,
        ),
      );
    }
    if (data.containsKey('notify_first_eligible')) {
      context.handle(
        _notifyFirstEligibleMeta,
        notifyFirstEligible.isAcceptableOrUnknown(
          data['notify_first_eligible']!,
          _notifyFirstEligibleMeta,
        ),
      );
    }
    if (data.containsKey('nearest_site_live_update')) {
      context.handle(
        _nearestSiteLiveUpdateMeta,
        nearestSiteLiveUpdate.isAcceptableOrUnknown(
          data['nearest_site_live_update']!,
          _nearestSiteLiveUpdateMeta,
        ),
      );
    }
    if (data.containsKey('nearest_site_include_construction')) {
      context.handle(
        _nearestSiteIncludeConstructionMeta,
        nearestSiteIncludeConstruction.isAcceptableOrUnknown(
          data['nearest_site_include_construction']!,
          _nearestSiteIncludeConstructionMeta,
        ),
      );
    }
    if (data.containsKey('nearest_site_show_direction')) {
      context.handle(
        _nearestSiteShowDirectionMeta,
        nearestSiteShowDirection.isAcceptableOrUnknown(
          data['nearest_site_show_direction']!,
          _nearestSiteShowDirectionMeta,
        ),
      );
    }
    if (data.containsKey('last_notified_change_id')) {
      context.handle(
        _lastNotifiedChangeIdMeta,
        lastNotifiedChangeId.isAcceptableOrUnknown(
          data['last_notified_change_id']!,
          _lastNotifiedChangeIdMeta,
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
    if (data.containsKey('map_latitude')) {
      context.handle(
        _mapLatitudeMeta,
        mapLatitude.isAcceptableOrUnknown(
          data['map_latitude']!,
          _mapLatitudeMeta,
        ),
      );
    }
    if (data.containsKey('map_longitude')) {
      context.handle(
        _mapLongitudeMeta,
        mapLongitude.isAcceptableOrUnknown(
          data['map_longitude']!,
          _mapLongitudeMeta,
        ),
      );
    }
    if (data.containsKey('map_zoom')) {
      context.handle(
        _mapZoomMeta,
        mapZoom.isAcceptableOrUnknown(data['map_zoom']!, _mapZoomMeta),
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
      authProvider: $UserSettingsTableTable.$converterauthProvidern.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}auth_provider'],
        ),
      ),
      firstLoginAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}first_login_at'],
      ),
      lastLoginAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_login_at'],
      ),
      setupCompletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}setup_completed_at'],
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
      clusterMarkers: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}cluster_markers'],
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
      appAppearance: $UserSettingsTableTable.$converterappAppearance.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}app_appearance'],
        )!,
      ),
      includeVisitedNearby: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}include_visited_nearby'],
      )!,
      includeVehicleInPrivateNote: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}include_vehicle_in_private_note'],
      )!,
      notifyNewSites: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}notify_new_sites'],
      )!,
      notifyFirstEligible: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}notify_first_eligible'],
      )!,
      nearestSiteLiveUpdate: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}nearest_site_live_update'],
      )!,
      nearestSiteIncludeConstruction: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}nearest_site_include_construction'],
      )!,
      nearestSiteShowDirection: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}nearest_site_show_direction'],
      )!,
      lastNotifiedChangeId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_notified_change_id'],
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
      mapLatitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}map_latitude'],
      ),
      mapLongitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}map_longitude'],
      ),
      mapZoom: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}map_zoom'],
      ),
    );
  }

  @override
  $UserSettingsTableTable createAlias(String alias) {
    return $UserSettingsTableTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<AuthProvider, String, String>
  $converterauthProvider = const EnumNameConverter<AuthProvider>(
    AuthProvider.values,
  );
  static JsonTypeConverter2<AuthProvider?, String?, String?>
  $converterauthProvidern = JsonTypeConverter2.asNullable(
    $converterauthProvider,
  );
  static JsonTypeConverter2<PollingInterval, String, String>
  $converterpollingInterval = const EnumNameConverter<PollingInterval>(
    PollingInterval.values,
  );
  static JsonTypeConverter2<MapFilter, String, String> $convertermapFilter =
      const EnumNameConverter<MapFilter>(MapFilter.values);
  static JsonTypeConverter2<UnitSystem, String, String> $converterunitSystem =
      const EnumNameConverter<UnitSystem>(UnitSystem.values);
  static JsonTypeConverter2<AppAppearance, String, String>
  $converterappAppearance = const EnumNameConverter<AppAppearance>(
    AppAppearance.values,
  );
}

class UserSettingsTableData extends DataClass
    implements Insertable<UserSettingsTableData> {
  final int id;
  final int? odUserId;
  final String? username;
  final String? displayName;

  /// GitHub or Google. Set for a live session and for a device-only use.
  final AuthProvider? authProvider;
  final DateTime? firstLoginAt;
  final DateTime? lastLoginAt;

  /// Set when the first-run setup screens finish. Null shows them again.
  final DateTime? setupCompletedAt;
  final DateTime? lastXlsxSyncAt;
  final PollingInterval pollingInterval;
  final double notificationRadiusKm;
  final MapFilter mapFilter;
  final bool showVisitedOnMap;
  final bool clusterMarkers;
  final double checkinRadiusKm;
  final UnitSystem unitSystem;
  final AppAppearance appAppearance;

  /// When false, the nearby check-in list hides sites the user has already
  /// visited. Turn on to show those sites with their last visit date.
  final bool includeVisitedNearby;

  /// When true, a check-in that names a vehicle appends year, make, model,
  /// and trim to the private note. The VIN is never included.
  final bool includeVehicleInPrivateNote;

  /// New-site and First-eligible alerts. Both default on.
  final bool notifyNewSites;
  final bool notifyFirstEligible;

  /// Android: an ongoing Live Update with the distance to the nearest
  /// unvisited site while the app runs. Construction sites are opt-in.
  final bool nearestSiteLiveUpdate;
  final bool nearestSiteIncludeConstruction;

  /// Which way the nearest site lies: an arrow while moving or with the phone
  /// flat, else compass letters. On, as it was before this setting existed.
  final bool nearestSiteShowDirection;

  /// Highest allChanges id already considered for a new-site alert.
  /// Null until the first poll, which records the cursor and does not alert.
  final int? lastNotifiedChangeId;
  final double? lastLatitude;
  final double? lastLongitude;
  final DateTime? lastSitesSyncAt;
  final DateTime? lastCheckinHistorySyncAt;

  /// Where the map was last left, so a cold start opens there while it waits
  /// for a location fix.
  final double? mapLatitude;
  final double? mapLongitude;
  final double? mapZoom;
  const UserSettingsTableData({
    required this.id,
    this.odUserId,
    this.username,
    this.displayName,
    this.authProvider,
    this.firstLoginAt,
    this.lastLoginAt,
    this.setupCompletedAt,
    this.lastXlsxSyncAt,
    required this.pollingInterval,
    required this.notificationRadiusKm,
    required this.mapFilter,
    required this.showVisitedOnMap,
    required this.clusterMarkers,
    required this.checkinRadiusKm,
    required this.unitSystem,
    required this.appAppearance,
    required this.includeVisitedNearby,
    required this.includeVehicleInPrivateNote,
    required this.notifyNewSites,
    required this.notifyFirstEligible,
    required this.nearestSiteLiveUpdate,
    required this.nearestSiteIncludeConstruction,
    required this.nearestSiteShowDirection,
    this.lastNotifiedChangeId,
    this.lastLatitude,
    this.lastLongitude,
    this.lastSitesSyncAt,
    this.lastCheckinHistorySyncAt,
    this.mapLatitude,
    this.mapLongitude,
    this.mapZoom,
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
    if (!nullToAbsent || authProvider != null) {
      map['auth_provider'] = Variable<String>(
        $UserSettingsTableTable.$converterauthProvidern.toSql(authProvider),
      );
    }
    if (!nullToAbsent || firstLoginAt != null) {
      map['first_login_at'] = Variable<DateTime>(firstLoginAt);
    }
    if (!nullToAbsent || lastLoginAt != null) {
      map['last_login_at'] = Variable<DateTime>(lastLoginAt);
    }
    if (!nullToAbsent || setupCompletedAt != null) {
      map['setup_completed_at'] = Variable<DateTime>(setupCompletedAt);
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
    map['cluster_markers'] = Variable<bool>(clusterMarkers);
    map['checkin_radius_km'] = Variable<double>(checkinRadiusKm);
    {
      map['unit_system'] = Variable<String>(
        $UserSettingsTableTable.$converterunitSystem.toSql(unitSystem),
      );
    }
    {
      map['app_appearance'] = Variable<String>(
        $UserSettingsTableTable.$converterappAppearance.toSql(appAppearance),
      );
    }
    map['include_visited_nearby'] = Variable<bool>(includeVisitedNearby);
    map['include_vehicle_in_private_note'] = Variable<bool>(
      includeVehicleInPrivateNote,
    );
    map['notify_new_sites'] = Variable<bool>(notifyNewSites);
    map['notify_first_eligible'] = Variable<bool>(notifyFirstEligible);
    map['nearest_site_live_update'] = Variable<bool>(nearestSiteLiveUpdate);
    map['nearest_site_include_construction'] = Variable<bool>(
      nearestSiteIncludeConstruction,
    );
    map['nearest_site_show_direction'] = Variable<bool>(
      nearestSiteShowDirection,
    );
    if (!nullToAbsent || lastNotifiedChangeId != null) {
      map['last_notified_change_id'] = Variable<int>(lastNotifiedChangeId);
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
    if (!nullToAbsent || mapLatitude != null) {
      map['map_latitude'] = Variable<double>(mapLatitude);
    }
    if (!nullToAbsent || mapLongitude != null) {
      map['map_longitude'] = Variable<double>(mapLongitude);
    }
    if (!nullToAbsent || mapZoom != null) {
      map['map_zoom'] = Variable<double>(mapZoom);
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
      authProvider: authProvider == null && nullToAbsent
          ? const Value.absent()
          : Value(authProvider),
      firstLoginAt: firstLoginAt == null && nullToAbsent
          ? const Value.absent()
          : Value(firstLoginAt),
      lastLoginAt: lastLoginAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastLoginAt),
      setupCompletedAt: setupCompletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(setupCompletedAt),
      lastXlsxSyncAt: lastXlsxSyncAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastXlsxSyncAt),
      pollingInterval: Value(pollingInterval),
      notificationRadiusKm: Value(notificationRadiusKm),
      mapFilter: Value(mapFilter),
      showVisitedOnMap: Value(showVisitedOnMap),
      clusterMarkers: Value(clusterMarkers),
      checkinRadiusKm: Value(checkinRadiusKm),
      unitSystem: Value(unitSystem),
      appAppearance: Value(appAppearance),
      includeVisitedNearby: Value(includeVisitedNearby),
      includeVehicleInPrivateNote: Value(includeVehicleInPrivateNote),
      notifyNewSites: Value(notifyNewSites),
      notifyFirstEligible: Value(notifyFirstEligible),
      nearestSiteLiveUpdate: Value(nearestSiteLiveUpdate),
      nearestSiteIncludeConstruction: Value(nearestSiteIncludeConstruction),
      nearestSiteShowDirection: Value(nearestSiteShowDirection),
      lastNotifiedChangeId: lastNotifiedChangeId == null && nullToAbsent
          ? const Value.absent()
          : Value(lastNotifiedChangeId),
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
      mapLatitude: mapLatitude == null && nullToAbsent
          ? const Value.absent()
          : Value(mapLatitude),
      mapLongitude: mapLongitude == null && nullToAbsent
          ? const Value.absent()
          : Value(mapLongitude),
      mapZoom: mapZoom == null && nullToAbsent
          ? const Value.absent()
          : Value(mapZoom),
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
      authProvider: $UserSettingsTableTable.$converterauthProvidern.fromJson(
        serializer.fromJson<String?>(json['authProvider']),
      ),
      firstLoginAt: serializer.fromJson<DateTime?>(json['firstLoginAt']),
      lastLoginAt: serializer.fromJson<DateTime?>(json['lastLoginAt']),
      setupCompletedAt: serializer.fromJson<DateTime?>(
        json['setupCompletedAt'],
      ),
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
      clusterMarkers: serializer.fromJson<bool>(json['clusterMarkers']),
      checkinRadiusKm: serializer.fromJson<double>(json['checkinRadiusKm']),
      unitSystem: $UserSettingsTableTable.$converterunitSystem.fromJson(
        serializer.fromJson<String>(json['unitSystem']),
      ),
      appAppearance: $UserSettingsTableTable.$converterappAppearance.fromJson(
        serializer.fromJson<String>(json['appAppearance']),
      ),
      includeVisitedNearby: serializer.fromJson<bool>(
        json['includeVisitedNearby'],
      ),
      includeVehicleInPrivateNote: serializer.fromJson<bool>(
        json['includeVehicleInPrivateNote'],
      ),
      notifyNewSites: serializer.fromJson<bool>(json['notifyNewSites']),
      notifyFirstEligible: serializer.fromJson<bool>(
        json['notifyFirstEligible'],
      ),
      nearestSiteLiveUpdate: serializer.fromJson<bool>(
        json['nearestSiteLiveUpdate'],
      ),
      nearestSiteIncludeConstruction: serializer.fromJson<bool>(
        json['nearestSiteIncludeConstruction'],
      ),
      nearestSiteShowDirection: serializer.fromJson<bool>(
        json['nearestSiteShowDirection'],
      ),
      lastNotifiedChangeId: serializer.fromJson<int?>(
        json['lastNotifiedChangeId'],
      ),
      lastLatitude: serializer.fromJson<double?>(json['lastLatitude']),
      lastLongitude: serializer.fromJson<double?>(json['lastLongitude']),
      lastSitesSyncAt: serializer.fromJson<DateTime?>(json['lastSitesSyncAt']),
      lastCheckinHistorySyncAt: serializer.fromJson<DateTime?>(
        json['lastCheckinHistorySyncAt'],
      ),
      mapLatitude: serializer.fromJson<double?>(json['mapLatitude']),
      mapLongitude: serializer.fromJson<double?>(json['mapLongitude']),
      mapZoom: serializer.fromJson<double?>(json['mapZoom']),
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
      'authProvider': serializer.toJson<String?>(
        $UserSettingsTableTable.$converterauthProvidern.toJson(authProvider),
      ),
      'firstLoginAt': serializer.toJson<DateTime?>(firstLoginAt),
      'lastLoginAt': serializer.toJson<DateTime?>(lastLoginAt),
      'setupCompletedAt': serializer.toJson<DateTime?>(setupCompletedAt),
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
      'clusterMarkers': serializer.toJson<bool>(clusterMarkers),
      'checkinRadiusKm': serializer.toJson<double>(checkinRadiusKm),
      'unitSystem': serializer.toJson<String>(
        $UserSettingsTableTable.$converterunitSystem.toJson(unitSystem),
      ),
      'appAppearance': serializer.toJson<String>(
        $UserSettingsTableTable.$converterappAppearance.toJson(appAppearance),
      ),
      'includeVisitedNearby': serializer.toJson<bool>(includeVisitedNearby),
      'includeVehicleInPrivateNote': serializer.toJson<bool>(
        includeVehicleInPrivateNote,
      ),
      'notifyNewSites': serializer.toJson<bool>(notifyNewSites),
      'notifyFirstEligible': serializer.toJson<bool>(notifyFirstEligible),
      'nearestSiteLiveUpdate': serializer.toJson<bool>(nearestSiteLiveUpdate),
      'nearestSiteIncludeConstruction': serializer.toJson<bool>(
        nearestSiteIncludeConstruction,
      ),
      'nearestSiteShowDirection': serializer.toJson<bool>(
        nearestSiteShowDirection,
      ),
      'lastNotifiedChangeId': serializer.toJson<int?>(lastNotifiedChangeId),
      'lastLatitude': serializer.toJson<double?>(lastLatitude),
      'lastLongitude': serializer.toJson<double?>(lastLongitude),
      'lastSitesSyncAt': serializer.toJson<DateTime?>(lastSitesSyncAt),
      'lastCheckinHistorySyncAt': serializer.toJson<DateTime?>(
        lastCheckinHistorySyncAt,
      ),
      'mapLatitude': serializer.toJson<double?>(mapLatitude),
      'mapLongitude': serializer.toJson<double?>(mapLongitude),
      'mapZoom': serializer.toJson<double?>(mapZoom),
    };
  }

  UserSettingsTableData copyWith({
    int? id,
    Value<int?> odUserId = const Value.absent(),
    Value<String?> username = const Value.absent(),
    Value<String?> displayName = const Value.absent(),
    Value<AuthProvider?> authProvider = const Value.absent(),
    Value<DateTime?> firstLoginAt = const Value.absent(),
    Value<DateTime?> lastLoginAt = const Value.absent(),
    Value<DateTime?> setupCompletedAt = const Value.absent(),
    Value<DateTime?> lastXlsxSyncAt = const Value.absent(),
    PollingInterval? pollingInterval,
    double? notificationRadiusKm,
    MapFilter? mapFilter,
    bool? showVisitedOnMap,
    bool? clusterMarkers,
    double? checkinRadiusKm,
    UnitSystem? unitSystem,
    AppAppearance? appAppearance,
    bool? includeVisitedNearby,
    bool? includeVehicleInPrivateNote,
    bool? notifyNewSites,
    bool? notifyFirstEligible,
    bool? nearestSiteLiveUpdate,
    bool? nearestSiteIncludeConstruction,
    bool? nearestSiteShowDirection,
    Value<int?> lastNotifiedChangeId = const Value.absent(),
    Value<double?> lastLatitude = const Value.absent(),
    Value<double?> lastLongitude = const Value.absent(),
    Value<DateTime?> lastSitesSyncAt = const Value.absent(),
    Value<DateTime?> lastCheckinHistorySyncAt = const Value.absent(),
    Value<double?> mapLatitude = const Value.absent(),
    Value<double?> mapLongitude = const Value.absent(),
    Value<double?> mapZoom = const Value.absent(),
  }) => UserSettingsTableData(
    id: id ?? this.id,
    odUserId: odUserId.present ? odUserId.value : this.odUserId,
    username: username.present ? username.value : this.username,
    displayName: displayName.present ? displayName.value : this.displayName,
    authProvider: authProvider.present ? authProvider.value : this.authProvider,
    firstLoginAt: firstLoginAt.present ? firstLoginAt.value : this.firstLoginAt,
    lastLoginAt: lastLoginAt.present ? lastLoginAt.value : this.lastLoginAt,
    setupCompletedAt: setupCompletedAt.present
        ? setupCompletedAt.value
        : this.setupCompletedAt,
    lastXlsxSyncAt: lastXlsxSyncAt.present
        ? lastXlsxSyncAt.value
        : this.lastXlsxSyncAt,
    pollingInterval: pollingInterval ?? this.pollingInterval,
    notificationRadiusKm: notificationRadiusKm ?? this.notificationRadiusKm,
    mapFilter: mapFilter ?? this.mapFilter,
    showVisitedOnMap: showVisitedOnMap ?? this.showVisitedOnMap,
    clusterMarkers: clusterMarkers ?? this.clusterMarkers,
    checkinRadiusKm: checkinRadiusKm ?? this.checkinRadiusKm,
    unitSystem: unitSystem ?? this.unitSystem,
    appAppearance: appAppearance ?? this.appAppearance,
    includeVisitedNearby: includeVisitedNearby ?? this.includeVisitedNearby,
    includeVehicleInPrivateNote:
        includeVehicleInPrivateNote ?? this.includeVehicleInPrivateNote,
    notifyNewSites: notifyNewSites ?? this.notifyNewSites,
    notifyFirstEligible: notifyFirstEligible ?? this.notifyFirstEligible,
    nearestSiteLiveUpdate: nearestSiteLiveUpdate ?? this.nearestSiteLiveUpdate,
    nearestSiteIncludeConstruction:
        nearestSiteIncludeConstruction ?? this.nearestSiteIncludeConstruction,
    nearestSiteShowDirection:
        nearestSiteShowDirection ?? this.nearestSiteShowDirection,
    lastNotifiedChangeId: lastNotifiedChangeId.present
        ? lastNotifiedChangeId.value
        : this.lastNotifiedChangeId,
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
    mapLatitude: mapLatitude.present ? mapLatitude.value : this.mapLatitude,
    mapLongitude: mapLongitude.present ? mapLongitude.value : this.mapLongitude,
    mapZoom: mapZoom.present ? mapZoom.value : this.mapZoom,
  );
  UserSettingsTableData copyWithCompanion(UserSettingsTableCompanion data) {
    return UserSettingsTableData(
      id: data.id.present ? data.id.value : this.id,
      odUserId: data.odUserId.present ? data.odUserId.value : this.odUserId,
      username: data.username.present ? data.username.value : this.username,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      authProvider: data.authProvider.present
          ? data.authProvider.value
          : this.authProvider,
      firstLoginAt: data.firstLoginAt.present
          ? data.firstLoginAt.value
          : this.firstLoginAt,
      lastLoginAt: data.lastLoginAt.present
          ? data.lastLoginAt.value
          : this.lastLoginAt,
      setupCompletedAt: data.setupCompletedAt.present
          ? data.setupCompletedAt.value
          : this.setupCompletedAt,
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
      clusterMarkers: data.clusterMarkers.present
          ? data.clusterMarkers.value
          : this.clusterMarkers,
      checkinRadiusKm: data.checkinRadiusKm.present
          ? data.checkinRadiusKm.value
          : this.checkinRadiusKm,
      unitSystem: data.unitSystem.present
          ? data.unitSystem.value
          : this.unitSystem,
      appAppearance: data.appAppearance.present
          ? data.appAppearance.value
          : this.appAppearance,
      includeVisitedNearby: data.includeVisitedNearby.present
          ? data.includeVisitedNearby.value
          : this.includeVisitedNearby,
      includeVehicleInPrivateNote: data.includeVehicleInPrivateNote.present
          ? data.includeVehicleInPrivateNote.value
          : this.includeVehicleInPrivateNote,
      notifyNewSites: data.notifyNewSites.present
          ? data.notifyNewSites.value
          : this.notifyNewSites,
      notifyFirstEligible: data.notifyFirstEligible.present
          ? data.notifyFirstEligible.value
          : this.notifyFirstEligible,
      nearestSiteLiveUpdate: data.nearestSiteLiveUpdate.present
          ? data.nearestSiteLiveUpdate.value
          : this.nearestSiteLiveUpdate,
      nearestSiteIncludeConstruction:
          data.nearestSiteIncludeConstruction.present
          ? data.nearestSiteIncludeConstruction.value
          : this.nearestSiteIncludeConstruction,
      nearestSiteShowDirection: data.nearestSiteShowDirection.present
          ? data.nearestSiteShowDirection.value
          : this.nearestSiteShowDirection,
      lastNotifiedChangeId: data.lastNotifiedChangeId.present
          ? data.lastNotifiedChangeId.value
          : this.lastNotifiedChangeId,
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
      mapLatitude: data.mapLatitude.present
          ? data.mapLatitude.value
          : this.mapLatitude,
      mapLongitude: data.mapLongitude.present
          ? data.mapLongitude.value
          : this.mapLongitude,
      mapZoom: data.mapZoom.present ? data.mapZoom.value : this.mapZoom,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserSettingsTableData(')
          ..write('id: $id, ')
          ..write('odUserId: $odUserId, ')
          ..write('username: $username, ')
          ..write('displayName: $displayName, ')
          ..write('authProvider: $authProvider, ')
          ..write('firstLoginAt: $firstLoginAt, ')
          ..write('lastLoginAt: $lastLoginAt, ')
          ..write('setupCompletedAt: $setupCompletedAt, ')
          ..write('lastXlsxSyncAt: $lastXlsxSyncAt, ')
          ..write('pollingInterval: $pollingInterval, ')
          ..write('notificationRadiusKm: $notificationRadiusKm, ')
          ..write('mapFilter: $mapFilter, ')
          ..write('showVisitedOnMap: $showVisitedOnMap, ')
          ..write('clusterMarkers: $clusterMarkers, ')
          ..write('checkinRadiusKm: $checkinRadiusKm, ')
          ..write('unitSystem: $unitSystem, ')
          ..write('appAppearance: $appAppearance, ')
          ..write('includeVisitedNearby: $includeVisitedNearby, ')
          ..write('includeVehicleInPrivateNote: $includeVehicleInPrivateNote, ')
          ..write('notifyNewSites: $notifyNewSites, ')
          ..write('notifyFirstEligible: $notifyFirstEligible, ')
          ..write('nearestSiteLiveUpdate: $nearestSiteLiveUpdate, ')
          ..write(
            'nearestSiteIncludeConstruction: $nearestSiteIncludeConstruction, ',
          )
          ..write('nearestSiteShowDirection: $nearestSiteShowDirection, ')
          ..write('lastNotifiedChangeId: $lastNotifiedChangeId, ')
          ..write('lastLatitude: $lastLatitude, ')
          ..write('lastLongitude: $lastLongitude, ')
          ..write('lastSitesSyncAt: $lastSitesSyncAt, ')
          ..write('lastCheckinHistorySyncAt: $lastCheckinHistorySyncAt, ')
          ..write('mapLatitude: $mapLatitude, ')
          ..write('mapLongitude: $mapLongitude, ')
          ..write('mapZoom: $mapZoom')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    odUserId,
    username,
    displayName,
    authProvider,
    firstLoginAt,
    lastLoginAt,
    setupCompletedAt,
    lastXlsxSyncAt,
    pollingInterval,
    notificationRadiusKm,
    mapFilter,
    showVisitedOnMap,
    clusterMarkers,
    checkinRadiusKm,
    unitSystem,
    appAppearance,
    includeVisitedNearby,
    includeVehicleInPrivateNote,
    notifyNewSites,
    notifyFirstEligible,
    nearestSiteLiveUpdate,
    nearestSiteIncludeConstruction,
    nearestSiteShowDirection,
    lastNotifiedChangeId,
    lastLatitude,
    lastLongitude,
    lastSitesSyncAt,
    lastCheckinHistorySyncAt,
    mapLatitude,
    mapLongitude,
    mapZoom,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserSettingsTableData &&
          other.id == this.id &&
          other.odUserId == this.odUserId &&
          other.username == this.username &&
          other.displayName == this.displayName &&
          other.authProvider == this.authProvider &&
          other.firstLoginAt == this.firstLoginAt &&
          other.lastLoginAt == this.lastLoginAt &&
          other.setupCompletedAt == this.setupCompletedAt &&
          other.lastXlsxSyncAt == this.lastXlsxSyncAt &&
          other.pollingInterval == this.pollingInterval &&
          other.notificationRadiusKm == this.notificationRadiusKm &&
          other.mapFilter == this.mapFilter &&
          other.showVisitedOnMap == this.showVisitedOnMap &&
          other.clusterMarkers == this.clusterMarkers &&
          other.checkinRadiusKm == this.checkinRadiusKm &&
          other.unitSystem == this.unitSystem &&
          other.appAppearance == this.appAppearance &&
          other.includeVisitedNearby == this.includeVisitedNearby &&
          other.includeVehicleInPrivateNote ==
              this.includeVehicleInPrivateNote &&
          other.notifyNewSites == this.notifyNewSites &&
          other.notifyFirstEligible == this.notifyFirstEligible &&
          other.nearestSiteLiveUpdate == this.nearestSiteLiveUpdate &&
          other.nearestSiteIncludeConstruction ==
              this.nearestSiteIncludeConstruction &&
          other.nearestSiteShowDirection == this.nearestSiteShowDirection &&
          other.lastNotifiedChangeId == this.lastNotifiedChangeId &&
          other.lastLatitude == this.lastLatitude &&
          other.lastLongitude == this.lastLongitude &&
          other.lastSitesSyncAt == this.lastSitesSyncAt &&
          other.lastCheckinHistorySyncAt == this.lastCheckinHistorySyncAt &&
          other.mapLatitude == this.mapLatitude &&
          other.mapLongitude == this.mapLongitude &&
          other.mapZoom == this.mapZoom);
}

class UserSettingsTableCompanion
    extends UpdateCompanion<UserSettingsTableData> {
  final Value<int> id;
  final Value<int?> odUserId;
  final Value<String?> username;
  final Value<String?> displayName;
  final Value<AuthProvider?> authProvider;
  final Value<DateTime?> firstLoginAt;
  final Value<DateTime?> lastLoginAt;
  final Value<DateTime?> setupCompletedAt;
  final Value<DateTime?> lastXlsxSyncAt;
  final Value<PollingInterval> pollingInterval;
  final Value<double> notificationRadiusKm;
  final Value<MapFilter> mapFilter;
  final Value<bool> showVisitedOnMap;
  final Value<bool> clusterMarkers;
  final Value<double> checkinRadiusKm;
  final Value<UnitSystem> unitSystem;
  final Value<AppAppearance> appAppearance;
  final Value<bool> includeVisitedNearby;
  final Value<bool> includeVehicleInPrivateNote;
  final Value<bool> notifyNewSites;
  final Value<bool> notifyFirstEligible;
  final Value<bool> nearestSiteLiveUpdate;
  final Value<bool> nearestSiteIncludeConstruction;
  final Value<bool> nearestSiteShowDirection;
  final Value<int?> lastNotifiedChangeId;
  final Value<double?> lastLatitude;
  final Value<double?> lastLongitude;
  final Value<DateTime?> lastSitesSyncAt;
  final Value<DateTime?> lastCheckinHistorySyncAt;
  final Value<double?> mapLatitude;
  final Value<double?> mapLongitude;
  final Value<double?> mapZoom;
  const UserSettingsTableCompanion({
    this.id = const Value.absent(),
    this.odUserId = const Value.absent(),
    this.username = const Value.absent(),
    this.displayName = const Value.absent(),
    this.authProvider = const Value.absent(),
    this.firstLoginAt = const Value.absent(),
    this.lastLoginAt = const Value.absent(),
    this.setupCompletedAt = const Value.absent(),
    this.lastXlsxSyncAt = const Value.absent(),
    this.pollingInterval = const Value.absent(),
    this.notificationRadiusKm = const Value.absent(),
    this.mapFilter = const Value.absent(),
    this.showVisitedOnMap = const Value.absent(),
    this.clusterMarkers = const Value.absent(),
    this.checkinRadiusKm = const Value.absent(),
    this.unitSystem = const Value.absent(),
    this.appAppearance = const Value.absent(),
    this.includeVisitedNearby = const Value.absent(),
    this.includeVehicleInPrivateNote = const Value.absent(),
    this.notifyNewSites = const Value.absent(),
    this.notifyFirstEligible = const Value.absent(),
    this.nearestSiteLiveUpdate = const Value.absent(),
    this.nearestSiteIncludeConstruction = const Value.absent(),
    this.nearestSiteShowDirection = const Value.absent(),
    this.lastNotifiedChangeId = const Value.absent(),
    this.lastLatitude = const Value.absent(),
    this.lastLongitude = const Value.absent(),
    this.lastSitesSyncAt = const Value.absent(),
    this.lastCheckinHistorySyncAt = const Value.absent(),
    this.mapLatitude = const Value.absent(),
    this.mapLongitude = const Value.absent(),
    this.mapZoom = const Value.absent(),
  });
  UserSettingsTableCompanion.insert({
    this.id = const Value.absent(),
    this.odUserId = const Value.absent(),
    this.username = const Value.absent(),
    this.displayName = const Value.absent(),
    this.authProvider = const Value.absent(),
    this.firstLoginAt = const Value.absent(),
    this.lastLoginAt = const Value.absent(),
    this.setupCompletedAt = const Value.absent(),
    this.lastXlsxSyncAt = const Value.absent(),
    this.pollingInterval = const Value.absent(),
    this.notificationRadiusKm = const Value.absent(),
    this.mapFilter = const Value.absent(),
    this.showVisitedOnMap = const Value.absent(),
    this.clusterMarkers = const Value.absent(),
    this.checkinRadiusKm = const Value.absent(),
    this.unitSystem = const Value.absent(),
    this.appAppearance = const Value.absent(),
    this.includeVisitedNearby = const Value.absent(),
    this.includeVehicleInPrivateNote = const Value.absent(),
    this.notifyNewSites = const Value.absent(),
    this.notifyFirstEligible = const Value.absent(),
    this.nearestSiteLiveUpdate = const Value.absent(),
    this.nearestSiteIncludeConstruction = const Value.absent(),
    this.nearestSiteShowDirection = const Value.absent(),
    this.lastNotifiedChangeId = const Value.absent(),
    this.lastLatitude = const Value.absent(),
    this.lastLongitude = const Value.absent(),
    this.lastSitesSyncAt = const Value.absent(),
    this.lastCheckinHistorySyncAt = const Value.absent(),
    this.mapLatitude = const Value.absent(),
    this.mapLongitude = const Value.absent(),
    this.mapZoom = const Value.absent(),
  });
  static Insertable<UserSettingsTableData> custom({
    Expression<int>? id,
    Expression<int>? odUserId,
    Expression<String>? username,
    Expression<String>? displayName,
    Expression<String>? authProvider,
    Expression<DateTime>? firstLoginAt,
    Expression<DateTime>? lastLoginAt,
    Expression<DateTime>? setupCompletedAt,
    Expression<DateTime>? lastXlsxSyncAt,
    Expression<String>? pollingInterval,
    Expression<double>? notificationRadiusKm,
    Expression<String>? mapFilter,
    Expression<bool>? showVisitedOnMap,
    Expression<bool>? clusterMarkers,
    Expression<double>? checkinRadiusKm,
    Expression<String>? unitSystem,
    Expression<String>? appAppearance,
    Expression<bool>? includeVisitedNearby,
    Expression<bool>? includeVehicleInPrivateNote,
    Expression<bool>? notifyNewSites,
    Expression<bool>? notifyFirstEligible,
    Expression<bool>? nearestSiteLiveUpdate,
    Expression<bool>? nearestSiteIncludeConstruction,
    Expression<bool>? nearestSiteShowDirection,
    Expression<int>? lastNotifiedChangeId,
    Expression<double>? lastLatitude,
    Expression<double>? lastLongitude,
    Expression<DateTime>? lastSitesSyncAt,
    Expression<DateTime>? lastCheckinHistorySyncAt,
    Expression<double>? mapLatitude,
    Expression<double>? mapLongitude,
    Expression<double>? mapZoom,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (odUserId != null) 'od_user_id': odUserId,
      if (username != null) 'username': username,
      if (displayName != null) 'display_name': displayName,
      if (authProvider != null) 'auth_provider': authProvider,
      if (firstLoginAt != null) 'first_login_at': firstLoginAt,
      if (lastLoginAt != null) 'last_login_at': lastLoginAt,
      if (setupCompletedAt != null) 'setup_completed_at': setupCompletedAt,
      if (lastXlsxSyncAt != null) 'last_xlsx_sync_at': lastXlsxSyncAt,
      if (pollingInterval != null) 'polling_interval': pollingInterval,
      if (notificationRadiusKm != null)
        'notification_radius_km': notificationRadiusKm,
      if (mapFilter != null) 'map_filter': mapFilter,
      if (showVisitedOnMap != null) 'show_visited_on_map': showVisitedOnMap,
      if (clusterMarkers != null) 'cluster_markers': clusterMarkers,
      if (checkinRadiusKm != null) 'checkin_radius_km': checkinRadiusKm,
      if (unitSystem != null) 'unit_system': unitSystem,
      if (appAppearance != null) 'app_appearance': appAppearance,
      if (includeVisitedNearby != null)
        'include_visited_nearby': includeVisitedNearby,
      if (includeVehicleInPrivateNote != null)
        'include_vehicle_in_private_note': includeVehicleInPrivateNote,
      if (notifyNewSites != null) 'notify_new_sites': notifyNewSites,
      if (notifyFirstEligible != null)
        'notify_first_eligible': notifyFirstEligible,
      if (nearestSiteLiveUpdate != null)
        'nearest_site_live_update': nearestSiteLiveUpdate,
      if (nearestSiteIncludeConstruction != null)
        'nearest_site_include_construction': nearestSiteIncludeConstruction,
      if (nearestSiteShowDirection != null)
        'nearest_site_show_direction': nearestSiteShowDirection,
      if (lastNotifiedChangeId != null)
        'last_notified_change_id': lastNotifiedChangeId,
      if (lastLatitude != null) 'last_latitude': lastLatitude,
      if (lastLongitude != null) 'last_longitude': lastLongitude,
      if (lastSitesSyncAt != null) 'last_sites_sync_at': lastSitesSyncAt,
      if (lastCheckinHistorySyncAt != null)
        'last_checkin_history_sync_at': lastCheckinHistorySyncAt,
      if (mapLatitude != null) 'map_latitude': mapLatitude,
      if (mapLongitude != null) 'map_longitude': mapLongitude,
      if (mapZoom != null) 'map_zoom': mapZoom,
    });
  }

  UserSettingsTableCompanion copyWith({
    Value<int>? id,
    Value<int?>? odUserId,
    Value<String?>? username,
    Value<String?>? displayName,
    Value<AuthProvider?>? authProvider,
    Value<DateTime?>? firstLoginAt,
    Value<DateTime?>? lastLoginAt,
    Value<DateTime?>? setupCompletedAt,
    Value<DateTime?>? lastXlsxSyncAt,
    Value<PollingInterval>? pollingInterval,
    Value<double>? notificationRadiusKm,
    Value<MapFilter>? mapFilter,
    Value<bool>? showVisitedOnMap,
    Value<bool>? clusterMarkers,
    Value<double>? checkinRadiusKm,
    Value<UnitSystem>? unitSystem,
    Value<AppAppearance>? appAppearance,
    Value<bool>? includeVisitedNearby,
    Value<bool>? includeVehicleInPrivateNote,
    Value<bool>? notifyNewSites,
    Value<bool>? notifyFirstEligible,
    Value<bool>? nearestSiteLiveUpdate,
    Value<bool>? nearestSiteIncludeConstruction,
    Value<bool>? nearestSiteShowDirection,
    Value<int?>? lastNotifiedChangeId,
    Value<double?>? lastLatitude,
    Value<double?>? lastLongitude,
    Value<DateTime?>? lastSitesSyncAt,
    Value<DateTime?>? lastCheckinHistorySyncAt,
    Value<double?>? mapLatitude,
    Value<double?>? mapLongitude,
    Value<double?>? mapZoom,
  }) {
    return UserSettingsTableCompanion(
      id: id ?? this.id,
      odUserId: odUserId ?? this.odUserId,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      authProvider: authProvider ?? this.authProvider,
      firstLoginAt: firstLoginAt ?? this.firstLoginAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      setupCompletedAt: setupCompletedAt ?? this.setupCompletedAt,
      lastXlsxSyncAt: lastXlsxSyncAt ?? this.lastXlsxSyncAt,
      pollingInterval: pollingInterval ?? this.pollingInterval,
      notificationRadiusKm: notificationRadiusKm ?? this.notificationRadiusKm,
      mapFilter: mapFilter ?? this.mapFilter,
      showVisitedOnMap: showVisitedOnMap ?? this.showVisitedOnMap,
      clusterMarkers: clusterMarkers ?? this.clusterMarkers,
      checkinRadiusKm: checkinRadiusKm ?? this.checkinRadiusKm,
      unitSystem: unitSystem ?? this.unitSystem,
      appAppearance: appAppearance ?? this.appAppearance,
      includeVisitedNearby: includeVisitedNearby ?? this.includeVisitedNearby,
      includeVehicleInPrivateNote:
          includeVehicleInPrivateNote ?? this.includeVehicleInPrivateNote,
      notifyNewSites: notifyNewSites ?? this.notifyNewSites,
      notifyFirstEligible: notifyFirstEligible ?? this.notifyFirstEligible,
      nearestSiteLiveUpdate:
          nearestSiteLiveUpdate ?? this.nearestSiteLiveUpdate,
      nearestSiteIncludeConstruction:
          nearestSiteIncludeConstruction ?? this.nearestSiteIncludeConstruction,
      nearestSiteShowDirection:
          nearestSiteShowDirection ?? this.nearestSiteShowDirection,
      lastNotifiedChangeId: lastNotifiedChangeId ?? this.lastNotifiedChangeId,
      lastLatitude: lastLatitude ?? this.lastLatitude,
      lastLongitude: lastLongitude ?? this.lastLongitude,
      lastSitesSyncAt: lastSitesSyncAt ?? this.lastSitesSyncAt,
      lastCheckinHistorySyncAt:
          lastCheckinHistorySyncAt ?? this.lastCheckinHistorySyncAt,
      mapLatitude: mapLatitude ?? this.mapLatitude,
      mapLongitude: mapLongitude ?? this.mapLongitude,
      mapZoom: mapZoom ?? this.mapZoom,
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
    if (authProvider.present) {
      map['auth_provider'] = Variable<String>(
        $UserSettingsTableTable.$converterauthProvidern.toSql(
          authProvider.value,
        ),
      );
    }
    if (firstLoginAt.present) {
      map['first_login_at'] = Variable<DateTime>(firstLoginAt.value);
    }
    if (lastLoginAt.present) {
      map['last_login_at'] = Variable<DateTime>(lastLoginAt.value);
    }
    if (setupCompletedAt.present) {
      map['setup_completed_at'] = Variable<DateTime>(setupCompletedAt.value);
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
    if (clusterMarkers.present) {
      map['cluster_markers'] = Variable<bool>(clusterMarkers.value);
    }
    if (checkinRadiusKm.present) {
      map['checkin_radius_km'] = Variable<double>(checkinRadiusKm.value);
    }
    if (unitSystem.present) {
      map['unit_system'] = Variable<String>(
        $UserSettingsTableTable.$converterunitSystem.toSql(unitSystem.value),
      );
    }
    if (appAppearance.present) {
      map['app_appearance'] = Variable<String>(
        $UserSettingsTableTable.$converterappAppearance.toSql(
          appAppearance.value,
        ),
      );
    }
    if (includeVisitedNearby.present) {
      map['include_visited_nearby'] = Variable<bool>(
        includeVisitedNearby.value,
      );
    }
    if (includeVehicleInPrivateNote.present) {
      map['include_vehicle_in_private_note'] = Variable<bool>(
        includeVehicleInPrivateNote.value,
      );
    }
    if (notifyNewSites.present) {
      map['notify_new_sites'] = Variable<bool>(notifyNewSites.value);
    }
    if (notifyFirstEligible.present) {
      map['notify_first_eligible'] = Variable<bool>(notifyFirstEligible.value);
    }
    if (nearestSiteLiveUpdate.present) {
      map['nearest_site_live_update'] = Variable<bool>(
        nearestSiteLiveUpdate.value,
      );
    }
    if (nearestSiteIncludeConstruction.present) {
      map['nearest_site_include_construction'] = Variable<bool>(
        nearestSiteIncludeConstruction.value,
      );
    }
    if (nearestSiteShowDirection.present) {
      map['nearest_site_show_direction'] = Variable<bool>(
        nearestSiteShowDirection.value,
      );
    }
    if (lastNotifiedChangeId.present) {
      map['last_notified_change_id'] = Variable<int>(
        lastNotifiedChangeId.value,
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
    if (mapLatitude.present) {
      map['map_latitude'] = Variable<double>(mapLatitude.value);
    }
    if (mapLongitude.present) {
      map['map_longitude'] = Variable<double>(mapLongitude.value);
    }
    if (mapZoom.present) {
      map['map_zoom'] = Variable<double>(mapZoom.value);
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
          ..write('authProvider: $authProvider, ')
          ..write('firstLoginAt: $firstLoginAt, ')
          ..write('lastLoginAt: $lastLoginAt, ')
          ..write('setupCompletedAt: $setupCompletedAt, ')
          ..write('lastXlsxSyncAt: $lastXlsxSyncAt, ')
          ..write('pollingInterval: $pollingInterval, ')
          ..write('notificationRadiusKm: $notificationRadiusKm, ')
          ..write('mapFilter: $mapFilter, ')
          ..write('showVisitedOnMap: $showVisitedOnMap, ')
          ..write('clusterMarkers: $clusterMarkers, ')
          ..write('checkinRadiusKm: $checkinRadiusKm, ')
          ..write('unitSystem: $unitSystem, ')
          ..write('appAppearance: $appAppearance, ')
          ..write('includeVisitedNearby: $includeVisitedNearby, ')
          ..write('includeVehicleInPrivateNote: $includeVehicleInPrivateNote, ')
          ..write('notifyNewSites: $notifyNewSites, ')
          ..write('notifyFirstEligible: $notifyFirstEligible, ')
          ..write('nearestSiteLiveUpdate: $nearestSiteLiveUpdate, ')
          ..write(
            'nearestSiteIncludeConstruction: $nearestSiteIncludeConstruction, ',
          )
          ..write('nearestSiteShowDirection: $nearestSiteShowDirection, ')
          ..write('lastNotifiedChangeId: $lastNotifiedChangeId, ')
          ..write('lastLatitude: $lastLatitude, ')
          ..write('lastLongitude: $lastLongitude, ')
          ..write('lastSitesSyncAt: $lastSitesSyncAt, ')
          ..write('lastCheckinHistorySyncAt: $lastCheckinHistorySyncAt, ')
          ..write('mapLatitude: $mapLatitude, ')
          ..write('mapLongitude: $mapLongitude, ')
          ..write('mapZoom: $mapZoom')
          ..write(')'))
        .toString();
  }
}

class $VehiclesTable extends Vehicles with TableInfo<$VehiclesTable, Vehicle> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VehiclesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _makeMeta = const VerificationMeta('make');
  @override
  late final GeneratedColumn<String> make = GeneratedColumn<String>(
    'make',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _modelMeta = const VerificationMeta('model');
  @override
  late final GeneratedColumn<String> model = GeneratedColumn<String>(
    'model',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _yearMeta = const VerificationMeta('year');
  @override
  late final GeneratedColumn<String> year = GeneratedColumn<String>(
    'year',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _trimMeta = const VerificationMeta('trim');
  @override
  late final GeneratedColumn<String> trim = GeneratedColumn<String>(
    'trim',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _hasVinMeta = const VerificationMeta('hasVin');
  @override
  late final GeneratedColumn<bool> hasVin = GeneratedColumn<bool>(
    'has_vin',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("has_vin" IN (0, 1))',
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    label,
    make,
    model,
    year,
    trim,
    hasVin,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'vehicles';
  @override
  VerificationContext validateIntegrity(
    Insertable<Vehicle> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('make')) {
      context.handle(
        _makeMeta,
        make.isAcceptableOrUnknown(data['make']!, _makeMeta),
      );
    }
    if (data.containsKey('model')) {
      context.handle(
        _modelMeta,
        model.isAcceptableOrUnknown(data['model']!, _modelMeta),
      );
    }
    if (data.containsKey('year')) {
      context.handle(
        _yearMeta,
        year.isAcceptableOrUnknown(data['year']!, _yearMeta),
      );
    }
    if (data.containsKey('trim')) {
      context.handle(
        _trimMeta,
        trim.isAcceptableOrUnknown(data['trim']!, _trimMeta),
      );
    }
    if (data.containsKey('has_vin')) {
      context.handle(
        _hasVinMeta,
        hasVin.isAcceptableOrUnknown(data['has_vin']!, _hasVinMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Vehicle map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Vehicle(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      )!,
      make: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}make'],
      ),
      model: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}model'],
      ),
      year: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}year'],
      ),
      trim: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}trim'],
      ),
      hasVin: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}has_vin'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $VehiclesTable createAlias(String alias) {
    return $VehiclesTable(attachedDatabase, alias);
  }
}

class Vehicle extends DataClass implements Insertable<Vehicle> {
  final String id;
  final String label;
  final String? make;
  final String? model;
  final String? year;
  final String? trim;
  final bool hasVin;
  final DateTime createdAt;
  const Vehicle({
    required this.id,
    required this.label,
    this.make,
    this.model,
    this.year,
    this.trim,
    required this.hasVin,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['label'] = Variable<String>(label);
    if (!nullToAbsent || make != null) {
      map['make'] = Variable<String>(make);
    }
    if (!nullToAbsent || model != null) {
      map['model'] = Variable<String>(model);
    }
    if (!nullToAbsent || year != null) {
      map['year'] = Variable<String>(year);
    }
    if (!nullToAbsent || trim != null) {
      map['trim'] = Variable<String>(trim);
    }
    map['has_vin'] = Variable<bool>(hasVin);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  VehiclesCompanion toCompanion(bool nullToAbsent) {
    return VehiclesCompanion(
      id: Value(id),
      label: Value(label),
      make: make == null && nullToAbsent ? const Value.absent() : Value(make),
      model: model == null && nullToAbsent
          ? const Value.absent()
          : Value(model),
      year: year == null && nullToAbsent ? const Value.absent() : Value(year),
      trim: trim == null && nullToAbsent ? const Value.absent() : Value(trim),
      hasVin: Value(hasVin),
      createdAt: Value(createdAt),
    );
  }

  factory Vehicle.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Vehicle(
      id: serializer.fromJson<String>(json['id']),
      label: serializer.fromJson<String>(json['label']),
      make: serializer.fromJson<String?>(json['make']),
      model: serializer.fromJson<String?>(json['model']),
      year: serializer.fromJson<String?>(json['year']),
      trim: serializer.fromJson<String?>(json['trim']),
      hasVin: serializer.fromJson<bool>(json['hasVin']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'label': serializer.toJson<String>(label),
      'make': serializer.toJson<String?>(make),
      'model': serializer.toJson<String?>(model),
      'year': serializer.toJson<String?>(year),
      'trim': serializer.toJson<String?>(trim),
      'hasVin': serializer.toJson<bool>(hasVin),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Vehicle copyWith({
    String? id,
    String? label,
    Value<String?> make = const Value.absent(),
    Value<String?> model = const Value.absent(),
    Value<String?> year = const Value.absent(),
    Value<String?> trim = const Value.absent(),
    bool? hasVin,
    DateTime? createdAt,
  }) => Vehicle(
    id: id ?? this.id,
    label: label ?? this.label,
    make: make.present ? make.value : this.make,
    model: model.present ? model.value : this.model,
    year: year.present ? year.value : this.year,
    trim: trim.present ? trim.value : this.trim,
    hasVin: hasVin ?? this.hasVin,
    createdAt: createdAt ?? this.createdAt,
  );
  Vehicle copyWithCompanion(VehiclesCompanion data) {
    return Vehicle(
      id: data.id.present ? data.id.value : this.id,
      label: data.label.present ? data.label.value : this.label,
      make: data.make.present ? data.make.value : this.make,
      model: data.model.present ? data.model.value : this.model,
      year: data.year.present ? data.year.value : this.year,
      trim: data.trim.present ? data.trim.value : this.trim,
      hasVin: data.hasVin.present ? data.hasVin.value : this.hasVin,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Vehicle(')
          ..write('id: $id, ')
          ..write('label: $label, ')
          ..write('make: $make, ')
          ..write('model: $model, ')
          ..write('year: $year, ')
          ..write('trim: $trim, ')
          ..write('hasVin: $hasVin, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, label, make, model, year, trim, hasVin, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Vehicle &&
          other.id == this.id &&
          other.label == this.label &&
          other.make == this.make &&
          other.model == this.model &&
          other.year == this.year &&
          other.trim == this.trim &&
          other.hasVin == this.hasVin &&
          other.createdAt == this.createdAt);
}

class VehiclesCompanion extends UpdateCompanion<Vehicle> {
  final Value<String> id;
  final Value<String> label;
  final Value<String?> make;
  final Value<String?> model;
  final Value<String?> year;
  final Value<String?> trim;
  final Value<bool> hasVin;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const VehiclesCompanion({
    this.id = const Value.absent(),
    this.label = const Value.absent(),
    this.make = const Value.absent(),
    this.model = const Value.absent(),
    this.year = const Value.absent(),
    this.trim = const Value.absent(),
    this.hasVin = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  VehiclesCompanion.insert({
    required String id,
    required String label,
    this.make = const Value.absent(),
    this.model = const Value.absent(),
    this.year = const Value.absent(),
    this.trim = const Value.absent(),
    this.hasVin = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       label = Value(label);
  static Insertable<Vehicle> custom({
    Expression<String>? id,
    Expression<String>? label,
    Expression<String>? make,
    Expression<String>? model,
    Expression<String>? year,
    Expression<String>? trim,
    Expression<bool>? hasVin,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (label != null) 'label': label,
      if (make != null) 'make': make,
      if (model != null) 'model': model,
      if (year != null) 'year': year,
      if (trim != null) 'trim': trim,
      if (hasVin != null) 'has_vin': hasVin,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  VehiclesCompanion copyWith({
    Value<String>? id,
    Value<String>? label,
    Value<String?>? make,
    Value<String?>? model,
    Value<String?>? year,
    Value<String?>? trim,
    Value<bool>? hasVin,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return VehiclesCompanion(
      id: id ?? this.id,
      label: label ?? this.label,
      make: make ?? this.make,
      model: model ?? this.model,
      year: year ?? this.year,
      trim: trim ?? this.trim,
      hasVin: hasVin ?? this.hasVin,
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
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (make.present) {
      map['make'] = Variable<String>(make.value);
    }
    if (model.present) {
      map['model'] = Variable<String>(model.value);
    }
    if (year.present) {
      map['year'] = Variable<String>(year.value);
    }
    if (trim.present) {
      map['trim'] = Variable<String>(trim.value);
    }
    if (hasVin.present) {
      map['has_vin'] = Variable<bool>(hasVin.value);
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
    return (StringBuffer('VehiclesCompanion(')
          ..write('id: $id, ')
          ..write('label: $label, ')
          ..write('make: $make, ')
          ..write('model: $model, ')
          ..write('year: $year, ')
          ..write('trim: $trim, ')
          ..write('hasVin: $hasVin, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RegionSyncsTable extends RegionSyncs
    with TableInfo<$RegionSyncsTable, RegionSync> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RegionSyncsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _regionIdMeta = const VerificationMeta(
    'regionId',
  );
  @override
  late final GeneratedColumn<int> regionId = GeneratedColumn<int>(
    'region_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastChangeIdMeta = const VerificationMeta(
    'lastChangeId',
  );
  @override
  late final GeneratedColumn<int> lastChangeId = GeneratedColumn<int>(
    'last_change_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _syncedAtMeta = const VerificationMeta(
    'syncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> syncedAt = GeneratedColumn<DateTime>(
    'synced_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [regionId, lastChangeId, syncedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'region_syncs';
  @override
  VerificationContext validateIntegrity(
    Insertable<RegionSync> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('region_id')) {
      context.handle(
        _regionIdMeta,
        regionId.isAcceptableOrUnknown(data['region_id']!, _regionIdMeta),
      );
    }
    if (data.containsKey('last_change_id')) {
      context.handle(
        _lastChangeIdMeta,
        lastChangeId.isAcceptableOrUnknown(
          data['last_change_id']!,
          _lastChangeIdMeta,
        ),
      );
    }
    if (data.containsKey('synced_at')) {
      context.handle(
        _syncedAtMeta,
        syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {regionId};
  @override
  RegionSync map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RegionSync(
      regionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}region_id'],
      )!,
      lastChangeId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_change_id'],
      )!,
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}synced_at'],
      ),
    );
  }

  @override
  $RegionSyncsTable createAlias(String alias) {
    return $RegionSyncsTable(attachedDatabase, alias);
  }
}

class RegionSync extends DataClass implements Insertable<RegionSync> {
  final int regionId;
  final int lastChangeId;
  final DateTime? syncedAt;
  const RegionSync({
    required this.regionId,
    required this.lastChangeId,
    this.syncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['region_id'] = Variable<int>(regionId);
    map['last_change_id'] = Variable<int>(lastChangeId);
    if (!nullToAbsent || syncedAt != null) {
      map['synced_at'] = Variable<DateTime>(syncedAt);
    }
    return map;
  }

  RegionSyncsCompanion toCompanion(bool nullToAbsent) {
    return RegionSyncsCompanion(
      regionId: Value(regionId),
      lastChangeId: Value(lastChangeId),
      syncedAt: syncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(syncedAt),
    );
  }

  factory RegionSync.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RegionSync(
      regionId: serializer.fromJson<int>(json['regionId']),
      lastChangeId: serializer.fromJson<int>(json['lastChangeId']),
      syncedAt: serializer.fromJson<DateTime?>(json['syncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'regionId': serializer.toJson<int>(regionId),
      'lastChangeId': serializer.toJson<int>(lastChangeId),
      'syncedAt': serializer.toJson<DateTime?>(syncedAt),
    };
  }

  RegionSync copyWith({
    int? regionId,
    int? lastChangeId,
    Value<DateTime?> syncedAt = const Value.absent(),
  }) => RegionSync(
    regionId: regionId ?? this.regionId,
    lastChangeId: lastChangeId ?? this.lastChangeId,
    syncedAt: syncedAt.present ? syncedAt.value : this.syncedAt,
  );
  RegionSync copyWithCompanion(RegionSyncsCompanion data) {
    return RegionSync(
      regionId: data.regionId.present ? data.regionId.value : this.regionId,
      lastChangeId: data.lastChangeId.present
          ? data.lastChangeId.value
          : this.lastChangeId,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RegionSync(')
          ..write('regionId: $regionId, ')
          ..write('lastChangeId: $lastChangeId, ')
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(regionId, lastChangeId, syncedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RegionSync &&
          other.regionId == this.regionId &&
          other.lastChangeId == this.lastChangeId &&
          other.syncedAt == this.syncedAt);
}

class RegionSyncsCompanion extends UpdateCompanion<RegionSync> {
  final Value<int> regionId;
  final Value<int> lastChangeId;
  final Value<DateTime?> syncedAt;
  const RegionSyncsCompanion({
    this.regionId = const Value.absent(),
    this.lastChangeId = const Value.absent(),
    this.syncedAt = const Value.absent(),
  });
  RegionSyncsCompanion.insert({
    this.regionId = const Value.absent(),
    this.lastChangeId = const Value.absent(),
    this.syncedAt = const Value.absent(),
  });
  static Insertable<RegionSync> custom({
    Expression<int>? regionId,
    Expression<int>? lastChangeId,
    Expression<DateTime>? syncedAt,
  }) {
    return RawValuesInsertable({
      if (regionId != null) 'region_id': regionId,
      if (lastChangeId != null) 'last_change_id': lastChangeId,
      if (syncedAt != null) 'synced_at': syncedAt,
    });
  }

  RegionSyncsCompanion copyWith({
    Value<int>? regionId,
    Value<int>? lastChangeId,
    Value<DateTime?>? syncedAt,
  }) {
    return RegionSyncsCompanion(
      regionId: regionId ?? this.regionId,
      lastChangeId: lastChangeId ?? this.lastChangeId,
      syncedAt: syncedAt ?? this.syncedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (regionId.present) {
      map['region_id'] = Variable<int>(regionId.value);
    }
    if (lastChangeId.present) {
      map['last_change_id'] = Variable<int>(lastChangeId.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<DateTime>(syncedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RegionSyncsCompanion(')
          ..write('regionId: $regionId, ')
          ..write('lastChangeId: $lastChangeId, ')
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }
}

class $NotificationLogTable extends NotificationLog
    with TableInfo<$NotificationLogTable, NotificationLogData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NotificationLogTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _channelMeta = const VerificationMeta(
    'channel',
  );
  @override
  late final GeneratedColumn<String> channel = GeneratedColumn<String>(
    'channel',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dedupeKeyMeta = const VerificationMeta(
    'dedupeKey',
  );
  @override
  late final GeneratedColumn<String> dedupeKey = GeneratedColumn<String>(
    'dedupe_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sentAtMeta = const VerificationMeta('sentAt');
  @override
  late final GeneratedColumn<DateTime> sentAt = GeneratedColumn<DateTime>(
    'sent_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    siteId,
    channel,
    dedupeKey,
    sentAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'notification_log';
  @override
  VerificationContext validateIntegrity(
    Insertable<NotificationLogData> instance, {
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
    if (data.containsKey('channel')) {
      context.handle(
        _channelMeta,
        channel.isAcceptableOrUnknown(data['channel']!, _channelMeta),
      );
    } else if (isInserting) {
      context.missing(_channelMeta);
    }
    if (data.containsKey('dedupe_key')) {
      context.handle(
        _dedupeKeyMeta,
        dedupeKey.isAcceptableOrUnknown(data['dedupe_key']!, _dedupeKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_dedupeKeyMeta);
    }
    if (data.containsKey('sent_at')) {
      context.handle(
        _sentAtMeta,
        sentAt.isAcceptableOrUnknown(data['sent_at']!, _sentAtMeta),
      );
    } else if (isInserting) {
      context.missing(_sentAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {siteId, channel, dedupeKey},
  ];
  @override
  NotificationLogData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NotificationLogData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      siteId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}site_id'],
      )!,
      channel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}channel'],
      )!,
      dedupeKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dedupe_key'],
      )!,
      sentAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}sent_at'],
      )!,
    );
  }

  @override
  $NotificationLogTable createAlias(String alias) {
    return $NotificationLogTable(attachedDatabase, alias);
  }
}

class NotificationLogData extends DataClass
    implements Insertable<NotificationLogData> {
  final int id;
  final int siteId;
  final String channel;

  /// Change id for a new site, or the site-local day for a First alert.
  final String dedupeKey;
  final DateTime sentAt;
  const NotificationLogData({
    required this.id,
    required this.siteId,
    required this.channel,
    required this.dedupeKey,
    required this.sentAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['site_id'] = Variable<int>(siteId);
    map['channel'] = Variable<String>(channel);
    map['dedupe_key'] = Variable<String>(dedupeKey);
    map['sent_at'] = Variable<DateTime>(sentAt);
    return map;
  }

  NotificationLogCompanion toCompanion(bool nullToAbsent) {
    return NotificationLogCompanion(
      id: Value(id),
      siteId: Value(siteId),
      channel: Value(channel),
      dedupeKey: Value(dedupeKey),
      sentAt: Value(sentAt),
    );
  }

  factory NotificationLogData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NotificationLogData(
      id: serializer.fromJson<int>(json['id']),
      siteId: serializer.fromJson<int>(json['siteId']),
      channel: serializer.fromJson<String>(json['channel']),
      dedupeKey: serializer.fromJson<String>(json['dedupeKey']),
      sentAt: serializer.fromJson<DateTime>(json['sentAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'siteId': serializer.toJson<int>(siteId),
      'channel': serializer.toJson<String>(channel),
      'dedupeKey': serializer.toJson<String>(dedupeKey),
      'sentAt': serializer.toJson<DateTime>(sentAt),
    };
  }

  NotificationLogData copyWith({
    int? id,
    int? siteId,
    String? channel,
    String? dedupeKey,
    DateTime? sentAt,
  }) => NotificationLogData(
    id: id ?? this.id,
    siteId: siteId ?? this.siteId,
    channel: channel ?? this.channel,
    dedupeKey: dedupeKey ?? this.dedupeKey,
    sentAt: sentAt ?? this.sentAt,
  );
  NotificationLogData copyWithCompanion(NotificationLogCompanion data) {
    return NotificationLogData(
      id: data.id.present ? data.id.value : this.id,
      siteId: data.siteId.present ? data.siteId.value : this.siteId,
      channel: data.channel.present ? data.channel.value : this.channel,
      dedupeKey: data.dedupeKey.present ? data.dedupeKey.value : this.dedupeKey,
      sentAt: data.sentAt.present ? data.sentAt.value : this.sentAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NotificationLogData(')
          ..write('id: $id, ')
          ..write('siteId: $siteId, ')
          ..write('channel: $channel, ')
          ..write('dedupeKey: $dedupeKey, ')
          ..write('sentAt: $sentAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, siteId, channel, dedupeKey, sentAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NotificationLogData &&
          other.id == this.id &&
          other.siteId == this.siteId &&
          other.channel == this.channel &&
          other.dedupeKey == this.dedupeKey &&
          other.sentAt == this.sentAt);
}

class NotificationLogCompanion extends UpdateCompanion<NotificationLogData> {
  final Value<int> id;
  final Value<int> siteId;
  final Value<String> channel;
  final Value<String> dedupeKey;
  final Value<DateTime> sentAt;
  const NotificationLogCompanion({
    this.id = const Value.absent(),
    this.siteId = const Value.absent(),
    this.channel = const Value.absent(),
    this.dedupeKey = const Value.absent(),
    this.sentAt = const Value.absent(),
  });
  NotificationLogCompanion.insert({
    this.id = const Value.absent(),
    required int siteId,
    required String channel,
    required String dedupeKey,
    required DateTime sentAt,
  }) : siteId = Value(siteId),
       channel = Value(channel),
       dedupeKey = Value(dedupeKey),
       sentAt = Value(sentAt);
  static Insertable<NotificationLogData> custom({
    Expression<int>? id,
    Expression<int>? siteId,
    Expression<String>? channel,
    Expression<String>? dedupeKey,
    Expression<DateTime>? sentAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (siteId != null) 'site_id': siteId,
      if (channel != null) 'channel': channel,
      if (dedupeKey != null) 'dedupe_key': dedupeKey,
      if (sentAt != null) 'sent_at': sentAt,
    });
  }

  NotificationLogCompanion copyWith({
    Value<int>? id,
    Value<int>? siteId,
    Value<String>? channel,
    Value<String>? dedupeKey,
    Value<DateTime>? sentAt,
  }) {
    return NotificationLogCompanion(
      id: id ?? this.id,
      siteId: siteId ?? this.siteId,
      channel: channel ?? this.channel,
      dedupeKey: dedupeKey ?? this.dedupeKey,
      sentAt: sentAt ?? this.sentAt,
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
    if (channel.present) {
      map['channel'] = Variable<String>(channel.value);
    }
    if (dedupeKey.present) {
      map['dedupe_key'] = Variable<String>(dedupeKey.value);
    }
    if (sentAt.present) {
      map['sent_at'] = Variable<DateTime>(sentAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NotificationLogCompanion(')
          ..write('id: $id, ')
          ..write('siteId: $siteId, ')
          ..write('channel: $channel, ')
          ..write('dedupeKey: $dedupeKey, ')
          ..write('sentAt: $sentAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $SitesTable sites = $SitesTable(this);
  late final $VisitsTable visits = $VisitsTable(this);
  late final $OutboxEntriesTable outboxEntries = $OutboxEntriesTable(this);
  late final $SiteCheckinsTable siteCheckins = $SiteCheckinsTable(this);
  late final $UserSettingsTableTable userSettingsTable =
      $UserSettingsTableTable(this);
  late final $VehiclesTable vehicles = $VehiclesTable(this);
  late final $RegionSyncsTable regionSyncs = $RegionSyncsTable(this);
  late final $NotificationLogTable notificationLog = $NotificationLogTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    sites,
    visits,
    outboxEntries,
    siteCheckins,
    userSettingsTable,
    vehicles,
    regionSyncs,
    notificationLog,
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
      Value<String?> street,
      Value<String?> city,
      Value<String?> state,
      Value<String> country,
      Value<String> region,
      Value<String?> timezone,
      Value<int?> stallCount,
      Value<int> stallsV2,
      Value<int> stallsV3,
      Value<int> stallsV4,
      Value<int> stallsUrban,
      Value<int> stallsOther,
      Value<bool> otherEvs,
      Value<DateTime?> dateOpened,
      Value<DateTime?> firstOpened,
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
      Value<String?> street,
      Value<String?> city,
      Value<String?> state,
      Value<String> country,
      Value<String> region,
      Value<String?> timezone,
      Value<int?> stallCount,
      Value<int> stallsV2,
      Value<int> stallsV3,
      Value<int> stallsV4,
      Value<int> stallsUrban,
      Value<int> stallsOther,
      Value<bool> otherEvs,
      Value<DateTime?> dateOpened,
      Value<DateTime?> firstOpened,
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

  ColumnFilters<String> get street => $composableBuilder(
    column: $table.street,
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

  ColumnFilters<int> get stallsV2 => $composableBuilder(
    column: $table.stallsV2,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get stallsV3 => $composableBuilder(
    column: $table.stallsV3,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get stallsV4 => $composableBuilder(
    column: $table.stallsV4,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get stallsUrban => $composableBuilder(
    column: $table.stallsUrban,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get stallsOther => $composableBuilder(
    column: $table.stallsOther,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get otherEvs => $composableBuilder(
    column: $table.otherEvs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dateOpened => $composableBuilder(
    column: $table.dateOpened,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get firstOpened => $composableBuilder(
    column: $table.firstOpened,
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

  ColumnOrderings<String> get street => $composableBuilder(
    column: $table.street,
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

  ColumnOrderings<int> get stallsV2 => $composableBuilder(
    column: $table.stallsV2,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get stallsV3 => $composableBuilder(
    column: $table.stallsV3,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get stallsV4 => $composableBuilder(
    column: $table.stallsV4,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get stallsUrban => $composableBuilder(
    column: $table.stallsUrban,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get stallsOther => $composableBuilder(
    column: $table.stallsOther,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get otherEvs => $composableBuilder(
    column: $table.otherEvs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dateOpened => $composableBuilder(
    column: $table.dateOpened,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get firstOpened => $composableBuilder(
    column: $table.firstOpened,
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

  GeneratedColumn<String> get street =>
      $composableBuilder(column: $table.street, builder: (column) => column);

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

  GeneratedColumn<int> get stallsV2 =>
      $composableBuilder(column: $table.stallsV2, builder: (column) => column);

  GeneratedColumn<int> get stallsV3 =>
      $composableBuilder(column: $table.stallsV3, builder: (column) => column);

  GeneratedColumn<int> get stallsV4 =>
      $composableBuilder(column: $table.stallsV4, builder: (column) => column);

  GeneratedColumn<int> get stallsUrban => $composableBuilder(
    column: $table.stallsUrban,
    builder: (column) => column,
  );

  GeneratedColumn<int> get stallsOther => $composableBuilder(
    column: $table.stallsOther,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get otherEvs =>
      $composableBuilder(column: $table.otherEvs, builder: (column) => column);

  GeneratedColumn<DateTime> get dateOpened => $composableBuilder(
    column: $table.dateOpened,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get firstOpened => $composableBuilder(
    column: $table.firstOpened,
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
                Value<String?> street = const Value.absent(),
                Value<String?> city = const Value.absent(),
                Value<String?> state = const Value.absent(),
                Value<String> country = const Value.absent(),
                Value<String> region = const Value.absent(),
                Value<String?> timezone = const Value.absent(),
                Value<int?> stallCount = const Value.absent(),
                Value<int> stallsV2 = const Value.absent(),
                Value<int> stallsV3 = const Value.absent(),
                Value<int> stallsV4 = const Value.absent(),
                Value<int> stallsUrban = const Value.absent(),
                Value<int> stallsOther = const Value.absent(),
                Value<bool> otherEvs = const Value.absent(),
                Value<DateTime?> dateOpened = const Value.absent(),
                Value<DateTime?> firstOpened = const Value.absent(),
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
                street: street,
                city: city,
                state: state,
                country: country,
                region: region,
                timezone: timezone,
                stallCount: stallCount,
                stallsV2: stallsV2,
                stallsV3: stallsV3,
                stallsV4: stallsV4,
                stallsUrban: stallsUrban,
                stallsOther: stallsOther,
                otherEvs: otherEvs,
                dateOpened: dateOpened,
                firstOpened: firstOpened,
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
                Value<String?> street = const Value.absent(),
                Value<String?> city = const Value.absent(),
                Value<String?> state = const Value.absent(),
                Value<String> country = const Value.absent(),
                Value<String> region = const Value.absent(),
                Value<String?> timezone = const Value.absent(),
                Value<int?> stallCount = const Value.absent(),
                Value<int> stallsV2 = const Value.absent(),
                Value<int> stallsV3 = const Value.absent(),
                Value<int> stallsV4 = const Value.absent(),
                Value<int> stallsUrban = const Value.absent(),
                Value<int> stallsOther = const Value.absent(),
                Value<bool> otherEvs = const Value.absent(),
                Value<DateTime?> dateOpened = const Value.absent(),
                Value<DateTime?> firstOpened = const Value.absent(),
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
                street: street,
                city: city,
                state: state,
                country: country,
                region: region,
                timezone: timezone,
                stallCount: stallCount,
                stallsV2: stallsV2,
                stallsV3: stallsV3,
                stallsV4: stallsV4,
                stallsUrban: stallsUrban,
                stallsOther: stallsOther,
                otherEvs: otherEvs,
                dateOpened: dateOpened,
                firstOpened: firstOpened,
                hasCheckins: hasCheckins,
                visited: visited,
                lastSynced: lastSynced,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SitesTable, Site>(table),
                  BaseReferences<_$AppDatabase, $SitesTable, Site>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
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
      Value<int?> checkinId,
      required int siteId,
      required DateTime checkinDate,
      required DateTime checkinTime,
      Value<CheckinPrecision> checkinPrecision,
      Value<bool> isFirst,
      Value<CheckinMethod> method,
      Value<String?> notesPublic,
      Value<String?> notesPrivate,
      Value<String?> vehicleId,
      Value<int?> geoDistanceAccuracy,
      Value<int?> geoDistance,
      required DateTime importedAt,
    });
typedef $$VisitsTableUpdateCompanionBuilder =
    VisitsCompanion Function({
      Value<int> id,
      Value<int?> checkinId,
      Value<int> siteId,
      Value<DateTime> checkinDate,
      Value<DateTime> checkinTime,
      Value<CheckinPrecision> checkinPrecision,
      Value<bool> isFirst,
      Value<CheckinMethod> method,
      Value<String?> notesPublic,
      Value<String?> notesPrivate,
      Value<String?> vehicleId,
      Value<int?> geoDistanceAccuracy,
      Value<int?> geoDistance,
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

  ColumnWithTypeConverterFilters<CheckinPrecision, CheckinPrecision, String>
  get checkinPrecision => $composableBuilder(
    column: $table.checkinPrecision,
    builder: (column) => ColumnWithTypeConverterFilters(column),
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

  ColumnFilters<String> get notesPrivate => $composableBuilder(
    column: $table.notesPrivate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get vehicleId => $composableBuilder(
    column: $table.vehicleId,
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

  ColumnOrderings<String> get checkinPrecision => $composableBuilder(
    column: $table.checkinPrecision,
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

  ColumnOrderings<String> get notesPrivate => $composableBuilder(
    column: $table.notesPrivate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get vehicleId => $composableBuilder(
    column: $table.vehicleId,
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

  GeneratedColumnWithTypeConverter<CheckinPrecision, String>
  get checkinPrecision => $composableBuilder(
    column: $table.checkinPrecision,
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

  GeneratedColumn<String> get notesPrivate => $composableBuilder(
    column: $table.notesPrivate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get vehicleId =>
      $composableBuilder(column: $table.vehicleId, builder: (column) => column);

  GeneratedColumn<int> get geoDistanceAccuracy => $composableBuilder(
    column: $table.geoDistanceAccuracy,
    builder: (column) => column,
  );

  GeneratedColumn<int> get geoDistance => $composableBuilder(
    column: $table.geoDistance,
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
                Value<int?> checkinId = const Value.absent(),
                Value<int> siteId = const Value.absent(),
                Value<DateTime> checkinDate = const Value.absent(),
                Value<DateTime> checkinTime = const Value.absent(),
                Value<CheckinPrecision> checkinPrecision = const Value.absent(),
                Value<bool> isFirst = const Value.absent(),
                Value<CheckinMethod> method = const Value.absent(),
                Value<String?> notesPublic = const Value.absent(),
                Value<String?> notesPrivate = const Value.absent(),
                Value<String?> vehicleId = const Value.absent(),
                Value<int?> geoDistanceAccuracy = const Value.absent(),
                Value<int?> geoDistance = const Value.absent(),
                Value<DateTime> importedAt = const Value.absent(),
              }) => VisitsCompanion(
                id: id,
                checkinId: checkinId,
                siteId: siteId,
                checkinDate: checkinDate,
                checkinTime: checkinTime,
                checkinPrecision: checkinPrecision,
                isFirst: isFirst,
                method: method,
                notesPublic: notesPublic,
                notesPrivate: notesPrivate,
                vehicleId: vehicleId,
                geoDistanceAccuracy: geoDistanceAccuracy,
                geoDistance: geoDistance,
                importedAt: importedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> checkinId = const Value.absent(),
                required int siteId,
                required DateTime checkinDate,
                required DateTime checkinTime,
                Value<CheckinPrecision> checkinPrecision = const Value.absent(),
                Value<bool> isFirst = const Value.absent(),
                Value<CheckinMethod> method = const Value.absent(),
                Value<String?> notesPublic = const Value.absent(),
                Value<String?> notesPrivate = const Value.absent(),
                Value<String?> vehicleId = const Value.absent(),
                Value<int?> geoDistanceAccuracy = const Value.absent(),
                Value<int?> geoDistance = const Value.absent(),
                required DateTime importedAt,
              }) => VisitsCompanion.insert(
                id: id,
                checkinId: checkinId,
                siteId: siteId,
                checkinDate: checkinDate,
                checkinTime: checkinTime,
                checkinPrecision: checkinPrecision,
                isFirst: isFirst,
                method: method,
                notesPublic: notesPublic,
                notesPrivate: notesPrivate,
                vehicleId: vehicleId,
                geoDistanceAccuracy: geoDistanceAccuracy,
                geoDistance: geoDistance,
                importedAt: importedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$VisitsTable, Visit>(table),
                  BaseReferences<_$AppDatabase, $VisitsTable, Visit>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
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
typedef $$OutboxEntriesTableCreateCompanionBuilder =
    OutboxEntriesCompanion Function({
      Value<int> visitId,
      Value<OutboxState> state,
      Value<double?> latitude,
      Value<double?> longitude,
      Value<double?> accuracy,
      Value<int> attempts,
      Value<DateTime?> lastAttemptAt,
      Value<String?> lastError,
    });
typedef $$OutboxEntriesTableUpdateCompanionBuilder =
    OutboxEntriesCompanion Function({
      Value<int> visitId,
      Value<OutboxState> state,
      Value<double?> latitude,
      Value<double?> longitude,
      Value<double?> accuracy,
      Value<int> attempts,
      Value<DateTime?> lastAttemptAt,
      Value<String?> lastError,
    });

class $$OutboxEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $OutboxEntriesTable> {
  $$OutboxEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get visitId => $composableBuilder(
    column: $table.visitId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<OutboxState, OutboxState, String> get state =>
      $composableBuilder(
        column: $table.state,
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

  ColumnFilters<double> get accuracy => $composableBuilder(
    column: $table.accuracy,
    builder: (column) => ColumnFilters(column),
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

class $$OutboxEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $OutboxEntriesTable> {
  $$OutboxEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get visitId => $composableBuilder(
    column: $table.visitId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get state => $composableBuilder(
    column: $table.state,
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

class $$OutboxEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $OutboxEntriesTable> {
  $$OutboxEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get visitId =>
      $composableBuilder(column: $table.visitId, builder: (column) => column);

  GeneratedColumnWithTypeConverter<OutboxState, String> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<double> get accuracy =>
      $composableBuilder(column: $table.accuracy, builder: (column) => column);

  GeneratedColumn<int> get attempts =>
      $composableBuilder(column: $table.attempts, builder: (column) => column);

  GeneratedColumn<DateTime> get lastAttemptAt => $composableBuilder(
    column: $table.lastAttemptAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);
}

class $$OutboxEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $OutboxEntriesTable,
          OutboxEntry,
          $$OutboxEntriesTableFilterComposer,
          $$OutboxEntriesTableOrderingComposer,
          $$OutboxEntriesTableAnnotationComposer,
          $$OutboxEntriesTableCreateCompanionBuilder,
          $$OutboxEntriesTableUpdateCompanionBuilder,
          (
            OutboxEntry,
            BaseReferences<_$AppDatabase, $OutboxEntriesTable, OutboxEntry>,
          ),
          OutboxEntry,
          PrefetchHooks Function()
        > {
  $$OutboxEntriesTableTableManager(_$AppDatabase db, $OutboxEntriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OutboxEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OutboxEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OutboxEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> visitId = const Value.absent(),
                Value<OutboxState> state = const Value.absent(),
                Value<double?> latitude = const Value.absent(),
                Value<double?> longitude = const Value.absent(),
                Value<double?> accuracy = const Value.absent(),
                Value<int> attempts = const Value.absent(),
                Value<DateTime?> lastAttemptAt = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
              }) => OutboxEntriesCompanion(
                visitId: visitId,
                state: state,
                latitude: latitude,
                longitude: longitude,
                accuracy: accuracy,
                attempts: attempts,
                lastAttemptAt: lastAttemptAt,
                lastError: lastError,
              ),
          createCompanionCallback:
              ({
                Value<int> visitId = const Value.absent(),
                Value<OutboxState> state = const Value.absent(),
                Value<double?> latitude = const Value.absent(),
                Value<double?> longitude = const Value.absent(),
                Value<double?> accuracy = const Value.absent(),
                Value<int> attempts = const Value.absent(),
                Value<DateTime?> lastAttemptAt = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
              }) => OutboxEntriesCompanion.insert(
                visitId: visitId,
                state: state,
                latitude: latitude,
                longitude: longitude,
                accuracy: accuracy,
                attempts: attempts,
                lastAttemptAt: lastAttemptAt,
                lastError: lastError,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$OutboxEntriesTable, OutboxEntry>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $OutboxEntriesTable,
                    OutboxEntry
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$OutboxEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $OutboxEntriesTable,
      OutboxEntry,
      $$OutboxEntriesTableFilterComposer,
      $$OutboxEntriesTableOrderingComposer,
      $$OutboxEntriesTableAnnotationComposer,
      $$OutboxEntriesTableCreateCompanionBuilder,
      $$OutboxEntriesTableUpdateCompanionBuilder,
      (
        OutboxEntry,
        BaseReferences<_$AppDatabase, $OutboxEntriesTable, OutboxEntry>,
      ),
      OutboxEntry,
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
                syncedAt: syncedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SiteCheckinsTable, SiteCheckin>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $SiteCheckinsTable,
                    SiteCheckin
                  >(db, table, e),
                ),
              )
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
      Value<AuthProvider?> authProvider,
      Value<DateTime?> firstLoginAt,
      Value<DateTime?> lastLoginAt,
      Value<DateTime?> setupCompletedAt,
      Value<DateTime?> lastXlsxSyncAt,
      Value<PollingInterval> pollingInterval,
      Value<double> notificationRadiusKm,
      Value<MapFilter> mapFilter,
      Value<bool> showVisitedOnMap,
      Value<bool> clusterMarkers,
      Value<double> checkinRadiusKm,
      Value<UnitSystem> unitSystem,
      Value<AppAppearance> appAppearance,
      Value<bool> includeVisitedNearby,
      Value<bool> includeVehicleInPrivateNote,
      Value<bool> notifyNewSites,
      Value<bool> notifyFirstEligible,
      Value<bool> nearestSiteLiveUpdate,
      Value<bool> nearestSiteIncludeConstruction,
      Value<bool> nearestSiteShowDirection,
      Value<int?> lastNotifiedChangeId,
      Value<double?> lastLatitude,
      Value<double?> lastLongitude,
      Value<DateTime?> lastSitesSyncAt,
      Value<DateTime?> lastCheckinHistorySyncAt,
      Value<double?> mapLatitude,
      Value<double?> mapLongitude,
      Value<double?> mapZoom,
    });
typedef $$UserSettingsTableTableUpdateCompanionBuilder =
    UserSettingsTableCompanion Function({
      Value<int> id,
      Value<int?> odUserId,
      Value<String?> username,
      Value<String?> displayName,
      Value<AuthProvider?> authProvider,
      Value<DateTime?> firstLoginAt,
      Value<DateTime?> lastLoginAt,
      Value<DateTime?> setupCompletedAt,
      Value<DateTime?> lastXlsxSyncAt,
      Value<PollingInterval> pollingInterval,
      Value<double> notificationRadiusKm,
      Value<MapFilter> mapFilter,
      Value<bool> showVisitedOnMap,
      Value<bool> clusterMarkers,
      Value<double> checkinRadiusKm,
      Value<UnitSystem> unitSystem,
      Value<AppAppearance> appAppearance,
      Value<bool> includeVisitedNearby,
      Value<bool> includeVehicleInPrivateNote,
      Value<bool> notifyNewSites,
      Value<bool> notifyFirstEligible,
      Value<bool> nearestSiteLiveUpdate,
      Value<bool> nearestSiteIncludeConstruction,
      Value<bool> nearestSiteShowDirection,
      Value<int?> lastNotifiedChangeId,
      Value<double?> lastLatitude,
      Value<double?> lastLongitude,
      Value<DateTime?> lastSitesSyncAt,
      Value<DateTime?> lastCheckinHistorySyncAt,
      Value<double?> mapLatitude,
      Value<double?> mapLongitude,
      Value<double?> mapZoom,
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

  ColumnWithTypeConverterFilters<AuthProvider?, AuthProvider, String>
  get authProvider => $composableBuilder(
    column: $table.authProvider,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<DateTime> get firstLoginAt => $composableBuilder(
    column: $table.firstLoginAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastLoginAt => $composableBuilder(
    column: $table.lastLoginAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get setupCompletedAt => $composableBuilder(
    column: $table.setupCompletedAt,
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

  ColumnFilters<bool> get clusterMarkers => $composableBuilder(
    column: $table.clusterMarkers,
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

  ColumnWithTypeConverterFilters<AppAppearance, AppAppearance, String>
  get appAppearance => $composableBuilder(
    column: $table.appAppearance,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<bool> get includeVisitedNearby => $composableBuilder(
    column: $table.includeVisitedNearby,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get includeVehicleInPrivateNote => $composableBuilder(
    column: $table.includeVehicleInPrivateNote,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get notifyNewSites => $composableBuilder(
    column: $table.notifyNewSites,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get notifyFirstEligible => $composableBuilder(
    column: $table.notifyFirstEligible,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get nearestSiteLiveUpdate => $composableBuilder(
    column: $table.nearestSiteLiveUpdate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get nearestSiteIncludeConstruction => $composableBuilder(
    column: $table.nearestSiteIncludeConstruction,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get nearestSiteShowDirection => $composableBuilder(
    column: $table.nearestSiteShowDirection,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastNotifiedChangeId => $composableBuilder(
    column: $table.lastNotifiedChangeId,
    builder: (column) => ColumnFilters(column),
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

  ColumnFilters<double> get mapLatitude => $composableBuilder(
    column: $table.mapLatitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get mapLongitude => $composableBuilder(
    column: $table.mapLongitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get mapZoom => $composableBuilder(
    column: $table.mapZoom,
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

  ColumnOrderings<String> get authProvider => $composableBuilder(
    column: $table.authProvider,
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

  ColumnOrderings<DateTime> get setupCompletedAt => $composableBuilder(
    column: $table.setupCompletedAt,
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

  ColumnOrderings<bool> get clusterMarkers => $composableBuilder(
    column: $table.clusterMarkers,
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

  ColumnOrderings<String> get appAppearance => $composableBuilder(
    column: $table.appAppearance,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get includeVisitedNearby => $composableBuilder(
    column: $table.includeVisitedNearby,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get includeVehicleInPrivateNote => $composableBuilder(
    column: $table.includeVehicleInPrivateNote,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get notifyNewSites => $composableBuilder(
    column: $table.notifyNewSites,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get notifyFirstEligible => $composableBuilder(
    column: $table.notifyFirstEligible,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get nearestSiteLiveUpdate => $composableBuilder(
    column: $table.nearestSiteLiveUpdate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get nearestSiteIncludeConstruction =>
      $composableBuilder(
        column: $table.nearestSiteIncludeConstruction,
        builder: (column) => ColumnOrderings(column),
      );

  ColumnOrderings<bool> get nearestSiteShowDirection => $composableBuilder(
    column: $table.nearestSiteShowDirection,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastNotifiedChangeId => $composableBuilder(
    column: $table.lastNotifiedChangeId,
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

  ColumnOrderings<double> get mapLatitude => $composableBuilder(
    column: $table.mapLatitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get mapLongitude => $composableBuilder(
    column: $table.mapLongitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get mapZoom => $composableBuilder(
    column: $table.mapZoom,
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

  GeneratedColumnWithTypeConverter<AuthProvider?, String> get authProvider =>
      $composableBuilder(
        column: $table.authProvider,
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

  GeneratedColumn<DateTime> get setupCompletedAt => $composableBuilder(
    column: $table.setupCompletedAt,
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

  GeneratedColumn<bool> get clusterMarkers => $composableBuilder(
    column: $table.clusterMarkers,
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

  GeneratedColumnWithTypeConverter<AppAppearance, String> get appAppearance =>
      $composableBuilder(
        column: $table.appAppearance,
        builder: (column) => column,
      );

  GeneratedColumn<bool> get includeVisitedNearby => $composableBuilder(
    column: $table.includeVisitedNearby,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get includeVehicleInPrivateNote => $composableBuilder(
    column: $table.includeVehicleInPrivateNote,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get notifyNewSites => $composableBuilder(
    column: $table.notifyNewSites,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get notifyFirstEligible => $composableBuilder(
    column: $table.notifyFirstEligible,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get nearestSiteLiveUpdate => $composableBuilder(
    column: $table.nearestSiteLiveUpdate,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get nearestSiteIncludeConstruction =>
      $composableBuilder(
        column: $table.nearestSiteIncludeConstruction,
        builder: (column) => column,
      );

  GeneratedColumn<bool> get nearestSiteShowDirection => $composableBuilder(
    column: $table.nearestSiteShowDirection,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastNotifiedChangeId => $composableBuilder(
    column: $table.lastNotifiedChangeId,
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

  GeneratedColumn<double> get mapLatitude => $composableBuilder(
    column: $table.mapLatitude,
    builder: (column) => column,
  );

  GeneratedColumn<double> get mapLongitude => $composableBuilder(
    column: $table.mapLongitude,
    builder: (column) => column,
  );

  GeneratedColumn<double> get mapZoom =>
      $composableBuilder(column: $table.mapZoom, builder: (column) => column);
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
                Value<AuthProvider?> authProvider = const Value.absent(),
                Value<DateTime?> firstLoginAt = const Value.absent(),
                Value<DateTime?> lastLoginAt = const Value.absent(),
                Value<DateTime?> setupCompletedAt = const Value.absent(),
                Value<DateTime?> lastXlsxSyncAt = const Value.absent(),
                Value<PollingInterval> pollingInterval = const Value.absent(),
                Value<double> notificationRadiusKm = const Value.absent(),
                Value<MapFilter> mapFilter = const Value.absent(),
                Value<bool> showVisitedOnMap = const Value.absent(),
                Value<bool> clusterMarkers = const Value.absent(),
                Value<double> checkinRadiusKm = const Value.absent(),
                Value<UnitSystem> unitSystem = const Value.absent(),
                Value<AppAppearance> appAppearance = const Value.absent(),
                Value<bool> includeVisitedNearby = const Value.absent(),
                Value<bool> includeVehicleInPrivateNote = const Value.absent(),
                Value<bool> notifyNewSites = const Value.absent(),
                Value<bool> notifyFirstEligible = const Value.absent(),
                Value<bool> nearestSiteLiveUpdate = const Value.absent(),
                Value<bool> nearestSiteIncludeConstruction =
                    const Value.absent(),
                Value<bool> nearestSiteShowDirection = const Value.absent(),
                Value<int?> lastNotifiedChangeId = const Value.absent(),
                Value<double?> lastLatitude = const Value.absent(),
                Value<double?> lastLongitude = const Value.absent(),
                Value<DateTime?> lastSitesSyncAt = const Value.absent(),
                Value<DateTime?> lastCheckinHistorySyncAt =
                    const Value.absent(),
                Value<double?> mapLatitude = const Value.absent(),
                Value<double?> mapLongitude = const Value.absent(),
                Value<double?> mapZoom = const Value.absent(),
              }) => UserSettingsTableCompanion(
                id: id,
                odUserId: odUserId,
                username: username,
                displayName: displayName,
                authProvider: authProvider,
                firstLoginAt: firstLoginAt,
                lastLoginAt: lastLoginAt,
                setupCompletedAt: setupCompletedAt,
                lastXlsxSyncAt: lastXlsxSyncAt,
                pollingInterval: pollingInterval,
                notificationRadiusKm: notificationRadiusKm,
                mapFilter: mapFilter,
                showVisitedOnMap: showVisitedOnMap,
                clusterMarkers: clusterMarkers,
                checkinRadiusKm: checkinRadiusKm,
                unitSystem: unitSystem,
                appAppearance: appAppearance,
                includeVisitedNearby: includeVisitedNearby,
                includeVehicleInPrivateNote: includeVehicleInPrivateNote,
                notifyNewSites: notifyNewSites,
                notifyFirstEligible: notifyFirstEligible,
                nearestSiteLiveUpdate: nearestSiteLiveUpdate,
                nearestSiteIncludeConstruction: nearestSiteIncludeConstruction,
                nearestSiteShowDirection: nearestSiteShowDirection,
                lastNotifiedChangeId: lastNotifiedChangeId,
                lastLatitude: lastLatitude,
                lastLongitude: lastLongitude,
                lastSitesSyncAt: lastSitesSyncAt,
                lastCheckinHistorySyncAt: lastCheckinHistorySyncAt,
                mapLatitude: mapLatitude,
                mapLongitude: mapLongitude,
                mapZoom: mapZoom,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> odUserId = const Value.absent(),
                Value<String?> username = const Value.absent(),
                Value<String?> displayName = const Value.absent(),
                Value<AuthProvider?> authProvider = const Value.absent(),
                Value<DateTime?> firstLoginAt = const Value.absent(),
                Value<DateTime?> lastLoginAt = const Value.absent(),
                Value<DateTime?> setupCompletedAt = const Value.absent(),
                Value<DateTime?> lastXlsxSyncAt = const Value.absent(),
                Value<PollingInterval> pollingInterval = const Value.absent(),
                Value<double> notificationRadiusKm = const Value.absent(),
                Value<MapFilter> mapFilter = const Value.absent(),
                Value<bool> showVisitedOnMap = const Value.absent(),
                Value<bool> clusterMarkers = const Value.absent(),
                Value<double> checkinRadiusKm = const Value.absent(),
                Value<UnitSystem> unitSystem = const Value.absent(),
                Value<AppAppearance> appAppearance = const Value.absent(),
                Value<bool> includeVisitedNearby = const Value.absent(),
                Value<bool> includeVehicleInPrivateNote = const Value.absent(),
                Value<bool> notifyNewSites = const Value.absent(),
                Value<bool> notifyFirstEligible = const Value.absent(),
                Value<bool> nearestSiteLiveUpdate = const Value.absent(),
                Value<bool> nearestSiteIncludeConstruction =
                    const Value.absent(),
                Value<bool> nearestSiteShowDirection = const Value.absent(),
                Value<int?> lastNotifiedChangeId = const Value.absent(),
                Value<double?> lastLatitude = const Value.absent(),
                Value<double?> lastLongitude = const Value.absent(),
                Value<DateTime?> lastSitesSyncAt = const Value.absent(),
                Value<DateTime?> lastCheckinHistorySyncAt =
                    const Value.absent(),
                Value<double?> mapLatitude = const Value.absent(),
                Value<double?> mapLongitude = const Value.absent(),
                Value<double?> mapZoom = const Value.absent(),
              }) => UserSettingsTableCompanion.insert(
                id: id,
                odUserId: odUserId,
                username: username,
                displayName: displayName,
                authProvider: authProvider,
                firstLoginAt: firstLoginAt,
                lastLoginAt: lastLoginAt,
                setupCompletedAt: setupCompletedAt,
                lastXlsxSyncAt: lastXlsxSyncAt,
                pollingInterval: pollingInterval,
                notificationRadiusKm: notificationRadiusKm,
                mapFilter: mapFilter,
                showVisitedOnMap: showVisitedOnMap,
                clusterMarkers: clusterMarkers,
                checkinRadiusKm: checkinRadiusKm,
                unitSystem: unitSystem,
                appAppearance: appAppearance,
                includeVisitedNearby: includeVisitedNearby,
                includeVehicleInPrivateNote: includeVehicleInPrivateNote,
                notifyNewSites: notifyNewSites,
                notifyFirstEligible: notifyFirstEligible,
                nearestSiteLiveUpdate: nearestSiteLiveUpdate,
                nearestSiteIncludeConstruction: nearestSiteIncludeConstruction,
                nearestSiteShowDirection: nearestSiteShowDirection,
                lastNotifiedChangeId: lastNotifiedChangeId,
                lastLatitude: lastLatitude,
                lastLongitude: lastLongitude,
                lastSitesSyncAt: lastSitesSyncAt,
                lastCheckinHistorySyncAt: lastCheckinHistorySyncAt,
                mapLatitude: mapLatitude,
                mapLongitude: mapLongitude,
                mapZoom: mapZoom,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$UserSettingsTableTable, UserSettingsTableData>(
                    table,
                  ),
                  BaseReferences<
                    _$AppDatabase,
                    $UserSettingsTableTable,
                    UserSettingsTableData
                  >(db, table, e),
                ),
              )
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
typedef $$VehiclesTableCreateCompanionBuilder =
    VehiclesCompanion Function({
      required String id,
      required String label,
      Value<String?> make,
      Value<String?> model,
      Value<String?> year,
      Value<String?> trim,
      Value<bool> hasVin,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });
typedef $$VehiclesTableUpdateCompanionBuilder =
    VehiclesCompanion Function({
      Value<String> id,
      Value<String> label,
      Value<String?> make,
      Value<String?> model,
      Value<String?> year,
      Value<String?> trim,
      Value<bool> hasVin,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$VehiclesTableFilterComposer
    extends Composer<_$AppDatabase, $VehiclesTable> {
  $$VehiclesTableFilterComposer({
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

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get make => $composableBuilder(
    column: $table.make,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get model => $composableBuilder(
    column: $table.model,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get trim => $composableBuilder(
    column: $table.trim,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get hasVin => $composableBuilder(
    column: $table.hasVin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$VehiclesTableOrderingComposer
    extends Composer<_$AppDatabase, $VehiclesTable> {
  $$VehiclesTableOrderingComposer({
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

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get make => $composableBuilder(
    column: $table.make,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get model => $composableBuilder(
    column: $table.model,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get trim => $composableBuilder(
    column: $table.trim,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get hasVin => $composableBuilder(
    column: $table.hasVin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$VehiclesTableAnnotationComposer
    extends Composer<_$AppDatabase, $VehiclesTable> {
  $$VehiclesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<String> get make =>
      $composableBuilder(column: $table.make, builder: (column) => column);

  GeneratedColumn<String> get model =>
      $composableBuilder(column: $table.model, builder: (column) => column);

  GeneratedColumn<String> get year =>
      $composableBuilder(column: $table.year, builder: (column) => column);

  GeneratedColumn<String> get trim =>
      $composableBuilder(column: $table.trim, builder: (column) => column);

  GeneratedColumn<bool> get hasVin =>
      $composableBuilder(column: $table.hasVin, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$VehiclesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $VehiclesTable,
          Vehicle,
          $$VehiclesTableFilterComposer,
          $$VehiclesTableOrderingComposer,
          $$VehiclesTableAnnotationComposer,
          $$VehiclesTableCreateCompanionBuilder,
          $$VehiclesTableUpdateCompanionBuilder,
          (Vehicle, BaseReferences<_$AppDatabase, $VehiclesTable, Vehicle>),
          Vehicle,
          PrefetchHooks Function()
        > {
  $$VehiclesTableTableManager(_$AppDatabase db, $VehiclesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VehiclesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VehiclesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VehiclesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> label = const Value.absent(),
                Value<String?> make = const Value.absent(),
                Value<String?> model = const Value.absent(),
                Value<String?> year = const Value.absent(),
                Value<String?> trim = const Value.absent(),
                Value<bool> hasVin = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VehiclesCompanion(
                id: id,
                label: label,
                make: make,
                model: model,
                year: year,
                trim: trim,
                hasVin: hasVin,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String label,
                Value<String?> make = const Value.absent(),
                Value<String?> model = const Value.absent(),
                Value<String?> year = const Value.absent(),
                Value<String?> trim = const Value.absent(),
                Value<bool> hasVin = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VehiclesCompanion.insert(
                id: id,
                label: label,
                make: make,
                model: model,
                year: year,
                trim: trim,
                hasVin: hasVin,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$VehiclesTable, Vehicle>(table),
                  BaseReferences<_$AppDatabase, $VehiclesTable, Vehicle>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$VehiclesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $VehiclesTable,
      Vehicle,
      $$VehiclesTableFilterComposer,
      $$VehiclesTableOrderingComposer,
      $$VehiclesTableAnnotationComposer,
      $$VehiclesTableCreateCompanionBuilder,
      $$VehiclesTableUpdateCompanionBuilder,
      (Vehicle, BaseReferences<_$AppDatabase, $VehiclesTable, Vehicle>),
      Vehicle,
      PrefetchHooks Function()
    >;
typedef $$RegionSyncsTableCreateCompanionBuilder =
    RegionSyncsCompanion Function({
      Value<int> regionId,
      Value<int> lastChangeId,
      Value<DateTime?> syncedAt,
    });
typedef $$RegionSyncsTableUpdateCompanionBuilder =
    RegionSyncsCompanion Function({
      Value<int> regionId,
      Value<int> lastChangeId,
      Value<DateTime?> syncedAt,
    });

class $$RegionSyncsTableFilterComposer
    extends Composer<_$AppDatabase, $RegionSyncsTable> {
  $$RegionSyncsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get regionId => $composableBuilder(
    column: $table.regionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastChangeId => $composableBuilder(
    column: $table.lastChangeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RegionSyncsTableOrderingComposer
    extends Composer<_$AppDatabase, $RegionSyncsTable> {
  $$RegionSyncsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get regionId => $composableBuilder(
    column: $table.regionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastChangeId => $composableBuilder(
    column: $table.lastChangeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RegionSyncsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RegionSyncsTable> {
  $$RegionSyncsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get regionId =>
      $composableBuilder(column: $table.regionId, builder: (column) => column);

  GeneratedColumn<int> get lastChangeId => $composableBuilder(
    column: $table.lastChangeId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);
}

class $$RegionSyncsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RegionSyncsTable,
          RegionSync,
          $$RegionSyncsTableFilterComposer,
          $$RegionSyncsTableOrderingComposer,
          $$RegionSyncsTableAnnotationComposer,
          $$RegionSyncsTableCreateCompanionBuilder,
          $$RegionSyncsTableUpdateCompanionBuilder,
          (
            RegionSync,
            BaseReferences<_$AppDatabase, $RegionSyncsTable, RegionSync>,
          ),
          RegionSync,
          PrefetchHooks Function()
        > {
  $$RegionSyncsTableTableManager(_$AppDatabase db, $RegionSyncsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RegionSyncsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RegionSyncsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RegionSyncsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> regionId = const Value.absent(),
                Value<int> lastChangeId = const Value.absent(),
                Value<DateTime?> syncedAt = const Value.absent(),
              }) => RegionSyncsCompanion(
                regionId: regionId,
                lastChangeId: lastChangeId,
                syncedAt: syncedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> regionId = const Value.absent(),
                Value<int> lastChangeId = const Value.absent(),
                Value<DateTime?> syncedAt = const Value.absent(),
              }) => RegionSyncsCompanion.insert(
                regionId: regionId,
                lastChangeId: lastChangeId,
                syncedAt: syncedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RegionSyncsTable, RegionSync>(table),
                  BaseReferences<_$AppDatabase, $RegionSyncsTable, RegionSync>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RegionSyncsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RegionSyncsTable,
      RegionSync,
      $$RegionSyncsTableFilterComposer,
      $$RegionSyncsTableOrderingComposer,
      $$RegionSyncsTableAnnotationComposer,
      $$RegionSyncsTableCreateCompanionBuilder,
      $$RegionSyncsTableUpdateCompanionBuilder,
      (
        RegionSync,
        BaseReferences<_$AppDatabase, $RegionSyncsTable, RegionSync>,
      ),
      RegionSync,
      PrefetchHooks Function()
    >;
typedef $$NotificationLogTableCreateCompanionBuilder =
    NotificationLogCompanion Function({
      Value<int> id,
      required int siteId,
      required String channel,
      required String dedupeKey,
      required DateTime sentAt,
    });
typedef $$NotificationLogTableUpdateCompanionBuilder =
    NotificationLogCompanion Function({
      Value<int> id,
      Value<int> siteId,
      Value<String> channel,
      Value<String> dedupeKey,
      Value<DateTime> sentAt,
    });

class $$NotificationLogTableFilterComposer
    extends Composer<_$AppDatabase, $NotificationLogTable> {
  $$NotificationLogTableFilterComposer({
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

  ColumnFilters<String> get channel => $composableBuilder(
    column: $table.channel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dedupeKey => $composableBuilder(
    column: $table.dedupeKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get sentAt => $composableBuilder(
    column: $table.sentAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$NotificationLogTableOrderingComposer
    extends Composer<_$AppDatabase, $NotificationLogTable> {
  $$NotificationLogTableOrderingComposer({
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

  ColumnOrderings<String> get channel => $composableBuilder(
    column: $table.channel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dedupeKey => $composableBuilder(
    column: $table.dedupeKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get sentAt => $composableBuilder(
    column: $table.sentAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$NotificationLogTableAnnotationComposer
    extends Composer<_$AppDatabase, $NotificationLogTable> {
  $$NotificationLogTableAnnotationComposer({
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

  GeneratedColumn<String> get channel =>
      $composableBuilder(column: $table.channel, builder: (column) => column);

  GeneratedColumn<String> get dedupeKey =>
      $composableBuilder(column: $table.dedupeKey, builder: (column) => column);

  GeneratedColumn<DateTime> get sentAt =>
      $composableBuilder(column: $table.sentAt, builder: (column) => column);
}

class $$NotificationLogTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $NotificationLogTable,
          NotificationLogData,
          $$NotificationLogTableFilterComposer,
          $$NotificationLogTableOrderingComposer,
          $$NotificationLogTableAnnotationComposer,
          $$NotificationLogTableCreateCompanionBuilder,
          $$NotificationLogTableUpdateCompanionBuilder,
          (
            NotificationLogData,
            BaseReferences<
              _$AppDatabase,
              $NotificationLogTable,
              NotificationLogData
            >,
          ),
          NotificationLogData,
          PrefetchHooks Function()
        > {
  $$NotificationLogTableTableManager(
    _$AppDatabase db,
    $NotificationLogTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NotificationLogTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NotificationLogTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NotificationLogTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> siteId = const Value.absent(),
                Value<String> channel = const Value.absent(),
                Value<String> dedupeKey = const Value.absent(),
                Value<DateTime> sentAt = const Value.absent(),
              }) => NotificationLogCompanion(
                id: id,
                siteId: siteId,
                channel: channel,
                dedupeKey: dedupeKey,
                sentAt: sentAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int siteId,
                required String channel,
                required String dedupeKey,
                required DateTime sentAt,
              }) => NotificationLogCompanion.insert(
                id: id,
                siteId: siteId,
                channel: channel,
                dedupeKey: dedupeKey,
                sentAt: sentAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$NotificationLogTable, NotificationLogData>(
                    table,
                  ),
                  BaseReferences<
                    _$AppDatabase,
                    $NotificationLogTable,
                    NotificationLogData
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$NotificationLogTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $NotificationLogTable,
      NotificationLogData,
      $$NotificationLogTableFilterComposer,
      $$NotificationLogTableOrderingComposer,
      $$NotificationLogTableAnnotationComposer,
      $$NotificationLogTableCreateCompanionBuilder,
      $$NotificationLogTableUpdateCompanionBuilder,
      (
        NotificationLogData,
        BaseReferences<
          _$AppDatabase,
          $NotificationLogTable,
          NotificationLogData
        >,
      ),
      NotificationLogData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$SitesTableTableManager get sites =>
      $$SitesTableTableManager(_db, _db.sites);
  $$VisitsTableTableManager get visits =>
      $$VisitsTableTableManager(_db, _db.visits);
  $$OutboxEntriesTableTableManager get outboxEntries =>
      $$OutboxEntriesTableTableManager(_db, _db.outboxEntries);
  $$SiteCheckinsTableTableManager get siteCheckins =>
      $$SiteCheckinsTableTableManager(_db, _db.siteCheckins);
  $$UserSettingsTableTableTableManager get userSettingsTable =>
      $$UserSettingsTableTableTableManager(_db, _db.userSettingsTable);
  $$VehiclesTableTableManager get vehicles =>
      $$VehiclesTableTableManager(_db, _db.vehicles);
  $$RegionSyncsTableTableManager get regionSyncs =>
      $$RegionSyncsTableTableManager(_db, _db.regionSyncs);
  $$NotificationLogTableTableManager get notificationLog =>
      $$NotificationLogTableTableManager(_db, _db.notificationLog);
}
