import 'package:flutter/widgets.dart';

/// App-wide [RouteObserver] used to reload a screen when the route pushed on
/// top of it is popped.
///
/// A list screen can already reload from the value returned by
/// `context.push(...)`, but that only covers the page that performed the push,
/// and only when the navigation goes back through that call site (a system
/// back gesture, an AppBar back button, or a child that navigates away with
/// `go` all drop the value). Subscribing to this observer instead makes "I have
/// become visible again" a first-class signal, so a page re-reads its data on
/// `didPopNext` no matter how it was left.
///
/// Registered on both the root `GoRouter` and the app's `ShellRoute` — pages
/// nested in a shell live on the shell's own [Navigator], which does not
/// forward events to the root observer unless told to.
final RouteObserver<PageRoute<dynamic>> appRouteObserver =
    RouteObserver<PageRoute<dynamic>>();

/// Subscribes [routeAware] to [appRouteObserver] for the route that [context]
/// belongs to, ignoring anything that is not a [PageRoute] (a dialog, a
/// sheet). Safe to call from `didChangeDependencies`.
void subscribeToAppRouteObserver(BuildContext context, RouteAware routeAware) {
  final route = ModalRoute.of(context);
  if (route is PageRoute<dynamic>) {
    appRouteObserver.subscribe(routeAware, route);
  }
}
