import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/router/app_router.dart';
import '../../../../di/injection.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../domain/entities/case_status.dart';
import '../../domain/entities/legal_case.dart';
import '../bloc/cases_bloc.dart';
import '../case_display_helpers.dart';

class CasesPage extends StatelessWidget {
  const CasesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<CasesBloc>()..add(FetchCasesRequested()),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.m),
                Text(context.tr('cases'), style: AppTypography.h1),
                const SizedBox(height: AppSpacing.l),
                _buildSearchBar(context),
                const SizedBox(height: AppSpacing.m),
                _buildStatusFilters(context),
                const SizedBox(height: AppSpacing.m),
                Expanded(
                  child: BlocBuilder<CasesBloc, CasesState>(
                    builder: (context, state) {
                      if (state is CasesLoading || state is CasesInitial) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                        );
                      } else if (state is CasesError) {
                        return ErrorView(
                          message: state.message,
                          onRetry: () => context.read<CasesBloc>().add(
                            FetchCasesRequested(),
                          ),
                        );
                      } else if (state is CasesLoaded) {
                        if (state.cases.isEmpty) {
                          return EmptyState(
                            message: context.tr('no_cases_found'),
                          );
                        }
                        return _buildCasesList(context, state.cases);
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
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.medium,
      ),
      child: TextField(
        onChanged: (value) =>
            context.read<CasesBloc>().add(CasesSearchChanged(value)),
        style: AppTypography.bodyMedium,
        decoration: InputDecoration(
          hintText: context.tr('search_cases'),
          prefixIcon: const Icon(
            Icons.search,
            color: AppColors.textHint,
            size: 20,
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildStatusFilters(BuildContext context) {
    return BlocBuilder<CasesBloc, CasesState>(
      builder: (context, state) {
        final activeFilter = state is CasesLoaded ? state.statusFilter : null;
        final filters = <CaseStatus?>[
          null,
          CaseStatus.draft,
          CaseStatus.active,
          CaseStatus.archived,
        ];
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: filters.map((status) {
              final isSelected = status == activeFilter;
              final label = status == null
                  ? context.tr('all')
                  : caseStatusLabel(context, status);
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(label),
                  selected: isSelected,
                  onSelected: (_) => context.read<CasesBloc>().add(
                    CasesStatusFilterChanged(status),
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

  Widget _buildCasesList(BuildContext context, List<LegalCase> cases) {
    return ListView.separated(
      itemCount: cases.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.m),
      itemBuilder: (context, index) {
        final legalCase = cases[index];
        return GestureDetector(
          onTap: () => context.push('${AppRouter.cases}/${legalCase.id}'),
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
                        legalCase.caseNumber,
                        style: AppTypography.labelLarge,
                      ),
                    ),
                    _buildBadge(
                      caseStatusLabel(context, legalCase.status),
                      caseStatusColor(legalCase.status),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(legalCase.client.fullName, style: AppTypography.bodySmall),
                const SizedBox(height: 8),
                _buildBadge(
                  casePriorityLabel(context, legalCase.priority),
                  casePriorityColor(legalCase.priority),
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
