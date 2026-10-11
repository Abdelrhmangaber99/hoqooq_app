import 'package:equatable/equatable.dart';

/// Tolerates a JSON int, double, or numeric string — so one odd field cannot
/// throw away the whole summary.
int? _asInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '');
}

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
    // `GET /dashboard` returns `activeCases`; `GET /reports/dashboard` returns
    // `totalActiveCases`. Accept either so the parser is endpoint-agnostic.
    final active =
        _asInt(json['activeCases']) ?? _asInt(json['totalActiveCases']) ?? 0;
    return DashboardMetrics(
      // Real firm-wide total when the endpoint provides it; otherwise fall
      // back to the active count rather than showing 0.
      totalCases: _asInt(json['totalCases']) ?? active,
      totalActiveCases: active,
      pendingTasks: _asInt(json['pendingTasks']) ?? 0,
      upcomingHearings: _asInt(json['upcomingHearings']) ?? 0,
    );
  }

  @override
  List<Object?> get props =>
      [totalCases, totalActiveCases, pendingTasks, upcomingHearings];
}
