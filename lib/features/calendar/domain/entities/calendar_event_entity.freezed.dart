// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'calendar_event_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CalendarEventEntity {

 String get id; String get tenantId; String get userId; User? get user; String get title; String? get description;@JsonKey(unknownEnumValue: CalendarEventType.unknown) CalendarEventType get eventType; String? get referenceId; DateTime get startsAt; DateTime? get endsAt; String? get location; bool get isAllDay; DateTime get createdAt; DateTime get updatedAt;
/// Create a copy of CalendarEventEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CalendarEventEntityCopyWith<CalendarEventEntity> get copyWith => _$CalendarEventEntityCopyWithImpl<CalendarEventEntity>(this as CalendarEventEntity, _$identity);

  /// Serializes this CalendarEventEntity to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CalendarEventEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.tenantId, tenantId) || other.tenantId == tenantId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.user, user) || other.user == user)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.eventType, eventType) || other.eventType == eventType)&&(identical(other.referenceId, referenceId) || other.referenceId == referenceId)&&(identical(other.startsAt, startsAt) || other.startsAt == startsAt)&&(identical(other.endsAt, endsAt) || other.endsAt == endsAt)&&(identical(other.location, location) || other.location == location)&&(identical(other.isAllDay, isAllDay) || other.isAllDay == isAllDay)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,tenantId,userId,user,title,description,eventType,referenceId,startsAt,endsAt,location,isAllDay,createdAt,updatedAt);

@override
String toString() {
  return 'CalendarEventEntity(id: $id, tenantId: $tenantId, userId: $userId, user: $user, title: $title, description: $description, eventType: $eventType, referenceId: $referenceId, startsAt: $startsAt, endsAt: $endsAt, location: $location, isAllDay: $isAllDay, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $CalendarEventEntityCopyWith<$Res>  {
  factory $CalendarEventEntityCopyWith(CalendarEventEntity value, $Res Function(CalendarEventEntity) _then) = _$CalendarEventEntityCopyWithImpl;
@useResult
$Res call({
 String id, String tenantId, String userId, User? user, String title, String? description,@JsonKey(unknownEnumValue: CalendarEventType.unknown) CalendarEventType eventType, String? referenceId, DateTime startsAt, DateTime? endsAt, String? location, bool isAllDay, DateTime createdAt, DateTime updatedAt
});


$UserCopyWith<$Res>? get user;

}
/// @nodoc
class _$CalendarEventEntityCopyWithImpl<$Res>
    implements $CalendarEventEntityCopyWith<$Res> {
  _$CalendarEventEntityCopyWithImpl(this._self, this._then);

  final CalendarEventEntity _self;
  final $Res Function(CalendarEventEntity) _then;

/// Create a copy of CalendarEventEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? tenantId = null,Object? userId = null,Object? user = freezed,Object? title = null,Object? description = freezed,Object? eventType = null,Object? referenceId = freezed,Object? startsAt = null,Object? endsAt = freezed,Object? location = freezed,Object? isAllDay = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,tenantId: null == tenantId ? _self.tenantId : tenantId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,user: freezed == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as User?,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,eventType: null == eventType ? _self.eventType : eventType // ignore: cast_nullable_to_non_nullable
as CalendarEventType,referenceId: freezed == referenceId ? _self.referenceId : referenceId // ignore: cast_nullable_to_non_nullable
as String?,startsAt: null == startsAt ? _self.startsAt : startsAt // ignore: cast_nullable_to_non_nullable
as DateTime,endsAt: freezed == endsAt ? _self.endsAt : endsAt // ignore: cast_nullable_to_non_nullable
as DateTime?,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String?,isAllDay: null == isAllDay ? _self.isAllDay : isAllDay // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}
/// Create a copy of CalendarEventEntity
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserCopyWith<$Res>? get user {
    if (_self.user == null) {
    return null;
  }

  return $UserCopyWith<$Res>(_self.user!, (value) {
    return _then(_self.copyWith(user: value));
  });
}
}


