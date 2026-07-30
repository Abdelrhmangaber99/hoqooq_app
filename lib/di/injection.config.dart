// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i361;
import 'package:get_it/get_it.dart' as _i174;
import 'package:hqooq/core/localization/locale_bloc.dart' as _i40;
import 'package:hqooq/core/network/dio_client.dart' as _i893;
import 'package:hqooq/core/network/interceptors/auth_interceptor.dart' as _i404;
import 'package:hqooq/core/network/interceptors/refresh_interceptor.dart'
    as _i722;
import 'package:hqooq/core/storage/token_storage.dart' as _i23;
import 'package:hqooq/core/theme/theme_bloc.dart' as _i926;
import 'package:hqooq/features/authentication/data/repository/auth_repository.dart'
    as _i494;
import 'package:hqooq/features/authentication/domain/repository/i_auth_repository.dart'
    as _i598;
import 'package:hqooq/features/authentication/domain/usecases/login_use_case.dart'
    as _i196;
import 'package:hqooq/features/authentication/presentation/bloc/auth_bloc.dart'
    as _i1026;
import 'package:hqooq/features/authentication/presentation/bloc/session_cubit.dart'
    as _i81;
import 'package:hqooq/features/calendar/data/repository/calendar_repository.dart'
    as _i225;
import 'package:hqooq/features/calendar/domain/repository/i_calendar_repository.dart'
    as _i495;
import 'package:hqooq/features/calendar/presentation/bloc/calendar_bloc.dart'
    as _i251;
import 'package:hqooq/features/cases/data/repository/case_repository.dart'
    as _i981;
import 'package:hqooq/features/cases/domain/repository/i_case_repository.dart'
    as _i320;
import 'package:hqooq/features/cases/domain/usecases/get_cases_use_case.dart'
    as _i613;
import 'package:hqooq/features/cases/presentation/bloc/case_details_bloc.dart'
    as _i995;
import 'package:hqooq/features/cases/presentation/bloc/case_documents_bloc.dart'
    as _i194;
import 'package:hqooq/features/cases/presentation/bloc/case_form_bloc.dart'
    as _i728;
import 'package:hqooq/features/cases/presentation/bloc/case_hearings_bloc.dart'
    as _i389;
import 'package:hqooq/features/cases/presentation/bloc/cases_bloc.dart'
    as _i546;
import 'package:hqooq/features/clients/data/repository/client_repository.dart'
    as _i351;
import 'package:hqooq/features/clients/domain/repository/i_client_repository.dart'
    as _i794;
import 'package:hqooq/features/clients/domain/usecases/get_clients_use_case.dart'
    as _i723;
import 'package:hqooq/features/clients/presentation/bloc/client_details_bloc.dart'
    as _i283;
import 'package:hqooq/features/clients/presentation/bloc/client_form_bloc.dart'
    as _i730;
import 'package:hqooq/features/clients/presentation/bloc/clients_bloc.dart'
    as _i165;
import 'package:hqooq/features/courts/data/repository/court_repository.dart'
    as _i150;
import 'package:hqooq/features/courts/domain/repository/i_court_repository.dart'
    as _i543;
import 'package:hqooq/features/dashboard/data/repository/dashboard_repository.dart'
    as _i773;
import 'package:hqooq/features/dashboard/domain/repository/i_dashboard_repository.dart'
    as _i1072;
import 'package:hqooq/features/dashboard/presentation/bloc/dashboard_bloc.dart'
    as _i548;
import 'package:hqooq/features/documents/data/repository/document_repository.dart'
    as _i106;
import 'package:hqooq/features/documents/domain/repository/i_document_repository.dart'
    as _i622;
import 'package:hqooq/features/hearings/data/repository/hearing_repository.dart'
    as _i506;
import 'package:hqooq/features/hearings/domain/repository/i_hearing_repository.dart'
    as _i844;
import 'package:hqooq/features/hearings/presentation/bloc/hearing_form_bloc.dart'
    as _i421;
import 'package:hqooq/features/tasks/data/repository/task_repository.dart'
    as _i23;
import 'package:hqooq/features/tasks/domain/repository/i_task_repository.dart'
    as _i949;
import 'package:hqooq/features/users/data/repository/user_repository.dart'
    as _i867;
import 'package:hqooq/features/users/domain/repository/i_user_repository.dart'
    as _i141;
