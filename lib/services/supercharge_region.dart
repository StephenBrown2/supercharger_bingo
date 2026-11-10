/// supercharge.info region ids from the reference data (100-103).
/// Boxes overlap, so this is the classifier that matched the live site list.
class SuperchargeRegion {
  static const int northAmerica = 100;
  static const int europe = 101;
  static const int asiaPacific = 102;
  static const int southAmerica = 103;

  /// Region for a coordinate. Levant sites that sit inside Europe's box are
  /// Asia Pacific, matching the live region ids.
  static int forCoordinates(double latitude, double longitude) {
    if (latitude <= 34 && longitude >= 34 && longitude < 40) {
      return asiaPacific;
    }
    if (latitude <= 13.5 && longitude >= -85 && longitude <= -34) {
      return southAmerica;
    }
    if (longitude <= -50 || (latitude >= 14 && longitude <= -30)) {
      return northAmerica;
    }
    if (longitude >= -30 && longitude < 40 && latitude >= 25) {
      return europe;
    }
    return asiaPacific;
  }
}
