import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';

class NotificationService {
  static const String baseUrl = 'https://dramal.com/api';

  // Notification endpoints
  static const String registerDeviceEndpoint = '/notifications/register-device';
  static const String unregisterDeviceEndpoint =
      '/notifications/unregister-device';
  static const String sendNotificationEndpoint = '/notifications/send';
  static const String getNotificationsEndpoint = '/notifications';
  static const String markReadEndpoint = '/notifications/mark-read';
  static const String settingsEndpoint = '/notifications/settings';

  // Get headers with auth token
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

  // Register device for push notifications
  static Future<ApiResponse<DeviceRegistrationResponse>> registerDevice({
    required String deviceToken,
    required String token,
  }) async {
    try {
      final deviceInfo = await _getDeviceInfo();

      final response = await http.post(
        Uri.parse('$baseUrl$registerDeviceEndpoint'),
        headers: _getHeaders(token: token),
        body: jsonEncode({
          'deviceToken': deviceToken,
          'platform': Platform.isIOS ? 'ios' : 'android',
          'appVersion': deviceInfo['appVersion'],
          'deviceModel': deviceInfo['deviceModel'],
          'osVersion': deviceInfo['osVersion'],
        }),
      );

      return _handleDeviceRegistrationResponse(response);
    } catch (e) {
      return ApiResponse.error('Failed to register device: ${e.toString()}');
    }
  }

