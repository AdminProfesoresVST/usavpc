import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/payments/presentation/screens/service_selection_screen.dart';

void main() {
  testWidgets('ServiceSelectionScreen renders static Gov-Style UI', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: ServiceSelectionScreen(),
        ),
      ),
    );

    // Verify Header
    expect(find.text('Simplifica tu Trámite Consular'), findsOneWidget);
    expect(find.text('Guía Oficial'), findsOneWidget);

    // Verify Sections
    expect(find.text('Cómo funciona'), findsOneWidget);
    expect(find.text('Servicios Populares'), findsOneWidget);

    // Verify Cards
    expect(find.text('Nueva Solicitud de Visa'), findsOneWidget);
    expect(find.text('Simulador de Entrevista'), findsOneWidget);
    expect(find.text('Auditoría de Documentos'), findsOneWidget);
  });
}
