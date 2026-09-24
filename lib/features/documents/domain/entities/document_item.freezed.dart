// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'document_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DocumentItem {

 String get id; String get title; String? get description; String get fileType; int get sizeBytes; String? get caseId;@JsonKey(name: 'case') CaseSummary? get caseSummary; String? get folderId; String? get categoryId; String? get linkedEntityType; String? get linkedEntityId; String get uploadedById; int get versionNumber; String? get sha256; DateTime get createdAt; DateTime get updatedAt;
/// Create a copy of DocumentItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DocumentItemCopyWith<DocumentItem> get copyWith => _$DocumentItemCopyWithImpl<DocumentItem>(this as DocumentItem, _$identity);

  /// Serializes this DocumentItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DocumentItem&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.fileType, fileType) || other.fileType == fileType)&&(identical(other.sizeBytes, sizeBytes) || other.sizeBytes == sizeBytes)&&(identical(other.caseId, caseId) || other.caseId == caseId)&&(identical(other.caseSummary, caseSummary) || other.caseSummary == caseSummary)&&(identical(other.folderId, folderId) || other.folderId == folderId)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.linkedEntityType, linkedEntityType) || other.linkedEntityType == linkedEntityType)&&(identical(other.linkedEntityId, linkedEntityId) || other.linkedEntityId == linkedEntityId)&&(identical(other.uploadedById, uploadedById) || other.uploadedById == uploadedById)&&(identical(other.versionNumber, versionNumber) || other.versionNumber == versionNumber)&&(identical(other.sha256, sha256) || other.sha256 == sha256)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,description,fileType,sizeBytes,caseId,caseSummary,folderId,categoryId,linkedEntityType,linkedEntityId,uploadedById,versionNumber,sha256,createdAt,updatedAt);

