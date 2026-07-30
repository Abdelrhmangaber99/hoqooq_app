// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'client.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Client {

 String get id; String get tenantId; String get clientCode;@JsonKey(unknownEnumValue: ClientType.unknown) ClientType get type; String get fullName;@JsonKey(unknownEnumValue: ClientStatus.unknown) ClientStatus get status; DateTime get createdAt; DateTime get updatedAt; String? get nationalId; String? get commercialReg; List<String> get emails; List<String> get phones; List<String> get addresses;
/// Create a copy of Client
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClientCopyWith<Client> get copyWith => _$ClientCopyWithImpl<Client>(this as Client, _$identity);

  /// Serializes this Client to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Client&&(identical(other.id, id) || other.id == id)&&(identical(other.tenantId, tenantId) || other.tenantId == tenantId)&&(identical(other.clientCode, clientCode) || other.clientCode == clientCode)&&(identical(other.type, type) || other.type == type)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.nationalId, nationalId) || other.nationalId == nationalId)&&(identical(other.commercialReg, commercialReg) || other.commercialReg == commercialReg)&&const DeepCollectionEquality().equals(other.emails, emails)&&const DeepCollectionEquality().equals(other.phones, phones)&&const DeepCollectionEquality().equals(other.addresses, addresses));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,tenantId,clientCode,type,fullName,status,createdAt,updatedAt,nationalId,commercialReg,const DeepCollectionEquality().hash(emails),const DeepCollectionEquality().hash(phones),const DeepCollectionEquality().hash(addresses));

@override
String toString() {
  return 'Client(id: $id, tenantId: $tenantId, clientCode: $clientCode, type: $type, fullName: $fullName, status: $status, createdAt: $createdAt, updatedAt: $updatedAt, nationalId: $nationalId, commercialReg: $commercialReg, emails: $emails, phones: $phones, addresses: $addresses)';
}


}

/// @nodoc
abstract mixin class $ClientCopyWith<$Res>  {
  factory $ClientCopyWith(Client value, $Res Function(Client) _then) = _$ClientCopyWithImpl;
@useResult
$Res call({
 String id, String tenantId, String clientCode,@JsonKey(unknownEnumValue: ClientType.unknown) ClientType type, String fullName,@JsonKey(unknownEnumValue: ClientStatus.unknown) ClientStatus status, DateTime createdAt, DateTime updatedAt, String? nationalId, String? commercialReg, List<String> emails, List<String> phones, List<String> addresses
});




}
/// @nodoc
class _$ClientCopyWithImpl<$Res>
    implements $ClientCopyWith<$Res> {
  _$ClientCopyWithImpl(this._self, this._then);

  final Client _self;
  final $Res Function(Client) _then;

/// Create a copy of Client
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? tenantId = null,Object? clientCode = null,Object? type = null,Object? fullName = null,Object? status = null,Object? createdAt = null,Object? updatedAt = null,Object? nationalId = freezed,Object? commercialReg = freezed,Object? emails = null,Object? phones = null,Object? addresses = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,tenantId: null == tenantId ? _self.tenantId : tenantId // ignore: cast_nullable_to_non_nullable
as String,clientCode: null == clientCode ? _self.clientCode : clientCode // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ClientType,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ClientStatus,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,nationalId: freezed == nationalId ? _self.nationalId : nationalId // ignore: cast_nullable_to_non_nullable
as String?,commercialReg: freezed == commercialReg ? _self.commercialReg : commercialReg // ignore: cast_nullable_to_non_nullable
as String?,emails: null == emails ? _self.emails : emails // ignore: cast_nullable_to_non_nullable
as List<String>,phones: null == phones ? _self.phones : phones // ignore: cast_nullable_to_non_nullable
as List<String>,addresses: null == addresses ? _self.addresses : addresses // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [Client].
extension ClientPatterns on Client {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Client value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Client() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Client value)  $default,){
final _that = this;
switch (_that) {
case _Client():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Client value)?  $default,){
final _that = this;
switch (_that) {
case _Client() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String tenantId,  String clientCode, @JsonKey(unknownEnumValue: ClientType.unknown)  ClientType type,  String fullName, @JsonKey(unknownEnumValue: ClientStatus.unknown)  ClientStatus status,  DateTime createdAt,  DateTime updatedAt,  String? nationalId,  String? commercialReg,  List<String> emails,  List<String> phones,  List<String> addresses)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Client() when $default != null:
return $default(_that.id,_that.tenantId,_that.clientCode,_that.type,_that.fullName,_that.status,_that.createdAt,_that.updatedAt,_that.nationalId,_that.commercialReg,_that.emails,_that.phones,_that.addresses);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String tenantId,  String clientCode, @JsonKey(unknownEnumValue: ClientType.unknown)  ClientType type,  String fullName, @JsonKey(unknownEnumValue: ClientStatus.unknown)  ClientStatus status,  DateTime createdAt,  DateTime updatedAt,  String? nationalId,  String? commercialReg,  List<String> emails,  List<String> phones,  List<String> addresses)  $default,) {final _that = this;
switch (_that) {
case _Client():
return $default(_that.id,_that.tenantId,_that.clientCode,_that.type,_that.fullName,_that.status,_that.createdAt,_that.updatedAt,_that.nationalId,_that.commercialReg,_that.emails,_that.phones,_that.addresses);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String tenantId,  String clientCode, @JsonKey(unknownEnumValue: ClientType.unknown)  ClientType type,  String fullName, @JsonKey(unknownEnumValue: ClientStatus.unknown)  ClientStatus status,  DateTime createdAt,  DateTime updatedAt,  String? nationalId,  String? commercialReg,  List<String> emails,  List<String> phones,  List<String> addresses)?  $default,) {final _that = this;
switch (_that) {
case _Client() when $default != null:
return $default(_that.id,_that.tenantId,_that.clientCode,_that.type,_that.fullName,_that.status,_that.createdAt,_that.updatedAt,_that.nationalId,_that.commercialReg,_that.emails,_that.phones,_that.addresses);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Client implements Client {
  const _Client({required this.id, required this.tenantId, required this.clientCode, @JsonKey(unknownEnumValue: ClientType.unknown) required this.type, required this.fullName, @JsonKey(unknownEnumValue: ClientStatus.unknown) required this.status, required this.createdAt, required this.updatedAt, this.nationalId, this.commercialReg, required final  List<String> emails, required final  List<String> phones, required final  List<String> addresses}): _emails = emails,_phones = phones,_addresses = addresses;
  factory _Client.fromJson(Map<String, dynamic> json) => _$ClientFromJson(json);

@override final  String id;
@override final  String tenantId;
@override final  String clientCode;
@override@JsonKey(unknownEnumValue: ClientType.unknown) final  ClientType type;
@override final  String fullName;
@override@JsonKey(unknownEnumValue: ClientStatus.unknown) final  ClientStatus status;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  String? nationalId;
@override final  String? commercialReg;
 final  List<String> _emails;
@override List<String> get emails {
  if (_emails is EqualUnmodifiableListView) return _emails;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_emails);
}

 final  List<String> _phones;
@override List<String> get phones {
  if (_phones is EqualUnmodifiableListView) return _phones;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_phones);
}

 final  List<String> _addresses;
@override List<String> get addresses {
  if (_addresses is EqualUnmodifiableListView) return _addresses;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_addresses);
}


