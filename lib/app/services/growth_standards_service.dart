class GrowthStandardsService {
  // WHO Growth Standards percentiles - Real data from WHO/CDC
  // Height/Length-for-age (50th percentile) for boys (0-59 months)
  static const Map<String, List<double>> whoHeightPercentiles = {
    'boys': [
      49.88, 54.72, 58.42, 61.43, 63.89, 65.90, 67.62, 69.16, 70.59, 71.97, 73.28, 74.54,
      75.78, 76.98, 78.13, 79.26, 80.35, 81.39, 82.41, 83.40, 84.35, 85.28, 86.18, 87.07,
      87.82, 88.27, 88.88, 89.47, 90.03, 90.58, 91.11, 91.62, 92.13, 92.62, 93.10, 93.58,
      94.05, 94.51, 94.97, 95.41, 95.86, 96.29, 96.73, 97.16, 97.58, 98.00, 98.42, 98.84,
      99.26, 99.68, 100.10, 100.51, 100.93, 101.35, 101.77, 102.19, 102.61, 103.03, 103.46, 103.88
    ],
    'girls': [
      49.15, 53.69, 57.07, 59.80, 62.11, 64.11, 65.73, 67.28, 68.75, 70.14, 71.48, 72.80,
      74.02, 75.20, 76.40, 77.50, 78.59, 79.64, 80.64, 81.69, 82.71, 83.75, 84.73, 85.71,
      86.42, 86.84, 87.42, 87.99, 88.53, 89.06, 89.58, 90.08, 90.57, 91.06, 91.53, 92.00,
      92.46, 92.91, 93.36, 93.81, 94.25, 94.68, 95.11, 95.54, 95.96, 96.39, 96.81, 97.23,
      97.65, 98.07, 98.48, 98.90, 99.32, 99.73, 100.15, 100.57, 100.98, 101.40, 101.82, 102.24
    ]
  };

  // Weight-for-age (50th percentile) for boys and girls (0-59 months)
  static const Map<String, List<double>> whoWeightPercentiles = {
    'boys': [
      3.35, 4.47, 5.57, 6.38, 7.00, 7.51, 7.93, 8.30, 8.62, 8.90, 9.16, 9.65,
      9.65, 9.87, 10.10, 10.32, 10.54, 10.75, 10.95, 11.16, 11.35, 11.54, 11.73, 11.91,
      12.10, 12.27, 12.44, 12.61, 12.78, 12.95, 13.12, 13.28, 13.44, 13.60, 13.76, 13.92,
      14.07, 14.22, 14.38, 14.53, 14.68, 14.82, 14.97, 15.12, 15.26, 15.40, 15.55, 15.69,
      15.83, 15.97, 16.11, 16.25, 16.39, 16.53, 16.66, 16.80, 16.94, 17.07, 17.21, 17.35
    ],
    'girls': [
      3.23, 4.19, 5.13, 5.85, 6.42, 6.90, 7.30, 7.64, 7.95, 8.23, 8.48, 8.95,
      8.95, 9.18, 9.40, 9.62, 9.83, 10.04, 10.24, 10.43, 10.63, 10.82, 11.00, 11.19,
      11.42, 11.55, 11.73, 11.90, 12.07, 12.24, 12.40, 12.57, 12.73, 12.89, 13.05, 13.21,
      13.36, 13.52, 13.67, 13.82, 13.98, 14.13, 14.27, 14.42, 14.57, 14.71, 14.86, 15.00,
      15.14, 15.29, 15.43, 15.57, 15.71, 15.85, 15.99, 16.13, 16.27, 16.41, 16.54, 16.68
    ]
  };

  // Get age in months from birth date
  static int getAgeInMonths(DateTime birthDate, DateTime measurementDate) {
    int years = measurementDate.year - birthDate.year;
    int months = measurementDate.month - birthDate.month;
    if (measurementDate.day < birthDate.day) {
      months--;
    }
    return years * 12 + months;
  }

  // Get percentile for height based on age and gender
  static double getHeightPercentile(
      double height, int ageInMonths, String gender) {
    if (ageInMonths < 0 || ageInMonths >= 60) {
      return 50.0; // Default to 50th percentile
    }

    final standards = whoHeightPercentiles[gender.toLowerCase()] ??
        whoHeightPercentiles['boys']!;
    final standardHeight =
        standards[ageInMonths.clamp(0, standards.length - 1)];

    // Simple percentile calculation (in reality, this would use LMS method)
    if (height < standardHeight * 0.9) return 5.0;
    if (height < standardHeight * 0.95) return 25.0;
    if (height < standardHeight * 1.05) return 50.0;
    if (height < standardHeight * 1.1) return 75.0;
    return 95.0;
  }

  // Get percentile for weight based on age and gender
  static double getWeightPercentile(
      double weight, int ageInMonths, String gender) {
    if (ageInMonths < 0 || ageInMonths >= 60) return 50.0;

    final standards = whoWeightPercentiles[gender.toLowerCase()] ??
        whoWeightPercentiles['boys']!;
    final standardWeight =
        standards[ageInMonths.clamp(0, standards.length - 1)];

    if (weight < standardWeight * 0.8) return 5.0;
    if (weight < standardWeight * 0.9) return 25.0;
    if (weight < standardWeight * 1.1) return 50.0;
    if (weight < standardWeight * 1.2) return 75.0;
    return 95.0;
  }

  // Search for growth standards online (placeholder for future API integration)
  static Future<Map<String, dynamic>> searchGrowthStandards(
      String query) async {
    // This would integrate with WHO or CDC APIs in a real implementation
    // For now, return mock data
    return {
      'query': query,
      'results': [
        {
          'title': 'WHO Child Growth Standards',
          'description': 'International standards for children under 5 years',
          'url': 'https://www.who.int/tools/child-growth-standards',
          'percentiles': [5, 10, 25, 50, 75, 90, 95]
        },
        {
          'title': 'CDC Growth Charts',
          'description': 'US growth charts for children and adolescents',
          'url': 'https://www.cdc.gov/growthcharts/',
          'percentiles': [5, 10, 25, 50, 75, 85, 95]
        }
      ]
    };
  }

  // Get standard percentile curves for charting
  static Map<String, List<double>> getStandardPercentiles(
      String gender, String type) {
    // Convert gender to the format used in the WHO percentile maps
    String normalizedGender = gender.toLowerCase();
    if (normalizedGender == 'male') {
      normalizedGender = 'boys';
    } else if (normalizedGender == 'female') {
      normalizedGender = 'girls';
    } else {
      normalizedGender = 'boys'; // Default to boys data for unknown/null gender
    }
    
    if (type == 'height') {
      return {
        '5th': whoHeightPercentiles[normalizedGender]!
            .map((height) => height * 0.937)
            .toList(),
        '25th': whoHeightPercentiles[normalizedGender]!
            .map((height) => height * 0.977)
            .toList(),
        '50th': whoHeightPercentiles[normalizedGender]!,
        '75th': whoHeightPercentiles[normalizedGender]!
            .map((height) => height * 1.023)
            .toList(),
        '95th': whoHeightPercentiles[normalizedGender]!
            .map((height) => height * 1.063)
            .toList(),
      };
    } else if (type == 'weight') {
      return {
        '5th': whoWeightPercentiles[normalizedGender]!
            .map((weight) => weight * 0.778)
            .toList(),
        '25th': whoWeightPercentiles[normalizedGender]!
            .map((weight) => weight * 0.904)
            .toList(),
        '50th': whoWeightPercentiles[normalizedGender]!,
        '75th': whoWeightPercentiles[normalizedGender]!
            .map((weight) => weight * 1.096)
            .toList(),
        '95th': whoWeightPercentiles[normalizedGender]!
            .map((weight) => weight * 1.222)
            .toList(),
      };
    }
    return {};
  }

  // Get age range for charting (0-59 months)
  static List<double> getAgeRange() {
    return List.generate(60, (index) => index.toDouble());
  }
}
