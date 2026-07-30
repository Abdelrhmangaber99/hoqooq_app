import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../di/injection.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../domain/entities/timeline_item.dart';
import '../bloc/calendar_bloc.dart';
import '../timeline_display_helpers.dart';

class CalendarPage extends StatelessWidget {
  const CalendarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<CalendarBloc>()..add(FetchTimelineRequested()),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: BlocBuilder<CalendarBloc, CalendarState>(
                  builder: (context, state) {
                    if (state is CalendarLoading || state is CalendarInitial) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      );
                    } else if (state is CalendarError) {
                      return ErrorView(
                        message: state.message,
                        onRetry: () => context.read<CalendarBloc>().add(
                          FetchTimelineRequested(),
                        ),
                      );
                    } else if (state is CalendarLoaded) {
                      return Column(
                        children: [
                          const SizedBox(height: AppSpacing.m),
                          _buildHeader(
                            context,
                            state.selectedDate,
                            state.viewMode,
                          ),
                          const SizedBox(height: AppSpacing.l),
                          if (state.viewMode == CalendarViewMode.month)
                            _buildCalendarGrid(
                              context,
                              state.items,
                              state.selectedDate,
                            ),
                          if (state.viewMode == CalendarViewMode.week)
                            _buildWeekView(context, state.selectedDate),
                          if (state.viewMode == CalendarViewMode.day)
                            _buildDayView(context, state.selectedDate),
                          const SizedBox(height: AppSpacing.l),
                          Expanded(
                            child: _buildEventsSection(
                              context,
                              state.items,
                              state.selectedDate,
                            ),
                          ),
                        ],
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
    );
  }

