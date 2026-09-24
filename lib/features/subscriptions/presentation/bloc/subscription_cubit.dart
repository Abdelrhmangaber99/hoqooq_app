import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/network/dio_error_mapper.dart';
import 'subscription_state.dart';

/// Single source of truth for the firm record (`/tenants/my-firm` — name,
/// logo, versioned subscription history) and the plan catalog. A
/// lazySingleton so Settings, the Subscription page, and the main-layout
/// sidebar all observe the same stream and every successful mutation
/// immediately rebuilds every consumer — no per-screen duplicate copies of
/// firm/subscription state, no manual refresh, no polling.
@lazySingleton
class SubscriptionCubit extends Cubit<SubscriptionState> {
  final Dio _dio;

  SubscriptionCubit(this._dio) : super(const SubscriptionInitial());

  Future<void> fetchSubscription() async {
    emit(const SubscriptionLoading());
    try {
      final responses = await Future.wait([
        _dio.get('/tenants/my-firm'),
        _dio.get('/subscriptions/plans').catchError((_) => Response(
              requestOptions: RequestOptions(path: '/subscriptions/plans'),
              data: [],
            )),
      ]);

      final firm = Map<String, dynamic>.from(responses[0].data as Map);
      final plansRaw = responses[1].data;
      final plans = plansRaw is List
          ? plansRaw.map((e) => Map<String, dynamic>.from(e as Map)).toList()
          : <Map<String, dynamic>>[];

      emit(SubscriptionLoaded(
        firm: firm,
        activeSubscription: extractActiveSubscription(firm),
        availablePlans: plans,
      ));
    } catch (e) {
      final message =
          e is DioException ? mapDioError(e).message : 'تعذر تحميل بيانات الاشتراك';
      emit(SubscriptionError(message));
    }
  }

  /// The subscription actually in effect: the latest version row that has
  /// not been superseded by a plan/cycle change and is not archived.
  /// `subscriptions[]` is a full version history — status (ACTIVE /
  /// PENDING / EXPIRED / CANCELLED) always comes from this row verbatim.
  static Map<String, dynamic>? extractActiveSubscription(
      Map<String, dynamic> firm) {
    final subscriptions = (firm['subscriptions'] as List?)
            ?.map((e) => Map<String, dynamic>.from(e as Map))
            .toList() ??
        [];
    if (subscriptions.isEmpty) return null;
    return subscriptions.firstWhere(
      (s) => s['supersededAt'] == null && s['isArchived'] != true,
      orElse: () => subscriptions.first,
    );
  }

  /// Public, flicker-free refetch for screen-entry synchronization.
  ///
  /// Dependent screens call this when they become visible so a change made
  /// outside this widget tree — a platform-admin plan change or
  /// cancellation, or an edit from another session — is picked up without
  /// a manual refresh, and without the full-screen spinner that
  /// [fetchSubscription] shows: whatever is already displayed stays on
  /// screen until the authoritative payload arrives. When the cubit has no
  /// data yet it falls back to a full [fetchSubscription].
  Future<void> refreshQuietly() {
    if (state is SubscriptionLoaded) return _refetch();
    return fetchSubscription();
  }

  /// Silent refetch that keeps the currently displayed data on screen.
  /// Used after every successful mutation: the authoritative payload
  /// replaces local state as soon as it arrives, so dependent screens
  /// (settings, subscription page, sidebar) rebuild immediately — without
  /// a full-screen loading state, a page reload, or an app restart.
  Future<void> _refetch() async {
    try {
      final response = await _dio.get('/tenants/my-firm');
      final firm = Map<String, dynamic>.from(response.data as Map);
      if (state is SubscriptionLoaded) {
        emit((state as SubscriptionLoaded).copyWith(
          firm: firm,
          activeSubscription: extractActiveSubscription(firm),
          isMutating: false,
          error: null,
        ));
      } else {
        await fetchSubscription();
      }
    } catch (e) {
      // The mutation itself succeeded — the refetch failing is a non-fatal
      // data-freshness problem, surfaced as an inline error over the
      // existing data rather than wiping the screen to an error state.
      final message =
          e is DioException ? mapDioError(e).message : 'تعذر تحديث بيانات الاشتراك';
      if (state is SubscriptionLoaded) {
        emit((state as SubscriptionLoaded).copyWith(
          isMutating: false,
          error: message,
        ));
      } else {
        emit(SubscriptionError(message));
      }
    }
  }

