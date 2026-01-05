class ScriptInjector {
  /// Generates the JS code to fill a specific fieldID with a value
  String generateFillScript(String fieldId, String value) {
    // Basic injection logic - in real app, this would be robust with null checks
    return "document.getElementById('$fieldId').value = '$value';";
  }

  /// Generates script to click a button
  String generateClickScript(String elementId) {
    return "document.getElementById('$elementId').click();";
  }
}
