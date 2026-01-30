import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/widgets/app_header.dart';
import 'package:mobile/core/theme/app_theme.dart';

void main() {
  testWidgets('AppHeader renders title correctly', (WidgetTester tester) async {
    // Arrange
    const testTitle = 'Test Title';

    // Act
    await tester.pumpWidget(
      const MaterialApp(
        home: AppHeader(title: testTitle),
      ),
    );

    // Assert
    expect(find.text(testTitle), findsOneWidget);
    expect(find.byType(AppBar), findsOneWidget);
  });

  testWidgets('AppHeader applies correct theme', (WidgetTester tester) async {
    // Arrange
    const testTitle = 'Styled Title';

    // Act
    await tester.pumpWidget(
      const MaterialApp(
        home: AppHeader(title: testTitle),
      ),
    );

    // Assert
    final appBar = tester.widget<AppBar>(find.byType(AppBar));
    expect(appBar.backgroundColor, AppTheme.navyPrimary);
    expect(appBar.centerTitle, true);
  });
}
