import 'chat_message.dart';

class ChatSession {
  final String id;
  final List<ChatMessage> messages;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? threadId;
  final String? model;

  ChatSession({
    required this.id,
    required this.messages,
    required this.createdAt,
    required this.updatedAt,
    this.threadId,
    this.model,
  });

  factory ChatSession.fromJson(Map<String, dynamic> json) {
    return ChatSession(
      id: json['id'] ?? '',
      messages: (json['messages'] as List<dynamic>?)
              ?.map((msg) => ChatMessage.fromJson(msg))
              .toList() ??
          [],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
      threadId: json['threadId'],
      model: json['model'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'messages': messages.map((msg) => msg.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'threadId': threadId,
      'model': model,
    };
  }

  ChatSession copyWith({
    String? id,
    List<ChatMessage>? messages,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? threadId,
    String? model,
  }) {
    return ChatSession(
      id: id ?? this.id,
      messages: messages ?? this.messages,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      threadId: threadId ?? this.threadId,
      model: model ?? this.model,
    );
  }

  ChatSession addMessage(ChatMessage message) {
    return copyWith(
      messages: [...messages, message],
      updatedAt: DateTime.now(),
    );
  }
}
