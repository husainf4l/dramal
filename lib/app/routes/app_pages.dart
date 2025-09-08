import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../views/splash_view.dart';
import '../views/login_view.dart';
import '../views/home_view.dart';
import '../views/profile_view.dart';
import '../views/edit_profile_view.dart';
import '../views/notifications_view.dart';
import '../views/notification_settings_view.dart';
import '../views/kids_list_view.dart';
import '../views/add_kid_view.dart';
import '../views/edit_kid_view.dart';
import '../views/kid_details_view.dart';
import '../bindings/kid_binding.dart';
import '../bindings/vaccine_binding.dart';
import '../views/temperature_tracking_view.dart';
import '../views/growth_tracking_view.dart';
import 'app_routes.dart';

class AppPages {
  static const initial = AppRoutes.splash;

  static final routes = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashView(),
      binding: KidBinding(),
    ),
    GetPage(name: AppRoutes.login, page: () => const LoginView()),
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeView(),
      binding: KidBinding(),
    ),

    GetPage(name: AppRoutes.profile, page: () => const ProfileView()),
    GetPage(name: AppRoutes.editProfile, page: () => const EditProfileView()),
    GetPage(
        name: AppRoutes.notifications, page: () => const NotificationsView()),
    GetPage(
        name: AppRoutes.notificationSettings,
        page: () => const NotificationSettingsView()),

    // Kid routes
    GetPage(
      name: AppRoutes.kidsList,
      page: () => const KidsListView(),
      binding: KidBinding(),
    ),
    GetPage(
      name: AppRoutes.addKid,
      page: () => const AddKidView(),
      binding: KidBinding(),
    ),
    GetPage(
      name: AppRoutes.editKid,
      page: () => const EditKidView(),
      binding: KidBinding(),
    ),
    GetPage(
      name: AppRoutes.kidDetails,
      page: () => const KidDetailsView(),
      binding: KidBinding(),
    ),

    // Vaccine routes (placeholders for future implementation)
    GetPage(
      name: AppRoutes.vaccineList,
      page: () => const Scaffold(), // TODO: Implement VaccineListView
      binding: VaccineBinding(),
    ),
    GetPage(
      name: AppRoutes.kidVaccines,
      page: () => const Scaffold(), // TODO: Implement KidVaccinesView
      binding: VaccineBinding(),
    ),
    GetPage(
      name: AppRoutes.addVaccineRecord,
      page: () => const Scaffold(), // TODO: Implement AddVaccineRecordView
      binding: VaccineBinding(),
    ),
    GetPage(
      name: AppRoutes.editVaccineRecord,
      page: () => const Scaffold(), // TODO: Implement EditVaccineRecordView
      binding: VaccineBinding(),
    ),

    // Temperature tracking routes
    GetPage(
      name: AppRoutes.temperatureTracking,
      page: () => const TemperatureTrackingView(),
      binding: KidBinding(),
    ),

    // Growth tracking routes
    GetPage(
      name: AppRoutes.growthTracking,
      page: () => const GrowthTrackingView(),
      binding: KidBinding(),
    ),
  ];
}
