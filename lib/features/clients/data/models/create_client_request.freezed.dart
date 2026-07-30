// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'create_client_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CreateClientRequest {

 String get clientCode; ClientType get type; String get fullName; String? get nationalId; String? get commercialReg; List<String>? get emails; List<String>? get phones; List<String>? get addresses;
/// Create a copy of CreateClientRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreateClientRequestCopyWith<CreateClientRequest> get copyWith => _$CreateClientRequestCopyWithImpl<CreateClientRequest>(this as CreateClientRequest, _$identity);

  /// Serializes this CreateClientRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateClientRequest&&(identical(other.clientCode, clientCode) || other.clientCode == clientCode)&&(identical(other.type, type) || other.type == type)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.nationalId, nationalId) || other.nationalId == nationalId)&&(identical(other.commercialReg, commercialReg) || other.commercialReg == commercialReg)&&const DeepCollectionEquality().equals(other.emails, emails)&&const DeepCollectionEquality().equals(other.phones, phones)&&const DeepCollectionEquality().equals(other.addresses, addresses));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,clientCode,type,fullName,nationalId,commercialReg,const DeepCollectionEquality().hash(emails),const DeepCollectionEquality().hash(phones),const DeepCollectionEquality().hash(addresses));

@override
String toString() {
  return 'CreateClientRequest(clientCode: $clientCode, type: $type, fullName: $fullName, nationalId: $nationalId, commercialReg: $commercialReg, emails: $emails, phones: $phones, addresses: $addresses)';
}


}

/// @nodoc
abstract mixin class $CreateClientRequestCopyWith<$Res>  {
  factory $CreateClientRequestCopyWith(CreateClientRequest value, $Res Function(CreateClientRequest) _then) = _$CreateClientRequestCopyWithImpl;
@useResult
$Res call({
 String clientCode, ClientType type, String fullName, String? nationalId, String? commercialReg, List<String>? emails, List<String>? phones, List<String>? addresses
});




}
/// @nodoc
class _$CreateClientRequestCopyWithImpl<$Res>
    implements $CreateClientRequestCopyWith<$Res> {
  _$CreateClientRequestCopyWithImpl(this._self, this._then);

  final CreateClientRequest _self;
  final $Res Function(CreateClientRequest) _then;

/// Create a copy of CreateClientRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? clientCode = null,Object? type = null,Object? fullName = null,Object? nationalId = freezed,Object? commercialReg = freezed,Object? emails = freezed,Object? phones = freezed,Object? addresses = freezed,}) {
  return _then(_self.copyWith(
clientCode: null == clientCode ? _self.clientCode : clientCode // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ClientType,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,nationalId: freezed == nationalId ? _self.nationalId : nationalId // ignore: cast_nullable_to_non_nullable
as String?,commercialReg: freezed == commercialReg ? _self.commercialReg : commercialReg // ignore: cast_nullable_to_non_nullable
as String?,emails: freezed == emails ? _self.emails : emails // ignore: cast_nullable_to_non_nullable
as List<String>?,phones: freezed == phones ? _self.phones : phones // ignore: cast_nullable_to_non_nullable
as List<String>?,addresses: freezed == addresses ? _self.addresses : addresses // ignore: cast_nullable_to_non_nullable
as List<String>?,
  ));
}

}