/// Adds pattern-matching-related methods to [CalendarEventEntity].
extension CalendarEventEntityPatterns on CalendarEventEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CalendarEventEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CalendarEventEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CalendarEventEntity value)  $default,){
final _that = this;
switch (_that) {
case _CalendarEventEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CalendarEventEntity value)?  $default,){
final _that = this;
switch (_that) {
case _CalendarEventEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String tenantId,  String userId,  User? user,  String title,  String? description, @JsonKey(unknownEnumValue: CalendarEventType.unknown)  CalendarEventType eventType,  String? referenceId,  DateTime startsAt,  DateTime? endsAt,  String? location,  bool isAllDay,  DateTime createdAt,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CalendarEventEntity() when $default != null:
return $default(_that.id,_that.tenantId,_that.userId,_that.user,_that.title,_that.description,_that.eventType,_that.referenceId,_that.startsAt,_that.endsAt,_that.location,_that.isAllDay,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String tenantId,  String userId,  User? user,  String title,  String? description, @JsonKey(unknownEnumValue: CalendarEventType.unknown)  CalendarEventType eventType,  String? referenceId,  DateTime startsAt,  DateTime? endsAt,  String? location,  bool isAllDay,  DateTime createdAt,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _CalendarEventEntity():
return $default(_that.id,_that.tenantId,_that.userId,_that.user,_that.title,_that.description,_that.eventType,_that.referenceId,_that.startsAt,_that.endsAt,_that.location,_that.isAllDay,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String tenantId,  String userId,  User? user,  String title,  String? description, @JsonKey(unknownEnumValue: CalendarEventType.unknown)  CalendarEventType eventType,  String? referenceId,  DateTime startsAt,  DateTime? endsAt,  String? location,  bool isAllDay,  DateTime createdAt,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _CalendarEventEntity() when $default != null:
return $default(_that.id,_that.tenantId,_that.userId,_that.user,_that.title,_that.description,_that.eventType,_that.referenceId,_that.startsAt,_that.endsAt,_that.location,_that.isAllDay,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CalendarEventEntity implements CalendarEventEntity {
  const _CalendarEventEntity({required this.id, required this.tenantId, required this.userId, this.user, required this.title, this.description, @JsonKey(unknownEnumValue: CalendarEventType.unknown) required this.eventType, this.referenceId, required this.startsAt, this.endsAt, this.location, required this.isAllDay, required this.createdAt, required this.updatedAt});
  factory _CalendarEventEntity.fromJson(Map<String, dynamic> json) => _$CalendarEventEntityFromJson(json);

@override final  String id;
@override final  String tenantId;
@override final  String userId;
@override final  User? user;
@override final  String title;
@override final  String? description;
@override@JsonKey(unknownEnumValue: CalendarEventType.unknown) final  CalendarEventType eventType;
@override final  String? referenceId;
@override final  DateTime startsAt;
@override final  DateTime? endsAt;
@override final  String? location;
@override final  bool isAllDay;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;

/// Create a copy of CalendarEventEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CalendarEventEntityCopyWith<_CalendarEventEntity> get copyWith => __$CalendarEventEntityCopyWithImpl<_CalendarEventEntity>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CalendarEventEntityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CalendarEventEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.tenantId, tenantId) || other.tenantId == tenantId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.user, user) || other.user == user)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.eventType, eventType) || other.eventType == eventType)&&(identical(other.referenceId, referenceId) || other.referenceId == referenceId)&&(identical(other.startsAt, startsAt) || other.startsAt == startsAt)&&(identical(other.endsAt, endsAt) || other.endsAt == endsAt)&&(identical(other.location, location) || other.location == location)&&(identical(other.isAllDay, isAllDay) || other.isAllDay == isAllDay)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,tenantId,userId,user,title,description,eventType,referenceId,startsAt,endsAt,location,isAllDay,createdAt,updatedAt);

@override
String toString() {
  return 'CalendarEventEntity(id: $id, tenantId: $tenantId, userId: $userId, user: $user, title: $title, description: $description, eventType: $eventType, referenceId: $referenceId, startsAt: $startsAt, endsAt: $endsAt, location: $location, isAllDay: $isAllDay, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$CalendarEventEntityCopyWith<$Res> implements $CalendarEventEntityCopyWith<$Res> {
  factory _$CalendarEventEntityCopyWith(_CalendarEventEntity value, $Res Function(_CalendarEventEntity) _then) = __$CalendarEventEntityCopyWithImpl;
@override @useResult
$Res call({
 String id, String tenantId, String userId, User? user, String title, String? description,@JsonKey(unknownEnumValue: CalendarEventType.unknown) CalendarEventType eventType, String? referenceId, DateTime startsAt, DateTime? endsAt, String? location, bool isAllDay, DateTime createdAt, DateTime updatedAt
});


@override $UserCopyWith<$Res>? get user;

}
/// @nodoc
class __$CalendarEventEntityCopyWithImpl<$Res>
    implements _$CalendarEventEntityCopyWith<$Res> {
  __$CalendarEventEntityCopyWithImpl(this._self, this._then);

  final _CalendarEventEntity _self;
  final $Res Function(_CalendarEventEntity) _then;

/// Create a copy of CalendarEventEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? tenantId = null,Object? userId = null,Object? user = freezed,Object? title = null,Object? description = freezed,Object? eventType = null,Object? referenceId = freezed,Object? startsAt = null,Object? endsAt = freezed,Object? location = freezed,Object? isAllDay = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_CalendarEventEntity(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,tenantId: null == tenantId ? _self.tenantId : tenantId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,user: freezed == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as User?,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,eventType: null == eventType ? _self.eventType : eventType // ignore: cast_nullable_to_non_nullable
as CalendarEventType,referenceId: freezed == referenceId ? _self.referenceId : referenceId // ignore: cast_nullable_to_non_nullable
as String?,startsAt: null == startsAt ? _self.startsAt : startsAt // ignore: cast_nullable_to_non_nullable
as DateTime,endsAt: freezed == endsAt ? _self.endsAt : endsAt // ignore: cast_nullable_to_non_nullable
as DateTime?,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String?,isAllDay: null == isAllDay ? _self.isAllDay : isAllDay // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

/// Create a copy of CalendarEventEntity
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserCopyWith<$Res>? get user {
    if (_self.user == null) {
    return null;
  }

  return $UserCopyWith<$Res>(_self.user!, (value) {
    return _then(_self.copyWith(user: value));
  });
}
}

// dart format on
