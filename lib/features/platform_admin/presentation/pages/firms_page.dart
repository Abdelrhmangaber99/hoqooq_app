import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/localization/error_messages.dart';
import '../../../../core/network/dio_error_mapper.dart';
import '../../../../core/router/app_route_observer.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../di/injection.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../domain/platform_admin_contract.dart';

class FirmsPage extends StatefulWidget {
  const FirmsPage({super.key});

  @override
  State<FirmsPage> createState() => _FirmsPageState();
}

class _FirmsPageState extends State<FirmsPage> with RouteAware {
  late Future<List<dynamic>> _firms;

  @override
  void initState() {
    super.initState();
    _firms = _load();
  }

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

  /// Firm details was closed: re-read the registry, whichever way it was
  /// left, so a status or subscription change is reflected immediately.
  @override
  void didPopNext() {
    if (mounted) setState(() => _firms = _load());
  }

  Future<List<dynamic>> _load() async {
    final response = await getIt<Dio>().get('/tenants');
    // Inactive firms must remain visible to the Super Admin: this page is
    // also the only place from which that firm can be inspected/reactivated.
    final firms = PlatformAdminContract.collection(response.data);
    Object? platformUsersData;
    try {
      final usersResponse = await getIt<Dio>().get('/users');
      platformUsersData = usersResponse.data;
    } catch (_) {
      // Older deployments may not expose the platform roster route.
    }
    return Future.wait(
      firms.map((firm) async {
        final copy = PlatformAdminContract.normalizeTenant(firm);
        // The deployed platform registry embeds the Firm Admin directly, and
        // it is the only readable source for one: the backend has no
        // `GET /users` and refuses `GET /employees` to a Super Admin. Use it as
        // the primary source so the admin row renders even when the per-firm
        // enrichment below cannot run.
        final registryAdmin = copy['firmAdmin'];
        if (registryAdmin is Map<String, dynamic>) {
          copy['_firmAdmin'] = registryAdmin;
        }
        final firmId = firm['id']?.toString();
        if (firmId != null) {
          try {
            final overview = (await getIt<Dio>().get('/tenants/$firmId')).data;
            var users = [
              ...PlatformAdminContract.overviewEmployees(overview),
              if (PlatformAdminContract.overviewAdmin(overview)
                  case final admin?)
                admin,
            ];
            if (users.isEmpty) {
              users = PlatformAdminContract.usersForFirm(
                platformUsersData,
                firmId,
              );
            }
            if (users.isEmpty) {
              try {
                final employees = await getIt<Dio>().get(
                  '/employees',
                  queryParameters: {'tenantId': firmId},
                );
                users = PlatformAdminContract.overviewEmployees({
                  'employees': employees.data is List
                      ? employees.data
                      : const [],
                });
              } catch (_) {
                // Keep the firm card usable when the fallback is unavailable.
              }
            }
            copy['_employees'] = users;
            final ownerId = firm['ownerUserId']?.toString();
            if (users.isNotEmpty) {
              copy['_firmAdmin'] = users.firstWhere(
                (user) =>
                    user['id']?.toString() == ownerId ||
                    // Employee records (`GET /employees`) carry the account id
                    // under `userId`/`user.id`, not `id` — that one is the
                    // Employee id, so match all three shapes against the
                    // firm's `ownerUserId`.
                    user['userId']?.toString() == ownerId ||
                    (user['user'] is Map &&
                        (user['user'] as Map)['id']?.toString() == ownerId) ||
                    user['accountType']?.toString() == 'FIRM_ADMIN',
                // The supported overview returns accounts oldest-first. On
                // older deployments it omits accountType/owner metadata, so
                // the first account is the originally provisioned Firm Admin.
                orElse: () => users.first,
              );
            }
          } catch (_) {
            // Keep the firm card and navigation available if enrichment fails.
          }
        }
        return copy;
      }),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.background,
    appBar: AppBar(title: Text(context.tr('firms'))),
    floatingActionButton: FloatingActionButton.extended(
      onPressed: () async {
        await context.push<bool>(AppRouter.provisionFirm);
        // Re-read on return regardless of the popped result, so a newly
        // provisioned firm appears even when the route carries no result.
        if (mounted) setState(() => _firms = _load());
      },
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.textOnPrimary,
      icon: const Icon(Icons.add_business_outlined),
      label: Text(context.tr('provision_firm')),
    ),
    body: FutureBuilder<List<dynamic>>(
      future: _firms,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          final error = snapshot.error;
          return _Failure(
            message: error is DioException
                ? mapDioError(error).message
                : context.tr('could_not_load_firm'),
            onRetry: () => setState(() => _firms = _load()),
          );
        }
        final firms = snapshot.data ?? const [];
        if (firms.isEmpty) {
          return Center(child: Text(context.tr('no_firms_found')));
        }
        return RefreshIndicator(
          onRefresh: () async => setState(() => _firms = _load()),
          child: ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.m),
            itemCount: firms.length,
            separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.s),
            itemBuilder: (_, index) => _FirmCard(
              firm: firms[index] as Map<String, dynamic>,
              onAdminTap: () {
                final firm = firms[index] as Map<String, dynamic>;
                final admin = firm['_firmAdmin'];
                if (admin is! Map) return;
                context.push(
                  AppRouter.firmAdminDetails(firm['id'].toString()),
                  extra: {'firm': firm, 'admin': admin},
                );
              },
              // Re-read the list on return, unconditionally: firm details
              // can change the subscription (plan / activate / cancel) and
              // the firm status, and this card renders both. Waiting on a
              // popped result left the list showing the previous plan and
              // "ACTIVE" after a successful change.
              onTap: () async {
                await context.push<bool>(
                  '${AppRouter.firms}/${(firms[index] as Map<String, dynamic>)['id']}',
                  extra: firms[index],
                );
                if (mounted) setState(() => _firms = _load());
              },
            ),
          ),
        );
      },
    ),
  );
}

