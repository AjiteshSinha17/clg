import 'package:flutter/foundation.dart';

class RoommateProvider extends ChangeNotifier {
  final List<String> _roommates = [];

  List<String> get roommates => List.unmodifiable(_roommates);

  void addRoommate(String id) {
    _roommates.add(id);
    notifyListeners();
  }
}
