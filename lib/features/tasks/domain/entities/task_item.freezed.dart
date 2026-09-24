// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'task_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TaskItem {

 String get id; String? get caseId;@JsonKey(name: 'case') CaseSummary? get caseSummary; String get assignedById; User? get assignedBy; String get assignedToId; User? get assignedTo; String get title; String? get description;@JsonKey(unknownEnumValue: TaskPriority.unknown) TaskPriority get priority;@JsonKey(unknownEnumValue: TaskStatus.unknown) TaskStatus get status; DateTime? get dueDate; DateTime? get completedAt; String? get linkedEntityType; String? get linkedEntityId; String? get completionNote; DateTime get createdAt; DateTime get updatedAt;
/// Create a copy of TaskItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TaskItemCopyWith<TaskItem> get copyWith => _$TaskItemCopyWithImpl<TaskItem>(this as TaskItem, _$identity);

  /// Serializes this TaskItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TaskItem&&(identical(other.id, id) || other.id == id)&&(identical(other.caseId, caseId) || other.caseId == caseId)&&(identical(other.caseSummary, caseSummary) || other.caseSummary == caseSummary)&&(identical(other.assignedById, assignedById) || other.assignedById == assignedById)&&(identical(other.assignedBy, assignedBy) || other.assignedBy == assignedBy)&&(identical(other.assignedToId, assignedToId) || other.assignedToId == assignedToId)&&(identical(other.assignedTo, assignedTo) || other.assignedTo == assignedTo)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.priority, priority) || other.priority == priority)&&(identical(other.status, status) || other.status == status)&&(identical(other.dueDate, dueDate) || other.dueDate == dueDate)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt)&&(identical(other.linkedEntityType, linkedEntityType) || other.linkedEntityType == linkedEntityType)&&(identical(other.linkedEntityId, linkedEntityId) || other.linkedEntityId == linkedEntityId)&&(identical(other.completionNote, completionNote) || other.completionNote == completionNote)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,caseId,caseSummary,assignedById,assignedBy,assignedToId,assignedTo,title,description,priority,status,dueDate,completedAt,linkedEntityType,linkedEntityId,completionNote,createdAt,updatedAt);

