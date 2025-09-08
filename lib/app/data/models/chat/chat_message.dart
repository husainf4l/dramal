class ChatMessage {
  final String id;
  final String content;
  final ChatMessageType type;
  final DateTime timestamp;
  final bool isFromUser;
  final String? sessionId;
  final ChatMessageSection? section;

  ChatMessage({
    required this.id,
    required this.content,
    required this.type,
    required this.timestamp,
    required this.isFromUser,
    this.sessionId,
    this.section,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      content: json['content'] ?? '',
      type: ChatMessageType.fromString(json['type'] ?? 'content'),
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
      isFromUser: json['isFromUser'] ?? false,
      sessionId: json['sessionId'],
      section: json['section'] != null
          ? ChatMessageSection.fromString(json['section'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'type': type.toString(),
      'timestamp': timestamp.toIso8601String(),
      'isFromUser': isFromUser,
      'sessionId': sessionId,
      'section': section?.toString(),
    };
  }

  ChatMessage copyWith({
    String? id,
    String? content,
    ChatMessageType? type,
    DateTime? timestamp,
    bool? isFromUser,
    String? sessionId,
    ChatMessageSection? section,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      content: content ?? this.content,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      isFromUser: isFromUser ?? this.isFromUser,
      sessionId: sessionId ?? this.sessionId,
      section: section ?? this.section,
    );
  }
}

enum ChatMessageType {
  content,
  thought,
  finalAnswer,
  error,
  status;

  static ChatMessageType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'content':
        return ChatMessageType.content;
      case 'thought':
        return ChatMessageType.thought;
      case 'final_answer':
        return ChatMessageType.finalAnswer;
      case 'error':
        return ChatMessageType.error;
      case 'status':
        return ChatMessageType.status;
      default:
        return ChatMessageType.content;
    }
  }

  @override
  String toString() {
    switch (this) {
      case ChatMessageType.content:
        return 'content';
      case ChatMessageType.thought:
        return 'thought';
      case ChatMessageType.finalAnswer:
        return 'final_answer';
      case ChatMessageType.error:
        return 'error';
      case ChatMessageType.status:
        return 'status';
    }
  }
}

enum ChatMessageSection {
  thought,
  finalAnswer;

  static ChatMessageSection fromString(String value) {
    switch (value.toLowerCase()) {
      case 'thought':
        return ChatMessageSection.thought;
      case 'final_answer':
        return ChatMessageSection.finalAnswer;
      default:
        return ChatMessageSection.finalAnswer;
    }
  }

  @override
  String toString() {
    switch (this) {
      case ChatMessageSection.thought:
        return 'thought';
      case ChatMessageSection.finalAnswer:
        return 'final_answer';
    }
  }
}
