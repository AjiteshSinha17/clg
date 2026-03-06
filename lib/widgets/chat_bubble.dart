import 'package:flutter/material.dart';
import '../models/message.dart';
import '../utils/timestamp_utils.dart';
import '../config/theme.dart';

/// Claymorphism + Skeuomorphism chat bubble for the community chat widget.
/// (Used in community_chat_screen.dart — the shared ChatBubble widget)
class ChatBubble extends StatelessWidget {
  final Message message;
  final bool isMe;

  const ChatBubble({super.key, required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // ── Colors ───────────────────────────────────────────────────────────
    final sentGradient = const LinearGradient(
      colors: [AppTheme.orange, AppTheme.orangeDark],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
    final recvColor = isDark ? AppTheme.darkCard : AppTheme.lightCard;
    final recvBorder = isDark
        ? Border.all(color: Colors.white.withValues(alpha: 0.07), width: 1)
        : Border.all(color: Colors.black.withValues(alpha: 0.06), width: 1);

    // ── Shadows ───────────────────────────────────────────────────────────
    final shadows = isMe
        ? AppTheme.clayShadowSent
        : (isDark ? AppTheme.clayShadowRecvDark : AppTheme.clayShadowRecvLight);

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
          maxWidth: MediaQuery.of(context).size.width * 0.72,
        ),
        decoration: BoxDecoration(
          gradient: isMe ? sentGradient : null,
          color: isMe ? null : recvColor,
          borderRadius: radius,
          border: isMe ? null : recvBorder,
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
                      color: AppTheme.orange,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              if (message.imageUrl != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(message.imageUrl!, fit: BoxFit.cover),
                  ),
                ),
              Text(
                message.content,
                style: TextStyle(
                  color: isMe
                      ? Colors.white
                      : (isDark
                            ? Colors.white.withValues(alpha: 0.87)
                            : const Color(0xFF1A1A1A)),
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
                        ? Colors.white.withValues(alpha: 0.65)
                        : (isDark
                              ? Colors.white.withValues(alpha: 0.45)
                              : Colors.black.withValues(alpha: 0.40)),
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
