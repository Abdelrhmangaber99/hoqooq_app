import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/network/dio_error_mapper.dart';
import '../../domain/entities/case_financial_summary.dart';
import '../../domain/entities/financial_analytics.dart';
import '../../domain/entities/invoice.dart';
import '../../domain/entities/payment.dart';
import '../../domain/entities/single_case_financial_detail.dart';
import '../../domain/repository/i_finance_repository.dart';
import '../models/create_invoice_request.dart';
import '../models/create_payment_request.dart';
import '../models/update_invoice_request.dart';

/// Real implementation of [IFinanceRepository] against `/finance/*` per
/// API_CONTRACT.md finding R. No mock ever existed for this feature — it's
/// new in M6, unlike most other repositories in this app.
@LazySingleton(as: IFinanceRepository)
class FinanceRepository implements IFinanceRepository {
  FinanceRepository(this._dio);

  final Dio _dio;

  @override
  ApiResult<List<Invoice>> getInvoices() async {
    try {
      final response = await _dio.get('/finance/invoices');
      final data = response.data as List<dynamic>;
      return Right(
        data
            .map((json) => Invoice.fromJson(json as Map<String, dynamic>))
            .toList(),
      );
    } on DioException catch (e) {
      return Left(mapDioError(e));
    }
  }

  @override
  ApiResult<Invoice> getInvoiceDetails(String id) async {
    try {
      final response = await _dio.get('/finance/invoices/$id');
      return Right(Invoice.fromJson(response.data as Map<String, dynamic>));
    } on DioException catch (e) {
      return Left(mapDioError(e));
    }
  }

  @override
  ApiResult<Invoice> createInvoice(CreateInvoiceRequest request) async {
    try {
      final response = await _dio.post(
        '/finance/invoices',
        data: request.toJson(),
      );
      return Right(Invoice.fromJson(response.data as Map<String, dynamic>));
    } on DioException catch (e) {
      return Left(mapDioError(e));
    }
  }

  @override
  ApiResult<Invoice> updateInvoice(
    String id,
    UpdateInvoiceRequest request,
  ) async {
    try {
      final response = await _dio.patch(
        '/finance/invoices/$id',
        data: request.toJson(),
      );
      return Right(Invoice.fromJson(response.data as Map<String, dynamic>));
    } on DioException catch (e) {
      return Left(mapDioError(e));
    }
  }

  @override
  ApiResult<List<Payment>> getPayments() async {
    try {
      final response = await _dio.get('/finance/payments');
      final data = response.data as List<dynamic>;
      return Right(
        data
            .map((json) => Payment.fromJson(json as Map<String, dynamic>))
            .toList(),
      );
    } on DioException catch (e) {
      return Left(mapDioError(e));
    }
  }

  @override
  ApiResult<Payment> createPayment(CreatePaymentRequest request) async {
    try {
      final response = await _dio.post(
        '/finance/payments',
        data: request.toJson(),
      );
      return Right(Payment.fromJson(response.data as Map<String, dynamic>));
    } on DioException catch (e) {
      return Left(mapDioError(e));
    }
  }

  @override
  ApiResult<FinancialAnalytics> getFinancialAnalytics() async {
    try {
      final response = await _dio.get('/finance/analytics');
      return Right(
        FinancialAnalytics.fromJson(response.data as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      return Left(mapDioError(e));
    }
  }

  @override
  ApiResult<List<CaseFinancialSummary>> getCasesFinancialSummary() async {
    try {
      final response = await _dio.get('/finance/cases-summary');
      final data = response.data as List<dynamic>;
      return Right(
        data
            .map(
              (json) =>
                  CaseFinancialSummary.fromJson(json as Map<String, dynamic>),
            )
            .toList(),
      );
    } on DioException catch (e) {
      return Left(mapDioError(e));
    }
  }

  @override
  ApiResult<SingleCaseFinancialDetail> getCaseFinancialSummary(
    String caseId,
  ) async {
    try {
      final response = await _dio.get('/finance/cases/$caseId/summary');
      return Right(
        SingleCaseFinancialDetail.fromJson(
          response.data as Map<String, dynamic>,
        ),
      );
    } on DioException catch (e) {
      return Left(mapDioError(e));
    }
  }
}
