// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'create_event_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CreateEventRequest {

 String get userId; String get title; String? get description; CalendarEventType get eventType; DateTime get startsAt; DateTime? get endsAt; String? get location; bool? get isAllDay;
/// Create a copy of CreateEventRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreateEventRequestCopyWith<CreateEventRequest> get copyWith => _$CreateEventRequestCopyWithImpl<CreateEventRequest>(this as CreateEventRequest, _$identity);

  /// Serializes this CreateEventRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateEventRequest&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.eventType, eventType) || other.eventType == eventType)&&(identical(other.startsAt, startsAt) || other.startsAt == startsAt)&&(identical(other.endsAt, endsAt) || other.endsAt == endsAt)&&(identical(other.location, location) || other.location == location)&&(identical(other.isAllDay, isAllDay) || other.isAllDay == isAllDay));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,title,description,eventType,startsAt,endsAt,location,isAllDay);

@override
String toString() {
  return 'CreateEventRequest(userId: $userId, title: $title, description: $description, eventType: $eventType, startsAt: $startsAt, endsAt: $endsAt, location: $location, isAllDay: $isAllDay)';
}


}

/// @nodoc
abstract mixin class $CreateEventRequestCopyWith<$Res>  {
  factory $CreateEventRequestCopyWith(CreateEventRequest value, $Res Function(CreateEventRequest) _then) = _$CreateEventRequestCopyWithImpl;
@useResult
$Res call({
 String userId, String title, String? description, CalendarEventType eventType, DateTime startsAt, DateTime? endsAt, String? location, bool? isAllDay
});




}
/// @nodoc
class _$CreateEventRequestCopyWithImpl<$Res>
    implements $CreateEventRequestCopyWith<$Res> {
  _$CreateEventRequestCopyWithImpl(this._self, this._then);

  final CreateEventRequest _self;
  final $Res Function(CreateEventRequest) _then;

/// Create a copy of CreateEventRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userId = null,Object? title = null,Object? description = freezed,Object? eventType = null,Object? startsAt = null,Object? endsAt = freezed,Object? location = freezed,Object? isAllDay = freezed,}) {
  return _then(_self.copyWith(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,eventType: null == eventType ? _self.eventType : eventType // ignore: cast_nullable_to_non_nullable
as CalendarEventType,startsAt: null == startsAt ? _self.startsAt : startsAt // ignore: cast_nullable_to_non_nullable
as DateTime,endsAt: freezed == endsAt ? _self.endsAt : endsAt // ignore: cast_nullable_to_non_nullable
as DateTime?,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String?,isAllDay: freezed == isAllDay ? _self.isAllDay : isAllDay // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}

}


/// Adds pattern-matching-related methods to [CreateEventRequest].
extension CreateEventRequestPatterns on CreateEventRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreateEventRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreateEventRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreateEventRequest value)  $default,){
final _that = this;
switch (_that) {
case _CreateEventRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreateEventRequest value)?  $default,){
final _that = this;
switch (_that) {
case _CreateEventRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String userId,  String title,  String? description,  CalendarEventType eventType,  DateTime startsAt,  DateTime? endsAt,  String? location,  bool? isAllDay)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreateEventRequest() when $default != null:
return $default(_that.userId,_that.title,_that.description,_that.eventType,_that.startsAt,_that.endsAt,_that.location,_that.isAllDay);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String userId,  String title,  String? description,  CalendarEventType eventType,  DateTime startsAt,  DateTime? endsAt,  String? location,  bool? isAllDay)  $default,) {final _that = this;
switch (_that) {
case _CreateEventRequest():
return $default(_that.userId,_that.title,_that.description,_that.eventType,_that.startsAt,_that.endsAt,_that.location,_that.isAllDay);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String userId,  String title,  String? description,  CalendarEventType eventType,  DateTime startsAt,  DateTime? endsAt,  String? location,  bool? isAllDay)?  $default,) {final _that = this;
switch (_that) {
case _CreateEventRequest() when $default != null:
return $default(_that.userId,_that.title,_that.description,_that.eventType,_that.startsAt,_that.endsAt,_that.location,_that.isAllDay);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CreateEventRequest implements CreateEventRequest {
  const _CreateEventRequest({required this.userId, required this.title, this.description, this.eventType = CalendarEventType.custom, required this.startsAt, this.endsAt, this.location, this.isAllDay});
  factory _CreateEventRequest.fromJson(Map<String, dynamic> json) => _$CreateEventRequestFromJson(json);

@override final  String userId;
@override final  String title;
@override final  String? description;
@override@JsonKey() final  CalendarEventType eventType;
@override final  DateTime startsAt;
@override final  DateTime? endsAt;
@override final  String? location;
@override final  bool? isAllDay;

/// Create a copy of CreateEventRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreateEventRequestCopyWith<_CreateEventRequest> get copyWith => __$CreateEventRequestCopyWithImpl<_CreateEventRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CreateEventRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreateEventRequest&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.eventType, eventType) || other.eventType == eventType)&&(identical(other.startsAt, startsAt) || other.startsAt == startsAt)&&(identical(other.endsAt, endsAt) || other.endsAt == endsAt)&&(identical(other.location, location) || other.location == location)&&(identical(other.isAllDay, isAllDay) || other.isAllDay == isAllDay));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,title,description,eventType,startsAt,endsAt,location,isAllDay);

@override
String toString() {
  return 'CreateEventRequest(userId: $userId, title: $title, description: $description, eventType: $eventType, startsAt: $startsAt, endsAt: $endsAt, location: $location, isAllDay: $isAllDay)';
}


}

/// @nodoc
abstract mixin class _$CreateEventRequestCopyWith<$Res> implements $CreateEventRequestCopyWith<$Res> {
  factory _$CreateEventRequestCopyWith(_CreateEventRequest value, $Res Function(_CreateEventRequest) _then) = __$CreateEventRequestCopyWithImpl;
@override @useResult
$Res call({
 String userId, String title, String? description, CalendarEventType eventType, DateTime startsAt, DateTime? endsAt, String? location, bool? isAllDay
});




}
/// @nodoc
class __$CreateEventRequestCopyWithImpl<$Res>
    implements _$CreateEventRequestCopyWith<$Res> {
  __$CreateEventRequestCopyWithImpl(this._self, this._then);

  final _CreateEventRequest _self;
  final $Res Function(_CreateEventRequest) _then;

/// Create a copy of CreateEventRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userId = null,Object? title = null,Object? description = freezed,Object? eventType = null,Object? startsAt = null,Object? endsAt = freezed,Object? location = freezed,Object? isAllDay = freezed,}) {
  return _then(_CreateEventRequest(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,eventType: null == eventType ? _self.eventType : eventType // ignore: cast_nullable_to_non_nullable
as CalendarEventType,startsAt: null == startsAt ? _self.startsAt : startsAt // ignore: cast_nullable_to_non_nullable
as DateTime,endsAt: freezed == endsAt ? _self.endsAt : endsAt // ignore: cast_nullable_to_non_nullable
as DateTime?,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String?,isAllDay: freezed == isAllDay ? _self.isAllDay : isAllDay // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}


}

// dart format on
