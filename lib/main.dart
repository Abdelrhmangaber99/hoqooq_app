import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/localization/app_localizations.dart';
import 'core/localization/locale_bloc.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'di/injection.dart';
import 'features/authentication/presentation/bloc/auth_bloc.dart';
import 'features/authentication/presentation/bloc/session_cubit.dart';
import 'features/profile/presentation/bloc/profile_cubit.dart';
import 'features/subscriptions/presentation/bloc/subscription_cubit.dart';
import 'l10n/app_localizations.dart' as gen_l10n;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Persistence
  await Hive.initFlutter();
  await Hive.openBox('settings');
  await Hive.openBox('court_cache');

  // Initialize Dependency Injection
  configureDependencies();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<LocaleBloc>()),
        BlocProvider(create: (_) => getIt<AuthBloc>()),
        BlocProvider(create: (_) => getIt<SessionCubit>()),
        BlocProvider(create: (_) => getIt<ProfileCubit>()),
        BlocProvider(create: (_) => getIt<SubscriptionCubit>()),
      ],
      child: BlocBuilder<LocaleBloc, LocaleState>(
        builder: (context, localeState) => MaterialApp.router(
          title: 'hoqooq',
          debugShowCheckedModeBanner: false,
          // Light mode only. No `darkTheme`/`themeMode` is supplied, so the
          // removed in-app switch cannot come back and the device's own
          // dark-mode setting cannot flip the app either.
          theme: AppTheme.lightTheme,
          locale: localeState.locale,
          routerConfig: AppRouter.router,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            gen_l10n.GeneratedAppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'), // English
            Locale('ar'), // Arabic
          ],
        ),
      ),
    );
  }
}
