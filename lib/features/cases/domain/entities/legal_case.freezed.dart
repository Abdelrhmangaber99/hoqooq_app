// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'legal_case.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$LegalCase {

 String get id; String get tenantId; String get caseNumber;@JsonKey(unknownEnumValue: CaseStatus.unknown) CaseStatus get status; String get caseTypeId;@JsonKey(unknownEnumValue: CasePriority.unknown) CasePriority get priority; DateTime get createdAt; DateTime get updatedAt; CaseClientSnapshot? get clientSnapshot; List<CaseOpponentSnapshot>? get opponentSnapshots; CaseTypeLookup? get caseType; String? get title; String? get courtCaseNumber; int? get courtCaseYear; String? get governorateId; String? get circuitId; String? get ownerFirmAdminId; String? get primaryLawyerId; String? get description; String? get courtName; DateTime? get openingDate; DateTime? get closingDate; String? get outcomeSummary; List<CaseTeamMember> get team;@JsonKey(fromJson: _timelineFromJson, includeToJson: false) List<CaseTimelineEvent>? get timelineEvents;
/// Create a copy of LegalCase
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LegalCaseCopyWith<LegalCase> get copyWith => _$LegalCaseCopyWithImpl<LegalCase>(this as LegalCase, _$identity);

  /// Serializes this LegalCase to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LegalCase&&(identical(other.id, id) || other.id == id)&&(identical(other.tenantId, tenantId) || other.tenantId == tenantId)&&(identical(other.caseNumber, caseNumber) || other.caseNumber == caseNumber)&&(identical(other.status, status) || other.status == status)&&(identical(other.caseTypeId, caseTypeId) || other.caseTypeId == caseTypeId)&&(identical(other.priority, priority) || other.priority == priority)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.clientSnapshot, clientSnapshot) || other.clientSnapshot == clientSnapshot)&&const DeepCollectionEquality().equals(other.opponentSnapshots, opponentSnapshots)&&(identical(other.caseType, caseType) || other.caseType == caseType)&&(identical(other.title, title) || other.title == title)&&(identical(other.courtCaseNumber, courtCaseNumber) || other.courtCaseNumber == courtCaseNumber)&&(identical(other.courtCaseYear, courtCaseYear) || other.courtCaseYear == courtCaseYear)&&(identical(other.governorateId, governorateId) || other.governorateId == governorateId)&&(identical(other.circuitId, circuitId) || other.circuitId == circuitId)&&(identical(other.ownerFirmAdminId, ownerFirmAdminId) || other.ownerFirmAdminId == ownerFirmAdminId)&&(identical(other.primaryLawyerId, primaryLawyerId) || other.primaryLawyerId == primaryLawyerId)&&(identical(other.description, description) || other.description == description)&&(identical(other.courtName, courtName) || other.courtName == courtName)&&(identical(other.openingDate, openingDate) || other.openingDate == openingDate)&&(identical(other.closingDate, closingDate) || other.closingDate == closingDate)&&(identical(other.outcomeSummary, outcomeSummary) || other.outcomeSummary == outcomeSummary)&&const DeepCollectionEquality().equals(other.team, team)&&const DeepCollectionEquality().equals(other.timelineEvents, timelineEvents));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,tenantId,caseNumber,status,caseTypeId,priority,createdAt,updatedAt,clientSnapshot,const DeepCollectionEquality().hash(opponentSnapshots),caseType,title,courtCaseNumber,courtCaseYear,governorateId,circuitId,ownerFirmAdminId,primaryLawyerId,description,courtName,openingDate,closingDate,outcomeSummary,const DeepCollectionEquality().hash(team),const DeepCollectionEquality().hash(timelineEvents)]);

@override
String toString() {
  return 'LegalCase(id: $id, tenantId: $tenantId, caseNumber: $caseNumber, status: $status, caseTypeId: $caseTypeId, priority: $priority, createdAt: $createdAt, updatedAt: $updatedAt, clientSnapshot: $clientSnapshot, opponentSnapshots: $opponentSnapshots, caseType: $caseType, title: $title, courtCaseNumber: $courtCaseNumber, courtCaseYear: $courtCaseYear, governorateId: $governorateId, circuitId: $circuitId, ownerFirmAdminId: $ownerFirmAdminId, primaryLawyerId: $primaryLawyerId, description: $description, courtName: $courtName, openingDate: $openingDate, closingDate: $closingDate, outcomeSummary: $outcomeSummary, team: $team, timelineEvents: $timelineEvents)';
}


}

