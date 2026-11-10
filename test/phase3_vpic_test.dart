import 'package:flutter_test/flutter_test.dart';

import 'package:supercharger_bingo/services/vehicle_service.dart';

void main() {
  group('VehicleService.parseVpicResults', () {
    test('extracts make/model/year/trim from a vPIC response', () {
      final json = {
        'Results': [
          {'Variable': 'Make', 'Value': 'TESLA'},
          {'Variable': 'Model', 'Value': 'Model 3'},
          {'Variable': 'Model Year', 'Value': '2021'},
          {'Variable': 'Trim', 'Value': 'Long Range'},
          {'Variable': 'Doors', 'Value': '4'},
        ],
      };
      final decode = VehicleService.parseVpicResults(json);
      expect(decode.make, 'Tesla');
      expect(decode.model, 'Model 3');
      expect(decode.year, '2021');
      expect(decode.trim, 'Long Range');
      expect(decode.isEmpty, isFalse);
    });

    test('ignores empty values and missing variables', () {
      final json = {
        'Results': [
          {'Variable': 'Make', 'Value': 'RIVIAN'},
          {'Variable': 'Model', 'Value': ''},
          {'Variable': 'Trim', 'Value': null},
        ],
      };
      final decode = VehicleService.parseVpicResults(json);
      expect(decode.make, 'Rivian');
      expect(decode.model, isNull);
      expect(decode.trim, isNull);
    });

    test('title-cases an all-caps make and keeps initialisms', () {
      VehicleDecode decode(String make) => VehicleService.parseVpicResults({
        'Results': [
          {'Variable': 'Make', 'Value': make},
        ],
      });

      expect(decode('MERCEDES-BENZ').make, 'Mercedes-Benz');
      expect(decode('LAND ROVER').make, 'Land Rover');
      expect(decode('BMW').make, 'BMW');
      expect(decode('GMC').make, 'GMC');
      expect(decode('MCLAREN').make, 'McLaren');
      expect(decode('Tesla').make, 'Tesla');
    });

    test('returns empty decode when Results is absent or malformed', () {
      expect(VehicleService.parseVpicResults({}).isEmpty, isTrue);
      expect(
        VehicleService.parseVpicResults({'Results': 'nope'}).isEmpty,
        isTrue,
      );
    });
  });
}
