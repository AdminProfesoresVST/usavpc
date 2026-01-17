/// Generates JavaScript injection scripts for DS-160 form automation.
/// This class creates the actual automation code that runs in the WebView.
class ScriptInjector {
  /// DS-160 field mappings from our form_data keys to actual DS-160 field IDs
  static const Map<String, String> ds160FieldMappings = {
    // Personal Information (Page 1)
    'lastName': 'ctl00_SiteContentPlaceHolder_FormView1_tbxAPP_SURNAME',
    'firstName': 'ctl00_SiteContentPlaceHolder_FormView1_tbxAPP_GIVEN_NAME',
    'birthCity': 'ctl00_SiteContentPlaceHolder_FormView1_tbxAPP_POB_CITY',
    'birthCountry': 'ctl00_SiteContentPlaceHolder_FormView1_ddlAPP_POB_CNTRY',
    'nationality': 'ctl00_SiteContentPlaceHolder_FormView1_ddlAPP_NATL',
    
    // Contact Information
    'email': 'ctl00_SiteContentPlaceHolder_FormView1_tbxAPP_EMAIL_ADDR',
    'phone': 'ctl00_SiteContentPlaceHolder_FormView1_tbxAPP_HOME_TEL',
    'address': 'ctl00_SiteContentPlaceHolder_FormView1_tbxAPP_ADDR_LN1',
    'city': 'ctl00_SiteContentPlaceHolder_FormView1_tbxAPP_ADDR_CITY',
    'country': 'ctl00_SiteContentPlaceHolder_FormView1_ddlAPP_ADDR_CNTRY',
    
    // Travel Information
    'purposeOfTrip': 'ctl00_SiteContentPlaceHolder_FormView1_ddlPURPOSE',
    'usAddress': 'ctl00_SiteContentPlaceHolder_FormView1_tbxUS_POC_ADDR_LN1',
    
    // Employment
    'occupation': 'ctl00_SiteContentPlaceHolder_FormView1_tbxPRESENT_OCCUPATION',
    'employer': 'ctl00_SiteContentPlaceHolder_FormView1_tbxPRESENT_EMPLOYER',
  };

  /// Generates the complete JS code to fill a field (with null/element checks)
  String generateFillScript(String fieldId, String value) {
    final escapedValue = value.replaceAll("'", "\\'").replaceAll('"', '\\"');
    return '''
(function() {
  var el = document.getElementById('$fieldId');
  if (el) {
    el.value = '$escapedValue';
    el.dispatchEvent(new Event('change', { bubbles: true }));
    return 'FILLED: $fieldId';
  }
  return 'NOT_FOUND: $fieldId';
})();
''';
  }

  /// Generates script to click a button/link
  String generateClickScript(String elementId) {
    return '''
(function() {
  var el = document.getElementById('$elementId');
  if (el) {
    el.click();
    return 'CLICKED: $elementId';
  }
  return 'NOT_FOUND: $elementId';
})();
''';
  }

  /// Generates script to select dropdown value
  String generateSelectScript(String fieldId, String value) {
    final escapedValue = value.replaceAll("'", "\\'");
    return '''
(function() {
  var el = document.getElementById('$fieldId');
  if (el && el.tagName === 'SELECT') {
    for (var i = 0; i < el.options.length; i++) {
      if (el.options[i].text.toLowerCase().includes('$escapedValue'.toLowerCase()) ||
          el.options[i].value.toLowerCase() === '$escapedValue'.toLowerCase()) {
        el.selectedIndex = i;
        el.dispatchEvent(new Event('change', { bubbles: true }));
        return 'SELECTED: $fieldId -> ' + el.options[i].text;
      }
    }
    return 'OPTION_NOT_FOUND: $fieldId -> $escapedValue';
  }
  return 'NOT_FOUND: $fieldId';
})();
''';
  }

  /// Generates a batch fill script from user's form_data
  String generateBatchFillScript(Map<String, dynamic> formData) {
    final buffer = StringBuffer();
    buffer.writeln('(function() {');
    buffer.writeln('  var results = [];');
    
    formData.forEach((key, value) {
      if (value != null && value.toString().isNotEmpty) {
        final fieldId = ds160FieldMappings[key];
        if (fieldId != null) {
          final escapedValue = value.toString().replaceAll("'", "\\'").replaceAll('"', '\\"');
          buffer.writeln('''
  (function() {
    var el = document.getElementById('$fieldId');
    if (el) {
      if (el.tagName === 'SELECT') {
        for (var i = 0; i < el.options.length; i++) {
          if (el.options[i].text.toLowerCase().includes('$escapedValue'.toLowerCase())) {
            el.selectedIndex = i;
            results.push('SELECTED: $key');
            break;
          }
        }
      } else {
        el.value = '$escapedValue';
        results.push('FILLED: $key');
      }
      el.dispatchEvent(new Event('change', { bubbles: true }));
    } else {
      results.push('NOT_FOUND: $key');
    }
  })();
''');
        }
      }
    });
    
    buffer.writeln('  return JSON.stringify(results);');
    buffer.writeln('})();');
    return buffer.toString();
  }

  /// Generates script to detect current DS-160 page
  String generatePageDetectionScript() {
    return '''
(function() {
  var title = document.querySelector('h1, .page-title, #pageTitle');
  var url = window.location.href;
  return JSON.stringify({
    title: title ? title.innerText : 'Unknown',
    url: url,
    hasNextButton: !!document.getElementById('ctl00_SiteContentPlaceHolder_btnContinue'),
    hasSaveButton: !!document.getElementById('ctl00_SiteContentPlaceHolder_btnSaveExit')
  });
})();
''';
  }

  /// Click the "Next" button to proceed
  String generateNextButtonScript() {
    return generateClickScript('ctl00_SiteContentPlaceHolder_btnContinue');
  }
}
