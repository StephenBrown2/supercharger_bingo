import 'dart:convert';

import '../database/database.dart';

/// supercharging.life starts OAuth at oauth.php?provider=GitHub|Google and
/// sends the browser back to that same URL. The session cookie is SCLSESSION.
Uri lifeAuthorizeUri(AuthProvider provider) {
  final name = switch (provider) {
    AuthProvider.github => 'GitHub',
    AuthProvider.google => 'Google',
  };
  return Uri.https('supercharging.life', '/oauth.php', {'provider': name});
}

String authProviderLabel(AuthProvider provider) {
  return switch (provider) {
    AuthProvider.github => 'GitHub',
    AuthProvider.google => 'Google',
  };
}

/// What the in-app browser found on the latest page.
class LifePageProbe {
  final String? sessionId;
  final String? displayName;
  final bool blocked;
  final Uri? page;

  const LifePageProbe({
    this.sessionId,
    this.displayName,
    this.blocked = false,
    this.page,
  });

  bool get signedIn {
    final host = page?.host ?? '';
    final name = displayName?.trim() ?? '';
    if (!host.endsWith('supercharging.life')) return false;
    if (sessionId == null || sessionId!.isEmpty) return false;
    if (name.isEmpty || name == 'Guest') return false;
    return true;
  }

  static LifePageProbe parse(String raw) {
    var text = raw.trim();
    if (text.isEmpty) return const LifePageProbe();
    try {
      final decoded = jsonDecode(text);
      if (decoded is String) text = decoded;
      if (decoded is Map) return _fromMap(decoded);
    } catch (_) {}
    try {
      final decoded = jsonDecode(text);
      if (decoded is Map) return _fromMap(decoded);
    } catch (_) {}
    return LifePageProbe(sessionId: readSessionCookie(text));
  }

  static LifePageProbe _fromMap(Map<dynamic, dynamic> json) {
    final href = json['href']?.toString();
    return LifePageProbe(
      sessionId: readSessionCookie(json['cookie']?.toString() ?? ''),
      displayName: json['name']?.toString(),
      blocked: json['blocked'] == true,
      page: href == null ? null : Uri.tryParse(href),
    );
  }
}

/// Pull SCLSESSION out of a `document.cookie` string. The live cookie is not
/// HttpOnly, so the page can see it.
String? readSessionCookie(String cookieHeader) {
  final cleaned = cookieHeader.replaceAll('"', '').trim();
  for (final part in cleaned.split(';')) {
    final bits = part.trim().split('=');
    if (bits.length >= 2 && bits.first == lifeSessionCookieName) {
      final value = bits.sublist(1).join('=').trim();
      if (value.isNotEmpty) return value;
    }
  }
  return null;
}

const lifeSessionCookieName = 'SCLSESSION';

/// Runs in the webview after each page load. Returns JSON.
const lifePageProbeScript = r'''
(function() {
  var name = '';
  var nameEl = document.querySelector('.nav-item.dropdown .d-xl-block div');
  if (nameEl) name = (nameEl.textContent || '').trim();
  var text = document.body ? document.body.innerText : '';
  var href = location.href || '';
  var blocked = /disallowed_useragent|Couldn't sign you in|This browser or app may not be secure/i.test(text)
    || href.indexOf('disallowed_useragent') !== -1;
  return JSON.stringify({
    cookie: document.cookie || '',
    name: name,
    blocked: blocked,
    href: href
  });
})()
''';