@override
String toString() {
  return 'TaskItem(id: $id, caseId: $caseId, caseSummary: $caseSummary, assignedById: $assignedById, assignedBy: $assignedBy, assignedToId: $assignedToId, assignedTo: $assignedTo, title: $title, description: $description, priority: $priority, status: $status, dueDate: $dueDate, completedAt: $completedAt, linkedEntityType: $linkedEntityType, linkedEntityId: $linkedEntityId, completionNote: $completionNote, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $TaskItemCopyWith<$Res>  {
  factory $TaskItemCopyWith(TaskItem value, $Res Function(TaskItem) _then) = _$TaskItemCopyWithImpl;
@useResult
$Res call({
 String id, String? caseId,@JsonKey(name: 'case') CaseSummary? caseSummary, String assignedById, User? assignedBy, String assignedToId, User? assignedTo, String title, String? description,@JsonKey(unknownEnumValue: TaskPriority.unknown) TaskPriority priority,@JsonKey(unknownEnumValue: TaskStatus.unknown) TaskStatus status, DateTime? dueDate, DateTime? completedAt, String? linkedEntityType, String? linkedEntityId, String? completionNote, DateTime createdAt, DateTime updatedAt
});


$CaseSummaryCopyWith<$Res>? get caseSummary;$UserCopyWith<$Res>? get assignedBy;$UserCopyWith<$Res>? get assignedTo;

}
/// @nodoc
class _$TaskItemCopyWithImpl<$Res>
    implements $TaskItemCopyWith<$Res> {
  _$TaskItemCopyWithImpl(this._self, this._then);

  final TaskItem _self;
  final $Res Function(TaskItem) _then;

/// Create a copy of TaskItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? caseId = freezed,Object? caseSummary = freezed,Object? assignedById = null,Object? assignedBy = freezed,Object? assignedToId = null,Object? assignedTo = freezed,Object? title = null,Object? description = freezed,Object? priority = null,Object? status = null,Object? dueDate = freezed,Object? completedAt = freezed,Object? linkedEntityType = freezed,Object? linkedEntityId = freezed,Object? completionNote = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,caseId: freezed == caseId ? _self.caseId : caseId // ignore: cast_nullable_to_non_nullable
as String?,caseSummary: freezed == caseSummary ? _self.caseSummary : caseSummary // ignore: cast_nullable_to_non_nullable
as CaseSummary?,assignedById: null == assignedById ? _self.assignedById : assignedById // ignore: cast_nullable_to_non_nullable
as String,assignedBy: freezed == assignedBy ? _self.assignedBy : assignedBy // ignore: cast_nullable_to_non_nullable
as User?,assignedToId: null == assignedToId ? _self.assignedToId : assignedToId // ignore: cast_nullable_to_non_nullable
as String,assignedTo: freezed == assignedTo ? _self.assignedTo : assignedTo // ignore: cast_nullable_to_non_nullable
as User?,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,priority: null == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as TaskPriority,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TaskStatus,dueDate: freezed == dueDate ? _self.dueDate : dueDate // ignore: cast_nullable_to_non_nullable
as DateTime?,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,linkedEntityType: freezed == linkedEntityType ? _self.linkedEntityType : linkedEntityType // ignore: cast_nullable_to_non_nullable
as String?,linkedEntityId: freezed == linkedEntityId ? _self.linkedEntityId : linkedEntityId // ignore: cast_nullable_to_non_nullable
as String?,completionNote: freezed == completionNote ? _self.completionNote : completionNote // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}
/// Create a copy of TaskItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CaseSummaryCopyWith<$Res>? get caseSummary {
    if (_self.caseSummary == null) {
    return null;
  }

  return $CaseSummaryCopyWith<$Res>(_self.caseSummary!, (value) {
    return _then(_self.copyWith(caseSummary: value));
  });
}/// Create a copy of TaskItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserCopyWith<$Res>? get assignedBy {
    if (_self.assignedBy == null) {
    return null;
  }

  return $UserCopyWith<$Res>(_self.assignedBy!, (value) {
    return _then(_self.copyWith(assignedBy: value));
  });
}/// Create a copy of TaskItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserCopyWith<$Res>? get assignedTo {
    if (_self.assignedTo == null) {
    return null;
  }

  return $UserCopyWith<$Res>(_self.assignedTo!, (value) {
    return _then(_self.copyWith(assignedTo: value));
  });
}
}


