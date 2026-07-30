import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../di/injection.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../authentication/domain/entities/user.dart';
import '../../../authentication/presentation/bloc/session_cubit.dart';
import '../../../documents/domain/entities/document_item.dart';
import '../../../documents/presentation/bloc/document_upload_bloc.dart';
import '../../../hearings/domain/entities/hearing.dart';
import '../../../hearings/presentation/hearing_display_helpers.dart';
import '../../domain/entities/legal_case.dart';
import '../bloc/case_details_bloc.dart';
import '../bloc/case_documents_bloc.dart';
import '../bloc/case_hearings_bloc.dart';
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
        BlocProvider(
          create: (context) =>
              getIt<CaseHearingsBloc>()
                ..add(FetchCaseHearingsRequested(caseId)),
        ),
        BlocProvider(
          create: (context) =>
              getIt<CaseDocumentsBloc>()
                ..add(FetchCaseDocumentsRequested(caseId)),
        ),
        BlocProvider(create: (context) => getIt<DocumentUploadBloc>()),
      ],
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: Text(context.tr('case_details'))),
        body: SafeArea(
          child: BlocListener<DocumentUploadBloc, DocumentUploadState>(
            listener: (context, state) {
              if (state is DocumentUploadSuccess) {
                context.read<CaseDocumentsBloc>().add(
                  FetchCaseDocumentsRequested(caseId),
                );
              } else if (state is DocumentUploadFailure) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(state.message)));
              }
            },
            child: BlocBuilder<CaseDetailsBloc, CaseDetailsState>(
              builder: (context, state) {
                if (state is CaseDetailsLoading ||
                    state is CaseDetailsInitial) {
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
      ),
    );
  }

  Widget _buildContent(BuildContext context, LegalCase legalCase) {
    // BR-026: agreedFee is finance-gated. isFirmAdmin is derived at login
    // (ownerUserId == user.id — see SessionCubit.authenticated); default
    // to hidden whenever there's no authenticated session at all.
    final sessionState = getIt<SessionCubit>().state;
    final isFirmAdmin =
        sessionState is SessionAuthenticated && sessionState.isFirmAdmin;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.m),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, legalCase),
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
          const SizedBox(height: AppSpacing.l),
          Text(context.tr('overview'), style: AppTypography.h3),
          const SizedBox(height: AppSpacing.m),
          _buildOverview(context, legalCase, showAgreedFee: isFirmAdmin),
          const SizedBox(height: AppSpacing.l),
          Text(context.tr('team'), style: AppTypography.h3),
          const SizedBox(height: AppSpacing.m),
          _buildTeam(context, legalCase),
          const SizedBox(height: AppSpacing.l),
          Text(context.tr('hearings'), style: AppTypography.h3),
          const SizedBox(height: AppSpacing.m),
          _buildHearingsSection(context),
          const SizedBox(height: AppSpacing.l),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(context.tr('documents'), style: AppTypography.h3),
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
              if (state is! DocumentUploadInProgress) return const SizedBox();
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
      ),
    );
  }

  Widget _buildHearingsSection(BuildContext context) {
    return BlocBuilder<CaseHearingsBloc, CaseHearingsState>(
      builder: (context, state) {
        if (state is CaseHearingsLoading || state is CaseHearingsInitial) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        } else if (state is CaseHearingsError) {
          return ErrorView(
            message: state.message,
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
                .map((h) => _buildHearingItem(context, h))
                .toList(),
          );
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildHearingItem(BuildContext context, Hearing hearing) {
    final dateFormat = DateFormat.yMMMd().add_jm();
    return GestureDetector(
      onTap: () async {
        final updated = await context.push<bool>(
          '${AppRouter.cases}/${hearing.caseId}/hearings/${hearing.id}/edit',
          extra: hearing,
        );
        if (updated == true && context.mounted) {
          context.read<CaseHearingsBloc>().add(
            FetchCaseHearingsRequested(caseId),
          );
        }
      },
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

  Widget _buildDocumentsSection(BuildContext context) {
    return BlocBuilder<CaseDocumentsBloc, CaseDocumentsState>(
      builder: (context, state) {
        if (state is CaseDocumentsLoading || state is CaseDocumentsInitial) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        } else if (state is CaseDocumentsError) {
          return ErrorView(
            message: state.message,
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
        ],
      ),
    );
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
      final result = await FilePicker.platform.pickFiles();
      filePath = result?.files.single.path;
    }

    if (filePath == null) return;
    bloc.add(DocumentUploadRequested(filePath: filePath, caseId: caseId));
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
          Text(
            legalCase.caseType?.name ?? context.tr('unknown'),
            style: AppTypography.h2,
          ),
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
          if (legalCase.defaultCourt != null)
            _buildInfoRow(context.tr('court'), legalCase.defaultCourt!.name),
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
      if (legalCase.primaryLawyerId != null)
        _TeamEntry(
          user: legalCase.primaryLawyer,
          userId: legalCase.primaryLawyerId!,
          roleLabel: context.tr('primary_lawyer'),
        ),
      ...legalCase.team.map(
        (m) =>
            _TeamEntry(user: m.user, userId: m.userId, roleLabel: m.roleOnCase),
      ),
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
                      entry.user?.fullName ?? entry.userId,
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
  final User? user;
  final String userId;
  final String roleLabel;
  _TeamEntry({
    required this.user,
    required this.userId,
    required this.roleLabel,
  });
}
