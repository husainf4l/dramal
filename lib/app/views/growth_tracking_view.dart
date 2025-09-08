import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/growth_model.dart';
import '../models/kid_model.dart';
import '../controllers/kid_controller.dart';
import '../services/growth_standards_service.dart';

class GrowthTrackingView extends StatefulWidget {
  const GrowthTrackingView({super.key});

  @override
  State<GrowthTrackingView> createState() => _GrowthTrackingViewState();
}

class _GrowthTrackingViewState extends State<GrowthTrackingView> {
  final KidController kidController = Get.find<KidController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selectedKid = kidController.selectedKid.value;

      if (selectedKid == null) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Growth Tracking'),
            backgroundColor: Theme.of(context).primaryColor,
          ),
          body: const Center(
            child: Text('Please select a child first'),
          ),
        );
      }

      return Scaffold(
        appBar: AppBar(
          title: const Text('Growth Tracking'),
          backgroundColor: Theme.of(context).primaryColor,
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () => _showGrowthStandardsSearch(),
              tooltip: 'Search Growth Standards',
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _showAddMeasurementDialog(),
              tooltip: 'Add Measurement',
            ),
          ],
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('growth')
              .where('kidId', isEqualTo: selectedKid.id)
              .orderBy('measurementDate', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              // Log error for debugging (remove in production)
              // print('Firebase Error: ${snapshot.error}');
              final errorMessage = snapshot.error.toString();

              // Check if it's an indexing error
              if (errorMessage.contains('index') ||
                  errorMessage.contains('Index') ||
                  errorMessage.contains('requires an index') ||
                  errorMessage.contains('FAILED_PRECONDITION')) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.build, size: 64, color: Colors.orange),
                        const SizedBox(height: 16),
                        const Text(
                          'Database Setup Required',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Firebase needs to create an index for this query.',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'This usually happens automatically, but you can also create it manually:',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            '1. Go to Firebase Console\n2. Select your project\n3. Go to Firestore Database\n4. Click on "Indexes" tab\n5. Create composite index:\n   - Collection: growth\n   - Fields: kidId (ASC), measurementDate (DESC)',
                            style: TextStyle(
                                fontSize: 12, fontFamily: 'monospace'),
                            textAlign: TextAlign.left,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Or simply add your first measurement and the index will be created automatically.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () => _showAddMeasurementDialog(),
                          icon: const Icon(Icons.add),
                          label: const Text('Add First Measurement'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: () => setState(() {}),
                          child: const Text('Try Again'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              // For other errors, show a more user-friendly message
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    const Text('Unable to load growth data'),
                    const SizedBox(height: 8),
                    const Text(
                      'Please check your internet connection and try again',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => setState(() {}),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            final docs = snapshot.data?.docs ?? [];
            final growthData = docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return GrowthData.fromJson({...data, 'id': doc.id});
            }).toList();

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Kid Selector
                  Obx(() {
                    final kids = kidController.kids;
                    if (kids.isEmpty) return const SizedBox.shrink();

                    return Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Select Child',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<KidData>(
                              initialValue: selectedKid,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                              ),
                              items: kids.map((kid) {
                                return DropdownMenuItem<KidData>(
                                  value: kid,
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 16,
                                        backgroundColor: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        child: Text(
                                          kid.name.isNotEmpty
                                              ? kid.name[0].toUpperCase()
                                              : '?',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(kid.name),
                                    ],
                                  ),
                                );
                              }).toList(),
                              onChanged: (KidData? newKid) {
                                if (newKid != null) {
                                  kidController.selectedKid.value = newKid;
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  }),

                  const SizedBox(height: 24),

                  // Latest Measurements Card
                  if (growthData.isNotEmpty)
                    Card(
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Latest Measurements',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildMeasurementCard(
                                    'Height',
                                    '${growthData.first.height.toStringAsFixed(1)} cm',
                                    Icons.height,
                                    Colors.blue,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildMeasurementCard(
                                    'Weight',
                                    '${growthData.first.weight.toStringAsFixed(1)} kg',
                                    Icons.monitor_weight,
                                    Colors.green,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _buildMeasurementCard(
                              'BMI',
                              '${growthData.first.bmi.toStringAsFixed(1)} (${growthData.first.bmiCategory})',
                              Icons.calculate,
                              Colors.purple,
                            ),
                            const SizedBox(height: 12),
                            if (growthData.isNotEmpty)
                              ElevatedButton.icon(
                                onPressed: () =>
                                    _showPercentileComparison(growthData),
                                icon: const Icon(Icons.compare_arrows),
                                label: const Text('Compare with Standards'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue[700],
                                  foregroundColor: Colors.white,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),

                  const SizedBox(height: 24),

                  // Growth Charts
                  if (growthData.length > 1) ...[
                    const Text(
                      'Growth Charts',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildGrowthChart(growthData, 'Height (cm)', Colors.blue),
                    const SizedBox(height: 24),
                    _buildGrowthChart(growthData, 'Weight (kg)', Colors.green),
                  ],

                  const SizedBox(height: 24),

                  // Growth History
                  if (growthData.isNotEmpty) ...[
                    const Text(
                      'Growth History',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: growthData.length,
                      itemBuilder: (context, index) {
                        final measurement = growthData[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary,
                              child: Text('${index + 1}'),
                            ),
                            title: Text(
                              '${measurement.height.toStringAsFixed(1)} cm, ${measurement.weight.toStringAsFixed(1)} kg',
                              style:
                                  const TextStyle(fontWeight: FontWeight.w500),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'BMI: ${measurement.bmi.toStringAsFixed(1)} (${measurement.bmiCategory})',
                                ),
                                Text(
                                  '${measurement.measurementDate.toLocal().toString().split(' ')[0]} - ${measurement.measuredBy}',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () =>
                                  _deleteMeasurement(measurement.id),
                            ),
                          ),
                        );
                      },
                    ),
                  ] else ...[
                    // Empty State
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.show_chart,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No growth measurements yet',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Add the first measurement to start tracking growth',
                            style: TextStyle(
                              color: Colors.grey,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () => _showAddMeasurementDialog(),
                            icon: const Icon(Icons.add),
                            label: const Text('Add First Measurement'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      );
    });
  }

  Widget _buildMeasurementCard(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrowthChart(
      List<GrowthData> growthData, String title, Color color) {
    final spots = growthData.asMap().entries.map((entry) {
      final index = entry.key;
      final data = entry.value;
      final value = title.contains('Height') ? data.height : data.weight;
      return FlSpot(index.toDouble(), value);
    }).toList();

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles:
                          SideTitles(showTitles: true, reservedSize: 40),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= growthData.length) {
                            return const Text('');
                          }
                          final date =
                              growthData[value.toInt()].measurementDate;
                          return Text(
                            '${date.month}/${date.day}',
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: color,
                      barWidth: 3,
                      belowBarData: BarAreaData(
                        show: true,
                        color: color.withValues(alpha: 0.1),
                      ),
                      dotData: FlDotData(show: true),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddMeasurementDialog() {
    final selectedKid = kidController.selectedKid.value;
    if (selectedKid == null) return;

    final heightController = TextEditingController();
    final weightController = TextEditingController();
    final measuredByController = TextEditingController(text: 'Dr. Smith');
    final locationController = TextEditingController(text: 'Clinic');
    final notesController = TextEditingController();
    DateTime selectedDate = DateTime.now();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Growth Measurement'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Date Picker
                ListTile(
                  title: const Text('Measurement Date'),
                  subtitle: Text(
                    selectedDate.toLocal().toString().split(' ')[0],
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      setState(() => selectedDate = date);
                    }
                  },
                ),
                const SizedBox(height: 16),

                // Height
                TextField(
                  controller: heightController,
                  decoration: const InputDecoration(
                    labelText: 'Height (cm)',
                    border: OutlineInputBorder(),
                    hintText: 'e.g., 85.5',
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: 12),

                // Weight
                TextField(
                  controller: weightController,
                  decoration: const InputDecoration(
                    labelText: 'Weight (kg)',
                    border: OutlineInputBorder(),
                    hintText: 'e.g., 12.3',
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: 12),

                // Measured By
                TextField(
                  controller: measuredByController,
                  decoration: const InputDecoration(
                    labelText: 'Measured By',
                    border: OutlineInputBorder(),
                    hintText: 'Doctor/Healthcare Provider',
                  ),
                ),

                const SizedBox(height: 12),

                // Location
                TextField(
                  controller: locationController,
                  decoration: const InputDecoration(
                    labelText: 'Location',
                    border: OutlineInputBorder(),
                    hintText: 'Clinic/Hospital',
                  ),
                ),

                const SizedBox(height: 12),

                // Notes
                TextField(
                  controller: notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notes (Optional)',
                    border: OutlineInputBorder(),
                    hintText: 'Additional observations...',
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
              onPressed: () async {
                final currentContext =
                    context; // Store context before async operations
                final height = double.tryParse(heightController.text);
                final weight = double.tryParse(weightController.text);

                if (height == null || weight == null) {
                  Get.snackbar(
                    'Error',
                    'Please enter valid height and weight',
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                  );
                  return;
                }

                try {
                  final measurement = GrowthData(
                    id: '',
                    kidId: selectedKid.id,
                    measurementDate: selectedDate,
                    height: height,
                    weight: weight,
                    measuredBy: measuredByController.text.trim().isEmpty
                        ? 'Healthcare Provider'
                        : measuredByController.text.trim(),
                    location: locationController.text.trim().isEmpty
                        ? 'Clinic'
                        : locationController.text.trim(),
                    notes: notesController.text.trim().isEmpty
                        ? null
                        : notesController.text.trim(),
                  );

                  final docRef = await FirebaseFirestore.instance
                      .collection('growth')
                      .add(measurement.toJson());

                  await docRef.update({'id': docRef.id});

                  if (currentContext.mounted) {
                    Navigator.of(currentContext).pop();
                  }

                  Get.snackbar(
                    'Success',
                    'Growth measurement added successfully',
                    backgroundColor: Colors.green,
                    colorText: Colors.white,
                    duration: const Duration(seconds: 3),
                  );
                } catch (e) {
                  Get.snackbar(
                    'Error',
                    'Failed to save measurement: ${e.toString()}',
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                    duration: const Duration(seconds: 5),
                  );
                }
              },
              child: const Text('Save Measurement'),
            ),
          ],
        ),
      ),
    );
  }

  void _showGrowthStandardsSearch() {
    final searchController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Growth Standards'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: searchController,
              decoration: const InputDecoration(
                labelText: 'Search for growth standards...',
                hintText: 'e.g., WHO standards, CDC charts',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Available Standards:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildStandardsList(),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () async {
              final currentContext =
                  context; // Store context before async operations
              if (searchController.text.isNotEmpty) {
                try {
                  final results =
                      await GrowthStandardsService.searchGrowthStandards(
                          searchController.text);
                  if (currentContext.mounted) {
                    Navigator.of(currentContext).pop();
                    _showSearchResults(results);
                  }
                } catch (e) {
                  Get.snackbar(
                    'Error',
                    'Failed to search standards: ${e.toString()}',
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                  );
                }
              }
            },
            child: const Text('Search'),
          ),
        ],
      ),
    );
  }

  Widget _buildStandardsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          title: const Text('WHO Child Growth Standards'),
          subtitle:
              const Text('International standards for children under 5 years'),
          trailing: const Icon(Icons.open_in_new),
          onTap: () => _openStandardsUrl(
              'https://www.who.int/tools/child-growth-standards'),
        ),
        ListTile(
          title: const Text('CDC Growth Charts'),
          subtitle: const Text('US growth charts for children and adolescents'),
          trailing: const Icon(Icons.open_in_new),
          onTap: () => _openStandardsUrl('https://www.cdc.gov/growthcharts/'),
        ),
      ],
    );
  }

  void _openStandardsUrl(String url) {
    // In a real app, this would open the URL in a browser
    Get.snackbar(
      'Opening Standards',
      'Redirecting to growth standards website...',
      backgroundColor: Colors.blue,
      colorText: Colors.white,
    );
  }

  void _showSearchResults(Map<String, dynamic> results) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Search Results for "${results['query']}"'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: (results['results'] as List).length,
            itemBuilder: (context, index) {
              final result = results['results'][index];
              return ListTile(
                title: Text(result['title']),
                subtitle: Text(result['description']),
                trailing: const Icon(Icons.open_in_new),
                onTap: () => _openStandardsUrl(result['url']),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showPercentileComparison(List<GrowthData> growthData) {
    final selectedKid = kidController.selectedKid.value;
    if (selectedKid == null || growthData.isEmpty) return;

    final gender = selectedKid.gender ?? 'Unknown';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Standard Growth Chart Comparison'),
        content: SizedBox(
          width: double.maxFinite,
          height: 600,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'View your child\'s measurements plotted on standard WHO growth charts',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                _buildComparisonChart(
                    growthData, gender, 'height', selectedKid),
                const SizedBox(height: 20),
                _buildComparisonChart(
                    growthData, gender, 'weight', selectedKid),
                const SizedBox(height: 16),
                _buildPercentileLegend(),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonChart(
      List<GrowthData> growthData, String gender, String type, KidData kid) {
    final standards =
        GrowthStandardsService.getStandardPercentiles(gender, type);
    final ageRange = GrowthStandardsService.getAgeRange();

    // Prepare child's data points (individual measurements)
    final childData = growthData.map((data) {
      final ageInMonths = GrowthStandardsService.getAgeInMonths(
          kid.dateOfBirth, data.measurementDate);
      final value = type == 'height' ? data.height : data.weight;
      // Only include data points that are within reasonable age range
      return FlSpot(ageInMonths.clamp(0, 59).toDouble(), value);
    }).where((spot) => spot.x >= 0 && spot.x < 60).toList();

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    '${type == 'height' ? 'Height' : 'Weight'} Growth Chart',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${growthData.length} measurements',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.blue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    drawHorizontalLine: true,
                    horizontalInterval: type == 'height' ? 5 : 2,
                    verticalInterval: 6, // Every 6 months
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 50,
                        interval: type == 'height' ? 10 : 5,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '${value.toInt()}',
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 12, // Every year
                        getTitlesWidget: (value, meta) {
                          final years = (value / 12).floor();
                          if (years >= 0 && years <= 5) {
                            return Text('${years}y',
                                style: const TextStyle(fontSize: 10));
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    topTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border:
                        Border.all(color: Colors.grey.withValues(alpha: 0.3)),
                  ),
                  minX: 0,
                  maxX: 60,
                  minY: type == 'height' ? 45 : 2,
                  maxY: type == 'height' ? 110 : 20,
                  lineBarsData: [
                    // 95th percentile curve
                    LineChartBarData(
                      spots: ageRange
                          .where((age) => age.toInt() < standards['95th']!.length)
                          .map((age) =>
                              FlSpot(age, standards['95th']![age.toInt()]))
                          .toList(),
                      isCurved: true,
                      color: Colors.red.withValues(alpha: 0.6),
                      barWidth: 2,
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(show: false),
                    ),
                    // 75th percentile curve
                    LineChartBarData(
                      spots: ageRange
                          .where((age) => age.toInt() < standards['75th']!.length)
                          .map((age) =>
                              FlSpot(age, standards['75th']![age.toInt()]))
                          .toList(),
                      isCurved: true,
                      color: Colors.orange.withValues(alpha: 0.6),
                      barWidth: 2,
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(show: false),
                    ),
                    // 50th percentile curve (main reference line)
                    LineChartBarData(
                      spots: ageRange
                          .where((age) => age.toInt() < standards['50th']!.length)
                          .map((age) =>
                              FlSpot(age, standards['50th']![age.toInt()]))
                          .toList(),
                      isCurved: true,
                      color: Colors.green.withValues(alpha: 0.8),
                      barWidth: 3,
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(show: false),
                    ),
                    // 25th percentile curve
                    LineChartBarData(
                      spots: ageRange
                          .where((age) => age.toInt() < standards['25th']!.length)
                          .map((age) =>
                              FlSpot(age, standards['25th']![age.toInt()]))
                          .toList(),
                      isCurved: true,
                      color: Colors.orange.withValues(alpha: 0.6),
                      barWidth: 2,
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(show: false),
                    ),
                    // 5th percentile curve
                    LineChartBarData(
                      spots: ageRange
                          .where((age) => age.toInt() < standards['5th']!.length)
                          .map((age) =>
                              FlSpot(age, standards['5th']![age.toInt()]))
                          .toList(),
                      isCurved: true,
                      color: Colors.red.withValues(alpha: 0.6),
                      barWidth: 2,
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(show: false),
                    ),
                    // Child's individual measurements as dots
                    LineChartBarData(
                      spots: childData,
                      isCurved: false,
                      color: Colors.blue,
                      barWidth: 1,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 6,
                            color: Colors.blue,
                            strokeWidth: 2,
                            strokeColor: Colors.white,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(show: false),
                    ),
                  ],
                  // Add tooltips for measurements
                  lineTouchData: LineTouchData(
                    enabled: true,
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((spot) {
                          // Only show tooltip for child's data points (last line bar data)
                          if (spot.barIndex == 5 && spot.spotIndex < growthData.length) {
                            final data = growthData[spot.spotIndex];
                            final ageInMonths =
                                GrowthStandardsService.getAgeInMonths(
                                    kid.dateOfBirth, data.measurementDate);
                            final value =
                                type == 'height' ? data.height : data.weight;
                            final unit = type == 'height' ? 'cm' : 'kg';
                            final date =
                                '${data.measurementDate.month}/${data.measurementDate.day}/${data.measurementDate.year}';

                            return LineTooltipItem(
                              '${ageInMonths ~/ 12}y ${ageInMonths % 12}m\n$value $unit\n$date',
                              const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            );
                          }
                          return null;
                        }).where((item) => item != null).toList();
                      },
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Measurement count and date range
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Measurements: ${growthData.length}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                if (growthData.isNotEmpty) ...[
                  Text(
                    'Latest: ${growthData.first.measurementDate.month}/${growthData.first.measurementDate.day}/${growthData.first.measurementDate.year}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPercentileLegend() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Growth Chart Legend',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            // Standard percentile curves
            Row(
              children: [
                Container(
                  width: 20,
                  height: 3,
                  color: Colors.green.withValues(alpha: 0.8),
                ),
                const SizedBox(width: 8),
                const Text('50th Percentile (Average)'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  width: 20,
                  height: 3,
                  color: Colors.orange.withValues(alpha: 0.6),
                ),
                const SizedBox(width: 8),
                const Text('25th & 75th Percentiles'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  width: 20,
                  height: 3,
                  color: Colors.red.withValues(alpha: 0.6),
                ),
                const SizedBox(width: 8),
                const Text('5th & 95th Percentiles'),
              ],
            ),
            const SizedBox(height: 12),
            // Child's measurements
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                const Text('Your Child\'s Measurements'),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'WHO Child Growth Standards (0-5 years)',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            const Text(
              '💡 Tap on any measurement dot to see details',
              style: TextStyle(fontSize: 12, color: Colors.blue),
            ),
            const SizedBox(height: 8),
            const Text(
              '📊 Measurements between percentile curves indicate normal growth',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteMeasurement(String measurementId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Measurement'),
        content: const Text(
            'Are you sure you want to delete this growth measurement? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final currentContext =
                  context; // Store context before async operations
              try {
                await FirebaseFirestore.instance
                    .collection('growth')
                    .doc(measurementId)
                    .delete();

                if (currentContext.mounted) {
                  Navigator.of(currentContext).pop();
                }

                Get.snackbar(
                  'Success',
                  'Measurement deleted successfully',
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                );
              } catch (e) {
                Get.snackbar(
                  'Error',
                  'Failed to delete measurement: ${e.toString()}',
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
