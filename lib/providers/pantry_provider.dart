import 'package:flutter/foundation.dart';
import 'package:prepify/models/pantry_item.dart';
import 'package:prepify/services/pantry_service.dart';

class PantryProvider extends ChangeNotifier {
  List<PantryItem> _items = [];
  bool _isLoading = false;

  List<PantryItem> get items => _items;
  bool get isLoading => _isLoading;

  PantryProvider() {
    _initStream();
  }

  void _initStream() {
    _isLoading = true;
    notifyListeners();
    PantryService.streamPantry().listen((data) {
      _items = data;
      _isLoading = false;
      notifyListeners();
    }, onError: (e) {
      debugPrint('Pantry stream error: $e');
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> addItem(String name, int quantity, {int threshold = 1}) async {
    await PantryService.addOrUpdateItem(name, quantity, threshold: threshold);
  }
}
