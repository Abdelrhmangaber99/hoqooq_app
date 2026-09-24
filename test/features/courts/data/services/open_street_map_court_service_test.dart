import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hqooq/features/courts/data/services/open_street_map_court_service.dart';
import 'package:mocktail/mocktail.dart';

class MockDio extends Mock implements Dio {}

class MemoryCourtSearchCache implements CourtSearchCache {
  final Map<String, List<Map<String, dynamic>>> values = {};
  final Map<String, DateTime> timestamps = {};

  @override
  List<Map<String, dynamic>>? read(String key) => values[key];

  @override
  DateTime? writtenAt(String key) => timestamps[key];

  @override
  Future<void> write(String key, List<Map<String, dynamic>> courts) async {
    values[key] = courts;
    timestamps[key] = DateTime.now().toUtc();
  }
}

void main() {
  late MockDio dio;
  late MemoryCourtSearchCache cache;

  setUpAll(() {
    registerFallbackValue(Options());
  });

  setUp(() {
    dio = MockDio();
    cache = MemoryCourtSearchCache();
  });

  test('provides the verified bundled Court before the first refresh', () {
    final service = OpenStreetMapCourtService(cache: cache, dio: dio);

    final courts = service.cachedCourts(
      governorateName: 'Cairo',
      languageCode: 'en',
    );

    expect(courts.single.displayName, 'Cairo Court of Appeal');
    expect(courts.single.placeId, startsWith('bundled:'));
  });

  test('refreshes from OpenStreetMap and caches results', () async {
    when(
      () => dio.get<List<dynamic>>(
        any(),
        queryParameters: any(named: 'queryParameters'),
        options: any(named: 'options'),
      ),
    ).thenAnswer(
      (_) async => Response<List<dynamic>>(
        requestOptions: RequestOptions(path: 'search'),
        statusCode: 200,
        data: [
          {'osm_type': 'relation', 'osm_id': 123},
        ],
      ),
    );
    when(
      () => dio.post<Map<String, dynamic>>(
        any(),
        data: any(named: 'data'),
        options: any(named: 'options'),
      ),
    ).thenAnswer(
      (_) async => Response<Map<String, dynamic>>(
        requestOptions: RequestOptions(path: 'interpreter'),
        statusCode: 200,
        data: {
          'elements': [
            {
              'type': 'way',
              'id': 42,
              'center': {'lat': 30.0444, 'lon': 31.2357},
              'tags': {
                'amenity': 'courthouse',
                'name': 'Cairo Court',
                'addr:city': 'Cairo',
              },
            },
          ],
        },
      ),
    );
    final service = OpenStreetMapCourtService(cache: cache, dio: dio);

    final courts = await service.refreshCourts(
      governorateName: 'Cairo',
      languageCode: 'en',
    );

    expect(courts.single.displayName, 'Cairo Court');
    expect(courts.single.mapsUri.host, 'www.openstreetmap.org');
    expect(
      service
          .cachedCourts(governorateName: 'Cairo', languageCode: 'en')
          .single
          .placeId,
      'osm:way:42',
    );
    final captured = verify(
      () => dio.get<List<dynamic>>(
        any(),
        queryParameters: captureAny(named: 'queryParameters'),
        options: captureAny(named: 'options'),
      ),
    ).captured;
    expect((captured[0] as Map<String, dynamic>)['countrycodes'], 'eg');
    expect(
      (captured[0] as Map<String, dynamic>)['q'],
      'Cairo Governorate, Egypt',
    );
    final options = captured[1] as Options;
    expect(options.headers?['User-Agent'], 'Hoqooq-Mobile/1.0');
    final overpassQuery =
        verify(
              () => dio.post<Map<String, dynamic>>(
                any(),
                data: captureAny(named: 'data'),
                options: any(named: 'options'),
              ),
            ).captured.single
            as String;
    expect(overpassQuery, contains('area:3600000123'));
    expect(overpassQuery, contains('amenity'));
  });
}
