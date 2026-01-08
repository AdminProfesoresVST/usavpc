class PassportModel {
  final String documentNumber;
  final String birthDate;
  final String expiryDate;
  final String personalNumber;
  final String firstName;
  final String lastName;
  final String nationality;
  final String sex;

  PassportModel({
    required this.documentNumber,
    required this.birthDate,
    required this.expiryDate,
    required this.personalNumber,
    required this.firstName,
    required this.lastName,
    required this.nationality,
    required this.sex,
  });
}

class MrzParser {
  /// Parses MRZ lines (TD3 format - 2 lines of 44 chars)
  static PassportModel? parse(List<String> lines) {
    if (lines.length < 2) return null;

    // Find the two lines that look like MRZ
    String? line1;
    String? line2;


    for (var i = 0; i < lines.length - 1; i++) {
        final l1 = lines[i].replaceAll(' ', '');
        final l2 = lines[i+1].replaceAll(' ', '');
        
        if (l1.length == 44 && l2.length == 44 && l1.startsWith('P<')) {
            line1 = l1;
            line2 = l2;
            break;
        }
    }

    if (line1 == null || line2 == null) return null;

    // Parse Line 1: P<UTOERIKSSON<<ANNA<MARIA<<<<<<<<<<<<<<<<<<<
    // 0-2: P<
    // 2-5: Issuer (UTO)
    // 5-44: Names (ERIKSSON<<ANNA<MARIA)
    
    final namesPart = line1.substring(5);
    final namesSplit = namesPart.split('<<');
    final lastName = namesSplit[0].replaceAll('<', ' ');
    final firstName = namesSplit.length > 1 ? namesSplit[1].replaceAll('<', ' ') : '';

    // Parse Line 2: L898902C<3UTO6908061F9406236ZE184226B<<<<<14
    // 0-9: Doc Number (L898902C<)
    // 9: Check Digit
    // 10-13: Nationality (UTO)
    // 13-19: DOB (YYMMDD) (690806)
    // 19: Check Digit
    // 20: Sex (F)
    // 21-27: Expiry (YYMMDD) (940623)
    // 27: Check Digit
    // 28-42: Personal Number
    // 42: Check Digit
    // 43: Final Check Digit

    final docNumber = line2.substring(0, 9).replaceAll('<', '');
    final nationality = line2.substring(10, 13);
    final dob = line2.substring(13, 19);
    final sex = line2.substring(20, 21);
    final expiry = line2.substring(21, 27);
    final personalNumber = line2.substring(28, 42).replaceAll('<', '');

    return PassportModel(
      documentNumber: docNumber,
      birthDate: dob,
      expiryDate: expiry,
      personalNumber: personalNumber,
      firstName: firstName.trim(),
      lastName: lastName.trim(),
      nationality: nationality,
      sex: sex,
    );
  }
}
