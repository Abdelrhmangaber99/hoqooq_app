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

 String get id; String get tenantId; String get caseNumber;@JsonKey(unknownEnumValue: CaseStatus.unknown) CaseStatus get status; String get clientId; String get caseTypeId;@JsonKey(unknownEnumValue: CasePriority.unknown) CasePriority get priority; DateTime get createdAt; DateTime get updatedAt; Client get client; String? get primaryLawyerId; User? get primaryLawyer; CaseTypeLookup? get caseType; String? get defaultCourtId; Court? get defaultCourt; DateTime? get openingDate; DateTime? get closingDate; String? get outcomeSummary; double? get agreedFee; List<CaseTeamMember> get team;
/// Create a copy of LegalCase
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LegalCaseCopyWith<LegalCase> get copyWith => _$LegalCaseCopyWithImpl<LegalCase>(this as LegalCase, _$identity);

  /// Serializes this LegalCase to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LegalCase&&(identical(other.id, id) || other.id == id)&&(identical(other.tenantId, tenantId) || other.tenantId == tenantId)&&(identical(other.caseNumber, caseNumber) || other.caseNumber == caseNumber)&&(identical(other.status, status) || other.status == status)&&(identical(other.clientId, clientId) || other.clientId == clientId)&&(identical(other.caseTypeId, caseTypeId) || other.caseTypeId == caseTypeId)&&(identical(other.priority, priority) || other.priority == priority)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.client, client) || other.client == client)&&(identical(other.primaryLawyerId, primaryLawyerId) || other.primaryLawyerId == primaryLawyerId)&&(identical(other.primaryLawyer, primaryLawyer) || other.primaryLawyer == primaryLawyer)&&(identical(other.caseType, caseType) || other.caseType == caseType)&&(identical(other.defaultCourtId, defaultCourtId) || other.defaultCourtId == defaultCourtId)&&(identical(other.defaultCourt, defaultCourt) || other.defaultCourt == defaultCourt)&&(identical(other.openingDate, openingDate) || other.openingDate == openingDate)&&(identical(other.closingDate, closingDate) || other.closingDate == closingDate)&&(identical(other.outcomeSummary, outcomeSummary) || other.outcomeSummary == outcomeSummary)&&(identical(other.agreedFee, agreedFee) || other.agreedFee == agreedFee)&&const DeepCollectionEquality().equals(other.team, team));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,tenantId,caseNumber,status,clientId,caseTypeId,priority,createdAt,updatedAt,client,primaryLawyerId,primaryLawyer,caseType,defaultCourtId,defaultCourt,openingDate,closingDate,outcomeSummary,agreedFee,const DeepCollectionEquality().hash(team)]);

@override
String toString() {
  return 'LegalCase(id: $id, tenantId: $tenantId, caseNumber: $caseNumber, status: $status, clientId: $clientId, caseTypeId: $caseTypeId, priority: $priority, createdAt: $createdAt, updatedAt: $updatedAt, client: $client, primaryLawyerId: $primaryLawyerId, primaryLawyer: $primaryLawyer, caseType: $caseType, defaultCourtId: $defaultCourtId, defaultCourt: $defaultCourt, openingDate: $openingDate, closingDate: $closingDate, outcomeSummary: $outcomeSummary, agreedFee: $agreedFee, team: $team)';
}


}

