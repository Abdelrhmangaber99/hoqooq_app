import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../di/injection.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../domain/entities/app_notification.dart';
import '../bloc/notifications_bloc.dart';
import '../notification_display_helpers.dart';

/// Rebuilt against real data (`GET /notifications/me` + `PATCH .../read`,
/// API_CONTRACT.md finding S) — previously 100%-static mock content since
/// before M1. The mock's category filter chips (`hearings`/
/// `deadline_alerts`) and per-item custom subtitle/icon are dropped: the
/// real response has no server-side type filter and no field beyond
/// `title`/`message`/`type` to build either from. "Mark all read" stays,
/// implemented as N concurrent `PATCH` calls over the currently-loaded
/// list — there's no bulk endpoint.
class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          getIt<NotificationsBloc>()..add(FetchNotificationsRequested()),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: BlocListener<NotificationsBloc, NotificationsState>(
            listenWhen: (previous, current) =>
                current is NotificationsLoaded && current.actionError != null,
            listener: (context, state) {
              final message = (state as NotificationsLoaded).actionError!;
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(message)));
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppSpacing.m),
                  _buildHeader(context),
                  const SizedBox(height: AppSpacing.l),
                  Expanded(
                    child: BlocBuilder<NotificationsBloc, NotificationsState>(
                      builder: (context, state) {
                        if (state is NotificationsLoading ||
                            state is NotificationsInitial) {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                            ),
                          );
                        } else if (state is NotificationsError) {
                          return ErrorView(
                            message: state.message,
                            isForbidden: state.isForbidden,
                            onRetry: () => context
                                .read<NotificationsBloc>()
                                .add(FetchNotificationsRequested()),
                          );
                        } else if (state is NotificationsLoaded) {
                          if (state.notifications.isEmpty) {
                            return EmptyState(
                              message: context.tr('no_notifications_found'),
                            );
                          }
                          return _buildNotificationsList(
                            context,
                            state.notifications,
                          );
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

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(context.tr('alerts'), style: AppTypography.h1),
        BlocBuilder<NotificationsBloc, NotificationsState>(
          builder: (context, state) {
            final hasNotifications =
                state is NotificationsLoaded && state.notifications.isNotEmpty;
            if (!hasNotifications) return const SizedBox();
            return GestureDetector(
              onTap: () => context.read<NotificationsBloc>().add(
                AllNotificationsMarkedAsReadRequested(),
              ),
              child: Text(
                context.tr('mark_all_read'),
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.primary,
                  fontSize: 12,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildNotificationsList(
    BuildContext context,
    List<AppNotification> notifications,
  ) {
    final dateFormat = DateFormat.yMMMd().add_jm();
    return ListView.separated(
      itemCount: notifications.length,
      separatorBuilder: (_, _) =>
          const Divider(color: AppColors.surfaceLight, height: 1),
      itemBuilder: (context, index) {
        final notification = notifications[index];
        return GestureDetector(
          onTap: () => context.read<NotificationsBloc>().add(
            NotificationMarkedAsReadRequested(notification.id),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        notificationTypeIcon(notification.type),
                        size: 20,
                        color: notificationTypeColor(notification.type),
                      ),
                    ),
                    // GET /notifications/me returns unread only, so every
                    // item in this list is unread by definition.
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
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
                              notification.title,
                              style: AppTypography.labelLarge,
                            ),
                          ),
                          Text(
                            dateFormat.format(notification.createdAt),
                            style: AppTypography.bodySmall.copyWith(
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification.message,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
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
}
