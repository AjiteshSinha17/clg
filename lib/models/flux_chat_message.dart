import 'package:uuid/uuid.dart';

enum FluxMessageType { user, ai, system, roadmap }

class FluxChatMessage {
  final String id;
  final String content;
  final FluxMessageType type;
  final DateTime timestamp;
  final bool isMarkdown;
  final Map<String, dynamic>? metadata;

  FluxChatMessage({
    String? id,
    required this.content,
    required this.type,
    DateTime? timestamp,
    this.isMarkdown = false,
    this.metadata,
  })  : id = id ?? const Uuid().v4(),
        timestamp = timestamp ?? DateTime.now();

  factory FluxChatMessage.user(String content) {
    return FluxChatMessage(
      content: content,
      type: FluxMessageType.user,
    );
  }

  factory FluxChatMessage.ai(String content, {bool isMarkdown = false}) {
    return FluxChatMessage(
      content: content,
      type: FluxMessageType.ai,
      isMarkdown: isMarkdown,
    );
  }

  factory FluxChatMessage.roadmap(String content) {
    return FluxChatMessage(
      content: content,
      type: FluxMessageType.roadmap,
      isMarkdown: true,
    );
  }

  factory FluxChatMessage.system(String content) {
    return FluxChatMessage(
      content: content,
      type: FluxMessageType.system,
    );
  }
}

