import '../database/database.dart';
import 'timezone_service.dart';

/// The calendar day of a Check-in at [site].
///
/// DATE_ONLY values are calendar dates stored as UTC midnight, so the day is
/// their UTC year, month and day. TIMESTAMP is converted into the site's IANA
/// zone first.
DateTime siteLocalDay(
  Site site,
  DateTime at, {
  CheckinPrecision precision = CheckinPrecision.timestamp,
}) {
  if (precision == CheckinPrecision.dateOnly) return _calendarDay(at.toUtc());
  return _calendarDay(TimezoneService.instance.localTime(site, at));
}

/// True when [checkinAt] precedes the site's Opening date.
///
/// A null Opening date cannot be rejected. The Opening date is date-only, so
/// it is compared on its own UTC year, month, and day.
bool checkinPrecedesOpening(
  Site site,
  DateTime checkinAt, {
  CheckinPrecision precision = CheckinPrecision.timestamp,
}) {
  final opened = site.firstOpeningDay;
  if (opened == null) return false;
  return siteLocalDay(
    site,
    checkinAt,
    precision: precision,
  ).isBefore(_calendarDay(opened.toUtc()));
}

DateTime _calendarDay(DateTime value) =>
    DateTime(value.year, value.month, value.day);
