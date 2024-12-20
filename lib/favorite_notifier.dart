import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoriteNotifier extends ValueNotifier<List<String>> {
  FavoriteNotifier() : super([]);

  Future<void> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    value = prefs.getStringList('favorites') ?? [];
  }

  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('favorites', value);
  }

  void toggleFavorite(String productId) async {
    if (value.contains(productId)) {
      value = List.from(value)..remove(productId);
    } else {
      value = List.from(value)..add(productId);
    }
    await _saveFavorites();
  }

  bool isFavorite(String productId) {
    return value.contains(productId);
  }
}
