// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'timeline_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TimelineItem {

 String get id; String? get title;
/// Create a copy of TimelineItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TimelineItemCopyWith<TimelineItem> get copyWith => _$TimelineItemCopyWithImpl<TimelineItem>(this as TimelineItem, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TimelineItem&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title));
}


@override
int get hashCode => Object.hash(runtimeType,id,title);

@override
String toString() {
  return 'TimelineItem(id: $id, title: $title)';
}


}

/// @nodoc
abstract mixin class $TimelineItemCopyWith<$Res>  {
  factory $TimelineItemCopyWith(TimelineItem value, $Res Function(TimelineItem) _then) = _$TimelineItemCopyWithImpl;
@useResult
$Res call({
 String id, String title
});




}
/// @nodoc
class _$TimelineItemCopyWithImpl<$Res>
    implements $TimelineItemCopyWith<$Res> {
  _$TimelineItemCopyWithImpl(this._self, this._then);

  final TimelineItem _self;
  final $Res Function(TimelineItem) _then;

/// Create a copy of TimelineItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title! : title // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [TimelineItem].
extension TimelineItemPatterns on TimelineItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( TimelineEventItem value)?  event,TResult Function( TimelineHearingItem value)?  hearing,TResult Function( TimelineTaskItem value)?  task,TResult Function( TimelineUnknownItem value)?  unknown,required TResult orElse(),}){
final _that = this;
switch (_that) {
case TimelineEventItem() when event != null:
return event(_that);case TimelineHearingItem() when hearing != null:
return hearing(_that);case TimelineTaskItem() when task != null:
return task(_that);case TimelineUnknownItem() when unknown != null:
return unknown(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( TimelineEventItem value)  event,required TResult Function( TimelineHearingItem value)  hearing,required TResult Function( TimelineTaskItem value)  task,required TResult Function( TimelineUnknownItem value)  unknown,}){
final _that = this;
switch (_that) {
case TimelineEventItem():
return event(_that);case TimelineHearingItem():
return hearing(_that);case TimelineTaskItem():
return task(_that);case TimelineUnknownItem():
return unknown(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( TimelineEventItem value)?  event,TResult? Function( TimelineHearingItem value)?  hearing,TResult? Function( TimelineTaskItem value)?  task,TResult? Function( TimelineUnknownItem value)?  unknown,}){
final _that = this;
switch (_that) {
case TimelineEventItem() when event != null:
return event(_that);case TimelineHearingItem() when hearing != null:
return hearing(_that);case TimelineTaskItem() when task != null:
return task(_that);case TimelineUnknownItem() when unknown != null:
return unknown(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String id,  String title,  DateTime date,  DateTime? endDate, @JsonKey(unknownEnumValue: CalendarEventType.unknown)  CalendarEventType eventType,  String? referenceId)?  event,TResult Function( String id,  String title,  DateTime? date, @JsonKey(unknownEnumValue: HearingStatus.unknown)  HearingStatus status,  CaseSummary? caseSummary)?  hearing,TResult Function( String id,  String title,  DateTime? date, @JsonKey(unknownEnumValue: TaskStatus.unknown)  TaskStatus status, @JsonKey(unknownEnumValue: TaskPriority.unknown)  TaskPriority priority,  CaseSummary? caseSummary)?  task,TResult Function( String id,  String? title)?  unknown,required TResult orElse(),}) {final _that = this;
switch (_that) {
case TimelineEventItem() when event != null:
return event(_that.id,_that.title,_that.date,_that.endDate,_that.eventType,_that.referenceId);case TimelineHearingItem() when hearing != null:
return hearing(_that.id,_that.title,_that.date,_that.status,_that.caseSummary);case TimelineTaskItem() when task != null:
return task(_that.id,_that.title,_that.date,_that.status,_that.priority,_that.caseSummary);case TimelineUnknownItem() when unknown != null:
return unknown(_that.id,_that.title);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String id,  String title,  DateTime date,  DateTime? endDate, @JsonKey(unknownEnumValue: CalendarEventType.unknown)  CalendarEventType eventType,  String? referenceId)  event,required TResult Function( String id,  String title,  DateTime? date, @JsonKey(unknownEnumValue: HearingStatus.unknown)  HearingStatus status,  CaseSummary? caseSummary)  hearing,required TResult Function( String id,  String title,  DateTime? date, @JsonKey(unknownEnumValue: TaskStatus.unknown)  TaskStatus status, @JsonKey(unknownEnumValue: TaskPriority.unknown)  TaskPriority priority,  CaseSummary? caseSummary)  task,required TResult Function( String id,  String? title)  unknown,}) {final _that = this;
switch (_that) {
case TimelineEventItem():
return event(_that.id,_that.title,_that.date,_that.endDate,_that.eventType,_that.referenceId);case TimelineHearingItem():
return hearing(_that.id,_that.title,_that.date,_that.status,_that.caseSummary);case TimelineTaskItem():
return task(_that.id,_that.title,_that.date,_that.status,_that.priority,_that.caseSummary);case TimelineUnknownItem():
return unknown(_that.id,_that.title);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String id,  String title,  DateTime date,  DateTime? endDate, @JsonKey(unknownEnumValue: CalendarEventType.unknown)  CalendarEventType eventType,  String? referenceId)?  event,TResult? Function( String id,  String title,  DateTime? date, @JsonKey(unknownEnumValue: HearingStatus.unknown)  HearingStatus status,  CaseSummary? caseSummary)?  hearing,TResult? Function( String id,  String title,  DateTime? date, @JsonKey(unknownEnumValue: TaskStatus.unknown)  TaskStatus status, @JsonKey(unknownEnumValue: TaskPriority.unknown)  TaskPriority priority,  CaseSummary? caseSummary)?  task,TResult? Function( String id,  String? title)?  unknown,}) {final _that = this;
switch (_that) {
case TimelineEventItem() when event != null:
return event(_that.id,_that.title,_that.date,_that.endDate,_that.eventType,_that.referenceId);case TimelineHearingItem() when hearing != null:
return hearing(_that.id,_that.title,_that.date,_that.status,_that.caseSummary);case TimelineTaskItem() when task != null:
return task(_that.id,_that.title,_that.date,_that.status,_that.priority,_that.caseSummary);case TimelineUnknownItem() when unknown != null:
return unknown(_that.id,_that.title);case _:
  return null;

}
}

}

