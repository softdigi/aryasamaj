import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';

/// Shell scaffold that provides a persistent BottomNavigationBar across
/// the 5 main sections: Home, Library, Members, Donation, Profile.
class MainScaffold extends StatelessWidget {
  final Widget child;
  const MainScaffold({super.key, required this.child});

  static const _tabs = [
    _TabItem(icon: Icons.home_outlined,       activeIcon: Icons.home,            label: AppStrings.home,     route: '/home'),
    _TabItem(icon: Icons.library_books_outlined, activeIcon: Icons.library_books, label: AppStrings.library, route: '/library'),
    _TabItem(icon: Icons.people_outline,      activeIcon: Icons.people,          label: AppStrings.members,  route: '/members'),
    _TabItem(icon: Icons.volunteer_activism_outlined, activeIcon: Icons.volunteer_activism, label: AppStrings.donation, route: '/donation'),
    _TabItem(icon: Icons.person_outline,      activeIcon: Icons.person,          label: AppStrings.profile,  route: '/profile'),
  ];

  int _tabIndexForRoute(String location) {
    for (var i = 0; i < _tabs.length; i++) {
      if (location.startsWith(_tabs[i].route)) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final currentIndex = _tabIndexForRoute(location);

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (i) {
          if (i != currentIndex) {
            context.go(_tabs[i].route);
          }
        },
        backgroundColor: Colors.white,
        indicatorColor: AppColors.saffronLight,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: _tabs.map((t) => NavigationDestination(
          icon: Icon(t.icon),
          selectedIcon: Icon(t.activeIcon, color: AppColors.saffron),
          label: t.label,
        )).toList(),
      ),
    );
  }
}

class _TabItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String route;
  const _TabItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.route,
  });
}
