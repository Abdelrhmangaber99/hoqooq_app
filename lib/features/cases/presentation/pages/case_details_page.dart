import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../di/injection.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../authentication/domain/entities/user.dart';
import '../../../authentication/presentation/bloc/session_cubit.dart';
import '../../domain/entities/legal_case.dart';
import '../bloc/case_details_bloc.dart';
import '../case_display_helpers.dart';

class CaseDetailsPage extends StatelessWidget {
  final String caseId;

  const CaseDetailsPage({super.key, required this.caseId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          getIt<CaseDetailsBloc>()..add(FetchCaseDetailsRequested(caseId)),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: Text(context.tr('case_details'))),
        body: SafeArea(
          child: BlocBuilder<CaseDetailsBloc, CaseDetailsState>(
            builder: (context, state) {
              if (state is CaseDetailsLoading || state is CaseDetailsInitial) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              } else if (state is CaseDetailsError) {
                return ErrorView(
                  message: state.message,
                  onRetry: () => context.read<CaseDetailsBloc>().add(
                    FetchCaseDetailsRequested(caseId),
                  ),
                );
              } else if (state is CaseDetailsLoaded) {
                return _buildContent(context, state.legalCase);
              }
              return const SizedBox();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, LegalCase legalCase) {
    // BR-026: agreedFee is finance-gated. isFirmAdmin can't yet be
    // reliably detected (no confirmed role.code value — see CLAUDE.md), so
    // per the user's explicit instruction this defaults to hidden rather
    // than shown to everyone.
    final sessionState = getIt<SessionCubit>().state;
    final isFirmAdmin =
        sessionState is SessionAuthenticated && sessionState.user.isFirmAdmin;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.m),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, legalCase),
          const SizedBox(height: AppSpacing.l),
          Text(context.tr('overview'), style: AppTypography.h3),
          const SizedBox(height: AppSpacing.m),
          _buildOverview(context, legalCase, showAgreedFee: isFirmAdmin),
          const SizedBox(height: AppSpacing.l),
          Text(context.tr('team'), style: AppTypography.h3),
          const SizedBox(height: AppSpacing.m),
          _buildTeam(context, legalCase),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, LegalCase legalCase) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.l),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.large,
        border: Border.all(color: AppColors.surfaceLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: caseStatusColor(
                    legalCase.status,
                  ).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  caseStatusLabel(context, legalCase.status),
                  style: AppTypography.labelMedium.copyWith(
                    color: caseStatusColor(legalCase.status),
                    fontSize: 10,
                  ),
                ),
              ),
              Text(
                legalCase.caseNumber,
                style: AppTypography.bodySmall.copyWith(fontSize: 10),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.m),
          Text(legalCase.caseType.name, style: AppTypography.h2),
          const SizedBox(height: 4),
          Text(legalCase.client.fullName, style: AppTypography.bodySmall),
        ],
      ),
    );
  }

  Widget _buildOverview(
    BuildContext context,
    LegalCase legalCase, {
    required bool showAgreedFee,
  }) {
    final dateFormat = DateFormat.yMMMd();
    return Container(
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.medium,
      ),
      child: Column(
        children: [
          _buildInfoRow(
            context.tr('priority'),
            casePriorityLabel(context, legalCase.priority),
          ),
          _buildInfoRow(context.tr('court'), legalCase.defaultCourt.name),
          if (legalCase.openingDate != null)
            _buildInfoRow(
              context.tr('opening_date'),
              dateFormat.format(legalCase.openingDate!),
            ),
          if (legalCase.closingDate != null)
            _buildInfoRow(
              context.tr('closing_date'),
              dateFormat.format(legalCase.closingDate!),
            ),
          if (legalCase.outcomeSummary != null)
            _buildInfoRow(
              context.tr('outcome_summary'),
              legalCase.outcomeSummary!,
            ),
          if (showAgreedFee && legalCase.agreedFee != null)
            _buildInfoRow(
              context.tr('agreed_fee'),
              legalCase.agreedFee!.toStringAsFixed(2),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.textHint,
              ),
            ),
          ),
          Expanded(child: Text(value, style: AppTypography.bodyMedium)),
        ],
      ),
    );
  }

  Widget _buildTeam(BuildContext context, LegalCase legalCase) {
    final members = [
      _TeamEntry(legalCase.primaryLawyer, context.tr('primary_lawyer')),
      ...legalCase.team.map((m) => _TeamEntry(m.user, m.role)),
    ];
    return Column(
      children: members
          .map(
            (entry) => Container(
              margin: const EdgeInsets.only(bottom: AppSpacing.s),
              padding: const EdgeInsets.all(AppSpacing.m),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppRadius.medium,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      entry.user.fullName,
                      style: AppTypography.labelLarge,
                    ),
                  ),
                  Text(entry.roleLabel, style: AppTypography.bodySmall),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

class _TeamEntry {
  final User user;
  final String roleLabel;
  _TeamEntry(this.user, this.roleLabel);
}
