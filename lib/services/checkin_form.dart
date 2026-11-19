import '../database/database.dart';
import 'life_time.dart';

/// One check-in ready for whichever [CheckinWriter] is active.
class CheckinDraft {
  final int siteId;
  final DateTime checkinAt;
  final CheckinPrecision precision;
  final double? latitude;
  final double? longitude;
  final double? accuracy;
  final String? notesPublic;
  final String? notesPrivate;

  /// supercharging.life user id, sent only when the session knows it.
  final int? userId;

  const CheckinDraft({
    required this.siteId,
    required this.checkinAt,
    required this.precision,
    this.latitude,
    this.longitude,
    this.accuracy,
    this.notesPublic,
    this.notesPrivate,
    this.userId,
  });
}

/// Field names from the logged-in `checkin.php` form.
///
/// `destination` asks for the check-in detail page, so the redirect carries
/// the new check-in id. Vehicle ids and VINs are never sent. Coordinates use the input names, not the script's swapped id.
Map<String, String> unofficialCheckinFields(CheckinDraft draft) {
  final fields = <String, String>{
    'supercharger_id': draft.siteId.toString(),
    'date': formatLifeDateField(draft.checkinAt, precision: draft.precision),
    'destination': 'checkin_detail',
  };
  if (draft.userId != null) {
    fields['user_id'] = draft.userId.toString();
  }
  final publicNote = draft.notesPublic;
  if (publicNote != null && publicNote.isNotEmpty) {
    fields['notes_public'] = publicNote;
  }
  final privateNote = draft.notesPrivate;
  if (privateNote != null && privateNote.isNotEmpty) {
    fields['notes_private'] = privateNote;
  }
  if (draft.latitude != null && draft.longitude != null) {
    fields['log_coords_lat'] = draft.latitude.toString();
    fields['log_coords_lon'] = draft.longitude.toString();
    if (draft.accuracy != null) {
      fields['log_coords_accuracy'] = draft.accuracy.toString();
    }
  }
  return fields;
}

/// The new check-in id from the form's redirect to
/// `/supercharging/checkin_detail.php?id=N`, or null for any other target.
int? checkinIdFromRedirect(String? location) {
  final uri = location == null ? null : Uri.tryParse(location);
  if (uri == null || !uri.path.endsWith('checkin_detail.php')) return null;
  return int.tryParse(uri.queryParameters['id'] ?? '');
}
