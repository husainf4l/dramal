import 'dart:math';
import 'package:flutter/material.dart';
import '../models/kid_model.dart';
import '../models/vaccine_model.dart';
import '../models/growth_model.dart';
import '../models/appointment_model.dart';
import '../models/medication_model.dart';

class DemoDataProvider {
  static final Random _random = Random();

  // Demo Kids Data
  static List<KidData> getDemoKids() {
    return [
      KidData(
        id: '1',
        userId: 'demo_user_1',
        name: 'Emma Johnson',
        dateOfBirth: DateTime(2023, 3, 15),
        gender: 'Female',
        bloodType: 'O+',
        allergies: ['Peanuts', 'Shellfish'],
        address: '123 Maple Street, Springfield',
        parentPhone: '+1 (555) 123-4567',
        emergencyContact: 'Sarah Johnson (Mother)',
        emergencyPhone: '+1 (555) 123-4568',
        insuranceProvider: 'Blue Cross Blue Shield',
        insuranceNumber: 'BCBS123456789',
        doctorName: 'Dr. Amal Damara',
        doctorPhone: '+1 (555) 987-6543',
        medicalNotes: 'Born at 7 lbs 8 oz. No complications.',
        createdAt: DateTime.now().subtract(const Duration(days: 180)),
      ),
      KidData(
        id: '2',
        userId: 'demo_user_1',
        name: 'Lucas Martinez',
        dateOfBirth: DateTime(2022, 8, 22),
        gender: 'Male',
        bloodType: 'A+',
        allergies: ['Dust mites'],
        address: '456 Oak Avenue, Springfield',
        parentPhone: '+1 (555) 234-5678',
        emergencyContact: 'Maria Martinez (Mother)',
        emergencyPhone: '+1 (555) 234-5679',
        insuranceProvider: 'Aetna Health',
        insuranceNumber: 'AET987654321',
        doctorName: 'Dr. Amal Damara',
        doctorPhone: '+1 (555) 987-6543',
        medicalNotes: 'Had RSV at 3 months. Fully recovered.',
        createdAt: DateTime.now().subtract(const Duration(days: 365)),
      ),
      KidData(
        id: '3',
        userId: 'demo_user_1',
        name: 'Sophia Patel',
        dateOfBirth: DateTime(2021, 12, 3),
        gender: 'Female',
        bloodType: 'B+',
        allergies: [],
        address: '789 Pine Road, Springfield',
        parentPhone: '+1 (555) 345-6789',
        emergencyContact: 'Priya Patel (Mother)',
        emergencyPhone: '+1 (555) 345-6790',
        insuranceProvider: 'United Healthcare',
        insuranceNumber: 'UHC456789123',
        doctorName: 'Dr. Amal Damara',
        doctorPhone: '+1 (555) 987-6543',
        medicalNotes: 'Excellent health overall. Regular checkups.',
        createdAt: DateTime.now().subtract(const Duration(days: 730)),
      ),
    ];
  }

  // Demo Vaccine Data
  static List<VaccineData> getDemoVaccines() {
    return [
      VaccineData(
        id: 'dtap',
        name: 'DTaP',
        description: 'Diphtheria, Tetanus, Pertussis',
        recommendedAgeMonths: 2,
        isRequired: true,
      ),
      VaccineData(
        id: 'hepb',
        name: 'Hepatitis B',
        description: 'Hepatitis B Virus',
        recommendedAgeMonths: 0, // Birth
        isRequired: true,
      ),
      VaccineData(
        id: 'hib',
        name: 'Hib',
        description: 'Haemophilus influenzae type b',
        recommendedAgeMonths: 2,
        isRequired: true,
      ),
      VaccineData(
        id: 'pcv13',
        name: 'PCV13',
        description: 'Pneumococcal Conjugate',
        recommendedAgeMonths: 2,
        isRequired: true,
      ),
      VaccineData(
        id: 'ipv',
        name: 'IPV',
        description: 'Inactivated Poliovirus',
        recommendedAgeMonths: 2,
        isRequired: true,
      ),
      VaccineData(
        id: 'rv',
        name: 'RV',
        description: 'Rotavirus',
        recommendedAgeMonths: 2,
        isRequired: false, // Optional
      ),
    ];
  }

