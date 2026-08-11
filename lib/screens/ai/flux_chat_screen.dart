import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../state/theme_provider.dart';
import '../../state/user_provider.dart';
import '../../services/flux_ai_provider.dart';
import '../../models/flux_chat_message.dart';
import '../../config/theme.dart';

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

  Future<void> _sendMessage(BuildContext context, [String? presetText]) async {
    final text = (presetText ?? _textController.text).trim();
    if (text.isEmpty) return;

    if (presetText == null) {
      _textController.clear();
    }
    _focusNode.unfocus();

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
      backgroundColor: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
      body: Stack(
        children: [
          // Ambient Radial Background Gradient
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, -0.6),
                  radius: 1.2,
                  colors: isDark
                      ? const [
                          Color(0xFF412D15),
                          Color(0xFF1F150C),
                          Color(0xFF090604),
                        ]
                      : [
                          const Color(0xFFFAF3EA),
                          const Color(0xFFF3FBFA),
                          Colors.white,
                        ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Top Custom Header Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF1F150C).withValues(alpha: 0.8)
                                : Colors.white.withValues(alpha: 0.8),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isDark
                                  ? AppTheme.goldenBorder.withValues(alpha: 0.3)
                                  : AppTheme.lightOutline,
                            ),
                          ),
                          child: Icon(
                            Icons.menu_rounded,
                            color: isDark ? AppTheme.softBeige : AppTheme.lightOnSurface,
                            size: 20,
                          ),
                        ),
                      ),
                      Text(
                        'ClgJone',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                          color: isDark ? AppTheme.softBeige : AppTheme.lightOnSurface,
                        ),
                      ),
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDark ? AppTheme.goldenBorder : AppTheme.lightPrimary,
                            width: 1.5,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 18,
                          backgroundColor: isDark ? AppTheme.darkContainer : AppTheme.lightContainer,
                          backgroundImage: currentUser?.avatarUrl != null && currentUser!.avatarUrl.isNotEmpty
                              ? NetworkImage(currentUser.avatarUrl) as ImageProvider
                              : null,
                          child: currentUser?.avatarUrl == null || currentUser!.avatarUrl.isEmpty
                              ? Icon(
                                  Icons.person_rounded,
                                  size: 20,
                                  color: isDark ? AppTheme.softBeige : AppTheme.lightPrimary,
                                )
                              : null,
                        ),
                      ),
                    ],
                  ),
                ),

                // Main Workspace Scroll Area
                Expanded(
                  child: ListView(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 110),
                    children: [
                      // 1. AI Wave Processing Loader Header & Welcoming Text
                      const SizedBox(height: 12),
                      const _WaveDotLoader(),
                      const SizedBox(height: 16),
                      Text(
                        currentUser?.name.isNotEmpty == true
                            ? 'Welcome, ${currentUser!.name.split(' ').first}! 👋'
                            : 'Welcome to Flux AI 👋',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppTheme.softBeige : AppTheme.lightOnSurface,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Your intelligent assistant for academics, hackathons, roommate tips & career roadmaps.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? AppTheme.darkOnSurfaceVariant : AppTheme.lightOnSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Section Title
                      Text(
                        'What can Flux AI do?',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppTheme.darkOnSurface : AppTheme.lightOnSurface,
                        ),
                      ),
                      const SizedBox(height: 14),

                      // 2. 4 Interactive Capability Cards Grid (2x2)
                      Row(
                        children: [
                          Expanded(
                            child: _buildBentoCard(
                              context: context,
                              isDark: isDark,
                              icon: Icons.school_rounded,
                              title: 'Academic Helper',
                              subtitle: 'Explain concepts & prepare for exams',
                              onTap: () => _sendMessage(
                                context,
                                'Help me summarize key concepts and prepare for upcoming college exams.',
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildBentoCard(
                              context: context,
                              isDark: isDark,
                              icon: Icons.emoji_events_rounded,
                              title: 'Events & Hackathons',
                              subtitle: 'Find top competitions & prize pools',
                              onTap: () => _sendMessage(
                                context,
                                'What are the top upcoming college hackathons and tech events in India?',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildBentoCard(
                              context: context,
                              isDark: isDark,
                              icon: Icons.group_rounded,
                              title: 'Roommate Advice',
                              subtitle: 'Tips for living & finding roommates',
                              onTap: () => _sendMessage(
                                context,
                                'What are the best tips for finding a compatible college roommate and managing budget?',
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildBentoCard(
                              context: context,
                              isDark: isDark,
                              icon: Icons.alt_route_rounded,
                              title: 'Career Roadmaps',
                              subtitle: 'Step-by-step paths for AI & Coding',
                              onTap: () => _sendMessage(
                                context,
                                'Create a step-by-step learning roadmap for Web & Mobile Development in 2026.',
                              ),
                            ),
                          ),
                        ],
                      ),

                      // 4. Conversation Messages Stream
                      if (aiState.messages.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        Divider(
                          color: isDark
                              ? AppTheme.goldenBorder.withValues(alpha: 0.2)
                              : Colors.black12,
                        ),
                        const SizedBox(height: 16),
                        ...aiState.messages.map((msg) {
                          final isUser = msg.type == FluxMessageType.user;
                          return _buildMessageBubble(
                            msg.content,
                            isUser,
                            isDark,
                            currentUser?.avatarUrl,
                            msg.isMarkdown,
                          );
                        }),
                      ],

                      if (aiState.isLoading)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: isDark ? AppTheme.goldenBorder : AppTheme.lightPrimary,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'Flux is thinking...',
                                style: TextStyle(
                                  color: isDark ? AppTheme.softBeige : AppTheme.lightOnSurfaceVariant,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 5. Glassmorphic Floating Bottom Input Bar
          Positioned(
            left: 16,
            right: 16,
            bottom: 20,
            child: _buildFloatingInputBar(isDark, context),
          ),
        ],
      ),
    );
  }

  // ── Bento Cards ─────────────────────────────────────────────────────────────
  Widget _buildBentoCard({
    required BuildContext context,
    required bool isDark,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 130),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF412D15).withValues(alpha: 0.6) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark
                ? AppTheme.goldenBorder.withValues(alpha: 0.25)
                : AppTheme.lightOutline,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkAquaticBg : const Color(0xFFE6F5F3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isDark ? AppTheme.goldenBorder : AppTheme.lightPrimary,
                size: 20,
              ),
            ),
            const SizedBox(height: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppTheme.darkOnSurface : AppTheme.lightOnSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppTheme.darkOnSurfaceVariant : AppTheme.lightOnSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }



  // ── Floating Glassmorphic Input Bar ────────────────────────────────────────
  Widget _buildFloatingInputBar(bool isDark, BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1F150C).withValues(alpha: 0.85)
            : Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: isDark
              ? AppTheme.goldenBorder.withValues(alpha: 0.3)
              : AppTheme.lightOutline,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.5 : 0.12),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {},
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkAquaticBg : const Color(0xFFE6F5F3),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark ? AppTheme.goldenBorder : AppTheme.lightPrimary,
                  width: 1.2,
                ),
              ),
              child: Icon(
                Icons.add_rounded,
                color: isDark ? AppTheme.softBeige : AppTheme.lightPrimary,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _textController,
              focusNode: _focusNode,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(context),
              style: TextStyle(
                fontSize: 14,
                color: isDark ? AppTheme.softBeige : AppTheme.lightOnSurface,
              ),
              decoration: InputDecoration(
                hintText: 'Ask Flux anything...',
                hintStyle: TextStyle(
                  fontSize: 13,
                  color: isDark ? AppTheme.darkOnSurfaceVariant : AppTheme.lightOnSurfaceVariant,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => _sendMessage(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient(isDark),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: (isDark ? AppTheme.goldenBorder : AppTheme.lightPrimary)
                        .withValues(alpha: 0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(
                Icons.arrow_upward_rounded,
                color: isDark ? AppTheme.darkOnPrimary : Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Message Bubbles ────────────────────────────────────────────────────────
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
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser)
            Container(
              margin: const EdgeInsets.only(right: 8, bottom: 4),
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkAquaticBg : AppTheme.lightPrimary,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark ? AppTheme.goldenBorder : Colors.transparent,
                ),
              ),
              child: Icon(
                Icons.auto_awesome,
                color: isDark ? AppTheme.softBeige : Colors.white,
                size: 14,
              ),
            ),
          Flexible(
            child: isUser
                ? _buildUserBubble(text, isDark)
                : _buildModelBubble(text, isDark, isMarkdown),
          ),
        ],
      ),
    );
  }

  Widget _buildUserBubble(String text, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkAquaticBg : AppTheme.lightPrimary,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(6),
        ),
        border: isDark ? Border.all(color: AppTheme.goldenBorder, width: 1.2) : null,
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isDark ? AppTheme.softBeige : Colors.white,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildModelBubble(String text, bool isDark, bool isMarkdown) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkContainer : Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
          bottomRight: Radius.circular(20),
          bottomLeft: Radius.circular(6),
        ),
        border: Border.all(
          color: isDark ? AppTheme.goldenBorder.withValues(alpha: 0.2) : Colors.black12,
        ),
      ),
      child: isMarkdown
          ? MarkdownBody(
              data: text,
              selectable: true,
              styleSheet: MarkdownStyleSheet(
                p: TextStyle(
                  color: isDark ? AppTheme.darkOnSurface : AppTheme.lightOnSurface,
                  fontSize: 14,
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
                color: isDark ? AppTheme.darkOnSurface : AppTheme.lightOnSurface,
                fontSize: 14,
              ),
            ),
    );
  }
}

// ── 4-Dot Animated Wave Loader ────────────────────────────────────────────────
class _WaveDotLoader extends StatefulWidget {
  const _WaveDotLoader();

  @override
  State<_WaveDotLoader> createState() => _WaveDotLoaderState();
}

class _WaveDotLoaderState extends State<_WaveDotLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(4, (index) {
          return AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final delay = index * 0.25;
              final sinValue = math.sin((_controller.value * 2 * math.pi) - delay);
              final offsetY = sinValue * 8;
              final opacity = 0.5 + (sinValue + 1) * 0.25;

              return Transform.translate(
                offset: Offset(0, offsetY),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFFE4C17C), Color(0xFF5B452B)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFE4C17C)
                            .withValues(alpha: opacity.clamp(0.2, 0.8)),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
