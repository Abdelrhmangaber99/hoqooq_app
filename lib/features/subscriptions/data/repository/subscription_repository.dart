import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/network/dio_error_mapper.dart';
import '../../domain/entities/subscription.dart';
import '../../domain/repository/i_subscription_repository.dart';

/// Real implementation of [ISubscriptionRepository] against
/// `POST /subscriptions/activate`. Exempt from `SubscriptionGuard` itself
/// (the guard excludes any URL containing `/api/subscriptions`), so this
/// call succeeds even while `SessionCubit` is in
/// `SessionSubscriptionInactive`.
@LazySingleton(as: ISubscriptionRepository)
class SubscriptionRepository implements ISubscriptionRepository {
  SubscriptionRepository(this._dio);

  final Dio _dio;

  @override
  ApiResult<Subscription> activateSubscription() async {
    try {
      final response = await _dio.post('/subscriptions/activate');
      return Right(
        Subscription.fromJson(response.data as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      return Left(mapDioError(e));
    }
  }
}