  // Unregister device
  static Future<ApiResponse<bool>> unregisterDevice({
    required String deviceId,
    required String token,
  }) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl$unregisterDeviceEndpoint'),
        headers: _getHeaders(token: token),
        body: jsonEncode({
          'deviceId': deviceId,
        }),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return ApiResponse.success(true);
      } else {
        final errorData = jsonDecode(response.body);
        return ApiResponse.error(
            errorData['message'] ?? 'Failed to unregister device');
      }
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }

  // Get notifications with pagination
  static Future<ApiResponse<NotificationList>> getNotifications({
    required String token,
    int page = 1,
    int limit = 20,
    String? readFilter, // 'true', 'false', or null for all
  }) async {
    try {
      // Debug: Validate parameters before sending
      print('🌐 Preparing API call with parameters:');
      print('  page: $page (type: ${page.runtimeType})');
      print('  limit: $limit (type: ${limit.runtimeType})');
      print('  token length: ${token.length}');

      // Ensure parameters are valid and within backend constraints
      final validatedPage = page > 0 ? page : 1;
      final validatedLimit = limit > 0 && limit <= 100 ? limit : 20;

      print('  validated page: $validatedPage');
      print('  validated limit: $validatedLimit');

      // Build query parameters manually to ensure proper formatting
      var queryString = 'page=$validatedPage&limit=$validatedLimit';

      if (readFilter != null) {
        queryString += '&read=$readFilter';
      }

      final uri = Uri.parse('$baseUrl$getNotificationsEndpoint?$queryString');

      print('🌐 Final URI: $uri');
      print('🌐 Query string: $queryString');

      final response = await http.get(
        uri,
        headers: _getHeaders(token: token),
      );

      return _handleNotificationListResponse(response);
    } catch (e) {
      return ApiResponse.error(
          'Failed to fetch notifications: ${e.toString()}');
    }
  }

  // Mark single notification as read
  static Future<ApiResponse<bool>> markNotificationRead({
    required String notificationId,
    required String token,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl$getNotificationsEndpoint/$notificationId/read'),
        headers: _getHeaders(token: token),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return ApiResponse.success(true);
      } else {
        final errorData = jsonDecode(response.body);
        return ApiResponse.error(
            errorData['message'] ?? 'Failed to mark notification as read');
      }
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }

  // Mark all notifications as read
  static Future<ApiResponse<bool>> markAllNotificationsRead({
    required String token,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl$markReadEndpoint'),
        headers: _getHeaders(token: token),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return ApiResponse.success(true);
      } else {
        final errorData = jsonDecode(response.body);
        return ApiResponse.error(
            errorData['message'] ?? 'Failed to mark all notifications as read');
      }
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }

  // Delete notification
  static Future<ApiResponse<bool>> deleteNotification({
    required String notificationId,
    required String token,
  }) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl$getNotificationsEndpoint/$notificationId'),
        headers: _getHeaders(token: token),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return ApiResponse.success(true);
      } else {
        final errorData = jsonDecode(response.body);
        return ApiResponse.error(
            errorData['message'] ?? 'Failed to delete notification');
      }
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }

  // Get notification settings
  static Future<ApiResponse<NotificationSettings>> getNotificationSettings({
    required String token,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$settingsEndpoint'),
        headers: _getHeaders(token: token),
      );

      return _handleNotificationSettingsResponse(response);
    } catch (e) {
      return ApiResponse.error(
          'Failed to fetch notification settings: ${e.toString()}');
    }
  }

  // Update notification settings
  static Future<ApiResponse<NotificationSettings>> updateNotificationSettings({
    required NotificationSettings settings,
    required String token,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl$settingsEndpoint'),
        headers: _getHeaders(token: token),
        body: jsonEncode(settings.toJson()),
      );

      return _handleNotificationSettingsResponse(response);
    } catch (e) {
      return ApiResponse.error(
          'Failed to update notification settings: ${e.toString()}');
    }
  }

  // Helper method to get device information
  static Future<Map<String, String>> _getDeviceInfo() async {
    // Simplified device info without external dependencies
    String deviceModel = 'Unknown Device';
    String osVersion = 'Unknown OS';
    String appVersion = '1.0.0'; // Default version

    if (Platform.isIOS) {
      deviceModel = 'iPhone';
      osVersion = 'iOS';
    } else if (Platform.isAndroid) {
      deviceModel = 'Android Device';
      osVersion = 'Android';
    }

    return {
      'appVersion': appVersion,
      'deviceModel': deviceModel,
      'osVersion': osVersion,
    };
  }

  // Response handlers
  static ApiResponse<DeviceRegistrationResponse>
      _handleDeviceRegistrationResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body);
      return ApiResponse.success(DeviceRegistrationResponse.fromJson(data));
    } else {
      final errorData = jsonDecode(response.body);
      return ApiResponse.error(
          errorData['message'] ?? 'Device registration failed');
    }
  }

  static ApiResponse<NotificationList> _handleNotificationListResponse(
      http.Response response) {
    print('🔔 API Response Status: ${response.statusCode}');
    print('🔔 API Response Body: ${response.body}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body);
      print('🔔 Parsed JSON data: $data');
      print('🔔 Type of data: ${data.runtimeType}');

      // Debug the notifications field specifically
      final notificationsField = data['notifications'];
      print('🔔 notifications field: $notificationsField');
      print('🔔 notifications field type: ${notificationsField.runtimeType}');

      if (notificationsField is List) {
        print(
            '🔔 notifications is a List with ${notificationsField.length} items');
        for (int i = 0; i < notificationsField.length && i < 3; i++) {
          print('🔔 Item $i: ${notificationsField[i]}');
          print('🔔 Item $i type: ${notificationsField[i].runtimeType}');
        }
      } else {
        print(
            '🔔 ERROR: notifications is NOT a List! It is: ${notificationsField.runtimeType}');
      }

      return ApiResponse.success(NotificationList.fromJson(data));
    } else {
      final errorData = jsonDecode(response.body);
      print('🔔 API Error Response: $errorData');
      return ApiResponse.error(
          errorData['message'] ?? 'Failed to fetch notifications');
    }
  }

  static ApiResponse<NotificationSettings> _handleNotificationSettingsResponse(
      http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body);
      return ApiResponse.success(NotificationSettings.fromJson(data));
    } else {
      final errorData = jsonDecode(response.body);
      return ApiResponse.error(
          errorData['message'] ?? 'Failed to handle notification settings');
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

// Device Registration Response model
class DeviceRegistrationResponse {
  final String deviceId;
  final String message;

  DeviceRegistrationResponse({
    required this.deviceId,
    required this.message,
  });

  factory DeviceRegistrationResponse.fromJson(Map<String, dynamic> json) {
    return DeviceRegistrationResponse(
      deviceId: json['deviceId']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
    );
  }
}

// Notification model
class AppNotification {
  final String id;
  final String title;
  final String body;
  final Map<String, dynamic>? data;
  final bool isRead;
  final DateTime createdAt;
  final String? imageUrl;
  final String type;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    this.data,
    required this.isRead,
    required this.createdAt,
    this.imageUrl,
    required this.type,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    print('📝 Parsing AppNotification from JSON: $json');
    print('📝 JSON type: ${json.runtimeType}');

    try {
      final id = json['id'];
      final title = json['title'];
      final body = json['body'];
      final data = json['data'];
      final isRead = json['isRead'];
      final createdAt = json['createdAt'];
      final imageUrl = json['imageUrl'];
      final type = json['type'];

      print('📝 Field types:');
      print('  id: ${id.runtimeType} = $id');
      print('  title: ${title.runtimeType} = $title');
      print('  body: ${body.runtimeType} = $body');
      print('  data: ${data.runtimeType} = $data');
      print('  isRead: ${isRead.runtimeType} = $isRead');
      print('  createdAt: ${createdAt.runtimeType} = $createdAt');
      print('  imageUrl: ${imageUrl.runtimeType} = $imageUrl');
      print('  type: ${type.runtimeType} = $type');

      return AppNotification(
        id: id?.toString() ?? '',
        title: title?.toString() ?? '',
        body: body?.toString() ?? '',
        data: data as Map<String, dynamic>?,
        isRead: isRead == true,
        createdAt:
            DateTime.tryParse(createdAt?.toString() ?? '') ?? DateTime.now(),
        imageUrl: imageUrl?.toString(),
        type: type?.toString() ?? 'general',
      );
    } catch (e) {
      print('📝 ERROR parsing AppNotification: $e');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'data': data,
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
      'imageUrl': imageUrl,
      'type': type,
    };
  }
}

