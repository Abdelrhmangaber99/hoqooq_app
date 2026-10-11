import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hqooq/core/router/app_route_observer.dart';

/// A minimal `RouteAware` screen, standing in for a list page: it subscribes
/// the way `EmployeesPage`/`FirmsPage` do and counts how often it is told it
/// became visible again.
class _ReloadingScreen extends StatefulWidget {
  const _ReloadingScreen({required this.onPopNext});

  final VoidCallback onPopNext;

  @override
  State<_ReloadingScreen> createState() => _ReloadingScreenState();
}

class _ReloadingScreenState extends State<_ReloadingScreen> with RouteAware {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    subscribeToAppRouteObserver(context, this);
  }

  @override
  void dispose() {
    appRouteObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() => widget.onPopNext();

  @override
  Widget build(BuildContext context) => const Scaffold(body: Text('list'));
}

void main() {
  testWidgets('a subscribed screen is notified when the page above it pops', (
    tester,
  ) async {
    var reloads = 0;

    await tester.pumpWidget(
      MaterialApp(
        navigatorObservers: [appRouteObserver],
        home: _ReloadingScreen(onPopNext: () => reloads++),
      ),
    );
    await tester.pumpAndSettle();
    expect(reloads, 0);

    // Push a form screen on top, then leave it — the value it pops is
    // deliberately ignored, because the reload must not depend on it.
    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    unawaitedPush(navigator, tester);
    await tester.pumpAndSettle();
    expect(find.text('form'), findsOneWidget);

    navigator.pop();
    await tester.pumpAndSettle();

    expect(find.text('list'), findsOneWidget);
    expect(reloads, 1);
  });

  testWidgets('an unsubscribed screen stops receiving notifications', (
    tester,
  ) async {
    var reloads = 0;

    await tester.pumpWidget(
      MaterialApp(
        navigatorObservers: [appRouteObserver],
        home: _ReloadingScreen(onPopNext: () => reloads++),
      ),
    );
    await tester.pumpAndSettle();

    // Replacing the home content disposes the subscribed State (and
    // unsubscribes it), so a later pop cannot call back into a dead State.
    await tester.pumpWidget(
      MaterialApp(
        navigatorObservers: [appRouteObserver],
        home: const Scaffold(body: Text('other')),
      ),
    );
    await tester.pumpAndSettle();

    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    unawaitedPush(navigator, tester);
    await tester.pumpAndSettle();
    navigator.pop();
    await tester.pumpAndSettle();

    expect(reloads, 0);
  });
}

void unawaitedPush(NavigatorState navigator, WidgetTester tester) {
  navigator.push(
    MaterialPageRoute<void>(builder: (_) => const Scaffold(body: Text('form'))),
  );
}
