import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hqooq/core/network/api_config.dart';
import 'package:hqooq/core/widgets/app_avatar.dart';
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

  // The deployed backend exposes exactly one avatar field (`avatarUrl`, a
  // nullable URL string on the user payload) and no upload route, so these
  // lock in both halves of that contract: a URL renders, its absence renders
  // initials, and nothing invents a photo that the server never sent.
  group('AppAvatar', () {
    testWidgets('renders initials when the backend sends no avatarUrl', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestable(const AppAvatar(name: 'Jane Doe', size: 40)),
      );

      expect(find.text('JD'), findsOneWidget);
      expect(find.byType(Image), findsNothing);
    });

    testWidgets('renders a single initial for a one-word name', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestable(const AppAvatar(name: 'youssef')),
      );

      expect(find.text('Y'), findsOneWidget);
    });

    testWidgets('renders the fallback for a blank or missing name', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestable(const AppAvatar(name: '')));

      expect(find.text('?'), findsOneWidget);
    });

    testWidgets('loads the backend avatarUrl verbatim when one is present', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestable(
          const AppAvatar(
            name: 'Jane Doe',
            imageUrl: 'https://cdn.example.com/jane.png',
          ),
        ),
      );

      final image = tester.widget<Image>(find.byType(Image));
      expect(
        (image.image as NetworkImage).url,
        'https://cdn.example.com/jane.png',
      );
      expect(find.text('JD'), findsNothing);
    });

    testWidgets('treats a blank avatarUrl as absent', (tester) async {
      await tester.pumpWidget(
        buildTestable(const AppAvatar(name: 'Jane Doe', imageUrl: '   ')),
      );

      expect(find.text('JD'), findsOneWidget);
      expect(find.byType(Image), findsNothing);
    });

    testWidgets('resolves a relative avatarUrl against the API host', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestable(
          const AppAvatar(name: 'Jane Doe', imageUrl: '/uploads/jane.png'),
        ),
      );

      final image = tester.widget<Image>(find.byType(Image));
      expect(
        (image.image as NetworkImage).url,
        '${ApiConfig.host}/uploads/jane.png',
      );
    });

    testWidgets('versions the URL so a re-saved photo is refetched', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestable(
          const AppAvatar(
            name: 'Jane Doe',
            imageUrl: 'https://cdn.example.com/jane.png',
            version: 'v2',
          ),
        ),
      );

      final image = tester.widget<Image>(find.byType(Image));
      expect(
        (image.image as NetworkImage).url,
        'https://cdn.example.com/jane.png?v=v2',
      );
    });

    test('initialsOf takes at most two letters and never returns empty', () {
      expect(AppAvatar.initialsOf('Jane Doe'), 'JD');
      expect(AppAvatar.initialsOf('jane doe smith'), 'JD');
      expect(AppAvatar.initialsOf('  '), '?');
    });
  });
}
