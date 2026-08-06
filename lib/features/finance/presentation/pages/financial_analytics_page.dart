import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../di/injection.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../domain/entities/financial_analytics.dart';
import '../bloc/financial_analytics_bloc.dart';

class FinancialAnalyticsPage extends StatelessWidget {
  const FinancialAnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          getIt<FinancialAnalyticsBloc>()
            ..add(FetchFinancialAnalyticsRequested()),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: Text(context.tr('financial_analytics'))),
        body: SafeArea(
          child: BlocBuilder<FinancialAnalyticsBloc, FinancialAnalyticsState>(
            builder: (context, state) {
              if (state is FinancialAnalyticsLoading ||
                  state is FinancialAnalyticsInitial) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              } else if (state is FinancialAnalyticsError) {
                return ErrorView(
                  message: state.message,
                  isForbidden: state.isForbidden,
                  onRetry: () => context.read<FinancialAnalyticsBloc>().add(
                    FetchFinancialAnalyticsRequested(),
                  ),
                );
              } else if (state is FinancialAnalyticsLoaded) {
                return _buildContent(context, state.analytics);
              }
              return const SizedBox();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, FinancialAnalytics analytics) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.m),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildMetricCard(
                context.tr('total_invoiced'),
                analytics.totalInvoiced.toStringAsFixed(2),
              ),
              const SizedBox(width: AppSpacing.m),
              _buildMetricCard(
                context.tr('total_paid'),
                analytics.totalPaid.toStringAsFixed(2),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.m),
          Row(
            children: [
              _buildMetricCard(
                context.tr('total_outstanding'),
                analytics.totalOutstanding.toStringAsFixed(2),
              ),
              const SizedBox(width: AppSpacing.m),
              _buildMetricCard(
                context.tr('collection_rate'),
                '${analytics.collectionRatePercentage.toStringAsFixed(1)}%',
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.m),
          Row(
            children: [
              _buildMetricCard(
                context.tr('gross_revenue'),
                analytics.grossRevenue.toStringAsFixed(2),
              ),
              const SizedBox(width: AppSpacing.m),
              _buildMetricCard(
                context.tr('net_profit'),
                analytics.netProfitEstimate.toStringAsFixed(2),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.l),
          Text(context.tr('invoices'), style: AppTypography.h3),
          const SizedBox(height: AppSpacing.m),
          Container(
            padding: const EdgeInsets.all(AppSpacing.m),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppRadius.medium,
              border: Border.all(color: AppColors.surfaceLight),
            ),
            child: Column(
              children: [
                _buildCountRow(
                  context.tr('invoices'),
                  analytics.totalInvoicesCount,
                ),
                _buildCountRow(context.tr('paid'), analytics.paidInvoicesCount),
                _buildCountRow(
                  context.tr('partial'),
                  analytics.partialInvoicesCount,
                ),
                _buildCountRow(
                  context.tr('unpaid'),
                  analytics.unpaidInvoicesCount,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.m),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.medium,
          border: Border.all(color: AppColors.surfaceLight),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: AppTypography.h2),
            Text(label, style: AppTypography.bodySmall),
          ],
        ),
      ),
    );
  }

  Widget _buildCountRow(String label, int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary)),
          Text('$count', style: AppTypography.bodyMedium),
        ],
      ),
    );
  }
}
