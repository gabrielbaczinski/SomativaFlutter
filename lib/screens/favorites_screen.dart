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
      backgroundColor: const Color(0xff1a1a2e),
      appBar: AppBar(
        title: const Text('Favoritos'),
        backgroundColor: const Color(0xff16213e),
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: favorites.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.star_border_rounded,
                      size: 72, color: Colors.white24),
                  SizedBox(height: 14),
                  Text(
                    'Nenhum jogo favoritado ainda',
                    style: TextStyle(color: Colors.white38, fontSize: 15),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Toque na estrela nos detalhes de um jogo',
                    style: TextStyle(color: Colors.white24, fontSize: 12),
                  ),
                ],
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.72,
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