/// @nodoc
abstract mixin class $LegalCaseCopyWith<$Res>  {
  factory $LegalCaseCopyWith(LegalCase value, $Res Function(LegalCase) _then) = _$LegalCaseCopyWithImpl;
@useResult
$Res call({
 String id, String tenantId, String caseNumber,@JsonKey(unknownEnumValue: CaseStatus.unknown) CaseStatus status, String caseTypeId,@JsonKey(unknownEnumValue: CasePriority.unknown) CasePriority priority, DateTime createdAt, DateTime updatedAt, CaseClientSnapshot? clientSnapshot, List<CaseOpponentSnapshot>? opponentSnapshots, CaseTypeLookup? caseType, String? title, String? courtCaseNumber, int? courtCaseYear, String? governorateId, String? circuitId, String? ownerFirmAdminId, String? primaryLawyerId, String? description, String? courtName, DateTime? openingDate, DateTime? closingDate, String? outcomeSummary, List<CaseTeamMember> team,@JsonKey(fromJson: _timelineFromJson, includeToJson: false) List<CaseTimelineEvent>? timelineEvents
});


$CaseTypeLookupCopyWith<$Res>? get caseType;

}
/// @nodoc
class _$LegalCaseCopyWithImpl<$Res>
    implements $LegalCaseCopyWith<$Res> {
  _$LegalCaseCopyWithImpl(this._self, this._then);

  final LegalCase _self;
  final $Res Function(LegalCase) _then;

/// Create a copy of LegalCase
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? tenantId = null,Object? caseNumber = null,Object? status = null,Object? caseTypeId = null,Object? priority = null,Object? createdAt = null,Object? updatedAt = null,Object? clientSnapshot = freezed,Object? opponentSnapshots = freezed,Object? caseType = freezed,Object? title = freezed,Object? courtCaseNumber = freezed,Object? courtCaseYear = freezed,Object? governorateId = freezed,Object? circuitId = freezed,Object? ownerFirmAdminId = freezed,Object? primaryLawyerId = freezed,Object? description = freezed,Object? courtName = freezed,Object? openingDate = freezed,Object? closingDate = freezed,Object? outcomeSummary = freezed,Object? team = null,Object? timelineEvents = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,tenantId: null == tenantId ? _self.tenantId : tenantId // ignore: cast_nullable_to_non_nullable
as String,caseNumber: null == caseNumber ? _self.caseNumber : caseNumber // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as CaseStatus,caseTypeId: null == caseTypeId ? _self.caseTypeId : caseTypeId // ignore: cast_nullable_to_non_nullable
as String,priority: null == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as CasePriority,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,clientSnapshot: freezed == clientSnapshot ? _self.clientSnapshot : clientSnapshot // ignore: cast_nullable_to_non_nullable
as CaseClientSnapshot?,opponentSnapshots: freezed == opponentSnapshots ? _self.opponentSnapshots : opponentSnapshots // ignore: cast_nullable_to_non_nullable
as List<CaseOpponentSnapshot>?,caseType: freezed == caseType ? _self.caseType : caseType // ignore: cast_nullable_to_non_nullable
as CaseTypeLookup?,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,courtCaseNumber: freezed == courtCaseNumber ? _self.courtCaseNumber : courtCaseNumber // ignore: cast_nullable_to_non_nullable
as String?,courtCaseYear: freezed == courtCaseYear ? _self.courtCaseYear : courtCaseYear // ignore: cast_nullable_to_non_nullable
as int?,governorateId: freezed == governorateId ? _self.governorateId : governorateId // ignore: cast_nullable_to_non_nullable
as String?,circuitId: freezed == circuitId ? _self.circuitId : circuitId // ignore: cast_nullable_to_non_nullable
as String?,ownerFirmAdminId: freezed == ownerFirmAdminId ? _self.ownerFirmAdminId : ownerFirmAdminId // ignore: cast_nullable_to_non_nullable
as String?,primaryLawyerId: freezed == primaryLawyerId ? _self.primaryLawyerId : primaryLawyerId // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,courtName: freezed == courtName ? _self.courtName : courtName // ignore: cast_nullable_to_non_nullable
as String?,openingDate: freezed == openingDate ? _self.openingDate : openingDate // ignore: cast_nullable_to_non_nullable
as DateTime?,closingDate: freezed == closingDate ? _self.closingDate : closingDate // ignore: cast_nullable_to_non_nullable
as DateTime?,outcomeSummary: freezed == outcomeSummary ? _self.outcomeSummary : outcomeSummary // ignore: cast_nullable_to_non_nullable
as String?,team: null == team ? _self.team : team // ignore: cast_nullable_to_non_nullable
as List<CaseTeamMember>,timelineEvents: freezed == timelineEvents ? _self.timelineEvents : timelineEvents // ignore: cast_nullable_to_non_nullable
as List<CaseTimelineEvent>?,
  ));
}
/// Create a copy of LegalCase
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CaseTypeLookupCopyWith<$Res>? get caseType {
    if (_self.caseType == null) {
    return null;
  }

  return $CaseTypeLookupCopyWith<$Res>(_self.caseType!, (value) {
    return _then(_self.copyWith(caseType: value));
  });
}
}


