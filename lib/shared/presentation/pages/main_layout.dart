import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/permission_codes.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/cache_busted_url.dart';
import '../../../core/widgets/app_avatar.dart';
import '../../../features/authentication/presentation/bloc/auth_bloc.dart';
import '../../../features/authentication/presentation/bloc/session_cubit.dart';
import '../../../features/subscriptions/presentation/bloc/subscription_cubit.dart';
import '../../../features/subscriptions/presentation/bloc/subscription_state.dart';
import '../../../features/subscriptions/presentation/widgets/firm_logo_image.dart';

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
            // The firm's own logo, shown beside its name in the sidebar. Its
            // `logoUrl` is a storage object key, not a URL, so it is fetched
            // as bytes by FirmLogoImage rather than with Image.network.
            String? firmLogoKey;
            Object? firmLogoVersion;
            if (subState is SubscriptionLoaded) {
              firmName = subState.firm['name'] as String? ?? firmName;
              firmLogoKey = subState.firm['logoUrl'] as String?;
              firmLogoVersion = subState.firm['updatedAt'];
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
                    // `GET /settings` is `@RequirePermissions(settings.read)`,
                    // which is `firm.profile.read` in v3 — so a holder of that
                    // code may open it too, not only a Firm Admin.
                    showSettings:
                        user?.isFirmAdmin == true ||
                        user?.hasPerm(PermissionCodes.firmProfileRead) == true,
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
                          workspaceLogoKey: firmLogoKey,
                          workspaceLogoVersion: firmLogoVersion,
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
                    titleSpacing: 16,
                    // The internal logo is the full horizontal lockup: mark,
                    // wordmark and tagline. It therefore already carries the
                    // brand name, so a separate `hoqooq_brand` label beside it
                    // only repeated what the image says.
                    title: Image.asset(
                      'assets/images/app_internal_logo.jpeg',
                      height: 30,
                      fit: BoxFit.contain,
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
                      workspaceLogoKey: firmLogoKey,
                      workspaceLogoVersion: firmLogoVersion,
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
  ];

  List<_NavItem> _firmItems(
    BuildContext context, {
    required bool showCases,
    required bool showClients,
    required bool showHearings,
    required bool showTasks,
    required bool showFinance,
    required bool showReports,
    required bool showEmployees,
    required bool showSettings,
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
    // Both of these pages existed and were routed, but had no sidebar entry —
    // the reference web app's "الإعدادات" group is where a user reaches them,
    // and on mobile Settings was reachable from nowhere at all.
    if (showSettings)
      _NavItem(context.tr('settings'), Icons.tune_outlined, AppRouter.settings),

    _NavItem(
      context.tr('notifications'),
      Icons.notifications_none_rounded,
      AppRouter.alerts,
    ),
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
        AppAvatar(name: userName, imageUrl: avatarUrl, size: 32),
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
    this.workspaceLogoKey,
    this.workspaceLogoVersion,
    this.isDrawer = false,
  });

  final List<_NavItem> items;
  final String location;
  final String userName;
  final String? avatarUrl;
  final String? workspaceName;
  final String? workspaceLogoKey;
  final Object? workspaceLogoVersion;
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
            // Stacked, not a row: the web build puts the wordmark above the
            // workspace badge, with 20px of padding at the top and 16 below.
            Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.white.withValues(alpha: .1)),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // The sidebar is the workspace's identity, so it leads with
                  // the FIRM's own uploaded logo — the product wordmark only
                  // stands in when the firm has not uploaded one (or for a
                  // platform account, which has no firm at all).
                  //
                  // `logoUrl` is a storage object key, not a URL, and reading
                  // the bytes back needs the bearer token, so FirmLogoImage
                  // fetches them through the authenticated `/tenants/my-firm/logo`
                  // route — `Image.network` on the key always 404'd.
                  if (workspaceLogoKey != null && workspaceLogoKey!.isNotEmpty)
                    Container(
                      width: 44,
                      height: 44,
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: FirmLogoImage(
                        logoKey: workspaceLogoKey,
                        version: workspaceLogoVersion,
                      ),
                    )
                  else
                    // The menu is a dark surface, so the product lockup is the
                    // white cut. The colour source asset is an opaque JPEG and
                    // would otherwise paint a white box on the brown menu; the
                    // web build reaches the same result by inverting its logo
                    // with a CSS filter.
                    Image.asset(
                      'assets/images/hoqooq-lockup-white.png',
                      height: 44,
                      fit: BoxFit.contain,
                    ),
                  const SizedBox(height: 12),
                  // The workspace name is treated as a badge here rather than as
                  // body copy, matching the brass pill the web build renders.
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.brass500.withValues(alpha: .15),
                      border: Border.all(
                        color: AppColors.brass500.withValues(alpha: .25),
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      isSuperAdmin
                          ? context.tr('platform_admin')
                          : (workspaceName ??
                                context.tr('legal_case_management')),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.brass300,
                        fontSize: 11,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              // Built eagerly rather than with a lazily-materialised ListView.
              // The menu is a fixed, short list, and laying every entry out
              // keeps the whole of it in the tree — and therefore in the
              // semantics tree — even when it is taller than a short viewport.
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 18,
                ),
                child: Column(
                  children: [
                    for (var i = 0; i < items.length; i++)
                      Padding(
                        padding: EdgeInsets.only(
                          bottom: i == items.length - 1 ? 0 : 4,
                        ),
                        child: _buildNavTile(context, items[i]),
                      ),
                  ],
                ),
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
                  AppAvatar(name: userName, imageUrl: avatarUrl, size: 34),
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

  Widget _buildNavTile(BuildContext context, _NavItem item) {
    final selected =
        location == item.route || location.startsWith('${item.route}/');
    return Material(
      color: selected
          ? AppColors.brass500.withValues(alpha: .15)
          : Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: [
          // The active pill carries a 2px brass bar on its leading edge, the
          // same `border-r-2` accent the web build draws on the selected nav
          // item. Rendered as a sibling rather than as a border because a
          // rounded decoration cannot take a single-sided border.
          SizedBox(
            width: 2,
            height: 44,
            child: selected
                ? const ColoredBox(color: AppColors.brass400)
                : null,
          ),
          Expanded(
            child: ListTile(
              dense: true,
              minTileHeight: 44,
              leading: Icon(
                item.icon,
                size: 19,
                color: selected ? AppColors.brass300 : AppColors.ink300,
              ),
              title: Text(
                item.label,
                style: AppTypography.bodyMedium.copyWith(
                  // The web build paints inactive items in `text-ink-300` and
                  // the selected one in `text-brass-300`.
                  color: selected ? AppColors.brass300 : AppColors.ink300,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
              onTap: () {
                if (isDrawer) Navigator.of(context).pop();
                context.go(item.route);
              },
            ),
          ),
        ],
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
