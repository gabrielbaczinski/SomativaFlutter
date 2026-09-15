import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/film.dart';

class GhibliApiService {
  static const String _baseUrl = 'https://ghibliapi.vercel.app';
  static const Duration _timeout = Duration(seconds: 15);

  Future<List<Film>> fetchAllFilms() async {
    final uri = Uri.parse('$_baseUrl/films');
    final response = await http.get(uri).timeout(_timeout);

    if (response.statusCode != 200) {
      throw Exception('Erro ao carregar filmes: ${response.statusCode}');
    }

    final List<dynamic> data = jsonDecode(response.body);
    return data.map((j) => Film.fromJson(j as Map<String, dynamic>)).toList();
  }

  Future<Film> fetchFilmDetail(String id) async {
    final uri = Uri.parse('$_baseUrl/films/$id');
    final response = await http.get(uri).timeout(_timeout);

    if (response.statusCode != 200) {
      throw Exception('Erro ao carregar detalhes: ${response.statusCode}');
    }

    return Film.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<List<Film>> searchFilms(String query) async {
    final uri = Uri.parse('$_baseUrl/films');
    final response = await http.get(uri).timeout(_timeout);

    if (response.statusCode != 200) {
      throw Exception('Erro na busca: ${response.statusCode}');
    }

    final List<dynamic> data = jsonDecode(response.body);
    return data
        .map((j) => Film.fromJson(j as Map<String, dynamic>))
        .where((f) => f.title.toLowerCase().contains(query.toLowerCase()) ||
            f.director.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
}
