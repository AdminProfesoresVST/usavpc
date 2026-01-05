import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/simulator/presentation/widgets/avatar_widget.dart';

void main() {
  testWidgets('AvatarWidget changes appearance based on state', (tester) async {
    // 1. Idle State
    await tester.pumpWidget(const MaterialApp(home: AvatarWidget(state: AvatarState.idle)));
    expect(find.byIcon(Icons.person), findsOneWidget);

    // 2. Speaking State
    await tester.pumpWidget(const MaterialApp(home: AvatarWidget(state: AvatarState.speaking)));
    expect(find.byIcon(Icons.record_voice_over), findsOneWidget);
    
    // 3. Thinking State
    await tester.pumpWidget(const MaterialApp(home: AvatarWidget(state: AvatarState.thinking)));
    expect(find.byIcon(Icons.psychology), findsOneWidget);
  });
}