/// Adds pattern-matching-related methods to [TaskItem].
extension TaskItemPatterns on TaskItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TaskItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TaskItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TaskItem value)  $default,){
final _that = this;
switch (_that) {
case _TaskItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TaskItem value)?  $default,){
final _that = this;
switch (_that) {
case _TaskItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? caseId, @JsonKey(name: 'case')  CaseSummary? caseSummary,  String assignedById,  User? assignedBy,  String assignedToId,  User? assignedTo,  String title,  String? description, @JsonKey(unknownEnumValue: TaskPriority.unknown)  TaskPriority priority, @JsonKey(unknownEnumValue: TaskStatus.unknown)  TaskStatus status,  DateTime? dueDate,  DateTime? completedAt,  String? linkedEntityType,  String? linkedEntityId,  String? completionNote,  DateTime createdAt,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TaskItem() when $default != null:
return $default(_that.id,_that.caseId,_that.caseSummary,_that.assignedById,_that.assignedBy,_that.assignedToId,_that.assignedTo,_that.title,_that.description,_that.priority,_that.status,_that.dueDate,_that.completedAt,_that.linkedEntityType,_that.linkedEntityId,_that.completionNote,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? caseId, @JsonKey(name: 'case')  CaseSummary? caseSummary,  String assignedById,  User? assignedBy,  String assignedToId,  User? assignedTo,  String title,  String? description, @JsonKey(unknownEnumValue: TaskPriority.unknown)  TaskPriority priority, @JsonKey(unknownEnumValue: TaskStatus.unknown)  TaskStatus status,  DateTime? dueDate,  DateTime? completedAt,  String? linkedEntityType,  String? linkedEntityId,  String? completionNote,  DateTime createdAt,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _TaskItem():
return $default(_that.id,_that.caseId,_that.caseSummary,_that.assignedById,_that.assignedBy,_that.assignedToId,_that.assignedTo,_that.title,_that.description,_that.priority,_that.status,_that.dueDate,_that.completedAt,_that.linkedEntityType,_that.linkedEntityId,_that.completionNote,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? caseId, @JsonKey(name: 'case')  CaseSummary? caseSummary,  String assignedById,  User? assignedBy,  String assignedToId,  User? assignedTo,  String title,  String? description, @JsonKey(unknownEnumValue: TaskPriority.unknown)  TaskPriority priority, @JsonKey(unknownEnumValue: TaskStatus.unknown)  TaskStatus status,  DateTime? dueDate,  DateTime? completedAt,  String? linkedEntityType,  String? linkedEntityId,  String? completionNote,  DateTime createdAt,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _TaskItem() when $default != null:
return $default(_that.id,_that.caseId,_that.caseSummary,_that.assignedById,_that.assignedBy,_that.assignedToId,_that.assignedTo,_that.title,_that.description,_that.priority,_that.status,_that.dueDate,_that.completedAt,_that.linkedEntityType,_that.linkedEntityId,_that.completionNote,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TaskItem implements TaskItem {
  const _TaskItem({required this.id, this.caseId, @JsonKey(name: 'case') this.caseSummary, required this.assignedById, this.assignedBy, required this.assignedToId, this.assignedTo, required this.title, this.description, @JsonKey(unknownEnumValue: TaskPriority.unknown) required this.priority, @JsonKey(unknownEnumValue: TaskStatus.unknown) required this.status, this.dueDate, this.completedAt, this.linkedEntityType, this.linkedEntityId, this.completionNote, required this.createdAt, required this.updatedAt});
  factory _TaskItem.fromJson(Map<String, dynamic> json) => _$TaskItemFromJson(json);

@override final  String id;
@override final  String? caseId;
@override@JsonKey(name: 'case') final  CaseSummary? caseSummary;
@override final  String assignedById;
@override final  User? assignedBy;
@override final  String assignedToId;
@override final  User? assignedTo;
@override final  String title;
@override final  String? description;
@override@JsonKey(unknownEnumValue: TaskPriority.unknown) final  TaskPriority priority;
@override@JsonKey(unknownEnumValue: TaskStatus.unknown) final  TaskStatus status;
@override final  DateTime? dueDate;
@override final  DateTime? completedAt;
@override final  String? linkedEntityType;
@override final  String? linkedEntityId;
@override final  String? completionNote;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;

/// Create a copy of TaskItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TaskItemCopyWith<_TaskItem> get copyWith => __$TaskItemCopyWithImpl<_TaskItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TaskItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TaskItem&&(identical(other.id, id) || other.id == id)&&(identical(other.caseId, caseId) || other.caseId == caseId)&&(identical(other.caseSummary, caseSummary) || other.caseSummary == caseSummary)&&(identical(other.assignedById, assignedById) || other.assignedById == assignedById)&&(identical(other.assignedBy, assignedBy) || other.assignedBy == assignedBy)&&(identical(other.assignedToId, assignedToId) || other.assignedToId == assignedToId)&&(identical(other.assignedTo, assignedTo) || other.assignedTo == assignedTo)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.priority, priority) || other.priority == priority)&&(identical(other.status, status) || other.status == status)&&(identical(other.dueDate, dueDate) || other.dueDate == dueDate)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt)&&(identical(other.linkedEntityType, linkedEntityType) || other.linkedEntityType == linkedEntityType)&&(identical(other.linkedEntityId, linkedEntityId) || other.linkedEntityId == linkedEntityId)&&(identical(other.completionNote, completionNote) || other.completionNote == completionNote)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,caseId,caseSummary,assignedById,assignedBy,assignedToId,assignedTo,title,description,priority,status,dueDate,completedAt,linkedEntityType,linkedEntityId,completionNote,createdAt,updatedAt);

@override
String toString() {
  return 'TaskItem(id: $id, caseId: $caseId, caseSummary: $caseSummary, assignedById: $assignedById, assignedBy: $assignedBy, assignedToId: $assignedToId, assignedTo: $assignedTo, title: $title, description: $description, priority: $priority, status: $status, dueDate: $dueDate, completedAt: $completedAt, linkedEntityType: $linkedEntityType, linkedEntityId: $linkedEntityId, completionNote: $completionNote, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$TaskItemCopyWith<$Res> implements $TaskItemCopyWith<$Res> {
  factory _$TaskItemCopyWith(_TaskItem value, $Res Function(_TaskItem) _then) = __$TaskItemCopyWithImpl;
@override @useResult
$Res call({
 String id, String? caseId,@JsonKey(name: 'case') CaseSummary? caseSummary, String assignedById, User? assignedBy, String assignedToId, User? assignedTo, String title, String? description,@JsonKey(unknownEnumValue: TaskPriority.unknown) TaskPriority priority,@JsonKey(unknownEnumValue: TaskStatus.unknown) TaskStatus status, DateTime? dueDate, DateTime? completedAt, String? linkedEntityType, String? linkedEntityId, String? completionNote, DateTime createdAt, DateTime updatedAt
});


@override $CaseSummaryCopyWith<$Res>? get caseSummary;@override $UserCopyWith<$Res>? get assignedBy;@override $UserCopyWith<$Res>? get assignedTo;

}
/// @nodoc
class __$TaskItemCopyWithImpl<$Res>
    implements _$TaskItemCopyWith<$Res> {
  __$TaskItemCopyWithImpl(this._self, this._then);

  final _TaskItem _self;
  final $Res Function(_TaskItem) _then;

/// Create a copy of TaskItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? caseId = freezed,Object? caseSummary = freezed,Object? assignedById = null,Object? assignedBy = freezed,Object? assignedToId = null,Object? assignedTo = freezed,Object? title = null,Object? description = freezed,Object? priority = null,Object? status = null,Object? dueDate = freezed,Object? completedAt = freezed,Object? linkedEntityType = freezed,Object? linkedEntityId = freezed,Object? completionNote = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_TaskItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,caseId: freezed == caseId ? _self.caseId : caseId // ignore: cast_nullable_to_non_nullable
as String?,caseSummary: freezed == caseSummary ? _self.caseSummary : caseSummary // ignore: cast_nullable_to_non_nullable
as CaseSummary?,assignedById: null == assignedById ? _self.assignedById : assignedById // ignore: cast_nullable_to_non_nullable
as String,assignedBy: freezed == assignedBy ? _self.assignedBy : assignedBy // ignore: cast_nullable_to_non_nullable
as User?,assignedToId: null == assignedToId ? _self.assignedToId : assignedToId // ignore: cast_nullable_to_non_nullable
as String,assignedTo: freezed == assignedTo ? _self.assignedTo : assignedTo // ignore: cast_nullable_to_non_nullable
as User?,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,priority: null == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as TaskPriority,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TaskStatus,dueDate: freezed == dueDate ? _self.dueDate : dueDate // ignore: cast_nullable_to_non_nullable
as DateTime?,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,linkedEntityType: freezed == linkedEntityType ? _self.linkedEntityType : linkedEntityType // ignore: cast_nullable_to_non_nullable
as String?,linkedEntityId: freezed == linkedEntityId ? _self.linkedEntityId : linkedEntityId // ignore: cast_nullable_to_non_nullable
as String?,completionNote: freezed == completionNote ? _self.completionNote : completionNote // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

/// Create a copy of TaskItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CaseSummaryCopyWith<$Res>? get caseSummary {
    if (_self.caseSummary == null) {
    return null;
  }

  return $CaseSummaryCopyWith<$Res>(_self.caseSummary!, (value) {
    return _then(_self.copyWith(caseSummary: value));
  });
}/// Create a copy of TaskItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserCopyWith<$Res>? get assignedBy {
    if (_self.assignedBy == null) {
    return null;
  }

  return $UserCopyWith<$Res>(_self.assignedBy!, (value) {
    return _then(_self.copyWith(assignedBy: value));
  });
}/// Create a copy of TaskItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserCopyWith<$Res>? get assignedTo {
    if (_self.assignedTo == null) {
    return null;
  }

  return $UserCopyWith<$Res>(_self.assignedTo!, (value) {
    return _then(_self.copyWith(assignedTo: value));
  });
}
}

// dart format on
