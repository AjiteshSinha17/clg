import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:firebase_auth/firebase_auth.dart' as auth;
import '../../services/chat_service.dart';
import '../../services/user_service.dart';
import '../../models/chat.dart';
import '../../models/user.dart';
import '../../utils/timestamp_utils.dart';

// Soft orange-white gradient palette
const _softOrange = Color(0xFFFF8C38);
const _softOrangeLight = Color(0xFFFFB870);

class ChatsListScreen extends StatelessWidget {
  const ChatsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final chatService = ChatService();
    final currentUserId = auth.FirebaseAuth.instance.currentUser?.uid;
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
                valueColor: const AlwaysStoppedAnimation<Color>(_softOrange),
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
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
                      gradient: LinearGradient(
                        colors: [
                          _softOrangeLight.withValues(alpha: 0.15),
                          _softOrange.withValues(alpha: 0.10),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _softOrange.withValues(alpha: 0.20),
                          blurRadius: 20,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.chat_bubble_outline_rounded,
                      size: 52,
                      color: _softOrange.withValues(alpha: 0.70),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'No chats yet',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Connect with others to start chatting!',
                    style: TextStyle(
                      color: isDark ? Colors.white38 : Colors.black38,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
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
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            child: _buildClayTile(
              context,
              leading: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark
                      ? const Color(0xFF2A2A2A)
                      : const Color(0xFFF0EDE8),
                ),
                child: const Icon(Icons.person_rounded, color: _softOrange),
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
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          child: _buildClayTile(
            context,
            leading: Container(
              padding: const EdgeInsets.all(2.5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [_softOrangeLight, _softOrange],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _softOrange.withValues(alpha: 0.30),
                    blurRadius: 8,
                    spreadRadius: 1,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 23,
                backgroundColor: isDark
                    ? const Color(0xFF1C1C1C)
                    : Colors.white,
                backgroundImage: user.avatarUrl.isNotEmpty
                    ? NetworkImage(user.avatarUrl)
                    : null,
                child: user.avatarUrl.isEmpty
                    ? Text(
                        user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _softOrange,
                          fontSize: 16,
                        ),
                      )
                    : null,
              ),
            ),
            title: Text(
              user.name,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            subtitle: Text(
              chat.lastMessage,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.40)
                    : Colors.black.withValues(alpha: 0.40),
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
                    color: _softOrange.withValues(alpha: 0.75),
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

  Widget _buildClayTile(
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
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1C1C1C) : const Color(0xFFFFF9F4),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.07)
                : _softOrange.withValues(alpha: 0.12),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.07),
              blurRadius: 16,
              spreadRadius: 0,
              offset: const Offset(0, 6),
            ),
            BoxShadow(
              color: Colors.white.withValues(alpha: isDark ? 0.04 : 0.80),
              blurRadius: 0,
              offset: const Offset(0, -1),
            ),
          ],
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