  // Demo Growth Data
  static List<GrowthData> getDemoGrowthData(String kidId) {
    final List<GrowthData> growthData = [];
    final kids = getDemoKids();

    // Find the kid by ID, or return empty list if not found
    if (kids.isEmpty) {
      return [];
    }
    final kid = kids.firstWhere(
      (k) => k.id == kidId,
      orElse: () => kids.first,
    );

    // Generate growth data from birth to current date
    final now = DateTime.now();
    final birthDate = kid.dateOfBirth;
    final totalDays = now.difference(birthDate).inDays;

    for (int i = 0; i <= totalDays; i += 30) {
      // Every 30 days
      final measurementDate = birthDate.add(Duration(days: i));

      // Generate realistic growth data based on age
      final ageInMonths = i / 30.44;
      final height = _calculateHeightForAge(ageInMonths);
      final weight = _calculateWeightForAge(ageInMonths);

      growthData.add(GrowthData(
        id: '${kidId}_growth_$i',
        kidId: kidId,
        measurementDate: measurementDate,
        height: height + _random.nextDouble() * 2 - 1, // ±1 variation
        weight: weight + _random.nextDouble() * 0.5 - 0.25, // ±0.25 variation

        measuredBy: 'Dr. Amal Damara',
        location: 'Springfield Medical Center',
        notes: i == 0
            ? 'Birth measurements'
            : i % 180 == 0
                ? 'Annual checkup'
                : 'Regular visit',
      ));
    }

    return growthData.reversed.toList(); // Most recent first
  }

  // Demo Appointments Data
  static List<AppointmentData> getDemoAppointments(String kidId) {
    final kids = getDemoKids();

    // Check if kid exists, if not return empty list
    if (!kids.any((k) => k.id == kidId)) {
      return [];
    }

    return [
      AppointmentData(
        id: 'appt_1',
        kidId: kidId,
        doctorName: 'Dr. Amal Damara',
        doctorSpecialty: 'Pediatric Dermatologist',
        clinicName: 'Dr. Amal Damara Clinic',
        appointmentDate: DateTime.now().add(const Duration(days: 7)),
        appointmentTime: const TimeOfDay(hour: 10, minute: 30),
        duration: const Duration(minutes: 30),
        appointmentType: 'Well-child checkup',
        reason: '6-month wellness visit',
        status: AppointmentStatus.scheduled,
        location: '456 Health Plaza, Springfield, IL 62702',
        phoneNumber: '+1 (555) 987-6543',
        notes: 'Bring vaccination records and growth chart',
        createdAt: DateTime.now().subtract(const Duration(days: 14)),
        updatedAt: DateTime.now(),
      ),
      AppointmentData(
        id: 'appt_2',
        kidId: kidId,
        doctorName: 'Dr. Amal Damara',
        doctorSpecialty: 'Pediatric Dermatologist',
        clinicName: 'Dr. Amal Damara Clinic',
        appointmentDate: DateTime.now().add(const Duration(days: 14)),
        appointmentTime: const TimeOfDay(hour: 14, minute: 0),
        duration: const Duration(minutes: 30),
        appointmentType: 'Skin check',
        reason: 'Eczema follow-up and skin assessment',
        status: AppointmentStatus.scheduled,
        location: '456 Health Plaza, Springfield, IL 62702',
        phoneNumber: '+1 (555) 987-6543',
        notes: 'Bring current skincare routine and any new rashes',
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
        updatedAt: DateTime.now(),
      ),
      AppointmentData(
        id: 'appt_3',
        kidId: kidId,
        doctorName: 'Dr. Amal Damara',
        doctorSpecialty: 'Pediatric Dermatologist',
        clinicName: 'Dr. Amal Damara Clinic',
        appointmentDate: DateTime.now().add(const Duration(days: 21)),
        appointmentTime: const TimeOfDay(hour: 11, minute: 15),
        duration: const Duration(minutes: 30),
        appointmentType: 'Acne consultation',
        reason: 'Adolescent acne assessment',
        status: AppointmentStatus.scheduled,
        location: '456 Health Plaza, Springfield, IL 62702',
        phoneNumber: '+1 (555) 987-6543',
        notes: 'Discuss hormonal changes and skincare routine',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        updatedAt: DateTime.now(),
      ),
    ];
  }

