/// Outcome of one check-in post (SPEC Section 13, Phase 5).
enum WriteOutcome {
  /// The writer accepted the check-in.
  accepted,

  /// The site refused the check-in. Do not retry.
  rejected,

  /// Network or server trouble. Leave it pending and try later.
  retry,

  /// The SCLSESSION is missing or expired. The user has to sign in again.
  needsSignIn,
}

class WriteResult {
  final WriteOutcome outcome;
  final String? message;

  const WriteResult(this.outcome, [this.message]);

  static const accepted = WriteResult(WriteOutcome.accepted);
  static const rejected = WriteResult(
    WriteOutcome.rejected,
    'Check-in was rejected',
  );
  static const retry = WriteResult(
    WriteOutcome.retry,
    'Network error, will retry',
  );
  static const needsSignIn = WriteResult(
    WriteOutcome.needsSignIn,
    signInAgainMessage,
  );
}

/// Pending row is waiting for a session that has not been captured yet.
const waitingForSignInMessage = 'Waiting for supercharging.life sign-in';

/// A stored session was rejected. The map asks the user to sign in again.
const signInAgainMessage = 'Sign in to supercharging.life again';

/// Minutes to wait after each failed attempt: 1, 5, 15, 60, then 4 hours.
const pendingRetryMinutes = [1, 5, 15, 60, 240];

Duration pendingRetryDelay(int attempts) {
  if (attempts <= 0) return Duration.zero;
  final index = (attempts - 1).clamp(0, pendingRetryMinutes.length - 1);
  return Duration(minutes: pendingRetryMinutes[index]);
}

/// True when [now] is far enough past [lastAttemptAt] to post again.
bool pendingReadyToRetry(DateTime? lastAttemptAt, int attempts, DateTime now) {
  if (lastAttemptAt == null || attempts <= 0) return true;
  return !now.isBefore(lastAttemptAt.add(pendingRetryDelay(attempts)));
}

bool looksLikeSignedOut({String? body, String? finalUri, int? statusCode}) {
  if (statusCode == 401 || statusCode == 403) return true;
  if (body != null && body.contains('Login to your account')) return true;
  if (finalUri != null && finalUri.contains('login.php')) return true;
  return false;
}

WriteResult writeResultFromHttp({
  required int? statusCode,
  String? body,
  String? finalUri,
}) {
  if (looksLikeSignedOut(
    body: body,
    finalUri: finalUri,
    statusCode: statusCode,
  )) {
    return WriteResult.needsSignIn;
  }
  if (statusCode == null ||
      statusCode == 408 ||
      statusCode == 429 ||
      statusCode >= 500) {
    return WriteResult.retry;
  }
  if (statusCode != 200) return WriteResult.rejected;
  return WriteResult.accepted;
}
