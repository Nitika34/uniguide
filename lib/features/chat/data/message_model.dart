class ChatDiagramStep {
  final String title;
  final String detail;

  const ChatDiagramStep({
    required this.title,
    required this.detail,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'detail': detail,
    };
  }

  factory ChatDiagramStep.fromJson(Map<String, dynamic> json) {
    return ChatDiagramStep(
      title: json['title'] as String? ?? '',
      detail: json['detail'] as String? ?? '',
    );
  }
}

class ChatDiagram {
  final String title;
  final List<ChatDiagramStep> steps;
  final String? footer;

  const ChatDiagram({
    required this.title,
    required this.steps,
    this.footer,
  });

  bool get hasContent => title.trim().isNotEmpty && steps.isNotEmpty;

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'steps': steps.map((step) => step.toJson()).toList(),
      'footer': footer,
    };
  }

  factory ChatDiagram.fromJson(Map<String, dynamic> json) {
    final rawSteps = json['steps'] as List<dynamic>? ?? const [];
    return ChatDiagram(
      title: json['title'] as String? ?? '',
      steps: rawSteps
          .map((step) =>
              ChatDiagramStep.fromJson(Map<String, dynamic>.from(step as Map)))
          .toList(),
      footer: json['footer'] as String?,
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final String? source;
  final ChatDiagram? diagram;

  ChatMessage({
    required this.text,
    required this.isUser,
    DateTime? timestamp,
    this.source,
    this.diagram,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'isUser': isUser,
      'timestamp': timestamp.toIso8601String(),
      'source': source,
      'diagram': diagram?.toJson(),
    };
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    final rawDiagram = json['diagram'];
    return ChatMessage(
      text: json['text'] as String? ?? '',
      isUser: json['isUser'] as bool? ?? false,
      timestamp: DateTime.tryParse(json['timestamp'] as String? ?? '') ??
          DateTime.now(),
      source: json['source'] as String?,
      diagram: rawDiagram is Map
          ? ChatDiagram.fromJson(Map<String, dynamic>.from(rawDiagram))
          : null,
    );
  }
}

class ChatSession {
  final String id;
  final String title;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<ChatMessage> messages;

  ChatSession({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    required this.messages,
  });

  factory ChatSession.create({
    required String id,
    required List<ChatMessage> messages,
  }) {
    final now = DateTime.now();
    return ChatSession(
      id: id,
      title: 'New chat',
      createdAt: now,
      updatedAt: now,
      messages: messages,
    );
  }

  String get previewText {
    if (messages.isEmpty) return 'No messages yet';
    final preview = messages.last.text.replaceAll('\n', ' ').trim();
    if (preview.isNotEmpty) return preview;
    if (messages.last.diagram?.hasContent ?? false) return 'Diagram response';
    return 'No messages yet';
  }

  ChatSession copyWith({
    String? id,
    String? title,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<ChatMessage>? messages,
  }) {
    return ChatSession(
      id: id ?? this.id,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      messages: messages ?? this.messages,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'messages': messages.map((message) => message.toJson()).toList(),
    };
  }

  factory ChatSession.fromJson(Map<String, dynamic> json) {
    final rawMessages = json['messages'] as List<dynamic>? ?? const [];
    return ChatSession(
      id: json['id'] as String? ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      title: json['title'] as String? ?? 'New chat',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '') ??
          DateTime.now(),
      messages: rawMessages
          .map((message) => ChatMessage.fromJson(
                Map<String, dynamic>.from(message as Map),
              ))
          .toList(),
    );
  }
}
