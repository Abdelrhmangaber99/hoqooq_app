import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../di/injection.dart';
import '../bloc/calendar_bloc.dart';
import '../../domain/entities/appointment.dart';

class CalendarPage extends StatelessWidget {
  const CalendarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<CalendarBloc>()..add(const FetchAppointmentsRequested()),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: BlocBuilder<CalendarBloc, CalendarState>(
                  builder: (context, state) {
                    if (state is CalendarLoading) {
                      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                    } else if (state is CalendarError) {
                      return Center(child: Text(state.message, style: const TextStyle(color: AppColors.error)));
                    } else if (state is CalendarLoaded) {
                      return Column(
                        children: [
                          const SizedBox(height: AppSpacing.m),
                          _buildHeader(context, state.selectedDate, state.viewMode),
                          const SizedBox(height: AppSpacing.l),
                          if (state.viewMode == CalendarViewMode.month)
                            _buildCalendarGrid(context, state.selectedDate),
                          if (state.viewMode == CalendarViewMode.week)
                            _buildWeekView(context, state.selectedDate),
                          if (state.viewMode == CalendarViewMode.day)
                            _buildDayView(context, state.selectedDate),
                          const SizedBox(height: AppSpacing.l),
                          Expanded(child: _buildEventsSection(context, state.appointments, state.selectedDate)),
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

  Widget _buildHeader(BuildContext context, DateTime selectedDate, CalendarViewMode currentMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text('${_getMonthName(selectedDate.month)} ', style: AppTypography.h1),
                  DropdownButton<int>(
                    value: selectedDate.year,
                    dropdownColor: AppColors.surface,
                    style: AppTypography.h1.copyWith(color: AppColors.primary),
                    underline: const SizedBox(),
                    icon: const Icon(Icons.arrow_drop_down, color: AppColors.primary),
                    onChanged: (year) {
                      if (year != null) {
                        context.read<CalendarBloc>().add(ChangeYearRequested(year));
                      }
                    },
                    items: List.generate(10, (index) => 2020 + index).map((year) {
                      return DropdownMenuItem(value: year, child: Text('$year'));
                    }).toList(),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: AppRadius.medium,
                ),
                child: Row(
                  children: [
                    _buildSegment(context, context.tr('month'), currentMode == CalendarViewMode.month, CalendarViewMode.month),
                    _buildSegment(context, context.tr('week'), currentMode == CalendarViewMode.week, CalendarViewMode.week),
                    _buildSegment(context, context.tr('day'), currentMode == CalendarViewMode.day, CalendarViewMode.day),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getMonthName(int month) {
    const months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
    return months[month - 1];
  }

  Widget _buildSegment(BuildContext context, String label, bool isSelected, CalendarViewMode mode) {
    return GestureDetector(
      onTap: () {
        context.read<CalendarBloc>().add(ChangeViewModeRequested(mode));
      },
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

  Widget _buildCalendarGrid(BuildContext context, DateTime selectedDate) {
    final days = ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: days.map((day) => Text(day, style: AppTypography.bodySmall)).toList(),
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
            itemCount: 35, // 5 weeks
            itemBuilder: (context, index) {
              final dayNum = index - 2; // Offset for July 2026 starting on Wednesday (index 3)
              if (dayNum < 1 || dayNum > 31) return const SizedBox();
              
              final isSelected = dayNum == selectedDate.day;
              final hasEvent = [7, 14, 16, 22, 28].contains(dayNum);
              
              return GestureDetector(
                onTap: () {
                  context.read<CalendarBloc>().add(SelectDateRequested(DateTime(selectedDate.year, selectedDate.month, dayNum)));
                },
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
                          color: isSelected ? Colors.black : AppColors.textPrimary,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
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
          // Find the Monday of the current week
          final monday = selectedDate.subtract(Duration(days: selectedDate.weekday - 1));
          final day = monday.add(Duration(days: index));
          final isSelected = day.day == selectedDate.day;

          return GestureDetector(
            onTap: () => context.read<CalendarBloc>().add(SelectDateRequested(day)),
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
                    style: AppTypography.bodySmall.copyWith(color: isSelected ? Colors.black : AppColors.textSecondary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${day.day}',
                    style: AppTypography.labelLarge.copyWith(color: isSelected ? Colors.black : AppColors.textPrimary),
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
            'Viewing agenda for ${selectedDate.day} ${_getMonthName(selectedDate.month)}',
            style: AppTypography.bodyMedium.copyWith(color: AppColors.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildEventsSection(BuildContext context, List<Appointment> appointments, DateTime selectedDate) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.l)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${_getMonthName(selectedDate.month)} ${selectedDate.day} — ${appointments.length} ${context.tr('events')}', style: AppTypography.h3),
          const SizedBox(height: AppSpacing.m),
          Expanded(
            child: appointments.isEmpty 
              ? Center(child: Text('No events for this day', style: AppTypography.bodySmall))
              : ListView.separated(
                  itemCount: appointments.length,
                  separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.m),
                  itemBuilder: (context, index) {
                    final appt = appointments[index];
                    return _buildEventItem(appt.title, appt.time, appt.type == 'Hearing' ? Colors.green : Colors.purple);
                  },
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventItem(String title, String time, Color color) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight.withValues(alpha: 0.5),
        borderRadius: AppRadius.medium,
        border: Border(left: BorderSide(color: color.withValues(alpha: 0.8), width: 4)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTypography.labelLarge),
              const SizedBox(height: 4),
              Text(time, style: AppTypography.bodySmall),
            ],
          ),
          const Icon(Icons.chevron_right, color: AppColors.textHint, size: 20),
        ],
      ),
    );
  }
}
