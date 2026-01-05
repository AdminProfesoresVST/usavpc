import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/rpa/logic/script_injector.dart';

void main() {
  test('ScriptInjector generates correct JS', () {
    final injector = ScriptInjector();
    
    expect(
      injector.generateFillScript('name', 'John'), 
      "document.getElementById('name').value = 'John';"
    );
    
    expect(
      injector.generateClickScript('submit'), 
      "document.getElementById('submit').click();"
    );
  });
}
