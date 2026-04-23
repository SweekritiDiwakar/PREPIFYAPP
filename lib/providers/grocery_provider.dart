import 'package:flutter/foundation.dart';
import 'package:prepify/models/grocery_list.dart';
import 'package:prepify/services/grocery_service.dart';

class GroceryProvider extends ChangeNotifier {
  List<GroceryList> _lists = [];
  bool _isLoading = false;

  List<GroceryList> get lists => _lists;
  bool get isLoading => _isLoading;

  GroceryProvider() {
    _initStream();
  }

  void _initStream() {
    _isLoading = true;
    notifyListeners();
    GroceryService.streamUserLists().listen((data) {
      _lists = data;
      _isLoading = false;
      notifyListeners();
    }, onError: (e) {
      debugPrint('Grocery stream error: $e');
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> createList(String name) async {
    await GroceryService.createList(name);
  }
}
