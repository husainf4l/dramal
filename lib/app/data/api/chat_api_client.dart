import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/chat/chat_request.dart';
import '../models/chat/chat_stream_event.dart';

class ChatApiClient {
  static const String baseUrl = 'https://skinior.com/api';
  static const String chatStreamEndpoint = '/chat/stream';

  final http.Client _client;
  final String? _accessToken;

  ChatApiClient({
    http.Client? client,
    String? accessToken,
  })  : _client = client ?? http.Client(),
        _accessToken = accessToken;

  Map<String, String> get _headers {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'text/event-stream',
      'Cache-Control': 'no-cache',
    };

    if (_accessToken != null) {
      headers['Authorization'] = 'Bearer $_accessToken';
    }

    return headers;
  }

  /// Sends a chat message and returns a stream of server-sent events
  Stream<ChatStreamEvent> sendMessage(ChatRequest request) async* {
    try {
      final url = Uri.parse('$baseUrl$chatStreamEndpoint');

      final httpRequest = http.Request('POST', url);
      httpRequest.headers.addAll(_headers);
      httpRequest.body = jsonEncode(request.toJson());

      final streamedResponse = await _client.send(httpRequest);
      print(
          '📡 HTTP Response: ${streamedResponse.statusCode} ${streamedResponse.reasonPhrase}');

      // Accept both 200 (OK) and 201 (Created) as successful responses
      if (streamedResponse.statusCode != 200 &&
          streamedResponse.statusCode != 201) {
        throw HttpException(
          'Failed to send message: ${streamedResponse.statusCode} ${streamedResponse.reasonPhrase}',
        );
      }

      yield* streamedResponse.stream
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .where((line) => line.isNotEmpty)
          .map((line) {
        print('📥 Raw SSE line: "$line"');
        return line;
      }).transform(_parseServerSentEvents());
    } catch (e) {
      yield ChatStreamEvent(
        event: 'error',
        data: {'error': e.toString()},
      );
    }
  }

  /// Transforms raw SSE lines into ChatStreamEvent objects
  StreamTransformer<String, ChatStreamEvent> _parseServerSentEvents() {
    return StreamTransformer<String, ChatStreamEvent>.fromHandlers(
      handleData: (line, sink) {
        if (line.trim().isEmpty) return;

        print('🔍 Parsing SSE line: "$line"');

        // Handle single line events
        if (line.startsWith('event:') || line.startsWith('data:')) {
          _handleSingleEvent(line, sink);
        }
      },
    );
  }

  String _currentEvent = '';
  String _currentData = '';

  void _handleSingleEvent(String line, EventSink<ChatStreamEvent> sink) {
    if (line.startsWith('event:')) {
      // If we have accumulated data, emit the previous event
      if (_currentEvent.isNotEmpty && _currentData.isNotEmpty) {
        _emitEvent(sink);
      }
      _currentEvent = line.substring(6).trim();
      _currentData = '';
    } else if (line.startsWith('data:')) {
      _currentData = line.substring(5).trim();

      // Emit immediately if we have both event and data
      if (_currentEvent.isNotEmpty && _currentData.isNotEmpty) {
        _emitEvent(sink);
      }
    }
  }

  void _emitEvent(EventSink<ChatStreamEvent> sink) {
    print('🎯 Emitting event: "${_currentEvent}" with data: "${_currentData}"');

    if (_currentData == '[DONE]') {
      print('✅ Done signal received');
      sink.add(ChatStreamEvent(
        event: 'done',
        data: {'status': 'completed'},
      ));
      return;
    }

    Map<String, dynamic> data = {};
    if (_currentData.isNotEmpty) {
      try {
        data = jsonDecode(_currentData);
        print('📋 Parsed JSON data: $data');
      } catch (e) {
        print('⚠️ Failed to parse JSON, using raw data: $e');
        data = {'raw': _currentData};
      }
    }

    final event = ChatStreamEvent(
      event: _currentEvent,
      data: data,
    );
    print('🚀 Final event object: $event');

    sink.add(event);

    // Reset for next event
    _currentEvent = '';
    _currentData = '';
  }

  void dispose() {
    _client.close();
  }
}