/// @nodoc


class TimelineEventItem implements TimelineItem {
  const TimelineEventItem({required this.id, required this.title, required this.date, this.endDate, @JsonKey(unknownEnumValue: CalendarEventType.unknown) required this.eventType, this.referenceId});
  

@override final  String id;
@override final  String title;
 final  DateTime date;
 final  DateTime? endDate;
@JsonKey(unknownEnumValue: CalendarEventType.unknown) final  CalendarEventType eventType;
 final  String? referenceId;

/// Create a copy of TimelineItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TimelineEventItemCopyWith<TimelineEventItem> get copyWith => _$TimelineEventItemCopyWithImpl<TimelineEventItem>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TimelineEventItem&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.date, date) || other.date == date)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&(identical(other.eventType, eventType) || other.eventType == eventType)&&(identical(other.referenceId, referenceId) || other.referenceId == referenceId));
}


@override
int get hashCode => Object.hash(runtimeType,id,title,date,endDate,eventType,referenceId);

@override
String toString() {
  return 'TimelineItem.event(id: $id, title: $title, date: $date, endDate: $endDate, eventType: $eventType, referenceId: $referenceId)';
}


}

/// @nodoc
abstract mixin class $TimelineEventItemCopyWith<$Res> implements $TimelineItemCopyWith<$Res> {
  factory $TimelineEventItemCopyWith(TimelineEventItem value, $Res Function(TimelineEventItem) _then) = _$TimelineEventItemCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, DateTime date, DateTime? endDate,@JsonKey(unknownEnumValue: CalendarEventType.unknown) CalendarEventType eventType, String? referenceId
});




}
/// @nodoc
class _$TimelineEventItemCopyWithImpl<$Res>
    implements $TimelineEventItemCopyWith<$Res> {
  _$TimelineEventItemCopyWithImpl(this._self, this._then);

  final TimelineEventItem _self;
  final $Res Function(TimelineEventItem) _then;

/// Create a copy of TimelineItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? date = null,Object? endDate = freezed,Object? eventType = null,Object? referenceId = freezed,}) {
  return _then(TimelineEventItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime?,eventType: null == eventType ? _self.eventType : eventType // ignore: cast_nullable_to_non_nullable
as CalendarEventType,referenceId: freezed == referenceId ? _self.referenceId : referenceId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class TimelineHearingItem implements TimelineItem {
  const TimelineHearingItem({required this.id, required this.title, this.date, @JsonKey(unknownEnumValue: HearingStatus.unknown) required this.status, this.caseSummary});
  

@override final  String id;
@override final  String title;
 final  DateTime? date;
@JsonKey(unknownEnumValue: HearingStatus.unknown) final  HearingStatus status;
 final  CaseSummary? caseSummary;

/// Create a copy of TimelineItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TimelineHearingItemCopyWith<TimelineHearingItem> get copyWith => _$TimelineHearingItemCopyWithImpl<TimelineHearingItem>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TimelineHearingItem&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.date, date) || other.date == date)&&(identical(other.status, status) || other.status == status)&&(identical(other.caseSummary, caseSummary) || other.caseSummary == caseSummary));
}


@override
int get hashCode => Object.hash(runtimeType,id,title,date,status,caseSummary);

@override
String toString() {
  return 'TimelineItem.hearing(id: $id, title: $title, date: $date, status: $status, caseSummary: $caseSummary)';
}


}

/// @nodoc
abstract mixin class $TimelineHearingItemCopyWith<$Res> implements $TimelineItemCopyWith<$Res> {
  factory $TimelineHearingItemCopyWith(TimelineHearingItem value, $Res Function(TimelineHearingItem) _then) = _$TimelineHearingItemCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, DateTime? date,@JsonKey(unknownEnumValue: HearingStatus.unknown) HearingStatus status, CaseSummary? caseSummary
});