/// Adds pattern-matching-related methods to [CreateClientRequest].
extension CreateClientRequestPatterns on CreateClientRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreateClientRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreateClientRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreateClientRequest value)  $default,){
final _that = this;
switch (_that) {
case _CreateClientRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreateClientRequest value)?  $default,){
final _that = this;
switch (_that) {
case _CreateClientRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String clientCode,  ClientType type,  String fullName,  String? nationalId,  String? commercialReg,  List<String>? emails,  List<String>? phones,  List<String>? addresses)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreateClientRequest() when $default != null:
return $default(_that.clientCode,_that.type,_that.fullName,_that.nationalId,_that.commercialReg,_that.emails,_that.phones,_that.addresses);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String clientCode,  ClientType type,  String fullName,  String? nationalId,  String? commercialReg,  List<String>? emails,  List<String>? phones,  List<String>? addresses)  $default,) {final _that = this;
switch (_that) {
case _CreateClientRequest():
return $default(_that.clientCode,_that.type,_that.fullName,_that.nationalId,_that.commercialReg,_that.emails,_that.phones,_that.addresses);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String clientCode,  ClientType type,  String fullName,  String? nationalId,  String? commercialReg,  List<String>? emails,  List<String>? phones,  List<String>? addresses)?  $default,) {final _that = this;
switch (_that) {
case _CreateClientRequest() when $default != null:
return $default(_that.clientCode,_that.type,_that.fullName,_that.nationalId,_that.commercialReg,_that.emails,_that.phones,_that.addresses);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CreateClientRequest implements CreateClientRequest {
  const _CreateClientRequest({required this.clientCode, required this.type, required this.fullName, this.nationalId, this.commercialReg, final  List<String>? emails, final  List<String>? phones, final  List<String>? addresses}): _emails = emails,_phones = phones,_addresses = addresses;
  factory _CreateClientRequest.fromJson(Map<String, dynamic> json) => _$CreateClientRequestFromJson(json);

@override final  String clientCode;
@override final  ClientType type;
@override final  String fullName;
@override final  String? nationalId;
@override final  String? commercialReg;
 final  List<String>? _emails;
@override List<String>? get emails {
  final value = _emails;
  if (value == null) return null;
  if (_emails is EqualUnmodifiableListView) return _emails;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

 final  List<String>? _phones;
@override List<String>? get phones {
  final value = _phones;
  if (value == null) return null;
  if (_phones is EqualUnmodifiableListView) return _phones;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

 final  List<String>? _addresses;
@override List<String>? get addresses {
  final value = _addresses;
  if (value == null) return null;
  if (_addresses is EqualUnmodifiableListView) return _addresses;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of CreateClientRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreateClientRequestCopyWith<_CreateClientRequest> get copyWith => __$CreateClientRequestCopyWithImpl<_CreateClientRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CreateClientRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreateClientRequest&&(identical(other.clientCode, clientCode) || other.clientCode == clientCode)&&(identical(other.type, type) || other.type == type)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.nationalId, nationalId) || other.nationalId == nationalId)&&(identical(other.commercialReg, commercialReg) || other.commercialReg == commercialReg)&&const DeepCollectionEquality().equals(other._emails, _emails)&&const DeepCollectionEquality().equals(other._phones, _phones)&&const DeepCollectionEquality().equals(other._addresses, _addresses));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,clientCode,type,fullName,nationalId,commercialReg,const DeepCollectionEquality().hash(_emails),const DeepCollectionEquality().hash(_phones),const DeepCollectionEquality().hash(_addresses));

@override
String toString() {
  return 'CreateClientRequest(clientCode: $clientCode, type: $type, fullName: $fullName, nationalId: $nationalId, commercialReg: $commercialReg, emails: $emails, phones: $phones, addresses: $addresses)';
}


}

/// @nodoc
abstract mixin class _$CreateClientRequestCopyWith<$Res> implements $CreateClientRequestCopyWith<$Res> {
  factory _$CreateClientRequestCopyWith(_CreateClientRequest value, $Res Function(_CreateClientRequest) _then) = __$CreateClientRequestCopyWithImpl;
@override @useResult
$Res call({
 String clientCode, ClientType type, String fullName, String? nationalId, String? commercialReg, List<String>? emails, List<String>? phones, List<String>? addresses
});




}
/// @nodoc
class __$CreateClientRequestCopyWithImpl<$Res>
    implements _$CreateClientRequestCopyWith<$Res> {
  __$CreateClientRequestCopyWithImpl(this._self, this._then);

  final _CreateClientRequest _self;
  final $Res Function(_CreateClientRequest) _then;

/// Create a copy of CreateClientRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? clientCode = null,Object? type = null,Object? fullName = null,Object? nationalId = freezed,Object? commercialReg = freezed,Object? emails = freezed,Object? phones = freezed,Object? addresses = freezed,}) {
  return _then(_CreateClientRequest(
clientCode: null == clientCode ? _self.clientCode : clientCode // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ClientType,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,nationalId: freezed == nationalId ? _self.nationalId : nationalId // ignore: cast_nullable_to_non_nullable
as String?,commercialReg: freezed == commercialReg ? _self.commercialReg : commercialReg // ignore: cast_nullable_to_non_nullable
as String?,emails: freezed == emails ? _self._emails : emails // ignore: cast_nullable_to_non_nullable
as List<String>?,phones: freezed == phones ? _self._phones : phones // ignore: cast_nullable_to_non_nullable
as List<String>?,addresses: freezed == addresses ? _self._addresses : addresses // ignore: cast_nullable_to_non_nullable
as List<String>?,
  ));
}


}

// dart format on
