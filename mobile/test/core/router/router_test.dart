import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/router/router.dart';

void main() {
  testWidgets('Router starts at home route', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: Consumer(
          builder: (context, ref, child) {
            final router = ref.watch(goRouterProvider);
            return MaterialApp.router(
              routerConfig: router,
            );
          },
        ),
      ),
    );

    expect(find.text('Home'), findsOneWidget);
  });
}
