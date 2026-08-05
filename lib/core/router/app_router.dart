import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'go_router_refresh_stream.dart';
import 'route_guards.dart';

import '../../di/injection.dart';
import '../../features/authentication/presentation/bloc/session_cubit.dart';
import '../../features/authentication/presentation/pages/splash_page.dart';
import '../../features/authentication/presentation/pages/login_page.dart';
import '../localization/app_localizations.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../widgets/app_button.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/calendar/presentation/pages/calendar_event_form_page.dart';
import '../../features/calendar/presentation/pages/calendar_page.dart';
import '../../features/cases/domain/entities/legal_case.dart';
import '../../features/cases/presentation/pages/case_form_page.dart';
import '../../features/cases/presentation/pages/cases_page.dart';
import '../../features/cases/presentation/pages/case_details_page.dart';
import '../../features/hearings/domain/entities/hearing.dart';
import '../../features/hearings/presentation/pages/hearing_form_page.dart';
import '../../features/clients/domain/entities/client.dart';
import '../../features/clients/presentation/pages/client_form_page.dart';
import '../../features/clients/presentation/pages/clients_page.dart';
import '../../features/clients/presentation/pages/client_profile_page.dart';
import '../../features/notifications/presentation/pages/notifications_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/subscriptions/presentation/pages/subscription_inactive_page.dart';
import '../../features/tasks/domain/entities/task_item.dart';
import '../../features/tasks/presentation/pages/task_form_page.dart';
import '../../shared/presentation/pages/main_layout.dart';

class AppRouter {
  AppRouter._();

  static const String splash = '/';
  static const String login = '/login';
  static const String home = '/home';
  static const String calendar = '/calendar';
  static const String cases = '/cases';
  static const String clients = '/clients';
  static const String alerts = '/alerts';
  static const String profile = '/profile';
  static const String subscriptionInactive = '/subscription-inactive';

  static final router = GoRouter(
    initialLocation: splash,
    redirect: RouteGuards.authGuard,
    refreshListenable: GoRouterRefreshStream(getIt<SessionCubit>().stream),
    errorBuilder: (context, state) =>
        _RouteNotFoundPage(onGoHome: () => context.go(home)),
    routes: [
      GoRoute(path: splash, builder: (context, state) => const SplashPage()),
      GoRoute(path: login, builder: (context, state) => const LoginPage()),
      GoRoute(
        path: subscriptionInactive,
        builder: (context, state) => const SubscriptionInactivePage(),
      ),
      ShellRoute(
        builder: (context, state, child) => MainLayout(child: child),
        routes: [
          GoRoute(
            path: home,
            builder: (context, state) => const DashboardPage(),
            routes: [
              GoRoute(
                path: 'tasks/new',
                builder: (context, state) => const TaskFormPage(),
              ),
              GoRoute(
                path: 'tasks/:taskId/edit',
                redirect: (context, state) =>
                    typedExtra<TaskItem>(state) == null ? home : null,
                builder: (context, state) =>
                    TaskFormPage(existingTask: typedExtra<TaskItem>(state)),
              ),
            ],
          ),
          GoRoute(
            path: calendar,
            builder: (context, state) => const CalendarPage(),
            routes: [
              GoRoute(
                path: 'new',
                builder: (context, state) => const CalendarEventFormPage(),
              ),
            ],
          ),
          GoRoute(
            path: cases,
            builder: (context, state) => const CasesPage(),
            routes: [
              GoRoute(
                path: 'new',
                builder: (context, state) => const CaseFormPage(),
              ),
              GoRoute(
                path: ':id',
                builder: (context, state) =>
                    CaseDetailsPage(caseId: state.pathParameters['id']!),
                routes: [
                  GoRoute(
                    path: 'edit',
                    redirect: (context, state) =>
                        typedExtra<LegalCase>(state) == null
                        ? '$cases/${state.pathParameters['id']}'
                        : null,
                    builder: (context, state) => CaseFormPage(
                      existingCase: typedExtra<LegalCase>(state),
                    ),
                  ),
                  GoRoute(
                    path: 'hearings/new',
                    builder: (context, state) =>
                        HearingFormPage(caseId: state.pathParameters['id']!),
                  ),
                  GoRoute(
                    path: 'hearings/:hearingId/edit',
                    redirect: (context, state) =>
                        typedExtra<Hearing>(state) == null
                        ? '$cases/${state.pathParameters['id']}'
                        : null,
                    builder: (context, state) => HearingFormPage(
                      caseId: state.pathParameters['id']!,
                      existingHearing: typedExtra<Hearing>(state),
                    ),
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: clients,
            builder: (context, state) => const ClientsPage(),
            routes: [
              GoRoute(
                path: 'new',
                builder: (context, state) => const ClientFormPage(),
              ),
              GoRoute(
                path: ':id',
                builder: (context, state) =>
                    ClientProfilePage(clientId: state.pathParameters['id']!),
                routes: [
                  GoRoute(
                    path: 'edit',
                    redirect: (context, state) =>
                        typedExtra<Client>(state) == null
                        ? '$clients/${state.pathParameters['id']}'
                        : null,
                    builder: (context, state) => ClientFormPage(
                      existingClient: typedExtra<Client>(state),
                    ),
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: alerts,
            builder: (context, state) => const NotificationsPage(),
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

/// Shown for any unmatched route (`GoRouter.errorBuilder`) — previously
/// unset, so any navigation to an unregistered path fell through to
/// go_router's default error page instead of something in-brand.
class _RouteNotFoundPage extends StatelessWidget {
  final VoidCallback onGoHome;
  const _RouteNotFoundPage({required this.onGoHome});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.l),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.explore_off_outlined,
                  size: 64,
                  color: AppColors.textHint,
                ),
                const SizedBox(height: AppSpacing.l),
                Text(
                  context.tr('page_not_found'),
                  style: AppTypography.h3,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.l),
                AppButton(text: context.tr('go_home'), onPressed: onGoHome),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
