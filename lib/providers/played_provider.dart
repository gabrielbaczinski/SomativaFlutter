import 'package:flutter/foundation.dart';
import '../models/pokemon.dart';
import '../services/persistence_service.dart';

class PlayedProvider extends ChangeNotifier {
  final PersistenceService _persistence = PersistenceService();
  List<Pokemon> _watched = [];

  List<Pokemon> get watched => List.unmodifiable(_watched);

  Future<void> load() async {
    _watched = await _persistence.loadWatched();
    notifyListeners();
  }

  bool isWatched(String id) => _watched.any((p) => p.id == id);

  Future<void> toggle(Pokemon pokemon) async {
    if (isWatched(pokemon.id)) {
      _watched.removeWhere((p) => p.id == pokemon.id);
    } else {
      _watched.add(pokemon);
    }
    await _persistence.saveWatched(_watched);
    notifyListeners();
  }
}
