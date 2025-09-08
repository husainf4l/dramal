import 'dart:async';
import '../api/chat_api_client.dart';
import '../models/chat/chat_request.dart';
import '../models/chat/chat_message.dart';
import '../models/chat/chat_session.dart';

abstract class ChatRepository {
  Stream<ChatMessage> sendMessage(String message, String sessionId);
  Future<ChatSession> getSession(String sessionId);
  Future<void> saveSession(ChatSession session);
  Future<List<ChatSession>> getAllSessions();
  Future<void> deleteSession(String sessionId);
}

class ChatRepositoryImpl implements ChatRepository {
  final ChatApiClient _apiClient;
  final Map<String, ChatSession> _sessionsCache = {};

  ChatRepositoryImpl({
    required ChatApiClient apiClient,
  }) : _apiClient = apiClient;

  @override
  Stream<ChatMessage> sendMessage(String message, String sessionId) async* {
    final request = ChatRequest(
      message: message,
      sessionId: sessionId,
    );

    // First yield the user's message
    final userMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: message,
      type: ChatMessageType.content,
      timestamp: DateTime.now(),
      isFromUser: true,
      sessionId: sessionId,
    );

    yield userMessage;

    // Process the stream response
    String accumulatedContent = '';

    await for (final event in _apiClient.sendMessage(request)) {
      print('🔗 Raw API event: ${event.toString()}');

      if (event.isError) {
        print('❌ API returned error: ${event.data}');
        yield ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          content: 'Error: ${event.data['error'] ?? 'Unknown error'}',
          type: ChatMessageType.error,
          timestamp: DateTime.now(),
          isFromUser: false,
          sessionId: sessionId,
        );
        break;
      }

      if (event.isStart) {
        print('🏁 Stream started');
        // Reset for new response
        accumulatedContent = '';
        continue;
      }

      if (event.isContent && event.content != null) {
        print(
            '📝 Content chunk: "${event.content}" (type: ${event.type}, section: ${event.section})');
        accumulatedContent += event.content!;

        print(
            '🔄 Accumulated content (${accumulatedContent.length} chars): "${accumulatedContent.length > 100 ? accumulatedContent.substring(0, 100) + '...' : accumulatedContent}"');

        // Parse and yield separate streaming messages for thought and answer
        final streamingMessages =
            _parseStreamingContent(accumulatedContent, sessionId);

        // Yield thought message if it exists and has content
        if (streamingMessages['thought'] != null) {
          yield streamingMessages['thought']!;
        }

        // Yield answer message if it exists and has content
        if (streamingMessages['answer'] != null) {
          yield streamingMessages['answer']!;
        }
      }

