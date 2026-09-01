import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/game.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../widgets/game_card.dart';
import 'detail_screen.dart';
import 'favorites_screen.dart';
import 'played_screen.dart';
import 'login_screen.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final _api = ApiService();
  final _searchController = TextEditingController();

  List<Game> _games = [];
  List<Game>? _searchResults;
  int _page = 0;
  bool _loading = false;
  bool _loadingMore = false;
  bool _hasMore = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadGames();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadGames() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final games = await _api.fetchGames(0);
      setState(() {
        _games = games;
        _page = 1;
        _hasMore = games.length == 20;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Falha ao carregar jogos. Verifique sua conexão.';
        _loading = false;
      });
    }
  }

  Future<void> _loadMore() async {
    if (_loadingMore || !_hasMore) return;
    setState(() => _loadingMore = true);
    try {
      final more = await _api.fetchGames(_page);
      setState(() {
        _games.addAll(more);
        _page++;
        _hasMore = more.length == 20;
        _loadingMore = false;
      });
    } catch (e) {
      setState(() {
        _loadingMore = false;
        _error = 'Falha ao carregar mais jogos.';
      });
    }
  }

  Future<void> _search() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      setState(() => _searchResults = null);
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await _api.searchGames(query);
      if (!mounted) return;
      setState(() {
        _searchResults = results;
        _loading = false;
      });
      if (results.length == 1) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => DetailScreen(game: results.first)),
        );
      }
    } catch (e) {
      setState(() {
        _error = 'Falha na busca. Tente novamente.';
        _loading = false;
      });
    }
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() => _searchResults = null);
  }

  Future<void> _logout() async {
    await context.read<AuthProvider>().logout();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  List<Game> get _displayGames => _searchResults ?? _games;

  @override
  Widget build(BuildContext context) {
    final username = context.watch<AuthProvider>().username ?? '';
    return Scaffold(
      backgroundColor: const Color(0xff1a1a2e),
      appBar: AppBar(
        backgroundColor: const Color(0xff16213e),
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('GameVault',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            if (username.isNotEmpty)
              Text('Olá, $username',
                  style: const TextStyle(fontSize: 11, color: Colors.white54)),
          ],
        ),
        actions: [
          Semantics(
            label: 'Acessar favoritos',
            child: IconButton(
              icon: const Icon(Icons.favorite, color: Color(0xffe94560)),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FavoritesScreen()),
              ),
            ),
          ),
          Semantics(
            label: 'Ver jogos jogados',
            child: IconButton(
              icon: const Icon(Icons.videogame_asset, color: Colors.white70),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PlayedScreen()),
              ),
            ),
          ),
          Semantics(
            label: 'Sair da conta',
            child: IconButton(
              icon: const Icon(Icons.logout, color: Colors.white54),
              onPressed: _logout,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
            child: Row(
              children: [
                Expanded(
                  child: Semantics(
                    label: 'Campo de busca de jogos',
                    child: TextField(
                      controller: _searchController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Buscar por nome do jogo...',
                        hintStyle: const TextStyle(color: Colors.white38),
                        prefixIcon:
                            const Icon(Icons.search, color: Colors.white38),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? Semantics(
                                label: 'Limpar busca',
                                child: IconButton(
                                  icon: const Icon(Icons.clear,
                                      color: Colors.white38),
                                  onPressed: _clearSearch,
                                ),
                              )
                            : null,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.white24),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: Color(0xffe94560)),
                        ),
                        filled: true,
                        fillColor: const Color(0xff16213e),
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onChanged: (_) => setState(() {}),
                      onSubmitted: (_) => _search(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Semantics(
                  label: 'Botão buscar jogo',
                  child: ElevatedButton(
                    onPressed: _search,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xffe94560),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Buscar'),
                  ),
                ),
              ],
            ),
          ),

          // Search result label
          if (_searchResults != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              child: Row(
                children: [
                  Text(
                    '${_searchResults!.length} resultado(s) para "${_searchController.text}"',
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: _clearSearch,
                    child: const Text('Ver todos',
                        style: TextStyle(
                            color: Color(0xffe94560), fontSize: 12)),
                  ),
                ],
              ),
            ),

          // Error banner
          if (_error != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade700),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.signal_wifi_off,
                        color: Colors.redAccent, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(_error!,
                          style: const TextStyle(
                              color: Colors.redAccent, fontSize: 12)),
                    ),
                    Semantics(
                      label: 'Tentar carregar novamente',
                      child: TextButton(
                        onPressed: _loadGames,
                        child: const Text('Tentar',
                            style: TextStyle(color: Color(0xffe94560))),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Main content
          if (_loading)
            const Expanded(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_displayGames.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.search_off, size: 64, color: Colors.white24),
                    const SizedBox(height: 12),
                    Text(
                      _searchResults != null
                          ? 'Nenhum jogo encontrado'
                          : 'Sem jogos disponíveis',
                      style: const TextStyle(color: Colors.white38),
                    ),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(12),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.72,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: _displayGames.length +
                    (_searchResults == null && _hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _displayGames.length) {
                    return Center(
                      child: _loadingMore
                          ? const Padding(
                              padding: EdgeInsets.all(16),
                              child: CircularProgressIndicator(),
                            )
                          : Semantics(
                              label: 'Carregar mais jogos',
                              child: ElevatedButton.icon(
                                onPressed: _loadMore,
                                icon: const Icon(Icons.expand_more),
                                label: const Text('Carregar Mais'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xff0f3460),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 12),
                                ),
                              ),
                            ),
                    );
                  }
                  final game = _displayGames[index];
                  return GameCard(
                    game: game,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => DetailScreen(game: game)),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
