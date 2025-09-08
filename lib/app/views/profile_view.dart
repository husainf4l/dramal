import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../routes/app_routes.dart';
import '../services/account_deletion_service.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();

    // Debug: Print actual data from AuthController
    print('=== PROFILE VIEW DEBUG ===');
    print('User Name: ${authController.userName.value}');
    print('User Email: ${authController.userEmail.value}');
    print('User ID: ${authController.userId.value}');
    print('Is Logged In: ${authController.isLoggedIn.value}');
    print('Access Token: ${authController.accessToken.value}');
    print('Current User Object: ${authController.currentUser.value}');
    if (authController.currentUser.value != null) {
      final user = authController.currentUser.value!;
      print('UserData Details:');
      print('  - ID: ${user.id}');
      print('  - Email: ${user.email}');
      print('  - First Name: ${user.firstName}');
      print('  - Last Name: ${user.lastName}');
      print('  - Full Name: ${user.fullName}');
      print('  - Avatar: ${user.avatar}');
      print('  - JSON: ${user.toJson()}');
    }
    print('========================');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Check if we can go back, otherwise go to home
            if (Navigator.of(context).canPop()) {
              Get.back();
            } else {
              Get.offAllNamed(AppRoutes.home);
            }
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => Get.toNamed(AppRoutes.editProfile),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Profile Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.primary.withOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  // Profile Picture
                  Obx(() => CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.white.withOpacity(0.2),
                        backgroundImage:
                            authController.currentUser.value?.avatar != null
                                ? NetworkImage(
                                    authController.currentUser.value!.avatar!)
                                : null,
                        child: authController.currentUser.value?.avatar == null
                            ? Icon(
                                Icons.person,
                                size: 50,
                                color: Colors.white.withOpacity(0.8),
                              )
                            : null,
                      )),
                  const SizedBox(height: 16),

                  // User Name
                  Obx(() => Text(
                        authController.userName.value.isNotEmpty
                            ? authController.userName.value
                            : '',
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                      )),

                  const SizedBox(height: 8),

                  // User Email
                  Obx(() => Text(
                        authController.userEmail.value.isNotEmpty
                            ? authController.userEmail.value
                            : '',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withOpacity(0.9),
                            ),
                      )),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Profile Information Cards - Only Real Data
            Obx(() => _buildInfoSection(context, 'Account Information', [
                  if (authController.userEmail.value.isNotEmpty)
                    _buildInfoRow(context, Icons.email_outlined, 'Email',
                        authController.userEmail.value),
                  if (authController.userName.value.isNotEmpty)
                    _buildInfoRow(context, Icons.person_outline, 'Full Name',
                        authController.userName.value),
                  if (authController.currentUser.value?.firstName?.isNotEmpty ==
                      true)
                    _buildInfoRow(context, Icons.person_outline, 'First Name',
                        authController.currentUser.value!.firstName!),
                  if (authController.currentUser.value?.lastName?.isNotEmpty ==
                      true)
                    _buildInfoRow(context, Icons.person_outline, 'Last Name',
                        authController.currentUser.value!.lastName!),
                  if (authController.userId.value.isNotEmpty)
                    _buildInfoRow(context, Icons.badge_outlined, 'User ID',
                        authController.userId.value),
                ])),

            const SizedBox(height: 16),

            // Account Management Section
            _buildAccountManagementSection(context, authController),

            const SizedBox(height: 24),

            // Edit Profile Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Get.toNamed(AppRoutes.editProfile),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Edit Profile',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(
      BuildContext context, String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(
      BuildContext context, IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onBackground
                            .withOpacity(0.6),
                        fontWeight: FontWeight.w500,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountManagementSection(
      BuildContext context, AuthController authController) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Account Management',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 16),
          // Delete Account Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () =>
                  _showAccountDeletionDialog(context, authController),
              icon: const Icon(
                Icons.delete_forever_outlined,
                color: Colors.red,
                size: 20,
              ),
              label: const Text(
                'Delete Account',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Permanently delete your account and all associated data. This action cannot be undone.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
          ),
        ],
      ),
    );
  }

  void _showAccountDeletionDialog(
      BuildContext context, AuthController authController) {
    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.warning_outlined,
              color: Colors.red,
              size: 24,
            ),
            const SizedBox(width: 8),
            const Text(
              'Delete Account',
              style: TextStyle(color: Colors.red),
            ),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to permanently delete your account?',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 12),
            Text(
              'This action will:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 8),
            Text('• Delete all your personal data'),
            Text('• Remove your skin analysis history'),
            Text('• Cancel any active subscriptions'),
            Text('• This action cannot be undone'),
            SizedBox(height: 16),
            Text(
              'If you proceed, you will be logged out and your account will be permanently deleted.',
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back(); // Close dialog first
              _confirmAccountDeletion(context, authController);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete Account'),
          ),
        ],
      ),
    );
  }

  void _confirmAccountDeletion(
      BuildContext context, AuthController authController) {
    final TextEditingController confirmController = TextEditingController();
    final TextEditingController reasonController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text(
          'Final Confirmation',
          style: TextStyle(color: Colors.red),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Please help us improve by sharing why you\'re leaving (optional):',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                hintText: 'e.g., Found a better app, Privacy concerns, etc.',
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              maxLines: 2,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            const Text(
              'Type "DELETE" to confirm account deletion:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: confirmController,
              decoration: const InputDecoration(
                hintText: 'Type DELETE here',
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (confirmController.text.trim().toUpperCase() == 'DELETE') {
                Get.back();
                _performAccountDeletion(
                  authController,
                  reason: reasonController.text.trim().isEmpty
                      ? null
                      : reasonController.text.trim(),
                );
              } else {
                Get.snackbar(
                  'Error',
                  'Please type "DELETE" to confirm',
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                  snackPosition: SnackPosition.BOTTOM,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Confirm Delete'),
          ),
        ],
      ),
    );
  }

  void _performAccountDeletion(AuthController authController,
      {String? reason}) async {
    // Show loading dialog
    Get.dialog(
      AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            const Text('Deleting your account...'),
          ],
        ),
      ),
      barrierDismissible: false,
    );

    try {
      // Call the backend API to delete the account
      bool success = await AccountDeletionService.deleteAccount(
        reason: reason ?? 'User requested account deletion',
      );

      if (success) {
        // Close loading dialog
        Get.back();

        // Show success message first, then navigate
        Get.snackbar(
          'Account Deleted',
          'Your account has been successfully deleted. We\'re sorry to see you go!',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
          icon: const Icon(Icons.check_circle, color: Colors.white),
        );

        // Add a small delay to let the user see the message, then navigate
        await Future.delayed(const Duration(milliseconds: 500));

        // Navigate to login and clear all routes
        Get.offAllNamed(AppRoutes.login);
      }
    } catch (e) {
      // Close loading dialog
      Get.back();

      // Show error message
      String errorMessage = e.toString();
      if (errorMessage.contains('Exception: ')) {
        errorMessage = errorMessage.replaceFirst('Exception: ', '');
      }

      Get.dialog(
        AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.error, color: Colors.red),
              const SizedBox(width: 8),
              const Text('Deletion Failed'),
            ],
          ),
          content: Text(
            'Failed to delete your account:\n\n$errorMessage\n\nPlease try again or contact support if the problem persists.',
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('OK'),
            ),
            if (errorMessage.contains('Authentication failed'))
              TextButton(
                onPressed: () {
                  Get.back();
                  authController.logout();
                  Get.offAllNamed(AppRoutes.login);
                },
                child: const Text('Re-login'),
              ),
          ],
        ),
      );
    }
  }
}
