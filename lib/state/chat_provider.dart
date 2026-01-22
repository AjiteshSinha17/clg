import 'package:flutter/foundation.dart';

class ChatProvider extends ChangeNotifier {
  // placeholder chat list
  final List<String> _chats = [];

  List<String> get chats => List.unmodifiable(_chats);

  void addChat(String id) {
    _chats.add(id);
    notifyListeners();
  }
}