  // Demo Medication Data
  static List<MedicationData> getDemoMedications(String kidId) {
    final kids = getDemoKids();

    // Check if kid exists, if not return empty list
    if (!kids.any((k) => k.id == kidId)) {
      return [];
    }

    return [
      MedicationData(
        id: 'med_1',
        kidId: kidId,
        medicationName: 'Amoxicillin',
        genericName: 'Amoxicillin',
        dosage: '125mg',
        frequency: '3 times daily',
        duration: const Duration(days: 10),
        startDate: DateTime.now().subtract(const Duration(days: 3)),
        endDate: DateTime.now().add(const Duration(days: 7)),
        prescribedBy: 'Dr. Amal Damara',
        pharmacyName: 'Springfield Pharmacy',
        pharmacyPhone: '+1 (555) 456-7890',
        instructions: 'Take with food. Complete full course.',
        sideEffects: 'Mild stomach upset, diarrhea',
        status: MedicationStatus.active,
        remainingDoses: 21,
        totalDoses: 30,
        notes: 'Ear infection treatment',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        updatedAt: DateTime.now(),
      ),
      MedicationData(
        id: 'med_2',
        kidId: kidId,
        medicationName: 'Children\'s Ibuprofen',
        genericName: 'Ibuprofen',
        dosage: '50mg',
        frequency: 'As needed for fever >101°F',
        duration: const Duration(days: 30),
        startDate: DateTime.now().subtract(const Duration(days: 1)),
        endDate: DateTime.now().add(const Duration(days: 29)),
        prescribedBy: 'Dr. Amal Damara',
        pharmacyName: 'Springfield Pharmacy',
        pharmacyPhone: '+1 (555) 456-7890',
        instructions: 'Give every 6 hours as needed for pain/fever',
        sideEffects: 'Stomach upset (give with food)',
        status: MedicationStatus.active,
        remainingDoses: 24,
        totalDoses: 24,
        notes: 'Fever reducer and pain reliever',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        updatedAt: DateTime.now(),
      ),
      MedicationData(
        id: 'med_3',
        kidId: kidId,
        medicationName: 'Children\'s Loratadine',
        genericName: 'Loratadine',
        dosage: '5mg',
        frequency: 'Once daily',
        duration: const Duration(days: 60),
        startDate: DateTime.now().subtract(const Duration(days: 30)),
        endDate: DateTime.now().add(const Duration(days: 30)),
        prescribedBy: 'Dr. Amal Damara',
        pharmacyName: 'Springfield Pharmacy',
        pharmacyPhone: '+1 (555) 456-7890',
        instructions: 'Take once daily for seasonal allergies',
        sideEffects: 'Rare: drowsiness, dry mouth',
        status: MedicationStatus.active,
        remainingDoses: 30,
        totalDoses: 60,
        notes: 'Seasonal allergy treatment',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now(),
      ),
    ];
  }

  // Helper methods for realistic growth calculations
  static double _calculateHeightForAge(double ageInMonths) {
    if (ageInMonths <= 12) {
      // Birth to 1 year: rapid growth
      return 50 + (ageInMonths * 2.5);
    } else if (ageInMonths <= 24) {
      // 1-2 years: continued growth
      return 75 + ((ageInMonths - 12) * 1.8);
    } else if (ageInMonths <= 36) {
      // 2-3 years: steady growth
      return 93 + ((ageInMonths - 24) * 1.2);
    } else {
      // 3+ years: slower growth
      return 102 + ((ageInMonths - 36) * 0.8);
    }
  }

  static double _calculateWeightForAge(double ageInMonths) {
    if (ageInMonths <= 6) {
      // Birth to 6 months: rapid weight gain
      return 3.5 + (ageInMonths * 0.6);
    } else if (ageInMonths <= 12) {
      // 6-12 months: continued gain
      return 7.5 + ((ageInMonths - 6) * 0.4);
    } else if (ageInMonths <= 24) {
      // 1-2 years: steady gain
      return 10 + ((ageInMonths - 12) * 0.25);
    } else if (ageInMonths <= 36) {
      // 2-3 years: slower gain
      return 12.5 + ((ageInMonths - 24) * 0.2);
    } else {
      // 3+ years: gradual gain
      return 14.5 + ((ageInMonths - 36) * 0.15);
    }
  }
}
