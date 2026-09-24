import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hqooq/core/widgets/app_badge.dart';
import 'package:hqooq/core/widgets/app_button.dart';
import 'package:hqooq/core/widgets/app_text_field.dart';

void main() {
  Widget buildTestable(Widget child) {
    return MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(child: child),
      ),
    );
  }

  group('AppBadge', () {
    testWidgets('renders label and variant color correctly', (tester) async {
      await tester.pumpWidget(
        buildTestable(
          const AppBadge(label: 'Active', variant: AppBadgeVariant.success),
        ),
      );

      expect(find.text('Active'), findsOneWidget);
    });
  });

  group('AppButton', () {
    testWidgets('renders button text and triggers onPressed when tapped', (
      tester,
    ) async {
      var pressed = false;
      await tester.pumpWidget(
        buildTestable(
          AppButton(
            text: 'Submit Form',
            onPressed: () => pressed = true,
          ),
        ),
      );

      expect(find.text('Submit Form'), findsOneWidget);
      await tester.tap(find.text('Submit Form'));
      await tester.pump();

      expect(pressed, isTrue);
    });

    testWidgets('shows progress indicator and disables tap when isLoading is true', (
      tester,
    ) async {
      var pressed = false;
      await tester.pumpWidget(
        buildTestable(
          AppButton(
            text: 'Submit Form',
            isLoading: true,
            onPressed: () => pressed = true,
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.tap(find.byType(AppButton));
      await tester.pump();

      expect(pressed, isFalse);
    });
  });

  group('AppTextField', () {
    testWidgets('renders upper-cased label and text input', (tester) async {
      final controller = TextEditingController();
      await tester.pumpWidget(
        buildTestable(
          AppTextField(
            label: 'Case Number',
            controller: controller,
          ),
        ),
      );

      expect(find.text('CASE NUMBER'), findsOneWidget);
      await tester.enterText(find.byType(TextFormField), 'CASE-12345');
      expect(controller.text, 'CASE-12345');
    });
  });
}
