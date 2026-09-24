import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/network/dio_error_mapper.dart';
import '../../domain/entities/case_finance_detail.dart';
import '../../domain/entities/finance_summary.dart';
import '../../domain/entities/payment_record.dart';
import '../../domain/repository/i_finance_repository.dart';
import '../models/create_payment_request.dart';

@LazySingleton(as: IFinanceRepository)
class FinanceRepository implements IFinanceRepository {
  FinanceRepository(this._dio);

  final Dio _dio;

  @override
  ApiResult<FinanceSummary> getSummary({Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.get(
        '/finance/summary',
        queryParameters: queryParameters,
      );
      final data = response.data as Map<String, dynamic>;
      return Right(FinanceSummary.fromJson(data));
    } catch (e) {
      if (e is DioException) {
        return Left(mapDioError(e));
      }
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  ApiResult<CaseFinanceDetail> getCaseFinance(String caseId) async {
    try {
      final response = await _dio.get('/finance/cases/$caseId');
      final data = response.data as Map<String, dynamic>;
      return Right(CaseFinanceDetail.fromJson(data));
    } catch (e) {
      if (e is DioException) {
        return Left(mapDioError(e));
      }
      return Left(ServerFailure(e.toString()));
    }
  }

  // NO agreed-fee writer here: the Case Finance controller exposes only
  // summary / caseFinance / record / reverse. The agreed fee is a Case
  // column and is written through the Cases module (`PATCH /cases/:id`,
  // `agreedFee` on Create/UpdateCaseDto) — which is where the app's own
  // case form already sends it. An earlier `PATCH /finance/cases/:id/
  // agreed-fee` call here targeted a route that does not exist and 404'd
  // on every attempt.

  @override
  ApiResult<PaymentRecord> recordPayment(
    String caseId,
    CreatePaymentRequest request,
  ) async {
    try {
      final response = await _dio.post(
        '/finance/cases/$caseId/payments',
        data: request.toJson(),
      );
      final data = response.data as Map<String, dynamic>;
      return Right(PaymentRecord.fromJson(data));
    } catch (e) {
      if (e is DioException) {
        return Left(mapDioError(e));
      }
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  ApiResult<PaymentRecord> reversePayment(
    String paymentId,
    String reason,
  ) async {
    try {
      final response = await _dio.patch(
        '/finance/payments/$paymentId/reverse',
        data: {'reason': reason},
      );
      final data = response.data as Map<String, dynamic>;
      return Right(PaymentRecord.fromJson(data));
    } catch (e) {
      if (e is DioException) {
        return Left(mapDioError(e));
      }
      return Left(ServerFailure(e.toString()));
    }
  }
}
