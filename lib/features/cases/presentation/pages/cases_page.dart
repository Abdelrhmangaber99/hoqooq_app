import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../core/auth/permission_check.dart';
import '../../../../core/auth/permission_codes.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/network/dio_error_mapper.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../di/injection.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../authentication/presentation/bloc/session_cubit.dart';
import '../../domain/entities/case_status.dart';
import '../../domain/entities/legal_case.dart';
import '../bloc/cases_bloc.dart';
import '../case_display_helpers.dart';

class CasesPage extends StatelessWidget {
  const CasesPage({super.key});

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

    return BlocProvider(
      create: (_) => getIt<CasesBloc>()..add(FetchCasesRequested()),
      child: const _CasesContent(),
    );
  }
}

class _CasesContent extends StatefulWidget {
  const _CasesContent();

  @override
  State<_CasesContent> createState() => _CasesContentState();
}

class _CasesContentState extends State<_CasesContent> {
  bool _exporting = false;

  bool get _canCreateCase {
    final sessionState = getIt<SessionCubit>().state;
    return sessionState is SessionAuthenticated &&
        sessionState.isFirmAdmin &&
        sessionState.user.hasPerm(PermissionCodes.caseCreate);
  }

  bool get _canExportCases =>
      currentUserHasPerm(PermissionCodes.reportOperationalRead);

  Future<void> _openCreateCase() async {
    final created = await context.push<bool>('${AppRouter.cases}/new');
    if (created == true && mounted) {
      context.read<CasesBloc>().add(FetchCasesRequested());
    }
  }

  Future<void> _exportCases() async {
    if (_exporting) return;
    setState(() => _exporting = true);
    try {
      final response = await getIt<Dio>().get<List<int>>(
        '/reports/export/cases',
        options: Options(responseType: ResponseType.bytes),
      );
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}${Platform.pathSeparator}cases.csv');
      await file.writeAsBytes(response.data ?? const <int>[], flush: true);
      final result = await OpenFilex.open(file.path, type: 'text/csv');
      if (result.type != ResultType.done && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.tr('case_export_open_failed'))),
        );
      }
    } on DioException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(mapDioError(error).message)));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.tr('case_export_failed'))),
        );
      }
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paper,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final padding = constraints.maxWidth >= 700
                ? AppSpacing.l
                : AppSpacing.m;
            return Padding(
              padding: EdgeInsets.all(padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context, constraints.maxWidth),
                  const SizedBox(height: AppSpacing.l),
                  BlocBuilder<CasesBloc, CasesState>(
                    buildWhen: (previous, current) =>
                        current is CasesLoaded || previous is CasesLoaded,
                    builder: (context, state) => state is CasesLoaded
                        ? _StatusTabs(state: state)
                        : const SizedBox.shrink(),
                  ),
                  const SizedBox(height: AppSpacing.m),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 340),
                    child: TextField(
                      onChanged: (value) => context.read<CasesBloc>().add(
                        CasesSearchChanged(value),
                      ),
                      style: AppTypography.bodyMedium,
                      decoration: InputDecoration(
                        hintText: context.tr('search_cases'),
                        prefixIcon: const Icon(Icons.search_rounded, size: 19),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.l),
                  Expanded(
                    child: BlocBuilder<CasesBloc, CasesState>(
                      builder: (context, state) {
                        if (state is CasesLoading || state is CasesInitial) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        if (state is CasesError) {
                          return ErrorView(
                            message: state.message,
                            isForbidden: state.isForbidden,
                            onRetry: () => context.read<CasesBloc>().add(
                              FetchCasesRequested(),
                            ),
                          );
                        }
                        if (state is CasesLoaded) {
                          if (state.cases.isEmpty) {
                            return _CasesEmptyState(
                              canCreate: _canCreateCase,
                              onCreate: _openCreateCase,
                            );
                          }
                          return _CasesGrid(cases: state.cases);
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, double width) {
    final actions = <Widget>[
      if (_canExportCases)
        OutlinedButton.icon(
          onPressed: _exporting ? null : _exportCases,
          icon: _exporting
              ? const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.download_outlined, size: 18),
          label: Text(context.tr(_exporting ? 'exporting' : 'export')),
        ),
      if (_canCreateCase)
        FilledButton.icon(
          onPressed: _openCreateCase,
          icon: const Icon(Icons.add_rounded, size: 18),
          label: Text(context.tr('new_case')),
        ),
    ];

    if (width < 520) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.tr('cases'), style: AppTypography.h1),
          if (actions.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.m),
            Wrap(
              spacing: AppSpacing.s,
              runSpacing: AppSpacing.s,
              children: actions,
            ),
          ],
        ],
      );
    }
    return Row(
      children: [
        Expanded(child: Text(context.tr('cases'), style: AppTypography.h1)),
        Wrap(
          spacing: AppSpacing.s,
          runSpacing: AppSpacing.s,
          children: actions,
        ),
      ],
    );
  }
}

class _StatusTabs extends StatelessWidget {
  const _StatusTabs({required this.state});

  final CasesLoaded state;

