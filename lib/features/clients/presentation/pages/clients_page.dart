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
import '../bloc/clients_bloc.dart';
import '../../domain/entities/client.dart';

class ClientsPage extends StatelessWidget {
  const ClientsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<ClientsBloc>()..add(const FetchClientsRequested()),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.m),
                _buildHeader(context),
                const SizedBox(height: AppSpacing.l),
                BlocBuilder<ClientsBloc, ClientsState>(
                  builder: (context, state) {
                    final query = state is ClientsLoaded ? state.searchQuery : '';
                    final filter = state is ClientsLoaded ? state.activeFilter : 'All';
                    return Column(
                      children: [
                        _buildSearchBar(context, query),
                        const SizedBox(height: AppSpacing.m),
                        _buildFilters(context, filter),
                      ],
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.m),
                Expanded(
                  child: BlocBuilder<ClientsBloc, ClientsState>(
                    builder: (context, state) {
                      if (state is ClientsLoading) {
                        return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                      } else if (state is ClientsError) {
                        return Center(child: Text(state.message, style: const TextStyle(color: AppColors.error)));
                      } else if (state is ClientsLoaded) {
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
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(context.tr('clients'), style: AppTypography.h1),
            Text('7 total', style: AppTypography.bodySmall),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
          ),
          child: const Icon(Icons.add, color: AppColors.primary, size: 20),
        ),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context, String currentQuery) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.medium,
      ),
      child: TextField(
        onChanged: (value) {
          context.read<ClientsBloc>().add(FetchClientsRequested(searchQuery: value));
        },
        style: AppTypography.bodyMedium,
        decoration: InputDecoration(
          hintText: context.tr('search_clients'),
          prefixIcon: const Icon(Icons.search, color: AppColors.textHint, size: 20),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildFilters(BuildContext context, String activeFilter) {
    final filters = [
      'All',
      'Active',
      'New',
      'Closed'
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(filters.length, (index) {
          final filter = filters[index];
          final isSelected = filter == activeFilter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(context.tr(filter.toLowerCase())),
              selected: isSelected,
              onSelected: (_) {
                context.read<ClientsBloc>().add(FetchClientsRequested(filter: filter));
              },
              backgroundColor: AppColors.surface,
              selectedColor: AppColors.primary,
              labelStyle: AppTypography.labelMedium.copyWith(
                color: isSelected ? Colors.black : AppColors.textSecondary,
                fontSize: 12,
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              side: BorderSide.none,
              showCheckmark: false,
            ),
          );
        }),
      ),
    );
  }

  Widget _buildClientsList(BuildContext context, List<Client> clients) {
    return ListView.separated(
      itemCount: clients.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.m),
      itemBuilder: (context, index) {
        final client = clients[index];
        return GestureDetector(
          onTap: () => context.push('${AppRouter.clients}/profile'),
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
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                  ),
                  child: Center(
                    child: Text(
                      _getInitials(client.name),
                      style: AppTypography.labelLarge.copyWith(color: AppColors.primary),
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
                          Text(client.name, style: AppTypography.labelLarge),
                          _buildStatusBadge(client.status, client.status == 'Active' ? Colors.green : Colors.orange),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(client.area, style: AppTypography.bodySmall),
                      const SizedBox(height: 4),
                      Text(client.info, style: AppTypography.bodySmall.copyWith(fontSize: 10)),
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
    List<String> parts = name.split(' ');
    if (parts.length >= 2) {
      return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase();
    }
    return name.substring(0, 1).toUpperCase();
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
