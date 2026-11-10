import 'api_service.dart';
import 'checkin_form.dart';
import 'write_result.dart';

/// Backend writer for a check-in (SPEC Section 2.2).
///
/// The unofficial `checkin.php` post and a future official API both implement
/// this, so sync and the dialog do not care which one is active.
abstract class CheckinWriter {
  Future<WriteResult> submit(CheckinDraft draft);
}

/// POC writer: multipart POST to supercharging.life `checkin.php`.
class UnofficialCheckinWriter implements CheckinWriter {
  final ApiService _api;

  UnofficialCheckinWriter(this._api);

  @override
  Future<WriteResult> submit(CheckinDraft draft) => _api.submitCheckin(draft);
}
