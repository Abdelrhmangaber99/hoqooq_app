// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'create_task_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CreateTaskRequest {

 String get caseId; String get assignedToId; String get title; String? get description; TaskPriority? get priority; TaskStatus? get status; DateTime? get dueDate; String? get linkedEntityType; String? get linkedEntityId;
/// Create a copy of CreateTaskRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreateTaskRequestCopyWith<CreateTaskRequest> get copyWith => _$CreateTaskRequestCopyWithImpl<CreateTaskRequest>(this as CreateTaskRequest, _$identity);

  /// Serializes this CreateTaskRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateTaskRequest&&(identical(other.caseId, caseId) || other.caseId == caseId)&&(identical(other.assignedToId, assignedToId) || other.assignedToId == assignedToId)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.priority, priority) || other.priority == priority)&&(identical(other.status, status) || other.status == status)&&(identical(other.dueDate, dueDate) || other.dueDate == dueDate)&&(identical(other.linkedEntityType, linkedEntityType) || other.linkedEntityType == linkedEntityType)&&(identical(other.linkedEntityId, linkedEntityId) || other.linkedEntityId == linkedEntityId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,caseId,assignedToId,title,description,priority,status,dueDate,linkedEntityType,linkedEntityId);

@override
String toString() {
  return 'CreateTaskRequest(caseId: $caseId, assignedToId: $assignedToId, title: $title, description: $description, priority: $priority, status: $status, dueDate: $dueDate, linkedEntityType: $linkedEntityType, linkedEntityId: $linkedEntityId)';
}


}

