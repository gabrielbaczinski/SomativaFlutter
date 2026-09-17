import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/pokemon.dart';
import '../providers/favorites_provider.dart';
import '../providers/played_provider.dart';
import '../services/poke_api_service.dart';
import '../utils/page_transitions.dart';
import '../utils/pokemon_types.dart';
import '../widgets/platform_image.dart';
import '../widgets/tap_scale.dart';

class DetailScreen extends StatefulWidget {
  final Pokemon pokemon;

  const DetailScreen({super.key, required this.pokemon});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen>
    with SingleTickerProviderStateMixin {
  final _api = PokeApiService();
  Pokemon? _detail;
  bool _loadingDetail = true;
  List<Pokemon> _evolutionChain = [];
  bool _loadingEvolution = true;

  late final AnimationController _entrance;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _fade = CurvedAnimation(parent: _entrance, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero)
        .animate(CurvedAnimation(parent: _entrance, curve: Curves.easeOutCubic));
    _entrance.forward();
    _fetchDetail();
    _fetchEvolution();
  }

  @override
  void dispose() {
    _entrance.dispose();
    super.dispose();
  }

  Future<void> _fetchDetail() async {
    try {
      final detail = await _api.fetchPokemonDetail(widget.pokemon.id);
      if (!mounted) return;
      setState(() => _detail = detail);
    } catch (_) {
      // usa os dados básicos se o detalhe falhar
    } finally {
      if (mounted) setState(() => _loadingDetail = false);
    }
  }

