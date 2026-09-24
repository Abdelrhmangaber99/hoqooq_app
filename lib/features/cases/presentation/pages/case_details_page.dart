import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:open_filex/open_filex.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import '../../../../core/auth/permission_check.dart';
import '../../../../core/auth/permission_codes.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_dropdown_field.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../di/injection.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../documents/domain/entities/document_item.dart';
import '../../../documents/domain/upload_file_validation.dart';
import '../../../documents/presentation/bloc/document_upload_bloc.dart';
import '../../../finance/presentation/bloc/case_ledger_bloc.dart';
import '../../../finance/presentation/bloc/payment_form_bloc.dart';
import '../../../finance/presentation/pages/case_finance_tab.dart';
import '../../../hearings/domain/entities/hearing.dart';
import '../../../hearings/presentation/hearing_display_helpers.dart';
import '../../../lookups/domain/entities/lookup_kind.dart';
import '../../../lookups/domain/repository/i_lookup_repository.dart';
import '../../../meetings/domain/entities/client_meeting.dart';
import '../../../meetings/domain/entities/meeting_status.dart' as meeting;
import '../../../meetings/presentation/bloc/case_meetings_bloc.dart';
import '../../../meetings/presentation/meeting_display_helpers.dart';
import '../../../service_of_process/domain/entities/service_process.dart';
import '../../../service_of_process/domain/entities/service_status.dart' as svc;
import '../../../service_of_process/presentation/bloc/case_service_process_bloc.dart';
import '../../../service_of_process/presentation/service_process_display_helpers.dart';
import '../../../tasks/domain/entities/task_item.dart';
import '../../../tasks/domain/entities/task_status.dart' as task_status;
import '../../../tasks/presentation/bloc/case_tasks_bloc.dart';
import '../../../tasks/presentation/task_display_helpers.dart';
import '../../data/models/assign_case_request.dart';
import '../../domain/entities/case_party_snapshot.dart';
import '../../domain/entities/case_status.dart';
import '../../domain/entities/case_timeline_event.dart';
import '../../domain/entities/legal_case.dart';
import '../bloc/case_details_bloc.dart';
import '../bloc/case_documents_bloc.dart';
import '../bloc/case_hearings_bloc.dart';
import '../bloc/case_team_assignment_bloc.dart';
import '../case_display_helpers.dart';

enum _UploadSource { camera, file }

class CaseDetailsPage extends StatelessWidget {
  final String caseId;

