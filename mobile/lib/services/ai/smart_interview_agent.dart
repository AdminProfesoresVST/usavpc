
/// The Brain of the Interview Process.
/// Intercepts raw data and applies "Human" logic before hitting the DB or UI.
class SmartInterviewAgent {
  
  /// Evaluates dependency logic with fuzzy "Human" understanding.
  /// 
  /// [actualValue] - What the user typed/said (e.g., "Nope", "Claro", "Santo Domingo")
  /// [dependencyValue] - What the DB expects (e.g., "true", "DOM")
  static bool evaluateLogic(String? actualValue, String dependencyValue) {
    if (actualValue == null) return false;
    
    final actual = actualValue.trim().toLowerCase();
    final required = dependencyValue.trim().toLowerCase();
    
    // 1. Boolean Logic (The "Smart" Part)
    if (required == 'true' || required == 'yes') {
      return _isTrue(actual);
    }
    
    if (required == 'false' || required == 'no') {
      return _isFalse(actual);
    }
    
    // 2. Standard String Match (Case Insensitive)
    return actual == required;
  }

  static bool _isTrue(String val) {
    if (val == 'true' || val == 'yes' || val == '1') return true;
    if (val == 'si' || val == 'yep' || val == 'sure' || val == 'claro') return true;
    if (val == 'ok' || val == 'correct') return true;
    return false;
  }

  static bool _isFalse(String val) {
    if (val == 'false' || val == 'no' || val == '0') return true;
    if (val == 'nop' || val == 'nope' || val == 'never' || val == 'negativo') return true;
    if (val == 'none' || val == 'ninguno' || val == 'jamás' || val == 'jamas') return true;
    return false;
  }

  /// Validates response against field type and common "Chatter" patterns.
  /// Returns NULL if valid, or an error message string if invalid.
  static String? validateAnswer(String fieldKey, String answer) {
    if (answer.isEmpty) return null; // Let standard validation handle empty
    
    final lower = answer.toLowerCase();
    
    // 1. Detect "Chatter" / "Attitude" / "Unknown" responses
    // These should NOT be saved as data fields.
    final invalidPhrases = [
      'no se', 'no sé', 'i dont know', 'dont know', 'ni idea',
      'dice mi pasaporte', 'lo dice el pasaporte', 'eso dice',
      'what?', 'que?', 'no entiendo', 'tambien', 'también',
      'idk', 'same', 'mismo', 'igual'
    ];
    
    // Strict Input Fields (Passport, Names, Cities, States)
    // These cannot contain conversational filler.
    if (_isStrictField(fieldKey)) {
       for (final phrase in invalidPhrases) {
          if (lower.contains(phrase)) {
             return 'Please provide the exact answer. Avoid phrases like "$phrase".';
          }
       }
       
       // Length checks
       if (answer.length < 2) return 'Too short.';
       if (answer.length > 50 && !fieldKey.contains('address')) return 'Too long.';
    }

    return null;
  }

  static bool _isStrictField(String key) {
     final k = key.toLowerCase();
     if (k.contains('passport')) return true;
     if (k.contains('city')) return true;
     if (k.contains('state')) return true;
     if (k.contains('name')) return true;
     if (k.contains('telecode')) return true;
     return false;
  }

  /// Injects Passport Data into the form context, normalizing keys.
  static Map<String, dynamic> processPassportContext(dynamic passportModel) {
     if (passportModel == null) return {};
     
     // NOTE: passportModel is 'PassportModel' type from MrzParser
     // We map it to DS-160 field keys
     return {
        'passport_number': passportModel.documentNumber,
        'given_name': passportModel.firstName, // Might contain middle names
        'surname': passportModel.lastName,
        'date_of_birth': _formatMrzDate(passportModel.birthDate), 
        'nationality': passportModel.nationality, // ISO code
        'sex': passportModel.sex == 'M' ? 'Male' : 'Female',
        'issuing_country': passportModel.nationality, // Usually same
     };
  }

  static String _formatMrzDate(String mrzDate) {
     // MRZ is YYMMDD. We want YYYY-MM-DD.
     // Heuristic: If YY > 26, assume 19YY, else 20YY (Adjust logic as needed for DOB)
     if (mrzDate.length != 6) return mrzDate;
     
     final yy = int.parse(mrzDate.substring(0, 2));
     final mm = mrzDate.substring(2, 4);
     final dd = mrzDate.substring(4, 6);
     
     // Valid until 2026? If DOB, could be 1926 or 2026. 
     // For DOB, usually assume past. If current year is 2026, 26 is 1926?
     // Let's assume < current year + 10 is 2000s, else 1900s.
     // Simple pivoting:
     final prefix = yy > 30 ? '19' : '20'; 
     return '$prefix$yy-$mm-$dd';
  }
}
