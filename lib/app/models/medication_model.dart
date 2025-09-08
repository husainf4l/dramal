import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum MedicationStatus {
  active,
  completed,
  paused,
  discontinued,
}

extension MedicationStatusExtension on MedicationStatus {
  String get displayName {
    switch (this) {
      case MedicationStatus.active:
        return 'Active';
      case MedicationStatus.completed:
        return 'Completed';
      case MedicationStatus.paused:
        return 'Paused';
      case MedicationStatus.discontinued:
        return 'Discontinued';
    }
  }

  Color get color {
    switch (this) {
      case MedicationStatus.active:
        return Colors.green;
      case MedicationStatus.completed:
        return Colors.blue;
      case MedicationStatus.paused:
        return Colors.orange;
      case MedicationStatus.discontinued:
        return Colors.red;
    }
  }
}

class MedicationData {
  final String id;
  final String kidId;
  final String medicationName;
  final String genericName;
  final String dosage;
  final String frequency;
  final Duration duration;
  final DateTime startDate;
  final DateTime endDate;
  final String prescribedBy;
  final String pharmacyName;
  final String pharmacyPhone;
  final String instructions;
  final String sideEffects;
  final MedicationStatus status;
  final int remainingDoses;
  final int totalDoses;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  MedicationData({
    required this.id,
    required this.kidId,
    required this.medicationName,
    required this.genericName,
    required this.dosage,
    required this.frequency,
    required this.duration,
    required this.startDate,
    required this.endDate,
    required this.prescribedBy,
    required this.pharmacyName,
    required this.pharmacyPhone,
    required this.instructions,
    required this.sideEffects,
    required this.status,
    required this.remainingDoses,
    required this.totalDoses,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  // Calculate progress percentage
  double get progressPercentage {
    if (totalDoses == 0) return 0.0;
    final usedDoses = totalDoses - remainingDoses;
    return (usedDoses / totalDoses) * 100;
  }

  // Check if medication is expired
  bool get isExpired {
    return DateTime.now().isAfter(endDate);
  }

  // Check if medication is running low
  bool get isRunningLow {
    if (totalDoses == 0) return false;
    return remainingDoses / totalDoses < 0.2; // Less than 20% remaining
  }

  // Get days remaining
  int get daysRemaining {
    final now = DateTime.now();
    if (now.isAfter(endDate)) return 0;
    return endDate.difference(now).inDays;
  }

  // Get formatted duration
  String get formattedDuration {
    final days = duration.inDays;
    if (days < 7) return '$days days';
    if (days < 30) return '${(days / 7).round()} weeks';
    return '${(days / 30).round()} months';
  }

  // Get next dose time (simplified - assumes regular intervals)
  DateTime? getNextDoseTime() {
    if (status != MedicationStatus.active || isExpired) return null;

    // This is a simplified calculation - real implementation would track actual doses
    final now = DateTime.now();
    final timeSinceStart = now.difference(startDate).inHours;

    // Assume daily medication for simplicity
    final dosesPerDay = _getDosesPerDay();
    if (dosesPerDay == 0) return null;

    final hoursPerDose = 24 / dosesPerDay;
    final nextDoseHour = startDate.hour + (timeSinceStart / hoursPerDose).ceil() * hoursPerDose.toInt();

    return DateTime(
      now.year,
      now.month,
      now.day,
      nextDoseHour % 24,
      startDate.minute,
    );
  }

  int _getDosesPerDay() {
    final frequency = this.frequency.toLowerCase();
    if (frequency.contains('once daily') || frequency.contains('1 time')) return 1;
    if (frequency.contains('twice') || frequency.contains('2 times')) return 2;
    if (frequency.contains('three') || frequency.contains('3 times')) return 3;
    if (frequency.contains('four') || frequency.contains('4 times')) return 4;
    if (frequency.contains('as needed')) return 0; // PRN medications
    return 1; // Default to once daily
  }

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'kidId': kidId,
      'medicationName': medicationName,
      'genericName': genericName,
      'dosage': dosage,
      'frequency': frequency,
      'duration': duration.inDays,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'prescribedBy': prescribedBy,
      'pharmacyName': pharmacyName,
      'pharmacyPhone': pharmacyPhone,
      'instructions': instructions,
      'sideEffects': sideEffects,
      'status': status.name,
      'remainingDoses': remainingDoses,
      'totalDoses': totalDoses,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Create from JSON
  factory MedicationData.fromJson(Map<String, dynamic> json) {
    return MedicationData(
      id: json['id'],
      kidId: json['kidId'],
      medicationName: json['medicationName'],
      genericName: json['genericName'],
      dosage: json['dosage'],
      frequency: json['frequency'],
      duration: Duration(days: json['duration']),
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      prescribedBy: json['prescribedBy'],
      pharmacyName: json['pharmacyName'],
      pharmacyPhone: json['pharmacyPhone'],
      instructions: json['instructions'],
      sideEffects: json['sideEffects'],
      status: MedicationStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => MedicationStatus.active,
      ),
      remainingDoses: json['remainingDoses'],
      totalDoses: json['totalDoses'],
      notes: json['notes'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}

class MedicationController extends GetxController {
  final RxList<MedicationData> medications = <MedicationData>[].obs;
  final RxBool isLoading = false.obs;

  // Get medications for specific kid
  List<MedicationData> getMedicationsForKid(String kidId) {
    return medications.where((med) => med.kidId == kidId).toList();
  }

  // Get active medications
  List<MedicationData> get activeMedications {
    return medications.where((med) => med.status == MedicationStatus.active).toList();
  }

  // Get medications by status
  List<MedicationData> getMedicationsByStatus(MedicationStatus status) {
    return medications.where((med) => med.status == status).toList();
  }

  // Get medications running low
  List<MedicationData> get medicationsRunningLow {
    return medications.where((med) => med.isRunningLow && med.status == MedicationStatus.active).toList();
  }

  // Get expired medications
  List<MedicationData> get expiredMedications {
    return medications.where((med) => med.isExpired && med.status == MedicationStatus.active).toList();
  }

  // Add new medication
  void addMedication(MedicationData medication) {
    medications.add(medication);
    medications.sort((a, b) => a.endDate.compareTo(b.endDate));
  }

  // Update medication status
  void updateMedicationStatus(String medicationId, MedicationStatus newStatus) {
    final index = medications.indexWhere((med) => med.id == medicationId);
    if (index != -1) {
      final updatedMedication = MedicationData(
        id: medications[index].id,
        kidId: medications[index].kidId,
        medicationName: medications[index].medicationName,
        genericName: medications[index].genericName,
        dosage: medications[index].dosage,
        frequency: medications[index].frequency,
        duration: medications[index].duration,
        startDate: medications[index].startDate,
        endDate: medications[index].endDate,
        prescribedBy: medications[index].prescribedBy,
        pharmacyName: medications[index].pharmacyName,
        pharmacyPhone: medications[index].pharmacyPhone,
        instructions: medications[index].instructions,
        sideEffects: medications[index].sideEffects,
        status: newStatus,
        remainingDoses: medications[index].remainingDoses,
        totalDoses: medications[index].totalDoses,
        notes: medications[index].notes,
        createdAt: medications[index].createdAt,
        updatedAt: DateTime.now(),
      );
      medications[index] = updatedMedication;
    }
  }

  // Decrease remaining doses
  void decreaseRemainingDoses(String medicationId, int doses) {
    final index = medications.indexWhere((med) => med.id == medicationId);
    if (index != -1) {
      final current = medications[index];
      final newRemaining = (current.remainingDoses - doses).clamp(0, current.totalDoses);

      updateMedicationStatus(
        medicationId,
        newRemaining == 0 ? MedicationStatus.completed : current.status,
      );
    }
  }

  // Get next medication dose for kid
  MedicationData? getNextMedicationDose(String kidId) {
    final kidMedications = getMedicationsForKid(kidId)
      .where((med) => med.status == MedicationStatus.active && !med.isExpired)
      .toList();

    if (kidMedications.isEmpty) return null;

    // Find medication with next dose time
    MedicationData? nextMed;
    DateTime? nextDoseTime;

    for (final med in kidMedications) {
      final medNextDose = med.getNextDoseTime();
      if (medNextDose != null) {
        if (nextDoseTime == null || medNextDose.isBefore(nextDoseTime)) {
          nextDoseTime = medNextDose;
          nextMed = med;
        }
      }
    }

    return nextMed;
  }
}
