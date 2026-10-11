import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/permission_codes.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/cache_busted_url.dart';
import '../../../features/authentication/presentation/bloc/auth_bloc.dart';
import '../../../features/authentication/presentation/bloc/session_cubit.dart';
import '../../../features/subscriptions/presentation/bloc/subscription_cubit.dart';
import '../../../features/subscriptions/presentation/bloc/subscription_state.dart';

class MainLayout extends StatelessWidget {
  const MainLayout({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SessionCubit, SessionState>(
      builder: (context, sessionState) {
        return BlocBuilder<SubscriptionCubit, SubscriptionState>(
          builder: (context, subState) {
            final user = sessionState is SessionAuthenticated ? sessionState.user : null;
            final isSuperAdmin = user?.isSuperAdmin ?? false;
            // A re-saved photo keeps the same URL, and Flutter's image cache is
            // keyed by URL — version the avatar so the header updates as soon
            // as the profile save lands.
            final avatarUrl = user?.avatarUrl;
            final versionedAvatarUrl = avatarUrl == null || avatarUrl.isEmpty
                ? null
                : cacheBustedUrl(avatarUrl, user?.updatedAt);

            String? firmName = user?.tenant?.name;
            if (subState is SubscriptionLoaded) {
              firmName = subState.firm['name'] as String? ?? firmName;
            }

            final items = isSuperAdmin
                ? _superAdminItems(context)
                : _firmItems(
                    context,
                    showCases:
                        user?.isFirmAdmin == true ||
                        user?.hasPerm(PermissionCodes.caseView) == true,
                    showClients:
                        user?.isFirmAdmin == true ||
                        user?.hasPerm(PermissionCodes.caseView) == true ||
                        user?.hasPerm(PermissionCodes.clientView) == true,
                    showHearings:
                        user?.isFirmAdmin == true ||
                        user?.hasPerm(PermissionCodes.hearingView) == true,
                    showTasks:
                        user?.isFirmAdmin == true ||
                        user?.hasPerm(PermissionCodes.taskView) == true,
                    showCalendar:
                        user?.isFirmAdmin == true ||
                        user?.hasPerm(PermissionCodes.calendarRead) == true,
                    showFinance:
                        user?.isFirmAdmin == true ||
                        user?.hasPerm(PermissionCodes.financeFirmRead) == true,
                    showReports:
                        user?.isFirmAdmin == true ||
                        user?.hasPerm(PermissionCodes.financeFirmRead) == true ||
                        user?.hasPerm(PermissionCodes.reportOperationalRead) ==
                            true,
                    showEmployees:
                        user?.isFirmAdmin == true ||
                        user?.hasPerm(PermissionCodes.employeeRead) == true,
                  );

            final location = GoRouterState.of(context).uri.path;

            return LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth >= 980) {
                  return Scaffold(
                    backgroundColor: AppColors.paper,
                    body: Row(
                      textDirection: TextDirection.rtl,
                      children: [
                        _Sidebar(
                          items: items,
                          location: location,
                          userName: user?.fullName ?? '',
                          avatarUrl: versionedAvatarUrl,
                          workspaceName: firmName,
                          isSuperAdmin: isSuperAdmin,
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              _TopBar(
                                userName: user?.fullName ?? '',
                                avatarUrl: versionedAvatarUrl,
                              ),
                              Expanded(child: child),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return Scaffold(
                  backgroundColor: AppColors.paper,
                  appBar: AppBar(
                    toolbarHeight: 56,
                    titleSpacing: 0,
                    title: Row(
                      children: [
                        Image.asset(
                          'assets/images/hoqooq-logo.png',
                          width: 32,
                          height: 32,
                        ),
                        const SizedBox(width: 8),
                        Text(context.tr('hoqooq_brand')),
                      ],
                    ),
                    actions: [
                      IconButton(
                        onPressed: () => context.go(AppRouter.alerts),
                        icon: const Icon(Icons.notifications_none_rounded),
                        tooltip: context.tr('notifications'),
                      ),
                      const SizedBox(width: 6),
                    ],
                  ),
                  drawer: Drawer(
                    width: 280,
                    backgroundColor: AppColors.ink800,
                    child: _Sidebar(
                      items: items,
                      location: location,
                      userName: user?.fullName ?? '',
                      avatarUrl: versionedAvatarUrl,
                      workspaceName: firmName,
                      isSuperAdmin: isSuperAdmin,
                      isDrawer: true,
                    ),
                  ),
                  body: child,
                );
              },
            );
          },
        );
      },
    );
  }

  List<_NavItem> _superAdminItems(BuildContext context) => [
    _NavItem(context.tr('firms'), Icons.business_outlined, AppRouter.firms),
    _NavItem(context.tr('profile'), Icons.settings_outlined, AppRouter.profile),
  ];

  List<_NavItem> _firmItems(
    BuildContext context, {
    required bool showCases,
    required bool showClients,
    required bool showHearings,
    required bool showTasks,
    required bool showCalendar,
    required bool showFinance,
    required bool showReports,
    required bool showEmployees,
  }) => [
    _NavItem(context.tr('home'), Icons.dashboard_outlined, AppRouter.home),
    if (showCases)
      _NavItem(
        context.tr('cases'),
        Icons.business_center_outlined,
        AppRouter.cases,
      ),
    if (showClients)
      _NavItem(
        context.tr('clients'),
        Icons.people_alt_outlined,
        AppRouter.clients,
      ),
    if (showHearings)
      _NavItem(context.tr('hearings'), Icons.gavel_rounded, AppRouter.hearings),
    if (showTasks)
      _NavItem(context.tr('tasks'), Icons.task_alt_outlined, AppRouter.tasks),
    if (showCalendar)
      _NavItem(
        context.tr('calendar'),
        Icons.calendar_month_outlined,
        AppRouter.calendar,
      ),
    if (showFinance)
      _NavItem(
        context.tr('finance'),
        Icons.account_balance_wallet_outlined,
        AppRouter.finance,
      ),
    if (showReports)
      _NavItem(
        context.tr('reports'),
        Icons.bar_chart_outlined,
        AppRouter.reports,
      ),
    if (showEmployees)
      _NavItem(
        context.tr('employees'),
        Icons.manage_accounts_outlined,
        AppRouter.employees,
      ),

    _NavItem(
      context.tr('notifications'),
      Icons.notifications_none_rounded,
      AppRouter.alerts,
    ),
    _NavItem(context.tr('profile'), Icons.settings_outlined, AppRouter.profile),
  ];
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.userName, this.avatarUrl});
  final String userName;
  final String? avatarUrl;

  @override
  Widget build(BuildContext context) => Container(
    height: 56,
    padding: const EdgeInsets.symmetric(horizontal: 24),
    decoration: const BoxDecoration(
      color: Colors.white,
      border: Border(bottom: BorderSide(color: AppColors.paperLine)),
    ),
    child: Row(
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: TextField(
            readOnly: true,
            decoration: InputDecoration(
              hintText: '${context.tr('search_cases')} ',
              prefixIcon: const Icon(Icons.search_rounded, size: 18),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
            ),
          ),
        ),
        const Spacer(),
        IconButton(
          onPressed: () => context.go(AppRouter.alerts),
          icon: const Icon(Icons.notifications_none_rounded),
          tooltip: context.tr('notifications'),
        ),
        const SizedBox(width: 8),
        _Avatar(name: userName, avatarUrl: avatarUrl, size: 32),
      ],
    ),
  );
}

