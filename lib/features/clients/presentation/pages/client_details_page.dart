import 'package:dartz/dartz.dart' hide State;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/network/api_result.dart';
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
import '../../../courts/domain/entities/case_type_reference.dart';
import '../client_display_helpers.dart';

/// موكل detail — mirrors the reference web app's `ClientDetail.jsx`.
///
/// There is no separate client id space: `caseId` is really a Case id, and
/// this page fetches that Case and reads its `clientSnapshot` (same reasoning
/// as [ClientsPage]).
class ClientDetailsPage extends StatefulWidget {
  const ClientDetailsPage({super.key, required this.caseId});

  final String caseId;

  @override
  State<ClientDetailsPage> createState() => _ClientDetailsPageState();
}

class _ClientDetailsPageState extends State<ClientDetailsPage> {
  late ApiResult<LegalCase> _case;

  @override
  void initState() {
    super.initState();
    _case = getIt<ICaseRepository>().getCaseDetails(widget.caseId);
  }

  void _reload() {
    setState(
      () => _case = getIt<ICaseRepository>().getCaseDetails(widget.caseId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: AppBar(title: Text(context.tr('client_profile'))),
      body: SafeArea(
        child: FutureBuilder<Either<Failure, LegalCase>>(
          future: _case,
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
                onRetry: _reload,
              ),
              (legalCase) {
                final client = legalCase.clientSnapshot;
                if (client == null) {
                  return EmptyState(
                    icon: Icons.person_off_outlined,
                    message: context.tr('client_not_found'),
                  );
                }
                return _ClientDetailsBody(legalCase: legalCase);
              },
            );
          },
        ),
      ),
    );
  }
}

class _ClientDetailsBody extends StatelessWidget {
  const _ClientDetailsBody({required this.legalCase});

  final LegalCase legalCase;

  @override
  Widget build(BuildContext context) {
    final client = legalCase.clientSnapshot!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.m),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _InfoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: AppColors.brass100,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        client.name.trim().isEmpty
                            ? '?'
                            : client.name.trim().characters.first.toUpperCase(),
                        style: AppTypography.h2.copyWith(
                          color: AppColors.brass800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(client.name, style: AppTypography.h3),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                isCompanyClient(client.clientType)
                                    ? Icons.business_outlined
                                    : Icons.person_outline_rounded,
                                size: 13,
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
                const SizedBox(height: AppSpacing.m),
                _DetailLine(
                  icon: Icons.phone_outlined,
                  label: context.tr('phone'),
                  value: client.phone,
                  mono: true,
                ),
                _DetailLine(
                  icon: Icons.mail_outline_rounded,
                  label: context.tr('email'),
                  value: client.email,
                ),
                if (_hasValue(client.nationalId))
                  _DetailLine(
                    icon: Icons.badge_outlined,
                    label: context.tr('national_id'),
                    value: client.nationalId,
                    mono: true,
                  ),
                if (_hasValue(client.registrationNo))
                  _DetailLine(
                    icon: Icons.numbers_rounded,
                    label: context.tr('registration_number'),
                    value: client.registrationNo,
                    mono: true,
                  ),
                if (_hasValue(client.address))
                  _DetailLine(
                    icon: Icons.location_on_outlined,
                    label: context.tr('address'),
                    value: client.address,
                  ),
                if (_hasValue(client.notes))
                  _DetailLine(
                    icon: Icons.sticky_note_2_outlined,
                    label: context.tr('notes'),
                    value: client.notes,
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.m),
          Text(context.tr('case'), style: AppTypography.h3),
          const SizedBox(height: AppSpacing.s),
          _InfoCard(
            padding: EdgeInsets.zero,
            child: InkWell(
              borderRadius: AppRadius.medium,
              onTap: () => context.push('${AppRouter.cases}/${legalCase.id}'),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.m),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FutureBuilder<List<CaseTypeReference>>(
                            future: loadCaseTypeReferences(),
                            builder: (context, snapshot) => Text(
                              caseTypeLabelFor(
                                languageCode: Localizations.localeOf(
                                  context,
                                ).languageCode,
                                caseTypeId: legalCase.caseTypeId,
                                caseType: legalCase.caseType,
                                caseTypes: snapshot.data ?? const [],
                                fallback:
                                    legalCase.title ?? legalCase.caseNumber,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.labelLarge,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            legalCaseCourtReference(legalCase),
                            style: AppTypography.bodySmall.copyWith(
                              fontFamily: AppTypography.monoFont,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    _CaseStatusChip(
                      label: caseStatusLabel(context, legalCase.status),
                      color: caseStatusColor(legalCase.status),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.chevron_left_rounded,
                      color: AppColors.ink300,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static bool _hasValue(String? value) =>
      value != null && value.trim().isNotEmpty;
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) => Container(
    padding: padding ?? const EdgeInsets.all(AppSpacing.m),
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
    child: child,
  );
}

class _DetailLine extends StatelessWidget {
  const _DetailLine({
    required this.icon,
    required this.label,
    required this.value,
    this.mono = false,
  });

  final IconData icon;
  final String label;
  final String? value;
  final bool mono;

  @override
  Widget build(BuildContext context) {
    final text = (value == null || value!.trim().isEmpty) ? '—' : value!;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 15, color: AppColors.ink400),
          const SizedBox(width: 8),
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.ink400,
              ),
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: AppTypography.bodyMedium.copyWith(
                fontFamily: mono ? AppTypography.monoFont : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CaseStatusChip extends StatelessWidget {
  const _CaseStatusChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
    decoration: BoxDecoration(
      color: color.withValues(alpha: .12),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      label,
      style: AppTypography.bodySmall.copyWith(
        color: color,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}
