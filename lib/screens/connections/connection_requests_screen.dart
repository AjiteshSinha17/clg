import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../models/connection_request.dart';
import '../../models/user.dart';
import '../../services/connection_service.dart';
import '../../state/theme_provider.dart';

/// Lists pending connection requests to the current user. Accept/Reject opens chat on accept.
class ConnectionRequestsScreen extends StatelessWidget {
  const ConnectionRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.themeMode == ThemeMode.dark;
    final connectionService = ConnectionService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Connection requests'),
        backgroundColor: isDark ? AppTheme.paletteCharcoal : AppTheme.paletteCream,
      ),
      body: StreamBuilder<List<ConnectionRequest>>(
        stream: connectionService.getPendingRequestsToMeStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final list = snapshot.data ?? [];
          if (list.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No pending requests',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            itemBuilder: (context, index) {
              final req = list[index];
              return _RequestTile(
                request: req,
                onAccept: () => _acceptAndOpenChat(context, req),
                onReject: () => _reject(context, req),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _acceptAndOpenChat(BuildContext context, ConnectionRequest req) async {
    final connectionService = ConnectionService();
    try {
      final chatId = await connectionService.acceptRequest(req.id);
      if (!context.mounted) return;
      final user = await _fetchUser(req.fromUserId);
      if (user != null && context.mounted) {
        context.push('/chat/$chatId', extra: user);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    }
  }

  Future<void> _reject(BuildContext context, ConnectionRequest req) async {
    final connectionService = ConnectionService();
    try {
      await connectionService.rejectRequest(req.id);
    } catch (_) {}
  }

  Future<User?> _fetchUser(String uid) async {
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (doc.exists) return User.fromFirestore(doc);
    return null;
  }
}

class _RequestTile extends StatelessWidget {
  final ConnectionRequest request;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const _RequestTile({
    required this.request,
    required this.onAccept,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(request.fromUserId).get(),
      builder: (context, snapshot) {
        User? fromUser;
        if (snapshot.hasData && snapshot.data!.exists) {
          fromUser = User.fromFirestore(snapshot.data!);
        }
        final name = fromUser?.name ?? 'Someone';
        final avatarUrl = fromUser?.avatarUrl ?? '';

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundImage: avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
              child: avatarUrl.isEmpty ? Text(name.isNotEmpty ? name[0].toUpperCase() : '?') : null,
            ),
            title: Text(name),
            subtitle: const Text('Wants to connect'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton(onPressed: onReject, child: const Text('Reject')),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: onAccept,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.paletteViolet,
                  ),
                  child: const Text('Accept'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
