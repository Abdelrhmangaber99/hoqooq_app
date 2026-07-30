import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/router/app_router.dart';

class MainLayout extends StatelessWidget {
  final Widget child;

  const MainLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;

    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _calculateSelectedIndex(location),
        onTap: (index) => _onItemTapped(index, context),
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_outlined),
            activeIcon: const Icon(Icons.home),
            label: context.tr('home'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.folder_outlined),
            activeIcon: const Icon(Icons.folder),
            label: context.tr('cases'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.calendar_today_outlined),
            activeIcon: const Icon(Icons.calendar_today),
            label: context.tr('calendar'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.people_outline),
            activeIcon: const Icon(Icons.people),
            label: context.tr('clients'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.notifications_none),
            activeIcon: const Icon(Icons.notifications),
            label: context.tr('alerts'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings_outlined),
            activeIcon: const Icon(Icons.settings),
            label: context.tr('profile'),
          ),
        ],
      ),
      floatingActionButton:
          location == AppRouter.home || location == AppRouter.calendar
          ? FloatingActionButton(
              onPressed: () {},
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textOnPrimary,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  int _calculateSelectedIndex(String location) {
    if (location.startsWith(AppRouter.home)) return 0;
    if (location.startsWith(AppRouter.cases)) return 1;
    if (location.startsWith(AppRouter.calendar)) return 2;
    if (location.startsWith(AppRouter.clients)) return 3;
    if (location.startsWith(AppRouter.alerts)) return 4;
    if (location.startsWith(AppRouter.profile)) return 5;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go(AppRouter.home);
        break;
      case 1:
        context.go(AppRouter.cases);
        break;
      case 2:
        context.go(AppRouter.calendar);
        break;
      case 3:
        context.go(AppRouter.clients);
        break;
      case 4:
        context.go(AppRouter.alerts);
        break;
      case 5:
        context.go(AppRouter.profile);
        break;
    }
  }
}
