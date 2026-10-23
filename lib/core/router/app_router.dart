import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'app_route_observer.dart';
import 'go_router_refresh_stream.dart';
import 'route_guards.dart';

import '../../di/injection.dart';
import '../../features/authentication/presentation/bloc/session_cubit.dart';
import '../../features/authentication/presentation/pages/splash_page.dart';
import '../../features/authentication/presentation/pages/login_page.dart';
import '../../features/authentication/presentation/pages/forgot_password_page.dart';
import '../../features/authentication/presentation/pages/reset_password_page.dart';
import '../../features/authentication/presentation/pages/activate_account_page.dart';
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
import '../../features/clients/presentation/pages/client_details_page.dart';
import '../../features/clients/presentation/pages/clients_page.dart';
import '../../features/reports/presentation/pages/reports_page.dart';
import '../../features/hearings/domain/entities/hearing.dart';
import '../../features/hearings/presentation/pages/hearing_form_page.dart';
import '../../features/hearings/presentation/pages/hearings_page.dart';
import '../../features/service_of_process/domain/entities/service_process.dart';
import '../../features/service_of_process/presentation/pages/service_process_form_page.dart';
import '../../features/service_of_process/presentation/pages/service_process_completion_page.dart';
import '../../features/meetings/domain/entities/client_meeting.dart';
import '../../features/meetings/presentation/pages/meeting_form_page.dart';
import '../../features/notifications/presentation/pages/notifications_page.dart';
import '../../features/platform_admin/presentation/pages/firms_page.dart';
import '../../features/platform_admin/presentation/pages/provision_firm_page.dart';
import '../../features/platform_admin/presentation/pages/firm_details_page.dart';
import '../../features/platform_admin/presentation/pages/firm_admin_details_page.dart';
import '../../features/employees/presentation/pages/employees_page.dart';
import '../../features/employees/presentation/pages/employee_edit_page.dart';
import '../../features/platform_admin/presentation/pages/create_user_page.dart';
import '../../features/tasks/domain/entities/task_item.dart';
import '../../features/tasks/presentation/pages/task_details_page.dart';
import '../../features/tasks/presentation/pages/task_form_page.dart';
import '../../features/tasks/presentation/pages/tasks_page.dart';

import '../../features/finance/presentation/pages/finance_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../shared/presentation/pages/main_layout.dart';

class AppRouter {
  AppRouter._();

  static const String splash = '/';
  static const String login = '/login';

  /// Password recovery (public, signed-out routes) — mirrors the reference
  /// web app's `/forgot-password` and `/reset-password`.
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';
  static const String activate = '/activate';
  static const String home = '/home';
  static const String calendar = '/calendar';
  static const String calendarNew = '/calendar/new';
  static const String hearings = '/hearings';
  static const String tasks = '/tasks';
  static const String tasksNew = '/tasks/new';
  static const String cases = '/cases';
  static const String clients = '/clients';
  static String clientDetails(String caseId) => '/clients/$caseId';
  static const String reports = '/reports';
  static const String finance = '/finance';
  static const String settings = '/settings';
  static const String alerts = '/alerts';
  static const String newHearingRoute = '/hearings/new';
  static String newHearing({
    required String caseId,
    String? governorateId,
  }) {
    final params = <String, String>{'caseId': caseId};
    if (governorateId != null && governorateId.isNotEmpty) {
      params['governorateId'] = governorateId;
    }
    return Uri(path: newHearingRoute, queryParameters: params).toString();
  }

  static const String employees = '/employees';
  static const String createEmployee = '/employees/new';
  static String editEmployee(String employeeId) =>
      '/employees/$employeeId/edit';
  static String employeePermissions(String employeeId) =>
      '/employees/$employeeId/permissions';
  static const String firms = '/firms';
  static const String provisionFirm = '/firms/provision';
  static String firmAdminDetails(String firmId) => '/firms/$firmId/admin';

  static final rootNavigatorKey = GlobalKey<NavigatorState>();