import 'package:injectable/injectable.dart' as _i526;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final networkModule = _$NetworkModule();
    gh.lazySingleton<_i40.LocaleBloc>(() => _i40.LocaleBloc());
    gh.lazySingleton<_i23.TokenStorage>(() => const _i23.TokenStorage());
    gh.lazySingleton<_i926.ThemeBloc>(() => _i926.ThemeBloc());
    gh.lazySingleton<_i81.SessionCubit>(() => _i81.SessionCubit());
    gh.factory<_i404.AuthInterceptor>(
      () => _i404.AuthInterceptor(gh<_i81.SessionCubit>()),
    );
    gh.factory<_i722.RefreshInterceptor>(
      () => _i722.RefreshInterceptor(
        gh<_i23.TokenStorage>(),
        gh<_i81.SessionCubit>(),
      ),
    );
    gh.lazySingleton<_i361.Dio>(
      () => networkModule.dio(
        gh<_i404.AuthInterceptor>(),
        gh<_i722.RefreshInterceptor>(),
      ),
    );
    gh.lazySingleton<_i794.IClientRepository>(
      () => _i351.ClientRepository(gh<_i361.Dio>(), gh<_i81.SessionCubit>()),
    );
    gh.factory<_i730.ClientFormBloc>(
      () => _i730.ClientFormBloc(gh<_i794.IClientRepository>()),
    );
    gh.lazySingleton<_i495.ICalendarRepository>(
      () => _i225.CalendarRepository(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i949.ITaskRepository>(
      () => _i23.TaskRepository(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i622.IDocumentRepository>(
      () => _i106.DocumentRepository(gh<_i361.Dio>()),
    );
    gh.factory<_i251.CalendarBloc>(
      () => _i251.CalendarBloc(gh<_i495.ICalendarRepository>()),
    );
    gh.factory<_i194.CaseDocumentsBloc>(
      () => _i194.CaseDocumentsBloc(gh<_i622.IDocumentRepository>()),
    );
    gh.lazySingleton<_i723.GetClientsUseCase>(
      () => _i723.GetClientsUseCase(gh<_i794.IClientRepository>()),
    );
    gh.lazySingleton<_i1072.IDashboardRepository>(
      () => _i773.DashboardRepository(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i844.IHearingRepository>(
      () => _i506.HearingRepository(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i320.ICaseRepository>(
      () => _i981.CaseRepository(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i141.IUserRepository>(
      () => _i867.UserRepository(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i543.ICourtRepository>(
      () => _i150.CourtRepository(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i598.IAuthRepository>(
      () => _i494.AuthRepository(gh<_i361.Dio>()),
    );
    gh.factory<_i421.HearingFormBloc>(
      () => _i421.HearingFormBloc(
        gh<_i844.IHearingRepository>(),
        gh<_i543.ICourtRepository>(),
      ),
    );
    gh.factory<_i165.ClientsBloc>(
      () => _i165.ClientsBloc(gh<_i723.GetClientsUseCase>()),
    );
    gh.lazySingleton<_i196.LoginUseCase>(
      () => _i196.LoginUseCase(gh<_i598.IAuthRepository>()),
    );
    gh.lazySingleton<_i613.GetCasesUseCase>(
      () => _i613.GetCasesUseCase(gh<_i320.ICaseRepository>()),
    );
    gh.factory<_i546.CasesBloc>(
      () => _i546.CasesBloc(gh<_i613.GetCasesUseCase>()),
    );
    gh.factory<_i728.CaseFormBloc>(
      () => _i728.CaseFormBloc(
        gh<_i320.ICaseRepository>(),
        gh<_i543.ICourtRepository>(),
        gh<_i141.IUserRepository>(),
      ),
    );
    gh.factory<_i995.CaseDetailsBloc>(
      () => _i995.CaseDetailsBloc(gh<_i320.ICaseRepository>()),
    );
    gh.factory<_i1026.AuthBloc>(
      () => _i1026.AuthBloc(
        gh<_i196.LoginUseCase>(),
        gh<_i598.IAuthRepository>(),
        gh<_i81.SessionCubit>(),
        gh<_i23.TokenStorage>(),
      ),
    );
    gh.factory<_i389.CaseHearingsBloc>(
      () => _i389.CaseHearingsBloc(gh<_i844.IHearingRepository>()),
    );
    gh.factory<_i548.DashboardBloc>(
      () => _i548.DashboardBloc(
        gh<_i1072.IDashboardRepository>(),
        gh<_i949.ITaskRepository>(),
        gh<_i81.SessionCubit>(),
      ),
    );
    gh.factory<_i283.ClientDetailsBloc>(
      () => _i283.ClientDetailsBloc(
        gh<_i794.IClientRepository>(),
        gh<_i320.ICaseRepository>(),
      ),
    );
    return this;
  }
}

class _$NetworkModule extends _i893.NetworkModule {}
