// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'document_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DocumentItem _$DocumentItemFromJson(Map<String, dynamic> json) =>
    _DocumentItem(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      fileType: json['fileType'] as String,
      sizeBytes: (json['sizeBytes'] as num).toInt(),
      caseId: json['caseId'] as String?,
      caseSummary: json['case'] == null
          ? null
          : CaseSummary.fromJson(json['case'] as Map<String, dynamic>),
      folderId: json['folderId'] as String?,
      categoryId: json['categoryId'] as String?,
      linkedEntityType: json['linkedEntityType'] as String?,
      linkedEntityId: json['linkedEntityId'] as String?,
      uploadedById: json['uploadedById'] as String,
      versionNumber: (json['versionNumber'] as num).toInt(),
      sha256: json['sha256'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$DocumentItemToJson(_DocumentItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'fileType': instance.fileType,
      'sizeBytes': instance.sizeBytes,
      'caseId': instance.caseId,
      'case': instance.caseSummary,
      'folderId': instance.folderId,
      'categoryId': instance.categoryId,
      'linkedEntityType': instance.linkedEntityType,
      'linkedEntityId': instance.linkedEntityId,
      'uploadedById': instance.uploadedById,
      'versionNumber': instance.versionNumber,
      'sha256': instance.sha256,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
