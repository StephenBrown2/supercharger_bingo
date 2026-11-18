import '../database/database.dart';

enum MapSiteType {
  all('All types'),
  v2('V2'),
  v3('V3'),
  v4('V4'),
  urban('Urban'),
  unknown('Unknown');

  const MapSiteType(this.label);
  final String label;

  bool matches(Site site) => switch (this) {
    all => true,
    v2 => site.stallsV2 > 0,
    v3 => site.stallsV3 > 0,
    v4 => site.stallsV4 > 0,
    urban => site.stallsUrban > 0,
    unknown =>
      site.stallsOther > 0 ||
          (site.stallsV2 <= 0 &&
              site.stallsV3 <= 0 &&
              site.stallsV4 <= 0 &&
              site.stallsUrban <= 0),
  };
}
