import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:firebase_auth/firebase_auth.dart' as auth;
import '../../services/chat_service.dart';
import '../../services/user_service.dart';
import '../../models/chat.dart';
import '../../models/user.dart';
import '../../utils/timestamp_utils.dart';

class ChatsListScreen extends StatelessWidget {
  const ChatsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final chatService = ChatService();
    final currentUserId = auth.FirebaseAuth.instance.currentUser?.uid;

    if (currentUserId == null) {
      return const Center(child: Text('Please login to view chats'));
    }

    return Scaffold(
      body: StreamBuilder<List<Chat>>(
        stream: chatService.getChatsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final chats = snapshot.data ?? [];

          if (chats.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No chats yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Connect with others to start chatting!',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index];
              final otherUserId = chat.participants.firstWhere(
                (id) => id != currentUserId,
                orElse: () => '',
              );

              if (otherUserId.isEmpty) return const SizedBox.shrink();

              return _ChatListItem(chat: chat, otherUserId: otherUserId);
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

  const _ChatListItem({required this.chat, required this.otherUserId});

  @override
  Widget build(BuildContext context) {
    final userService = UserService();

    return FutureBuilder<User?>(
      future: userService.getUserProfile(otherUserId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const ListTile(
            leading: CircleAvatar(child: Icon(Icons.person)),
            title: Text('Loading...'),
          );
        }

        final user = snapshot.data!;
        final lastMessageTime = _formatTime(chat.lastMessageTime);

        return ListTile(
          leading: CircleAvatar(
            backgroundImage: user.avatarUrl.isNotEmpty
                ? NetworkImage(user.avatarUrl)
                : null,
            child: user.avatarUrl.isEmpty
                ? Text(user.name.isNotEmpty ? user.name[0].toUpperCase() : '?')
                : null,
          ),
          title: Text(
            user.name,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            chat.lastMessage,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Text(
            lastMessageTime,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          onTap: () {
            context.push('/chat/${chat.id}', extra: user);
          },
        );
      },
    );
  }

  // Modified: Use shared timestamp formatting utility
  String _formatTime(DateTime time) {
    return formatMessageTimestamp(time);
  }
}
