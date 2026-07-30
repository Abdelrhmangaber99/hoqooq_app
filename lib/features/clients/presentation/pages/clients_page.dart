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
import '../../domain/entities/client.dart';
import '../../domain/entities/client_status.dart';
import '../bloc/clients_bloc.dart';
import '../client_display_helpers.dart';

class ClientsPage extends StatelessWidget {
  const ClientsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<ClientsBloc>()..add(FetchClientsRequested()),
      child: Builder(
        builder: (context) => Scaffold(
          backgroundColor: AppColors.background,
          floatingActionButton: FloatingActionButton(
            backgroundColor: AppColors.primary,
            onPressed: () async {
              final created = await context.push<bool>(
                '${AppRouter.clients}/new',
              );
              if (created == true && context.mounted) {
                context.read<ClientsBloc>().add(FetchClientsRequested());
              }
            },
            child: const Icon(Icons.add),
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppSpacing.m),
                  Text(context.tr('clients'), style: AppTypography.h1),
                  const SizedBox(height: AppSpacing.l),
                  _buildSearchBar(context),
                  const SizedBox(height: AppSpacing.m),
                  _buildStatusFilters(context),
                  const SizedBox(height: AppSpacing.m),
                  Expanded(
                    child: BlocBuilder<ClientsBloc, ClientsState>(
                      builder: (context, state) {
                        if (state is ClientsLoading ||
                            state is ClientsInitial) {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                            ),
                          );
                        } else if (state is ClientsError) {
                          return ErrorView(
                            message: state.message,
                            onRetry: () => context.read<ClientsBloc>().add(
                              FetchClientsRequested(),
                            ),
                          );
                        } else if (state is ClientsLoaded) {
                          if (state.clients.isEmpty) {
                            return EmptyState(
                              message: context.tr('no_clients_found'),
                            );
                          }
                          return _buildClientsList(context, state.clients);
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

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.medium,
      ),
      child: TextField(
        onChanged: (value) {
          context.read<ClientsBloc>().add(ClientsSearchChanged(value));
        },
        style: AppTypography.bodyMedium,
        decoration: InputDecoration(
          hintText: context.tr('search_clients'),
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
    return BlocBuilder<ClientsBloc, ClientsState>(
      builder: (context, state) {
        final activeFilter = state is ClientsLoaded ? state.statusFilter : null;
        final filters = <ClientStatus?>[
          null,
          ClientStatus.active,
          ClientStatus.archived,
          ClientStatus.inactive,
        ];
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: filters.map((status) {
              final isSelected = status == activeFilter;
              final label = status == null
                  ? context.tr('all')
                  : clientStatusLabel(context, status);
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(label),
                  selected: isSelected,
                  onSelected: (_) => context.read<ClientsBloc>().add(
                    ClientsStatusFilterChanged(status),
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

  Widget _buildClientsList(BuildContext context, List<Client> clients) {
    return ListView.separated(
      itemCount: clients.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.m),
      itemBuilder: (context, index) {
        final client = clients[index];
        return GestureDetector(
          onTap: () => context.push('${AppRouter.clients}/${client.id}'),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.m),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppRadius.medium,
              border: Border.all(color: AppColors.surfaceLight),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      _getInitials(client.fullName),
                      style: AppTypography.labelLarge.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.m),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              client.fullName,
                              style: AppTypography.labelLarge,
                            ),
                          ),
                          _buildStatusBadge(
                            clientStatusLabel(context, client.status),
                            clientStatusColor(client.status),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(client.clientCode, style: AppTypography.bodySmall),
                      if (client.emails.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          client.emails.first,
                          style: AppTypography.bodySmall.copyWith(fontSize: 10),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase();
    }
    if (parts.isEmpty || parts[0].isEmpty) return '?';
    return parts[0].substring(0, 1).toUpperCase();
  }

  Widget _buildStatusBadge(String text, Color color) {
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
