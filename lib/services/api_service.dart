import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/game.dart';
import '../models/game_detail.dart';

class ApiService {
  static const _baseUrl = 'https://www.freetogame.com/api';
  static const _pageSize = 20;

  // Static cache so multiple ApiService instances share the same data
  static List<Game>? _allGames;

  Future<List<Game>> _fetchAllGames() async {
    if (_allGames != null) return _allGames!;
    final response =
        await http.get(Uri.parse('$_baseUrl/games')).timeout(const Duration(seconds: 15));
    if (response.statusCode != 200) {
      throw Exception('Falha ao carregar jogos (HTTP ${response.statusCode})');
    }
    final list = json.decode(response.body) as List<dynamic>;
    _allGames = list.map((e) => Game.fromJson(e as Map<String, dynamic>)).toList();
    return _allGames!;
  }

  Future<List<Game>> fetchGames(int page) async {
    final all = await _fetchAllGames();
    final start = page * _pageSize;
    if (start >= all.length) return [];
    final end = (start + _pageSize).clamp(0, all.length);
    return all.sublist(start, end);
  }

  bool hasMorePages(int page) {
    if (_allGames == null) return true;
    return page * _pageSize < _allGames!.length;
  }

  Future<GameDetail> fetchGameDetail(int id) async {
    final response = await http
        .get(Uri.parse('$_baseUrl/game?id=$id'))
        .timeout(const Duration(seconds: 15));
    if (response.statusCode != 200) {
      throw Exception('Falha ao carregar detalhes (HTTP ${response.statusCode})');
    }
    return GameDetail.fromJson(json.decode(response.body) as Map<String, dynamic>);
  }

  Future<List<Game>> searchGames(String query) async {
    final all = await _fetchAllGames();
    final lower = query.toLowerCase().trim();
    return all.where((g) => g.title.toLowerCase().contains(lower)).toList();
  }
}
