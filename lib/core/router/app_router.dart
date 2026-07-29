import 'package:go_router/go_router.dart';
import 'route_guards.dart';

import '../../features/authentication/presentation/pages/splash_page.dart';
import '../../features/authentication/presentation/pages/login_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/calendar/presentation/pages/calendar_page.dart';
import '../../features/calendar/presentation/pages/appointment_details_page.dart';
import '../../features/calendar/presentation/pages/new_appointment_page.dart';
import '../../features/clients/presentation/pages/clients_page.dart';
import '../../features/clients/presentation/pages/client_profile_page.dart';
import '../../features/cases/presentation/pages/case_details_page.dart';
import '../../features/notifications/presentation/pages/notifications_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../shared/presentation/pages/main_layout.dart';

class AppRouter {
  AppRouter._();

  static const String splash = '/';
  static const String login = '/login';
  static const String home = '/home';
  static const String calendar = '/calendar';
  static const String clients = '/clients';
  static const String alerts = '/alerts';
  static const String profile = '/profile';

  static final router = GoRouter(
    initialLocation: splash,
    redirect: RouteGuards.authGuard,
    routes: [
      GoRoute(
        path: splash,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: login,
        builder: (context, state) => const LoginPage(),
      ),
      ShellRoute(
        builder: (context, state, child) => MainLayout(child: child),
        routes: [
          GoRoute(
            path: home,
            builder: (context, state) => const DashboardPage(),
          ),
          GoRoute(
            path: calendar,
            builder: (context, state) => const CalendarPage(),
            routes: [
              GoRoute(
                path: 'details',
                builder: (context, state) => const AppointmentDetailsPage(),
              ),
              GoRoute(
                path: 'new',
                builder: (context, state) => const NewAppointmentPage(),
              ),
            ],
          ),
          GoRoute(
            path: clients,
            builder: (context, state) => const ClientsPage(),
            routes: [
              GoRoute(
                path: 'profile',
                builder: (context, state) => const ClientProfilePage(),
              ),
            ],
          ),
          GoRoute(
            path: alerts,
            builder: (context, state) => const NotificationsPage(),
          ),
          GoRoute(
            path: '/case-details',
            builder: (context, state) => const CaseDetailsPage(),
          ),
          GoRoute(
            path: profile,
            builder: (context, state) => const ProfilePage(),
          ),
        ],
      ),
    ],
  );
}
