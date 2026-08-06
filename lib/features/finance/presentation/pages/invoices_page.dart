import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/auth/permission_check.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/router/app_router.dart';
import '../../../../di/injection.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../domain/entities/invoice.dart';
import '../../domain/entities/invoice_status.dart';
import '../bloc/invoices_bloc.dart';
import '../finance_display_helpers.dart';

/// The Finance hub — Analytics and Cases-Summary are reachable via the
/// AppBar icons here rather than separate bottom-nav entries, per the
/// approved M6 plan (no bottom-nav restructure).
class InvoicesPage extends StatelessWidget {
  const InvoicesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<InvoicesBloc>()..add(FetchInvoicesRequested()),
      // `Builder` gives everything below a context that's a genuine
      // descendant of this `BlocProvider` — same fix class as
      // `CasesPage`/`ClientsPage` (see those files' doc comments).
      child: Builder(
        builder: (context) => Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: Text(context.tr('invoices')),
            actions: [
              IconButton(
                icon: const Icon(Icons.bar_chart_outlined),
                tooltip: context.tr('financial_analytics'),
                onPressed: () => context.push('${AppRouter.finance}/analytics'),
              ),
              IconButton(
                icon: const Icon(Icons.list_alt_outlined),
                tooltip: context.tr('cases_financial_summary'),
                onPressed: () =>
                    context.push('${AppRouter.finance}/cases-summary'),
              ),
            ],
          ),
          floatingActionButton: currentUserHasPerm('finance.create')
              ? FloatingActionButton(
                  backgroundColor: AppColors.primary,
                  onPressed: () async {
                    final created = await context.push<bool>(
                      '${AppRouter.finance}/new',
                    );
                    if (created == true && context.mounted) {
                      context.read<InvoicesBloc>().add(
                        FetchInvoicesRequested(),
                      );
                    }
                  },
                  child: const Icon(Icons.add),
                )
              : null,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppSpacing.m),
                  _buildStatusFilters(context),
                  const SizedBox(height: AppSpacing.m),
                  Expanded(
                    child: BlocBuilder<InvoicesBloc, InvoicesState>(
                      builder: (context, state) {
                        if (state is InvoicesLoading ||
                            state is InvoicesInitial) {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                            ),
                          );
                        } else if (state is InvoicesError) {
                          return ErrorView(
                            message: state.message,
                            isForbidden: state.isForbidden,
                            onRetry: () => context.read<InvoicesBloc>().add(
                              FetchInvoicesRequested(),
                            ),
                          );
                        } else if (state is InvoicesLoaded) {
                          if (state.invoices.isEmpty) {
                            return EmptyState(
                              message: context.tr('no_invoices_found'),
                            );
                          }
                          return _buildInvoicesList(context, state.invoices);
                        }
                        return const SizedBox();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusFilters(BuildContext context) {
    return BlocBuilder<InvoicesBloc, InvoicesState>(
      builder: (context, state) {
        final activeFilter = state is InvoicesLoaded
            ? state.statusFilter
            : null;
        final filters = <InvoiceStatus?>[
          null,
          InvoiceStatus.draft,
          InvoiceStatus.sent,
          InvoiceStatus.partial,
          InvoiceStatus.paid,
          InvoiceStatus.cancelled,
        ];
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: filters.map((status) {
              final isSelected = status == activeFilter;
              final label = status == null
                  ? context.tr('all')
                  : invoiceStatusLabel(context, status);
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(label),
                  selected: isSelected,
                  onSelected: (_) => context.read<InvoicesBloc>().add(
                    InvoicesStatusFilterChanged(status),
                  ),
                  backgroundColor: AppColors.surface,
                  selectedColor: AppColors.primary,
                  labelStyle: AppTypography.labelMedium.copyWith(
                    color: isSelected ? Colors.black : AppColors.textSecondary,
                    fontSize: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  side: BorderSide.none,
                  showCheckmark: false,
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildInvoicesList(BuildContext context, List<Invoice> invoices) {
    return ListView.separated(
      itemCount: invoices.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.m),
      itemBuilder: (context, index) {
        final invoice = invoices[index];
        return GestureDetector(
          onTap: () => context.push('${AppRouter.finance}/${invoice.id}'),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        invoice.invoiceNumber,
                        style: AppTypography.labelLarge,
                      ),
                    ),
                    _buildBadge(
                      invoiceStatusLabel(context, invoice.status),
                      invoiceStatusColor(invoice.status),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  invoice.client?.fullName ?? context.tr('unknown'),
                  style: AppTypography.bodySmall,
                ),
                const SizedBox(height: 8),
                Text(
                  invoice.grandTotal.toStringAsFixed(2),
                  style: AppTypography.labelMedium,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: AppTypography.labelMedium.copyWith(color: color, fontSize: 10),
      ),
    );
  }
}
