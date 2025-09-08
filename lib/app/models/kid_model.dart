// Kid Data model
import 'package:cloud_firestore/cloud_firestore.dart';

class KidData {
  final String id;
  final String userId; // Parent/Guardian user ID
  final String name;
  final DateTime dateOfBirth;
  final String? gender;
  final String? bloodType;
  final List<String>? allergies;
  final String address;
  final String? parentPhone;
  final String? emergencyContact;
  final String? emergencyPhone;
  final String? insuranceProvider;
  final String? insuranceNumber;
  final String? doctorName;
  final String? doctorPhone;
  final String? medicalNotes;
  final String? insuranceInfo;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  KidData({
    required this.id,
    required this.userId,
    required this.name,
    required this.dateOfBirth,
    this.gender,
    this.bloodType,
    this.allergies,
    required this.address,
    this.parentPhone,
    this.emergencyContact,
    this.emergencyPhone,
    this.insuranceProvider,
    this.insuranceNumber,
    this.doctorName,
    this.doctorPhone,
    this.medicalNotes,
    this.insuranceInfo,
    this.createdAt,
    this.updatedAt,
  });

  factory KidData.fromJson(Map<String, dynamic> json) {
    DateTime? dateOfBirth;
    DateTime? createdAt;
    DateTime? updatedAt;

    try {
      if (json['dateOfBirth'] != null) {
        if (json['dateOfBirth'] is String) {
          dateOfBirth = DateTime.parse(json['dateOfBirth']);
        } else if (json['dateOfBirth'] is Timestamp) {
          dateOfBirth = (json['dateOfBirth'] as Timestamp).toDate();
        }
      }
    } catch (e) {
      print('Error parsing dateOfBirth: $e, using current date');
      dateOfBirth = DateTime.now();
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

    return KidData(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      dateOfBirth: dateOfBirth ?? DateTime.now(),
      gender: json['gender']?.toString(),
      bloodType: json['bloodType']?.toString(),
      allergies: json['allergies'] != null ? List<String>.from(json['allergies']) : null,
      address: json['address']?.toString() ?? '',
      parentPhone: json['parentPhone']?.toString(),
      emergencyContact: json['emergencyContact']?.toString(),
      emergencyPhone: json['emergencyPhone']?.toString(),
      insuranceProvider: json['insuranceProvider']?.toString(),
      insuranceNumber: json['insuranceNumber']?.toString(),
      doctorName: json['doctorName']?.toString(),
      doctorPhone: json['doctorPhone']?.toString(),
      medicalNotes: json['medicalNotes']?.toString(),
      insuranceInfo: json['insuranceInfo']?.toString(),
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'gender': gender,
      'bloodType': bloodType,
      'allergies': allergies,
      'address': address,
      'parentPhone': parentPhone,
      'emergencyContact': emergencyContact,
      'emergencyPhone': emergencyPhone,
      'insuranceProvider': insuranceProvider,
      'insuranceNumber': insuranceNumber,
      'doctorName': doctorName,
      'doctorPhone': doctorPhone,
      'medicalNotes': medicalNotes,
      'insuranceInfo': insuranceInfo,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  // Method to convert to JSON for updates (includes ID)
  Map<String, dynamic> toJsonForUpdate() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'gender': gender,
      'bloodType': bloodType,
      'allergies': allergies,
      'address': address,
      'parentPhone': parentPhone,
      'emergencyContact': emergencyContact,
      'emergencyPhone': emergencyPhone,
      'insuranceProvider': insuranceProvider,
      'insuranceNumber': insuranceNumber,
      'doctorName': doctorName,
      'doctorPhone': doctorPhone,
      'medicalNotes': medicalNotes,
      'insuranceInfo': insuranceInfo,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  // Calculate age in years and months
  String get age {
    final now = DateTime.now();
    int years = now.year - dateOfBirth.year;
    int months = now.month - dateOfBirth.month;

    if (now.month < dateOfBirth.month ||
        (now.month == dateOfBirth.month && now.day < dateOfBirth.day)) {
      years--;
      months = 12 - dateOfBirth.month + now.month;
      if (now.day < dateOfBirth.day) {
        months--;
      }
    } else if (now.day < dateOfBirth.day) {
      months--;
    }

    if (months < 0) {
      months += 12;
      years--;
    }

    if (years == 0) {
      return '$months months';
    } else if (months == 0) {
      return '$years years';
    } else {
      return '$years years and $months months';
    }
  }

  // Get formatted date of birth
  String get formattedDateOfBirth {
    return '${dateOfBirth.day.toString().padLeft(2, '0')}/'
        '${dateOfBirth.month.toString().padLeft(2, '0')}/'
        '${dateOfBirth.year}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is KidData && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
