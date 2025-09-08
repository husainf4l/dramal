class ChatRequest {
  final String message;
  final String sessionId;

  ChatRequest({
    required this.message,
    required this.sessionId,
  });

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'session_id': sessionId,
    };
  }

  factory ChatRequest.fromJson(Map<String, dynamic> json) {
    return ChatRequest(
      message: json['message'] ?? '',
      sessionId: json['session_id'] ?? '',
    );
  }
}
