import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/network/dio_error_mapper.dart';
import '../../domain/entities/lookup.dart';
import '../../domain/entities/lookup_kind.dart';
import '../../domain/repository/i_lookup_repository.dart';

/// Real implementation of [ILookupRepository] against `GET /lookups`.
@LazySingleton(as: ILookupRepository)
class LookupRepository implements ILookupRepository {
  LookupRepository(this._dio);

  final Dio _dio;

  /// Collapses duplicate option rows before they reach a dropdown.
  ///
  /// The endpoint is documented as returning the *global* (`tenant_id IS
  /// NULL`) lookups, but it is served by a TypeORM `find({ tenantId: null
  /// })` that this TypeORM version silently drops from the WHERE clause
  /// (its `invalidWhereValuesBehavior.null` default is `ignore`). The
  /// query therefore returns every tenant's row for a kind as well, so the
  /// same Hearing Type / Service Method / Document Category came back
  /// several times over and rendered as duplicate entries in the pickers.
  ///
  /// Grouping by label pair and preferring the global row keeps each
  /// distinct option once, and picks the row the endpoint was supposed to
  /// return. Options whose labels differ are all kept, so a firm-authored
  /// type is never hidden. Fixing the filter belongs to the backend; this
  /// is the client-side guard so the UI shows one entry per option.
  static List<Lookup> dedupeByLabel(List<Lookup> lookups) {
    final byLabel = <String, Lookup>{};
    for (final lookup in lookups) {
      final key = '${lookup.labelEn}\u0000${lookup.labelAr}';
      final existing = byLabel[key];
      if (existing == null || _isGlobal(lookup) && !_isGlobal(existing)) {
        byLabel[key] = lookup;
      }
    }
    return byLabel.values.toList();
  }

  static bool _isGlobal(Lookup lookup) =>
      lookup.tenantId == null || lookup.tenantId!.isEmpty;

  @override
  ApiResult<List<Lookup>> getLookups({required LookupKind kind}) async {
    try {
      if (kind == LookupKind.caseType) {
        final response = await _dio.get('/reference/case-types');
        final data = response.data as List<dynamic>;
        final now = DateTime.now().toIso8601String();
        return Right(
          dedupeByLabel(
            data.map((json) {
              final item = json as Map<String, dynamic>;
              return Lookup.fromJson({
                ...item,
                'tenantId': item['tenantId'] ?? '',
                'kind': 'CASE_TYPE',
                'isActive': item['isActive'] ?? true,
                'createdAt': item['createdAt'] ?? now,
                'updatedAt': item['updatedAt'] ?? now,
              });
            }).toList(),
          ),
        );
      }
      final response = await _dio.get(
        '/lookups',
        queryParameters: {'kind': lookupKindWireValue(kind)},
      );
      final data = response.data as List<dynamic>;
      return Right(
        dedupeByLabel(
          data
              .map((json) => Lookup.fromJson(json as Map<String, dynamic>))
              .toList(),
        ),
      );
    } on DioException catch (e) {
      return Left(mapDioError(e));
    }
  }
}
