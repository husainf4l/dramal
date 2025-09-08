import 'dart:async';
import '../data/repositories/chat_repository.dart';
import '../data/models/chat/chat_message.dart';
import '../data/models/chat/chat_session.dart';

class ChatService {
  final ChatRepository _repository;

  ChatService({
    required ChatRepository repository,
  }) : _repository = repository;

  /// Sends a message and returns a stream of responses
  Stream<ChatMessage> sendMessage({
    required String message,
    required String sessionId,
  }) {
    if (message.trim().isEmpty) {
      throw ArgumentError('Message cannot be empty');
    }

    if (sessionId.trim().isEmpty) {
      throw ArgumentError('Session ID cannot be empty');
    }

    return _repository.sendMessage(message.trim(), sessionId);
  }

  /// Gets a chat session by ID
  Future<ChatSession> getSession(String sessionId) {
    if (sessionId.trim().isEmpty) {
      throw ArgumentError('Session ID cannot be empty');
    }

    return _repository.getSession(sessionId);
  }

  /// Creates a new chat session
  Future<ChatSession> createSession() async {
    final sessionId = _generateSessionId();
    return await _repository.getSession(sessionId);
  }

  /// Gets all chat sessions
  Future<List<ChatSession>> getAllSessions() {
    return _repository.getAllSessions();
  }

  /// Deletes a chat session
  Future<void> deleteSession(String sessionId) {
    if (sessionId.trim().isEmpty) {
      throw ArgumentError('Session ID cannot be empty');
    }

    return _repository.deleteSession(sessionId);
  }

  /// Saves a chat session
  Future<void> saveSession(ChatSession session) {
    return _repository.saveSession(session);
  }

  /// Generates a unique session ID
  String _generateSessionId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = (timestamp * 1000 + (timestamp % 1000)).toString();
    return 'session_$random';
  }

  /// Gets the latest message from a session
  ChatMessage? getLatestMessage(ChatSession session) {
    if (session.messages.isEmpty) return null;
    return session.messages.last;
  }

  /// Gets only user messages from a session
  List<ChatMessage> getUserMessages(ChatSession session) {
    return session.messages.where((msg) => msg.isFromUser).toList();
  }

  /// Gets only AI messages from a session
  List<ChatMessage> getAIMessages(ChatSession session) {
    return session.messages.where((msg) => !msg.isFromUser).toList();
  }

  /// Checks if a session has any messages
  bool hasMessages(ChatSession session) {
    return session.messages.isNotEmpty;
  }

  /// Gets message count for a session
  int getMessageCount(ChatSession session) {
    return session.messages.length;
  }

  /// Searches messages in a session
  List<ChatMessage> searchMessages(ChatSession session, String query) {
    if (query.trim().isEmpty) return [];

    final lowercaseQuery = query.toLowerCase();
    return session.messages
        .where((msg) => msg.content.toLowerCase().contains(lowercaseQuery))
        .toList();
  }
}
