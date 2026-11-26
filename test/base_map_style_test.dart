import 'package:flutter_map_vector_tiles/flutter_map_vector_tiles.dart' as vt;
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  for (final name in ['colorful', 'eclipse']) {
    test('bundled $name style loads its tiles source and icons', () async {
      final style = await vt.StyleReader(
        uri: 'asset://assets/map/$name.json',
        cache: false,
      ).read();
      addTearDown(style.dispose);

      expect(style.providers.providers.keys, ['versatiles-shortbread']);
      expect(style.sprites, isNotNull);
      expect(style.sprites!.sprites, contains('icon-atm'));
      expect(style.glyphs, isNull);
    });
  }
}
