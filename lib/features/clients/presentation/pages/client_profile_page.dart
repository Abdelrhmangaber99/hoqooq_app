import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../di/injection.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../cases/domain/entities/legal_case.dart';
import '../../../cases/presentation/case_display_helpers.dart';
import '../../domain/entities/client.dart';
import '../bloc/client_details_bloc.dart';
import '../client_display_helpers.dart';

class ClientProfilePage extends StatelessWidget {
  final String clientId;

  const ClientProfilePage({super.key, required this.clientId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          getIt<ClientDetailsBloc>()
            ..add(FetchClientDetailsRequested(clientId)),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: Text(context.tr('client_profile'))),
        body: SafeArea(
          child: BlocBuilder<ClientDetailsBloc, ClientDetailsState>(
            builder: (context, state) {
              if (state is ClientDetailsLoading ||
                  state is ClientDetailsInitial) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              } else if (state is ClientDetailsError) {
                return ErrorView(
                  message: state.message,
                  onRetry: () => context.read<ClientDetailsBloc>().add(
                    FetchClientDetailsRequested(clientId),
                  ),
                );
              } else if (state is ClientDetailsLoaded) {
                return _buildContent(context, state.client, state.cases);
              }
              return const SizedBox();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    Client client,
    List<LegalCase> cases,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.m),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderCard(context, client),
          const SizedBox(height: AppSpacing.m),
          AppButton(
            text: context.tr('edit_client'),
            style: AppButtonStyle.outline,
            onPressed: () async {
              final updated = await context.push<bool>(
                '${AppRouter.clients}/${client.id}/edit',
                extra: client,
              );
              if (updated == true && context.mounted) {
                context.read<ClientDetailsBloc>().add(
                  FetchClientDetailsRequested(client.id),
                );
              }
            },
          ),
          const SizedBox(height: AppSpacing.l),
          Text(context.tr('contact_info'), style: AppTypography.h3),
          const SizedBox(height: AppSpacing.m),
          _buildContactInfo(context, client),
          const SizedBox(height: AppSpacing.l),
          Text(context.tr('cases'), style: AppTypography.h3),
          const SizedBox(height: AppSpacing.m),
          if (cases.isEmpty)
            Text(
              context.tr('no_cases_for_client'),
              style: AppTypography.bodySmall,
            )
          else
            ...cases.map((c) => _buildCaseItem(context, c)),
        ],
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context, Client client) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.l),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.large,
        border: Border.all(color: AppColors.surfaceLight),
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.3),
              ),
            ),
            child: Center(
              child: Text(
                clientTypeLabel(context, client.type).substring(0, 1),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.m),
          Text(client.fullName, style: AppTypography.h2),
          const SizedBox(height: 4),
          Text(
            '${clientTypeLabel(context, client.type)} · ${client.clientCode}',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            clientStatusLabel(context, client.status),
            style: AppTypography.bodySmall.copyWith(
              color: clientStatusColor(client.status),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfo(BuildContext context, Client client) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.medium,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (client.emails.isNotEmpty)
            _buildInfoRow(
              context,
              Icons.email_outlined,
              context.tr('emails'),
              client.emails.join(', '),
            ),
          if (client.phones.isNotEmpty)
            _buildInfoRow(
              context,
              Icons.phone_outlined,
              context.tr('phones'),
              client.phones.join(', '),
            ),
          if (client.addresses.isNotEmpty)
            _buildInfoRow(
              context,
              Icons.location_on_outlined,
              context.tr('addresses'),
              client.addresses.join(', '),
            ),
          if (client.nationalId != null)
            _buildInfoRow(
              context,
              Icons.badge_outlined,
              context.tr('national_id'),
              client.nationalId!,
            ),
          if (client.commercialReg != null)
            _buildInfoRow(
              context,
              Icons.business_outlined,
              context.tr('commercial_reg'),
              client.commercialReg!,
            ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: AppColors.primary),
          ),
          const SizedBox(width: AppSpacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTypography.labelMedium.copyWith(
                    fontSize: 10,
                    color: AppColors.textHint,
                  ),
                ),
                const SizedBox(height: 2),
                Text(value, style: AppTypography.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCaseItem(BuildContext context, LegalCase legalCase) {
    return GestureDetector(
      onTap: () => context.push('${AppRouter.cases}/${legalCase.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.m),
        padding: const EdgeInsets.all(AppSpacing.m),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.medium,
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  legalCase.caseType?.name ?? context.tr('unknown'),
                  style: AppTypography.labelLarge,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: caseStatusColor(
                      legalCase.status,
                    ).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    caseStatusLabel(context, legalCase.status),
                    style: TextStyle(
                      color: caseStatusColor(legalCase.status),
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  legalCase.caseNumber,
                  style: AppTypography.bodySmall.copyWith(fontSize: 10),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
