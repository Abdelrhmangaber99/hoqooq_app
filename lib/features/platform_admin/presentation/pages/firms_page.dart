import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/network/dio_error_mapper.dart';
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

class _FirmsPageState extends State<FirmsPage> {
  late Future<List<dynamic>> _firms;

  @override
  void initState() {
    super.initState();
    _firms = _load();
  }

  Future<List<dynamic>> _load() async {
    final response = await getIt<Dio>().get('/tenants');
    return response.data as List<dynamic>;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.background,
    appBar: AppBar(title: Text(context.tr('firms'))),
    floatingActionButton: FloatingActionButton.extended(
      onPressed: () async {
        final created = await context.push<bool>(AppRouter.provisionFirm);
        if (created == true && mounted) setState(() => _firms = _load());
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
          return _Failure(
            message: mapDioError(snapshot.error as DioException).message,
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
              // Re-read the list on return, unconditionally: firm details
              // can change the subscription (plan / activate / cancel) and
              // the firm status, and this card renders both. Waiting on a
              // popped result left the list showing the previous plan and
              // "ACTIVE" after a successful change.
              onTap: () async {
                await context.push<bool>(
                  '${AppRouter.firms}/${(firms[index] as Map<String, dynamic>)['id']}',
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
  const _FirmCard({required this.firm, required this.onTap});
  final Map<String, dynamic> firm;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final subscription = PlatformAdminContract.currentSubscription(firm);
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.medium,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.m),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.medium,
        ),
        child: Row(
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
                      'Firm status: ${firm['status'] ?? '—'}',
                      style: AppTypography.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
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
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.m),
          AppButton(text: 'Try again', onPressed: onRetry),
        ],
      ),
    ),
  );
}
