// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dashboard_metrics.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DashboardMetrics {

 int get totalActiveCases; int get pendingTasks; int get upcomingHearings;
/// Create a copy of DashboardMetrics
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DashboardMetricsCopyWith<DashboardMetrics> get copyWith => _$DashboardMetricsCopyWithImpl<DashboardMetrics>(this as DashboardMetrics, _$identity);

  /// Serializes this DashboardMetrics to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DashboardMetrics&&(identical(other.totalActiveCases, totalActiveCases) || other.totalActiveCases == totalActiveCases)&&(identical(other.pendingTasks, pendingTasks) || other.pendingTasks == pendingTasks)&&(identical(other.upcomingHearings, upcomingHearings) || other.upcomingHearings == upcomingHearings));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalActiveCases,pendingTasks,upcomingHearings);

@override
String toString() {
  return 'DashboardMetrics(totalActiveCases: $totalActiveCases, pendingTasks: $pendingTasks, upcomingHearings: $upcomingHearings)';
}


}

/// @nodoc
abstract mixin class $DashboardMetricsCopyWith<$Res>  {
  factory $DashboardMetricsCopyWith(DashboardMetrics value, $Res Function(DashboardMetrics) _then) = _$DashboardMetricsCopyWithImpl;
@useResult
$Res call({
 int totalActiveCases, int pendingTasks, int upcomingHearings
});




}
/// @nodoc
class _$DashboardMetricsCopyWithImpl<$Res>
    implements $DashboardMetricsCopyWith<$Res> {
  _$DashboardMetricsCopyWithImpl(this._self, this._then);

  final DashboardMetrics _self;
  final $Res Function(DashboardMetrics) _then;

/// Create a copy of DashboardMetrics
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? totalActiveCases = null,Object? pendingTasks = null,Object? upcomingHearings = null,}) {
  return _then(_self.copyWith(
totalActiveCases: null == totalActiveCases ? _self.totalActiveCases : totalActiveCases // ignore: cast_nullable_to_non_nullable
as int,pendingTasks: null == pendingTasks ? _self.pendingTasks : pendingTasks // ignore: cast_nullable_to_non_nullable
as int,upcomingHearings: null == upcomingHearings ? _self.upcomingHearings : upcomingHearings // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [DashboardMetrics].
extension DashboardMetricsPatterns on DashboardMetrics {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DashboardMetrics value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DashboardMetrics() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DashboardMetrics value)  $default,){
final _that = this;
switch (_that) {
case _DashboardMetrics():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DashboardMetrics value)?  $default,){
final _that = this;
switch (_that) {
case _DashboardMetrics() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int totalActiveCases,  int pendingTasks,  int upcomingHearings)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DashboardMetrics() when $default != null:
return $default(_that.totalActiveCases,_that.pendingTasks,_that.upcomingHearings);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int totalActiveCases,  int pendingTasks,  int upcomingHearings)  $default,) {final _that = this;
switch (_that) {
case _DashboardMetrics():
return $default(_that.totalActiveCases,_that.pendingTasks,_that.upcomingHearings);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int totalActiveCases,  int pendingTasks,  int upcomingHearings)?  $default,) {final _that = this;
switch (_that) {
case _DashboardMetrics() when $default != null:
return $default(_that.totalActiveCases,_that.pendingTasks,_that.upcomingHearings);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DashboardMetrics implements DashboardMetrics {
  const _DashboardMetrics({required this.totalActiveCases, required this.pendingTasks, required this.upcomingHearings});
  factory _DashboardMetrics.fromJson(Map<String, dynamic> json) => _$DashboardMetricsFromJson(json);

@override final  int totalActiveCases;
@override final  int pendingTasks;
@override final  int upcomingHearings;

/// Create a copy of DashboardMetrics
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DashboardMetricsCopyWith<_DashboardMetrics> get copyWith => __$DashboardMetricsCopyWithImpl<_DashboardMetrics>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DashboardMetricsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DashboardMetrics&&(identical(other.totalActiveCases, totalActiveCases) || other.totalActiveCases == totalActiveCases)&&(identical(other.pendingTasks, pendingTasks) || other.pendingTasks == pendingTasks)&&(identical(other.upcomingHearings, upcomingHearings) || other.upcomingHearings == upcomingHearings));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalActiveCases,pendingTasks,upcomingHearings);

@override
String toString() {
  return 'DashboardMetrics(totalActiveCases: $totalActiveCases, pendingTasks: $pendingTasks, upcomingHearings: $upcomingHearings)';
}


}

/// @nodoc
abstract mixin class _$DashboardMetricsCopyWith<$Res> implements $DashboardMetricsCopyWith<$Res> {
  factory _$DashboardMetricsCopyWith(_DashboardMetrics value, $Res Function(_DashboardMetrics) _then) = __$DashboardMetricsCopyWithImpl;
@override @useResult
$Res call({
 int totalActiveCases, int pendingTasks, int upcomingHearings
});




}
/// @nodoc
class __$DashboardMetricsCopyWithImpl<$Res>
    implements _$DashboardMetricsCopyWith<$Res> {
  __$DashboardMetricsCopyWithImpl(this._self, this._then);

  final _DashboardMetrics _self;
  final $Res Function(_DashboardMetrics) _then;

/// Create a copy of DashboardMetrics
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? totalActiveCases = null,Object? pendingTasks = null,Object? upcomingHearings = null,}) {
  return _then(_DashboardMetrics(
totalActiveCases: null == totalActiveCases ? _self.totalActiveCases : totalActiveCases // ignore: cast_nullable_to_non_nullable
as int,pendingTasks: null == pendingTasks ? _self.pendingTasks : pendingTasks // ignore: cast_nullable_to_non_nullable
as int,upcomingHearings: null == upcomingHearings ? _self.upcomingHearings : upcomingHearings // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
