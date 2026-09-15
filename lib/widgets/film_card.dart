import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/pokemon.dart';
import '../providers/favorites_provider.dart';
import '../providers/played_provider.dart';
import '../screens/detail_screen.dart';
import 'platform_image.dart';

class PokemonCard extends StatelessWidget {
  final Pokemon pokemon;

  const PokemonCard({super.key, required this.pokemon});

  @override
  Widget build(BuildContext context) {
    final isFav = context.watch<FavoritesProvider>().isFavorite(pokemon.id);
    final isWatched = context.watch<PlayedProvider>().isWatched(pokemon.id);

    // RF10 — semanticLabel descritivo
    final semanticLabel = StringBuffer(pokemon.name);
    semanticLabel.write(', ${pokemon.number}');
    if (pokemon.types.isNotEmpty) semanticLabel.write('. Tipo: ${pokemon.types}');
    if (isFav) semanticLabel.write('. Favoritado');
    if (isWatched) semanticLabel.write('. Marcado');
    semanticLabel.write('. Toque para ver detalhes.');

    return Semantics(
      label: semanticLabel.toString(),
      button: true,
      child: GestureDetector(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => DetailScreen(pokemon: pokemon)),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF8FAB).withValues(alpha: 0.15),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // RF10 — semanticLabel na imagem
                      Semantics(
                        label: 'Imagem de ${pokemon.name}',
                        child: PlatformImage(
                          url: pokemon.image,
                          fit: BoxFit.contain,
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Row(
                          children: [
                            if (isFav)
                              _Badge(
                                icon: Icons.favorite_rounded,
                                color: const Color(0xFFFF8FAB),
                              ),
                            if (isWatched)
                              _Badge(
                                icon: Icons.check_circle_rounded,
                                color: const Color(0xFF97C8A0),
                              ),
                          ],
                        ),
                      ),
                      Positioned(
                        bottom: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFB8A9D9),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            pokemon.number,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pokemon.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF4A3F55),
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        pokemon.types.isNotEmpty
                            ? pokemon.types
                            : pokemon.number,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF9E91B8),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _Badge({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 4),
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.4),
            blurRadius: 6,
          ),
        ],
      ),
      child: Icon(icon, color: Colors.white, size: 12),
    );
  }
}