  static final router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: splash,
    // Lets a screen reload itself when the route above it is popped
    // (`didPopNext`) instead of relying solely on `context.push`'s return
    // value. The shell below registers the same observer for its own
    // navigator, where the nested tab pages actually live.
    observers: [appRouteObserver],
    redirect: RouteGuards.authGuard,
    refreshListenable: GoRouterRefreshStream(getIt<SessionCubit>().stream),
    errorBuilder: (context, state) =>
        _RouteNotFoundPage(onGoHome: () => context.go(home)),
    routes: [
      GoRoute(path: splash, builder: (context, state) => const SplashPage()),
      GoRoute(path: login, builder: (context, state) => const LoginPage()),
      GoRoute(
        path: forgotPassword,
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      // The emailed link carries its one-time token as `?token=...`; an
      // empty/missing token is handled on the page (invalid-link state),
      // never posted.
      GoRoute(
        path: resetPassword,
        builder: (context, state) =>
            ResetPasswordPage(token: state.uri.queryParameters['token'] ?? ''),
      ),
      GoRoute(
        path: activate,
        builder: (context, state) =>
            ActivateAccountPage(token: state.uri.queryParameters['token'] ?? ''),
      ),
      ShellRoute(
        builder: (context, state, child) => MainLayout(child: child),
        observers: [appRouteObserver],
        routes: [
          GoRoute(
            path: firms,
            builder: (context, state) => const FirmsPage(),
            routes: [
              GoRoute(
                path: 'provision',
                builder: (context, state) => const ProvisionFirmPage(),
              ),
              GoRoute(
                path: ':id',
                builder: (context, state) => FirmDetailsPage(
                  firmId: state.pathParameters['id']!,
                  initialFirm: state.extra is Map<String, dynamic>
                      ? state.extra! as Map<String, dynamic>
                      : null,
                ),
                routes: [
                  GoRoute(
                    path: 'admin',
                    redirect: (context, state) =>
                        state.extra is Map<String, dynamic> ? null : firms,
                    builder: (context, state) {
                      final data = state.extra! as Map<String, dynamic>;
                      return FirmAdminDetailsPage(
                        firm: Map<String, dynamic>.from(data['firm'] as Map),
                        admin: Map<String, dynamic>.from(data['admin'] as Map),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
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
            path: hearings,
            builder: (context, state) => const HearingsPage(),
            routes: [
              // Scheduling a hearing from the hearings list itself (not a
              // specific case) — the case is picked on the way in, then the
              // shared form is seeded with it. Bounced when no case survived
              // a cold deep-link (mirrors the edit-route guards above).
              GoRoute(
                path: 'new',
                redirect: (context, state) =>
                    state.uri.queryParameters['caseId'] == null ? hearings : null,
                builder: (context, state) => HearingFormPage(
                  caseId: state.uri.queryParameters['caseId']!,
                  governorateId: state.uri.queryParameters['governorateId'],
                ),
              ),
            ],
          ),
          GoRoute(
            path: tasks,
            builder: (context, state) => const TasksPage(),
            routes: [
              GoRoute(
                path: 'new',
                builder: (context, state) => const TaskFormPage(),
              ),
              GoRoute(
                path: ':taskId/edit',
                redirect: (context, state) =>
                    typedExtra<TaskItem>(state) == null ? tasks : null,
                builder: (context, state) =>
                    TaskFormPage(existingTask: typedExtra<TaskItem>(state)),
              ),
              // The Task is carried as `extra` rather than re-fetched: every
              // caller (the Tasks board, a Case's Tasks section) already holds
              // the row it was tapped. A cold deep-link has no extra and is
              // bounced back to the list, same guard as the edit route above.
              GoRoute(
                path: ':taskId',
                redirect: (context, state) =>
                    typedExtra<TaskItem>(state) == null ? tasks : null,
                builder: (context, state) =>
                    TaskDetailsPage(task: typedExtra<TaskItem>(state)!),
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
                    builder: (context, state) => HearingFormPage(
                      caseId: state.pathParameters['id']!,
                      governorateId: state.uri.queryParameters['governorateId'],
                    ),
                  ),
                  GoRoute(
                    path: 'hearings/:hearingId/edit',
                    redirect: (context, state) =>
                        typedExtra<Hearing>(state) == null
                        ? '$cases/${state.pathParameters['id']}'
                        : null,
                    builder: (context, state) => HearingFormPage(
                      caseId: state.pathParameters['id']!,
                      governorateId: state.uri.queryParameters['governorateId'],
                      existingHearing: typedExtra<Hearing>(state),
                    ),
                  ),
                  GoRoute(
                    path: 'service/new',
                    builder: (context, state) => ServiceProcessFormPage(
                      caseId: state.pathParameters['id']!,
                      governorateId: state.uri.queryParameters['governorateId'],
                    ),
                  ),
                  GoRoute(
                    path: 'service/:serviceId/edit',
                    redirect: (context, state) =>
                        typedExtra<ServiceProcess>(state) == null
                        ? '$cases/${state.pathParameters['id']}'
                        : null,
                    builder: (context, state) => ServiceProcessFormPage(
                      caseId: state.pathParameters['id']!,
                      governorateId: state.uri.queryParameters['governorateId'],
                      existing: typedExtra<ServiceProcess>(state),
                    ),
                  ),
                  GoRoute(
                    path: 'service/:serviceId/complete',
                    redirect: (context, state) =>
                        typedExtra<ServiceProcess>(state) == null
                        ? '$cases/${state.pathParameters['id']}'
                        : null,
                    builder: (context, state) => ServiceProcessCompletionPage(
                      process: typedExtra<ServiceProcess>(state)!,
                    ),
                  ),
                  GoRoute(
                    path: 'meetings/new',
                    builder: (context, state) =>
                        MeetingFormPage(caseId: state.pathParameters['id']!),
                  ),
                  GoRoute(
                    path: 'meetings/:meetingId/edit',
                    redirect: (context, state) =>
                        typedExtra<ClientMeeting>(state) == null
                        ? '$cases/${state.pathParameters['id']}'
                        : null,
                    builder: (context, state) => MeetingFormPage(
                      caseId: state.pathParameters['id']!,
                      existing: typedExtra<ClientMeeting>(state),
                    ),
                  ),
                  GoRoute(
                    path: 'tasks/new',
                    builder: (context, state) =>
                        TaskFormPage(fixedCaseId: state.pathParameters['id']!),
                  ),
                  GoRoute(
                    path: 'tasks/:taskId/edit',
                    redirect: (context, state) =>
                        typedExtra<TaskItem>(state) == null
                        ? '$cases/${state.pathParameters['id']}'
                        : null,
                    builder: (context, state) => TaskFormPage(
                      fixedCaseId: state.pathParameters['id']!,
                      existingTask: typedExtra<TaskItem>(state),
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
                path: ':caseId',
                builder: (context, state) => ClientDetailsPage(
                  caseId: state.pathParameters['caseId']!,
                ),
              ),
            ],
          ),
          GoRoute(
            path: reports,
            builder: (context, state) => const ReportsPage(),
          ),
          GoRoute(
            path: employees,
            builder: (context, state) => const EmployeesPage(),
            routes: [
              GoRoute(
                path: 'new',
                builder: (context, state) => const CreateUserPage(),
              ),
              GoRoute(
                path: ':id/edit',
                builder: (context, state) =>
                    EmployeeEditPage(employeeId: state.pathParameters['id']!),
              ),
            ],
          ),
          GoRoute(
            path: finance,
            builder: (context, state) => const FinancePage(),
          ),
          GoRoute(
            path: settings,
            builder: (context, state) => const SettingsPage(),
          ),
          GoRoute(
            path: alerts,
            builder: (context, state) => const NotificationsPage(),
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