/// Adds pattern-matching-related methods to [LegalCase].
extension LegalCasePatterns on LegalCase {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LegalCase value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LegalCase() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LegalCase value)  $default,){
final _that = this;
switch (_that) {
case _LegalCase():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LegalCase value)?  $default,){
final _that = this;
switch (_that) {
case _LegalCase() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String tenantId,  String caseNumber, @JsonKey(unknownEnumValue: CaseStatus.unknown)  CaseStatus status,  String caseTypeId, @JsonKey(unknownEnumValue: CasePriority.unknown)  CasePriority priority,  DateTime createdAt,  DateTime updatedAt,  CaseClientSnapshot? clientSnapshot,  List<CaseOpponentSnapshot>? opponentSnapshots,  CaseTypeLookup? caseType,  String? title,  String? courtCaseNumber,  int? courtCaseYear,  String? governorateId,  String? circuitId,  String? ownerFirmAdminId,  String? primaryLawyerId,  String? description,  String? courtName,  DateTime? openingDate,  DateTime? closingDate,  String? outcomeSummary,  List<CaseTeamMember> team, @JsonKey(fromJson: _timelineFromJson, includeToJson: false)  List<CaseTimelineEvent>? timelineEvents)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LegalCase() when $default != null:
return $default(_that.id,_that.tenantId,_that.caseNumber,_that.status,_that.caseTypeId,_that.priority,_that.createdAt,_that.updatedAt,_that.clientSnapshot,_that.opponentSnapshots,_that.caseType,_that.title,_that.courtCaseNumber,_that.courtCaseYear,_that.governorateId,_that.circuitId,_that.ownerFirmAdminId,_that.primaryLawyerId,_that.description,_that.courtName,_that.openingDate,_that.closingDate,_that.outcomeSummary,_that.team,_that.timelineEvents);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String tenantId,  String caseNumber, @JsonKey(unknownEnumValue: CaseStatus.unknown)  CaseStatus status,  String caseTypeId, @JsonKey(unknownEnumValue: CasePriority.unknown)  CasePriority priority,  DateTime createdAt,  DateTime updatedAt,  CaseClientSnapshot? clientSnapshot,  List<CaseOpponentSnapshot>? opponentSnapshots,  CaseTypeLookup? caseType,  String? title,  String? courtCaseNumber,  int? courtCaseYear,  String? governorateId,  String? circuitId,  String? ownerFirmAdminId,  String? primaryLawyerId,  String? description,  String? courtName,  DateTime? openingDate,  DateTime? closingDate,  String? outcomeSummary,  List<CaseTeamMember> team, @JsonKey(fromJson: _timelineFromJson, includeToJson: false)  List<CaseTimelineEvent>? timelineEvents)  $default,) {final _that = this;
switch (_that) {
case _LegalCase():
return $default(_that.id,_that.tenantId,_that.caseNumber,_that.status,_that.caseTypeId,_that.priority,_that.createdAt,_that.updatedAt,_that.clientSnapshot,_that.opponentSnapshots,_that.caseType,_that.title,_that.courtCaseNumber,_that.courtCaseYear,_that.governorateId,_that.circuitId,_that.ownerFirmAdminId,_that.primaryLawyerId,_that.description,_that.courtName,_that.openingDate,_that.closingDate,_that.outcomeSummary,_that.team,_that.timelineEvents);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String tenantId,  String caseNumber, @JsonKey(unknownEnumValue: CaseStatus.unknown)  CaseStatus status,  String caseTypeId, @JsonKey(unknownEnumValue: CasePriority.unknown)  CasePriority priority,  DateTime createdAt,  DateTime updatedAt,  CaseClientSnapshot? clientSnapshot,  List<CaseOpponentSnapshot>? opponentSnapshots,  CaseTypeLookup? caseType,  String? title,  String? courtCaseNumber,  int? courtCaseYear,  String? governorateId,  String? circuitId,  String? ownerFirmAdminId,  String? primaryLawyerId,  String? description,  String? courtName,  DateTime? openingDate,  DateTime? closingDate,  String? outcomeSummary,  List<CaseTeamMember> team, @JsonKey(fromJson: _timelineFromJson, includeToJson: false)  List<CaseTimelineEvent>? timelineEvents)?  $default,) {final _that = this;
switch (_that) {
case _LegalCase() when $default != null:
return $default(_that.id,_that.tenantId,_that.caseNumber,_that.status,_that.caseTypeId,_that.priority,_that.createdAt,_that.updatedAt,_that.clientSnapshot,_that.opponentSnapshots,_that.caseType,_that.title,_that.courtCaseNumber,_that.courtCaseYear,_that.governorateId,_that.circuitId,_that.ownerFirmAdminId,_that.primaryLawyerId,_that.description,_that.courtName,_that.openingDate,_that.closingDate,_that.outcomeSummary,_that.team,_that.timelineEvents);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LegalCase implements LegalCase {
  const _LegalCase({required this.id, required this.tenantId, required this.caseNumber, @JsonKey(unknownEnumValue: CaseStatus.unknown) required this.status, required this.caseTypeId, @JsonKey(unknownEnumValue: CasePriority.unknown) required this.priority, required this.createdAt, required this.updatedAt, this.clientSnapshot, final  List<CaseOpponentSnapshot>? opponentSnapshots, this.caseType, this.title, this.courtCaseNumber, this.courtCaseYear, this.governorateId, this.circuitId, this.ownerFirmAdminId, this.primaryLawyerId, this.description, this.courtName, this.openingDate, this.closingDate, this.outcomeSummary, required final  List<CaseTeamMember> team, @JsonKey(fromJson: _timelineFromJson, includeToJson: false) final  List<CaseTimelineEvent>? timelineEvents}): _opponentSnapshots = opponentSnapshots,_team = team,_timelineEvents = timelineEvents;
  factory _LegalCase.fromJson(Map<String, dynamic> json) => _$LegalCaseFromJson(json);

@override final  String id;
@override final  String tenantId;
@override final  String caseNumber;
@override@JsonKey(unknownEnumValue: CaseStatus.unknown) final  CaseStatus status;
@override final  String caseTypeId;
@override@JsonKey(unknownEnumValue: CasePriority.unknown) final  CasePriority priority;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  CaseClientSnapshot? clientSnapshot;
 final  List<CaseOpponentSnapshot>? _opponentSnapshots;
@override List<CaseOpponentSnapshot>? get opponentSnapshots {
  final value = _opponentSnapshots;
  if (value == null) return null;
  if (_opponentSnapshots is EqualUnmodifiableListView) return _opponentSnapshots;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override final  CaseTypeLookup? caseType;
@override final  String? title;
@override final  String? courtCaseNumber;
@override final  int? courtCaseYear;
@override final  String? governorateId;
@override final  String? circuitId;
@override final  String? ownerFirmAdminId;
@override final  String? primaryLawyerId;
@override final  String? description;
@override final  String? courtName;
@override final  DateTime? openingDate;
@override final  DateTime? closingDate;
@override final  String? outcomeSummary;
 final  List<CaseTeamMember> _team;
@override List<CaseTeamMember> get team {
  if (_team is EqualUnmodifiableListView) return _team;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_team);
}

 final  List<CaseTimelineEvent>? _timelineEvents;
@override@JsonKey(fromJson: _timelineFromJson, includeToJson: false) List<CaseTimelineEvent>? get timelineEvents {
  final value = _timelineEvents;
  if (value == null) return null;
  if (_timelineEvents is EqualUnmodifiableListView) return _timelineEvents;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of LegalCase
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LegalCaseCopyWith<_LegalCase> get copyWith => __$LegalCaseCopyWithImpl<_LegalCase>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LegalCaseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LegalCase&&(identical(other.id, id) || other.id == id)&&(identical(other.tenantId, tenantId) || other.tenantId == tenantId)&&(identical(other.caseNumber, caseNumber) || other.caseNumber == caseNumber)&&(identical(other.status, status) || other.status == status)&&(identical(other.caseTypeId, caseTypeId) || other.caseTypeId == caseTypeId)&&(identical(other.priority, priority) || other.priority == priority)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.clientSnapshot, clientSnapshot) || other.clientSnapshot == clientSnapshot)&&const DeepCollectionEquality().equals(other._opponentSnapshots, _opponentSnapshots)&&(identical(other.caseType, caseType) || other.caseType == caseType)&&(identical(other.title, title) || other.title == title)&&(identical(other.courtCaseNumber, courtCaseNumber) || other.courtCaseNumber == courtCaseNumber)&&(identical(other.courtCaseYear, courtCaseYear) || other.courtCaseYear == courtCaseYear)&&(identical(other.governorateId, governorateId) || other.governorateId == governorateId)&&(identical(other.circuitId, circuitId) || other.circuitId == circuitId)&&(identical(other.ownerFirmAdminId, ownerFirmAdminId) || other.ownerFirmAdminId == ownerFirmAdminId)&&(identical(other.primaryLawyerId, primaryLawyerId) || other.primaryLawyerId == primaryLawyerId)&&(identical(other.description, description) || other.description == description)&&(identical(other.courtName, courtName) || other.courtName == courtName)&&(identical(other.openingDate, openingDate) || other.openingDate == openingDate)&&(identical(other.closingDate, closingDate) || other.closingDate == closingDate)&&(identical(other.outcomeSummary, outcomeSummary) || other.outcomeSummary == outcomeSummary)&&const DeepCollectionEquality().equals(other._team, _team)&&const DeepCollectionEquality().equals(other._timelineEvents, _timelineEvents));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,tenantId,caseNumber,status,caseTypeId,priority,createdAt,updatedAt,clientSnapshot,const DeepCollectionEquality().hash(_opponentSnapshots),caseType,title,courtCaseNumber,courtCaseYear,governorateId,circuitId,ownerFirmAdminId,primaryLawyerId,description,courtName,openingDate,closingDate,outcomeSummary,const DeepCollectionEquality().hash(_team),const DeepCollectionEquality().hash(_timelineEvents)]);

