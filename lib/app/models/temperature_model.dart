import 'package:cloud_firestore/cloud_firestore.dart';

class TemperatureData {
  final String id;
  final String kidId;
  final double temperature; // in Celsius
  final DateTime measurementDate;
  final String measuredBy;
  final String? location;
  final String? notes;
  final List<String>? symptoms;
  final DateTime? createdAt;

  TemperatureData({
    required this.id,
    required this.kidId,
    required this.temperature,
    required this.measurementDate,
    required this.measuredBy,
    this.location,
    this.notes,
    this.symptoms,
    this.createdAt,
  });

  // Temperature status based on age-appropriate ranges
  String get temperatureStatus {
    if (temperature < 36.0) return 'Low';
    if (temperature <= 37.5) return 'Normal';
    if (temperature <= 38.5) return 'Mild Fever';
    if (temperature <= 39.5) return 'Moderate Fever';
    return 'High Fever';
  }

  // Get status color for UI
  String get statusColor {
    switch (temperatureStatus) {
      case 'Low':
        return 'blue';
      case 'Normal':
        return 'green';
      case 'Mild Fever':
        return 'yellow';
      case 'Moderate Fever':
        return 'orange';
      case 'High Fever':
        return 'red';
      default:
        return 'grey';
    }
  }

  // Convert to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'kidId': kidId,
      'temperature': temperature,
      'measurementDate': measurementDate.toIso8601String(),
      'measuredBy': measuredBy,
      'location': location,
      'notes': notes,
      'symptoms': symptoms,
      'createdAt':
          createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
    };
  }

  // Create from Firestore document
  factory TemperatureData.fromJson(Map<String, dynamic> json) {
    return TemperatureData(
      id: json['id'] ?? '',
      kidId: json['kidId'] ?? '',
      temperature: (json['temperature'] ?? 0.0).toDouble(),
      measurementDate: DateTime.parse(
          json['measurementDate'] ?? DateTime.now().toIso8601String()),
      measuredBy: json['measuredBy'] ?? '',
      location: json['location'],
      notes: json['notes'],
      symptoms:
          json['symptoms'] != null ? List<String>.from(json['symptoms']) : null,
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    );
  }

  // Create from Firestore document snapshot
  factory TemperatureData.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TemperatureData.fromJson({
      ...data,
      'id': doc.id,
    });
  }
}
