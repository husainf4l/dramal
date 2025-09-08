import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'https://dramal.com/api';

  // Auth endpoints
  static const String registerEndpoint = '/auth/register';
  static const String loginEndpoint = '/auth/login';
  static const String googleMobileEndpoint = '/auth/google/mobile';
  static const String googleTokenEndpoint = '/auth/google/token';
  static const String appleMobileEndpoint = '/auth/apple/mobile';
  static const String appleTokenEndpoint = '/auth/apple/token';
  static const String refreshEndpoint = '/auth/refresh';
  static const String logoutEndpoint = '/auth/logout';

  // Payment endpoints
  static const String processPaymentEndpoint = '/payments/process';
  static const String subscriptionPlansEndpoint = '/subscriptions/plans';
  static const String subscriptionStatusEndpoint = '/subscriptions/status';

  // Get headers with auth token if available
  static Map<String, String> _getHeaders({String? token}) {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  // Register user
  static Future<ApiResponse<AuthResponse>> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$registerEndpoint'),
        headers: _getHeaders(),
        body: jsonEncode({
          'email': email,
          'password': password,
          'firstName': firstName,
          'lastName': lastName,
        }),
      );

      return _handleAuthResponse(response);
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }

  // Login user
  static Future<ApiResponse<AuthResponse>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$loginEndpoint'),
        headers: _getHeaders(),
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      return _handleAuthResponse(response);
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }

  // Google Sign-In (Mobile)
  static Future<ApiResponse<AuthResponse>> googleSignInMobile({
    required String idToken,
    required String email,
    String? firstName,
    String? lastName,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$googleMobileEndpoint'),
        headers: _getHeaders(),
        body: jsonEncode({
          'idToken': idToken,
          'email': email,
          'firstName': firstName,
          'lastName': lastName,
        }),
      );

      return _handleAuthResponse(response);
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }

  // Google Token
  static Future<ApiResponse<AuthResponse>> googleToken({
    required String token,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$googleTokenEndpoint'),
        headers: _getHeaders(),
        body: jsonEncode({
          'token': token,
        }),
      );

      return _handleAuthResponse(response);
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }

  // Apple Sign-In (Mobile)
  static Future<ApiResponse<AuthResponse>> appleSignInMobile({
    required String authorizationCode,
    required String identityToken,
    String? email,
    String? firstName,
    String? lastName,
  }) async {
    try {
      final requestBody = {
        'authorizationCode': authorizationCode,
        'identityToken': identityToken,
        'email': email,
        'firstName': firstName,
        'lastName': lastName,
      };

      // Debug logging
      print('Apple Sign-In API Request:');
      print('Email: $email');
      print('FirstName: $firstName');
      print('LastName: $lastName');
      print('AuthorizationCode length: ${authorizationCode.length}');
      print('IdentityToken length: ${identityToken.length}');

      final response = await http.post(
        Uri.parse('$baseUrl$appleMobileEndpoint'),
        headers: _getHeaders(),
        body: jsonEncode(requestBody),
      );

      return _handleAuthResponse(response);
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }

  // Apple Token
  static Future<ApiResponse<AuthResponse>> appleToken({
    required String token,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$appleTokenEndpoint'),
        headers: _getHeaders(),
        body: jsonEncode({
          'token': token,
        }),
      );

      return _handleAuthResponse(response);
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }

  // Refresh Token
  static Future<ApiResponse<AuthResponse>> refreshToken({
    required String refreshToken,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$refreshEndpoint'),
        headers: _getHeaders(),
        body: jsonEncode({
          'refreshToken': refreshToken,
        }),
      );

      return _handleAuthResponse(response);
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }

  // Logout
  static Future<ApiResponse<Map<String, dynamic>>> logout({
    required String token,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$logoutEndpoint'),
        headers: _getHeaders(token: token),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return ApiResponse.success({});
      } else {
        return ApiResponse.error('Logout failed: ${response.statusCode}');
      }
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }

  // Process subscription payment
  static Future<ApiResponse<Map<String, dynamic>>> processSubscriptionPayment({
    required String paymentToken,
    required String planId,
    required double amount,
    required String currency,
    required String paymentMethod,
    required String? userToken,
  }) async {
    try {
      print('Processing subscription payment...');
      print('Plan ID: $planId');
      print('Amount: $amount $currency');
      print('Payment Method: $paymentMethod');

      final response = await http.post(
        Uri.parse('$baseUrl$processPaymentEndpoint'),
        headers: _getHeaders(token: userToken),
        body: jsonEncode({
          'payment_token': paymentToken,
          'plan_id': planId,
          'amount': amount,
          'currency': currency,
          'payment_method': paymentMethod,
        }),
      );

      print('Payment API Response Status: ${response.statusCode}');
      print('Payment API Response Body: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        try {
          final Map<String, dynamic> data = jsonDecode(response.body);
          return ApiResponse.success(data);
        } catch (e) {
          print('Error parsing payment response: $e');
          return ApiResponse.error('Failed to parse payment response: $e');
        }
      } else {
        try {
          final Map<String, dynamic> errorData = jsonDecode(response.body);
          final message = errorData['message'] ?? 'Payment processing failed';
          return ApiResponse.error(message);
        } catch (e) {
          return ApiResponse.error(
              'Payment failed with status: ${response.statusCode}');
        }
      }
    } catch (e) {
      print('Payment processing error: $e');
      return ApiResponse.error('Payment processing failed: $e');
    }
  }

  // Handle auth response
  static ApiResponse<AuthResponse> _handleAuthResponse(http.Response response) {
    print('API Response Status: ${response.statusCode}');
    print('API Response Body: ${response.body}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        final Map<String, dynamic> data = jsonDecode(response.body);
        print('Parsed API Data: $data');
        final authResponse = AuthResponse.fromJson(data);
        print('AuthResponse created successfully');
        return ApiResponse.success(authResponse);
      } catch (e) {
        print('Error parsing auth response: $e');
        return ApiResponse.error('Failed to parse response: $e');
      }
    } else {
      try {
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        final message = errorData['message'] ?? 'Authentication failed';
        return ApiResponse.error(message);
      } catch (e) {
        return ApiResponse.error(
            'Authentication failed with status: ${response.statusCode}');
      }
    }
  }
}

// Generic API Response wrapper
class ApiResponse<T> {
  final T? data;
  final String? error;
  final bool isSuccess;

  ApiResponse.success(this.data)
      : error = null,
        isSuccess = true;
  ApiResponse.error(this.error)
      : data = null,
        isSuccess = false;
}

// Auth Response model
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

// User Data model
class UserData {
  final String id;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? avatar;

  UserData({
    required this.id,
    required this.email,
    this.firstName,
    this.lastName,
    this.avatar,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      firstName: json['firstName']?.toString(),
      lastName: json['lastName']?.toString(),
      avatar: json['avatar']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'avatar': avatar,
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
