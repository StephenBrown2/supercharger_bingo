import '../database/database.dart';
import 'life_time.dart';
import 'timezone_service.dart';

/// True when [checkinAt] precedes the earliest known site opening day.
///
/// A null open date cannot be rejected. DATE_ONLY uses the stored calendar
/// date as-is. TIMESTAMP is converted into the site's IANA zone first.
/// The opening date is compared on its own year, month, and day.
bool checkinPrecedesOpening(
  Site site,
  DateTime checkinAt, {
  CheckinPrecision precision = CheckinPrecision.timestamp,
}) {
  final opened = site.firstOpeningDay;
  if (opened == null) return false;

  // Opening dates are date-only values stored as UTC midnight. Reading them
  // in a negative offset shifts the local calendar to the previous day, so
  // the open day is the UTC year/month/day.
  final openDay = _calendarDay(opened.toUtc());
  final DateTime checkinDay;
  if (precision == CheckinPrecision.dateOnly) {
    checkinDay = _calendarDay(checkinAt.toUtc());
  } else {
    final local = TimezoneService.instance.localTime(site, checkinAt);
    checkinDay = _calendarDay(local);
  }
  return checkinDay.isBefore(openDay);
}

DateTime _calendarDay(DateTime value) =>
    DateTime(value.year, value.month, value.day);

/// User-facing rejection, or null when the check-in is allowed.
String? checkinOpeningRejection(
  Site site,
  DateTime checkinAt, {
  CheckinPrecision precision = CheckinPrecision.timestamp,
}) {
  if (!checkinPrecedesOpening(site, checkinAt, precision: precision)) {
    return null;
  }
  final opened = site.firstOpeningDay!.toUtc();
  return 'This site opens on ${formatCalendarDate(opened)}. '
      'A check-in before then is not valid.';
}