  @override
  Widget build(BuildContext context) {
    const statuses = [
      CaseStatus.draft,
      CaseStatus.active,
      CaseStatus.suspended,
      CaseStatus.closed,
      CaseStatus.archived,
    ];
    final totalCount = state.totalCount > 0
        ? state.totalCount
        : state.cases.length;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _StatusTab(
            label: context.tr('all'),
            count: totalCount,
            selected: state.statusFilter == null,
            onTap: () => context.read<CasesBloc>().add(
              const CasesStatusFilterChanged(null),
            ),
          ),
          for (final status in statuses)
            _StatusTab(
              label: caseStatusLabel(context, status),
              count:
                  state.statusCounts[status] ??
                  state.cases.where((item) => item.status == status).length,
              selected: state.statusFilter == status,
              onTap: () => context.read<CasesBloc>().add(
                CasesStatusFilterChanged(status),
              ),
            ),
        ],
      ),
    );
  }
}

class _StatusTab extends StatelessWidget {
  const _StatusTab({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: AppSpacing.s),
      child: Material(
        color: selected ? AppColors.ink800 : Colors.white,
        borderRadius: AppRadius.small,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.small,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(
                color: selected ? AppColors.ink800 : AppColors.paperLine,
              ),
              borderRadius: AppRadius.small,
            ),
            child: Row(
              children: [
                Text(
                  label,
                  style: AppTypography.labelMedium.copyWith(
                    color: selected ? Colors.white : AppColors.ink500,
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? Colors.white.withValues(alpha: .14)
                        : AppColors.paperSoft,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$count',
                    style: AppTypography.bodySmall.copyWith(
                      color: selected ? Colors.white : AppColors.ink400,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CasesGrid extends StatelessWidget {
  const _CasesGrid({required this.cases});

  final List<LegalCase> cases;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 390,
        mainAxisExtent: 190,
        crossAxisSpacing: AppSpacing.m,
        mainAxisSpacing: AppSpacing.m,
      ),
      itemCount: cases.length,
      itemBuilder: (context, index) => _CaseCard(legalCase: cases[index]),
    );
  }
}

class _CaseCard extends StatelessWidget {
  const _CaseCard({required this.legalCase});

  final LegalCase legalCase;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    return Material(
      color: Colors.white,
      borderRadius: AppRadius.medium,
      child: InkWell(
        onTap: () => context.push('${AppRouter.cases}/${legalCase.id}'),
        borderRadius: AppRadius.medium,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: const BoxDecoration(
                      color: AppColors.ink800,
                      borderRadius: AppRadius.medium,
                    ),
                    child: const Icon(
                      Icons.business_center_outlined,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          (legalCase.title?.trim().isNotEmpty ?? false)
                              ? legalCase.title!
                              : (legalCase.courtCaseNumber?.trim().isNotEmpty ?? false)
                                  ? legalCase.courtCaseNumber!
                                  : legalCase.caseNumber,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.labelLarge.copyWith(
                            color: AppColors.ink800,
                          ),
                        ),
                        Text(
                          (legalCase.courtCaseNumber?.trim().isNotEmpty ?? false)
                              ? legalCase.courtCaseNumber!
                              : legalCase.caseNumber,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.bodySmall.copyWith(
                            fontFamily: AppTypography.monoFont,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _Badge(
                    text: caseStatusLabel(context, legalCase.status),
                    color: caseStatusColor(legalCase.status),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _MetadataRow(
                icon: Icons.description_outlined,
                text: legalCase.caseType?.name ?? '—',
              ),
              const SizedBox(height: 7),
              _MetadataRow(
                icon: Icons.account_balance_outlined,
                text: legalCase.courtName ?? '—',
              ),
              const Spacer(),
              const Divider(height: 1),
              const SizedBox(height: 10),
              Row(
                children: [
                  _Badge(
                    text: casePriorityLabel(context, legalCase.priority),
                    color: casePriorityColor(legalCase.priority),
                    dot: true,
                  ),
                  const Spacer(),
                  Text(
                    legalCase.openingDate == null
                        ? '—'
                        : DateFormat(
                            'yyyy-MM-dd',
                            locale,
                          ).format(legalCase.openingDate!),
                    style: AppTypography.bodySmall.copyWith(
                      fontFamily: AppTypography.monoFont,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetadataRow extends StatelessWidget {
  const _MetadataRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.ink400),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.bodySmall.copyWith(color: AppColors.ink500),
          ),
        ),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.text, required this.color, this.dot = false});

  final String text;
  final Color color;
  final bool dot;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dot) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 5),
          ],
          Text(
            text,
            style: AppTypography.bodySmall.copyWith(color: color, fontSize: 10),
          ),
        ],
      ),
    );
  }
}

class _CasesEmptyState extends StatelessWidget {
  const _CasesEmptyState({required this.canCreate, required this.onCreate});

  final bool canCreate;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          EmptyState(
            icon: Icons.business_center_outlined,
            message: context.tr('no_cases_found'),
          ),
          if (canCreate)
            FilledButton.icon(
              onPressed: onCreate,
              icon: const Icon(Icons.add_rounded),
              label: Text(context.tr('new_case')),
            ),
        ],
      ),
    );
  }
}
