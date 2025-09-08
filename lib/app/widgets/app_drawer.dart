import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../controllers/theme_controller.dart';
import '../routes/app_routes.dart';
import 'dr_amal_damra_logo.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();
    final ThemeController themeController = Get.find<ThemeController>();

    return Drawer(
      width: 280,
      child: Column(
        children: [
          // Header Section
          _buildDrawerHeader(context, authController),

          // Scrollable Navigation Items
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                children: [
                  _buildNavigationSection(context),
                  const SizedBox(height: 8),
                  _buildSettingsSection(context, themeController),
                  const SizedBox(height: 8),
                  _buildSupportSection(context),
                ],
              ),
            ),
          ),

          // Footer Section
          _buildDrawerFooter(context, authController),
        ],
      ),
    );
  }

  Widget _buildDrawerHeader(
      BuildContext context, AuthController authController) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity, // Full drawer width
      height: 220, // Reduced from 200
      padding: const EdgeInsets.fromLTRB(
          16.0, 60.0, 16.0, 16.0), // Container padding instead of child Padding
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDarkMode
              ? [
                  // Dark theme colors
                  Theme.of(context).colorScheme.surface,
                  Theme.of(context).colorScheme.surface.withOpacity(0.8),
                ]
              : [
                  // Light theme colors
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.primary.withOpacity(0.8),
                ],
        ),
        // Add a subtle border for dark mode
        border: isDarkMode
            ? Border(
                bottom: BorderSide(
                  color: Theme.of(context).dividerColor.withOpacity(0.3),
                  width: 1,
                ),
              )
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Dr. Amal Damra Logo
          DrAmalDamraLogo(
            width: 120,
            height: 60,
            textColor: isDarkMode
                ? Theme.of(context).colorScheme.onSurface
                : Colors.white,
            fontSize: 18,
          ),
          const SizedBox(height: 8), // Reduced spacing

          // User Name
          Obx(() => Text(
                authController.userName.value.isNotEmpty
                    ? authController.userName.value
                    : 'Welcome User',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: isDarkMode
                          ? Theme.of(context).colorScheme.onSurface
                          : Colors.white,
                      fontWeight: FontWeight.w400,
                      fontSize: 16,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )),
          const SizedBox(height: 2), // Reduced spacing

          // User Email
          Obx(() => Text(
                authController.userEmail.value.isNotEmpty
                    ? authController.userEmail.value
                    : 'user@example.com',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isDarkMode
                          ? Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.7)
                          : Colors.white.withOpacity(0.8),
                      fontSize: 12,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )),
        ],
      ),
    );
  }

  Widget _buildNavigationSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4), // Reduced padding
          child: Text(
            'Navigation',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  // Changed from labelLarge
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
        _DrawerItem(
          icon: Icons.home_outlined,
          selectedIcon: Icons.home,
          title: 'Home',
          onTap: () {
            Get.back();
            Get.offAllNamed(AppRoutes.home);
          },
          isSelected: Get.currentRoute == AppRoutes.home,
        ),
        _DrawerItem(
          icon: Icons.child_care_outlined,
          selectedIcon: Icons.child_care,
          title: 'Kids',
          onTap: () {
            Get.back();
            Get.toNamed(AppRoutes.kidsList);
          },
          isSelected: Get.currentRoute == AppRoutes.kidsList,
        ),
        _DrawerItem(
          icon: Icons.notifications_outlined,
          selectedIcon: Icons.notifications,
          title: 'Notifications',
          onTap: () {
            Get.back();
            Get.toNamed('/notifications');
          },
          isSelected: Get.currentRoute == '/notifications',
        ),
      ],
    );
  }

  Widget _buildSettingsSection(
      BuildContext context, ThemeController themeController) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4), // Reduced padding
          child: Text(
            'Settings',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  // Changed from labelLarge
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
        _DrawerItem(
          icon: Icons.person_outline,
          selectedIcon: Icons.person,
          title: 'Profile & Account',
          onTap: () {
            Get.back();
            Get.toNamed(AppRoutes.profile);
          },
          isSelected: Get.currentRoute == AppRoutes.profile,
        ),
        // Compact dark mode toggle
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          child: ListTile(
            dense: true, // Makes the tile more compact
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
            leading: Container(
              width: 36, // Reduced from 40
              height: 36,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10), // Reduced radius
              ),
              child: Obx(() => Icon(
                    themeController.isDarkMode.value
                        ? Icons.dark_mode_outlined
                        : Icons.light_mode_outlined,
                    color: Theme.of(context).colorScheme.primary,
                    size: 18, // Reduced icon size
                  )),
            ),
            title: Text(
              'Dark Mode',
              style: TextStyle(
                fontSize: 14, // Reduced font size
                fontWeight: FontWeight.w500,
              ),
            ),
            trailing: Transform.scale(
              scale: 0.8, // Make switch smaller
              child: Obx(() => Switch(
                    value: themeController.isDarkMode.value,
                    onChanged: (_) => themeController.toggleTheme(),
                    activeColor: Theme.of(context).colorScheme.primary,
                  )),
            ),
            onTap: () => themeController.toggleTheme(),
          ),
        ),
      ],
    );
  }

  Widget _buildSupportSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4), // Reduced padding
          child: Text(
            'Support',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  // Changed from labelLarge
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
        _DrawerItem(
          icon: Icons.info_outline,
          selectedIcon: Icons.info,
          title: 'About',
          onTap: () {
            Get.back();
            _showAboutDialog();
          },
        ),
      ],
    );
  }

  Widget _buildDrawerFooter(
      BuildContext context, AuthController authController) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 8, vertical: 8), // Reduced padding
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 2),
            child: ListTile(
              dense: true, // More compact
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              leading: Container(
                width: 36, // Reduced from 40
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10), // Reduced radius
                ),
                child: const Icon(
                  Icons.logout,
                  color: Colors.red,
                  size: 18, // Reduced icon size
                ),
              ),
              title: Text(
                'Logout',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w500,
                  fontSize: 14, // Reduced font size
                ),
              ),
              onTap: () => _showLogoutDialog(context, authController),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 4), // Reduced padding
            child: Text(
              'Version 1.0.0',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.color
                        ?.withOpacity(0.6),
                    fontSize: 11, // Smaller font
                  ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AuthController authController) {
    Get.dialog(
      AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back(); // Close dialog
              Get.back(); // Close drawer
              authController.logout();
              Get.offAllNamed(AppRoutes.login);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            DrAmalDamraLogo(
              width: 32,
              height: 32,
              isMinimal: true,
              fontSize: 12,
            ),
            const SizedBox(width: 12),
            const Text('About Dr. Amal Damra'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Professional skincare consultation app by Dr. Amal Damra.',
            ),
            SizedBox(height: 16),
            Text(
              'Version: 1.0.0',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 8),
            Text(
              'Developer: Dr. Amal Damra',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final IconData? selectedIcon;
  final String title;
  final VoidCallback onTap;
  final bool isSelected;

  const _DrawerItem({
    required this.icon,
    this.selectedIcon,
    required this.title,
    required this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color? iconColor =
        isSelected ? Theme.of(context).colorScheme.primary : null;

    final Color? backgroundColor = isSelected
        ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
        : null;

    return Container(
      margin: const EdgeInsets.symmetric(
          horizontal: 8, vertical: 1), // Reduced vertical margin
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10), // Slightly smaller radius
      ),
      child: ListTile(
        dense: true, // More compact
        contentPadding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 2), // Reduced padding
        leading: Container(
          width: 36, // Reduced from 40
          height: 36,
          decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
                : Theme.of(context).colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10), // Reduced radius
          ),
          child: Icon(
            isSelected && selectedIcon != null ? selectedIcon! : icon,
            color: iconColor ?? Theme.of(context).colorScheme.primary,
            size: 18, // Reduced icon size
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: iconColor,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            fontSize: 14, // Reduced font size
          ),
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10), // Match container radius
        ),
      ),
    );
  }
}
