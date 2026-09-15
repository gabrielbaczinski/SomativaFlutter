import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/pokemon.dart';
import '../providers/auth_provider.dart';
import '../services/poke_api_service.dart';
import '../widgets/film_card.dart';
import 'favorites_screen.dart';
import 'played_screen.dart';
import 'detail_screen.dart';
import 'login_screen.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final _api = PokeApiService();
  final _searchCtrl = TextEditingController();

  List<Pokemon> _pokemons = [];
  List<Pokemon>? _searchResults;
  bool _loading = false;
  bool _loadingMore = false;
  bool _searching = false;
  bool _hasMore = false;
  String? _error;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _loadPage(0);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  // RF01 — carrega página da API (paginação real: limit + offset)
  Future<void> _loadPage(int page) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await _api.fetchPokemons(page);
      if (!mounted) return;
      setState(() {
        _pokemons = result.pokemons;
        _currentPage = result.currentPage;
        _hasMore = result.hasNextPage;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = 'Erro ao carregar pokémons. Tente novamente.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // RF01 — "Carregar Mais": busca próxima página e acumula na lista
  Future<void> _loadMore() async {
    if (_loadingMore) return;
    setState(() => _loadingMore = true);
    try {
      final result = await _api.fetchPokemons(_currentPage + 1);
      if (!mounted) return;
      setState(() {
        _pokemons.addAll(result.pokemons);
        _currentPage = result.currentPage;
        _hasMore = result.hasNextPage;
      });
    } catch (_) {
      // erro silencioso no carregar mais
    } finally {
      if (mounted) setState(() => _loadingMore = false);
    }
  }

  // RF08 — acionado pelo botão "Buscar" ou submit do teclado
  Future<void> _doSearch() async {
    final query = _searchCtrl.text.trim();
    if (query.isEmpty) {
      setState(() => _searchResults = null);
      return;
    }
    setState(() {
      _searching = true;
      _searchResults = null;
    });
    try {
      final results = await _api.searchPokemons(query);
      if (!mounted) return;
      // RF08 — resultado único: navega diretamente para o detalhe
      if (results.length == 1) {
        setState(() {
          _searching = false;
          _searchResults = null;
        });
        if (!mounted) return;
        Navigator.of(context).push(
          MaterialPageRoute(
              builder: (_) => DetailScreen(pokemon: results.first)),
        );
        return;
      }
      setState(() => _searchResults = results);
    } catch (_) {
      if (!mounted) return;
      setState(() => _searchResults = []);
    } finally {
      if (mounted) setState(() => _searching = false);
    }
  }

  void _clearSearch() {
    _searchCtrl.clear();
    setState(() => _searchResults = null);
  }

  @override
  Widget build(BuildContext context) {
    final username = context.watch<AuthProvider>().username ?? '';

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            snap: true,
            pinned: false,
            backgroundColor: Colors.transparent,
            expandedHeight: 140,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                padding: const EdgeInsets.fromLTRB(20, 52, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Olá, $username',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF9E91B8),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Text(
                              'Pokédex',
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF4A3F55),
                              ),
                            ),
                          ],
                        ),
                        // RF10 — botões de navegação com Semantics e área de toque adequada
                        Row(
                          children: [
                            Semantics(
                              label: 'Ver pokémons favoritos',
                              button: true,
                              child: _NavButton(
                                icon: Icons.favorite_rounded,
                                color: const Color(0xFFFF8FAB),
                                tooltip: 'Favoritos',
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                      builder: (_) => const FavoritesScreen()),
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Semantics(
                              label: 'Ver pokémons capturados',
                              button: true,
                              child: _NavButton(
                                icon: Icons.catching_pokemon_rounded,
                                color: const Color(0xFF97C8A0),
                                tooltip: 'Capturados',
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                      builder: (_) => const PlayedScreen()),
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Semantics(
                              label: 'Sair do aplicativo',
                              button: true,
                              child: _NavButton(
                                icon: Icons.logout_rounded,
                                color: const Color(0xFFB8A9D9),
                                tooltip: 'Sair',
                                onTap: () async {
                                  await context.read<AuthProvider>().logout();
                                  if (context.mounted) {
                                    Navigator.of(context).pushAndRemoveUntil(
                                      MaterialPageRoute(
                                          builder: (_) => const LoginScreen()),
                                      (_) => false,
                                    );
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          // RF08 — TextField + TextEditingController + ElevatedButton "Buscar"
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchCtrl,
                      decoration: InputDecoration(
                        hintText: 'Buscar pokémon pelo nome...',
                        prefixIcon: const Icon(Icons.search_rounded,
                            color: Color(0xFFFF8FAB)),
                        suffixIcon: _searchCtrl.text.isNotEmpty
                            ? Semantics(
                                label: 'Limpar busca',
                                button: true,
                                child: IconButton(
                                  icon: const Icon(Icons.close_rounded,
                                      color: Color(0xFF9E91B8)),
                                  onPressed: _clearSearch,
                                ),
                              )
                            : null,
                      ),
                      onSubmitted: (_) => _doSearch(),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // RF08 — botão "Buscar" obrigatório
                  SizedBox(
                    height: 52,
                    child: Semantics(
                      label: 'Buscar pokémon',
                      button: true,
                      child: ElevatedButton(
                        onPressed: _searching ? null : _doSearch,
                        style: ElevatedButton.styleFrom(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 16),
                        ),
                        child: _searching
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2.5),
                              )
                            : const Text('Buscar'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // RF09 — loading indicator durante carregamento inicial
          if (_loading)
            const SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(color: Color(0xFFFF8FAB)),
              ),
            )
          // RF09 — mensagem de erro amigável
          else if (_error != null)
            SliverFillRemaining(child: _buildError())
          else if (_searchResults != null)
            _buildSearchResults()
          else ...[
            _buildGrid(_pokemons),
            // RF01 — ElevatedButton "Carregar Mais" acumulativo com paginação da API
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(32, 12, 32, 28),
                child: _hasMore || _loadingMore
                    ? Semantics(
                        label: 'Carregar mais pokémons',
                        button: true,
                        child: SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _loadingMore ? null : _loadMore,
                            child: _loadingMore
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                        color: Colors.white, strokeWidth: 2.5),
                                  )
                                : const Text('Carregar Mais'),
                          ),
                        ),
                      )
                    : const Center(
                        child: Text(
                          'Todos os pokémons carregados',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF9E91B8),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    final results = _searchResults!;
    if (results.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.search_off_rounded,
                  size: 52, color: Color(0xFFD4C8E0)),
              const SizedBox(height: 12),
              const Text(
                'Pokémon não encontrado',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF9E91B8),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Digite o nome exato do pokémon',
                style: TextStyle(fontSize: 13, color: Color(0xFF9E91B8)),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: _clearSearch,
                child: const Text(
                  'Limpar busca',
                  style: TextStyle(
                    color: Color(0xFFFF8FAB),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate(
          (_, i) => PokemonCard(pokemon: results[i]),
          childCount: results.length,
        ),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.75,
        ),
      ),
    );
  }

  SliverPadding _buildGrid(List<Pokemon> pokemons) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate(
          (_, i) => PokemonCard(pokemon: pokemons[i]),
          childCount: pokemons.length,
        ),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.75,
        ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off_rounded,
                size: 56, color: Color(0xFFD4C8E0)),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: const TextStyle(
                color: Color(0xFF9E91B8),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Semantics(
              label: 'Tentar carregar pokémons novamente',
              button: true,
              child: ElevatedButton(
                onPressed: () => _loadPage(0),
                child: const Text('Tentar Novamente'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// RF10 — área de toque mínima de 44px
class _NavButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onTap;

  const _NavButton({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
      ),
    );
  }
}
