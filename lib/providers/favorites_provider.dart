import 'package:flutter/material.dart';
import '../models/game.dart';
import '../services/persistence_service.dart';

class FavoritesProvider extends ChangeNotifier {
  final _persistence = PersistenceService();
  List<Game> _favorites = [];

  List<Game> get favorites => List.unmodifiable(_favorites);

  Future<void> load() async {
    _favorites = await _persistence.loadFavorites();
    notifyListeners();
  }

  bool isFavorite(int id) => _favorites.any((g) => g.id == id);

  Future<void> toggle(Game game) async {
    if (isFavorite(game.id)) {
      _favorites.removeWhere((g) => g.id == game.id);
    } else {
      _favorites.add(game);
    }
    await _persistence.saveFavorites(_favorites);
    notifyListeners();
  }
}
