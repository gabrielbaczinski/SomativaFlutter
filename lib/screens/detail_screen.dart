import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/game.dart';
import '../models/game_detail.dart';
import '../providers/favorites_provider.dart';
import '../providers/played_provider.dart';
import '../services/api_service.dart';
import '../widgets/platform_image.dart';

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
    setState(() { _loading = true; _error = null; });
    try {
      final detail = await _api.fetchGameDetail(widget.game.id);
      if (!mounted) return;
      setState(() { _detail = detail; _loading = false; });
    } catch (e) {
      if (!mounted) return;
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
      backgroundColor: const Color(0xff0d0d1a),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            backgroundColor: const Color(0xff0d0d1a),
            foregroundColor: Colors.white,
            leading: Semantics(
              label: 'Voltar',
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  margin: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: Colors.white, size: 18),
                ),
              ),
            ),
            actions: [
              Semantics(
                label: isFav
                    ? 'Remover ${widget.game.title} dos favoritos'
                    : 'Adicionar ${widget.game.title} aos favoritos',
                child: GestureDetector(
                  onTap: () => favorites.toggle(widget.game),
                  child: Container(
                    margin: const EdgeInsets.all(10),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isFav
                          ? const Color(0xffe94560).withValues(alpha: 0.2)
                          : Colors.black.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(10),
                      border: isFav
                          ? Border.all(
                              color:
                                  const Color(0xffe94560).withValues(alpha: 0.5))
                          : null,
                    ),
                    child: Icon(
                      isFav ? Icons.star_rounded : Icons.star_outline_rounded,
                      color: isFav ? const Color(0xffe94560) : Colors.white,
                      size: 22,
                    ),
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Semantics(
                    label: 'Imagem do jogo ${widget.game.title}',
                    child: PlatformImage(
                      url: widget.game.thumbnail,
                      fit: BoxFit.cover,
                      placeholder: () => const ColoredBox(
                        color: Color(0xff16213e),
                        child: Center(
                          child: Icon(Icons.videogame_asset,
                              size: 72, color: Colors.white12),
                        ),
                      ),
                    ),
                  ),
                  // Gradient bottom → top
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: [0.3, 1.0],
                        colors: [Colors.transparent, Color(0xff0d0d1a)],
                      ),
                    ),
                  ),
                  // Gradient top → para o appbar ficar legível
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.center,
                        colors: [
                          Colors.black.withValues(alpha: 0.4),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título
                  Text(
                    widget.game.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Botão "Marcar como Jogado"
                  Semantics(
                    label: isPlayed
                        ? 'Desmarcar ${widget.game.title} como jogado'
                        : 'Marcar ${widget.game.title} como jogado',
                    child: GestureDetector(
                      onTap: () => played.toggle(widget.game),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        decoration: BoxDecoration(
                          color: isPlayed
                              ? const Color(0xff4ecca3).withValues(alpha: 0.15)
                              : const Color(0xff1a1a2e),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isPlayed
                                ? const Color(0xff4ecca3).withValues(alpha: 0.5)
                                : Colors.white.withValues(alpha: 0.1),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              isPlayed
                                  ? Icons.check_circle_rounded
                                  : Icons.check_circle_outline_rounded,
                              color: isPlayed
                                  ? const Color(0xff4ecca3)
                                  : const Color(0xff8888aa),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              isPlayed ? 'Marcado como Jogado' : 'Marcar como Jogado',
                              style: TextStyle(
                                color: isPlayed
                                    ? const Color(0xff4ecca3)
                                    : const Color(0xff8888aa),
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  if (_loading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40),
                        child: CircularProgressIndicator(
                            color: Color(0xffe94560), strokeWidth: 2.5),
                      ),
                    )
                  else if (_error != null)
                    _ErrorState(error: _error!, onRetry: _loadDetail)
                  else if (_detail != null)
                    _DetailContent(detail: _detail!),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
  const _ErrorState({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            const Icon(Icons.signal_wifi_off_rounded,
                size: 56, color: Colors.white12),
            const SizedBox(height: 14),
            Text(error,
                style: const TextStyle(color: Color(0xff8888aa)),
                textAlign: TextAlign.center),
            const SizedBox(height: 24),
            Semantics(
              label: 'Tentar carregar detalhes novamente',
              child: GestureDetector(
                onTap: onRetry,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xffe94560), Color(0xffc0392b)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.refresh_rounded,
                          color: Colors.white, size: 18),
                      SizedBox(width: 8),
                      Text('Tentar Novamente',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                    ],
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

class _DetailContent extends StatelessWidget {
  final GameDetail detail;
  const _DetailContent({required this.detail});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Chips de info
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            if (detail.genre.isNotEmpty) _InfoChip(detail.genre, const Color(0xffe94560)),
            if (detail.platform.isNotEmpty)
              _InfoChip(detail.platform, const Color(0xff0f3460)),
            if (detail.status.isNotEmpty)
              _InfoChip(
                detail.status,
                detail.status.toLowerCase() == 'live'
                    ? const Color(0xff4ecca3)
                    : const Color(0xff8888aa),
                textColor: detail.status.toLowerCase() == 'live'
                    ? const Color(0xff0d2b25)
                    : const Color(0xff0d0d1a),
              ),
          ],
        ),
        const SizedBox(height: 20),

        // Info grid
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xff1a1a2e),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
          ),
          child: Column(
            children: [
              _InfoRow(Icons.code_rounded, 'Desenvolvedor', detail.developer),
              if (detail.developer.isNotEmpty && detail.publisher.isNotEmpty)
                Divider(color: Colors.white.withValues(alpha: 0.05), height: 16),
              _InfoRow(Icons.business_rounded, 'Publisher', detail.publisher),
              if (detail.publisher.isNotEmpty && detail.releaseDate.isNotEmpty)
                Divider(color: Colors.white.withValues(alpha: 0.05), height: 16),
              _InfoRow(Icons.calendar_today_rounded, 'Lançamento', detail.releaseDate),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Descrição
        const Text(
          'Sobre o Jogo',
          style: TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          detail.description.isEmpty ? detail.title : detail.description,
          style: const TextStyle(
            color: Color(0xffb0b0c3),
            height: 1.65,
            fontSize: 14,
          ),
        ),

        // Screenshots
        if (detail.screenshots.isNotEmpty) ...[
          const SizedBox(height: 24),
          const Text(
            'Screenshots',
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 170,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: detail.screenshots.length,
              itemBuilder: (_, i) => Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Semantics(
                  label: 'Screenshot ${i + 1} do jogo ${detail.title}',
                  child: SizedBox(
                    width: 280,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: PlatformImage(
                        url: detail.screenshots[i].image,
                        fit: BoxFit.cover,
                        placeholder: () => Container(
                          color: const Color(0xff16213e),
                          child: const Icon(Icons.broken_image_rounded,
                              color: Colors.white12, size: 36),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final Color bg;
  final Color textColor;

  const _InfoChip(this.label, this.bg, {this.textColor = Colors.white});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: bg.withValues(alpha: 0.35)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: bg == const Color(0xff4ecca3) ? bg : Colors.white70,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow(this.icon, this.label, this.value);

  @override
  Widget build(BuildContext context) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Row(
      children: [
        Icon(icon, color: const Color(0xffe94560), size: 16),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      color: Color(0xff8888aa), fontSize: 11)),
              Text(value,
                  style: const TextStyle(
                      color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ],
    );
  }
}
