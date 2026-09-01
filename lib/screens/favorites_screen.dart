import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/favorites_provider.dart';
import '../widgets/game_card.dart';
import 'detail_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final favorites = context.watch<FavoritesProvider>().favorites;

    return Scaffold(
      backgroundColor: const Color(0xff0d0d1a),
      appBar: AppBar(
        backgroundColor: const Color(0xff0d0d1a),
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Row(
          children: [
            const Icon(Icons.favorite_rounded, color: Color(0xffe94560), size: 20),
            const SizedBox(width: 8),
            const Text(
              'Favoritos',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            if (favorites.isNotEmpty) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xffe94560).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: const Color(0xffe94560).withValues(alpha: 0.3)),
                ),
                child: Text(
                  '${favorites.length}',
                  style: const TextStyle(
                      color: Color(0xffe94560),
                      fontSize: 12,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ],
        ),
      ),
      body: favorites.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xffe94560).withValues(alpha: 0.08),
                      border: Border.all(
                          color: const Color(0xffe94560).withValues(alpha: 0.15)),
                    ),
                    child: const Icon(Icons.favorite_border_rounded,
                        size: 36, color: Color(0xffe94560)),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Nenhum favorito ainda',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Toque na estrela ⭐ nos detalhes de um jogo',
                    style: TextStyle(color: Color(0xff8888aa), fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.68,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final game = favorites[index];
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
    );
  }
}
