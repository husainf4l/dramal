// Vaccine Data model
import 'package:cloud_firestore/cloud_firestore.dart';

class VaccineData {
  final String id;
  final String name;
  final String description;
  final int recommendedAgeMonths; // Age in months when vaccine is recommended
  final int? boosterIntervalMonths; // Interval for booster shots (optional)
  final bool isRequired;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  VaccineData({
    required this.id,
    required this.name,
    required this.description,
    required this.recommendedAgeMonths,
    this.boosterIntervalMonths,
    this.isRequired = true,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  factory VaccineData.fromJson(Map<String, dynamic> json) {
    return VaccineData(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      recommendedAgeMonths: json['recommendedAgeMonths'] ?? 0,
      boosterIntervalMonths: json['boosterIntervalMonths'],
      isRequired: json['isRequired'] ?? true,
      notes: json['notes']?.toString(),
      createdAt: json['createdAt'] != null
          ? json['createdAt'] is String
              ? DateTime.parse(json['createdAt'])
              : (json['createdAt'] as Timestamp).toDate()
          : null,
      updatedAt: json['updatedAt'] != null
          ? json['updatedAt'] is String
              ? DateTime.parse(json['updatedAt'])
              : (json['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'recommendedAgeMonths': recommendedAgeMonths,
      'boosterIntervalMonths': boosterIntervalMonths,
      'isRequired': isRequired,
      'notes': notes,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  // Get recommended age in years and months
  String get formattedRecommendedAge {
    final years = recommendedAgeMonths ~/ 12;
    final months = recommendedAgeMonths % 12;

    if (years > 0 && months > 0) {
      return '$years years $months months';
    } else if (years > 0) {
      return '$years years';
    } else {
      return '$months months';
    }
  }
}

// Vaccine Record model (tracks when a vaccine was given to a specific kid)
class VaccineRecord {
  final String id;
  final String kidId;
  final String vaccineId;
  final DateTime administeredDate;
  final String? administeredBy; // Doctor or clinic name
  final String? batchNumber;
  final String? notes;
  final bool isBooster;
  final DateTime? nextDueDate; // For booster shots
  final DateTime? createdAt;
  final DateTime? updatedAt;

  VaccineRecord({
    required this.id,
    required this.kidId,
    required this.vaccineId,
    required this.administeredDate,
    this.administeredBy,
    this.batchNumber,
    this.notes,
    this.isBooster = false,
    this.nextDueDate,
    this.createdAt,
    this.updatedAt,
  });

  factory VaccineRecord.fromJson(Map<String, dynamic> json) {
    DateTime? administeredDate;
    DateTime? nextDueDate;
    DateTime? createdAt;
    DateTime? updatedAt;

    try {
      if (json['administeredDate'] != null) {
        if (json['administeredDate'] is String) {
          administeredDate = DateTime.parse(json['administeredDate']);
        } else if (json['administeredDate'] is Timestamp) {
          administeredDate = (json['administeredDate'] as Timestamp).toDate();
        }
      }
    } catch (e) {
      print('Error parsing administeredDate: $e');
      administeredDate = DateTime.now();
    }

    try {
      if (json['nextDueDate'] != null) {
        if (json['nextDueDate'] is String) {
          nextDueDate = DateTime.parse(json['nextDueDate']);
        } else if (json['nextDueDate'] is Timestamp) {
          nextDueDate = (json['nextDueDate'] as Timestamp).toDate();
        }
      }
    } catch (e) {
      print('Error parsing nextDueDate: $e');
      nextDueDate = null;
    }

    try {
      if (json['createdAt'] != null) {
        if (json['createdAt'] is String) {
          createdAt = DateTime.parse(json['createdAt']);
        } else if (json['createdAt'] is Timestamp) {
          createdAt = (json['createdAt'] as Timestamp).toDate();
        }
      }
    } catch (e) {
      print('Error parsing createdAt: $e');
      createdAt = null;
    }

    try {
      if (json['updatedAt'] != null) {
        if (json['updatedAt'] is String) {
          updatedAt = DateTime.parse(json['updatedAt']);
        } else if (json['updatedAt'] is Timestamp) {
          updatedAt = (json['updatedAt'] as Timestamp).toDate();
        }
      }
    } catch (e) {
      print('Error parsing updatedAt: $e');
      updatedAt = null;
    }

    return VaccineRecord(
      id: json['id']?.toString() ?? '',
      kidId: json['kidId']?.toString() ?? '',
      vaccineId: json['vaccineId']?.toString() ?? '',
      administeredDate: administeredDate ?? DateTime.now(),
      administeredBy: json['administeredBy']?.toString(),
      batchNumber: json['batchNumber']?.toString(),
      notes: json['notes']?.toString(),
      isBooster: json['isBooster'] ?? false,
      nextDueDate: nextDueDate,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'kidId': kidId,
      'vaccineId': vaccineId,
      'administeredDate': administeredDate.toIso8601String(),
      'administeredBy': administeredBy,
      'batchNumber': batchNumber,
      'notes': notes,
      'isBooster': isBooster,
      'nextDueDate': nextDueDate?.toIso8601String(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  // Get formatted administered date
  String get formattedAdministeredDate {
    return '${administeredDate.day.toString().padLeft(2, '0')}/'
        '${administeredDate.month.toString().padLeft(2, '0')}/'
        '${administeredDate.year}';
  }

  // Check if next dose is due
  bool get isNextDoseDue {
    if (nextDueDate == null) return false;
    return nextDueDate!.isBefore(DateTime.now());
  }

  // Get days until next dose
  int? get daysUntilNextDose {
    if (nextDueDate == null) return null;
    return nextDueDate!.difference(DateTime.now()).inDays;
  }
}

// Combined model for vaccine status (vaccine + records for a specific kid)
class KidVaccineStatus {
  final VaccineData vaccine;
  final List<VaccineRecord> records;
  final bool isCompleted;
  final DateTime? lastAdministeredDate;
  final DateTime? nextDueDate;
  final String status; // 'completed', 'due', 'overdue', 'upcoming'

  KidVaccineStatus({
    required this.vaccine,
    required this.records,
    required this.isCompleted,
    this.lastAdministeredDate,
    this.nextDueDate,
    required this.status,
  });

  // Get the most recent record
  VaccineRecord? get latestRecord {
    if (records.isEmpty) return null;
    return records.reduce(
        (a, b) => a.administeredDate.isAfter(b.administeredDate) ? a : b);
  }

  // Check if vaccine is overdue
  bool get isOverdue {
    if (nextDueDate == null) return false;
    return nextDueDate!.isBefore(DateTime.now());
  }

  // Get status color for UI
  String get statusColor {
    switch (status) {
      case 'completed':
        return 'green';
      case 'due':
        return 'orange';
      case 'overdue':
        return 'red';
      case 'upcoming':
        return 'blue';
      default:
        return 'grey';
    }
  }
}
