import '../database/database.dart';

/// Parse a supercharging.life timestamp.
///
/// History rows use a space and a short offset, for example
/// `2026-11-10 00:05:53-05`. Dart's parser wants `T` and `±HH:mm`.
DateTime? parseLifeTimestamp(String? raw) {
  if (raw == null) return null;
  var value = raw.trim();
  if (value.isEmpty) return null;
  value = value.replaceFirst(' ', 'T');
  value = value.replaceFirstMapped(
    RegExp(r'([+-]\d{2})(\d{2})$'),
    (match) => '${match[1]}:${match[2]}',
  );
  value = value.replaceFirstMapped(
    RegExp(r'([+-]\d{2})$'),
    (match) => '${match[1]}:00',
  );
  try {
    return DateTime.parse(value);
  } catch (_) {
    return null;
  }
}

/// Format the live check-in form's `date` field.
///
/// TIMESTAMP matches `dayjs` `YYYY-MM-DD HH:mm:ssZ`. DATE_ONLY is the calendar
/// date shown on Check-in Detail.
String formatLifeDateField(
  DateTime instant, {
  required CheckinPrecision precision,
}) {
  final year = instant.year.toString().padLeft(4, '0');
  final month = instant.month.toString().padLeft(2, '0');
  final day = instant.day.toString().padLeft(2, '0');
  final date = '$year-$month-$day';
  if (precision == CheckinPrecision.dateOnly) return date;

  final hour = instant.hour.toString().padLeft(2, '0');
  final minute = instant.minute.toString().padLeft(2, '0');
  final second = instant.second.toString().padLeft(2, '0');
  final offset = instant.timeZoneOffset;
  final sign = offset.isNegative ? '-' : '+';
  final totalMinutes = offset.abs().inMinutes;
  final offsetHour = (totalMinutes ~/ 60).toString().padLeft(2, '0');
  final offsetMinute = (totalMinutes % 60).toString().padLeft(2, '0');
  return '$date $hour:$minute:$second$sign$offsetHour:$offsetMinute';
}

String formatCalendarDate(DateTime date) {
  final year = date.year.toString().padLeft(4, '0');
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '$year-$month-$day';
}
