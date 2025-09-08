import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/kid_controller.dart';
import '../models/kid_model.dart';
import '../routes/app_routes.dart';

class EditKidView extends StatelessWidget {
  const EditKidView({super.key});

  @override
  Widget build(BuildContext context) {
    final KidController kidController = Get.find<KidController>();
    final KidData kidData = Get.arguments as KidData;

    final _formKey = GlobalKey<FormState>();
    final _nameController = TextEditingController(text: kidData.name);
    final _addressController = TextEditingController(text: kidData.address);
    final _insuranceController =
        TextEditingController(text: kidData.insuranceInfo ?? '');
    final Rx<DateTime> _selectedDate = Rx<DateTime>(kidData.dateOfBirth);
    final Rx<String?> _selectedGender = Rx<String?>(kidData.gender);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Kid Profile'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Kid's Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Kid\'s Name *',
                  hintText: 'Enter the child\'s full name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter the kid\'s name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Date of Birth
              Obx(() => InkWell(
                    onTap: () async {
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate.value,
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
                      );
                      if (pickedDate != null) {
                        _selectedDate.value = pickedDate;
                      }
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Date of Birth *',
                        hintText: 'Select date of birth',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      child: Text(
                        '${_selectedDate.value.day.toString().padLeft(2, '0')}/'
                        '${_selectedDate.value.month.toString().padLeft(2, '0')}/'
                        '${_selectedDate.value.year}',
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                    ),
                  )),
              const SizedBox(height: 24),

              // Gender
              Obx(() => DropdownButtonFormField<String>(
                    value: _selectedGender.value,
                    decoration: const InputDecoration(
                      labelText: 'Gender',
                      hintText: 'Select gender',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Male', child: Text('Male')),
                      DropdownMenuItem(value: 'Female', child: Text('Female')),
                    ],
                    onChanged: (value) {
                      _selectedGender.value = value;
                    },
                  )),
              const SizedBox(height: 24),

              // Address
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Address *',
                  hintText: 'Enter the child\'s address',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter the address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Insurance Info (Optional)
              TextFormField(
                controller: _insuranceController,
                decoration: const InputDecoration(
                  labelText: 'Insurance Information',
                  hintText: 'Enter insurance details (optional)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.health_and_safety),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 32),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: Obx(() => ElevatedButton(
                      onPressed: kidController.isSaving.value
                          ? null
                          : () async {
                              if (_formKey.currentState!.validate()) {
                                final updatedKidData = KidData(
                                  id: kidData.id,
                                  userId: kidData.userId,
                                  name: _nameController.text.trim(),
                                  dateOfBirth: _selectedDate.value,
                                  gender: _selectedGender.value,
                                  bloodType: kidData.bloodType,
                                  allergies: kidData.allergies,
                                  address: _addressController.text.trim(),
                                  parentPhone: kidData.parentPhone,
                                  emergencyContact: kidData.emergencyContact,
                                  emergencyPhone: kidData.emergencyPhone,
                                  insuranceProvider: kidData.insuranceProvider,
                                  insuranceNumber: kidData.insuranceNumber,
                                  doctorName: kidData.doctorName,
                                  doctorPhone: kidData.doctorPhone,
                                  medicalNotes: kidData.medicalNotes,
                                  insuranceInfo:
                                      _insuranceController.text.trim().isEmpty
                                          ? null
                                          : _insuranceController.text.trim(),
                                  createdAt: kidData.createdAt,
                                );

                                final success = await kidController
                                    .updateKid(updatedKidData);
                                if (success) {
                                  // Navigate to home screen
                                  Get.offAllNamed(AppRoutes.home);
                                }
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: kidController.isSaving.value
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'Update Kid Profile',
                              style: TextStyle(fontSize: 16),
                            ),
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
