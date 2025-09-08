import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ThemeController extends GetxController {
  final _storage = GetStorage();
  final _key = 'isDarkMode';

  // Observable for theme mode
  RxBool isDarkMode = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Load saved theme preference
    isDarkMode.value = _storage.read(_key) ?? false;
  }

  /// Toggle between light and dark theme
  void toggleTheme() {
    isDarkMode.value = !isDarkMode.value;
    _storage.write(_key, isDarkMode.value);
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
  }

  /// Get current theme mode
  ThemeMode get themeMode =>
      isDarkMode.value ? ThemeMode.dark : ThemeMode.light;
}
