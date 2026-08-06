import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../di/injection.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../domain/entities/case_financial_summary.dart';
import '../bloc/cases_financial_summary_bloc.dart';
import '../finance_display_helpers.dart';

class CasesFinancialSummaryPage extends StatelessWidget {
  const CasesFinancialSummaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          getIt<CasesFinancialSummaryBloc>()
            ..add(FetchCasesFinancialSummaryRequested()),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: Text(context.tr('cases_financial_summary'))),
        body: SafeArea(
          child:
              BlocBuilder<
                CasesFinancialSummaryBloc,
                CasesFinancialSummaryState
              >(
                builder: (context, state) {
                  if (state is CasesFinancialSummaryLoading ||
                      state is CasesFinancialSummaryInitial) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    );
                  } else if (state is CasesFinancialSummaryError) {
                    return ErrorView(
                      message: state.message,
                      isForbidden: state.isForbidden,
                      onRetry: () => context
                          .read<CasesFinancialSummaryBloc>()
                          .add(FetchCasesFinancialSummaryRequested()),
                    );
                  } else if (state is CasesFinancialSummaryLoaded) {
                    if (state.summaries.isEmpty) {
                      return EmptyState(message: context.tr('no_cases_found'));
                    }
                    return _buildList(context, state.summaries);
                  }
                  return const SizedBox();
                },
              ),
        ),
      ),
    );
  }

  Widget _buildList(
    BuildContext context,
    List<CaseFinancialSummary> summaries,
  ) {
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.m),
      itemCount: summaries.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.m),
      itemBuilder: (context, index) {
        final summary = summaries[index];
        return Container(
          padding: const EdgeInsets.all(AppSpacing.m),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppRadius.medium,
            border: Border.all(color: AppColors.surfaceLight),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      summary.caseNumber,
                      style: AppTypography.labelLarge,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: paymentStatusColor(
                        summary.paymentStatus,
                      ).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      paymentStatusLabel(context, summary.paymentStatus),
                      style: TextStyle(
                        color: paymentStatusColor(summary.paymentStatus),
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(summary.clientName, style: AppTypography.bodySmall),
              const SizedBox(height: 8),
              Text(
                '${context.tr('outstanding_balance')}: '
                '${summary.outstandingBalance.toStringAsFixed(2)}',
                style: AppTypography.bodyMedium,
              ),
            ],
          ),
        );
      },
    );
  }
}
