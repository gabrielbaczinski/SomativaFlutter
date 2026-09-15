import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/anime.dart';

class PaginatedAnime {
  final List<Anime> animes;
  final int currentPage;
  final bool hasNextPage;
  final int lastPage;

  const PaginatedAnime({
    required this.animes,
    required this.currentPage,
    required this.hasNextPage,
    required this.lastPage,
  });
}

class JikanApiService {
  static const String _baseUrl = 'https://api.jikan.moe/v4';
  static const int itemsPerPage = 8;
  static const Duration _timeout = Duration(seconds: 20);

  // Jikan usa páginas a partir de 1; internamente usamos 0-based
  Future<PaginatedAnime> fetchAnimes(int page) async {
    final uri = Uri.parse(
        '$_baseUrl/top/anime?page=${page + 1}&limit=$itemsPerPage&type=tv');
    final response = await http.get(uri).timeout(_timeout);

    if (response.statusCode != 200) {
      throw Exception('Erro ao carregar animes: ${response.statusCode}');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final pagination = body['pagination'] as Map<String, dynamic>;
    final List<dynamic> data = body['data'] as List<dynamic>;

    return PaginatedAnime(
      animes: data
          .map((j) => Anime.fromJson(j as Map<String, dynamic>))
          .toList(),
      currentPage: page,
      hasNextPage: pagination['has_next_page'] as bool,
      lastPage: pagination['last_visible_page'] as int,
    );
  }

  Future<List<Anime>> searchAnimes(String query) async {
    final uri = Uri.parse(
        '$_baseUrl/anime?q=${Uri.encodeComponent(query)}&limit=25&sfw=true');
    final response = await http.get(uri).timeout(_timeout);

    if (response.statusCode != 200) {
      throw Exception('Erro na busca: ${response.statusCode}');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final List<dynamic> data = body['data'] as List<dynamic>;
    return data
        .map((j) => Anime.fromJson(j as Map<String, dynamic>))
        .toList();
  }
}
