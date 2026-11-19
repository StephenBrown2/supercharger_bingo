// Shared parsers for the supercharge.info allSites and allChanges payloads.
// Nested types (status, country, region, address, gps, stalls) are defined once.
// ignore_for_file: constant_identifier_names

import 'dart:convert';

List<AllSites> allSitesFromJson(String str) =>
    List<AllSites>.from(json.decode(str).map((x) => AllSites.fromJson(x)));

String allSitesToJson(List<AllSites> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class AllSites {
  int id;
  String? locationId;
  String name;
  Status status;
  Address address;
  Gps gps;
  DateTime? dateOpened;
  int stallCount;
  bool counted;
  int elevationMeters;
  int powerKilowatt;
  bool solarCanopy;
  bool battery;
  bool otherEVs;
  int statusDays;
  bool urlDiscuss;
  Stalls? stalls;
  Map<String, int>? plugs;
  int? parkingId;
  String? facilityName;
  int? plugshareId;
  int? osmId;
  String? facilityHours;
  String? addressNotes;
  String? hours;
  String? accessNotes;

  AllSites({
    required this.id,
    this.locationId,
    required this.name,
    required this.status,
    required this.address,
    required this.gps,
    this.dateOpened,
    required this.stallCount,
    required this.counted,
    required this.elevationMeters,
    required this.powerKilowatt,
    required this.solarCanopy,
    required this.battery,
    required this.otherEVs,
    required this.statusDays,
    required this.urlDiscuss,
    this.stalls,
    this.plugs,
    this.parkingId,
    this.facilityName,
    this.plugshareId,
    this.osmId,
    this.facilityHours,
    this.addressNotes,
    this.hours,
    this.accessNotes,
  });

  factory AllSites.fromJson(Map<String, dynamic> json) => AllSites(
    id: json["id"],
    locationId: json["locationId"],
    name: json["name"],
    status: statusValues.map[json["status"]]!,
    address: Address.fromJson(json["address"]),
    gps: Gps.fromJson(json["gps"]),
    dateOpened: json["dateOpened"] == null
        ? null
        : DateTime.parse(json["dateOpened"]),
    stallCount: json["stallCount"],
    counted: json["counted"],
    elevationMeters: json["elevationMeters"],
    powerKilowatt: json["powerKilowatt"],
    solarCanopy: json["solarCanopy"],
    battery: json["battery"],
    otherEVs: json["otherEVs"],
    statusDays: json["statusDays"],
    urlDiscuss: json["urlDiscuss"],
    stalls: json["stalls"] == null ? null : Stalls.fromJson(json["stalls"]),
    plugs: json["plugs"] == null
        ? null
        : Map.from(json["plugs"]).map((k, v) => MapEntry<String, int>(k, v)),
    parkingId: json["parkingId"],
    facilityName: json["facilityName"],
    plugshareId: json["plugshareId"],
    osmId: json["osmId"],
    facilityHours: json["facilityHours"],
    addressNotes: json["addressNotes"],
    hours: json["hours"],
    accessNotes: json["accessNotes"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "locationId": locationId,
    "name": name,
    "status": statusValues.reverse[status],
    "address": address.toJson(),
    "gps": gps.toJson(),
    "dateOpened": dateOpened == null
        ? null
        : "${dateOpened!.year.toString().padLeft(4, '0')}-${dateOpened!.month.toString().padLeft(2, '0')}-${dateOpened!.day.toString().padLeft(2, '0')}",
    "stallCount": stallCount,
    "counted": counted,
    "elevationMeters": elevationMeters,
    "powerKilowatt": powerKilowatt,
    "solarCanopy": solarCanopy,
    "battery": battery,
    "otherEVs": otherEVs,
    "statusDays": statusDays,
    "urlDiscuss": urlDiscuss,
    "stalls": stalls?.toJson(),
    "plugs": plugs == null
        ? null
        : Map.from(plugs!).map((k, v) => MapEntry<String, dynamic>(k, v)),
    "parkingId": parkingId,
    "facilityName": facilityName,
    "plugshareId": plugshareId,
    "osmId": osmId,
    "facilityHours": facilityHours,
    "addressNotes": addressNotes,
    "hours": hours,
    "accessNotes": accessNotes,
  };
}

class Address {
  String street;
  String city;
  String? state;
  String? zip;
  int countryId;
  Country country;
  int regionId;
  Region region;

  Address({
    required this.street,
    required this.city,
    required this.state,
    required this.zip,
    required this.countryId,
    required this.country,
    required this.regionId,
    required this.region,
  });

  factory Address.fromJson(Map<String, dynamic> json) => Address(
    street: json["street"],
    city: json["city"],
    state: json["state"],
    zip: json["zip"],
    countryId: json["countryId"],
    country: countryValues.map[json["country"]]!,
    regionId: json["regionId"],
    region: regionValues.map[json["region"]]!,
  );

  Map<String, dynamic> toJson() => {
    "street": street,
    "city": city,
    "state": state,
    "zip": zip,
    "countryId": countryId,
    "country": countryValues.reverse[country],
    "regionId": regionId,
    "region": regionValues.reverse[region],
  };
}

enum Country {
  AUSTRALIA,
  AUSTRIA,
  BELGIUM,
  BOSNIA_AND_HERZEGOVINA,
  BULGARIA,
  CANADA,
  CHILE,
  CHINA,
  COLOMBIA,
  CROATIA,
  CZECH_REPUBLIC,
  DENMARK,
  ESTONIA,
  FINLAND,
  FRANCE,
  GERMANY,
  GREECE,
  HUNGARY,
  ICELAND,
  INDIA,
  IRELAND,
  ISRAEL,
  ITALY,
  JAPAN,
  JORDAN,
  KAZAKHSTAN,
  LATVIA,
  LIECHTENSTEIN,
  LITHUANIA,
  LUXEMBOURG,
  MALAYSIA,
  MEXICO,
  MOROCCO,
  NETHERLANDS,
  NEW_ZEALAND,
  NORWAY,
  OMAN,
  PHILIPPINES,
  POLAND,
  PORTUGAL,
  QATAR,
  ROMANIA,
  SAUDI_ARABIA,
  SERBIA,
  SINGAPORE,
  SLOVAKIA,
  SLOVENIA,
  SOUTH_KOREA,
  SPAIN,
  SWEDEN,
  SWITZERLAND,
  TAIWAN,
  THAILAND,
  TURKEY,
  UNITED_ARAB_EMIRATES,
  UNITED_KINGDOM,
  URUGUAY,
  USA,
}

final countryValues = EnumValues({
  "Australia": Country.AUSTRALIA,
  "Austria": Country.AUSTRIA,
  "Belgium": Country.BELGIUM,
  "Bosnia and Herzegovina": Country.BOSNIA_AND_HERZEGOVINA,
  "Bulgaria": Country.BULGARIA,
  "Canada": Country.CANADA,
  "Chile": Country.CHILE,
  "China": Country.CHINA,
  "Colombia": Country.COLOMBIA,
  "Croatia": Country.CROATIA,
  "Czech Republic": Country.CZECH_REPUBLIC,
  "Denmark": Country.DENMARK,
  "Estonia": Country.ESTONIA,
  "Finland": Country.FINLAND,
  "France": Country.FRANCE,
  "Germany": Country.GERMANY,
  "Greece": Country.GREECE,
  "Hungary": Country.HUNGARY,
  "Iceland": Country.ICELAND,
  "India": Country.INDIA,
  "Ireland": Country.IRELAND,
  "Israel": Country.ISRAEL,
  "Italy": Country.ITALY,
  "Japan": Country.JAPAN,
  "Jordan": Country.JORDAN,
  "Kazakhstan": Country.KAZAKHSTAN,
  "Latvia": Country.LATVIA,
  "Liechtenstein": Country.LIECHTENSTEIN,
  "Lithuania": Country.LITHUANIA,
  "Luxembourg": Country.LUXEMBOURG,
  "Malaysia": Country.MALAYSIA,
  "Mexico": Country.MEXICO,
  "Morocco": Country.MOROCCO,
  "Netherlands": Country.NETHERLANDS,
  "New Zealand": Country.NEW_ZEALAND,
  "Norway": Country.NORWAY,
  "Oman": Country.OMAN,
  "Philippines": Country.PHILIPPINES,
  "Poland": Country.POLAND,
  "Portugal": Country.PORTUGAL,
  "Qatar": Country.QATAR,
  "Romania": Country.ROMANIA,
  "Saudi Arabia": Country.SAUDI_ARABIA,
  "Serbia": Country.SERBIA,
  "Singapore": Country.SINGAPORE,
  "Slovakia": Country.SLOVAKIA,
  "Slovenia": Country.SLOVENIA,
  "South Korea": Country.SOUTH_KOREA,
  "Spain": Country.SPAIN,
  "Sweden": Country.SWEDEN,
  "Switzerland": Country.SWITZERLAND,
  "Taiwan": Country.TAIWAN,
  "Thailand": Country.THAILAND,
  "Turkey": Country.TURKEY,
  "United Arab Emirates": Country.UNITED_ARAB_EMIRATES,
  "United Kingdom": Country.UNITED_KINGDOM,
  "Uruguay": Country.URUGUAY,
  "USA": Country.USA,
});

enum Region { ASIA_PACIFIC, EUROPE, NORTH_AMERICA, SOUTH_AMERICA }

final regionValues = EnumValues({
  "Asia Pacific": Region.ASIA_PACIFIC,
  "Europe": Region.EUROPE,
  "North America": Region.NORTH_AMERICA,
  "South America": Region.SOUTH_AMERICA,
});

class Gps {
  double latitude;
  double longitude;

  Gps({required this.latitude, required this.longitude});

  factory Gps.fromJson(Map<String, dynamic> json) => Gps(
    latitude: json["latitude"]?.toDouble(),
    longitude: json["longitude"]?.toDouble(),
  );

  Map<String, dynamic> toJson() => {
    "latitude": latitude,
    "longitude": longitude,
  };
}

class Stalls {
  int? v3;
  int? v4;
  int? trailerFriendly;
  int? accessible;
  int? v2;
  int? urban;
  int? other;

  Stalls({
    this.v3,
    this.v4,
    this.trailerFriendly,
    this.accessible,
    this.v2,
    this.urban,
    this.other,
  });

  factory Stalls.fromJson(Map<String, dynamic> json) => Stalls(
    v3: json["v3"],
    v4: json["v4"],
    trailerFriendly: json["trailerFriendly"],
    accessible: json["accessible"],
    v2: json["v2"],
    urban: json["urban"],
    other: json["other"],
  );

  Map<String, dynamic> toJson() => {
    "v3": v3,
    "v4": v4,
    "trailerFriendly": trailerFriendly,
    "accessible": accessible,
    "v2": v2,
    "urban": urban,
    "other": other,
  };
}

enum Status {
  CLOSED_PERM,
  CLOSED_TEMP,
  CONSTRUCTION,
  OPEN,
  PERMIT,
  PLAN,
  VOTING,
}

final statusValues = EnumValues({
  "CLOSED_PERM": Status.CLOSED_PERM,
  "CLOSED_TEMP": Status.CLOSED_TEMP,
  "CONSTRUCTION": Status.CONSTRUCTION,
  // supercharging.life shows an EXPANDING site as OPEN, and so does the app.
  // Keep this key before "OPEN" so [EnumValues.reverse] writes "OPEN".
  "EXPANDING": Status.OPEN,
  "OPEN": Status.OPEN,
  "PERMIT": Status.PERMIT,
  "PLAN": Status.PLAN,
  "VOTING": Status.VOTING,
});

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}

List<AllChanges> allChangesFromJson(String str) =>
    List<AllChanges>.from(json.decode(str).map((x) => AllChanges.fromJson(x)));

String allChangesToJson(List<AllChanges> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class AllChanges {
  int id;
  int siteId;
  DateTime date;
  ChangeType changeType;
  Status siteStatus;
  Status? prevStatus;
  int stallCount;
  int prevCount;
  int powerKilowatt;
  bool notify;
  String siteName;
  int regionId;
  Region region;
  int countryId;
  Country country;
  String? state;
  AllSites site;
  String dateFormatted;

  AllChanges({
    required this.id,
    required this.siteId,
    required this.date,
    required this.changeType,
    required this.siteStatus,
    required this.prevStatus,
    required this.stallCount,
    required this.prevCount,
    required this.powerKilowatt,
    required this.notify,
    required this.siteName,
    required this.regionId,
    required this.region,
    required this.countryId,
    required this.country,
    required this.state,
    required this.site,
    required this.dateFormatted,
  });

  factory AllChanges.fromJson(Map<String, dynamic> json) => AllChanges(
    id: json["id"],
    siteId: json["siteId"],
    date: DateTime.parse(json["date"]),
    changeType: changeTypeValues.map[json["changeType"]]!,
    siteStatus: statusValues.map[json["siteStatus"]]!,
    prevStatus: statusValues.map[json["prevStatus"]],
    stallCount: json["stallCount"],
    prevCount: json["prevCount"],
    powerKilowatt: json["powerKilowatt"],
    notify: json["notify"],
    siteName: json["siteName"],
    regionId: json["regionId"],
    region: regionValues.map[json["region"]]!,
    countryId: json["countryId"],
    country: countryValues.map[json["country"]]!,
    state: json["state"],
    site: AllSites.fromJson(json["site"]),
    dateFormatted: json["dateFormatted"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "siteId": siteId,
    "date":
        "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}",
    "changeType": changeTypeValues.reverse[changeType],
    "siteStatus": statusValues.reverse[siteStatus],
    "prevStatus": statusValues.reverse[prevStatus],
    "stallCount": stallCount,
    "prevCount": prevCount,
    "powerKilowatt": powerKilowatt,
    "notify": notify,
    "siteName": siteName,
    "regionId": regionId,
    "region": regionValues.reverse[region],
    "countryId": countryId,
    "country": countryValues.reverse[country],
    "state": state,
    "site": site.toJson(),
    "dateFormatted": dateFormatted,
  };
}

enum ChangeType { ADD, UPDATE }

final changeTypeValues = EnumValues({
  "ADD": ChangeType.ADD,
  "UPDATE": ChangeType.UPDATE,
});
