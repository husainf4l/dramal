import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class EditProfileView extends StatefulWidget {
  const EditProfileView({super.key});

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _birthdayController = TextEditingController();
  final _locationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCurrentData();
  }

  void _loadCurrentData() {
    final AuthController authController = Get.find<AuthController>();

    // Debug: Print actual data being loaded
    print('=== EDIT PROFILE DEBUG ===');
    print('Loading user data...');
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
    print('=========================');

    _nameController.text = authController.userName.value.isNotEmpty
        ? authController.userName.value
        : '';
    _emailController.text = authController.userEmail.value.isNotEmpty
        ? authController.userEmail.value
        : '';
    // Remove demo data - only use real API data
    _phoneController.text = '';
    _birthdayController.text = '';
    _locationController.text = '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _birthdayController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        actions: [
          TextButton(
            onPressed: _saveProfile,
            child: Text(
              'Save',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Profile Picture Section
              Center(
                child: Stack(
                  children: [
                    Obx(() {
                      final AuthController authController =
                          Get.find<AuthController>();
                      return CircleAvatar(
                        radius: 60,
                        backgroundColor: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.1),
                        backgroundImage:
                            authController.currentUser.value?.avatar != null
                                ? NetworkImage(
                                    authController.currentUser.value!.avatar!)
                                : null,
                        child: authController.currentUser.value?.avatar == null
                            ? Icon(
                                Icons.person,
                                size: 60,
                                color: Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withOpacity(0.6),
                              )
                            : null,
                      );
                    }),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            width: 3,
                          ),
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 20,
                          ),
                          onPressed: _changeProfilePicture,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Form Fields
              _buildTextField(
                controller: _nameController,
                label: 'Full Name',
                icon: Icons.person_outline,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              _buildTextField(
                controller: _emailController,
                label: 'Email',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!GetUtils.isEmail(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              _buildTextField(
                controller: _phoneController,
                label: 'Phone Number',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),

              const SizedBox(height: 16),

              _buildTextField(
                controller: _birthdayController,
                label: 'Birthday',
                icon: Icons.cake_outlined,
                readOnly: true,
                onTap: _selectBirthday,
              ),

              const SizedBox(height: 16),

              _buildTextField(
                controller: _locationController,
                label: 'Location',
                icon: Icons.location_on_outlined,
              ),

              const SizedBox(height: 32),

              // Preferences Section
              Container(
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
                      'Preferences',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                    const SizedBox(height: 16),
                    _buildSwitchTile(
                      icon: Icons.notifications_outlined,
                      title: 'Push Notifications',
                      subtitle:
                          'Receive notifications about your skincare routine',
                      value: true,
                      onChanged: (value) {
                        // Handle notification preference change
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildSwitchTile(
                      icon: Icons.email_outlined,
                      title: 'Email Notifications',
                      subtitle: 'Receive email updates and tips',
                      value: false,
                      onChanged: (value) {
                        // Handle email preference change
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Save Changes',
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
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      readOnly: readOnly,
      onTap: onTap,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).dividerColor,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).dividerColor.withOpacity(0.5),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 2,
          ),
        ),
        filled: true,
        fillColor: Theme.of(context).cardColor,
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
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
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onBackground
                          .withOpacity(0.6),
                    ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: Theme.of(context).colorScheme.primary,
        ),
      ],
    );
  }

  void _changeProfilePicture() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                _showComingSoon('Camera');
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _showComingSoon('Gallery');
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Remove Photo'),
              onTap: () {
                Navigator.pop(context);
                _showComingSoon('Remove Photo');
              },
            ),
          ],
        ),
      ),
    );
  }

  void _selectBirthday() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1990, 1, 1),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _birthdayController.text =
            '${picked.day}/${picked.month}/${picked.year}';
      });
    }
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      // Save profile logic here
      final AuthController authController = Get.find<AuthController>();

      // Debug: Print data being saved
      print('=== SAVE PROFILE DEBUG ===');
      print('Saving profile data...');
      print('Name: ${_nameController.text}');
      print('Email: ${_emailController.text}');
      print('Phone: ${_phoneController.text}');
      print('Birthday: ${_birthdayController.text}');
      print('Location: ${_locationController.text}');
      print(
          'Before update - Current userName: ${authController.userName.value}');
      print(
          'Before update - Current userEmail: ${authController.userEmail.value}');

      // Update the user data (in a real app, you'd call an API)
      // For now, just update the local values
      authController.userName.value = _nameController.text;

      print('After update - New userName: ${authController.userName.value}');
      print('========================');

      Get.snackbar(
        'Success',
        'Profile updated successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Theme.of(context).colorScheme.primary,
        colorText: Colors.white,
      );

      Get.back();
    }
  }

  void _showComingSoon(String feature) {
    Get.snackbar(
      'Coming Soon',
      '$feature feature will be available in a future update.',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }
}
