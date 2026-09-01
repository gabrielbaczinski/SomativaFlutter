import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/game.dart';

class PersistenceService {
  static const _favoritesKey = 'favorites_v1';
  static const _playedKey = 'played_v1';

  Future<List<Game>> loadFavorites() => _load(_favoritesKey);
  Future<List<Game>> loadPlayed() => _load(_playedKey);
  Future<void> saveFavorites(List<Game> games) => _save(_favoritesKey, games);
  Future<void> savePlayed(List<Game> games) => _save(_playedKey, games);

  Future<List<Game>> _load(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(key);
    if (raw == null || raw.isEmpty) return [];
    final list = json.decode(raw) as List<dynamic>;
    return list.map((e) => Game.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> _save(String key, List<Game> games) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      key,
      json.encode(games.map((g) => g.toJson()).toList()),
    );
  }
}
