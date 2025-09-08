import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget drawer;
  final Widget body;
  final Widget? appBar;

  const ResponsiveLayout({
    super.key,
    required this.drawer,
    required this.body,
    this.appBar,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 1200;
    final isTablet = screenWidth > 768 && screenWidth <= 1200;

    if (isDesktop) {
      // Desktop layout with permanent navigation rail
      return Scaffold(
        body: Row(
          children: [
            // Permanent side navigation
            Container(
              width: 280,
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                border: Border(
                  right: BorderSide(
                    color: Theme.of(context).dividerColor,
                    width: 1,
                  ),
                ),
              ),
              child: drawer,
            ),
            // Main content
            Expanded(child: body),
          ],
        ),
      );
    } else if (isTablet) {
      // Tablet layout with rail navigation
      return Scaffold(
        body: Row(
          children: [
            // Collapsed navigation rail
            _buildNavigationRail(context),
            // Main content
            Expanded(child: body),
          ],
        ),
      );
    } else {
      // Mobile layout with drawer
      return Scaffold(
        drawer: drawer,
        body: body,
      );
    }
  }

  Widget _buildNavigationRail(BuildContext context) {
    return Container(
      width: 72,
      child: NavigationRail(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        selectedIndex: 0,
        onDestinationSelected: (index) {
          // Handle navigation
          switch (index) {
            case 0:
              // Home
              break;
            case 1:
              _showComingSoon('Profile');
              break;
            case 2:
              _showComingSoon('Analytics');
              break;
            case 3:
              _showComingSoon('Settings');
              break;
          }
        },
        destinations: const [
          NavigationRailDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: Text('Home'),
          ),
          NavigationRailDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: Text('Profile'),
          ),
          NavigationRailDestination(
            icon: Icon(Icons.analytics_outlined),
            selectedIcon: Icon(Icons.analytics),
            label: Text('Analytics'),
          ),
          NavigationRailDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: Text('Settings'),
          ),
        ],
      ),
    );
  }

  void _showComingSoon(String feature) {
    Get.snackbar(
      'Coming Soon!',
      '$feature feature will be available soon.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Theme.of(Get.context!).colorScheme.primary,
      colorText: Colors.white,
      borderRadius: 12,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 2),
    );
  }
}