@override
String toString() {
  return 'DocumentItem(id: $id, title: $title, description: $description, fileType: $fileType, sizeBytes: $sizeBytes, caseId: $caseId, caseSummary: $caseSummary, folderId: $folderId, categoryId: $categoryId, linkedEntityType: $linkedEntityType, linkedEntityId: $linkedEntityId, uploadedById: $uploadedById, versionNumber: $versionNumber, sha256: $sha256, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $DocumentItemCopyWith<$Res>  {
  factory $DocumentItemCopyWith(DocumentItem value, $Res Function(DocumentItem) _then) = _$DocumentItemCopyWithImpl;
@useResult
$Res call({
 String id, String title, String? description, String fileType, int sizeBytes, String? caseId,@JsonKey(name: 'case') CaseSummary? caseSummary, String? folderId, String? categoryId, String? linkedEntityType, String? linkedEntityId, String uploadedById, int versionNumber, String? sha256, DateTime createdAt, DateTime updatedAt
});


$CaseSummaryCopyWith<$Res>? get caseSummary;

}
/// @nodoc
class _$DocumentItemCopyWithImpl<$Res>
    implements $DocumentItemCopyWith<$Res> {
  _$DocumentItemCopyWithImpl(this._self, this._then);

  final DocumentItem _self;
  final $Res Function(DocumentItem) _then;

/// Create a copy of DocumentItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? description = freezed,Object? fileType = null,Object? sizeBytes = null,Object? caseId = freezed,Object? caseSummary = freezed,Object? folderId = freezed,Object? categoryId = freezed,Object? linkedEntityType = freezed,Object? linkedEntityId = freezed,Object? uploadedById = null,Object? versionNumber = null,Object? sha256 = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,fileType: null == fileType ? _self.fileType : fileType // ignore: cast_nullable_to_non_nullable
as String,sizeBytes: null == sizeBytes ? _self.sizeBytes : sizeBytes // ignore: cast_nullable_to_non_nullable
as int,caseId: freezed == caseId ? _self.caseId : caseId // ignore: cast_nullable_to_non_nullable
as String?,caseSummary: freezed == caseSummary ? _self.caseSummary : caseSummary // ignore: cast_nullable_to_non_nullable
as CaseSummary?,folderId: freezed == folderId ? _self.folderId : folderId // ignore: cast_nullable_to_non_nullable
as String?,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String?,linkedEntityType: freezed == linkedEntityType ? _self.linkedEntityType : linkedEntityType // ignore: cast_nullable_to_non_nullable
as String?,linkedEntityId: freezed == linkedEntityId ? _self.linkedEntityId : linkedEntityId // ignore: cast_nullable_to_non_nullable
as String?,uploadedById: null == uploadedById ? _self.uploadedById : uploadedById // ignore: cast_nullable_to_non_nullable
as String,versionNumber: null == versionNumber ? _self.versionNumber : versionNumber // ignore: cast_nullable_to_non_nullable
as int,sha256: freezed == sha256 ? _self.sha256 : sha256 // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}
/// Create a copy of DocumentItem
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


/// Adds pattern-matching-related methods to [DocumentItem].
extension DocumentItemPatterns on DocumentItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DocumentItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DocumentItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DocumentItem value)  $default,){
final _that = this;
switch (_that) {
case _DocumentItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DocumentItem value)?  $default,){
final _that = this;
switch (_that) {
case _DocumentItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String? description,  String fileType,  int sizeBytes,  String? caseId, @JsonKey(name: 'case')  CaseSummary? caseSummary,  String? folderId,  String? categoryId,  String? linkedEntityType,  String? linkedEntityId,  String uploadedById,  int versionNumber,  String? sha256,  DateTime createdAt,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DocumentItem() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.fileType,_that.sizeBytes,_that.caseId,_that.caseSummary,_that.folderId,_that.categoryId,_that.linkedEntityType,_that.linkedEntityId,_that.uploadedById,_that.versionNumber,_that.sha256,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String? description,  String fileType,  int sizeBytes,  String? caseId, @JsonKey(name: 'case')  CaseSummary? caseSummary,  String? folderId,  String? categoryId,  String? linkedEntityType,  String? linkedEntityId,  String uploadedById,  int versionNumber,  String? sha256,  DateTime createdAt,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _DocumentItem():
return $default(_that.id,_that.title,_that.description,_that.fileType,_that.sizeBytes,_that.caseId,_that.caseSummary,_that.folderId,_that.categoryId,_that.linkedEntityType,_that.linkedEntityId,_that.uploadedById,_that.versionNumber,_that.sha256,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String? description,  String fileType,  int sizeBytes,  String? caseId, @JsonKey(name: 'case')  CaseSummary? caseSummary,  String? folderId,  String? categoryId,  String? linkedEntityType,  String? linkedEntityId,  String uploadedById,  int versionNumber,  String? sha256,  DateTime createdAt,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _DocumentItem() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.fileType,_that.sizeBytes,_that.caseId,_that.caseSummary,_that.folderId,_that.categoryId,_that.linkedEntityType,_that.linkedEntityId,_that.uploadedById,_that.versionNumber,_that.sha256,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DocumentItem implements DocumentItem {
  const _DocumentItem({required this.id, required this.title, this.description, required this.fileType, required this.sizeBytes, this.caseId, @JsonKey(name: 'case') this.caseSummary, this.folderId, this.categoryId, this.linkedEntityType, this.linkedEntityId, required this.uploadedById, required this.versionNumber, this.sha256, required this.createdAt, required this.updatedAt});
  factory _DocumentItem.fromJson(Map<String, dynamic> json) => _$DocumentItemFromJson(json);

@override final  String id;
@override final  String title;
@override final  String? description;
@override final  String fileType;
@override final  int sizeBytes;
@override final  String? caseId;
@override@JsonKey(name: 'case') final  CaseSummary? caseSummary;
@override final  String? folderId;
@override final  String? categoryId;
@override final  String? linkedEntityType;
@override final  String? linkedEntityId;
@override final  String uploadedById;
@override final  int versionNumber;
@override final  String? sha256;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;

/// Create a copy of DocumentItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DocumentItemCopyWith<_DocumentItem> get copyWith => __$DocumentItemCopyWithImpl<_DocumentItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DocumentItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DocumentItem&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.fileType, fileType) || other.fileType == fileType)&&(identical(other.sizeBytes, sizeBytes) || other.sizeBytes == sizeBytes)&&(identical(other.caseId, caseId) || other.caseId == caseId)&&(identical(other.caseSummary, caseSummary) || other.caseSummary == caseSummary)&&(identical(other.folderId, folderId) || other.folderId == folderId)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.linkedEntityType, linkedEntityType) || other.linkedEntityType == linkedEntityType)&&(identical(other.linkedEntityId, linkedEntityId) || other.linkedEntityId == linkedEntityId)&&(identical(other.uploadedById, uploadedById) || other.uploadedById == uploadedById)&&(identical(other.versionNumber, versionNumber) || other.versionNumber == versionNumber)&&(identical(other.sha256, sha256) || other.sha256 == sha256)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,description,fileType,sizeBytes,caseId,caseSummary,folderId,categoryId,linkedEntityType,linkedEntityId,uploadedById,versionNumber,sha256,createdAt,updatedAt);

@override
String toString() {
  return 'DocumentItem(id: $id, title: $title, description: $description, fileType: $fileType, sizeBytes: $sizeBytes, caseId: $caseId, caseSummary: $caseSummary, folderId: $folderId, categoryId: $categoryId, linkedEntityType: $linkedEntityType, linkedEntityId: $linkedEntityId, uploadedById: $uploadedById, versionNumber: $versionNumber, sha256: $sha256, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$DocumentItemCopyWith<$Res> implements $DocumentItemCopyWith<$Res> {
  factory _$DocumentItemCopyWith(_DocumentItem value, $Res Function(_DocumentItem) _then) = __$DocumentItemCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String? description, String fileType, int sizeBytes, String? caseId,@JsonKey(name: 'case') CaseSummary? caseSummary, String? folderId, String? categoryId, String? linkedEntityType, String? linkedEntityId, String uploadedById, int versionNumber, String? sha256, DateTime createdAt, DateTime updatedAt
});


@override $CaseSummaryCopyWith<$Res>? get caseSummary;

}
/// @nodoc
class __$DocumentItemCopyWithImpl<$Res>
    implements _$DocumentItemCopyWith<$Res> {
  __$DocumentItemCopyWithImpl(this._self, this._then);

  final _DocumentItem _self;
  final $Res Function(_DocumentItem) _then;

/// Create a copy of DocumentItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? description = freezed,Object? fileType = null,Object? sizeBytes = null,Object? caseId = freezed,Object? caseSummary = freezed,Object? folderId = freezed,Object? categoryId = freezed,Object? linkedEntityType = freezed,Object? linkedEntityId = freezed,Object? uploadedById = null,Object? versionNumber = null,Object? sha256 = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_DocumentItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,fileType: null == fileType ? _self.fileType : fileType // ignore: cast_nullable_to_non_nullable
as String,sizeBytes: null == sizeBytes ? _self.sizeBytes : sizeBytes // ignore: cast_nullable_to_non_nullable
as int,caseId: freezed == caseId ? _self.caseId : caseId // ignore: cast_nullable_to_non_nullable
as String?,caseSummary: freezed == caseSummary ? _self.caseSummary : caseSummary // ignore: cast_nullable_to_non_nullable
as CaseSummary?,folderId: freezed == folderId ? _self.folderId : folderId // ignore: cast_nullable_to_non_nullable
as String?,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String?,linkedEntityType: freezed == linkedEntityType ? _self.linkedEntityType : linkedEntityType // ignore: cast_nullable_to_non_nullable
as String?,linkedEntityId: freezed == linkedEntityId ? _self.linkedEntityId : linkedEntityId // ignore: cast_nullable_to_non_nullable
as String?,uploadedById: null == uploadedById ? _self.uploadedById : uploadedById // ignore: cast_nullable_to_non_nullable
as String,versionNumber: null == versionNumber ? _self.versionNumber : versionNumber // ignore: cast_nullable_to_non_nullable
as int,sha256: freezed == sha256 ? _self.sha256 : sha256 // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

/// Create a copy of DocumentItem
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

// dart format on
