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

  // Filtro por tipo — a PokéAPI devolve a lista inteira do tipo de uma vez
  // (sem limit/offset), então a paginação dessa lista é feita no cliente.
  Future<List<Pokemon>> fetchPokemonsByType(String type) async {
    final uri = Uri.parse('$_baseUrl/type/${type.toLowerCase()}');
    final response = await http.get(uri).timeout(_timeout);

    if (response.statusCode != 200) {
      throw Exception('Erro ao carregar tipo: ${response.statusCode}');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final entries = body['pokemon'] as List<dynamic>;
    return entries
        .map((e) => Pokemon.fromListJson(
            (e as Map<String, dynamic>)['pokemon'] as Map<String, dynamic>))
        .toList();
  }

  // Cadeia de evolução: pokemon -> pokemon-species -> evolution-chain.
  // Em ramificações (ex.: Eevee), segue apenas o primeiro caminho.
  Future<List<Pokemon>> fetchEvolutionChain(String id) async {
    final speciesUri = Uri.parse('$_baseUrl/pokemon-species/$id');
    final speciesResponse = await http.get(speciesUri).timeout(_timeout);
    if (speciesResponse.statusCode != 200) return [];

    final speciesBody =
        jsonDecode(speciesResponse.body) as Map<String, dynamic>;
    final chainUrl =
        (speciesBody['evolution_chain'] as Map<String, dynamic>)['url']
            as String;
    final chainResponse = await http.get(Uri.parse(chainUrl)).timeout(_timeout);
    if (chainResponse.statusCode != 200) return [];

    final chainBody = jsonDecode(chainResponse.body) as Map<String, dynamic>;
    final stages = <Pokemon>[];
    Map<String, dynamic>? node = chainBody['chain'] as Map<String, dynamic>?;
    while (node != null) {
      final species = node['species'] as Map<String, dynamic>;
      final speciesUrl = species['url'] as String;
      final speciesId =
          speciesUrl.split('/').where((s) => s.isNotEmpty).last;
      stages.add(Pokemon.stub(speciesId, species['name'] as String));

      final evolvesTo = node['evolves_to'] as List<dynamic>;
      node = evolvesTo.isNotEmpty
          ? evolvesTo.first as Map<String, dynamic>
          : null;
    }
    return stages;
  }
}
