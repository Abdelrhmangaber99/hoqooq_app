import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hqooq/di/injection.dart';
import 'package:hqooq/features/subscriptions/presentation/widgets/firm_logo_image.dart';
import 'package:mocktail/mocktail.dart';

class MockDio extends Mock implements Dio {}

/// 1x1 transparent PNG — `Image.memory` needs genuinely decodable bytes, or
/// the codec failure surfaces as an unhandled test exception.
final Uint8List _pngBytes = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8'
  'z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==',
);

void main() {
  late MockDio dio;

  setUp(() async {
    await getIt.reset();
    dio = MockDio();
    getIt.registerLazySingleton<Dio>(() => dio);
    registerFallbackValue(RequestOptions(path: '/'));
  });

  tearDown(() async {
    await getIt.reset();
  });

  Response<List<int>> okBytes(List<int> bytes) => Response<List<int>>(
    requestOptions: RequestOptions(path: '/tenants/my-firm/logo'),
    data: bytes,
    statusCode: 200,
  );

  Widget build(String? logoKey, {Object? version}) => MaterialApp(
    home: Scaffold(
      body: SizedBox(
        width: 80,
        height: 80,
        child: FirmLogoImage(logoKey: logoKey, version: version),
      ),
    ),
  );

  testWidgets('fetches the logo bytes and renders them as an image', (
    tester,
  ) async {
    when(
      () => dio.get<List<int>>(
        '/tenants/my-firm/logo',
        options: any(named: 'options'),
      ),
    ).thenAnswer((_) async => okBytes(_pngBytes));

    await tester.pumpWidget(build('branding/tenants/t1/logo-aaaa'));

    await tester.pumpAndSettle();

    expect(find.byType(Image), findsOneWidget);
    verify(
      () => dio.get<List<int>>(
        '/tenants/my-firm/logo',
        options: any(named: 'options'),
      ),
    ).called(1);
  });

  testWidgets('makes no request when the firm has no logo yet', (tester) async {
    await tester.pumpWidget(build(null));
    await tester.pumpAndSettle();

    expect(find.byType(Image), findsNothing);
    expect(find.byIcon(Icons.business_outlined), findsOneWidget);
    verifyNever(
      () => dio.get<List<int>>(
        '/tenants/my-firm/logo',
        options: any(named: 'options'),
      ),
    );
  });

  testWidgets('falls back to the placeholder when the fetch fails', (
    tester,
  ) async {
    when(
      () => dio.get<List<int>>(
        '/tenants/my-firm/logo',
        options: any(named: 'options'),
      ),
    ).thenThrow(
      DioException(
        requestOptions: RequestOptions(path: '/tenants/my-firm/logo'),
        type: DioExceptionType.connectionError,
      ),
    );

    await tester.pumpWidget(build('branding/tenants/t1/logo-fails'));
    await tester.pumpAndSettle();

    expect(find.byType(Image), findsNothing);
    expect(find.byIcon(Icons.business_outlined), findsOneWidget);
  });

  testWidgets('a re-upload (new version) triggers a fresh fetch', (
    tester,
  ) async {
    when(
      () => dio.get<List<int>>(
        '/tenants/my-firm/logo',
        options: any(named: 'options'),
      ),
    ).thenAnswer((_) async => okBytes(_pngBytes));

    await tester.pumpWidget(
      build('branding/tenants/t1/logo-1', version: '2026-01-01'),
    );
    await tester.pumpAndSettle();
    expect(find.byType(Image), findsOneWidget);

    // Same key, bumped version: the widget must not serve stale bytes.
    when(
      () => dio.get<List<int>>(
        '/tenants/my-firm/logo',
        options: any(named: 'options'),
      ),
    ).thenAnswer((_) async => okBytes(_pngBytes));
    await tester.pumpWidget(
      build('branding/tenants/t1/logo-1', version: '2026-02-02'),
    );
    await tester.pumpAndSettle();

    verify(
      () => dio.get<List<int>>(
        '/tenants/my-firm/logo',
        options: any(named: 'options'),
      ),
    ).called(2);
  });
}
