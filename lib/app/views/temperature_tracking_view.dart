import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../controllers/kid_controller.dart';
import '../models/kid_model.dart';
import '../models/temperature_model.dart';
import '../routes/app_routes.dart';

class TemperatureTrackingView extends StatefulWidget {
  const TemperatureTrackingView({super.key});

  @override
  State<TemperatureTrackingView> createState() =>
      _TemperatureTrackingViewState();
}

class _TemperatureTrackingViewState extends State<TemperatureTrackingView> {
  final TextEditingController _temperatureController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  KidData? _selectedKidForTemperature;

  @override
  void initState() {
    super.initState();
    final KidController kidController = Get.find<KidController>();
    _selectedKidForTemperature = kidController.selectedKid.value;
  }

  @override
  void dispose() {
    _temperatureController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _saveTemperature() async {
    final temperature = double.tryParse(_temperatureController.text);
    if (temperature == null) {
      Get.snackbar('Error', 'Please enter a valid temperature');
      return;
    }

    if (_selectedKidForTemperature == null) {
      Get.snackbar('Error', 'Please select a child');
      return;
    }

    try {
      // Create temperature data
      final temperatureData = TemperatureData(
        id: '', // Firestore will generate the ID
        kidId: _selectedKidForTemperature!.id,
        temperature: temperature,
        measurementDate: DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
          _selectedTime.hour,
          _selectedTime.minute,
        ),
        measuredBy: 'Parent/Guardian', // You can make this configurable
        location: null, // Location not currently used
        notes: null, // You can add a notes field to the UI
        symptoms: null, // You can add symptoms selection to the UI
        createdAt: DateTime.now(),
      );

      // Save to Firestore
      final docRef = await FirebaseFirestore.instance
          .collection('temperatures')
          .add(temperatureData.toJson());

      // Update the ID with the document ID
      await docRef.update({'id': docRef.id});

      Get.snackbar(
        'Success',
        'Temperature recorded for ${_selectedKidForTemperature!.name}: $temperature°C',
        duration: const Duration(seconds: 3),
      );

      Get.offAllNamed(AppRoutes.home);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to save temperature: ${e.toString()}',
        duration: const Duration(seconds: 5),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final KidController kidController = Get.find<KidController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Temperature Tracking'),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Child Selection Header
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Select Child',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                        const SizedBox(height: 12),
                        Obx(() {
                          final kids = kidController.kids;
                          if (kids.isEmpty) {
                            return const Text('No children added yet');
                          }
                          return DropdownButtonFormField<KidData>(
                            value: _selectedKidForTemperature,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                            ),
                            hint: const Text('Choose a child'),
                            items: kids.map((kid) {
                              return DropdownMenuItem<KidData>(
                                value: kid,
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 16,
                                      backgroundColor:
                                          Theme.of(context).colorScheme.primary,
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
                            onChanged: (KidData? newValue) {
                              setState(() {
                                _selectedKidForTemperature = newValue;
                              });
                            },
                          );
                        }),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                if (_selectedKidForTemperature != null)
                  Text(
                    'Recording temperature for ${_selectedKidForTemperature!.name}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                const SizedBox(height: 20),
                TextField(
                  controller: _temperatureController,
                  decoration: const InputDecoration(
                    labelText: 'Temperature (°C)',
                    border: OutlineInputBorder(),
                    hintText: 'e.g., 36.5',
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Date: ${_selectedDate.toLocal().toString().split(' ')[0]}',
                      ),
                    ),
                    TextButton(
                      onPressed: () => _selectDate(context),
                      child: const Text('Select Date'),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Time: ${_selectedTime.format(context)}',
                      ),
                    ),
                    TextButton(
                      onPressed: () => _selectTime(context),
                      child: const Text('Select Time'),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: _saveTemperature,
                  child: const Text('Save Temperature'),
                ),
                if (_selectedKidForTemperature != null) ...[
                  const SizedBox(height: 40),
                  Text(
                    'Previous Records',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 20),
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('temperatures')
                        .where('kidId',
                            isEqualTo: _selectedKidForTemperature!.id)
                        .orderBy('measurementDate', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      }
                      if (snapshot.hasError) {
                        print('Firebase Error: ${snapshot.error}');
                        return Text('Error: ${snapshot.error}');
                      }
                      final docs = snapshot.data!.docs;
                      if (docs.isEmpty) {
                        return const Text('No previous records');
                      }
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: docs.length,
                        itemBuilder: (context, index) {
                          final data =
                              docs[index].data() as Map<String, dynamic>;
                          final temp = TemperatureData.fromJson(data);
                          return Card(
                            child: ListTile(
                              title: Text(
                                  '${temp.temperature}°C - ${temp.temperatureStatus}'),
                              subtitle: Text(temp.location != null
                                  ? '${temp.measurementDate.toLocal()} - ${temp.location}'
                                  : '${temp.measurementDate.toLocal()}'),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
