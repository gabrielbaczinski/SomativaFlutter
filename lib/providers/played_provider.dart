import 'package:flutter/material.dart';
import '../models/game.dart';
import '../services/persistence_service.dart';

class PlayedProvider extends ChangeNotifier {
  final _persistence = PersistenceService();
  List<Game> _played = [];

  List<Game> get played => List.unmodifiable(_played);

  Future<void> load() async {
    _played = await _persistence.loadPlayed();
    notifyListeners();
  }

  bool isPlayed(int id) => _played.any((g) => g.id == id);

  Future<void> toggle(Game game) async {
    if (isPlayed(game.id)) {
      _played.removeWhere((g) => g.id == game.id);
    } else {
      _played.add(game);
    }
    await _persistence.savePlayed(_played);
    notifyListeners();
  }
}
