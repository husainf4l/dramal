// User Data model
class UserData {
  final String id;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? avatar;
  final DateTime? createdAt;

  UserData({
    required this.id,
    required this.email,
    this.firstName,
    this.lastName,
    this.avatar,
    this.createdAt,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      firstName: json['firstName']?.toString(),
      lastName: json['lastName']?.toString(),
      avatar: json['avatar']?.toString(),
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'avatar': avatar,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  String get fullName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    } else if (firstName != null) {
      return firstName!;
    } else if (lastName != null) {
      return lastName!;
    }
    return email;
  }
}

// Auth Response model (simplified for Firebase)
class AuthResponse {
  final String accessToken;
  final String? refreshToken;
  final UserData user;

  AuthResponse({
    required this.accessToken,
    this.refreshToken,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: json['accessToken']?.toString() ??
          json['access_token']?.toString() ??
          json['token']?.toString() ??
          '',
      refreshToken:
          json['refreshToken']?.toString() ?? json['refresh_token']?.toString(),
      user: UserData.fromJson(json['user'] ?? {}),
    );
  }
}
