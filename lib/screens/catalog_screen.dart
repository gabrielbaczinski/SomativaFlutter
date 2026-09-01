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
    setState(() { _loading = true; _error = null; });
    try {
      final games = await _api.fetchGames(0);
      if (!mounted) return;
      setState(() {
        _games = games;
        _page = 1;
        _hasMore = games.length == 20;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
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
      if (!mounted) return;
      setState(() {
        _games.addAll(more);
        _page++;
        _hasMore = more.length == 20;
        _loadingMore = false;
      });
    } catch (e) {
      if (!mounted) return;
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
    setState(() { _loading = true; _error = null; });
    try {
      final results = await _api.searchGames(query);
      if (!mounted) return;
      setState(() { _searchResults = results; _loading = false; });
      if (results.length == 1) {
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => DetailScreen(game: results.first)));
      }
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = 'Falha na busca.'; _loading = false; });
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
        MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  List<Game> get _displayGames => _searchResults ?? _games;

  @override
  Widget build(BuildContext context) {
    final username = context.watch<AuthProvider>().username ?? '';

    return Scaffold(
      backgroundColor: const Color(0xff0d0d1a),
      body: CustomScrollView(
        slivers: [
          // AppBar personalizada
          SliverAppBar(
            floating: true,
            snap: true,
            backgroundColor: const Color(0xff0d0d1a),
            expandedHeight: 110,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xff1a0a14).withValues(alpha: 0.9),
                      const Color(0xff0d0d1a),
                    ],
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(20, 48, 16, 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.sports_esports,
                                  color: Color(0xffe94560), size: 20),
                              const SizedBox(width: 6),
                              const Text(
                                'GameVault',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                          if (username.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Text(
                                'Bem-vindo, $username 👾',
                                style: const TextStyle(
                                  color: Color(0xff8888aa),
                                  fontSize: 12,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    Semantics(
                      label: 'Acessar favoritos',
                      child: _NavButton(
                        icon: Icons.favorite_rounded,
                        color: const Color(0xffe94560),
                        onTap: () => Navigator.push(context,
                            MaterialPageRoute(
                                builder: (_) => const FavoritesScreen())),
                      ),
                    ),
                    Semantics(
                      label: 'Ver jogos jogados',
                      child: _NavButton(
                        icon: Icons.videogame_asset_rounded,
                        color: const Color(0xff4ecca3),
                        onTap: () => Navigator.push(context,
                            MaterialPageRoute(
                                builder: (_) => const PlayedScreen())),
                      ),
                    ),
                    Semantics(
                      label: 'Sair da conta',
                      child: _NavButton(
                        icon: Icons.logout_rounded,
                        color: const Color(0xff8888aa),
                        onTap: _logout,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Search bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Semantics(
                      label: 'Campo de busca de jogos',
                      child: TextField(
                        controller: _searchController,
                        style:
                            const TextStyle(color: Colors.white, fontSize: 14),
                        onChanged: (_) => setState(() {}),
                        onSubmitted: (_) => _search(),
                        decoration: InputDecoration(
                          hintText: 'Buscar por nome...',
                          hintStyle: const TextStyle(
                              color: Color(0xff8888aa), fontSize: 14),
                          prefixIcon: const Icon(Icons.search_rounded,
                              color: Color(0xff8888aa), size: 20),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? Semantics(
                                  label: 'Limpar busca',
                                  child: IconButton(
                                    icon: const Icon(Icons.close_rounded,
                                        size: 18,
                                        color: Color(0xff8888aa)),
                                    onPressed: _clearSearch,
                                  ),
                                )
                              : null,
                          filled: true,
                          fillColor: const Color(0xff1a1a2e),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                                color: Colors.white.withValues(alpha: 0.07)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                                color: Color(0xffe94560), width: 1.5),
                          ),
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Semantics(
                    label: 'Botão buscar jogo',
                    child: GestureDetector(
                      onTap: _search,
                      child: Container(
                        height: 48,
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xffe94560), Color(0xffc0392b)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xffe94560)
                                  .withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text(
                            'Buscar',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Resultado de busca ou label
          if (_searchResults != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Row(
                  children: [
                    Text(
                      '${_searchResults!.length} resultado(s) para '
                      '"${_searchController.text}"',
                      style: const TextStyle(
                          color: Color(0xff8888aa), fontSize: 12),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: _clearSearch,
                      child: const Text('Ver todos',
                          style: TextStyle(
                              color: Color(0xffe94560),
                              fontSize: 12,
                              fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ),

          // Erro
          if (_error != null)
            SliverToBoxAdapter(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xffe94560).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: const Color(0xffe94560).withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.signal_wifi_off_rounded,
                          color: Color(0xffe94560), size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(_error!,
                            style: const TextStyle(
                                color: Color(0xffe94560), fontSize: 12)),
                      ),
                      TextButton(
                        onPressed: _loadGames,
                        child: const Text('Tentar',
                            style: TextStyle(color: Color(0xffe94560))),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Loading state
          if (_loading)
            const SliverFillRemaining(
              child: Center(
                  child: CircularProgressIndicator(
                      color: Color(0xffe94560), strokeWidth: 2.5)),
            )
          else if (_displayGames.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _searchResults != null
                          ? Icons.search_off_rounded
                          : Icons.videogame_asset_off_rounded,
                      size: 64,
                      color: Colors.white12,
                    ),
                    const SizedBox(height: 14),
                    Text(
                      _searchResults != null
                          ? 'Nenhum jogo encontrado'
                          : 'Sem jogos disponíveis',
                      style: const TextStyle(
                          color: Color(0xff8888aa), fontSize: 15),
                    ),
                  ],
                ),
              ),
            )
          else ...[
            // Grid de jogos
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.68,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final game = _displayGames[index];
                    return GameCard(
                      game: game,
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => DetailScreen(game: game))),
                    );
                  },
                  childCount: _displayGames.length,
                ),
              ),
            ),

            // Botão Carregar Mais
            if (_searchResults == null && _hasMore)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: _loadingMore
                      ? const Center(
                          child: CircularProgressIndicator(
                              color: Color(0xffe94560), strokeWidth: 2.5))
                      : Semantics(
                          label: 'Carregar mais jogos',
                          child: GestureDetector(
                            onTap: _loadMore,
                            child: Container(
                              width: double.infinity,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                color: const Color(0xff1a1a2e),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.1)),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.expand_more_rounded,
                                      color: Color(0xff8888aa), size: 20),
                                  SizedBox(width: 8),
                                  Text(
                                    'Carregar Mais',
                                    style: TextStyle(
                                      color: Color(0xff8888aa),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                ),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),
          ],
        ],
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _NavButton(
      {required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(left: 6),
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Icon(icon, color: color, size: 18),
      ),
    );
  }
}
