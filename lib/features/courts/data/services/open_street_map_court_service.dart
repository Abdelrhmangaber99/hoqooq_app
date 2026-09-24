import 'dart:async';

import 'package:dio/dio.dart';
import 'package:hive/hive.dart';

import '../../domain/entities/court_place_enrichment.dart';

abstract class CourtSearchCache {
  List<Map<String, dynamic>>? read(String key);
  DateTime? writtenAt(String key);
  Future<void> write(String key, List<Map<String, dynamic>> courts);
}

class MemoryCourtSearchCache implements CourtSearchCache {
  final Map<String, List<Map<String, dynamic>>> _values = {};
  final Map<String, DateTime> _timestamps = {};

  @override
  List<Map<String, dynamic>>? read(String key) => _values[key];

  @override
  DateTime? writtenAt(String key) => _timestamps[key];

  @override
  Future<void> write(String key, List<Map<String, dynamic>> courts) async {
    _values[key] = courts;
    _timestamps[key] = DateTime.now().toUtc();
  }
}

class HiveCourtSearchCache implements CourtSearchCache {
  HiveCourtSearchCache(this._box);

  final Box<dynamic> _box;

  @override
  List<Map<String, dynamic>>? read(String key) {
    final value = _box.get('$key:data');
    if (value is! List) return null;
    return value
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  @override
  DateTime? writtenAt(String key) {
    final value = _box.get('$key:writtenAt');
    return value is String ? DateTime.tryParse(value) : null;
  }

  @override
  Future<void> write(String key, List<Map<String, dynamic>> courts) async {
    await _box.put('$key:data', courts);
    await _box.put('$key:writtenAt', DateTime.now().toUtc().toIso8601String());
  }
}

class OpenStreetMapCourtService {
  OpenStreetMapCourtService({
    required CourtSearchCache cache,
    Dio? dio,
    Duration cacheTtl = const Duration(days: 30),
  }) : _cache = cache,
       _dio = dio ?? Dio(),
       _cacheTtl = cacheTtl;

  static const _nominatimUrl = 'https://nominatim.openstreetmap.org/search';
  static const _overpassUrl = 'https://overpass-api.de/api/interpreter';
  static DateTime? _lastNominatimRequestAt;

  static const Map<String, List<String>> _bundledFallback = {
    'cairo': ['Cairo Court of Appeal'],
    'alexandria': ['Alexandria Court of Appeal'],
  };

  final Dio _dio;
  final CourtSearchCache _cache;
  final Duration _cacheTtl;

  // Version 2 deliberately invalidates the old, limited Nominatim result cache.
  String _key(String governorateName, String languageCode) =>
      'osm-courts-v2:${governorateName.trim().toLowerCase()}:$languageCode';

  List<CourtPlaceEnrichment> cachedCourts({
    required String governorateName,
    required String languageCode,
  }) {
    final cached = _cache.read(_key(governorateName, languageCode));
    if (cached != null && cached.isNotEmpty) {
      return cached.map(CourtPlaceEnrichment.fromCacheJson).toList();
    }
    return (_bundledFallback[governorateName.trim().toLowerCase()] ?? const [])
        .map(CourtPlaceEnrichment.bundled)
        .toList();
  }

  bool isFresh({
    required String governorateName,
    required String languageCode,
  }) {
    final writtenAt = _cache.writtenAt(_key(governorateName, languageCode));
    return writtenAt != null &&
        DateTime.now().toUtc().difference(writtenAt) < _cacheTtl;
  }

  Future<List<CourtPlaceEnrichment>> refreshCourts({
    required String governorateName,
    required String languageCode,
  }) async {
    await _respectNominatimRateLimit();
    final boundaryResponse = await _dio.get<List<dynamic>>(
      _nominatimUrl,
      queryParameters: {
        'format': 'jsonv2',
        'q': '$governorateName Governorate, Egypt',
        'countrycodes': 'eg',
        'featuretype': 'state',
        'limit': 1,
      },
      options: Options(
        headers: {
          'User-Agent': 'Hoqooq-Mobile/1.0',
          'Accept-Language': languageCode == 'ar' ? 'ar,en' : 'en,ar',
        },
      ),
    );
    final boundaries = boundaryResponse.data ?? const [];
    if (boundaries.isEmpty || boundaries.first is! Map) return const [];
    final boundary = Map<String, dynamic>.from(boundaries.first as Map);
    final query = _buildOverpassQuery(boundary);
    if (query == null) return const [];

    final response = await _dio.post<Map<String, dynamic>>(
      _overpassUrl,
      data: query,
      options: Options(
        contentType: 'text/plain',
        headers: {'User-Agent': 'Hoqooq-Mobile/1.0'},
      ),
    );
    final elements = response.data?['elements'];
    final results = (elements is List ? elements : const <dynamic>[])
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .map(
          (item) => CourtPlaceEnrichment.fromOverpassJson(
            item,
            languageCode: languageCode,
          ),
        )
        .where((court) => court.displayName.isNotEmpty)
        .toList();
    final unique = <String, CourtPlaceEnrichment>{};
    for (final court in results) {
      unique.putIfAbsent(court.placeId, () => court);
    }
    final courts = unique.values.toList()
      ..sort((left, right) => left.displayName.compareTo(right.displayName));
    if (courts.isNotEmpty) {
      await _cache.write(
        _key(governorateName, languageCode),
        courts.map((court) => court.toCacheJson()).toList(),
      );
    }
    return courts;
  }

  String? _buildOverpassQuery(Map<String, dynamic> boundary) {
    final osmType = boundary['osm_type']?.toString();
    final osmId = int.tryParse(boundary['osm_id']?.toString() ?? '');
    String scope;
    if (osmType == 'relation' && osmId != null) {
      scope = '(area:${3600000000 + osmId})';
    } else {
      final box = boundary['boundingbox'];
      if (box is! List || box.length < 4) return null;
      final south = double.tryParse(box[0].toString());
      final north = double.tryParse(box[1].toString());
      final west = double.tryParse(box[2].toString());
      final east = double.tryParse(box[3].toString());
      if ([south, north, west, east].contains(null)) return null;
      scope = '($south,$west,$north,$east)';
    }
    return '''[out:json][timeout:25];
(
  nwr["amenity"="courthouse"]$scope;
  nwr["government"="judiciary"]$scope;
  nwr["office"="government"]["name"~"محكمة|court",i]$scope;
);
out center tags;''';
  }

  Future<void> _respectNominatimRateLimit() async {
    final lastRequestAt = _lastNominatimRequestAt;
    if (lastRequestAt != null) {
      final remaining =
          const Duration(seconds: 1) - DateTime.now().difference(lastRequestAt);
      if (remaining > Duration.zero) await Future<void>.delayed(remaining);
    }
    _lastNominatimRequestAt = DateTime.now();
  }
}
