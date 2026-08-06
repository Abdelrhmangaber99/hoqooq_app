// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'financial_analytics.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$FinancialAnalytics {

 double get totalInvoiced; double get totalPaid; double get totalOutstanding; double get collectionRatePercentage; int get totalInvoicesCount; int get paidInvoicesCount; int get partialInvoicesCount; int get unpaidInvoicesCount; double get grossRevenue; double get netProfitEstimate;
/// Create a copy of FinancialAnalytics
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FinancialAnalyticsCopyWith<FinancialAnalytics> get copyWith => _$FinancialAnalyticsCopyWithImpl<FinancialAnalytics>(this as FinancialAnalytics, _$identity);

  /// Serializes this FinancialAnalytics to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FinancialAnalytics&&(identical(other.totalInvoiced, totalInvoiced) || other.totalInvoiced == totalInvoiced)&&(identical(other.totalPaid, totalPaid) || other.totalPaid == totalPaid)&&(identical(other.totalOutstanding, totalOutstanding) || other.totalOutstanding == totalOutstanding)&&(identical(other.collectionRatePercentage, collectionRatePercentage) || other.collectionRatePercentage == collectionRatePercentage)&&(identical(other.totalInvoicesCount, totalInvoicesCount) || other.totalInvoicesCount == totalInvoicesCount)&&(identical(other.paidInvoicesCount, paidInvoicesCount) || other.paidInvoicesCount == paidInvoicesCount)&&(identical(other.partialInvoicesCount, partialInvoicesCount) || other.partialInvoicesCount == partialInvoicesCount)&&(identical(other.unpaidInvoicesCount, unpaidInvoicesCount) || other.unpaidInvoicesCount == unpaidInvoicesCount)&&(identical(other.grossRevenue, grossRevenue) || other.grossRevenue == grossRevenue)&&(identical(other.netProfitEstimate, netProfitEstimate) || other.netProfitEstimate == netProfitEstimate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalInvoiced,totalPaid,totalOutstanding,collectionRatePercentage,totalInvoicesCount,paidInvoicesCount,partialInvoicesCount,unpaidInvoicesCount,grossRevenue,netProfitEstimate);

@override
String toString() {
  return 'FinancialAnalytics(totalInvoiced: $totalInvoiced, totalPaid: $totalPaid, totalOutstanding: $totalOutstanding, collectionRatePercentage: $collectionRatePercentage, totalInvoicesCount: $totalInvoicesCount, paidInvoicesCount: $paidInvoicesCount, partialInvoicesCount: $partialInvoicesCount, unpaidInvoicesCount: $unpaidInvoicesCount, grossRevenue: $grossRevenue, netProfitEstimate: $netProfitEstimate)';
}


}

