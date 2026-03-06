import 'package:intl/intl.dart';

/// Shared timestamp formatting for chat messages.
///
/// Always shows full date + time so it's clear
/// when a message was sent, for example:
/// "5 Mar 2026 • 6:05 PM".
String formatMessageTimestamp(DateTime time) {
  final dateStr = DateFormat('d MMM yyyy').format(time); // e.g. "5 Mar 2026"
  final timeStr = DateFormat('h:mm a').format(time); // e.g. "6:05 PM"
  return '$dateStr • $timeStr';
}
