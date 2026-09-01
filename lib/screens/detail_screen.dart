import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/game.dart';
import '../models/game_detail.dart';
import '../providers/favorites_provider.dart';
import '../providers/played_provider.dart';
import '../services/api_service.dart';

class DetailScreen extends StatefulWidget {
  final Game game;

  const DetailScreen({super.key, required this.game});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final _api = ApiService();
  GameDetail? _detail;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final detail = await _api.fetchGameDetail(widget.game.id);
      setState(() {
        _detail = detail;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Falha ao carregar detalhes. Verifique sua conexão.';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final favorites = context.watch<FavoritesProvider>();
    final played = context.watch<PlayedProvider>();
    final isFav = favorites.isFavorite(widget.game.id);
    final isPlayed = played.isPlayed(widget.game.id);

    return Scaffold(
      backgroundColor: const Color(0xff1a1a2e),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 230,
            pinned: true,
            backgroundColor: const Color(0xff16213e),
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.fromLTRB(56, 0, 56, 14),
              title: Text(
                widget.game.title,
                style: const TextStyle(
                    fontSize: 13,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              background: _HeroImage(game: widget.game),
            ),
            actions: [
              Semantics(
                label: isFav
                    ? 'Remover ${widget.game.title} dos favoritos'
                    : 'Adicionar ${widget.game.title} aos favoritos',
                child: IconButton(
                  iconSize: 28,
                  icon: Icon(
                    isFav ? Icons.star_rounded : Icons.star_outline_rounded,
                    color: isFav ? const Color(0xffe94560) : Colors.white,
                  ),
                  onPressed: () => favorites.toggle(widget.game),
                ),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Played toggle
                  Semantics(
                    label: isPlayed
                        ? 'Desmarcar ${widget.game.title} como jogado'
                        : 'Marcar ${widget.game.title} como jogado',
                    child: SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => played.toggle(widget.game),
                        icon: Icon(
                          isPlayed
                              ? Icons.check_circle_rounded
                              : Icons.check_circle_outline_rounded,
                          color: isPlayed
                              ? Colors.greenAccent
                              : Colors.white54,
                        ),
                        label: Text(
                          isPlayed ? 'Marcado como Jogado' : 'Marcar como Jogado',
                          style: TextStyle(
                            color: isPlayed ? Colors.greenAccent : Colors.white54,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: isPlayed
                                ? Colors.greenAccent
                                : Colors.white24,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (_loading)
                    const Center(
                        child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(),
                    ))
                  else if (_error != null)
                    _ErrorState(error: _error!, onRetry: _loadDetail)
                  else if (_detail != null)
                    _DetailBody(detail: _detail!),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroImage extends StatelessWidget {
  final Game game;
  const _HeroImage({required this.game});

  @override
  Widget build(BuildContext context) {
    if (game.thumbnail.isEmpty) return _placeholder();
    return Semantics(
      label: 'Imagem do jogo ${game.title}',
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            game.thumbnail,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _placeholder(),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  const Color(0xff16213e).withOpacity(0.9),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholder() => Container(
        color: const Color(0xff0f3460),
        child: const Center(
          child: Icon(Icons.videogame_asset, size: 72, color: Colors.white24),
        ),
      );
}

class _ErrorState extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
  const _ErrorState({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(Icons.signal_wifi_off, size: 56, color: Colors.white24),
            const SizedBox(height: 12),
            Text(error,
                style: const TextStyle(color: Colors.white54),
                textAlign: TextAlign.center),
            const SizedBox(height: 20),
            Semantics(
              label: 'Tentar carregar detalhes novamente',
              child: ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Tentar Novamente'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xffe94560),
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailBody extends StatelessWidget {
  final GameDetail detail;
  const _DetailBody({required this.detail});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Genre/Platform/Status chips
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: [
            if (detail.genre.isNotEmpty) _chip(detail.genre, const Color(0xff0f3460)),
            if (detail.platform.isNotEmpty)
              _chip(detail.platform, const Color(0xff16213e)),
            if (detail.status.isNotEmpty)
              _chip(
                detail.status,
                detail.status.toLowerCase() == 'live'
                    ? Colors.green.withOpacity(0.25)
                    : Colors.grey.withOpacity(0.2),
                textColor: detail.status.toLowerCase() == 'live'
                    ? Colors.greenAccent
                    : Colors.grey,
              ),
          ],
        ),
        const SizedBox(height: 16),

        // Info rows
        _InfoRow('Desenvolvedor', detail.developer),
        _InfoRow('Publisher', detail.publisher),
        _InfoRow('Lançamento', detail.releaseDate),

        const SizedBox(height: 16),
        const Text(
          'Descrição',
          style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Colors.white),
        ),
        const SizedBox(height: 8),
        Text(
          detail.description.isEmpty
              ? detail.title
              : detail.description,
          style:
              const TextStyle(color: Colors.white70, height: 1.55, fontSize: 14),
        ),

        // Screenshots
        if (detail.screenshots.isNotEmpty) ...[
          const SizedBox(height: 24),
          const Text(
            'Screenshots',
            style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Colors.white),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 175,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: detail.screenshots.length,
              itemBuilder: (_, i) => Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Semantics(
                  label: 'Screenshot ${i + 1} do jogo ${detail.title}',
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      detail.screenshots[i].image,
                      width: 290,
                      height: 175,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 290,
                        color: const Color(0xff16213e),
                        child: const Icon(Icons.broken_image,
                            color: Colors.white24, size: 40),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _chip(String label, Color bg, {Color textColor = Colors.white70}) =>
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label,
            style: TextStyle(color: textColor, fontSize: 12)),
      );
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 112,
            child: Text('$label:',
                style: const TextStyle(
                    color: Colors.white38,
                    fontSize: 13,
                    fontWeight: FontWeight.w600)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(color: Colors.white70, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}
