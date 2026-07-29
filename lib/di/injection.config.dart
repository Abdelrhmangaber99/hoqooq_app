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
import 'package:hqooq/core/network/interceptors/tenant_interceptor.dart'
    as _i486;
import 'package:hqooq/core/theme/theme_bloc.dart' as _i926;
import 'package:hqooq/features/authentication/data/repository/mock_auth_repository.dart'
    as _i648;
import 'package:hqooq/features/authentication/domain/repository/i_auth_repository.dart'
    as _i598;
import 'package:hqooq/features/authentication/domain/usecases/login_use_case.dart'
    as _i196;
import 'package:hqooq/features/authentication/presentation/bloc/auth_bloc.dart'
    as _i1026;
import 'package:hqooq/features/calendar/data/repository/mock_appointment_repository.dart'
    as _i456;
import 'package:hqooq/features/calendar/domain/repository/i_appointment_repository.dart'
    as _i588;
import 'package:hqooq/features/calendar/domain/usecases/get_appointments_use_case.dart'
    as _i266;
import 'package:hqooq/features/calendar/presentation/bloc/calendar_bloc.dart'
    as _i251;
import 'package:hqooq/features/cases/data/repository/mock_case_repository.dart'
    as _i155;
import 'package:hqooq/features/cases/domain/repository/i_case_repository.dart'
    as _i320;
import 'package:hqooq/features/cases/domain/usecases/get_cases_use_case.dart'
    as _i613;
import 'package:hqooq/features/cases/presentation/bloc/cases_bloc.dart'
    as _i546;
import 'package:hqooq/features/clients/data/repository/mock_client_repository.dart'
    as _i317;
import 'package:hqooq/features/clients/domain/repository/i_client_repository.dart'
    as _i794;
import 'package:hqooq/features/clients/domain/usecases/get_clients_use_case.dart'
    as _i723;
import 'package:hqooq/features/clients/presentation/bloc/clients_bloc.dart'
    as _i165;
import 'package:injectable/injectable.dart' as _i526;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final networkModule = _$NetworkModule();
    gh.factory<_i486.TenantInterceptor>(() => _i486.TenantInterceptor());
    gh.lazySingleton<_i40.LocaleBloc>(() => _i40.LocaleBloc());
    gh.lazySingleton<_i361.Dio>(() => networkModule.dio);
    gh.lazySingleton<_i926.ThemeBloc>(() => _i926.ThemeBloc());
    gh.lazySingleton<_i320.ICaseRepository>(() => _i155.MockCaseRepository());
    gh.lazySingleton<_i598.IAuthRepository>(() => _i648.MockAuthRepository());
    gh.lazySingleton<_i588.IAppointmentRepository>(
      () => _i456.MockAppointmentRepository(),
    );
    gh.lazySingleton<_i794.IClientRepository>(
      () => _i317.MockClientRepository(),
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
    gh.lazySingleton<_i266.GetAppointmentsUseCase>(
      () => _i266.GetAppointmentsUseCase(gh<_i588.IAppointmentRepository>()),
    );
    gh.factory<_i251.CalendarBloc>(
      () => _i251.CalendarBloc(gh<_i266.GetAppointmentsUseCase>()),
    );
    gh.lazySingleton<_i723.GetClientsUseCase>(
      () => _i723.GetClientsUseCase(gh<_i794.IClientRepository>()),
    );
    gh.factory<_i1026.AuthBloc>(
      () => _i1026.AuthBloc(gh<_i196.LoginUseCase>()),
    );
    gh.factory<_i165.ClientsBloc>(
      () => _i165.ClientsBloc(gh<_i723.GetClientsUseCase>()),
    );
    return this;
  }
}

class _$NetworkModule extends _i893.NetworkModule {}