  Widget _buildHeader(
    BuildContext context,
    DateTime selectedDate,
    CalendarViewMode currentMode,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    '${_getMonthName(selectedDate.month)} ',
                    style: AppTypography.h1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                DropdownButton<int>(
                  value: selectedDate.year,
                  dropdownColor: AppColors.surface,
                  style: AppTypography.h1.copyWith(color: AppColors.primary),
                  underline: const SizedBox(),
                  icon: const Icon(
                    Icons.arrow_drop_down,
                    color: AppColors.primary,
                  ),
                  onChanged: (year) {
                    if (year != null) {
                      context.read<CalendarBloc>().add(
                        ChangeYearRequested(year),
                      );
                    }
                  },
                  items: List.generate(10, (index) => 2020 + index).map((year) {
                    return DropdownMenuItem(value: year, child: Text('$year'));
                  }).toList(),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppRadius.medium,
            ),
            child: Row(
              children: [
                _buildSegment(
                  context,
                  context.tr('month'),
                  currentMode == CalendarViewMode.month,
                  CalendarViewMode.month,
                ),
                _buildSegment(
                  context,
                  context.tr('week'),
                  currentMode == CalendarViewMode.week,
                  CalendarViewMode.week,
                ),
                _buildSegment(
                  context,
                  context.tr('day'),
                  currentMode == CalendarViewMode.day,
                  CalendarViewMode.day,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }

  Widget _buildSegment(
    BuildContext context,
    String label,
    bool isSelected,
    CalendarViewMode mode,
  ) {
    return GestureDetector(
      onTap: () =>
          context.read<CalendarBloc>().add(ChangeViewModeRequested(mode)),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: AppRadius.small,
        ),
        child: Text(
          label,
          style: AppTypography.labelMedium.copyWith(
            color: isSelected ? Colors.black : AppColors.textSecondary,
            fontSize: 10,
          ),
        ),
      ),
    );
  }

  Widget _buildCalendarGrid(
    BuildContext context,
    List<TimelineItem> items,
    DateTime selectedDate,
  ) {
    final days = ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'];
    final firstOfMonth = DateTime(selectedDate.year, selectedDate.month, 1);
    // DateTime.weekday is Mon=1..Sun=7; shift so Sun=0..Sat=6 to match the
    // Su-Mo-...-Sa header above.
    final firstWeekdayIndex = firstOfMonth.weekday % 7;
    final daysInMonth = DateTime(
      selectedDate.year,
      selectedDate.month + 1,
      0,
    ).day;
    final eventDays = items
        .map(timelineItemDate)
        .whereType<DateTime>()
        .where(
          (d) => d.year == selectedDate.year && d.month == selectedDate.month,
        )
        .map((d) => d.day)
        .toSet();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: days
                .map((day) => Text(day, style: AppTypography.bodySmall))
                .toList(),
          ),
          const SizedBox(height: AppSpacing.m),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
            ),
            itemCount: 42, // 6 weeks, enough for any month/offset combination
            itemBuilder: (context, index) {
              final dayNum = index - firstWeekdayIndex + 1;
              if (dayNum < 1 || dayNum > daysInMonth) return const SizedBox();

              final isSelected = dayNum == selectedDate.day;
              final hasEvent = eventDays.contains(dayNum);

              return GestureDetector(
                onTap: () => context.read<CalendarBloc>().add(
                  SelectDateRequested(
                    DateTime(selectedDate.year, selectedDate.month, dayNum),
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : Colors.transparent,
                    borderRadius: AppRadius.medium,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$dayNum',
                        style: AppTypography.bodyMedium.copyWith(
                          color: isSelected
                              ? Colors.black
                              : AppColors.textPrimary,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                      if (hasEvent && !isSelected)
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          width: 4,
                          height: 4,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWeekView(BuildContext context, DateTime selectedDate) {
    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
        itemCount: 7,
        itemBuilder: (context, index) {
          final monday = selectedDate.subtract(
            Duration(days: selectedDate.weekday - 1),
          );
          final day = monday.add(Duration(days: index));
          final isSelected =
              day.day == selectedDate.day && day.month == selectedDate.month;

          return GestureDetector(
            onTap: () =>
                context.read<CalendarBloc>().add(SelectDateRequested(day)),
            child: Container(
              width: 50,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.surface,
                borderRadius: AppRadius.medium,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'][index],
                    style: AppTypography.bodySmall.copyWith(
                      color: isSelected
                          ? Colors.black
                          : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${day.day}',
                    style: AppTypography.labelLarge.copyWith(
                      color: isSelected ? Colors.black : AppColors.textPrimary,
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

  Widget _buildDayView(BuildContext context, DateTime selectedDate) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.m),
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.medium,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.calendar_today, size: 16, color: AppColors.primary),
          const SizedBox(width: 12),
          Text(
            '${selectedDate.day} ${_getMonthName(selectedDate.month)}',
            style: AppTypography.bodyMedium.copyWith(color: AppColors.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildEventsSection(
    BuildContext context,
    List<TimelineItem> items,
    DateTime selectedDate,
  ) {
    final dayItems = items.where((item) {
      final date = timelineItemDate(item);
      return date != null &&
          date.year == selectedDate.year &&
          date.month == selectedDate.month &&
          date.day == selectedDate.day;
    }).toList();

    return Container(
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.l)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${_getMonthName(selectedDate.month)} ${selectedDate.day} — ${dayItems.length} ${context.tr('events')}',
            style: AppTypography.h3,
          ),
          const SizedBox(height: AppSpacing.m),
          Expanded(
            child: dayItems.isEmpty
                ? EmptyState(message: context.tr('no_events_for_day'))
                : ListView.separated(
                    itemCount: dayItems.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: AppSpacing.m),
                    itemBuilder: (context, index) =>
                        _buildEventItem(context, dayItems[index]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventItem(BuildContext context, TimelineItem item) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight.withValues(alpha: 0.5),
        borderRadius: AppRadius.medium,
        border: Border(
          left: BorderSide(
            color: timelineItemColor(item).withValues(alpha: 0.8),
            width: 4,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(timelineItemTitle(item), style: AppTypography.labelLarge),
                const SizedBox(height: 4),
                Text(
                  timelineItemSubtitle(context, item),
                  style: AppTypography.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
