import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/ocr/logic/mrz_parser.dart';

void main() {
  group('MrzParser', () {
    test('parses valid TD3 passport MRZ', () {
      final lines = [
        'P<UTOERIKSSON<<ANNA<MARIA<<<<<<<<<<<<<<<<<<<',
        'L898902C<3UTO6908061F9406236ZE184226B<<<<<14'
      ];

      final result = MrzParser.parse(lines);

      expect(result, isNotNull);
      expect(result!.documentNumber, 'L898902C');
      expect(result.firstName, 'ANNA MARIA');
      expect(result.lastName, 'ERIKSSON');
      expect(result.birthDate, '690806');
      expect(result.expiryDate, '940623');
      expect(result.sex, 'F');
      expect(result.nationality, 'UTO');
    });

    test('returns null for invalid MRZ', () {
      final lines = [
        'Hello World',
        'Not an MRZ line'
      ];
      final result = MrzParser.parse(lines);
      expect(result, isNull);
    });
  });
}