$CaseSummaryCopyWith<$Res>? get caseSummary;

}
/// @nodoc
class _$TimelineHearingItemCopyWithImpl<$Res>
    implements $TimelineHearingItemCopyWith<$Res> {
  _$TimelineHearingItemCopyWithImpl(this._self, this._then);

  final TimelineHearingItem _self;
  final $Res Function(TimelineHearingItem) _then;

/// Create a copy of TimelineItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? date = freezed,Object? status = null,Object? caseSummary = freezed,}) {
  return _then(TimelineHearingItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,date: freezed == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as HearingStatus,caseSummary: freezed == caseSummary ? _self.caseSummary : caseSummary // ignore: cast_nullable_to_non_nullable
as CaseSummary?,
  ));
}

/// Create a copy of TimelineItem
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
}
}

/// @nodoc


class TimelineTaskItem implements TimelineItem {
  const TimelineTaskItem({required this.id, required this.title, this.date, @JsonKey(unknownEnumValue: TaskStatus.unknown) required this.status, @JsonKey(unknownEnumValue: TaskPriority.unknown) required this.priority, this.caseSummary});
  

@override final  String id;
@override final  String title;
 final  DateTime? date;
@JsonKey(unknownEnumValue: TaskStatus.unknown) final  TaskStatus status;
@JsonKey(unknownEnumValue: TaskPriority.unknown) final  TaskPriority priority;
 final  CaseSummary? caseSummary;

/// Create a copy of TimelineItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TimelineTaskItemCopyWith<TimelineTaskItem> get copyWith => _$TimelineTaskItemCopyWithImpl<TimelineTaskItem>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TimelineTaskItem&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.date, date) || other.date == date)&&(identical(other.status, status) || other.status == status)&&(identical(other.priority, priority) || other.priority == priority)&&(identical(other.caseSummary, caseSummary) || other.caseSummary == caseSummary));
}


@override
int get hashCode => Object.hash(runtimeType,id,title,date,status,priority,caseSummary);

@override
String toString() {
  return 'TimelineItem.task(id: $id, title: $title, date: $date, status: $status, priority: $priority, caseSummary: $caseSummary)';
}


}

/// @nodoc
abstract mixin class $TimelineTaskItemCopyWith<$Res> implements $TimelineItemCopyWith<$Res> {
  factory $TimelineTaskItemCopyWith(TimelineTaskItem value, $Res Function(TimelineTaskItem) _then) = _$TimelineTaskItemCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, DateTime? date,@JsonKey(unknownEnumValue: TaskStatus.unknown) TaskStatus status,@JsonKey(unknownEnumValue: TaskPriority.unknown) TaskPriority priority, CaseSummary? caseSummary
});


$CaseSummaryCopyWith<$Res>? get caseSummary;

}
/// @nodoc
class _$TimelineTaskItemCopyWithImpl<$Res>
    implements $TimelineTaskItemCopyWith<$Res> {
  _$TimelineTaskItemCopyWithImpl(this._self, this._then);

  final TimelineTaskItem _self;
  final $Res Function(TimelineTaskItem) _then;

/// Create a copy of TimelineItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? date = freezed,Object? status = null,Object? priority = null,Object? caseSummary = freezed,}) {
  return _then(TimelineTaskItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,date: freezed == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TaskStatus,priority: null == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as TaskPriority,caseSummary: freezed == caseSummary ? _self.caseSummary : caseSummary // ignore: cast_nullable_to_non_nullable
as CaseSummary?,
  ));
}

/// Create a copy of TimelineItem
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
}
}

/// @nodoc


class TimelineUnknownItem implements TimelineItem {
  const TimelineUnknownItem({required this.id, this.title});
  

@override final  String id;
@override final  String? title;

/// Create a copy of TimelineItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TimelineUnknownItemCopyWith<TimelineUnknownItem> get copyWith => _$TimelineUnknownItemCopyWithImpl<TimelineUnknownItem>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TimelineUnknownItem&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title));
}


@override
int get hashCode => Object.hash(runtimeType,id,title);

@override
String toString() {
  return 'TimelineItem.unknown(id: $id, title: $title)';
}


}

/// @nodoc
abstract mixin class $TimelineUnknownItemCopyWith<$Res> implements $TimelineItemCopyWith<$Res> {
  factory $TimelineUnknownItemCopyWith(TimelineUnknownItem value, $Res Function(TimelineUnknownItem) _then) = _$TimelineUnknownItemCopyWithImpl;
@override @useResult
$Res call({
 String id, String? title
});




}
/// @nodoc
class _$TimelineUnknownItemCopyWithImpl<$Res>
    implements $TimelineUnknownItemCopyWith<$Res> {
  _$TimelineUnknownItemCopyWithImpl(this._self, this._then);

  final TimelineUnknownItem _self;
  final $Res Function(TimelineUnknownItem) _then;

/// Create a copy of TimelineItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = freezed,}) {
  return _then(TimelineUnknownItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
