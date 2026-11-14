import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart' show MethodChannel;

import '../database/database.dart';

const _channel = MethodChannel('supercharger_bingo/navigate');

/// Only Android has the native side so far.
bool get canNavigateToSite => !kIsWeb && Platform.isAndroid;

/// Open [site] in a navigation app (Google Maps, Waze, Tesla, ...).
/// False when no installed app can take it.
Future<bool> navigateToSite(Site site) async {
  if (!canNavigateToSite) return false;
  return await _channel.invokeMethod<bool>('navigate', {
        'latitude': site.latitude,
        'longitude': site.longitude,
        'label': 'Tesla Supercharger ${site.name}',
      }) ??
      false;
}