/// @nodoc
abstract mixin class $LegalCaseCopyWith<$Res>  {
  factory $LegalCaseCopyWith(LegalCase value, $Res Function(LegalCase) _then) = _$LegalCaseCopyWithImpl;
@useResult
$Res call({
 String id, String tenantId, String caseNumber,@JsonKey(unknownEnumValue: CaseStatus.unknown) CaseStatus status, String clientId, String caseTypeId,@JsonKey(unknownEnumValue: CasePriority.unknown) CasePriority priority, DateTime createdAt, DateTime updatedAt, Client client, String? primaryLawyerId, User? primaryLawyer, CaseTypeLookup? caseType, String? defaultCourtId, Court? defaultCourt, DateTime? openingDate, DateTime? closingDate, String? outcomeSummary, double? agreedFee, List<CaseTeamMember> team
});


$ClientCopyWith<$Res> get client;$UserCopyWith<$Res>? get primaryLawyer;$CaseTypeLookupCopyWith<$Res>? get caseType;$CourtCopyWith<$Res>? get defaultCourt;

}
/// @nodoc
class _$LegalCaseCopyWithImpl<$Res>
    implements $LegalCaseCopyWith<$Res> {
  _$LegalCaseCopyWithImpl(this._self, this._then);

  final LegalCase _self;
  final $Res Function(LegalCase) _then;

/// Create a copy of LegalCase
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? tenantId = null,Object? caseNumber = null,Object? status = null,Object? clientId = null,Object? caseTypeId = null,Object? priority = null,Object? createdAt = null,Object? updatedAt = null,Object? client = null,Object? primaryLawyerId = freezed,Object? primaryLawyer = freezed,Object? caseType = freezed,Object? defaultCourtId = freezed,Object? defaultCourt = freezed,Object? openingDate = freezed,Object? closingDate = freezed,Object? outcomeSummary = freezed,Object? agreedFee = freezed,Object? team = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,tenantId: null == tenantId ? _self.tenantId : tenantId // ignore: cast_nullable_to_non_nullable
as String,caseNumber: null == caseNumber ? _self.caseNumber : caseNumber // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as CaseStatus,clientId: null == clientId ? _self.clientId : clientId // ignore: cast_nullable_to_non_nullable
as String,caseTypeId: null == caseTypeId ? _self.caseTypeId : caseTypeId // ignore: cast_nullable_to_non_nullable
as String,priority: null == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as CasePriority,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,client: null == client ? _self.client : client // ignore: cast_nullable_to_non_nullable
as Client,primaryLawyerId: freezed == primaryLawyerId ? _self.primaryLawyerId : primaryLawyerId // ignore: cast_nullable_to_non_nullable
as String?,primaryLawyer: freezed == primaryLawyer ? _self.primaryLawyer : primaryLawyer // ignore: cast_nullable_to_non_nullable
as User?,caseType: freezed == caseType ? _self.caseType : caseType // ignore: cast_nullable_to_non_nullable
as CaseTypeLookup?,defaultCourtId: freezed == defaultCourtId ? _self.defaultCourtId : defaultCourtId // ignore: cast_nullable_to_non_nullable
as String?,defaultCourt: freezed == defaultCourt ? _self.defaultCourt : defaultCourt // ignore: cast_nullable_to_non_nullable
as Court?,openingDate: freezed == openingDate ? _self.openingDate : openingDate // ignore: cast_nullable_to_non_nullable
as DateTime?,closingDate: freezed == closingDate ? _self.closingDate : closingDate // ignore: cast_nullable_to_non_nullable
as DateTime?,outcomeSummary: freezed == outcomeSummary ? _self.outcomeSummary : outcomeSummary // ignore: cast_nullable_to_non_nullable
as String?,agreedFee: freezed == agreedFee ? _self.agreedFee : agreedFee // ignore: cast_nullable_to_non_nullable
as double?,team: null == team ? _self.team : team // ignore: cast_nullable_to_non_nullable
as List<CaseTeamMember>,
  ));
}
/// Create a copy of LegalCase
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ClientCopyWith<$Res> get client {
  
  return $ClientCopyWith<$Res>(_self.client, (value) {
    return _then(_self.copyWith(client: value));
  });
}/// Create a copy of LegalCase
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserCopyWith<$Res>? get primaryLawyer {
    if (_self.primaryLawyer == null) {
    return null;
  }

  return $UserCopyWith<$Res>(_self.primaryLawyer!, (value) {
    return _then(_self.copyWith(primaryLawyer: value));
  });
}/// Create a copy of LegalCase
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
}/// Create a copy of LegalCase
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CourtCopyWith<$Res>? get defaultCourt {
    if (_self.defaultCourt == null) {
    return null;
  }

  return $CourtCopyWith<$Res>(_self.defaultCourt!, (value) {
    return _then(_self.copyWith(defaultCourt: value));
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String tenantId,  String caseNumber, @JsonKey(unknownEnumValue: CaseStatus.unknown)  CaseStatus status,  String clientId,  String caseTypeId, @JsonKey(unknownEnumValue: CasePriority.unknown)  CasePriority priority,  DateTime createdAt,  DateTime updatedAt,  Client client,  String? primaryLawyerId,  User? primaryLawyer,  CaseTypeLookup? caseType,  String? defaultCourtId,  Court? defaultCourt,  DateTime? openingDate,  DateTime? closingDate,  String? outcomeSummary,  double? agreedFee,  List<CaseTeamMember> team)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LegalCase() when $default != null:
return $default(_that.id,_that.tenantId,_that.caseNumber,_that.status,_that.clientId,_that.caseTypeId,_that.priority,_that.createdAt,_that.updatedAt,_that.client,_that.primaryLawyerId,_that.primaryLawyer,_that.caseType,_that.defaultCourtId,_that.defaultCourt,_that.openingDate,_that.closingDate,_that.outcomeSummary,_that.agreedFee,_that.team);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String tenantId,  String caseNumber, @JsonKey(unknownEnumValue: CaseStatus.unknown)  CaseStatus status,  String clientId,  String caseTypeId, @JsonKey(unknownEnumValue: CasePriority.unknown)  CasePriority priority,  DateTime createdAt,  DateTime updatedAt,  Client client,  String? primaryLawyerId,  User? primaryLawyer,  CaseTypeLookup? caseType,  String? defaultCourtId,  Court? defaultCourt,  DateTime? openingDate,  DateTime? closingDate,  String? outcomeSummary,  double? agreedFee,  List<CaseTeamMember> team)  $default,) {final _that = this;
switch (_that) {
case _LegalCase():
return $default(_that.id,_that.tenantId,_that.caseNumber,_that.status,_that.clientId,_that.caseTypeId,_that.priority,_that.createdAt,_that.updatedAt,_that.client,_that.primaryLawyerId,_that.primaryLawyer,_that.caseType,_that.defaultCourtId,_that.defaultCourt,_that.openingDate,_that.closingDate,_that.outcomeSummary,_that.agreedFee,_that.team);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String tenantId,  String caseNumber, @JsonKey(unknownEnumValue: CaseStatus.unknown)  CaseStatus status,  String clientId,  String caseTypeId, @JsonKey(unknownEnumValue: CasePriority.unknown)  CasePriority priority,  DateTime createdAt,  DateTime updatedAt,  Client client,  String? primaryLawyerId,  User? primaryLawyer,  CaseTypeLookup? caseType,  String? defaultCourtId,  Court? defaultCourt,  DateTime? openingDate,  DateTime? closingDate,  String? outcomeSummary,  double? agreedFee,  List<CaseTeamMember> team)?  $default,) {final _that = this;
switch (_that) {
case _LegalCase() when $default != null:
return $default(_that.id,_that.tenantId,_that.caseNumber,_that.status,_that.clientId,_that.caseTypeId,_that.priority,_that.createdAt,_that.updatedAt,_that.client,_that.primaryLawyerId,_that.primaryLawyer,_that.caseType,_that.defaultCourtId,_that.defaultCourt,_that.openingDate,_that.closingDate,_that.outcomeSummary,_that.agreedFee,_that.team);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LegalCase implements LegalCase {
  const _LegalCase({required this.id, required this.tenantId, required this.caseNumber, @JsonKey(unknownEnumValue: CaseStatus.unknown) required this.status, required this.clientId, required this.caseTypeId, @JsonKey(unknownEnumValue: CasePriority.unknown) required this.priority, required this.createdAt, required this.updatedAt, required this.client, this.primaryLawyerId, this.primaryLawyer, this.caseType, this.defaultCourtId, this.defaultCourt, this.openingDate, this.closingDate, this.outcomeSummary, this.agreedFee, required final  List<CaseTeamMember> team}): _team = team;
  factory _LegalCase.fromJson(Map<String, dynamic> json) => _$LegalCaseFromJson(json);

@override final  String id;
@override final  String tenantId;
@override final  String caseNumber;
@override@JsonKey(unknownEnumValue: CaseStatus.unknown) final  CaseStatus status;
@override final  String clientId;
@override final  String caseTypeId;
@override@JsonKey(unknownEnumValue: CasePriority.unknown) final  CasePriority priority;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  Client client;
@override final  String? primaryLawyerId;
@override final  User? primaryLawyer;
@override final  CaseTypeLookup? caseType;
@override final  String? defaultCourtId;
@override final  Court? defaultCourt;
@override final  DateTime? openingDate;
@override final  DateTime? closingDate;
@override final  String? outcomeSummary;
@override final  double? agreedFee;
 final  List<CaseTeamMember> _team;
@override List<CaseTeamMember> get team {
  if (_team is EqualUnmodifiableListView) return _team;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_team);
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LegalCase&&(identical(other.id, id) || other.id == id)&&(identical(other.tenantId, tenantId) || other.tenantId == tenantId)&&(identical(other.caseNumber, caseNumber) || other.caseNumber == caseNumber)&&(identical(other.status, status) || other.status == status)&&(identical(other.clientId, clientId) || other.clientId == clientId)&&(identical(other.caseTypeId, caseTypeId) || other.caseTypeId == caseTypeId)&&(identical(other.priority, priority) || other.priority == priority)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.client, client) || other.client == client)&&(identical(other.primaryLawyerId, primaryLawyerId) || other.primaryLawyerId == primaryLawyerId)&&(identical(other.primaryLawyer, primaryLawyer) || other.primaryLawyer == primaryLawyer)&&(identical(other.caseType, caseType) || other.caseType == caseType)&&(identical(other.defaultCourtId, defaultCourtId) || other.defaultCourtId == defaultCourtId)&&(identical(other.defaultCourt, defaultCourt) || other.defaultCourt == defaultCourt)&&(identical(other.openingDate, openingDate) || other.openingDate == openingDate)&&(identical(other.closingDate, closingDate) || other.closingDate == closingDate)&&(identical(other.outcomeSummary, outcomeSummary) || other.outcomeSummary == outcomeSummary)&&(identical(other.agreedFee, agreedFee) || other.agreedFee == agreedFee)&&const DeepCollectionEquality().equals(other._team, _team));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,tenantId,caseNumber,status,clientId,caseTypeId,priority,createdAt,updatedAt,client,primaryLawyerId,primaryLawyer,caseType,defaultCourtId,defaultCourt,openingDate,closingDate,outcomeSummary,agreedFee,const DeepCollectionEquality().hash(_team)]);