@override
String toString() {
  return 'LegalCase(id: $id, tenantId: $tenantId, caseNumber: $caseNumber, status: $status, caseTypeId: $caseTypeId, priority: $priority, createdAt: $createdAt, updatedAt: $updatedAt, clientSnapshot: $clientSnapshot, opponentSnapshots: $opponentSnapshots, caseType: $caseType, title: $title, courtCaseNumber: $courtCaseNumber, courtCaseYear: $courtCaseYear, governorateId: $governorateId, circuitId: $circuitId, ownerFirmAdminId: $ownerFirmAdminId, primaryLawyerId: $primaryLawyerId, description: $description, courtName: $courtName, openingDate: $openingDate, closingDate: $closingDate, outcomeSummary: $outcomeSummary, team: $team, timelineEvents: $timelineEvents)';
}


}

/// @nodoc
abstract mixin class _$LegalCaseCopyWith<$Res> implements $LegalCaseCopyWith<$Res> {
  factory _$LegalCaseCopyWith(_LegalCase value, $Res Function(_LegalCase) _then) = __$LegalCaseCopyWithImpl;
@override @useResult
$Res call({
 String id, String tenantId, String caseNumber,@JsonKey(unknownEnumValue: CaseStatus.unknown) CaseStatus status, String caseTypeId,@JsonKey(unknownEnumValue: CasePriority.unknown) CasePriority priority, DateTime createdAt, DateTime updatedAt, CaseClientSnapshot? clientSnapshot, List<CaseOpponentSnapshot>? opponentSnapshots, CaseTypeLookup? caseType, String? title, String? courtCaseNumber, int? courtCaseYear, String? governorateId, String? circuitId, String? ownerFirmAdminId, String? primaryLawyerId, String? description, String? courtName, DateTime? openingDate, DateTime? closingDate, String? outcomeSummary, List<CaseTeamMember> team,@JsonKey(fromJson: _timelineFromJson, includeToJson: false) List<CaseTimelineEvent>? timelineEvents
});


@override $CaseTypeLookupCopyWith<$Res>? get caseType;

}
/// @nodoc
class __$LegalCaseCopyWithImpl<$Res>
    implements _$LegalCaseCopyWith<$Res> {
  __$LegalCaseCopyWithImpl(this._self, this._then);

  final _LegalCase _self;
  final $Res Function(_LegalCase) _then;

/// Create a copy of LegalCase
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? tenantId = null,Object? caseNumber = null,Object? status = null,Object? caseTypeId = null,Object? priority = null,Object? createdAt = null,Object? updatedAt = null,Object? clientSnapshot = freezed,Object? opponentSnapshots = freezed,Object? caseType = freezed,Object? title = freezed,Object? courtCaseNumber = freezed,Object? courtCaseYear = freezed,Object? governorateId = freezed,Object? circuitId = freezed,Object? ownerFirmAdminId = freezed,Object? primaryLawyerId = freezed,Object? description = freezed,Object? courtName = freezed,Object? openingDate = freezed,Object? closingDate = freezed,Object? outcomeSummary = freezed,Object? team = null,Object? timelineEvents = freezed,}) {
  return _then(_LegalCase(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,tenantId: null == tenantId ? _self.tenantId : tenantId // ignore: cast_nullable_to_non_nullable
as String,caseNumber: null == caseNumber ? _self.caseNumber : caseNumber // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as CaseStatus,caseTypeId: null == caseTypeId ? _self.caseTypeId : caseTypeId // ignore: cast_nullable_to_non_nullable
as String,priority: null == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as CasePriority,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,clientSnapshot: freezed == clientSnapshot ? _self.clientSnapshot : clientSnapshot // ignore: cast_nullable_to_non_nullable
as CaseClientSnapshot?,opponentSnapshots: freezed == opponentSnapshots ? _self._opponentSnapshots : opponentSnapshots // ignore: cast_nullable_to_non_nullable
as List<CaseOpponentSnapshot>?,caseType: freezed == caseType ? _self.caseType : caseType // ignore: cast_nullable_to_non_nullable
as CaseTypeLookup?,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,courtCaseNumber: freezed == courtCaseNumber ? _self.courtCaseNumber : courtCaseNumber // ignore: cast_nullable_to_non_nullable
as String?,courtCaseYear: freezed == courtCaseYear ? _self.courtCaseYear : courtCaseYear // ignore: cast_nullable_to_non_nullable
as int?,governorateId: freezed == governorateId ? _self.governorateId : governorateId // ignore: cast_nullable_to_non_nullable
as String?,circuitId: freezed == circuitId ? _self.circuitId : circuitId // ignore: cast_nullable_to_non_nullable
as String?,ownerFirmAdminId: freezed == ownerFirmAdminId ? _self.ownerFirmAdminId : ownerFirmAdminId // ignore: cast_nullable_to_non_nullable
as String?,primaryLawyerId: freezed == primaryLawyerId ? _self.primaryLawyerId : primaryLawyerId // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,courtName: freezed == courtName ? _self.courtName : courtName // ignore: cast_nullable_to_non_nullable
as String?,openingDate: freezed == openingDate ? _self.openingDate : openingDate // ignore: cast_nullable_to_non_nullable
as DateTime?,closingDate: freezed == closingDate ? _self.closingDate : closingDate // ignore: cast_nullable_to_non_nullable
as DateTime?,outcomeSummary: freezed == outcomeSummary ? _self.outcomeSummary : outcomeSummary // ignore: cast_nullable_to_non_nullable
as String?,team: null == team ? _self._team : team // ignore: cast_nullable_to_non_nullable
as List<CaseTeamMember>,timelineEvents: freezed == timelineEvents ? _self._timelineEvents : timelineEvents // ignore: cast_nullable_to_non_nullable
as List<CaseTimelineEvent>?,
  ));
}

/// Create a copy of LegalCase
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CaseTypeLookupCopyWith<$Res>? get caseType {
    if (_self.caseType == null) {
    return null;
  }

  return $CaseTypeLookupCopyWith<$Res>(_self.caseType!, (value) {
    return _then(_self.copyWith(caseType: value));
  });
}
}

// dart format on
