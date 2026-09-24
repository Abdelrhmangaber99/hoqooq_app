import 'package:equatable/equatable.dart';

class DashboardMetrics extends Equatable {
  const DashboardMetrics({
    this.totalCases = 0,
    required this.totalActiveCases,
    required this.pendingTasks,
    required this.upcomingHearings,
  });

  final int totalCases;
  final int totalActiveCases;
  final int pendingTasks;
  final int upcomingHearings;

  factory DashboardMetrics.fromJson(Map<String, dynamic> json) {
    final active = (json['activeCases'] as int?) ??
        (json['totalActiveCases'] as int?) ??
        0;
    return DashboardMetrics(
      totalCases: (json['totalCases'] as int?) ?? active,
      totalActiveCases: active,
      pendingTasks: (json['pendingTasks'] as int?) ?? 0,
      upcomingHearings: (json['upcomingHearings'] as int?) ?? 0,
    );
  }

  @override
  List<Object?> get props =>
      [totalCases, totalActiveCases, pendingTasks, upcomingHearings];
}
