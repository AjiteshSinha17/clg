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
    final primaryColor = isDark ? AppTheme.darkPrimary : AppTheme.lightPrimary;
    final connectionService = ConnectionService();

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(
          'Connection Requests',
          style: TextStyle(
            color: isDark ? AppTheme.darkOnSurface : AppTheme.lightOnSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: context.canPop()
            ? IconButton(
                icon: Icon(
                  Icons.arrow_back_rounded,
                  color: isDark ? AppTheme.darkOnSurface : AppTheme.lightOnSurface,
                ),
                onPressed: () => context.pop(),
              )
            : null,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: StreamBuilder<List<ConnectionRequest>>(
          stream: connectionService.getPendingRequestsToMeStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(color: primaryColor),
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
            final list = snapshot.data ?? [];
            if (list.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.inbox_rounded,
                      size: 56,
                      color: primaryColor.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No pending connection requests',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppTheme.darkOnSurfaceVariant
                            : AppTheme.lightOnSurfaceVariant,
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
                  isDark: isDark,
                  onAccept: () => _acceptAndOpenChat(context, req),
                  onReject: () => _reject(context, req),
                );
              },
            );
          },
        ),
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
  final bool isDark;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const _RequestTile({
    required this.request,
    required this.isDark,
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

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: AppTheme.liquidGlassDecoration(
            isDark: isDark,
            radius: 20,
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: isDark
                      ? AppTheme.darkContainer
                      : const Color(0xFFE6F5F3),
                  backgroundImage: avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
                  child: avatarUrl.isEmpty
                      ? Text(
                          name.isNotEmpty ? name[0].toUpperCase() : '?',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppTheme.darkPrimary : AppTheme.lightPrimary,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppTheme.darkOnSurface : AppTheme.lightOnSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Wants to connect with you',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? AppTheme.darkOnSurfaceVariant
                              : AppTheme.lightOnSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: onReject,
                  child: Text(
                    'Reject',
                    style: TextStyle(
                      color: isDark ? AppTheme.darkOutline : AppTheme.lightOutline,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: onAccept,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient(isDark),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.aquaGlow.withValues(
                            alpha: isDark ? 0.35 : 0.2,
                          ),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Text(
                      'Accept',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
