import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/kid_controller.dart';
import '../routes/app_routes.dart';

class KidsListView extends StatelessWidget {
  const KidsListView({super.key});

  @override
  Widget build(BuildContext context) {
    final KidController kidController = Get.find<KidController>();

    // Load kids every time the view is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      kidController.loadKids();
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kids Profiles'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Get.toNamed(AppRoutes.addKid),
          ),
        ],
      ),
      body: Obx(() {
        if (kidController.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (kidController.kids.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.child_care,
                  size: 80,
                  color: Colors.grey.withValues(alpha: 0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'No kids added yet',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.grey,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Add your first kid profile',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.withValues(alpha: 0.7),
                      ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => Get.toNamed(AppRoutes.addKid),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Kid'),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: kidController.kids.length,
          itemBuilder: (context, index) {
            final kid = kidController.kids[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: Text(
                    kid.name.isNotEmpty ? kid.name[0].toUpperCase() : '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(
                  kid.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Age: ${kid.age}'),
                    Text('DOB: ${kid.formattedDateOfBirth}'),
                    if (kid.insuranceInfo != null &&
                        kid.insuranceInfo!.isNotEmpty)
                      Text('Insurance: ${kid.insuranceInfo}'),
                  ],
                ),
                trailing: PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        Get.toNamed(
                          AppRoutes.editKid,
                          arguments: kid,
                        );
                        break;
                      case 'delete':
                        _showDeleteConfirmation(context, kid);
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Text('Edit'),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text('Delete'),
                    ),
                  ],
                ),
                onTap: () => Get.toNamed(
                  AppRoutes.kidDetails,
                  arguments: kid,
                ),
              ),
            );
          },
        );
      }),
    );
  }

  void _showDeleteConfirmation(BuildContext context, kid) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Kid Profile'),
        content:
            Text('Are you sure you want to delete ${kid.name}\'s profile?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Get.find<KidController>().deleteKid(kid.id);
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