class _FirmCard extends StatelessWidget {
  const _FirmCard({
    required this.firm,
    required this.onTap,
    required this.onAdminTap,
  });
  final Map<String, dynamic> firm;
  final VoidCallback onTap;
  final VoidCallback onAdminTap;
  @override
  Widget build(BuildContext context) {
    final subscription = PlatformAdminContract.currentSubscription(firm);
    final firmAdmin = firm['_firmAdmin'] is Map
        ? firm['_firmAdmin'] as Map
        : null;
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.medium,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.m),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.medium,
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: .12),
                    borderRadius: AppRadius.medium,
                  ),
                  child: const Icon(
                    Icons.account_balance_outlined,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: AppSpacing.m),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        firm['name'] as String? ?? context.tr('unnamed_firm'),
                        style: AppTypography.h3,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        firm['contactEmail'] as String? ?? '',
                        style: AppTypography.bodySmall,
                      ),
                      if (firmAdmin != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            'Firm Admin: ${firmAdmin['fullName'] ?? firmAdmin['email'] ?? '—'}',
                            style: AppTypography.bodySmall,
                          ),
                        ),
                      if (subscription != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            '${subscription['status'] ?? '—'} · ${((subscription['plan'] as Map?)?['name']) ?? 'No plan'}',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          'Firm status: ${firm['status']?.toString().toUpperCase() ?? '—'}',
                          style: AppTypography.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded),
              ],
            ),
            if (firmAdmin != null) ...[
              const Divider(height: AppSpacing.l),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.admin_panel_settings_outlined),
                title: Text(
                  firmAdmin['fullName']?.toString() ??
                      firmAdmin['email']?.toString() ??
                      'Firm Admin',
                ),
                subtitle: Text(
                  [
                    firmAdmin['email'],
                    firmAdmin['status'],
                  ].where((value) => value != null).join(' · '),
                ),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: onAdminTap,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Failure extends StatelessWidget {
  const _Failure({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.l),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 44, color: AppColors.error),
          const SizedBox(height: AppSpacing.m),
          Text(
            localizedErrorMessage(context, message),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.m),
          AppButton(text: context.tr('try_again'), onPressed: onRetry),
        ],
      ),
    ),
  );
}
