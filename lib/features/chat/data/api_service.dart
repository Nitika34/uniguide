import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../../core/app_config.dart';
import 'message_model.dart';

class ChatApiResponse {
  final String answer;
  final List<String> sources;
  final ChatDiagram? diagram;

  const ChatApiResponse({
    required this.answer,
    required this.sources,
    this.diagram,
  });
}

class ApiService {
  final String baseUrl = AppConfig.baseUrl;

  Future<ChatApiResponse> getRAGResponse(String query) async {
    final uri = Uri.parse('$baseUrl/chat/');
    try {
      final response = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'question': query}),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final rawSources = data['sources'] as List<dynamic>? ?? const [];
        final rawDiagram = data['diagram'];

        return ChatApiResponse(
          answer: data['answer'] ??
              data['response'] ??
              data['result'] ??
              'No valid response from backend',
          sources: rawSources.map((source) => source.toString()).toList(),
          diagram: rawDiagram is Map<String, dynamic>
              ? ChatDiagram.fromJson(rawDiagram)
              : rawDiagram is Map
                  ? ChatDiagram.fromJson(
                      Map<String, dynamic>.from(rawDiagram),
                    )
                  : null,
        );
      }

      throw Exception(
        'Backend returned ${response.statusCode} at $uri. '
        'Make sure Flask is running and the /chat/ route is available.',
      );
    } on SocketException {
      throw Exception(
        'Cannot reach backend at $baseUrl.\n'
        'If you are using Android emulator, keep port 5000 and use 10.0.2.2.\n'
        'If you are using a real phone, start Flutter with:\n'
        'flutter run --dart-define=API_HOST=<YOUR-PC-IP>:5000',
      );
    } on TimeoutException {
      throw Exception(
        'Backend request timed out at $uri. '
        'Check whether Flask is running or busy.',
      );
    } on FormatException {
      throw Exception(
        'Backend response was not valid JSON from $uri.',
      );
    }
  }
}
