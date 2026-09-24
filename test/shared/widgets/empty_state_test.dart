import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hqooq/shared/widgets/empty_state.dart';

void main() {
  Widget buildTestable(Widget child) {
    return MaterialApp(
      home: Scaffold(
        body: child,
      ),
    );
  }

  testWidgets('renders message and custom icon when provided', (tester) async {
    await tester.pumpWidget(
      buildTestable(
        const EmptyState(
          message: 'No cases found',
          icon: Icons.folder_off_outlined,
        ),
      ),
    );

    expect(find.text('No cases found'), findsOneWidget);
    expect(find.byIcon(Icons.folder_off_outlined), findsOneWidget);
  });

  testWidgets('renders default inbox icon when icon parameter is omitted', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildTestable(
        const EmptyState(
          message: 'Nothing here',
        ),
      ),
    );

    expect(find.text('Nothing here'), findsOneWidget);
    expect(find.byIcon(Icons.inbox_outlined), findsOneWidget);
  });
}
