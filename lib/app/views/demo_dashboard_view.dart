import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/kid_controller.dart';
import '../views/growth_tracking_view.dart';
import '../views/appointments_view.dart';
import '../views/medication_view.dart';
import '../data/demo_data_provider.dart';

class DemoDashboardView extends StatelessWidget {
  const DemoDashboardView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final KidController kidController = Get.find<KidController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Demo Dashboard'),
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showDemoInfo(context),
            tooltip: 'Demo Info',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).primaryColor.withOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '🏥 Pediatric Care Demo',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Explore comprehensive child health management features with realistic demo data.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Quick Stats
            const Text(
              '📊 Demo Overview',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                _buildStatCard(
                  context,
                  icon: Icons.child_care,
                  title: 'Kids',
                  value: '${DemoDataProvider.getDemoKids().length}',
                  color: Colors.blue,
                ),
                const SizedBox(width: 12),
                _buildStatCard(
                  context,
                  icon: Icons.vaccines,
                  title: 'Vaccines',
                  value: '${DemoDataProvider.getDemoVaccines().length}',
                  color: Colors.green,
                ),
                const SizedBox(width: 12),
                _buildStatCard(
                  context,
                  icon: Icons.calendar_today,
                  title: 'Appointments',
                  value: '${DemoDataProvider.getDemoAppointments('1').length}',
                  color: Colors.purple,
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Main Features
            const Text(
              '🚀 Core Features',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            // Growth Tracking
            _buildFeatureCard(
              context,
              icon: Icons.show_chart,
              title: 'Growth Tracking',
              description: 'Monitor height, weight, and head circumference with interactive charts and percentile calculations.',
              color: Colors.blue,
              features: [
                '📊 Interactive growth charts',
                '📏 Height & weight tracking',
                '🧠 Head circumference measurements',
                '📈 Percentile calculations',
                '📅 Historical data visualization',
              ],
              onTap: () => Get.to(() => const GrowthTrackingView()),
            ),

            const SizedBox(height: 16),

            // Appointments
            _buildFeatureCard(
              context,
              icon: Icons.calendar_today,
              title: 'Appointment Management',
              description: 'Schedule and manage doctor appointments with detailed information and reminders.',
              color: Colors.purple,
              features: [
                '📅 Appointment scheduling',
                '👨‍⚕️ Doctor & clinic information',
                '⏰ Time & duration tracking',
                '📍 Location & contact details',
                '🔄 Status updates',
              ],
              onTap: () => Get.to(() => const AppointmentsView()),
            ),

            const SizedBox(height: 16),

            // Medications
            _buildFeatureCard(
              context,
              icon: Icons.medication,
              title: 'Medication Tracking',
              description: 'Track prescriptions, dosages, and medication schedules with smart reminders.',
              color: Colors.green,
              features: [
                '💊 Prescription management',
                '⏱️ Dosage & frequency tracking',
                '📊 Progress monitoring',
                '🏥 Pharmacy integration',
                '⚠️ Refill alerts',
              ],
              onTap: () => Get.to(() => const MedicationView()),
            ),

            const SizedBox(height: 32),

            // Demo Data Info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.blue.withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.info, color: Colors.blue),
                      const SizedBox(width: 8),
                      const Text(
                        'Demo Data Information',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'This demo includes realistic pediatric data for 3 children with comprehensive medical information including:',
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '• Complete vaccination records\n'
                    '• Growth measurements with charts\n'
                    '• Scheduled and past appointments\n'
                    '• Active medication tracking\n'
                    '• Medical history and notes',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Call to Action
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Get.back(),
                icon: const Icon(Icons.home),
                label: const Text('Back to Home'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: color.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required List<String> features,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: color, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios, color: Colors.grey[400]),
                ],
              ),

              const SizedBox(height: 12),

              // Description
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 16),

              // Features
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: features.map((feature) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: color.withOpacity(0.3)),
                    ),
                    child: Text(
                      feature,
                      style: TextStyle(
                        fontSize: 12,
                        color: color,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDemoInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Demo Information'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'This demo showcases the following features:',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 12),

              _buildDemoFeature(
                '👶 Kids Management',
                'Complete profiles with medical information, emergency contacts, and insurance details.',
              ),

              _buildDemoFeature(
                '💉 Vaccine Tracking',
                'Comprehensive vaccination records with schedules, dosages, and administration details.',
              ),

              _buildDemoFeature(
                '📊 Growth Charts',
                'Interactive charts showing height, weight, and head circumference with percentile tracking.',
              ),

              _buildDemoFeature(
                '📅 Appointments',
                'Full appointment management with doctor details, locations, and status tracking.',
              ),

              _buildDemoFeature(
                '💊 Medications',
                'Medication tracking with dosages, frequencies, progress monitoring, and pharmacy integration.',
              ),

              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'All demo data is realistic and follows pediatric care best practices. '
                  'Tap on any feature to explore the full functionality.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }

  Widget _buildDemoFeature(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
