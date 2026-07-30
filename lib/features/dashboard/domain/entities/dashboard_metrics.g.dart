// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_metrics.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DashboardMetrics _$DashboardMetricsFromJson(Map<String, dynamic> json) =>
    _DashboardMetrics(
      totalActiveCases: (json['totalActiveCases'] as num).toInt(),
      pendingTasks: (json['pendingTasks'] as num).toInt(),
      upcomingHearings: (json['upcomingHearings'] as num).toInt(),
    );

Map<String, dynamic> _$DashboardMetricsToJson(_DashboardMetrics instance) =>
    <String, dynamic>{
      'totalActiveCases': instance.totalActiveCases,
      'pendingTasks': instance.pendingTasks,
      'upcomingHearings': instance.upcomingHearings,
    };
