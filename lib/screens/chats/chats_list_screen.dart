import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:provider/provider.dart';
import '../../services/chat_service.dart';
import '../../services/user_service.dart';
import '../../models/chat.dart';
import '../../models/user.dart';
import '../../utils/timestamp_utils.dart';
import '../../config/theme.dart';
import '../../state/theme_provider.dart';

class ChatsListScreen extends StatelessWidget {
  const ChatsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final chatService = ChatService();
    final currentUserId = auth.FirebaseAuth.instance.currentUser?.uid;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.themeMode == ThemeMode.dark;

    if (currentUserId == null) {
      return const Center(child: Text('Please login to view chats'));
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: StreamBuilder<List<Chat>>(
        stream: chatService.getChatsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                color: isDark ? AppTheme.darkPrimary : AppTheme.lightPrimary,
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: TextStyle(
                  color: isDark ? AppTheme.darkOnSurface : AppTheme.lightOnSurface,
                ),
              ),
            );
          }

          final chats = snapshot.data ?? [];

          if (chats.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDark
                          ? AppTheme.darkPrimaryContainer.withValues(alpha: 0.15)
                          : const Color(0xFF006A66).withValues(alpha: 0.08),
                      border: Border.all(
                        color: isDark
                            ? AppTheme.darkPrimaryContainer.withValues(alpha: 0.4)
                            : const Color(0xFF18D8D0).withValues(alpha: 0.4),
                      ),
                    ),
                    child: Icon(
                      Icons.chat_bubble_outline_rounded,
                      size: 48,
                      color: isDark ? AppTheme.darkPrimary : AppTheme.lightPrimary,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'No chats yet',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppTheme.darkOnSurface : AppTheme.lightOnSurface,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Connect with others to start chatting!',
                    style: TextStyle(
                      color: isDark
                          ? AppTheme.darkOnSurfaceVariant
                          : AppTheme.lightOnSurfaceVariant,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index];
              final otherUserId = chat.participants.firstWhere(
                (id) => id != currentUserId,
                orElse: () => '',
              );

              if (otherUserId.isEmpty) return const SizedBox.shrink();

              return _ChatListItem(
                chat: chat,
                otherUserId: otherUserId,
                isDark: isDark,
              );
            },
          );
        },
      ),
    );
  }
}

class _ChatListItem extends StatelessWidget {
  final Chat chat;
  final String otherUserId;
  final bool isDark;

  const _ChatListItem({
    required this.chat,
    required this.otherUserId,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final userService = UserService();

    return FutureBuilder<User?>(
      future: userService.getUserProfile(otherUserId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: _buildTile(
              context,
              leading: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark ? AppTheme.darkContainer : Colors.white,
                ),
                child: Icon(
                  Icons.person_rounded,
                  color: isDark ? AppTheme.darkPrimary : AppTheme.lightPrimary,
                ),
              ),
              title: const Text('Loading...'),
              subtitle: const SizedBox.shrink(),
              trailing: const SizedBox.shrink(),
              onTap: null,
            ),
          );
        }

        final user = snapshot.data!;
        final lastMessageTime = formatMessageTimestamp(chat.lastMessageTime);

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: _buildTile(
            context,
            leading: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark ? AppTheme.darkPrimary : AppTheme.lightPrimary,
                  width: 1.5,
                ),
              ),
              child: CircleAvatar(
                radius: 22,
                backgroundColor: isDark ? AppTheme.darkContainer : Colors.white,
                backgroundImage: user.avatarUrl.isNotEmpty
                    ? NetworkImage(user.avatarUrl)
                    : null,
                child: user.avatarUrl.isEmpty
                    ? Text(
                        user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? AppTheme.darkOnSurface
                              : AppTheme.lightOnSurface,
                          fontSize: 16,
                        ),
                      )
                    : null,
              ),
            ),
            title: Text(
              user.name,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
                color: isDark ? AppTheme.darkOnSurface : AppTheme.lightOnSurface,
              ),
            ),
            subtitle: Text(
              chat.lastMessage,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                color: isDark
                    ? AppTheme.darkOnSurfaceVariant
                    : AppTheme.lightOnSurfaceVariant,
              ),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  lastMessageTime,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? AppTheme.darkPrimary : AppTheme.lightPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            onTap: () => context.push('/chat/${chat.id}', extra: user),
          ),
        );
      },
    );
  }

  Widget _buildTile(
    BuildContext context, {
    required Widget leading,
    required Widget title,
    required Widget subtitle,
    required Widget trailing,
    required VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: AppTheme.liquidGlassDecoration(
          isDark: isDark,
          radius: 20,
        ),
        child: Row(
          children: [
            leading,
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [title, const SizedBox(height: 2), subtitle],
              ),
            ),
            const SizedBox(width: 8),
            trailing,
          ],
        ),
      ),
    );
  }
}
