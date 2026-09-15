import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/pokemon.dart';

class PersistenceService {
  static const String _favoritesKey = 'favorites_v4';
  static const String _watchedKey = 'watched_v4';

  Future<List<Pokemon>> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_favoritesKey);
    if (json == null) return [];
    final List<dynamic> list = jsonDecode(json);
    return list
        .map((j) => Pokemon.fromJson(j as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveFavorites(List<Pokemon> pokemons) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _favoritesKey, jsonEncode(pokemons.map((p) => p.toJson()).toList()));
  }

  Future<List<Pokemon>> loadWatched() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_watchedKey);
    if (json == null) return [];
    final List<dynamic> list = jsonDecode(json);
    return list
        .map((j) => Pokemon.fromJson(j as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveWatched(List<Pokemon> pokemons) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _watchedKey, jsonEncode(pokemons.map((p) => p.toJson()).toList()));
  }
}
