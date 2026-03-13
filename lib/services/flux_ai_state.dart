import '../models/flux_chat_message.dart';

class FluxAiState {
  final List<FluxChatMessage> messages;
  final bool isLoading;
  final bool autoScroll;

  const FluxAiState({
    this.messages = const [],
    this.isLoading = false,
    this.autoScroll = true,
  });

  FluxAiState copyWith({
    List<FluxChatMessage>? messages,
    bool? isLoading,
    bool? autoScroll,
  }) {
    return FluxAiState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      autoScroll: autoScroll ?? this.autoScroll,
    );
  }
}

