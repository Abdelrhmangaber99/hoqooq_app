// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'update_client_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UpdateClientRequest {

@JsonKey(includeIfNull: false) String? get clientCode;@JsonKey(includeIfNull: false) ClientType? get type;@JsonKey(includeIfNull: false) String? get fullName;@JsonKey(includeIfNull: false) String? get nationalId;@JsonKey(includeIfNull: false) String? get commercialReg;@JsonKey(includeIfNull: false) List<String>? get emails;@JsonKey(includeIfNull: false) List<String>? get phones;@JsonKey(includeIfNull: false) List<String>? get addresses;
/// Create a copy of UpdateClientRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UpdateClientRequestCopyWith<UpdateClientRequest> get copyWith => _$UpdateClientRequestCopyWithImpl<UpdateClientRequest>(this as UpdateClientRequest, _$identity);

  /// Serializes this UpdateClientRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpdateClientRequest&&(identical(other.clientCode, clientCode) || other.clientCode == clientCode)&&(identical(other.type, type) || other.type == type)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.nationalId, nationalId) || other.nationalId == nationalId)&&(identical(other.commercialReg, commercialReg) || other.commercialReg == commercialReg)&&const DeepCollectionEquality().equals(other.emails, emails)&&const DeepCollectionEquality().equals(other.phones, phones)&&const DeepCollectionEquality().equals(other.addresses, addresses));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,clientCode,type,fullName,nationalId,commercialReg,const DeepCollectionEquality().hash(emails),const DeepCollectionEquality().hash(phones),const DeepCollectionEquality().hash(addresses));

@override
String toString() {
  return 'UpdateClientRequest(clientCode: $clientCode, type: $type, fullName: $fullName, nationalId: $nationalId, commercialReg: $commercialReg, emails: $emails, phones: $phones, addresses: $addresses)';
}


}

/// @nodoc
abstract mixin class $UpdateClientRequestCopyWith<$Res>  {
  factory $UpdateClientRequestCopyWith(UpdateClientRequest value, $Res Function(UpdateClientRequest) _then) = _$UpdateClientRequestCopyWithImpl;
@useResult
$Res call({
@JsonKey(includeIfNull: false) String? clientCode,@JsonKey(includeIfNull: false) ClientType? type,@JsonKey(includeIfNull: false) String? fullName,@JsonKey(includeIfNull: false) String? nationalId,@JsonKey(includeIfNull: false) String? commercialReg,@JsonKey(includeIfNull: false) List<String>? emails,@JsonKey(includeIfNull: false) List<String>? phones,@JsonKey(includeIfNull: false) List<String>? addresses
});




}
/// @nodoc
class _$UpdateClientRequestCopyWithImpl<$Res>
    implements $UpdateClientRequestCopyWith<$Res> {
  _$UpdateClientRequestCopyWithImpl(this._self, this._then);

  final UpdateClientRequest _self;
  final $Res Function(UpdateClientRequest) _then;

/// Create a copy of UpdateClientRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? clientCode = freezed,Object? type = freezed,Object? fullName = freezed,Object? nationalId = freezed,Object? commercialReg = freezed,Object? emails = freezed,Object? phones = freezed,Object? addresses = freezed,}) {
  return _then(_self.copyWith(
clientCode: freezed == clientCode ? _self.clientCode : clientCode // ignore: cast_nullable_to_non_nullable
as String?,type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ClientType?,fullName: freezed == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String?,nationalId: freezed == nationalId ? _self.nationalId : nationalId // ignore: cast_nullable_to_non_nullable
as String?,commercialReg: freezed == commercialReg ? _self.commercialReg : commercialReg // ignore: cast_nullable_to_non_nullable
as String?,emails: freezed == emails ? _self.emails : emails // ignore: cast_nullable_to_non_nullable
as List<String>?,phones: freezed == phones ? _self.phones : phones // ignore: cast_nullable_to_non_nullable
as List<String>?,addresses: freezed == addresses ? _self.addresses : addresses // ignore: cast_nullable_to_non_nullable
as List<String>?,
  ));
}

}


