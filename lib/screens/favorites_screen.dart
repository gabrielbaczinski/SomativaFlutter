import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/favorites_provider.dart';
import '../widgets/film_card.dart';
import '../widgets/staggered_fade_in.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final favorites = context.watch<FavoritesProvider>().favorites;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.favorite_rounded,
                color: Color(0xFFFF8FAB), size: 22),
            const SizedBox(width: 8),
            const Text(
              'Favoritos',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: Color(0xFF4A3F55),
              ),
            ),
            if (favorites.isNotEmpty) ...[
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF8FAB),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${favorites.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ],
        ),
        leading: IconButton(
          tooltip: 'Voltar para o catálogo',
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF4A3F55)),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: favorites.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF8FAB).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.favorite_border_rounded,
                      size: 56,
                      color: Color(0xFFFF8FAB),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Nenhum favorito ainda',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF4A3F55),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      'Explore os pokémons e adicione seus favoritos.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF7A6D93),
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.75,
              ),
              itemCount: favorites.length,
              itemBuilder: (_, i) => StaggeredFadeIn(
                  index: i, child: PokemonCard(pokemon: favorites[i])),
            ),
    );
  }
}