  Future<bool> changePlan({
    required String planId,
    required String billingCycle,
    String? firmId,
  }) async {
    final currentState = state;
    final currentFirmId = firmId ??
        (currentState is SubscriptionLoaded
            ? currentState.firm['id'] as String?
            : null);

    final path = currentFirmId != null && currentFirmId.isNotEmpty
        ? '/subscriptions/$currentFirmId'
        : '/subscriptions/my-firm';

    if (currentState is SubscriptionLoaded) {
      emit(currentState.copyWith(isMutating: true, error: null));
    }
    try {
      await _dio.patch(
        path,
        data: {
          'planId': planId,
          'billingCycle': billingCycle,
        },
      );
      await _refetch();
      return true;
    } catch (e) {
      final message =
          e is DioException ? mapDioError(e).message : 'تعذر تغيير خطة الاشتراك';
      if (state is SubscriptionLoaded) {
        emit((state as SubscriptionLoaded).copyWith(isMutating: false, error: message));
      } else {
        emit(SubscriptionError(message));
      }
      return false;
    }
  }

  Future<bool> deactivateSubscription({String? firmId}) async {
    final currentState = state;
    final currentFirmId = firmId ??
        (currentState is SubscriptionLoaded
            ? currentState.firm['id'] as String?
            : null);

    final path = currentFirmId != null && currentFirmId.isNotEmpty
        ? '/subscriptions/$currentFirmId/deactivate'
        : '/subscriptions/deactivate';

    if (currentState is SubscriptionLoaded) {
      emit(currentState.copyWith(isMutating: true, error: null));
    }
    try {
      await _dio.post(path);
      await _refetch();
      return true;
    } catch (e) {
      final message =
          e is DioException ? mapDioError(e).message : 'تعذر إلغاء الاشتراك';
      if (state is SubscriptionLoaded) {
        emit((state as SubscriptionLoaded).copyWith(isMutating: false, error: message));
      } else {
        emit(SubscriptionError(message));
      }
      return false;
    }
  }

  Future<bool> activateSubscription({String? firmId}) async {
    final currentState = state;
    final currentFirmId = firmId ??
        (currentState is SubscriptionLoaded
            ? currentState.firm['id'] as String?
            : null);

    final path = currentFirmId != null && currentFirmId.isNotEmpty
        ? '/subscriptions/$currentFirmId/activate'
        : '/subscriptions/activate';

    if (currentState is SubscriptionLoaded) {
      emit(currentState.copyWith(isMutating: true, error: null));
    }
    try {
      await _dio.post(path);
      await _refetch();
      return true;
    } catch (e) {
      final message =
          e is DioException ? mapDioError(e).message : 'تعذر تفعيل الاشتراك';
      if (state is SubscriptionLoaded) {
        emit((state as SubscriptionLoaded).copyWith(isMutating: false, error: message));
      } else {
        emit(SubscriptionError(message));
      }
      return false;
    }
  }

  /// PATCH /tenants/my-firm (UpdateTenantDto: name, address, contactEmail —
  /// the backend rejects any other property). On success the authoritative
  /// firm payload is refetched into shared state, so the settings form and
  /// the sidebar workspace name update immediately.
  Future<bool> saveFirmInfo({
    required String name,
    required String address,
    required String contactEmail,
  }) async {
    final currentState = state;
    if (currentState is! SubscriptionLoaded) return false;
    emit(currentState.copyWith(isMutating: true, error: null));
    try {
      await _dio.patch(
        '/tenants/my-firm',
        data: {
          'name': name,
          'address': address,
          'contactEmail': contactEmail,
        },
      );
      await _refetch();
      return true;
    } catch (e) {
      final message =
          e is DioException ? mapDioError(e).message : 'تعذر حفظ بيانات المكتب';
      emit(currentState.copyWith(isMutating: false, error: message));
      return false;
    }
  }

  /// POST /tenants/my-firm/logo (multipart `logo` field, ≤5MB image per the
  /// backend). Bumps the cached `logoUrl` inside shared state so every
  /// consumer showing the logo rebuilds with the new URL immediately —
  /// network image caches keyed by URL cannot serve the old logo because
  /// the key itself changed.
  Future<bool> uploadFirmLogo(String filePath) async {
    final currentState = state;
    if (currentState is! SubscriptionLoaded) return false;
    emit(currentState.copyWith(isMutating: true, error: null));
    try {
      final file = File(filePath);
      final length = await file.length();
      if (length > 5 * 1024 * 1024) {
        emit(currentState.copyWith(
          isMutating: false,
          error: 'حجم الصورة يجب ألا يتجاوز 5 ميجابايت',
        ));
        return false;
      }

      final fileName = filePath.split(RegExp(r'[/\\]')).last;
      final formData = FormData.fromMap({
        'logo': await MultipartFile.fromFile(filePath, filename: fileName),
      });

      await _dio.post('/tenants/my-firm/logo', data: formData);
      await _refetch();
      return true;
    } catch (e) {
      final message =
          e is DioException ? mapDioError(e).message : 'تعذر رفع الشعار';
      emit(currentState.copyWith(isMutating: false, error: message));
      return false;
    }
  }
}