@override
String toString() {
  return 'LegalCase(id: $id, tenantId: $tenantId, caseNumber: $caseNumber, status: $status, clientId: $clientId, caseTypeId: $caseTypeId, priority: $priority, createdAt: $createdAt, updatedAt: $updatedAt, client: $client, primaryLawyerId: $primaryLawyerId, primaryLawyer: $primaryLawyer, caseType: $caseType, defaultCourtId: $defaultCourtId, defaultCourt: $defaultCourt, openingDate: $openingDate, closingDate: $closingDate, outcomeSummary: $outcomeSummary, agreedFee: $agreedFee, team: $team)';
}


}

/// @nodoc
abstract mixin class _$LegalCaseCopyWith<$Res> implements $LegalCaseCopyWith<$Res> {
  factory _$LegalCaseCopyWith(_LegalCase value, $Res Function(_LegalCase) _then) = __$LegalCaseCopyWithImpl;
@override @useResult
$Res call({
 String id, String tenantId, String caseNumber,@JsonKey(unknownEnumValue: CaseStatus.unknown) CaseStatus status, String clientId, String caseTypeId,@JsonKey(unknownEnumValue: CasePriority.unknown) CasePriority priority, DateTime createdAt, DateTime updatedAt, Client client, String? primaryLawyerId, User? primaryLawyer, CaseTypeLookup? caseType, String? defaultCourtId, Court? defaultCourt, DateTime? openingDate, DateTime? closingDate, String? outcomeSummary, double? agreedFee, List<CaseTeamMember> team
});


@override $ClientCopyWith<$Res> get client;@override $UserCopyWith<$Res>? get primaryLawyer;@override $CaseTypeLookupCopyWith<$Res>? get caseType;@override $CourtCopyWith<$Res>? get defaultCourt;

}
/// @nodoc
class __$LegalCaseCopyWithImpl<$Res>
    implements _$LegalCaseCopyWith<$Res> {
  __$LegalCaseCopyWithImpl(this._self, this._then);

  final _LegalCase _self;
  final $Res Function(_LegalCase) _then;

/// Create a copy of LegalCase
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? tenantId = null,Object? caseNumber = null,Object? status = null,Object? clientId = null,Object? caseTypeId = null,Object? priority = null,Object? createdAt = null,Object? updatedAt = null,Object? client = null,Object? primaryLawyerId = freezed,Object? primaryLawyer = freezed,Object? caseType = freezed,Object? defaultCourtId = freezed,Object? defaultCourt = freezed,Object? openingDate = freezed,Object? closingDate = freezed,Object? outcomeSummary = freezed,Object? agreedFee = freezed,Object? team = null,}) {
  return _then(_LegalCase(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,tenantId: null == tenantId ? _self.tenantId : tenantId // ignore: cast_nullable_to_non_nullable
as String,caseNumber: null == caseNumber ? _self.caseNumber : caseNumber // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as CaseStatus,clientId: null == clientId ? _self.clientId : clientId // ignore: cast_nullable_to_non_nullable
as String,caseTypeId: null == caseTypeId ? _self.caseTypeId : caseTypeId // ignore: cast_nullable_to_non_nullable
as String,priority: null == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as CasePriority,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,client: null == client ? _self.client : client // ignore: cast_nullable_to_non_nullable
as Client,primaryLawyerId: freezed == primaryLawyerId ? _self.primaryLawyerId : primaryLawyerId // ignore: cast_nullable_to_non_nullable
as String?,primaryLawyer: freezed == primaryLawyer ? _self.primaryLawyer : primaryLawyer // ignore: cast_nullable_to_non_nullable
as User?,caseType: freezed == caseType ? _self.caseType : caseType // ignore: cast_nullable_to_non_nullable
as CaseTypeLookup?,defaultCourtId: freezed == defaultCourtId ? _self.defaultCourtId : defaultCourtId // ignore: cast_nullable_to_non_nullable
as String?,defaultCourt: freezed == defaultCourt ? _self.defaultCourt : defaultCourt // ignore: cast_nullable_to_non_nullable
as Court?,openingDate: freezed == openingDate ? _self.openingDate : openingDate // ignore: cast_nullable_to_non_nullable
as DateTime?,closingDate: freezed == closingDate ? _self.closingDate : closingDate // ignore: cast_nullable_to_non_nullable
as DateTime?,outcomeSummary: freezed == outcomeSummary ? _self.outcomeSummary : outcomeSummary // ignore: cast_nullable_to_non_nullable
as String?,agreedFee: freezed == agreedFee ? _self.agreedFee : agreedFee // ignore: cast_nullable_to_non_nullable
as double?,team: null == team ? _self._team : team // ignore: cast_nullable_to_non_nullable
as List<CaseTeamMember>,
  ));
}

/// Create a copy of LegalCase
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ClientCopyWith<$Res> get client {
  
  return $ClientCopyWith<$Res>(_self.client, (value) {
    return _then(_self.copyWith(client: value));
  });
}/// Create a copy of LegalCase
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserCopyWith<$Res>? get primaryLawyer {
    if (_self.primaryLawyer == null) {
    return null;
  }

  return $UserCopyWith<$Res>(_self.primaryLawyer!, (value) {
    return _then(_self.copyWith(primaryLawyer: value));
  });
}/// Create a copy of LegalCase
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
}/// Create a copy of LegalCase
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CourtCopyWith<$Res>? get defaultCourt {
    if (_self.defaultCourt == null) {
    return null;
  }

  return $CourtCopyWith<$Res>(_self.defaultCourt!, (value) {
    return _then(_self.copyWith(defaultCourt: value));
  });
}
}

// dart format on
