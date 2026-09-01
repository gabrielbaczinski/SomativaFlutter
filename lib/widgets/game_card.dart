import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/game.dart';
import '../providers/favorites_provider.dart';
import '../providers/played_provider.dart';
import 'platform_image.dart';

class GameCard extends StatelessWidget {
  final Game game;
  final VoidCallback onTap;

  const GameCard({super.key, required this.game, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isFav = context.watch<FavoritesProvider>().isFavorite(game.id);
    final isPlayed = context.watch<PlayedProvider>().isPlayed(game.id);

    return Semantics(
      label: 'Jogo: ${game.title}, gênero: ${game.genre}. '
          '${isFav ? "Favoritado." : ""}${isPlayed ? " Jogado." : ""}',
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background image
              PlatformImage(
                url: game.thumbnail,
                fit: BoxFit.cover,
                placeholder: _placeholder,
              ),

              // Gradient overlay — garante legibilidade do texto
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: [0.35, 1.0],
                    colors: [Colors.transparent, Color(0xf00d0d1a)],
                  ),
                ),
              ),

              // Title + genre na parte inferior
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (game.genre.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(bottom: 5),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xffe94560).withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            game.genre.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                      Text(
                        game.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          shadows: [
                            Shadow(blurRadius: 6, color: Colors.black87),
                          ],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),

              // Badges de status (topo direito)
              if (isFav || isPlayed)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isPlayed) _badge(Icons.check_circle_rounded, const Color(0xff4ecca3)),
                      if (isFav) ...[
                        if (isPlayed) const SizedBox(width: 4),
                        _badge(Icons.star_rounded, const Color(0xffe94560)),
                      ],
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _badge(IconData icon, Color color) => Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.65),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.4), width: 1),
        ),
        child: Icon(icon, color: color, size: 13),
      );

  Widget _placeholder() => const ColoredBox(
        color: Color(0xff16213e),
        child: Center(
          child: Icon(Icons.videogame_asset, size: 40, color: Colors.white12),
        ),
      );
}