  const CaseDetailsPage({super.key, required this.caseId});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              getIt<CaseDetailsBloc>()..add(FetchCaseDetailsRequested(caseId)),
        ),
        if (currentUserHasPerm(PermissionCodes.hearingView))
          BlocProvider(
            create: (context) =>
                getIt<CaseHearingsBloc>()
                  ..add(FetchCaseHearingsRequested(caseId)),
          ),
        if (currentUserHasPerm(PermissionCodes.serviceView))
          BlocProvider(
            create: (context) =>
                getIt<CaseServiceProcessBloc>()
                  ..add(FetchCaseServiceProcessesRequested(caseId)),
          ),
        if (currentUserHasPerm(PermissionCodes.meetingView))
          BlocProvider(
            create: (context) =>
                getIt<CaseMeetingsBloc>()
                  ..add(FetchCaseMeetingsRequested(caseId)),
          ),
        if (currentUserHasPerm(PermissionCodes.taskView))
          BlocProvider(
            create: (context) =>
                getIt<CaseTasksBloc>()..add(FetchCaseTasksRequested(caseId)),
          ),
        if (currentUserHasPerm(PermissionCodes.documentView))
          BlocProvider(
            create: (context) =>
                getIt<CaseDocumentsBloc>()
                  ..add(FetchCaseDocumentsRequested(caseId)),
          ),
        if (currentUserHasPerm(PermissionCodes.financeCaseView)) ...[
          BlocProvider(
            create: (context) =>
                getIt<CaseLedgerBloc>()..add(FetchCaseLedgerRequested(caseId)),
          ),
          BlocProvider(create: (context) => getIt<PaymentFormBloc>()),
        ],
        BlocProvider(create: (context) => getIt<DocumentUploadBloc>()),
      ],
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: BlocListener<DocumentUploadBloc, DocumentUploadState>(
            listener: (context, state) {
              if (state is DocumentUploadSuccess &&
                  currentUserHasPerm(PermissionCodes.documentView)) {
                context.read<CaseDocumentsBloc>().add(
                  FetchCaseDocumentsRequested(caseId),
                );
              } else if (state is DocumentUploadFailure) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(state.message)));
              }
            },
            child: BlocConsumer<CaseDetailsBloc, CaseDetailsState>(
              listener: (context, state) {
                if (state is CaseDetailsLoaded && state.actionError != null) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(state.actionError!)));
                }
              },
              builder: (context, state) {
                if (state is CaseDetailsLoading ||
                    state is CaseDetailsInitial) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                } else if (state is CaseDetailsError) {
                  return ErrorView(
                    message: state.message,
                    isForbidden: state.isForbidden,
                    onRetry: () => context.read<CaseDetailsBloc>().add(
                      FetchCaseDetailsRequested(caseId),
                    ),
                  );
                } else if (state is CaseDetailsLoaded) {
                  return _buildContent(
                    context,
                    state.legalCase,
                    isUpdatingStatus: state.isUpdatingStatus,
                  );
                }
                return const SizedBox();
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    LegalCase legalCase, {
    required bool isUpdatingStatus,
  }) {
    return _CaseDetailsTabs(
      owner: this,
      legalCase: legalCase,
      isUpdatingStatus: isUpdatingStatus,
    );
  }

  @Deprecated('Retained temporarily while the tabbed detail sections migrate.')
  Widget buildLegacyContent(
    BuildContext context,
    LegalCase legalCase, {
    required bool isUpdatingStatus,
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.m),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, legalCase),
          if (isUpdatingStatus) ...[
            const SizedBox(height: AppSpacing.s),
            const LinearProgressIndicator(),
          ],
          if (currentUserHasPerm(PermissionCodes.caseEdit)) ...[
            const SizedBox(height: AppSpacing.m),
            AppButton(
              text: context.tr('edit_case'),
              style: AppButtonStyle.outline,
              onPressed: () async {
                final updated = await context.push<bool>(
                  '${AppRouter.cases}/${legalCase.id}/edit',
                  extra: legalCase,
                );
                if (updated == true && context.mounted) {
                  context.read<CaseDetailsBloc>().add(
                    FetchCaseDetailsRequested(caseId),
                  );
                }
              },
            ),
          ],
          if (currentUserHasPerm(PermissionCodes.caseStatusManage)) ...[
            const SizedBox(height: AppSpacing.m),
            AppButton(
              text: context.tr('change_case_status'),
              style: AppButtonStyle.outline,
              isLoading: isUpdatingStatus,
              onPressed: () => _showChangeStatusDialog(context, legalCase),
            ),
          ],
          const SizedBox(height: AppSpacing.l),
          Text(context.tr('overview'), style: AppTypography.h3),
          const SizedBox(height: AppSpacing.m),
          _buildOverview(context, legalCase),
          if (legalCase.timelineEvents?.isNotEmpty ?? false) ...[
            const SizedBox(height: AppSpacing.l),
            Text(context.tr('case_timeline'), style: AppTypography.h3),
            const SizedBox(height: AppSpacing.m),
            _buildTimeline(context, legalCase.timelineEvents!),
          ],
          if (legalCase.clientSnapshot != null &&
              currentUserHasPerm(PermissionCodes.clientView)) ...[
            const SizedBox(height: AppSpacing.l),
            Text(context.tr('client'), style: AppTypography.h3),
            const SizedBox(height: AppSpacing.m),
            _buildClientSnapshot(context, legalCase.clientSnapshot!),
          ],
          if (legalCase.opponentSnapshots != null &&
              currentUserHasPerm(PermissionCodes.opponentView)) ...[
            const SizedBox(height: AppSpacing.l),
            Text(context.tr('opponents'), style: AppTypography.h3),
            const SizedBox(height: AppSpacing.m),
            _buildOpponentSnapshots(context, legalCase.opponentSnapshots!),
          ],
          const SizedBox(height: AppSpacing.l),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(context.tr('team'), style: AppTypography.h3),
              if (currentUserHasPerm(PermissionCodes.caseAccessManage))
                GestureDetector(
                  onTap: () =>
                      _showAssignTeamMemberSheet(context, legalCase),
                  child: const Icon(
                    Icons.person_add_alt_1_outlined,
                    color: AppColors.primary,
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.m),
          _buildTeam(context, legalCase),
          if (currentUserHasPerm(PermissionCodes.hearingView)) ...[
            const SizedBox(height: AppSpacing.l),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(context.tr('hearings'), style: AppTypography.h3),
                if (currentUserHasPerm(PermissionCodes.hearingCreate))
                  GestureDetector(
                    onTap: () async {
                      final created = await context.push<bool>(
                        '${AppRouter.cases}/${legalCase.id}/hearings/new'
                        '?governorateId=${legalCase.governorateId ?? ''}',
                      );
                      if (created == true && context.mounted) {
                        context.read<CaseHearingsBloc>().add(
                          FetchCaseHearingsRequested(caseId),
                        );
                      }
                    },
                    child: const Icon(
                      Icons.event_available_outlined,
                      color: AppColors.primary,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.m),
            _buildHearingsSection(context, legalCase.governorateId),
          ],
          if (currentUserHasPerm(PermissionCodes.serviceView)) ...[
            const SizedBox(height: AppSpacing.l),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(context.tr('service_of_process'), style: AppTypography.h3),
                if (currentUserHasPerm(PermissionCodes.serviceCreate))
                  GestureDetector(
                    onTap: () async {
                      final created = await context.push<bool>(
                        '${AppRouter.cases}/${legalCase.id}/service/new'
                        '?governorateId=${legalCase.governorateId ?? ''}',
                      );
                      if (created == true && context.mounted) {
                        context.read<CaseServiceProcessBloc>().add(
                          FetchCaseServiceProcessesRequested(legalCase.id),
                        );
                      }
                    },
                    child: const Icon(
                      Icons.outgoing_mail,
                      color: AppColors.primary,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.m),
            _buildServiceProcessesSection(context, legalCase.governorateId),
          ],
          if (currentUserHasPerm(PermissionCodes.meetingView)) ...[
            const SizedBox(height: AppSpacing.l),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(context.tr('client_meetings'), style: AppTypography.h3),
                if (currentUserHasPerm(PermissionCodes.meetingCreate))
                  IconButton(
                    onPressed: () async {
                      final created = await context.push<bool>(
                        '${AppRouter.cases}/${legalCase.id}/meetings/new',
                      );
                      if (created == true && context.mounted) {
                        context.read<CaseMeetingsBloc>().add(
                          FetchCaseMeetingsRequested(legalCase.id),
                        );
                      }
                    },
                    icon: const Icon(
                      Icons.groups_outlined,
                      color: AppColors.primary,
                    ),
                  ),
              ],
            ),
            _buildMeetingsSection(context),
          ],
          if (currentUserHasPerm(PermissionCodes.taskView)) ...[
            const SizedBox(height: AppSpacing.l),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(context.tr('tasks'), style: AppTypography.h3),
                if (currentUserHasPerm(PermissionCodes.taskCreate))
                  IconButton(
                    tooltip: context.tr('create_task'),
                    onPressed: () async {
                      final created = await context.push<bool>(
                        '${AppRouter.cases}/${legalCase.id}/tasks/new',
                      );
                      if (created == true && context.mounted) {
                        context.read<CaseTasksBloc>().add(
                          FetchCaseTasksRequested(legalCase.id),
                        );
                      }
                    },
                    icon: const Icon(Icons.add_task, color: AppColors.primary),
                  ),
              ],
            ),
            _buildTasksSection(context),
          ],
          if (currentUserHasPerm(PermissionCodes.documentView)) ...[
            const SizedBox(height: AppSpacing.l),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(context.tr('documents'), style: AppTypography.h3),
                if (currentUserHasPerm(PermissionCodes.documentUpload))
                  GestureDetector(
                    onTap: () => _showUploadOptions(context, legalCase.id),
                    child: const Icon(
                      Icons.add_circle_outline,
                      color: AppColors.primary,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.m),
            BlocBuilder<DocumentUploadBloc, DocumentUploadState>(
              builder: (context, state) {
                if (state is! DocumentUploadInProgress) {
                  return const SizedBox();
                }
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.m),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.tr('uploading'),
                        style: AppTypography.bodySmall,
                      ),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: state.progress > 0 ? state.progress : null,
                        color: AppColors.primary,
                        backgroundColor: AppColors.surfaceLight,
                      ),
                    ],
                  ),
                );
              },
            ),
            _buildDocumentsSection(context),
          ],
        ],
      ),
    );
  }

  Future<void> _showChangeStatusDialog(
    BuildContext context,
    LegalCase legalCase,
  ) async {
    var selected = legalCase.status;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(context.tr('change_case_status')),
          content: AppDropdownField<CaseStatus>(
            label: context.tr('status'),
            value: selected,
            items: CaseStatus.values.where(
              (status) =>
                  status != CaseStatus.unknown &&
                  status != CaseStatus.suspended,
            ),
            labelOf: (status) => caseStatusLabel(context, status),
            onChanged: (status) => setDialogState(() => selected = status!),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(context.tr('cancel')),
            ),
            FilledButton(
              onPressed: selected == legalCase.status
                  ? null
                  : () => Navigator.pop(dialogContext, true),
              child: Text(context.tr('confirm')),
            ),
          ],
        ),
      ),
    );
    if (confirmed == true && context.mounted) {
      context.read<CaseDetailsBloc>().add(
        ChangeCaseStatusRequested(legalCase.id, selected),
      );
    }
  }

  Widget _buildHearingsSection(BuildContext context, String? governorateId) {
    return BlocBuilder<CaseHearingsBloc, CaseHearingsState>(
      builder: (context, state) {
        if (state is CaseHearingsLoading || state is CaseHearingsInitial) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        } else if (state is CaseHearingsError) {
          return ErrorView(
            message: state.message,
            isForbidden: state.isForbidden,
            onRetry: () => context.read<CaseHearingsBloc>().add(
              FetchCaseHearingsRequested(caseId),
            ),
          );
        } else if (state is CaseHearingsLoaded) {
          if (state.hearings.isEmpty) {
            return EmptyState(message: context.tr('no_hearings_for_case'));
          }
          return Column(
            children: state.hearings
                .map((h) => _buildHearingItem(context, h, governorateId))
                .toList(),
          );
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildHearingItem(
    BuildContext context,
    Hearing hearing,
    String? governorateId,
  ) {
    final dateFormat = DateFormat.yMMMd().add_jm();
    return GestureDetector(
      onTap: currentUserHasPerm(PermissionCodes.hearingEdit)
          ? () async {
              final updated = await context.push<bool>(
                '${AppRouter.cases}/${hearing.caseId}/hearings/${hearing.id}/edit'
                '?governorateId=${governorateId ?? ''}',
                extra: hearing,
              );
              if (updated == true && context.mounted) {
                context.read<CaseHearingsBloc>().add(
                  FetchCaseHearingsRequested(caseId),
                );
              }
            }
          : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.s),
        padding: const EdgeInsets.all(AppSpacing.m),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.medium,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  dateFormat.format(hearing.scheduledAt),
                  style: AppTypography.labelLarge,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: hearingStatusColor(
                      hearing.status,
                    ).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    hearingStatusLabel(context, hearing.status),
                    style: TextStyle(
                      color: hearingStatusColor(hearing.status),
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
            if (hearing.court != null) ...[
              const SizedBox(height: 4),
              Text(hearing.court!.name, style: AppTypography.bodySmall),
            ],
            if (hearing.judgeName != null) ...[
              const SizedBox(height: 4),
              Text(
                '${context.tr('judge')}: ${hearing.judgeName}',
                style: AppTypography.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildServiceProcessesSection(
    BuildContext context,
    String? governorateId,
  ) {
    return BlocConsumer<CaseServiceProcessBloc, CaseServiceProcessState>(
      listener: (context, state) {
        if (state is CaseServiceProcessLoaded && state.actionError != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.actionError!)));
        }
      },
      builder: (context, state) {
        if (state is CaseServiceProcessInitial ||
            state is CaseServiceProcessLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is CaseServiceProcessError) {
          return ErrorView(
            message: state.message,
            isForbidden: state.isForbidden,
            onRetry: () => context.read<CaseServiceProcessBloc>().add(
              FetchCaseServiceProcessesRequested(caseId),
            ),
          );
        }
        if (state is CaseServiceProcessLoaded) {
          if (state.items.isEmpty) {
            return EmptyState(message: context.tr('no_service_processes'));
          }
          return Column(
            children: state.items
                .map(
                  (item) =>
                      _buildServiceProcessItem(context, item, governorateId),
                )
                .toList(),
          );
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildServiceProcessItem(
    BuildContext context,
    ServiceProcess item,
    String? governorateId,
  ) {
    final format = DateFormat.yMMMd().add_jm();
    return GestureDetector(
      onTap: currentUserHasPerm(PermissionCodes.serviceEdit)
          ? () async {
              final updated = await context.push<bool>(
                '${AppRouter.cases}/${item.caseId}/service/${item.id}/edit'
                '?governorateId=${governorateId ?? ''}',
                extra: item,
              );
              if (updated == true && context.mounted) {
                context.read<CaseServiceProcessBloc>().add(
                  FetchCaseServiceProcessesRequested(item.caseId),
                );
              }
            }
          : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.s),
        padding: const EdgeInsets.all(AppSpacing.m),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.medium,
        ),
        child: Row(
          children: [
            const Icon(Icons.outgoing_mail, color: AppColors.primary),
            const SizedBox(width: AppSpacing.m),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.targetName, style: AppTypography.labelLarge),
                  const SizedBox(height: 4),
                  Text(
                    format.format(item.scheduledAt),
                    style: AppTypography.bodySmall,
                  ),
                  if (item.serviceMethod != null)
                    Text(
                      item.serviceMethod!.labelFor(
                        Localizations.localeOf(context),
                      ),
                      style: AppTypography.bodySmall,
                    ),
                ],
              ),
            ),
            Column(
              children: [
                Text(
                  serviceStatusLabel(context, item.status),
                  style: AppTypography.labelMedium.copyWith(
                    color: serviceStatusColor(item.status),
                  ),
                ),
                if (item.status != svc.ServiceStatus.completed &&
                    item.status != svc.ServiceStatus.failed &&
                    item.status != svc.ServiceStatus.cancelled &&
                    currentUserHasPerm(PermissionCodes.serviceComplete) &&
                    currentUserHasPerm(PermissionCodes.documentUpload))
                  IconButton(
                    tooltip: context.tr('complete_service_process'),
                    onPressed: () async {
                      final completed = await context.push<bool>(
                        '${AppRouter.cases}/${item.caseId}/service/${item.id}/complete',
                        extra: item,
                      );
                      if (completed == true && context.mounted) {
                        context.read<CaseServiceProcessBloc>().add(
                          FetchCaseServiceProcessesRequested(item.caseId),
                        );
                        if (currentUserHasPerm(PermissionCodes.documentView)) {
                          context.read<CaseDocumentsBloc>().add(
                            FetchCaseDocumentsRequested(item.caseId),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.task_alt, color: AppColors.success),
                  ),
                if (item.status != svc.ServiceStatus.completed &&
                    item.status != svc.ServiceStatus.failed &&
                    item.status != svc.ServiceStatus.cancelled &&
                    currentUserHasPerm(PermissionCodes.serviceComplete))
                  IconButton(
                    tooltip: context.tr('cancel_service_process'),
                    onPressed: () => _confirmCancelService(context, item),
                    icon: const Icon(
                      Icons.cancel_outlined,
                      color: AppColors.error,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmCancelService(
    BuildContext context,
    ServiceProcess item,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.tr('cancel_service_process')),
        content: Text(context.tr('cancel_service_process_confirmation')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(context.tr('cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(context.tr('confirm')),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      context.read<CaseServiceProcessBloc>().add(
        CancelServiceProcessRequested(id: item.id, caseId: item.caseId),
      );
    }
  }

  Widget _buildMeetingsSection(BuildContext context) {
    return BlocConsumer<CaseMeetingsBloc, CaseMeetingsState>(
      listener: (context, state) {
        if (state is CaseMeetingsLoaded && state.actionError != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.actionError!)));
        }
      },
      builder: (context, state) {
        if (state is CaseMeetingsInitial || state is CaseMeetingsLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is CaseMeetingsError) {
          return ErrorView(
            message: state.message,
            isForbidden: state.isForbidden,
            onRetry: () => context.read<CaseMeetingsBloc>().add(
              FetchCaseMeetingsRequested(caseId),
            ),
          );
        }
        if (state is CaseMeetingsLoaded) {
          if (state.items.isEmpty) {
            return EmptyState(message: context.tr('no_client_meetings'));
          }
          return Column(
            children: state.items
                .map((item) => _buildMeetingItem(context, item))
                .toList(),
          );
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildMeetingItem(BuildContext context, ClientMeeting item) {
    final isFinal =
        item.status == meeting.MeetingStatus.completed ||
        item.status == meeting.MeetingStatus.cancelled;
    return GestureDetector(
      onTap: currentUserHasPerm(PermissionCodes.meetingEdit) && !isFinal
          ? () async {
              final updated = await context.push<bool>(
                '${AppRouter.cases}/${item.caseId}/meetings/${item.id}/edit',
                extra: item,
              );
              if (updated == true && context.mounted) {
                context.read<CaseMeetingsBloc>().add(
                  FetchCaseMeetingsRequested(item.caseId),
                );
              }
            }
          : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.s),
        padding: const EdgeInsets.all(AppSpacing.m),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.medium,
        ),
        child: Row(
          children: [
            const Icon(Icons.groups_outlined, color: AppColors.primary),
            const SizedBox(width: AppSpacing.m),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.subject, style: AppTypography.labelLarge),
                  Text(item.locationOrMethod, style: AppTypography.bodySmall),
                  Text(
                    DateFormat.yMMMd().add_jm().format(item.scheduledAt),
                    style: AppTypography.bodySmall,
                  ),
                ],
              ),
            ),
            Column(
              children: [
                Text(
                  meetingStatusLabel(context, item.status),
                  style: AppTypography.labelMedium.copyWith(
                    color: meetingStatusColor(item.status),
                  ),
                ),
                if (!isFinal &&
                    currentUserHasPerm(PermissionCodes.meetingComplete)) ...[
                  IconButton(
                    onPressed: () => _completeMeeting(context, item),
                    icon: const Icon(Icons.task_alt, color: AppColors.success),
                  ),
                  IconButton(
                    onPressed: () => _cancelMeeting(context, item),
                    icon: const Icon(
                      Icons.cancel_outlined,
                      color: AppColors.error,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _completeMeeting(
    BuildContext context,
    ClientMeeting item,
  ) async {
    final controller = TextEditingController();
    final outcome = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.tr('complete_client_meeting')),
        content: AppTextField(
          label: context.tr('outcome_notes'),
          controller: controller,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(context.tr('cancel')),
          ),
          FilledButton(
            onPressed: () {
              final value = controller.text.trim();
              if (value.isNotEmpty) Navigator.pop(dialogContext, value);
            },
            child: Text(context.tr('confirm')),
          ),
        ],
      ),
    );
    controller.dispose();
    if (outcome != null && context.mounted) {
      context.read<CaseMeetingsBloc>().add(
        CompleteMeetingRequested(
          id: item.id,
          caseId: item.caseId,
          outcomeNotes: outcome,
        ),
      );
    }
  }

  Future<void> _cancelMeeting(BuildContext context, ClientMeeting item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.tr('cancel_client_meeting')),
        content: Text(context.tr('cancel_client_meeting_confirmation')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(context.tr('cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(context.tr('confirm')),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      context.read<CaseMeetingsBloc>().add(
        CancelMeetingRequested(id: item.id, caseId: item.caseId),
      );
    }
  }

  Widget _buildTasksSection(BuildContext context) {
    return BlocConsumer<CaseTasksBloc, CaseTasksState>(
      listener: (context, state) {
        if (state is CaseTasksLoaded && state.actionError != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.actionError!)));
        }
      },
      builder: (context, state) {
        if (state is CaseTasksInitial || state is CaseTasksLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is CaseTasksError) {
          return ErrorView(
            message: state.message,
            isForbidden: state.isForbidden,
            onRetry: () => context.read<CaseTasksBloc>().add(
              FetchCaseTasksRequested(caseId),
            ),
          );
        }
        if (state is CaseTasksLoaded) {
          if (state.items.isEmpty) {
            return EmptyState(message: context.tr('no_tasks_for_case'));
          }
          return Column(
            children: state.items
                .map((item) => _buildTaskItem(context, item))
                .toList(),
          );
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildTaskItem(BuildContext context, TaskItem item) {
    final isFinal =
        item.status == task_status.TaskStatus.completed ||
        item.status == task_status.TaskStatus.cancelled;
    return GestureDetector(
      onTap: currentUserHasPerm(PermissionCodes.taskUpdate) && !isFinal
          ? () async {
              final updated = await context.push<bool>(
                '${AppRouter.cases}/$caseId/tasks/${item.id}/edit',
                extra: item,
              );
              if (updated == true && context.mounted) {
                context.read<CaseTasksBloc>().add(
                  FetchCaseTasksRequested(caseId),
                );
              }
            }
          : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.s),
        padding: const EdgeInsets.all(AppSpacing.m),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.medium,
        ),
        child: Row(
          children: [
            const Icon(Icons.task_outlined, color: AppColors.primary),
            const SizedBox(width: AppSpacing.m),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title, style: AppTypography.labelLarge),
                  if (item.dueDate != null)
                    Text(
                      '${context.tr('due_date')}: '
                      '${DateFormat.yMMMd().format(item.dueDate!.toLocal())}',
                      style: AppTypography.bodySmall,
                    ),
                  if (item.completionNote != null &&
                      item.completionNote!.isNotEmpty)
                    Text(item.completionNote!, style: AppTypography.bodySmall),
                ],
              ),
            ),
            Column(
              children: [
                Text(
                  taskStatusLabel(context, item.status),
                  style: AppTypography.labelMedium.copyWith(
                    color: taskStatusColor(item.status),
                  ),
                ),
                if (!isFinal &&
                    currentUserHasPerm(PermissionCodes.taskComplete)) ...[
                  IconButton(
                    tooltip: context.tr('complete_task'),
                    onPressed: () => _completeTask(context, item),
                    icon: const Icon(Icons.task_alt, color: AppColors.success),
                  ),
                  IconButton(
                    tooltip: context.tr('cancel_task'),
                    onPressed: () => _cancelTask(context, item),
                    icon: const Icon(
                      Icons.cancel_outlined,
                      color: AppColors.error,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _completeTask(BuildContext context, TaskItem item) async {
    final controller = TextEditingController();
    final note = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.tr('complete_task')),
        content: AppTextField(
          label: context.tr('completion_note'),
          controller: controller,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(context.tr('cancel')),
          ),
          FilledButton(
            onPressed: () {
              final value = controller.text.trim();
              if (value.isNotEmpty) Navigator.pop(dialogContext, value);
            },
            child: Text(context.tr('confirm')),
          ),
        ],
      ),
    );
    controller.dispose();
    if (note != null && context.mounted) {
      context.read<CaseTasksBloc>().add(
        CompleteTaskRequested(
          id: item.id,
          caseId: caseId,
          completionNote: note,
        ),
      );
    }
  }

  Future<void> _cancelTask(BuildContext context, TaskItem item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.tr('cancel_task')),
        content: Text(context.tr('cancel_task_confirmation')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(context.tr('cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(context.tr('confirm')),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      context.read<CaseTasksBloc>().add(
        CancelTaskRequested(id: item.id, caseId: caseId),
      );
    }
  }

  Widget _buildDocumentsSection(BuildContext context) {
    return BlocConsumer<CaseDocumentsBloc, CaseDocumentsState>(
      listener: (context, state) async {
        if (state is! CaseDocumentsLoaded) return;
        if (state.actionError != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.actionError!)));
        }
        final download = state.downloadedDocument;
        if (download != null) {
          final directory = await getTemporaryDirectory();
          final safeName = download.fileName.replaceAll(
            RegExp(r'[\\/:*?"<>|]'),
            '_',
          );
          final path = '${directory.path}${Platform.pathSeparator}$safeName';
          await File(path).writeAsBytes(download.bytes, flush: true);
          final openResult = await OpenFilex.open(path);
          if (!context.mounted) return;
          if (openResult.type != ResultType.done) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '${context.tr('document_open_failed')} ${openResult.message}',
                ),
              ),
            );
          }
        }
      },
      builder: (context, state) {
        if (state is CaseDocumentsLoading || state is CaseDocumentsInitial) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        } else if (state is CaseDocumentsError) {
          return ErrorView(
            message: state.message,
            isForbidden: state.isForbidden,
            onRetry: () => context.read<CaseDocumentsBloc>().add(
              FetchCaseDocumentsRequested(caseId),
            ),
          );
        } else if (state is CaseDocumentsLoaded) {
          if (state.documents.isEmpty) {
            return EmptyState(message: context.tr('no_documents_for_case'));
          }
          return Column(
            children: state.documents
                .map((d) => _buildDocumentItem(context, d))
                .toList(),
          );
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildDocumentItem(BuildContext context, DocumentItem document) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.s),
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.medium,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.description_outlined,
              size: 20,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: AppSpacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(document.title, style: AppTypography.labelLarge),
                const SizedBox(height: 2),
                Text(
                  '${document.fileType} · ${_formatSize(document.sizeBytes)} · '
                  '${context.tr('version')} ${document.versionNumber}',
                  style: AppTypography.bodySmall.copyWith(fontSize: 10),
                ),
              ],
            ),
          ),
          if (currentUserHasPerm(PermissionCodes.documentDownload))
            IconButton(
              tooltip: context.tr('download_document'),
              onPressed: () => context.read<CaseDocumentsBloc>().add(
                DownloadDocumentRequested(
                  documentId: document.id,
                  fileName: document.title,
                ),
              ),
              icon: const Icon(Icons.download_outlined),
            ),
          if (currentUserHasPerm(PermissionCodes.documentUpload))
            IconButton(
              tooltip: context.tr('upload_new_version'),
              onPressed: () => _uploadDocumentVersion(context, document),
              icon: const Icon(Icons.upload_file_outlined),
            ),
          if (currentUserHasPerm(PermissionCodes.documentManage))
            IconButton(
              tooltip: context.tr('archive_document'),
              onPressed: () => _archiveDocument(context, document),
              icon: const Icon(Icons.archive_outlined),
            ),
        ],
      ),
    );
  }

  Future<void> _uploadDocumentVersion(
    BuildContext context,
    DocumentItem document,
  ) async {
    final result = await FilePicker.pickFiles();
    final filePath = result?.files.single.path;
    if (filePath == null) return;
    final validation = validateUploadFile(
      filePath,
      await File(filePath).length(),
    );
    if (validation != null) {
      if (!context.mounted) return;
      final message = validation == UploadValidationError.tooLarge
          ? context.tr('upload_file_too_large')
          : context.tr('upload_file_type_unsupported');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
      return;
    }
    if (!context.mounted) return;
    final controller = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.tr('upload_new_version')),
        content: AppTextField(
          label: context.tr('change_summary_optional'),
          controller: controller,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(context.tr('cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(context.tr('confirm')),
          ),
        ],
      ),
    );
    final summary = controller.text.trim();
    controller.dispose();
    if (confirmed == true && context.mounted) {
      context.read<CaseDocumentsBloc>().add(
        UploadDocumentVersionRequested(
          documentId: document.id,
          caseId: caseId,
          filePath: filePath,
          changeSummary: summary.isEmpty ? null : summary,
        ),
      );
    }
  }

  Future<void> _archiveDocument(
    BuildContext context,
    DocumentItem document,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.tr('archive_document')),
        content: Text(context.tr('archive_document_confirmation')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(context.tr('cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(context.tr('confirm')),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      context.read<CaseDocumentsBloc>().add(
        ArchiveDocumentRequested(documentId: document.id, caseId: caseId),
      );
    }
  }

  Widget _buildTimeline(BuildContext context, List<CaseTimelineEvent> events) {
    final ordered = [...events]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return Column(
      children: ordered.map((event) {
        final transition = event.previousState != null || event.newState != null
            ? '${event.previousState ?? '—'} → ${event.newState ?? '—'}'
            : null;
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: AppSpacing.s),
          padding: const EdgeInsets.all(AppSpacing.m),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppRadius.medium,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.history, color: AppColors.primary),
              const SizedBox(width: AppSpacing.m),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _timelineEventLabel(context, event.eventType),
                      style: AppTypography.labelLarge,
                    ),
                    if (event.note?.isNotEmpty ?? false)
                      Text(event.note!, style: AppTypography.bodySmall),
                    if (transition != null)
                      Text(transition, style: AppTypography.bodySmall),
                    Text(
                      DateFormat.yMMMd().add_jm().format(
                        event.createdAt.toLocal(),
                      ),
                      style: AppTypography.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  String _timelineEventLabel(BuildContext context, CaseTimelineEventType type) {
    final key = switch (type) {
      CaseTimelineEventType.created => 'timeline_case_created',
      CaseTimelineEventType.lawyerChanged => 'timeline_lawyer_changed',
      CaseTimelineEventType.statusChanged => 'timeline_status_changed',
      CaseTimelineEventType.hearingScheduled => 'timeline_hearing_scheduled',
      CaseTimelineEventType.hearingCompleted => 'timeline_hearing_completed',
      CaseTimelineEventType.documentUploaded => 'timeline_document_uploaded',
      CaseTimelineEventType.noteAdded => 'timeline_note_added',
      CaseTimelineEventType.paymentReceived => 'timeline_payment_received',
      CaseTimelineEventType.taskAssigned => 'timeline_task_assigned',
      CaseTimelineEventType.serviceOfProcessAdded => 'timeline_service_added',
      CaseTimelineEventType.serviceOfProcessUpdated =>
        'timeline_service_updated',
      CaseTimelineEventType.grantAdded => 'timeline_grant_added',
      CaseTimelineEventType.grantRevoked => 'timeline_grant_revoked',
      CaseTimelineEventType.unknown => 'unknown',
    };
    return context.tr(key);
  }

  Future<void> _showUploadOptions(BuildContext context, String caseId) async {
    final bloc = context.read<DocumentUploadBloc>();
    final source = await showModalBottomSheet<_UploadSource>(
      context: context,
      backgroundColor: AppColors.surface,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: Text(sheetContext.tr('take_photo')),
              onTap: () => Navigator.pop(sheetContext, _UploadSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.attach_file),
              title: Text(sheetContext.tr('choose_file')),
              onTap: () => Navigator.pop(sheetContext, _UploadSource.file),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;

    String? filePath;
    if (source == _UploadSource.camera) {
      final granted = await Permission.camera.request();
      if (!granted.isGranted) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(context.tr('camera_permission_denied'))),
          );
        }
        return;
      }
      final photo = await ImagePicker().pickImage(source: ImageSource.camera);
      filePath = photo?.path;
    } else {
      final result = await FilePicker.pickFiles();
      filePath = result?.files.single.path;
    }

    if (filePath == null) return;

    final sizeBytes = await File(filePath).length();
    final validationError = validateUploadFile(filePath, sizeBytes);
    if (validationError != null) {
      if (!context.mounted) return;
      final message = validationError == UploadValidationError.tooLarge
          ? context.tr('upload_file_too_large')
          : context.tr('upload_file_type_unsupported');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
      return;
    }

    if (!context.mounted) return;
    final categoriesResult = await getIt<ILookupRepository>().getLookups(
      kind: LookupKind.documentCategory,
    );
    if (!context.mounted) return;
    final categories = categoriesResult.fold((_) => const [], (items) => items);
    if (categories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('document_categories_unavailable'))),
      );
      return;
    }
    final categoryId = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppColors.surface,
      builder: (sheetContext) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.m),
              child: Text(
                sheetContext.tr('document_category'),
                style: AppTypography.h3,
              ),
            ),
            ...categories.map(
              (category) => ListTile(
                title: Text(
                  category.labelFor(Localizations.localeOf(sheetContext)),
                ),
                onTap: () => Navigator.pop(sheetContext, category.id),
              ),
            ),
          ],
        ),
      ),
    );
    if (categoryId == null) return;

    bloc.add(
      DocumentUploadRequested(
        filePath: filePath,
        caseId: caseId,
        categoryId: categoryId,
      ),
    );
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  Widget _buildHeader(BuildContext context, LegalCase legalCase) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.l),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.medium,
        border: Border.all(color: AppColors.paperLine),
        boxShadow: const [
          BoxShadow(
            color: Color(0x080B192F),
            blurRadius: 14,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            legalCase.caseNumber,
            style: AppTypography.h1.copyWith(
              fontFamily: AppTypography.monoFont,
            ),
          ),
          const SizedBox(height: AppSpacing.s),
          Wrap(
            spacing: AppSpacing.s,
            runSpacing: AppSpacing.s,
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: casePriorityColor(
                    legalCase.priority,
                  ).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: casePriorityColor(legalCase.priority),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      casePriorityLabel(context, legalCase.priority),
                      style: AppTypography.labelMedium.copyWith(
                        color: casePriorityColor(legalCase.priority),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (_present(legalCase.title) != null) ...[
            const SizedBox(height: AppSpacing.m),
            Text(legalCase.title!, style: AppTypography.h3),
          ],
          if (legalCase.clientSnapshot != null) ...[
            const SizedBox(height: 4),
            Text(
              legalCase.clientSnapshot!.name,
              style: AppTypography.bodySmall,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOverview(BuildContext context, LegalCase legalCase) {
    final dateFormat = DateFormat.yMMMd(
      Localizations.localeOf(context).languageCode,
    );
    final membersWithUser = legalCase.team
        .where((member) => member.user != null)
        .toList();
    final leadLawyer = membersWithUser.isEmpty
        ? null
        : membersWithUser.first.user!.fullName;
    final items = <({String label, String value})>[
      (
        label: context.tr('client'),
        value: legalCase.clientSnapshot?.name ?? '—',
      ),
      (label: context.tr('case_type'), value: legalCase.caseType?.name ?? '—'),
      (label: context.tr('court'), value: legalCase.courtName ?? '—'),
      (
        label: context.tr('primary_lawyer'),
        value: leadLawyer ?? '—',
      ),
      (
        label: context.tr('court_case_number'),
        value: _present(legalCase.courtCaseNumber) ?? '—',
      ),
      (
        label: context.tr('court_case_year'),
        value: legalCase.courtCaseYear?.toString() ?? '—',
      ),
      (
        label: context.tr('opening_date'),
        value: legalCase.openingDate == null
            ? '—'
            : dateFormat.format(legalCase.openingDate!),
      ),
      (
        label: context.tr('closing_date'),
        value: legalCase.closingDate == null
            ? '—'
            : dateFormat.format(legalCase.closingDate!),
      ),
      (
        label: context.tr('description'),
        value: _present(legalCase.description) ?? '—',
      ),
      (
        label: context.tr('outcome_summary'),
        value: _present(legalCase.outcomeSummary) ?? '—',
      ),
    ];
    return Container(
      padding: const EdgeInsets.all(AppSpacing.l),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.medium,
        border: Border.all(color: AppColors.paperLine),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final columns = constraints.maxWidth >= 600 ? 2 : 1;
          final width =
              (constraints.maxWidth - AppSpacing.l * (columns - 1)) / columns;
          return Wrap(
            spacing: AppSpacing.l,
            runSpacing: AppSpacing.l,
            children: [
              for (final item in items)
                SizedBox(
                  width: width,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.label, style: AppTypography.bodySmall),
                      const SizedBox(height: 4),
                      Text(item.value, style: AppTypography.bodyMedium),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildClientSnapshot(BuildContext context, CaseClientSnapshot client) {
    return _buildPartyCard([
      _buildInfoRow(context.tr('client_name'), client.name),
      _buildInfoRow(
        context.tr('client_type'),
        _partyTypeLabel(context, client.clientType),
      ),
      if (_present(client.nationalId) != null)
        _buildInfoRow(context.tr('national_id'), client.nationalId!),
      if (_present(client.registrationNo) != null)
        _buildInfoRow(
          context.tr('registration_number'),
          client.registrationNo!,
        ),
      if (_present(client.phone) != null)
        _buildInfoRow(context.tr('phone'), client.phone!),
      if (_present(client.email) != null)
        _buildInfoRow(context.tr('email'), client.email!),
      if (_present(client.address) != null)
        _buildInfoRow(context.tr('address'), client.address!),
      if (_present(client.notes) != null)
        _buildInfoRow(context.tr('notes'), client.notes!),
    ]);
  }

  Widget _buildOpponentSnapshots(
    BuildContext context,
    List<CaseOpponentSnapshot> opponents,
  ) {
    if (opponents.isEmpty) {
      return EmptyState(message: context.tr('no_opponents_added'));
    }
    return Column(
      children: [
        for (var index = 0; index < opponents.length; index++) ...[
          if (index > 0) const SizedBox(height: AppSpacing.s),
          _buildPartyCard([
            _buildInfoRow(context.tr('opponent_name'), opponents[index].name),
            _buildInfoRow(
              context.tr('opponent_type'),
              _partyTypeLabel(context, opponents[index].opponentType),
            ),
            if (_present(opponents[index].contact) != null)
              _buildInfoRow(
                context.tr('contact_details'),
                opponents[index].contact!,
              ),
            if (_present(opponents[index].representative) != null)
              _buildInfoRow(
                context.tr('representative'),
                opponents[index].representative!,
              ),
            if (_present(opponents[index].notes) != null)
              _buildInfoRow(context.tr('notes'), opponents[index].notes!),
          ]),
        ],
      ],
    );
  }

  Widget _buildPartyCard(List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.medium,
      ),
      child: Column(children: children),
    );
  }

  String _partyTypeLabel(BuildContext context, String value) {
    return context.tr(
      value.toUpperCase() == 'COMPANY' ? 'company' : 'individual',
    );
  }

  String? _present(String? value) {
    final trimmed = value?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
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
    if (legalCase.team.isEmpty) {
      return EmptyState(message: context.tr('no_team_members'));
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.medium,
        border: Border.all(color: AppColors.paperLine),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A0B192F),
            blurRadius: 12,
            offset: Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var index = 0; index < legalCase.team.length; index++) ...[
            if (index > 0) const Divider(height: 1, color: AppColors.paperLine),
            _TeamMemberRow(
              name:
                  _present(legalCase.team[index].user?.fullName) ??
                  legalCase.team[index].userId,
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _showAssignTeamMemberSheet(
    BuildContext context,
    LegalCase legalCase,
  ) async {
    final caseDetailsBloc = context.read<CaseDetailsBloc>();
    final assigned = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      builder: (sheetContext) => BlocProvider(
        create: (_) =>
            getIt<CaseTeamAssignmentBloc>()
              ..add(LoadCaseTeamAssignmentReferenceDataRequested()),
        child: _AssignTeamMemberSheet(
          caseId: legalCase.id,
          assignedUserIds: legalCase.team.map((member) => member.userId).toSet(),
        ),
      ),
    );
    if (assigned == true && context.mounted) {
      caseDetailsBloc.add(FetchCaseDetailsRequested(legalCase.id));
    }
  }
}

class _CaseDetailsTabs extends StatelessWidget {
  const _CaseDetailsTabs({
    required this.owner,
    required this.legalCase,
    required this.isUpdatingStatus,
  });

  final CaseDetailsPage owner;
  final LegalCase legalCase;
  final bool isUpdatingStatus;

  @override
  Widget build(BuildContext context) {
    final tabs = <_CaseTab>[
      _CaseTab(
        label: context.tr('overview'),
        icon: Icons.dashboard_outlined,
        child: _overviewTab(context),
      ),
      _CaseTab(
        label: context.tr('team'),
        icon: Icons.group_outlined,
        child: _teamTab(context),
      ),
      if (currentUserHasPerm(PermissionCodes.documentView))
        _CaseTab(
          label: context.tr('documents'),
          icon: Icons.folder_outlined,
          child: _documentsTab(context),
        ),
      if (currentUserHasPerm(PermissionCodes.hearingView))
        _CaseTab(
          label: context.tr('hearings'),
          icon: Icons.gavel_outlined,
          child: _hearingsTab(context),
        ),
      if (currentUserHasPerm(PermissionCodes.serviceView))
        _CaseTab(
          label: context.tr('service_of_process'),
          icon: Icons.outgoing_mail,
          child: _serviceTab(context),
        ),
      if (currentUserHasPerm(PermissionCodes.meetingView))
        _CaseTab(
          label: context.tr('client_meetings'),
          icon: Icons.groups_outlined,
          child: _meetingsTab(context),
        ),
      if (currentUserHasPerm(PermissionCodes.opponentView))
        _CaseTab(
          label: context.tr('opponents'),
          icon: Icons.person_off_outlined,
          child: _opponentsTab(context),
        ),
      if (currentUserHasPerm(PermissionCodes.taskView))
        _CaseTab(
          label: context.tr('tasks'),
          icon: Icons.task_alt_outlined,
          child: _tasksTab(context),
        ),
      if (currentUserHasPerm(PermissionCodes.financeCaseView))
        _CaseTab(
          label: context.tr('finance'),
          icon: Icons.account_balance_wallet_outlined,
          child: CaseFinanceTab(caseId: legalCase.id),
        ),
    ];

    return DefaultTabController(
      length: tabs.length,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.m,
          AppSpacing.s,
          AppSpacing.m,
          0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _breadcrumb(context),
            const SizedBox(height: AppSpacing.s),
            owner._buildHeader(context, legalCase),
            if (isUpdatingStatus) ...[
              const SizedBox(height: AppSpacing.s),
              const LinearProgressIndicator(),
            ],
            const SizedBox(height: AppSpacing.m),
            _actions(context),
            const SizedBox(height: AppSpacing.m),
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: AppColors.paperLine)),
              ),
              child: TabBar(
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                dividerColor: Colors.transparent,
                indicatorColor: AppColors.brass500,
                labelColor: AppColors.ink800,
                unselectedLabelColor: AppColors.ink400,
                labelStyle: AppTypography.labelMedium,
                tabs: [
                  for (final tab in tabs)
                    Tab(
                      height: 46,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(tab.icon, size: 17),
                          const SizedBox(width: 6),
                          Text(tab.label),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.m),
            Expanded(
              child: TabBarView(children: [for (final tab in tabs) tab.child]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _breadcrumb(BuildContext context) {
    return Row(
      children: [
        IconButton(
          tooltip: context.tr('cases'),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go(AppRouter.cases),
          icon: const Icon(Icons.arrow_back_rounded, size: 20),
        ),
        Text(context.tr('cases'), style: AppTypography.bodySmall),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 6),
          child: Icon(Icons.chevron_right_rounded, size: 16),
        ),
        Expanded(
          child: Text(
            legalCase.caseNumber,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.bodySmall.copyWith(
              fontFamily: AppTypography.monoFont,
              color: AppColors.ink600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _actions(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.s,
      runSpacing: AppSpacing.s,
      children: [
        if (currentUserHasPerm(PermissionCodes.caseStatusManage))
          OutlinedButton.icon(
            onPressed: isUpdatingStatus
                ? null
                : () => owner._showChangeStatusDialog(context, legalCase),
            icon: const Icon(Icons.swap_horiz_rounded, size: 18),
            label: Text(context.tr('change_case_status')),
          ),
        if (currentUserHasPerm(PermissionCodes.caseEdit))
          OutlinedButton.icon(
            onPressed: () async {
              final updated = await context.push<bool>(
                '${AppRouter.cases}/${legalCase.id}/edit',
                extra: legalCase,
              );
              if (updated == true && context.mounted) {
                context.read<CaseDetailsBloc>().add(
                  FetchCaseDetailsRequested(legalCase.id),
                );
              }
            },
            icon: const Icon(Icons.edit_outlined, size: 18),
            label: Text(context.tr('edit_case')),
          ),
      ],
    );
  }

  Widget _tabScroll(List<Widget> children) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _overviewTab(BuildContext context) {
    return _tabScroll([
      owner._buildOverview(context, legalCase),
      if (legalCase.clientSnapshot != null &&
          currentUserHasPerm(PermissionCodes.clientView)) ...[
        const SizedBox(height: AppSpacing.l),
        _sectionTitle(context.tr('client')),
        const SizedBox(height: AppSpacing.s),
        owner._buildClientSnapshot(context, legalCase.clientSnapshot!),
      ],
      if (legalCase.timelineEvents?.isNotEmpty ?? false) ...[
        const SizedBox(height: AppSpacing.l),
        _sectionTitle(context.tr('case_timeline')),
        const SizedBox(height: AppSpacing.s),
        owner._buildTimeline(context, legalCase.timelineEvents!),
      ],
    ]);
  }

  Widget _teamTab(BuildContext context) {
    return _tabScroll([
      _sectionHeader(
        context,
        context.tr('team'),
        currentUserHasPerm(PermissionCodes.caseAccessManage)
            ? AppButton(
                text: context.tr('add_team_member'),
                fullWidth: false,
                onPressed: () =>
                    owner._showAssignTeamMemberSheet(context, legalCase),
                icon: Icons.person_add_alt_1_outlined,
              )
            : null,
      ),
      const SizedBox(height: AppSpacing.s),
      owner._buildTeam(context, legalCase),
    ]);
  }

  Widget _documentsTab(BuildContext context) {
    return _tabScroll([
      _sectionHeader(
        context,
        context.tr('documents'),
        currentUserHasPerm(PermissionCodes.documentUpload)
            ? IconButton(
                tooltip: context.tr('upload_document'),
                onPressed: () =>
                    owner._showUploadOptions(context, legalCase.id),
                icon: const Icon(Icons.add_circle_outline),
              )
            : null,
      ),
      BlocBuilder<DocumentUploadBloc, DocumentUploadState>(
        builder: (context, state) {
          if (state is! DocumentUploadInProgress) {
            return const SizedBox.shrink();
          }
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.m),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(context.tr('uploading'), style: AppTypography.bodySmall),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: state.progress > 0 ? state.progress : null,
                ),
              ],
            ),
          );
        },
      ),
      owner._buildDocumentsSection(context),
    ]);
  }

  Widget _hearingsTab(BuildContext context) {
    return _tabScroll([
      _sectionHeader(
        context,
        context.tr('hearings'),
        currentUserHasPerm(PermissionCodes.hearingCreate)
            ? IconButton(
                tooltip: context.tr('new_hearing'),
                onPressed: () async {
                  final created = await context.push<bool>(
                    '${AppRouter.cases}/${legalCase.id}/hearings/new'
                    '?governorateId=${legalCase.governorateId ?? ''}',
                  );
                  if (created == true && context.mounted) {
                    context.read<CaseHearingsBloc>().add(
                      FetchCaseHearingsRequested(legalCase.id),
                    );
                  }
                },
                icon: const Icon(Icons.event_available_outlined),
              )
            : null,
      ),
      owner._buildHearingsSection(context, legalCase.governorateId),
    ]);
  }

  Widget _serviceTab(BuildContext context) {
    return _tabScroll([
      _sectionHeader(
        context,
        context.tr('service_of_process'),
        currentUserHasPerm(PermissionCodes.serviceCreate)
            ? IconButton(
                tooltip: context.tr('new_service_process'),
                onPressed: () async {
                  final created = await context.push<bool>(
                    '${AppRouter.cases}/${legalCase.id}/service/new'
                    '?governorateId=${legalCase.governorateId ?? ''}',
                  );
                  if (created == true && context.mounted) {
                    context.read<CaseServiceProcessBloc>().add(
                      FetchCaseServiceProcessesRequested(legalCase.id),
                    );
                  }
                },
                icon: const Icon(Icons.outgoing_mail),
              )
            : null,
      ),
      owner._buildServiceProcessesSection(context, legalCase.governorateId),
    ]);
  }

  Widget _meetingsTab(BuildContext context) {
    return _tabScroll([
      _sectionHeader(
        context,
        context.tr('client_meetings'),
        currentUserHasPerm(PermissionCodes.meetingCreate)
            ? IconButton(
                tooltip: context.tr('new_client_meeting'),
                onPressed: () async {
                  final created = await context.push<bool>(
                    '${AppRouter.cases}/${legalCase.id}/meetings/new',
                  );
                  if (created == true && context.mounted) {
                    context.read<CaseMeetingsBloc>().add(
                      FetchCaseMeetingsRequested(legalCase.id),
                    );
                  }
                },
                icon: const Icon(Icons.groups_outlined),
              )
            : null,
      ),
      owner._buildMeetingsSection(context),
    ]);
  }

  Widget _opponentsTab(BuildContext context) {
    return _tabScroll([
      _sectionTitle(context.tr('opponents')),
      const SizedBox(height: AppSpacing.s),
      owner._buildOpponentSnapshots(
        context,
        legalCase.opponentSnapshots ?? const [],
      ),
    ]);
  }

  Widget _tasksTab(BuildContext context) {
    return _tabScroll([
      _sectionHeader(
        context,
        context.tr('tasks'),
        currentUserHasPerm(PermissionCodes.taskCreate)
            ? IconButton(
                tooltip: context.tr('create_task'),
                onPressed: () async {
                  final created = await context.push<bool>(
                    '${AppRouter.cases}/${legalCase.id}/tasks/new',
                  );
                  if (created == true && context.mounted) {
                    context.read<CaseTasksBloc>().add(
                      FetchCaseTasksRequested(legalCase.id),
                    );
                  }
                },
                icon: const Icon(Icons.add_task),
              )
            : null,
      ),
      owner._buildTasksSection(context),
    ]);
  }

  Widget _sectionTitle(String title) => Text(title, style: AppTypography.h3);

  Widget _sectionHeader(BuildContext context, String title, Widget? action) {
    return Row(
      children: [
        Expanded(child: _sectionTitle(title)),
        if (action != null) action,
      ],
    );
  }
}

class _CaseTab {
  const _CaseTab({
    required this.label,
    required this.icon,
    required this.child,
  });

  final String label;
  final IconData icon;
  final Widget child;
}

class _AssignTeamMemberSheet extends StatefulWidget {
  final String caseId;
  final Set<String> assignedUserIds;
  const _AssignTeamMemberSheet({
    required this.caseId,
    required this.assignedUserIds,
  });

  @override
  State<_AssignTeamMemberSheet> createState() => _AssignTeamMemberSheetState();
}

class _AssignTeamMemberSheetState extends State<_AssignTeamMemberSheet> {
  String? _userId;

  @override
  Widget build(BuildContext context) {
    return BlocListener<CaseTeamAssignmentBloc, CaseTeamAssignmentState>(
      listener: (context, state) {
        if (state is CaseTeamAssignmentSuccess) {
          Navigator.of(context).pop(true);
        } else if (state is CaseTeamAssignmentReady &&
            state.submitError != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.submitError!)));
        }
      },
      child: BlocBuilder<CaseTeamAssignmentBloc, CaseTeamAssignmentState>(
        builder: (context, state) {
          if (state is CaseTeamAssignmentLoading ||
              state is CaseTeamAssignmentInitial) {
            return const Padding(
              padding: EdgeInsets.all(AppSpacing.xl),
              child: Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            );
          }
          if (state is! CaseTeamAssignmentReady) return const SizedBox();

          final employees = state.users
              .where((user) => !widget.assignedUserIds.contains(user.id))
              .toList(growable: false);

          return Padding(
            padding: EdgeInsets.only(
              left: AppSpacing.m,
              right: AppSpacing.m,
              top: AppSpacing.m,
              bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.m,
            ),
            child: SizedBox(
              height: MediaQuery.sizeOf(context).height * 0.82,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.tr('add_team_member'),
                    style: AppTypography.h3,
                  ),
                  const SizedBox(height: AppSpacing.s),
                  Text(
                    context.tr('add_team_member_hint'),
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.m),
                  AppDropdownField<String?>(
                    label: context.tr('employee'),
                    value: _userId,
                    backgroundColor: AppColors.surfaceLight,
                    items: employees.map((user) => user.id),
                    labelOf: (id) => id == null
                        ? context.tr('none')
                        : employees
                              .firstWhere((user) => user.id == id)
                              .fullName,
                    onChanged: (value) => setState(() {
                      _userId = value;
                    }),
                  ),
                  const SizedBox(height: AppSpacing.m),
                  if (employees.isEmpty)
                    Expanded(
                      child: Center(
                        child: Text(context.tr('no_employees_to_add')),
                      ),
                    )
                  else
                    const Spacer(),
                  AppButton(
                    text: context.tr('add_team_member'),
                    icon: Icons.person_add_alt_1_outlined,
                    isLoading: state.isSubmitting,
                    onPressed: _userId == null
                        ? null
                        : () => context.read<CaseTeamAssignmentBloc>().add(
                            CaseTeamAssignmentSubmitted(
                              widget.caseId,
                              AssignCaseRequest(
                                userId: _userId!,
                                capabilities: const ['case.view'],
                              ),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _TeamMemberRow extends StatelessWidget {
  const _TeamMemberRow({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final trimmed = name.trim();
    final initial = trimmed.isEmpty ? '?' : trimmed.characters.first;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.l,
        vertical: 12,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 17,
            backgroundColor: AppColors.brass100,
            child: Text(
              initial.toUpperCase(),
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.brass700,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.s),
          Expanded(
            child: Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.labelLarge.copyWith(
                color: AppColors.ink800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
