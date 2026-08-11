import 'package:flutter/material.dart';
import '../models/message.dart';
import '../utils/timestamp_utils.dart';
import '../config/theme.dart';

/// Aquatic Nebula Neumorphism + Liquid Glass chat bubble for community and direct chats.
class ChatBubble extends StatelessWidget {
  final Message message;
  final bool isMe;

  const ChatBubble({super.key, required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // ── Colors ───────────────────────────────────────────────────────────
    final sentGradient = AppTheme.primaryGradient(isDark);
    final recvColor = isDark
        ? AppTheme.darkContainer.withValues(alpha: 0.85)
        : Colors.white.withValues(alpha: 0.90);
    final recvBorder = Border.all(
      color: isDark
          ? AppTheme.darkPrimary.withValues(alpha: 0.25)
          : const Color(0xFF18D8D0).withValues(alpha: 0.35),
      width: 1,
    );

    // ── Shadows ───────────────────────────────────────────────────────────
    final shadows = isMe
        ? [
            BoxShadow(
              color: AppTheme.aquaGlow.withValues(alpha: isDark ? 0.35 : 0.25),
              blurRadius: 10,
              offset: const Offset(2, 4),
            ),
          ]
        : AppTheme.neumorphicShadows(isDark);

    // ── Border radius ─────────────────────────────────────────────────────
    final radius = BorderRadius.only(
      topLeft: const Radius.circular(22),
      topRight: const Radius.circular(22),
      bottomLeft: isMe ? const Radius.circular(22) : const Radius.circular(4),
      bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(22),
    );

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isMe
              ? (isDark ? AppTheme.darkAquaticBg : null)
              : recvColor,
          gradient: isMe
              ? (isDark ? null : sentGradient)
              : null,
          borderRadius: radius,
          border: isMe
              ? (isDark ? Border.all(color: AppTheme.goldenBorder, width: 1.2) : null)
              : recvBorder,
          boxShadow: shadows,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isMe)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    message.senderName,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? AppTheme.softBeige
                          : AppTheme.lightPrimary,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              if (message.imageUrl != null && message.imageUrl!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.network(message.imageUrl!, fit: BoxFit.cover),
                  ),
                ),
              Text(
                message.content,
                style: TextStyle(
                  color: isMe
                      ? (isDark ? AppTheme.softBeige : Colors.white)
                      : (isDark
                            ? AppTheme.darkOnSurface
                            : AppTheme.lightOnSurface),
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 4),
              Align(
                alignment: Alignment.bottomRight,
                child: Text(
                  _formatTime(message.timestamp),
                  style: TextStyle(
                    fontSize: 10,
                    color: isMe
                        ? (isDark ? AppTheme.softBeige.withValues(alpha: 0.8) : Colors.white.withValues(alpha: 0.75))
                        : (isDark
                              ? AppTheme.darkOnSurfaceVariant
                              : AppTheme.lightOnSurfaceVariant),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime time) => formatMessageTimestamp(time);
}