      if (event.isDone) {
        print(
            '🏁 Stream completed. Final content length: ${accumulatedContent.length}');

        // Parse the content to separate thought and final answer
        final parsedMessages =
            _parseThoughtAndAnswer(accumulatedContent, sessionId);

        // Yield thought message first (if exists)
        if (parsedMessages['thought'] != null) {
          yield parsedMessages['thought']!;
        }

        // Yield final answer message
        if (parsedMessages['answer'] != null) {
          yield parsedMessages['answer']!;
        }

        // Update session cache with all messages
        final messagesToSave = <ChatMessage>[userMessage];
        if (parsedMessages['thought'] != null) {
          messagesToSave.add(parsedMessages['thought']!);
        }
        if (parsedMessages['answer'] != null) {
          messagesToSave.add(parsedMessages['answer']!);
        }

        await _updateSessionWithMessages(sessionId, messagesToSave);
        break;
      }
    }
  }

  @override
  Future<ChatSession> getSession(String sessionId) async {
    if (_sessionsCache.containsKey(sessionId)) {
      return _sessionsCache[sessionId]!;
    }

    // For now, create a new session if it doesn't exist
    // In a real app, you might fetch from local storage or server
    final session = ChatSession(
      id: sessionId,
      messages: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    _sessionsCache[sessionId] = session;
    return session;
  }

  @override
  Future<void> saveSession(ChatSession session) async {
    _sessionsCache[session.id] = session;
    // Here you would typically save to local storage or server
  }

  @override
  Future<List<ChatSession>> getAllSessions() async {
    return _sessionsCache.values.toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  @override
  Future<void> deleteSession(String sessionId) async {
    _sessionsCache.remove(sessionId);
    // Here you would typically delete from local storage or server
  }

  Future<void> _updateSessionWithMessages(
    String sessionId,
    List<ChatMessage> newMessages,
  ) async {
    final session = await getSession(sessionId);
    final updatedSession = session.copyWith(
      messages: [...session.messages, ...newMessages],
      updatedAt: DateTime.now(),
    );
    await saveSession(updatedSession);
  }

  /// Parses content that contains both thought and final answer
  Map<String, ChatMessage?> _parseThoughtAndAnswer(
      String content, String sessionId) {
    ChatMessage? thoughtMessage;
    ChatMessage? answerMessage;

    final timestamp = DateTime.now();
    final baseId = timestamp.millisecondsSinceEpoch;

    // Regular expression to extract thought and final answer
    final thoughtRegex = RegExp(
        r'\*\*Thought:\*\*\s*(.*?)(?=\*\*Final Answer:\*\*|$)',
        dotAll: true);
    final answerRegex = RegExp(r'\*\*Final Answer:\*\*\s*(.*?)$', dotAll: true);

    // Extract thought
    final thoughtMatch = thoughtRegex.firstMatch(content);
    if (thoughtMatch != null) {
      final thoughtContent = thoughtMatch.group(1)?.trim();
      if (thoughtContent != null && thoughtContent.isNotEmpty) {
        thoughtMessage = ChatMessage(
          id: '${baseId}_thought',
          content: thoughtContent,
          type: ChatMessageType.thought,
          timestamp: timestamp, // Thought gets earlier timestamp
          isFromUser: false,
          sessionId: sessionId,
          section: ChatMessageSection.thought,
        );
        print(
            '🧠 Extracted thought: ${thoughtContent.substring(0, thoughtContent.length > 100 ? 100 : thoughtContent.length)}...');
      }
    }

    // Extract final answer
    final answerMatch = answerRegex.firstMatch(content);
    if (answerMatch != null) {
      final answerContent = answerMatch.group(1)?.trim();
      if (answerContent != null && answerContent.isNotEmpty) {
        answerMessage = ChatMessage(
          id: '${baseId}_answer',
          content: answerContent,
          type: ChatMessageType.finalAnswer,
          timestamp: timestamp.add(
              const Duration(milliseconds: 100)), // Answer gets later timestamp
          isFromUser: false,
          sessionId: sessionId,
          section: ChatMessageSection.finalAnswer,
        );
        print(
            '💬 Extracted answer: ${answerContent.substring(0, answerContent.length > 100 ? 100 : answerContent.length)}...');
      }
    } else {
      // If no structured format found, treat entire content as final answer
      answerMessage = ChatMessage(
        id: '${baseId}_answer',
        content: content.trim(),
        type: ChatMessageType.finalAnswer,
        timestamp: timestamp,
        isFromUser: false,
        sessionId: sessionId,
        section: ChatMessageSection.finalAnswer,
      );
      print('💬 No structured format found, using entire content as answer');
    }

    return {
      'thought': thoughtMessage,
      'answer': answerMessage,
    };
  }

  /// Parses streaming content to show thought and answer as they build up
  Map<String, ChatMessage?> _parseStreamingContent(
      String content, String sessionId) {
    ChatMessage? thoughtMessage;
    ChatMessage? answerMessage;

    final timestamp = DateTime.now();
    final streamingId = 'streaming-${timestamp.millisecondsSinceEpoch}';

    // Check if we have thought content building up
    final thoughtRegex = RegExp(
        r'\*\*Thought:\*\*\s*(.*?)(?=\*\*Final Answer:\*\*|$)',
        dotAll: true);
    final thoughtMatch = thoughtRegex.firstMatch(content);

    if (thoughtMatch != null) {
      final thoughtContent = thoughtMatch.group(1)?.trim();
      if (thoughtContent != null && thoughtContent.isNotEmpty) {
        thoughtMessage = ChatMessage(
          id: '${streamingId}_thought',
          content: thoughtContent,
          type: ChatMessageType.thought,
          timestamp: timestamp, // Thought gets earlier timestamp
          isFromUser: false,
          sessionId: sessionId,
          section: ChatMessageSection.thought,
        );
      }
    }

    // Check if we have final answer content building up
    final answerRegex = RegExp(r'\*\*Final Answer:\*\*\s*(.*?)$', dotAll: true);
    final answerMatch = answerRegex.firstMatch(content);

    if (answerMatch != null) {
      final answerContent = answerMatch.group(1)?.trim();
      if (answerContent != null && answerContent.isNotEmpty) {
        answerMessage = ChatMessage(
          id: '${streamingId}_answer',
          content: answerContent,
          type: ChatMessageType.finalAnswer,
          timestamp: timestamp.add(
              const Duration(milliseconds: 100)), // Answer gets later timestamp
          isFromUser: false,
          sessionId: sessionId,
          section: ChatMessageSection.finalAnswer,
        );
      }
    }

    return {
      'thought': thoughtMessage,
      'answer': answerMessage,
    };
  }
}