/// @nodoc
abstract mixin class $CreateTaskRequestCopyWith<$Res>  {
  factory $CreateTaskRequestCopyWith(CreateTaskRequest value, $Res Function(CreateTaskRequest) _then) = _$CreateTaskRequestCopyWithImpl;
@useResult
$Res call({
 String caseId, String assignedToId, String title, String? description, TaskPriority? priority, TaskStatus? status, DateTime? dueDate, String? linkedEntityType, String? linkedEntityId
});




}
/// @nodoc
class _$CreateTaskRequestCopyWithImpl<$Res>
    implements $CreateTaskRequestCopyWith<$Res> {
  _$CreateTaskRequestCopyWithImpl(this._self, this._then);

  final CreateTaskRequest _self;
  final $Res Function(CreateTaskRequest) _then;

/// Create a copy of CreateTaskRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? caseId = null,Object? assignedToId = null,Object? title = null,Object? description = freezed,Object? priority = freezed,Object? status = freezed,Object? dueDate = freezed,Object? linkedEntityType = freezed,Object? linkedEntityId = freezed,}) {
  return _then(_self.copyWith(
caseId: null == caseId ? _self.caseId : caseId // ignore: cast_nullable_to_non_nullable
as String,assignedToId: null == assignedToId ? _self.assignedToId : assignedToId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,priority: freezed == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as TaskPriority?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TaskStatus?,dueDate: freezed == dueDate ? _self.dueDate : dueDate // ignore: cast_nullable_to_non_nullable
as DateTime?,linkedEntityType: freezed == linkedEntityType ? _self.linkedEntityType : linkedEntityType // ignore: cast_nullable_to_non_nullable
as String?,linkedEntityId: freezed == linkedEntityId ? _self.linkedEntityId : linkedEntityId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CreateTaskRequest].
extension CreateTaskRequestPatterns on CreateTaskRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreateTaskRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreateTaskRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreateTaskRequest value)  $default,){
final _that = this;
switch (_that) {
case _CreateTaskRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreateTaskRequest value)?  $default,){
final _that = this;
switch (_that) {
case _CreateTaskRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String caseId,  String assignedToId,  String title,  String? description,  TaskPriority? priority,  TaskStatus? status,  DateTime? dueDate,  String? linkedEntityType,  String? linkedEntityId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreateTaskRequest() when $default != null:
return $default(_that.caseId,_that.assignedToId,_that.title,_that.description,_that.priority,_that.status,_that.dueDate,_that.linkedEntityType,_that.linkedEntityId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String caseId,  String assignedToId,  String title,  String? description,  TaskPriority? priority,  TaskStatus? status,  DateTime? dueDate,  String? linkedEntityType,  String? linkedEntityId)  $default,) {final _that = this;
switch (_that) {
case _CreateTaskRequest():
return $default(_that.caseId,_that.assignedToId,_that.title,_that.description,_that.priority,_that.status,_that.dueDate,_that.linkedEntityType,_that.linkedEntityId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String caseId,  String assignedToId,  String title,  String? description,  TaskPriority? priority,  TaskStatus? status,  DateTime? dueDate,  String? linkedEntityType,  String? linkedEntityId)?  $default,) {final _that = this;
switch (_that) {
case _CreateTaskRequest() when $default != null:
return $default(_that.caseId,_that.assignedToId,_that.title,_that.description,_that.priority,_that.status,_that.dueDate,_that.linkedEntityType,_that.linkedEntityId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CreateTaskRequest implements CreateTaskRequest {
  const _CreateTaskRequest({required this.caseId, required this.assignedToId, required this.title, this.description, this.priority, this.status, this.dueDate, this.linkedEntityType, this.linkedEntityId});
  factory _CreateTaskRequest.fromJson(Map<String, dynamic> json) => _$CreateTaskRequestFromJson(json);

@override final  String caseId;
@override final  String assignedToId;
@override final  String title;
@override final  String? description;
@override final  TaskPriority? priority;
@override final  TaskStatus? status;
@override final  DateTime? dueDate;
@override final  String? linkedEntityType;
@override final  String? linkedEntityId;

/// Create a copy of CreateTaskRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreateTaskRequestCopyWith<_CreateTaskRequest> get copyWith => __$CreateTaskRequestCopyWithImpl<_CreateTaskRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CreateTaskRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreateTaskRequest&&(identical(other.caseId, caseId) || other.caseId == caseId)&&(identical(other.assignedToId, assignedToId) || other.assignedToId == assignedToId)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.priority, priority) || other.priority == priority)&&(identical(other.status, status) || other.status == status)&&(identical(other.dueDate, dueDate) || other.dueDate == dueDate)&&(identical(other.linkedEntityType, linkedEntityType) || other.linkedEntityType == linkedEntityType)&&(identical(other.linkedEntityId, linkedEntityId) || other.linkedEntityId == linkedEntityId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,caseId,assignedToId,title,description,priority,status,dueDate,linkedEntityType,linkedEntityId);

@override
String toString() {
  return 'CreateTaskRequest(caseId: $caseId, assignedToId: $assignedToId, title: $title, description: $description, priority: $priority, status: $status, dueDate: $dueDate, linkedEntityType: $linkedEntityType, linkedEntityId: $linkedEntityId)';
}


}

/// @nodoc
abstract mixin class _$CreateTaskRequestCopyWith<$Res> implements $CreateTaskRequestCopyWith<$Res> {
  factory _$CreateTaskRequestCopyWith(_CreateTaskRequest value, $Res Function(_CreateTaskRequest) _then) = __$CreateTaskRequestCopyWithImpl;
@override @useResult
$Res call({
 String caseId, String assignedToId, String title, String? description, TaskPriority? priority, TaskStatus? status, DateTime? dueDate, String? linkedEntityType, String? linkedEntityId
});




}
/// @nodoc
class __$CreateTaskRequestCopyWithImpl<$Res>
    implements _$CreateTaskRequestCopyWith<$Res> {
  __$CreateTaskRequestCopyWithImpl(this._self, this._then);

  final _CreateTaskRequest _self;
  final $Res Function(_CreateTaskRequest) _then;

/// Create a copy of CreateTaskRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? caseId = null,Object? assignedToId = null,Object? title = null,Object? description = freezed,Object? priority = freezed,Object? status = freezed,Object? dueDate = freezed,Object? linkedEntityType = freezed,Object? linkedEntityId = freezed,}) {
  return _then(_CreateTaskRequest(
caseId: null == caseId ? _self.caseId : caseId // ignore: cast_nullable_to_non_nullable
as String,assignedToId: null == assignedToId ? _self.assignedToId : assignedToId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,priority: freezed == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as TaskPriority?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TaskStatus?,dueDate: freezed == dueDate ? _self.dueDate : dueDate // ignore: cast_nullable_to_non_nullable
as DateTime?,linkedEntityType: freezed == linkedEntityType ? _self.linkedEntityType : linkedEntityType // ignore: cast_nullable_to_non_nullable
as String?,linkedEntityId: freezed == linkedEntityId ? _self.linkedEntityId : linkedEntityId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
