import 'package:dartz/dartz.dart' hide State;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/auth/permission_check.dart';
import '../../../../core/auth/permission_codes.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/router/app_route_observer.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../di/injection.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../cases/domain/entities/legal_case.dart';
import '../../../cases/domain/repository/i_case_repository.dart';
import '../../../cases/presentation/case_display_helpers.dart';
import '../client_display_helpers.dart';

/// الموكلين (Clients) — mirrors the reference web app's `Clients.jsx`.
///
/// There is no standalone Clients resource: a client is an immutable
/// `clientSnapshot` embedded 1:1 on a Case, entered only at case-creation
/// time. `GET /cases` joins `clientSnapshot` server-side, so this is a single
/// request and each row maps to exactly one case (the backend has no concept
/// of one real-world person spanning multiple cases). The page is therefore
/// gated by `case.view`, exactly like the web sidebar entry.
class ClientsPage extends StatefulWidget {
  const ClientsPage({super.key});

  @override
  State<ClientsPage> createState() => _ClientsPageState();
}

class _ClientsPageState extends State<ClientsPage> with RouteAware {
  late ApiResult<List<LegalCase>> _cases;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _cases = _load();
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

  @override
  void didPopNext() {
    if (mounted) setState(_reload);
  }

  ApiResult<List<LegalCase>> _load() => getIt<ICaseRepository>().getCases();

  void _reload() => _cases = _load();

  @override
  Widget build(BuildContext context) {
    if (!currentUserHasPerm(PermissionCodes.caseView)) {
      return Scaffold(
        backgroundColor: AppColors.paper,
        body: SafeArea(
          child: ErrorView(
            message: context.tr('no_permission_message'),
            isForbidden: true,
            onRetry: () {},
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.paper,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.m),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(context.tr('clients'), style: AppTypography.h1),
              const SizedBox(height: AppSpacing.l),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 340),
                child: TextField(
                  onChanged: (value) =>
                      setState(() => _query = value.trim().toLowerCase()),
                  style: AppTypography.bodyMedium,
                  decoration: InputDecoration(
                    hintText: context.tr('search_clients'),
                    prefixIcon: const Icon(Icons.search_rounded, size: 19),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.l),
              Expanded(
                child: FutureBuilder<Either<Failure, List<LegalCase>>>(
                  future: _cases,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState != ConnectionState.done) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final result = snapshot.data;
                    if (result == null) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return result.fold(
                      (failure) => ErrorView(
                        message: failure.message,
                        isForbidden: failure is ForbiddenFailure,
                        onRetry: () => setState(_reload),
                      ),
                      _buildRows,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRows(List<LegalCase> cases) {
    final rows = cases
        .where((c) => c.clientSnapshot != null)
        .where((c) {
          if (_query.isEmpty) return true;
          return (c.clientSnapshot!.name).toLowerCase().contains(_query);
        })
        .toList();

    if (rows.isEmpty) {
      return EmptyState(
        icon: Icons.people_alt_outlined,
        message: context.tr('no_clients_found'),
      );
    }

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 390,
        mainAxisExtent: 244,
        crossAxisSpacing: AppSpacing.m,
        mainAxisSpacing: AppSpacing.m,
      ),
      itemCount: rows.length,
      itemBuilder: (context, index) => _ClientCard(legalCase: rows[index]),
    );
  }
}

class _ClientCard extends StatelessWidget {
  const _ClientCard({required this.legalCase});

  final LegalCase legalCase;

  @override
  Widget build(BuildContext context) {
    final client = legalCase.clientSnapshot!;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.paperLine),
        borderRadius: AppRadius.medium,
        boxShadow: const [
          BoxShadow(
            color: Color(0x080B192F),
            blurRadius: 12,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _ClientAvatar(name: client.name),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      client.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.labelLarge.copyWith(
                        color: AppColors.ink800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Icon(
                          isCompanyClient(client.clientType)
                              ? Icons.business_outlined
                              : Icons.person_outline_rounded,
                          size: 12,
                          color: AppColors.ink400,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          clientTypeLabel(context, client.clientType),
                          style: AppTypography.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _ContactLine(
            icon: Icons.phone_outlined,
            text: client.phone ?? '—',
          ),
          const SizedBox(height: 6),
          _ContactLine(
            icon: Icons.mail_outline_rounded,
            text: client.email ?? '—',
          ),
          const Spacer(),
          const Divider(height: 1),
          const SizedBox(height: 8),
          Row(
            children: [
              Flexible(
                child: Text(
                  legalCaseCourtReference(legalCase),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodySmall.copyWith(
                    fontFamily: AppTypography.monoFont,
                  ),
                ),
              ),
              const Spacer(),
              _StatusBadge(
                label: caseStatusLabel(context, legalCase.status),
                color: caseStatusColor(legalCase.status),
              ),
            ],
          ),
          const SizedBox(height: 10),
          OutlinedButton(
            onPressed: () =>
                context.push(AppRouter.clientDetails(legalCase.id)),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(38),
              side: const BorderSide(color: AppColors.paperLine),
              foregroundColor: AppColors.ink700,
              shape: const RoundedRectangleBorder(
                borderRadius: AppRadius.small,
              ),
            ),
            child: Text(context.tr('view_details')),
          ),
        ],
      ),
    );
  }
}

class _ClientAvatar extends StatelessWidget {
  const _ClientAvatar({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final initial = name.trim().isEmpty
        ? '?'
        : name.trim().characters.first.toUpperCase();
    return Container(
      width: 46,
      height: 46,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: AppColors.brass100,
        shape: BoxShape.circle,
      ),
      child: Text(
        initial,
        style: AppTypography.h3.copyWith(color: AppColors.brass800),
      ),
    );
  }
}

class _ContactLine extends StatelessWidget {
  const _ContactLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 13, color: AppColors.ink400),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.ink500,
              fontFamily: AppTypography.monoFont,
            ),
          ),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: AppTypography.bodySmall.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 10,
        ),
      ),
    );
  }
}
