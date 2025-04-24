import 'package:flutter/foundation.dart';

class TagFilterProvider with ChangeNotifier {
  List<String> _selectedTags = [];
  List<String> _availableTags = [];

  List<String> get selectedTags => _selectedTags;
  List<String> get availableTags => _availableTags;

  void setAvailableTags(List<String> tags) {
    _availableTags = tags;
    notifyListeners();
  }

  void toggleTag(String tag) {
    if (_selectedTags.contains(tag)) {
      _selectedTags.remove(tag);
    } else {
      _selectedTags.add(tag);
    }
    notifyListeners();
  }

  void clearTags() {
    _selectedTags.clear();
    notifyListeners();
  }
}