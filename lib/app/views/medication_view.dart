import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../data/demo_data_provider.dart';
import '../models/medication_model.dart';
import '../models/kid_model.dart';
import '../controllers/kid_controller.dart';

class MedicationView extends StatefulWidget {
  const MedicationView({Key? key}) : super(key: key);

  @override
  State<MedicationView> createState() => _MedicationViewState();
}

class _MedicationViewState extends State<MedicationView>
    with SingleTickerProviderStateMixin {
  final KidController kidController = Get.find<KidController>();
  late List<MedicationData> medications;
  late TabController _tabController;
  late KidData selectedKid;

  @override
  void initState() {
    super.initState();
    selectedKid = kidController.selectedKid.value ?? DemoDataProvider.getDemoKids().first;
    medications = DemoDataProvider.getDemoMedications(selectedKid.id);
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medications'),
        backgroundColor: Theme.of(context).primaryColor,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Active', icon: Icon(Icons.medication)),
            Tab(text: 'Running Low', icon: Icon(Icons.warning)),
            Tab(text: 'All', icon: Icon(Icons.list)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddMedicationDialog(),
            tooltip: 'Add Medication',
          ),
        ],
      ),
      body: Column(
        children: [
          // Kid Selector
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.surface,
            child: Obx(() {
              final kids = kidController.kids;
              if (kids.isEmpty) return const SizedBox.shrink();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Select Child',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<KidData>(
                    value: selectedKid,
                    isExpanded: true,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: kids.map((kid) {
                      return DropdownMenuItem<KidData>(
                        value: kid,
                        child: Text(kid.name),
                      );
                    }).toList(),
                    onChanged: (KidData? newKid) {
                      if (newKid != null) {
                        setState(() {
                          selectedKid = newKid;
                          medications = DemoDataProvider.getDemoMedications(newKid.id);
                        });
                      }
                    },
                  ),
                ],
              );
            }),
          ),

          // Medications List
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildMedicationsList(_getActiveMedications()),
                _buildMedicationsList(_getRunningLowMedications()),
                _buildMedicationsList(medications),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<MedicationData> _getActiveMedications() {
    return medications.where((med) => med.status == MedicationStatus.active).toList()
      ..sort((a, b) => a.endDate.compareTo(b.endDate));
  }

  List<MedicationData> _getRunningLowMedications() {
    return medications.where((med) =>
      med.status == MedicationStatus.active &&
      med.isRunningLow
    ).toList();
  }

  Widget _buildMedicationsList(List<MedicationData> medicationsList) {
    if (medicationsList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.medication_liquid,
              size: 80,
              color: Colors.grey.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No medications found',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap + to add a new medication',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.withOpacity(0.5),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: medicationsList.length,
      itemBuilder: (context, index) {
        final medication = medicationsList[index];
        return _buildMedicationCard(medication);
      },
    );
  }

  Widget _buildMedicationCard(MedicationData medication) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _showMedicationDetails(medication),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with status and progress
              Row(
                children: [
                  Expanded(
                    child: Text(
                      medication.medicationName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: medication.status.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: medication.status.color.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      medication.status.displayName,
                      style: TextStyle(
                        color: medication.status.color,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Generic name and dosage
              Text(
                '${medication.genericName} • ${medication.dosage}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),

              const SizedBox(height: 12),

              // Frequency and duration
              Row(
                children: [
                  Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    medication.frequency,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Progress bar and remaining info
              if (medication.status == MedicationStatus.active) ...[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: LinearProgressIndicator(
                            value: medication.progressPercentage / 100,
                            backgroundColor: Colors.grey[300],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              medication.progressPercentage > 80
                                ? Colors.red
                                : medication.progressPercentage > 50
                                  ? Colors.orange
                                  : Colors.green,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${medication.progressPercentage.toStringAsFixed(0)}%',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    Row(
                      children: [
                        Text(
                          '${medication.remainingDoses} doses left',
                          style: TextStyle(
                            fontSize: 12,
                            color: medication.isRunningLow ? Colors.red : Colors.grey[600],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '${medication.daysRemaining} days remaining',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // Warning for running low or expired
                if (medication.isRunningLow || medication.isExpired) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: medication.isExpired ? Colors.red.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: medication.isExpired ? Colors.red.withOpacity(0.3) : Colors.orange.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          medication.isExpired ? Icons.error : Icons.warning,
                          size: 16,
                          color: medication.isExpired ? Colors.red : Colors.orange,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            medication.isExpired
                              ? 'Medication has expired!'
                              : 'Running low on medication',
                            style: TextStyle(
                              fontSize: 12,
                              color: medication.isExpired ? Colors.red : Colors.orange,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],

              // Prescribed by and pharmacy
              const SizedBox(height: 8),
              Text(
                'Prescribed by ${medication.prescribedBy}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),

              Text(
                medication.pharmacyName,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showMedicationDetails(MedicationData medication) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Expanded(
                    child: Text(
                      medication.medicationName,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: medication.status.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      medication.status.displayName,
                      style: TextStyle(
                        color: medication.status.color,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              Text(
                medication.genericName,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),

              const SizedBox(height: 16),

              // Medication details
              _buildDetailRow('Dosage', medication.dosage),
              _buildDetailRow('Frequency', medication.frequency),
              _buildDetailRow('Duration', medication.formattedDuration),
              _buildDetailRow('Start Date', DateFormat('MMM dd, yyyy').format(medication.startDate)),
              _buildDetailRow('End Date', DateFormat('MMM dd, yyyy').format(medication.endDate)),

              const SizedBox(height: 16),

              // Progress
              if (medication.status == MedicationStatus.active) ...[
                const Text(
                  'Progress',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: medication.progressPercentage / 100,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    medication.progressPercentage > 80
                      ? Colors.red
                      : medication.progressPercentage > 50
                        ? Colors.orange
                        : Colors.green,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${medication.remainingDoses} of ${medication.totalDoses} doses remaining (${medication.daysRemaining} days left)',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],

              const SizedBox(height: 16),

              // Instructions
              const Text(
                'Instructions',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                medication.instructions,
                style: const TextStyle(
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: 16),

              // Side Effects
              const Text(
                'Side Effects',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                medication.sideEffects,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),

              const SizedBox(height: 16),

              // Pharmacy Info
              _buildDetailRow('Pharmacy', medication.pharmacyName),
              _buildDetailRow('Phone', medication.pharmacyPhone),
              _buildDetailRow('Prescribed By', medication.prescribedBy),

              // Notes
              if (medication.notes != null && medication.notes!.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text(
                  'Notes',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  medication.notes!,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Action Buttons
              if (medication.status == MedicationStatus.active) ...[
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // Call pharmacy
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Calling ${medication.pharmacyPhone}')),
                          );
                        },
                        icon: const Icon(Icons.phone),
                        label: const Text('Call Pharmacy'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // Mark dose taken
                          setState(() {
                            // In a real app, this would update the medication state
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Dose logged successfully!')),
                          );
                        },
                        icon: const Icon(Icons.check),
                        label: const Text('Log Dose'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddMedicationDialog() {
    final nameController = TextEditingController();
    final dosageController = TextEditingController();
    final frequencyController = TextEditingController();
    final instructionsController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Medication'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Medication Name',
                  hintText: 'Enter medication name',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: dosageController,
                decoration: const InputDecoration(
                  labelText: 'Dosage',
                  hintText: 'e.g., 125mg, 5ml, 1 tablet',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: frequencyController,
                decoration: const InputDecoration(
                  labelText: 'Frequency',
                  hintText: 'e.g., 3 times daily, Once daily',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: instructionsController,
                decoration: const InputDecoration(
                  labelText: 'Instructions',
                  hintText: 'Special instructions',
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty &&
                  dosageController.text.isNotEmpty &&
                  frequencyController.text.isNotEmpty) {
                final newMedication = MedicationData(
                  id: 'med_${DateTime.now().millisecondsSinceEpoch}',
                  kidId: selectedKid.id,
                  medicationName: nameController.text,
                  genericName: nameController.text,
                  dosage: dosageController.text,
                  frequency: frequencyController.text,
                  duration: const Duration(days: 10),
                  startDate: DateTime.now(),
                  endDate: DateTime.now().add(const Duration(days: 10)),
                  prescribedBy: 'Dr. Emily Chen',
                  pharmacyName: 'Springfield Pharmacy',
                  pharmacyPhone: '+1 (555) 456-7890',
                  instructions: instructionsController.text.isNotEmpty
                    ? instructionsController.text
                    : 'Take as prescribed',
                  sideEffects: 'Consult doctor if side effects occur',
                  status: MedicationStatus.active,
                  remainingDoses: 30,
                  totalDoses: 30,
                  notes: 'New prescription',
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                );

                setState(() {
                  medications.add(newMedication);
                });

                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Medication added successfully!')),
                );
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
