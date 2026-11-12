import 'package:flutter_test/flutter_test.dart';
import 'package:supercharger_bingo/services/write_result.dart';

void main() {
  test('http results separate retry, rejection, and a signed-out session', () {
    expect(writeResultFromHttp(statusCode: 500).outcome, WriteOutcome.retry);
    expect(writeResultFromHttp(statusCode: 400).outcome, WriteOutcome.rejected);
    expect(
      writeResultFromHttp(statusCode: 401).outcome,
      WriteOutcome.needsSignIn,
    );
    expect(
      writeResultFromHttp(
        statusCode: 200,
        body: 'Login to your account',
      ).outcome,
      WriteOutcome.needsSignIn,
    );
    expect(writeResultFromHttp(statusCode: 200).outcome, WriteOutcome.accepted);
    expect(
      writeResultFromHttp(
        statusCode: 302,
        finalUri: 'https://supercharging.life//login.php?required=1',
      ).outcome,
      WriteOutcome.needsSignIn,
    );
    expect(
      writeResultFromHttp(
        statusCode: 302,
        finalUri: 'https://supercharging.life/supercharging/',
      ).outcome,
      WriteOutcome.accepted,
    );

    final now = DateTime(2026, 11, 10, 12);
    expect(pendingReadyToRetry(now, 1, now), isFalse);
    expect(
      pendingReadyToRetry(now.subtract(const Duration(minutes: 1)), 1, now),
      isTrue,
    );
  });
}
