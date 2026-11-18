import 'dart:convert';

const lifeRoleDiagnosticsEnabled = bool.fromEnvironment(
  'LIFE_ROLE_DIAGNOSTICS',
);

const _roleFields = [
  'role',
  'userRole',
  'user_role',
  'isAdmin',
  'is_admin',
  'admin',
  'canReviewCheckins',
  'can_review_checkins',
  'canModerateCheckins',
];
const _roleObjects = ['', 'currentUser', 'user', 'auth', 'session'];
const _roleWords = {
  'admin',
  'administrator',
  'superadmin',
  'moderator',
  'staff',
  'owner',
  'user',
  'regular',
  'member',
  'guest',
};

/// No raw WebView output crosses the logging boundary.
String? formatLifeRoleDiagnostics(String raw) {
  try {
    dynamic value = jsonDecode(raw);
    if (value is String) value = jsonDecode(value);
    if (value is! Map || value['ownSite'] != true) return null;
    final safe = <String, Object>{};
    if (value['adminLink'] is bool) safe['adminLink'] = value['adminLink'];
    for (final source in [..._roleObjects, 'body', 'html']) {
      for (final field in _roleFields) {
        final key = source.isEmpty ? field : '$source.$field';
        if (!value.containsKey(key)) continue;
        final signal = value[key];
        safe[key] = switch (signal) {
          bool b => b,
          int n when n == 0 || n == 1 => n,
          String s when _roleWords.contains(s.toLowerCase()) => s.toLowerCase(),
          _ => 'present',
        };
      }
    }
    return jsonEncode(safe);
  } catch (_) {
    return null;
  }
}

// shortcut: these are candidate page signals, not verified authorization claims.
final lifeRoleProbeScript =
    '''
(function() {
  if (location.hostname !== 'supercharging.life') return null;
  var result = {ownSite: true};
  var fields = ${jsonEncode(_roleFields)};
  var sources = ${jsonEncode(_roleObjects)};
  var words = ${jsonEncode(_roleWords.toList())};
  function own(object, key) {
    if (!object) return undefined;
    var descriptor = Object.getOwnPropertyDescriptor(object, key);
    return descriptor && descriptor.value;
  }
  function add(key, value) {
    if (value === undefined || value === null) return;
    var lower = typeof value === 'string' ? value.toLowerCase() : '';
    result[key] = typeof value === 'boolean' || value === 0 || value === 1
      ? value : words.indexOf(lower) >= 0 ? lower : 'present';
  }
  sources.forEach(function(source) {
    var object = source ? own(window, source) : window;
    fields.forEach(function(field) {
      add(source ? source + '.' + field : field, own(object, field));
    });
  });
  [['body', document.body], ['html', document.documentElement]].forEach(function(pair) {
    if (!pair[1]) return;
    fields.forEach(function(field) {
      var attribute = 'data-' + field.replace(/[A-Z]/g, function(c) { return '-' + c.toLowerCase(); }).replace(/_/g, '-');
      add(pair[0] + '.' + field, pair[1].getAttribute(attribute));
    });
  });
  result.adminLink = Array.from(document.querySelectorAll('nav a, .navbar a')).some(function(a) {
    return /^(admin|administration|moderation)\u0024/i.test((a.textContent || '').trim())
      || /\\/(admin|moderation)(\\/|\\.php|\u0024)/i.test(a.pathname || '');
  });
  return JSON.stringify(result);
})()
''';
