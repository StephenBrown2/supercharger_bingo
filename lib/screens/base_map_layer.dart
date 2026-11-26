import 'dart:convert';

import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb;
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_map_vector_tiles/flutter_map_vector_tiles.dart' as vt;
import 'package:flutter_mapigrade/flutter_mapigrade.dart';
import 'package:material_ui/material_ui.dart';

/// OpenStreetMap vector tiles, in a light or dark style to match the app.
/// [children] are the map's overlay layers.
///
/// Android draws the map on the GPU with MapLibre Native (Mapigrade); overlays
/// sit inside its layer so they stay aligned while the map moves. Web and the
/// other platforms draw it in Dart with flutter_map_vector_tiles.
class BaseMapLayer extends StatelessWidget {
  const BaseMapLayer({super.key, required this.children});

  final List<Widget> children;

  // OpenStreetMap's tile policy asks apps to identify themselves. Mapigrade
  // leaves User-Agent to Android's HTTP client; the policy accepts an
  // X-Requested-With app ID instead.
  static final _headers = [
    HttpHeaderRule(
      url: 'https://vector.openstreetmap.org/**',
      headers: const {'X-Requested-With': 'bingo.supercharger.checkin'},
    ),
  ];

  static bool get _useMapigrade =>
      !kIsWeb &&
      defaultTargetPlatform == TargetPlatform.android &&
      MapigradeLayer.isSupported;

  static String _asset(Brightness brightness) => brightness == Brightness.dark
      ? 'assets/map/eclipse.json'
      : 'assets/map/colorful.json';

  static final _mapigradeStyles = <Brightness, Future<String>>{};

  // The bundled style draws land and roads without waiting for a download.
  // MapLibre needs glyphs for labels, so those still come from OpenStreetMap.
  static Future<String> _mapigradeStyle(
    Brightness brightness,
  ) => _mapigradeStyles[brightness] ??= rootBundle
      .loadString(_asset(brightness))
      .then(
        (json) => jsonEncode({
          ...jsonDecode(json) as Map<String, dynamic>,
          'sprite': 'asset://assets/map/sprites',
          'glyphs':
              'https://vector.openstreetmap.org/styles/shortbread/fonts/{fontstack}/{range}.pbf',
        }),
      );

  static final _styles = <Brightness, Future<vt.Style>>{};

  // The styles are bundled because OpenStreetMap serves them without CORS
  // headers; see assets/map/README.md.
  static Future<vt.Style> _style(
    Brightness brightness,
  ) => _styles[brightness] ??= vt.StyleReader(
    uri: 'asset://${_asset(brightness)}',
    cache: false,
    headers: kIsWeb
        ? const {}
        : const {
            'User-Agent':
                'SuperchargerBingo (bingo.supercharger.checkin; +https://supercharger.bingo)',
          },
  ).read();

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    if (_useMapigrade) {
      return FutureBuilder<String>(
        future: _mapigradeStyle(brightness),
        builder: (context, snapshot) {
          final style = snapshot.data;
          // The asset loads within a frame or two. Showing the overlays
          // meanwhile would build them twice and blink the markers.
          if (style == null) return const SizedBox.shrink();
          return MapigradeLayer(
            styleJson: style,
            httpHeaders: _headers,
            children: children,
          );
        },
      );
    }
    return Stack(
      children: [
        FutureBuilder<vt.Style>(
          key: ValueKey(brightness),
          future: _style(brightness),
          builder: (context, snapshot) {
            final style = snapshot.data;
            if (style == null) return const SizedBox.shrink();
            return vt.VectorTileLayer(
              theme: style.theme,
              tileProviders: style.providers,
              sprites: style.sprites,
            );
          },
        ),
        ...children,
      ],
    );
  }
}
