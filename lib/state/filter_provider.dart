import 'package:flutter/foundation.dart';

class FilterProvider extends ChangeNotifier {
  final Map<String, dynamic> _filters = {};

  Map<String, dynamic> get filters => Map.unmodifiable(_filters);

  void updateFilter(String key, dynamic value) {
    _filters[key] = value;
    notifyListeners();
  }
}
