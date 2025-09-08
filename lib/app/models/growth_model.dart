import 'package:get/get.dart';

class GrowthData {
  final String id;
  final String kidId;
  final DateTime measurementDate;
  final double height; // in cm
  final double weight; // in kg
  final String measuredBy;
  final String location;
  final String? notes;

  GrowthData({
    required this.id,
    required this.kidId,
    required this.measurementDate,
    required this.height,
    required this.weight,
    required this.measuredBy,
    required this.location,
    this.notes,
  });

  // Calculate BMI
  double get bmi {
    final heightInMeters = height / 100;
    return weight / (heightInMeters * heightInMeters);
  }

  // Get BMI category using standard classifications
  String get bmiCategory {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal weight';
    if (bmi < 30) return 'Overweight';
    if (bmi < 35) return 'Obese Class I';
    if (bmi < 40) return 'Obese Class II';
    return 'Obese Class III';
  }

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'kidId': kidId,
      'measurementDate': measurementDate.toIso8601String(),
      'height': height,
      'weight': weight,
      'measuredBy': measuredBy,
      'location': location,
      'notes': notes,
    };
  }

  // Create from JSON
  factory GrowthData.fromJson(Map<String, dynamic> json) {
    return GrowthData(
      id: json['id'],
      kidId: json['kidId'],
      measurementDate: DateTime.parse(json['measurementDate']),
      height: json['height'].toDouble(),
      weight: json['weight'].toDouble(),
      measuredBy: json['measuredBy'],
      location: json['location'],
      notes: json['notes'],
    );
  }
}

class GrowthController extends GetxController {
  final RxList<GrowthData> growthData = <GrowthData>[].obs;
  final RxBool isLoading = false.obs;

  // Add new growth measurement
  void addGrowthMeasurement(GrowthData measurement) {
    growthData.add(measurement);
    // Sort by date (most recent first)
    growthData.sort((a, b) => b.measurementDate.compareTo(a.measurementDate));
  }

  // Get latest measurement
  GrowthData? get latestMeasurement {
    return growthData.isNotEmpty ? growthData.first : null;
  }

  // Get growth data for specific kid
  List<GrowthData> getGrowthDataForKid(String kidId) {
    return growthData.where((data) => data.kidId == kidId).toList();
  }

  // Calculate growth percentiles (simplified)
  Map<String, double> getGrowthPercentiles(String kidId) {
    final kidData = getGrowthDataForKid(kidId);
    if (kidData.isEmpty) return {};

    final latest = kidData.first;
    // Simplified percentile calculation (would normally use CDC data)
    final heightPercentile = _calculatePercentile(
        latest.height, kidData.map((d) => d.height).toList());
    final weightPercentile = _calculatePercentile(
        latest.weight, kidData.map((d) => d.weight).toList());

    return {
      'height': heightPercentile,
      'weight': weightPercentile,
      'bmi': latest.bmi,
    };
  }

  double _calculatePercentile(double value, List<double> values) {
    if (values.isEmpty) return 50.0;
    values.sort();
    final index = values.indexWhere((v) => v >= value);
    if (index == -1) return 100.0;
    return (index / values.length) * 100;
  }
}
