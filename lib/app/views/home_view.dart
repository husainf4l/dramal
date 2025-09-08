import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/kid_controller.dart';
import '../widgets/app_drawer.dart';
import '../widgets/kids_header_widget.dart';
import '../views/growth_tracking_view.dart';
import '../views/appointments_view.dart';
import '../views/medication_view.dart';
import '../views/demo_dashboard_view.dart';
import '../routes/app_routes.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final KidController kidController = Get.find<KidController>();

    // Load kids every time the view is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      kidController.loadKids();
    });

    return Scaffold(
      drawer: const AppDrawer(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.toNamed(AppRoutes.addKid),
        icon: const Icon(Icons.add),
        label: const Text('Add Child'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: CustomScrollView(
        slivers: [
          // Modern App Bar with gradient
          SliverAppBar(
            expandedHeight: 180,
            floating: false,
            pinned: true,
            backgroundColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: Theme.of(context).brightness == Brightness.dark
                        ? [
                            Theme.of(context).colorScheme.surface,
                            Theme.of(context)
                                .colorScheme
                                .surface
                                .withValues(alpha: 0.8),
                          ]
                        : [
                            Theme.of(context).colorScheme.primary,
                            Theme.of(context)
                                .colorScheme
                                .primary
                                .withValues(alpha: 0.8),
                          ],
                  ),
                ),
                child: const SafeArea(
                  child: KidsHeaderWidget(),
                ),
              ),
            ),
            leading: Builder(
              builder: (BuildContext context) {
                final bool isDarkMode =
                    Theme.of(context).brightness == Brightness.dark;
                return Container(
                  margin: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? Theme.of(context)
                            .colorScheme
                            .surface
                            .withValues(alpha: 0.3)
                        : Colors.white.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDarkMode
                          ? Theme.of(context)
                              .colorScheme
                              .outline
                              .withValues(alpha: 0.3)
                          : Colors.white.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.menu_rounded,
                      color: isDarkMode
                          ? Theme.of(context).colorScheme.onSurface
                          : Colors.white,
                      size: 24,
                    ),
                    onPressed: () => Scaffold.of(context).openDrawer(),
                  ),
                );
              },
            ),
            actions: [
              Builder(
                builder: (context) {
                  final bool isDarkMode =
                      Theme.of(context).brightness == Brightness.dark;
                  return IconButton(
                    icon: Icon(
                      Icons.notifications_outlined,
                      color: isDarkMode
                          ? Theme.of(context).colorScheme.onSurface
                          : Colors.white,
                      size: 24,
                    ),
                    onPressed: () {
                      Get.snackbar(
                        'Notifications',
                        'Push notifications are handled automatically by Firebase',
                        duration: const Duration(seconds: 3),
                      );
                    },
                    tooltip: 'Notifications',
                  );
                },
              ),
            ],
          ),

          // Main content with action buttons
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 24,
              ),
              child: Column(
                children: [
                  // Show empty state or add kid prompt when no kids
                  Obx(() {
                    final selectedKid = kidController.selectedKid.value;
                    final kidsCount = kidController.kids.length;
                    if (selectedKid == null && kidsCount == 0) {
                      return Container(
                        padding: const EdgeInsets.all(32),
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withValues(alpha: 0.1),
                              Theme.of(context)
                                  .colorScheme
                                  .secondary
                                  .withValues(alpha: 0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Theme.of(context)
                                .colorScheme
                                .outline
                                .withValues(alpha: 0.2),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.family_restroom,
                              size: 80,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'Welcome to Pediatric Care',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                  ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Start your child\'s health journey with comprehensive care tracking',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.7),
                                  ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 32),
                            ElevatedButton.icon(
                              onPressed: () => Get.toNamed(AppRoutes.addKid),
                              icon: const Icon(Icons.add, size: 24),
                              label: const Text('Add Your First Child'),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 32, vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 2,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  }),

                  // Welcome message for selected kid
                  Obx(() {
                    final selectedKid = kidController.selectedKid.value;
                    if (selectedKid != null) {
                      return Container(
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withValues(alpha: 0.1),
                              Theme.of(context)
                                  .colorScheme
                                  .secondary
                                  .withValues(alpha: 0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Theme.of(context)
                                .colorScheme
                                .outline
                                .withValues(alpha: 0.2),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 28,
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary,
                              child: Text(
                                selectedKid.name.isNotEmpty
                                    ? selectedKid.name[0].toUpperCase()
                                    : '?',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'How is ${selectedKid.name.split(' ').first} doing today? 🌟',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
                                        ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Keep track of their health and schedule appointments',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface
                                              .withValues(alpha: 0.7),
                                        ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  }),

                  // Action Buttons Grid
                  Obx(() {
                    final selectedKid = kidController.selectedKid.value;
                    if (selectedKid != null) {
                      return GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        childAspectRatio: 1.1,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        children: [
                          _buildActionButton(
                            context,
                            icon: Icons.play_circle_outline,
                            title: 'Demo Dashboard',
                            subtitle: 'Explore features',
                            color: Colors.blue,
                            onTap: () =>
                                Get.to(() => const DemoDashboardView()),
                          ),
                          _buildActionButton(
                            context,
                            icon: Icons.show_chart,
                            title: 'Growth Tracking',
                            subtitle: 'View charts',
                            color: Colors.blue,
                            onTap: () =>
                                Get.to(() => const GrowthTrackingView()),
                          ),
                          _buildActionButton(
                            context,
                            icon: Icons.calendar_today,
                            title: 'Appointments',
                            subtitle: 'Schedule & view',
                            color: Colors.purple,
                            onTap: () => Get.to(() => const AppointmentsView()),
                          ),
                          _buildActionButton(
                            context,
                            icon: Icons.medication,
                            title: 'Medications',
                            subtitle: 'Track doses',
                            color: Colors.green,
                            onTap: () => Get.to(() => const MedicationView()),
                          ),
                          _buildActionButton(
                            context,
                            icon: Icons.note_add,
                            title: 'Add Notes',
                            subtitle: 'Health notes',
                            color: Colors.orange,
                            onTap: () {
                              Get.snackbar(
                                'Notes',
                                'Notes feature coming soon!',
                                snackPosition: SnackPosition.BOTTOM,
                              );
                            },
                          ),
                          _buildActionButton(
                            context,
                            icon: Icons.thermostat,
                            title: 'Temperature',
                            subtitle: 'Track fever',
                            color: Colors.red,
                            onTap: () =>
                                Get.toNamed(AppRoutes.temperatureTracking),
                          ),
                        ],
                      );
                    }
                    return const SizedBox.shrink();
                  }),

                  const SizedBox(height: 32),

                  // Quick Actions Section
                  Obx(() {
                    final selectedKid = kidController.selectedKid.value;
                    if (selectedKid != null) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Quick Actions',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                ),
                          ),
                          const SizedBox(height: 16),
                          Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                children: [
                                  ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor:
                                          Colors.orange.withValues(alpha: 0.1),
                                      child: const Icon(Icons.vaccines,
                                          color: Colors.orange),
                                    ),
                                    title: const Text('Vaccination Records'),
                                    subtitle: const Text(
                                        'View and update vaccine history'),
                                    trailing:
                                        const Icon(Icons.arrow_forward_ios),
                                    onTap: () =>
                                        Get.toNamed(AppRoutes.vaccineList),
                                  ),
                                  const Divider(),
                                  ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor:
                                          Colors.blue.withValues(alpha: 0.1),
                                      child: const Icon(Icons.person,
                                          color: Colors.blue),
                                    ),
                                    title: const Text('Edit Profile'),
                                    subtitle:
                                        const Text('Update child information'),
                                    trailing:
                                        const Icon(Icons.arrow_forward_ios),
                                    onTap: () => Get.toNamed(AppRoutes.editKid,
                                        arguments: selectedKid),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    }
                    return const SizedBox.shrink();
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: color.withValues(alpha: 0.1),
                child: Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.6),
                      fontSize: 10,
                    ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
