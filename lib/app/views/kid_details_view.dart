import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/kid_model.dart';
import '../routes/app_routes.dart';

class KidDetailsView extends StatelessWidget {
  const KidDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    final KidData kidData = Get.arguments as KidData;

    return Scaffold(
      appBar: AppBar(
        title: Text('${kidData.name}\'s Profile'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => Get.toNamed(
              AppRoutes.editKid,
              arguments: kidData,
            ),
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
                  // Profile Picture Placeholder
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    child: Text(
                      kidData.name.isNotEmpty
                          ? kidData.name[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                        fontSize: 36,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Kid's Name
                  Text(
                    kidData.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

                  // Age
                  Text(
                    '${kidData.age} years old',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Details Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Date of Birth
                    _buildDetailRow(
                      context,
                      'Date of Birth',
                      kidData.formattedDateOfBirth,
                      Icons.calendar_today,
                    ),
                    const Divider(),

                    // Age
                    _buildDetailRow(
                      context,
                      'Age',
                      '${kidData.age} years',
                      Icons.cake,
                    ),
                    const Divider(),

                    // Address
                    _buildDetailRow(
                      context,
                      'Address',
                      kidData.address,
                      Icons.location_on,
                    ),

                    // Insurance Info (if available)
                    if (kidData.insuranceInfo != null &&
                        kidData.insuranceInfo!.isNotEmpty) ...[
                      const Divider(),
                      _buildDetailRow(
                        context,
                        'Insurance',
                        kidData.insuranceInfo!,
                        Icons.health_and_safety,
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Quick Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Get.toNamed(
                      AppRoutes.editKid,
                      arguments: kidData,
                    ),
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit Profile'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Add functionality to schedule appointment or contact doctor
                      Get.snackbar(
                        'Coming Soon',
                        'Appointment scheduling will be available soon',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    },
                    icon: const Icon(Icons.schedule),
                    label: const Text('Schedule Visit'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
      BuildContext context, String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          color: Theme.of(context).colorScheme.primary,
          size: 24,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
