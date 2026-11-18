import 'api_service.dart';
import 'checkin_form.dart';
import 'write_result.dart';

/// Backend writer for a check-in (SPEC Section 2.2).
///
/// The unofficial `checkin.php` post and a future official API both implement
/// this, so the Check-in outbox does not care which one is active. A writer
/// never answers [WriteOutcome.rejected]: supercharging.life does not refuse
/// check-ins, so a response it cannot read is retried.
abstract class CheckinWriter {
  Future<WriteResult> submit(CheckinDraft draft);
}

/// POC writer: multipart POST to supercharging.life `checkin.php`.
class UnofficialCheckinWriter implements CheckinWriter {
  final ApiService _api;

  UnofficialCheckinWriter(this._api);

  @override
  Future<WriteResult> submit(CheckinDraft draft) async {
    final result = await _api.submitCheckin(draft);
    if (result.outcome != WriteOutcome.rejected) return result;
    return const WriteResult(
      WriteOutcome.retry,
      'supercharging.life sent an unexpected answer, will retry',
    );
  }
}
