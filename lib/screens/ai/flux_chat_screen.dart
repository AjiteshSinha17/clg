import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../state/theme_provider.dart';
import '../../state/user_provider.dart';
import '../../services/flux_ai_provider.dart';
import '../../models/flux_chat_message.dart';

// Flux soft theme
const _fluxPrimary = Color(0xFF6B4DFF); // Soft electric purple
const _fluxPrimaryLight = Color(0xFF8B73FF); // Lighter purple variant

class FluxChatScreen extends StatelessWidget {
  const FluxChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FluxAiProvider()..addWelcomeMessage(),
      child: const _FluxChatBody(),
    );
  }
}

class _FluxChatBody extends StatefulWidget {
  const _FluxChatBody();

  @override
  State<_FluxChatBody> createState() => _FluxChatBodyState();
}

class _FluxChatBodyState extends State<_FluxChatBody> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _scrollController.dispose();
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 100,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage(BuildContext context) async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    _textController.clear();
    _focusNode.requestFocus();

    final ai = context.read<FluxAiProvider>();
    await ai.sendMessage(text);
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final isDark = themeProvider.themeMode == ThemeMode.dark;
    final currentUser = userProvider.user;

    final aiState = context.watch<FluxAiProvider>().state;
    if (aiState.autoScroll) _scrollToBottom();

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF161618) : const Color(0xFFF8F9FB),
      appBar: AppBar(
        title: const Text(
          'Flux AI',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: -0.5),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: isDark ? Colors.grey[800] : Colors.grey[300],
              backgroundImage: currentUser?.profileImageUrl != null
                  ? NetworkImage(currentUser!.profileImageUrl!)
                  : null,
              child: currentUser?.profileImageUrl == null
                  ? const Icon(Icons.person, size: 20, color: Colors.grey)
                  : null,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                itemCount: aiState.messages.length,
                itemBuilder: (context, index) {
                  final msg = aiState.messages[index];
                  final isUser = msg.type == FluxMessageType.user;
                  return _buildMessageBubble(
                    msg.content,
                    isUser,
                    isDark,
                    currentUser?.profileImageUrl,
                    msg.isMarkdown,
                  );
                },
              ),
            ),
            if (aiState.isLoading)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(_fluxPrimary),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Flux is typing...',
                      style: TextStyle(
                        color: isDark ? Colors.white54 : Colors.black54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            _buildInputBar(isDark, context),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(
    String text,
    bool isUser,
    bool isDark,
    String? userAvatarUrl,
    bool isMarkdown,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser)
            Container(
              margin: const EdgeInsets.only(right: 8, bottom: 4),
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: _fluxPrimary,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.auto_awesome,
                color: Colors.white,
                size: 14,
              ),
            ),
          Flexible(
            child: isUser
                ? _buildUserBubble(text)
                : _buildModelBubble(text, isDark, isMarkdown),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 14,
              backgroundColor: isDark ? Colors.grey[800] : Colors.grey[300],
              backgroundImage:
                  userAvatarUrl != null ? NetworkImage(userAvatarUrl) : null,
              child: userAvatarUrl == null
                  ? const Icon(Icons.person, size: 16, color: Colors.grey)
                  : null,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildUserBubble(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: _fluxPrimary,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(6),
        ),
        boxShadow: [
          BoxShadow(
            color: _fluxPrimary.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
    );
  }

  Widget _buildModelBubble(String text, bool isDark, bool isMarkdown) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF242424) : Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
          bottomRight: Radius.circular(20),
          bottomLeft: Radius.circular(6),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: isMarkdown
          ? MarkdownBody(
              data: text,
              selectable: true,
              styleSheet: MarkdownStyleSheet(
                p: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontSize: 15,
                ),
                a: const TextStyle(
                  color: _fluxPrimaryLight,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTapLink: (t, href, title) async {
                if (href != null) {
                  final url = Uri.parse(href);
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  }
                }
              },
            )
          : Text(
              text,
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontSize: 15,
              ),
            ),
    );
  }

  Widget _buildInputBar(bool isDark, BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161618) : const Color(0xFFF8F9FB),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: TextField(
                controller: _textController,
                focusNode: _focusNode,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(context),
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                ),
                decoration: InputDecoration(
                  hintText: 'Ask Flux anything...',
                  hintStyle: TextStyle(
                    color: isDark ? Colors.white38 : Colors.black38,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  suffixIcon: Icon(
                    Icons.mic_none_outlined,
                    color: _fluxPrimary.withValues(alpha: 0.8),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () => _sendMessage(context),
            child: Container(
              height: 52,
              width: 52,
              decoration: BoxDecoration(
                color: _fluxPrimary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: _fluxPrimary.withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.send_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