/// Adds pattern-matching-related methods to [UpdateClientRequest].
extension UpdateClientRequestPatterns on UpdateClientRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UpdateClientRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UpdateClientRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UpdateClientRequest value)  $default,){
final _that = this;
switch (_that) {
case _UpdateClientRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UpdateClientRequest value)?  $default,){
final _that = this;
switch (_that) {
case _UpdateClientRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(includeIfNull: false)  String? clientCode, @JsonKey(includeIfNull: false)  ClientType? type, @JsonKey(includeIfNull: false)  String? fullName, @JsonKey(includeIfNull: false)  String? nationalId, @JsonKey(includeIfNull: false)  String? commercialReg, @JsonKey(includeIfNull: false)  List<String>? emails, @JsonKey(includeIfNull: false)  List<String>? phones, @JsonKey(includeIfNull: false)  List<String>? addresses)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UpdateClientRequest() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(includeIfNull: false)  String? clientCode, @JsonKey(includeIfNull: false)  ClientType? type, @JsonKey(includeIfNull: false)  String? fullName, @JsonKey(includeIfNull: false)  String? nationalId, @JsonKey(includeIfNull: false)  String? commercialReg, @JsonKey(includeIfNull: false)  List<String>? emails, @JsonKey(includeIfNull: false)  List<String>? phones, @JsonKey(includeIfNull: false)  List<String>? addresses)  $default,) {final _that = this;
switch (_that) {
case _UpdateClientRequest():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(includeIfNull: false)  String? clientCode, @JsonKey(includeIfNull: false)  ClientType? type, @JsonKey(includeIfNull: false)  String? fullName, @JsonKey(includeIfNull: false)  String? nationalId, @JsonKey(includeIfNull: false)  String? commercialReg, @JsonKey(includeIfNull: false)  List<String>? emails, @JsonKey(includeIfNull: false)  List<String>? phones, @JsonKey(includeIfNull: false)  List<String>? addresses)?  $default,) {final _that = this;
switch (_that) {
case _UpdateClientRequest() when $default != null:
return $default(_that.clientCode,_that.type,_that.fullName,_that.nationalId,_that.commercialReg,_that.emails,_that.phones,_that.addresses);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UpdateClientRequest implements UpdateClientRequest {
  const _UpdateClientRequest({@JsonKey(includeIfNull: false) this.clientCode, @JsonKey(includeIfNull: false) this.type, @JsonKey(includeIfNull: false) this.fullName, @JsonKey(includeIfNull: false) this.nationalId, @JsonKey(includeIfNull: false) this.commercialReg, @JsonKey(includeIfNull: false) final  List<String>? emails, @JsonKey(includeIfNull: false) final  List<String>? phones, @JsonKey(includeIfNull: false) final  List<String>? addresses}): _emails = emails,_phones = phones,_addresses = addresses;
  factory _UpdateClientRequest.fromJson(Map<String, dynamic> json) => _$UpdateClientRequestFromJson(json);

@override@JsonKey(includeIfNull: false) final  String? clientCode;
@override@JsonKey(includeIfNull: false) final  ClientType? type;
@override@JsonKey(includeIfNull: false) final  String? fullName;
@override@JsonKey(includeIfNull: false) final  String? nationalId;
@override@JsonKey(includeIfNull: false) final  String? commercialReg;
 final  List<String>? _emails;
@override@JsonKey(includeIfNull: false) List<String>? get emails {
  final value = _emails;
  if (value == null) return null;
  if (_emails is EqualUnmodifiableListView) return _emails;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

 final  List<String>? _phones;
@override@JsonKey(includeIfNull: false) List<String>? get phones {
  final value = _phones;
  if (value == null) return null;
  if (_phones is EqualUnmodifiableListView) return _phones;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

 final  List<String>? _addresses;
@override@JsonKey(includeIfNull: false) List<String>? get addresses {
  final value = _addresses;
  if (value == null) return null;
  if (_addresses is EqualUnmodifiableListView) return _addresses;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of UpdateClientRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UpdateClientRequestCopyWith<_UpdateClientRequest> get copyWith => __$UpdateClientRequestCopyWithImpl<_UpdateClientRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UpdateClientRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpdateClientRequest&&(identical(other.clientCode, clientCode) || other.clientCode == clientCode)&&(identical(other.type, type) || other.type == type)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.nationalId, nationalId) || other.nationalId == nationalId)&&(identical(other.commercialReg, commercialReg) || other.commercialReg == commercialReg)&&const DeepCollectionEquality().equals(other._emails, _emails)&&const DeepCollectionEquality().equals(other._phones, _phones)&&const DeepCollectionEquality().equals(other._addresses, _addresses));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,clientCode,type,fullName,nationalId,commercialReg,const DeepCollectionEquality().hash(_emails),const DeepCollectionEquality().hash(_phones),const DeepCollectionEquality().hash(_addresses));

@override
String toString() {
  return 'UpdateClientRequest(clientCode: $clientCode, type: $type, fullName: $fullName, nationalId: $nationalId, commercialReg: $commercialReg, emails: $emails, phones: $phones, addresses: $addresses)';
}


}

/// @nodoc
abstract mixin class _$UpdateClientRequestCopyWith<$Res> implements $UpdateClientRequestCopyWith<$Res> {
  factory _$UpdateClientRequestCopyWith(_UpdateClientRequest value, $Res Function(_UpdateClientRequest) _then) = __$UpdateClientRequestCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(includeIfNull: false) String? clientCode,@JsonKey(includeIfNull: false) ClientType? type,@JsonKey(includeIfNull: false) String? fullName,@JsonKey(includeIfNull: false) String? nationalId,@JsonKey(includeIfNull: false) String? commercialReg,@JsonKey(includeIfNull: false) List<String>? emails,@JsonKey(includeIfNull: false) List<String>? phones,@JsonKey(includeIfNull: false) List<String>? addresses
});




}
/// @nodoc
class __$UpdateClientRequestCopyWithImpl<$Res>
    implements _$UpdateClientRequestCopyWith<$Res> {
  __$UpdateClientRequestCopyWithImpl(this._self, this._then);

  final _UpdateClientRequest _self;
  final $Res Function(_UpdateClientRequest) _then;

/// Create a copy of UpdateClientRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? clientCode = freezed,Object? type = freezed,Object? fullName = freezed,Object? nationalId = freezed,Object? commercialReg = freezed,Object? emails = freezed,Object? phones = freezed,Object? addresses = freezed,}) {
  return _then(_UpdateClientRequest(
clientCode: freezed == clientCode ? _self.clientCode : clientCode // ignore: cast_nullable_to_non_nullable
as String?,type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ClientType?,fullName: freezed == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String?,nationalId: freezed == nationalId ? _self.nationalId : nationalId // ignore: cast_nullable_to_non_nullable
as String?,commercialReg: freezed == commercialReg ? _self.commercialReg : commercialReg // ignore: cast_nullable_to_non_nullable
as String?,emails: freezed == emails ? _self._emails : emails // ignore: cast_nullable_to_non_nullable
as List<String>?,phones: freezed == phones ? _self._phones : phones // ignore: cast_nullable_to_non_nullable
as List<String>?,addresses: freezed == addresses ? _self._addresses : addresses // ignore: cast_nullable_to_non_nullable
as List<String>?,
  ));
}


}

// dart format on
