import 'package:flutter/material.dart';

class NotificationModel {
  final String id;
  final String title;
  final String message;
  final String type; // 'info', 'warning', 'success', 'tip'
  final DateTime createdAt;
  final bool isRead;
  final String? actionUrl;
  final Map<String, dynamic>? metadata;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.createdAt,
    this.isRead = false,
    this.actionUrl,
    this.metadata,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      type: json['type'] as String? ?? 'info',
      createdAt: DateTime.parse(json['created_at'] as String),
      isRead: json['is_read'] as bool? ?? false,
      actionUrl: json['action_url'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'type': type,
      'created_at': createdAt.toIso8601String(),
      'is_read': isRead,
      'action_url': actionUrl,
      'metadata': metadata,
    };
  }

  IconData get icon {
    switch (type) {
      case 'warning':
        return Icons.warning_rounded;
      case 'success':
        return Icons.check_circle_rounded;
      case 'tip':
        return Icons.tips_and_updates_rounded;
      case 'info':
      default:
        return Icons.info_rounded;
    }
  }

  Color get color {
    switch (type) {
      case 'warning':
        return const Color(0xFFFFA726);
      case 'success':
        return const Color(0xFF4CAF50);
      case 'tip':
        return const Color(0xFF2196F3);
      case 'info':
      default:
        return const Color(0xFF6366F1);
    }
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }

  NotificationModel copyWith({
    String? id,
    String? title,
    String? message,
    String? type,
    DateTime? createdAt,
    bool? isRead,
    String? actionUrl,
    Map<String, dynamic>? metadata,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      actionUrl: actionUrl ?? this.actionUrl,
      metadata: metadata ?? this.metadata,
    );
  }
}