  Future<void> _fetchEvolution() async {
    try {
      final chain = await _api.fetchEvolutionChain(widget.pokemon.id);
      if (!mounted) return;
      setState(() => _evolutionChain = chain);
    } catch (_) {
      // sem cadeia de evolução disponível — seção fica oculta
    } finally {
      if (mounted) setState(() => _loadingEvolution = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pokemon = _detail ?? widget.pokemon;
    final isFav = context.watch<FavoritesProvider>().isFavorite(pokemon.id);
    final isWatched = context.watch<PlayedProvider>().isWatched(pokemon.id);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: Colors.white,
            // RF10 — botão voltar com Semantics e área de toque adequada
            leading: Semantics(
              label: 'Voltar para o catálogo',
              button: true,
              child: TapScale(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  margin: const EdgeInsets.all(8),
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8),
                    ],
                  ),
                  child: const Icon(Icons.arrow_back_rounded,
                      color: Color(0xFF4A3F55)),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: const Color(0xFFFFF0F5),
                child: Semantics(
                  label: 'Imagem de ${pokemon.name}',
                  child: Hero(
                    tag: 'pokemon_${widget.pokemon.id}',
                    child: PlatformImage(url: pokemon.image, fit: BoxFit.contain),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fade,
              child: SlideTransition(
                position: _slide,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  pokemon.name,
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF4A3F55),
                                  ),
                                ),
                                Text(
                                  pokemon.number,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFF7A6D93),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (_loadingDetail)
                            const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  color: Color(0xFFFF8FAB), strokeWidth: 2),
                            ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          if (pokemon.types.isNotEmpty)
                            ...pokemon.types.split(', ').map(
                                  (t) => _TypeChip(type: t),
                                ),
                          if (pokemon.height.isNotEmpty)
                            _InfoChip(
                              icon: Icons.height_rounded,
                              label: pokemon.height,
                              color: const Color(0xFF97C8A0),
                            ),
                          if (pokemon.weight.isNotEmpty)
                            _InfoChip(
                              icon: Icons.monitor_weight_outlined,
                              label: pokemon.weight,
                              color: const Color(0xFFB8A9D9),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // RF04 / RF07 — botões de favoritar e capturar com Semantics (RF10)
                      Row(
                        children: [
                          Expanded(
                            child: Semantics(
                              label: isFav
                                  ? 'Remover ${pokemon.name} dos favoritos'
                                  : 'Adicionar ${pokemon.name} aos favoritos',
                              button: true,
                              child: _ActionButton(
                                icon: isFav
                                    ? Icons.favorite_rounded
                                    : Icons.favorite_border_rounded,
                                label: isFav ? 'Nos Favoritos' : 'Favoritar',
                                color: const Color(0xFFFF8FAB),
                                active: isFav,
                                onTap: () {
                                  HapticFeedback.mediumImpact();
                                  context.read<FavoritesProvider>().toggle(pokemon);
                                },
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Semantics(
                              label: isWatched
                                  ? '${pokemon.name} já capturado'
                                  : 'Marcar ${pokemon.name} como capturado',
                              button: true,
                              child: _ActionButton(
                                icon: isWatched
                                    ? Icons.catching_pokemon_rounded
                                    : Icons.catching_pokemon_outlined,
                                label: isWatched ? 'Capturado' : 'Capturar',
                                color: const Color(0xFF97C8A0),
                                active: isWatched,
                                onTap: () {
                                  HapticFeedback.mediumImpact();
                                  context.read<PlayedProvider>().toggle(pokemon);
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const _SectionTitle('Detalhes'),
                      const SizedBox(height: 8),
                      _DetailRow('Número', pokemon.number),
                      if (pokemon.types.isNotEmpty)
                        _DetailRow('Tipo', pokemon.types),
                      if (pokemon.height.isNotEmpty)
                        _DetailRow('Altura', pokemon.height),
                      if (pokemon.weight.isNotEmpty)
                        _DetailRow('Peso', pokemon.weight),
                      if (pokemon.stats.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        const _SectionTitle('Estatísticas Base'),
                        const SizedBox(height: 12),
                        ...pokemon.stats.map((s) => _StatBar(
                              label: s.label,
                              value: s.value,
                              color: pokemon.types.isNotEmpty
                                  ? pokemonTypeColor(
                                      pokemon.types.split(', ').first)
                                  : const Color(0xFFFF8FAB),
                            )),
                      ],
                      if (_loadingEvolution || _evolutionChain.length > 1) ...[
                        const SizedBox(height: 24),
                        const _SectionTitle('Linha de Evolução'),
                        const SizedBox(height: 12),
                        _buildEvolutionRow(),
                      ],
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEvolutionRow() {
    if (_loadingEvolution) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
                color: Color(0xFFFF8FAB), strokeWidth: 2.5),
          ),
        ),
      );
    }
    return SizedBox(
      height: 104,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _evolutionChain.length,
        separatorBuilder: (_, __) => const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Icon(Icons.arrow_forward_rounded,
              color: Color(0xFF7A6D93), size: 20),
        ),
        itemBuilder: (context, i) {
          final stage = _evolutionChain[i];
          final isCurrent = stage.id == widget.pokemon.id;
          return Semantics(
            label: isCurrent
                ? '${stage.name}, estágio atual'
                : 'Ver detalhes de ${stage.name}',
            button: !isCurrent,
            child: TapScale(
              onTap: isCurrent
                  ? null
                  : () => Navigator.of(context)
                      .push(fadeSlideRoute(DetailScreen(pokemon: stage))),
              child: SizedBox(
                width: 76,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF0F5),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isCurrent
                              ? const Color(0xFFFF8FAB)
                              : const Color(0xFFFF8FAB).withValues(alpha: 0.25),
                          width: isCurrent ? 2.5 : 1.5,
                        ),
                      ),
                      child: PlatformImage(url: stage.image, fit: BoxFit.contain),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      stage.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w600,
                        color: isCurrent
                            ? const Color(0xFFFF8FAB)
                            : const Color(0xFF4A3F55),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  final String type;
  const _TypeChip({required this.type});

  @override
  Widget build(BuildContext context) {
    final color = pokemonTypeColor(type);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        type,
        style: TextStyle(
          fontSize: 13,
          color: color.withValues(alpha: 1.0),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoChip(
      {required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool active;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TapScale(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        // RF10 — altura mínima de 44px para área de toque
        constraints: const BoxConstraints(minHeight: 44),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: active ? color : color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(16),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: active ? Colors.white : color, size: 18),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: active ? Colors.white : color,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w800,
        color: Color(0xFF4A3F55),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF7A6D93),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF4A3F55),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatBar extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _StatBar({required this.label, required this.value, required this.color});

  static const int _maxStat = 200;

  @override
  Widget build(BuildContext context) {
    final fraction = (value / _maxStat).clamp(0.0, 1.0);
    return Semantics(
      label: '$label: $value de até $_maxStat',
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          children: [
            SizedBox(
              width: 92,
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 12.5,
                  color: Color(0xFF7A6D93),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(
              width: 30,
              child: Text(
                '$value',
                style: const TextStyle(
                  fontSize: 12.5,
                  color: Color(0xFF4A3F55),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: fraction),
                  duration: const Duration(milliseconds: 700),
                  curve: Curves.easeOutCubic,
                  builder: (context, animatedValue, _) => LinearProgressIndicator(
                    value: animatedValue,
                    minHeight: 10,
                    backgroundColor: color.withValues(alpha: 0.15),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