class _Sidebar extends StatelessWidget {
  const _Sidebar({
    required this.items,
    required this.location,
    required this.userName,
    this.avatarUrl,
    required this.workspaceName,
    required this.isSuperAdmin,
    this.isDrawer = false,
  });

  final List<_NavItem> items;
  final String location;
  final String userName;
  final String? avatarUrl;
  final String? workspaceName;
  final bool isSuperAdmin;
  final bool isDrawer;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 256,
    child: ColoredBox(
      color: AppColors.ink800,
      child: SafeArea(
        child: Column(
          children: [
            Container(
              height: 64,
              padding: const EdgeInsets.symmetric(horizontal: 18),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.white.withValues(alpha: .1)),
                ),
              ),
              child: Row(
                children: [
                  Image.asset(
                    'assets/images/hoqooq-logo.png',
                    width: 38,
                    height: 38,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.tr('hoqooq_brand'),
                          style: AppTypography.h3.copyWith(color: Colors.white),
                        ),
                        Text(
                          isSuperAdmin
                              ? context.tr('platform_admin')
                              : (workspaceName ??
                                    context.tr('legal_case_management')),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.ink300,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 18,
                ),
                itemCount: items.length,
                separatorBuilder: (_, _) => const SizedBox(height: 4),
                itemBuilder: (context, index) {
                  final item = items[index];
                  final selected =
                      location == item.route ||
                      location.startsWith('${item.route}/');
                  return Material(
                    color: selected
                        ? AppColors.brass500.withValues(alpha: .15)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    child: ListTile(
                      dense: true,
                      minTileHeight: 44,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: selected
                            ? const BorderSide(
                                color: AppColors.brass400,
                                width: 0,
                                strokeAlign: BorderSide.strokeAlignInside,
                              )
                            : BorderSide.none,
                      ),
                      leading: Icon(
                        item.icon,
                        size: 19,
                        color: selected ? AppColors.brass300 : AppColors.ink300,
                      ),
                      title: Text(
                        item.label,
                        style: AppTypography.bodyMedium.copyWith(
                          color: selected
                              ? AppColors.brass300
                              : AppColors.ink200,
                          fontWeight: selected
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                      onTap: () {
                        if (isDrawer) Navigator.of(context).pop();
                        context.go(item.route);
                      },
                    ),
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.white.withValues(alpha: .1)),
                ),
              ),
              child: Row(
                children: [
                  _Avatar(name: userName, avatarUrl: avatarUrl, size: 34),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      userName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodyMedium.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () =>
                        context.read<AuthBloc>().add(LogoutRequested()),
                    icon: const Icon(
                      Icons.logout_rounded,
                      color: AppColors.ink300,
                      size: 19,
                    ),
                    tooltip: context.tr('sign_out'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.name, required this.size, this.avatarUrl});
  final String name;
  final double size;
  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    final initial = name.trim().isEmpty
        ? 'H'
        : name.trim().characters.first.toUpperCase();

    final resolvedUrl = resolveImageUrl(avatarUrl);
    if (resolvedUrl != null && resolvedUrl.isNotEmpty) {
      return Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          color: AppColors.brass100,
          shape: BoxShape.circle,
        ),
        clipBehavior: Clip.antiAlias,
        child: Image.network(
          resolvedUrl,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Center(
            child: Text(
              initial,
              style: AppTypography.labelLarge.copyWith(color: AppColors.brass800),
            ),
          ),
        ),
      );
    }

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: AppColors.brass100,
        shape: BoxShape.circle,
      ),
      child: Text(
        initial,
        style: AppTypography.labelLarge.copyWith(color: AppColors.brass800),
      ),
    );
  }
}

class _NavItem {
  const _NavItem(this.label, this.icon, this.route);
  final String label;
  final IconData icon;
  final String route;
}