/// Create a copy of Client
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ClientCopyWith<_Client> get copyWith => __$ClientCopyWithImpl<_Client>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ClientToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Client&&(identical(other.id, id) || other.id == id)&&(identical(other.tenantId, tenantId) || other.tenantId == tenantId)&&(identical(other.clientCode, clientCode) || other.clientCode == clientCode)&&(identical(other.type, type) || other.type == type)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.nationalId, nationalId) || other.nationalId == nationalId)&&(identical(other.commercialReg, commercialReg) || other.commercialReg == commercialReg)&&const DeepCollectionEquality().equals(other._emails, _emails)&&const DeepCollectionEquality().equals(other._phones, _phones)&&const DeepCollectionEquality().equals(other._addresses, _addresses));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,tenantId,clientCode,type,fullName,status,createdAt,updatedAt,nationalId,commercialReg,const DeepCollectionEquality().hash(_emails),const DeepCollectionEquality().hash(_phones),const DeepCollectionEquality().hash(_addresses));

@override
String toString() {
  return 'Client(id: $id, tenantId: $tenantId, clientCode: $clientCode, type: $type, fullName: $fullName, status: $status, createdAt: $createdAt, updatedAt: $updatedAt, nationalId: $nationalId, commercialReg: $commercialReg, emails: $emails, phones: $phones, addresses: $addresses)';
}


}

/// @nodoc
abstract mixin class _$ClientCopyWith<$Res> implements $ClientCopyWith<$Res> {
  factory _$ClientCopyWith(_Client value, $Res Function(_Client) _then) = __$ClientCopyWithImpl;
@override @useResult
$Res call({
 String id, String tenantId, String clientCode,@JsonKey(unknownEnumValue: ClientType.unknown) ClientType type, String fullName,@JsonKey(unknownEnumValue: ClientStatus.unknown) ClientStatus status, DateTime createdAt, DateTime updatedAt, String? nationalId, String? commercialReg, List<String> emails, List<String> phones, List<String> addresses
});




}
/// @nodoc
class __$ClientCopyWithImpl<$Res>
    implements _$ClientCopyWith<$Res> {
  __$ClientCopyWithImpl(this._self, this._then);

  final _Client _self;
  final $Res Function(_Client) _then;

/// Create a copy of Client
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? tenantId = null,Object? clientCode = null,Object? type = null,Object? fullName = null,Object? status = null,Object? createdAt = null,Object? updatedAt = null,Object? nationalId = freezed,Object? commercialReg = freezed,Object? emails = null,Object? phones = null,Object? addresses = null,}) {
  return _then(_Client(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,tenantId: null == tenantId ? _self.tenantId : tenantId // ignore: cast_nullable_to_non_nullable
as String,clientCode: null == clientCode ? _self.clientCode : clientCode // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ClientType,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ClientStatus,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,nationalId: freezed == nationalId ? _self.nationalId : nationalId // ignore: cast_nullable_to_non_nullable
as String?,commercialReg: freezed == commercialReg ? _self.commercialReg : commercialReg // ignore: cast_nullable_to_non_nullable
as String?,emails: null == emails ? _self._emails : emails // ignore: cast_nullable_to_non_nullable
as List<String>,phones: null == phones ? _self._phones : phones // ignore: cast_nullable_to_non_nullable
as List<String>,addresses: null == addresses ? _self._addresses : addresses // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on