/// @nodoc
abstract mixin class $FinancialAnalyticsCopyWith<$Res>  {
  factory $FinancialAnalyticsCopyWith(FinancialAnalytics value, $Res Function(FinancialAnalytics) _then) = _$FinancialAnalyticsCopyWithImpl;
@useResult
$Res call({
 double totalInvoiced, double totalPaid, double totalOutstanding, double collectionRatePercentage, int totalInvoicesCount, int paidInvoicesCount, int partialInvoicesCount, int unpaidInvoicesCount, double grossRevenue, double netProfitEstimate
});




}
/// @nodoc
class _$FinancialAnalyticsCopyWithImpl<$Res>
    implements $FinancialAnalyticsCopyWith<$Res> {
  _$FinancialAnalyticsCopyWithImpl(this._self, this._then);

  final FinancialAnalytics _self;
  final $Res Function(FinancialAnalytics) _then;

/// Create a copy of FinancialAnalytics
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? totalInvoiced = null,Object? totalPaid = null,Object? totalOutstanding = null,Object? collectionRatePercentage = null,Object? totalInvoicesCount = null,Object? paidInvoicesCount = null,Object? partialInvoicesCount = null,Object? unpaidInvoicesCount = null,Object? grossRevenue = null,Object? netProfitEstimate = null,}) {
  return _then(_self.copyWith(
totalInvoiced: null == totalInvoiced ? _self.totalInvoiced : totalInvoiced // ignore: cast_nullable_to_non_nullable
as double,totalPaid: null == totalPaid ? _self.totalPaid : totalPaid // ignore: cast_nullable_to_non_nullable
as double,totalOutstanding: null == totalOutstanding ? _self.totalOutstanding : totalOutstanding // ignore: cast_nullable_to_non_nullable
as double,collectionRatePercentage: null == collectionRatePercentage ? _self.collectionRatePercentage : collectionRatePercentage // ignore: cast_nullable_to_non_nullable
as double,totalInvoicesCount: null == totalInvoicesCount ? _self.totalInvoicesCount : totalInvoicesCount // ignore: cast_nullable_to_non_nullable
as int,paidInvoicesCount: null == paidInvoicesCount ? _self.paidInvoicesCount : paidInvoicesCount // ignore: cast_nullable_to_non_nullable
as int,partialInvoicesCount: null == partialInvoicesCount ? _self.partialInvoicesCount : partialInvoicesCount // ignore: cast_nullable_to_non_nullable
as int,unpaidInvoicesCount: null == unpaidInvoicesCount ? _self.unpaidInvoicesCount : unpaidInvoicesCount // ignore: cast_nullable_to_non_nullable
as int,grossRevenue: null == grossRevenue ? _self.grossRevenue : grossRevenue // ignore: cast_nullable_to_non_nullable
as double,netProfitEstimate: null == netProfitEstimate ? _self.netProfitEstimate : netProfitEstimate // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [FinancialAnalytics].
extension FinancialAnalyticsPatterns on FinancialAnalytics {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FinancialAnalytics value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FinancialAnalytics() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FinancialAnalytics value)  $default,){
final _that = this;
switch (_that) {
case _FinancialAnalytics():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FinancialAnalytics value)?  $default,){
final _that = this;
switch (_that) {
case _FinancialAnalytics() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double totalInvoiced,  double totalPaid,  double totalOutstanding,  double collectionRatePercentage,  int totalInvoicesCount,  int paidInvoicesCount,  int partialInvoicesCount,  int unpaidInvoicesCount,  double grossRevenue,  double netProfitEstimate)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FinancialAnalytics() when $default != null:
return $default(_that.totalInvoiced,_that.totalPaid,_that.totalOutstanding,_that.collectionRatePercentage,_that.totalInvoicesCount,_that.paidInvoicesCount,_that.partialInvoicesCount,_that.unpaidInvoicesCount,_that.grossRevenue,_that.netProfitEstimate);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double totalInvoiced,  double totalPaid,  double totalOutstanding,  double collectionRatePercentage,  int totalInvoicesCount,  int paidInvoicesCount,  int partialInvoicesCount,  int unpaidInvoicesCount,  double grossRevenue,  double netProfitEstimate)  $default,) {final _that = this;
switch (_that) {
case _FinancialAnalytics():
return $default(_that.totalInvoiced,_that.totalPaid,_that.totalOutstanding,_that.collectionRatePercentage,_that.totalInvoicesCount,_that.paidInvoicesCount,_that.partialInvoicesCount,_that.unpaidInvoicesCount,_that.grossRevenue,_that.netProfitEstimate);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double totalInvoiced,  double totalPaid,  double totalOutstanding,  double collectionRatePercentage,  int totalInvoicesCount,  int paidInvoicesCount,  int partialInvoicesCount,  int unpaidInvoicesCount,  double grossRevenue,  double netProfitEstimate)?  $default,) {final _that = this;
switch (_that) {
case _FinancialAnalytics() when $default != null:
return $default(_that.totalInvoiced,_that.totalPaid,_that.totalOutstanding,_that.collectionRatePercentage,_that.totalInvoicesCount,_that.paidInvoicesCount,_that.partialInvoicesCount,_that.unpaidInvoicesCount,_that.grossRevenue,_that.netProfitEstimate);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FinancialAnalytics implements FinancialAnalytics {
  const _FinancialAnalytics({required this.totalInvoiced, required this.totalPaid, required this.totalOutstanding, required this.collectionRatePercentage, required this.totalInvoicesCount, required this.paidInvoicesCount, required this.partialInvoicesCount, required this.unpaidInvoicesCount, required this.grossRevenue, required this.netProfitEstimate});
  factory _FinancialAnalytics.fromJson(Map<String, dynamic> json) => _$FinancialAnalyticsFromJson(json);

@override final  double totalInvoiced;
@override final  double totalPaid;
@override final  double totalOutstanding;
@override final  double collectionRatePercentage;
@override final  int totalInvoicesCount;
@override final  int paidInvoicesCount;
@override final  int partialInvoicesCount;
@override final  int unpaidInvoicesCount;
@override final  double grossRevenue;
@override final  double netProfitEstimate;

/// Create a copy of FinancialAnalytics
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FinancialAnalyticsCopyWith<_FinancialAnalytics> get copyWith => __$FinancialAnalyticsCopyWithImpl<_FinancialAnalytics>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FinancialAnalyticsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FinancialAnalytics&&(identical(other.totalInvoiced, totalInvoiced) || other.totalInvoiced == totalInvoiced)&&(identical(other.totalPaid, totalPaid) || other.totalPaid == totalPaid)&&(identical(other.totalOutstanding, totalOutstanding) || other.totalOutstanding == totalOutstanding)&&(identical(other.collectionRatePercentage, collectionRatePercentage) || other.collectionRatePercentage == collectionRatePercentage)&&(identical(other.totalInvoicesCount, totalInvoicesCount) || other.totalInvoicesCount == totalInvoicesCount)&&(identical(other.paidInvoicesCount, paidInvoicesCount) || other.paidInvoicesCount == paidInvoicesCount)&&(identical(other.partialInvoicesCount, partialInvoicesCount) || other.partialInvoicesCount == partialInvoicesCount)&&(identical(other.unpaidInvoicesCount, unpaidInvoicesCount) || other.unpaidInvoicesCount == unpaidInvoicesCount)&&(identical(other.grossRevenue, grossRevenue) || other.grossRevenue == grossRevenue)&&(identical(other.netProfitEstimate, netProfitEstimate) || other.netProfitEstimate == netProfitEstimate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalInvoiced,totalPaid,totalOutstanding,collectionRatePercentage,totalInvoicesCount,paidInvoicesCount,partialInvoicesCount,unpaidInvoicesCount,grossRevenue,netProfitEstimate);

@override
String toString() {
  return 'FinancialAnalytics(totalInvoiced: $totalInvoiced, totalPaid: $totalPaid, totalOutstanding: $totalOutstanding, collectionRatePercentage: $collectionRatePercentage, totalInvoicesCount: $totalInvoicesCount, paidInvoicesCount: $paidInvoicesCount, partialInvoicesCount: $partialInvoicesCount, unpaidInvoicesCount: $unpaidInvoicesCount, grossRevenue: $grossRevenue, netProfitEstimate: $netProfitEstimate)';
}


}

/// @nodoc
abstract mixin class _$FinancialAnalyticsCopyWith<$Res> implements $FinancialAnalyticsCopyWith<$Res> {
  factory _$FinancialAnalyticsCopyWith(_FinancialAnalytics value, $Res Function(_FinancialAnalytics) _then) = __$FinancialAnalyticsCopyWithImpl;
@override @useResult
$Res call({
 double totalInvoiced, double totalPaid, double totalOutstanding, double collectionRatePercentage, int totalInvoicesCount, int paidInvoicesCount, int partialInvoicesCount, int unpaidInvoicesCount, double grossRevenue, double netProfitEstimate
});




}
/// @nodoc
class __$FinancialAnalyticsCopyWithImpl<$Res>
    implements _$FinancialAnalyticsCopyWith<$Res> {
  __$FinancialAnalyticsCopyWithImpl(this._self, this._then);

  final _FinancialAnalytics _self;
  final $Res Function(_FinancialAnalytics) _then;

/// Create a copy of FinancialAnalytics
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? totalInvoiced = null,Object? totalPaid = null,Object? totalOutstanding = null,Object? collectionRatePercentage = null,Object? totalInvoicesCount = null,Object? paidInvoicesCount = null,Object? partialInvoicesCount = null,Object? unpaidInvoicesCount = null,Object? grossRevenue = null,Object? netProfitEstimate = null,}) {
  return _then(_FinancialAnalytics(
totalInvoiced: null == totalInvoiced ? _self.totalInvoiced : totalInvoiced // ignore: cast_nullable_to_non_nullable
as double,totalPaid: null == totalPaid ? _self.totalPaid : totalPaid // ignore: cast_nullable_to_non_nullable
as double,totalOutstanding: null == totalOutstanding ? _self.totalOutstanding : totalOutstanding // ignore: cast_nullable_to_non_nullable
as double,collectionRatePercentage: null == collectionRatePercentage ? _self.collectionRatePercentage : collectionRatePercentage // ignore: cast_nullable_to_non_nullable
as double,totalInvoicesCount: null == totalInvoicesCount ? _self.totalInvoicesCount : totalInvoicesCount // ignore: cast_nullable_to_non_nullable
as int,paidInvoicesCount: null == paidInvoicesCount ? _self.paidInvoicesCount : paidInvoicesCount // ignore: cast_nullable_to_non_nullable
as int,partialInvoicesCount: null == partialInvoicesCount ? _self.partialInvoicesCount : partialInvoicesCount // ignore: cast_nullable_to_non_nullable
as int,unpaidInvoicesCount: null == unpaidInvoicesCount ? _self.unpaidInvoicesCount : unpaidInvoicesCount // ignore: cast_nullable_to_non_nullable
as int,grossRevenue: null == grossRevenue ? _self.grossRevenue : grossRevenue // ignore: cast_nullable_to_non_nullable
as double,netProfitEstimate: null == netProfitEstimate ? _self.netProfitEstimate : netProfitEstimate // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
