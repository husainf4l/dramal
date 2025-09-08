import 'dart:convert';

class ChatStreamEvent {
  final String event;
  final Map<String, dynamic> data;

  ChatStreamEvent({
    required this.event,
    required this.data,
  });

  factory ChatStreamEvent.fromRaw(String rawEvent) {
    final lines = rawEvent.split('\n');
    String event = '';
    String dataStr = '';

    for (final line in lines) {
      if (line.startsWith('event:')) {
        event = line.substring(6).trim();
      } else if (line.startsWith('data:')) {
        dataStr = line.substring(5).trim();
      }
    }

    Map<String, dynamic> data = {};
    if (dataStr.isNotEmpty && dataStr != '[DONE]') {
      try {
        data = jsonDecode(dataStr);
      } catch (e) {
        data = {'raw': dataStr};
      }
    }

    return ChatStreamEvent(
      event: event,
      data: data,
    );
  }

  bool get isContent => event == 'content';
  bool get isStart => event == 'start';
  bool get isDone => event == 'done' || data['status'] == 'completed';
  bool get isConnected => event == 'connected';
  bool get isProxyEnd => event == 'proxy_end';
  bool get isError => event == 'error';

  String? get content => data['content'];
  String? get type => data['type'];
  String? get section => data['section'];
  String? get threadId => data['thread_id'];
  String? get model => data['model'];
  String? get status => data['status'];
}