// Notification List model
class NotificationList {
  final List<AppNotification> notifications;
  final int totalCount;
  final int currentPage;
  final int totalPages;
  final bool hasNextPage;

  NotificationList({
    required this.notifications,
    required this.totalCount,
    required this.currentPage,
    required this.totalPages,
    required this.hasNextPage,
  });

  factory NotificationList.fromJson(Map<String, dynamic> json) {
    print('📋 Parsing NotificationList from JSON: $json');

    final notificationsJson = json['notifications'] as List<dynamic>? ?? [];
    print('📋 notificationsJson: $notificationsJson');
    print('📋 notificationsJson type: ${notificationsJson.runtimeType}');
    print('📋 notificationsJson length: ${notificationsJson.length}');

    final notifications = <AppNotification>[];
    try {
      for (int i = 0; i < notificationsJson.length; i++) {
        final item = notificationsJson[i];
        print('📋 Processing item $i: $item');
        print('📋 Item $i type: ${item.runtimeType}');

        if (item is Map<String, dynamic>) {
          final notification = AppNotification.fromJson(item);
          notifications.add(notification);
          print('📋 Successfully parsed notification $i');
        } else {
          print(
              '📋 ERROR: Item $i is not a Map<String, dynamic>! It is: ${item.runtimeType}');
          // Try to cast it anyway
          try {
            final notification =
                AppNotification.fromJson(item as Map<String, dynamic>);
            notifications.add(notification);
            print('📋 Successfully parsed notification $i after casting');
          } catch (e) {
            print('📋 ERROR parsing item $i: $e');
          }
        }
      }
    } catch (e) {
      print('📋 ERROR in notification parsing loop: $e');
    }

    print('📋 Successfully parsed ${notifications.length} notifications');

    return NotificationList(
      notifications: notifications,
      totalCount: json['totalCount']?.toInt() ?? 0,
      currentPage: json['currentPage']?.toInt() ?? 1,
      totalPages: json['totalPages']?.toInt() ?? 1,
      hasNextPage: json['hasNextPage'] == true,
    );
  }
}

// Notification Settings model
class NotificationSettings {
  final bool pushEnabled;
  final bool skinAnalysisEnabled;
  final bool remindersEnabled;
  final bool marketingEnabled;
  final bool soundEnabled;
  final bool vibrationEnabled;
  final String quietHoursStart;
  final String quietHoursEnd;

  NotificationSettings({
    required this.pushEnabled,
    required this.skinAnalysisEnabled,
    required this.remindersEnabled,
    required this.marketingEnabled,
    required this.soundEnabled,
    required this.vibrationEnabled,
    required this.quietHoursStart,
    required this.quietHoursEnd,
  });

  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
      pushEnabled: json['pushEnabled'] == true,
      skinAnalysisEnabled: json['skinAnalysisEnabled'] == true,
      remindersEnabled: json['remindersEnabled'] == true,
      marketingEnabled: json['marketingEnabled'] == true,
      soundEnabled: json['soundEnabled'] == true,
      vibrationEnabled: json['vibrationEnabled'] == true,
      quietHoursStart: json['quietHoursStart']?.toString() ?? '22:00',
      quietHoursEnd: json['quietHoursEnd']?.toString() ?? '08:00',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pushEnabled': pushEnabled,
      'skinAnalysisEnabled': skinAnalysisEnabled,
      'remindersEnabled': remindersEnabled,
      'marketingEnabled': marketingEnabled,
      'soundEnabled': soundEnabled,
      'vibrationEnabled': vibrationEnabled,
      'quietHoursStart': quietHoursStart,
      'quietHoursEnd': quietHoursEnd,
    };
  }

  NotificationSettings copyWith({
    bool? pushEnabled,
    bool? skinAnalysisEnabled,
    bool? remindersEnabled,
    bool? marketingEnabled,
    bool? soundEnabled,
    bool? vibrationEnabled,
    String? quietHoursStart,
    String? quietHoursEnd,
  }) {
    return NotificationSettings(
      pushEnabled: pushEnabled ?? this.pushEnabled,
      skinAnalysisEnabled: skinAnalysisEnabled ?? this.skinAnalysisEnabled,
      remindersEnabled: remindersEnabled ?? this.remindersEnabled,
      marketingEnabled: marketingEnabled ?? this.marketingEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      quietHoursStart: quietHoursStart ?? this.quietHoursStart,
      quietHoursEnd: quietHoursEnd ?? this.quietHoursEnd,
    );
  }
}
