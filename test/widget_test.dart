import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pregapp/ui/theme/design_tokens.dart';

void main() {
  test('design tokens stay on the clinical palette', () {
    expect(AppColors.ink, const Color(0xFF241C24));
    expect(AppColors.semanticAlert, const Color(0xFFD64545));
    expect(AppSpacing.md, 16);
    expect(AppRadius.cardLarge, 28);
  });

  testWidgets('theme builds without crashing', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(),
        home: const Scaffold(body: Text('Mira')),
      ),
    );
    expect(find.text('Mira'), findsOneWidget);
  });
}
