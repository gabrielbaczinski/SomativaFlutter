import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/pokemon.dart';

class PaginatedPokemon {
  final List<Pokemon> pokemons;
  final int currentPage;
  final bool hasNextPage;

  const PaginatedPokemon({
    required this.pokemons,
    required this.currentPage,
    required this.hasNextPage,
  });
}

class PokeApiService {
  static const String _baseUrl = 'https://pokeapi.co/api/v2';
  static const int itemsPerPage = 20;
  static const Duration _timeout = Duration(seconds: 15);

  // RF01 — paginação real da API via limit + offset
  Future<PaginatedPokemon> fetchPokemons(int page) async {
    final offset = page * itemsPerPage;
    final uri = Uri.parse(
        '$_baseUrl/pokemon?limit=$itemsPerPage&offset=$offset');
    final response = await http.get(uri).timeout(_timeout);

    if (response.statusCode != 200) {
      throw Exception('Erro ao carregar pokémons: ${response.statusCode}');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final results = body['results'] as List<dynamic>;

    return PaginatedPokemon(
      pokemons: results
          .map((r) => Pokemon.fromListJson(r as Map<String, dynamic>))
          .toList(),
      currentPage: page,
      hasNextPage: body['next'] != null,
    );
  }

  // Busca detalhes completos de um pokémon pelo id
  Future<Pokemon> fetchPokemonDetail(String id) async {
    final uri = Uri.parse('$_baseUrl/pokemon/$id');
    final response = await http.get(uri).timeout(_timeout);

    if (response.statusCode != 200) {
      throw Exception('Erro ao carregar detalhes: ${response.statusCode}');
    }

    return Pokemon.fromDetailJson(
        jsonDecode(response.body) as Map<String, dynamic>);
  }

  // RF08 — busca por nome exato (PokeAPI não tem busca parcial)
  Future<List<Pokemon>> searchPokemons(String query) async {
    final name = query.toLowerCase().trim().replaceAll(' ', '-');
    final uri = Uri.parse('$_baseUrl/pokemon/$name');
    final response = await http.get(uri).timeout(_timeout);

    if (response.statusCode == 404) return [];
    if (response.statusCode != 200) {
      throw Exception('Erro na busca: ${response.statusCode}');
    }

    final pokemon = Pokemon.fromDetailJson(
        jsonDecode(response.body) as Map<String, dynamic>);
    return [pokemon];
  }
}
