import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../core/config/api_config.dart';
import '../../../core/network/stream_parser.dart';

/// Chat API client with streaming support
class ChatApi {
  final http.Client _client;

  ChatApi({http.Client? client}) : _client = client ?? http.Client();

  /// Send a chat request and stream the response
  Stream<StreamEvent> sendMessage({
    required List<Map<String, dynamic>> messages,
    String model = ApiConfig.defaultModel,
  }) async* {
    final request = http.Request('POST', Uri.parse(ApiConfig.chatEndpoint));
    request.headers['Content-Type'] = 'application/json';
    request.body = jsonEncode({
      'model': model,
      'messages': messages,
      'stream': true,
    });

    final response = await _client.send(request);

    if (response.statusCode != 200) {
      final body = await response.stream.bytesToString();
      yield StreamEvent(
        type: StreamEventType.error,
        data: {'error': 'Server error ${response.statusCode}: $body'},
      );
      return;
    }

    await for (final chunk in response.stream.transform(utf8.decoder)) {
      for (final line in chunk.split('\n')) {
        final event = StreamParser.parseLine(line);
        if (event != null) {
          yield event;
        }
      }
    }
  }

  /// Check if the server is healthy
  Future<bool> checkHealth() async {
    try {
      final response = await _client
          .get(Uri.parse(ApiConfig.healthEndpoint))
          .timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Get available tools from the server
  Future<List<Map<String, dynamic>>> getTools() async {
    try {
      final response = await _client.get(Uri.parse(ApiConfig.toolsEndpoint));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  void dispose() {
    _client.close();
  }
}
