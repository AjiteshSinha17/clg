import 'package:flutter/foundation.dart';

/// Minimal CommunityProvider to satisfy app wiring. Expand with real logic.
class CommunityProvider extends ChangeNotifier {
  // placeholder state
  final List<String> _communities = [];

  List<String> get communities => List.unmodifiable(_communities);

  void addCommunity(String id) {
    _communities.add(id);
    notifyListeners();
  }
}
