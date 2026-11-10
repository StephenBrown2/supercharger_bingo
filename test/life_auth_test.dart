import 'package:flutter_test/flutter_test.dart';
import 'package:supercharger_bingo/database/database.dart';
import 'package:supercharger_bingo/services/life_auth.dart';

void main() {
  test('authorize urls use the live provider names', () {
    expect(
      lifeAuthorizeUri(AuthProvider.github).toString(),
      'https://supercharging.life/oauth.php?provider=GitHub',
    );
    expect(
      lifeAuthorizeUri(AuthProvider.google).queryParameters['provider'],
      'Google',
    );
  });

  test('a guest session cookie is not a completed sign-in', () {
    final probe = LifePageProbe.parse(
      '{"cookie":"SCLSESSION=abc","name":"Guest","blocked":false,'
      '"href":"https://supercharging.life/supercharging/"}',
    );
    expect(probe.sessionId, 'abc');
    expect(probe.signedIn, isFalse);
  });

  test('a named session on supercharging.life is a completed sign-in', () {
    const raw =
        '"{\\"cookie\\":\\"SCLSESSION=deadbeef; other=1\\",\\"name\\":\\"Ada\\",'
        '\\"blocked\\":false,\\"href\\":\\"https://supercharging.life/supercharging/\\"}"';
    final probe = LifePageProbe.parse(raw);
    expect(probe.sessionId, 'deadbeef');
    expect(probe.displayName, 'Ada');
    expect(probe.signedIn, isTrue);
  });

  test('a provider block is reported and is not a sign-in', () {
    final probe = LifePageProbe.parse(
      '{"cookie":"","name":"","blocked":true,'
      '"href":"https://accounts.google.com/signin/oauth/error?authError=disallowed_useragent"}',
    );
    expect(probe.blocked, isTrue);
    expect(probe.signedIn, isFalse);
  });

  test('a bare cookie header still yields the session id', () {
    expect(
      LifePageProbe.parse('SCLSESSION=abc123; theme=dark').sessionId,
      'abc123',
    );
  });
}
