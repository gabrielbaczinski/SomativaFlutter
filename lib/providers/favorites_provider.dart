import 'package:flutter/foundation.dart';
import '../models/pokemon.dart';
import '../services/persistence_service.dart';

class FavoritesProvider extends ChangeNotifier {
  final PersistenceService _persistence = PersistenceService();
  List<Pokemon> _favorites = [];

  List<Pokemon> get favorites => List.unmodifiable(_favorites);

  Future<void> load() async {
    _favorites = await _persistence.loadFavorites();
    notifyListeners();
  }

  bool isFavorite(String id) => _favorites.any((p) => p.id == id);

  Future<void> toggle(Pokemon pokemon) async {
    if (isFavorite(pokemon.id)) {
      _favorites.removeWhere((p) => p.id == pokemon.id);
    } else {
      _favorites.add(pokemon);
    }
    await _persistence.saveFavorites(_favorites);
    notifyListeners();
  }
}
