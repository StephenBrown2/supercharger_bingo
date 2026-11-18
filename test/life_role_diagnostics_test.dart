import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:supercharger_bingo/services/life_role_diagnostics.dart';

void main() {
  test('logs only recognized role signals, never arbitrary page values', () {
    final result = formatLifeRoleDiagnostics(
      jsonEncode({
        'ownSite': true,
        'adminLink': true,
        'role': 'administrator',
        'isAdmin': false,
        'userRole': 'private@example.com',
        'cookie': 'secret-cookie',
        'token': 'secret-token',
        'name': 'Private Person',
      }),
    );
    expect(jsonDecode(result!), {
      'adminLink': true,
      'role': 'administrator',
      'isAdmin': false,
      'userRole': 'present',
    });
    expect(result, isNot(contains('secret')));
    expect(result, isNot(contains('Private')));
    expect(result, isNot(contains('@')));
  });

  test('handles doubly encoded WebView results and hides complex values', () {
    final result = formatLifeRoleDiagnostics(
      jsonEncode(
        jsonEncode({
          'ownSite': true,
          'role': {'token': 'secret'},
          'isAdmin': 1,
        }),
      ),
    );
    expect(jsonDecode(result!), {'role': 'present', 'isAdmin': 1});
  });

  test('ignores provider pages, malformed results and missing site guard', () {
    for (final raw in [
      'null',
      '{}',
      'broken',
      '{"ownSite":false,"role":"admin"}',
    ]) {
      expect(formatLifeRoleDiagnostics(raw), isNull);
    }
  });
}
