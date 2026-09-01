import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/played_provider.dart';
import '../widgets/game_card.dart';
import 'detail_screen.dart';

class PlayedScreen extends StatelessWidget {
  const PlayedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final played = context.watch<PlayedProvider>().played;

    return Scaffold(
      backgroundColor: const Color(0xff0d0d1a),
      appBar: AppBar(
        backgroundColor: const Color(0xff0d0d1a),
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Row(
          children: [
            const Icon(Icons.videogame_asset_rounded,
                color: Color(0xff4ecca3), size: 20),
            const SizedBox(width: 8),
            const Text(
              'Jogados',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            if (played.isNotEmpty) ...[
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xff4ecca3).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: const Color(0xff4ecca3).withValues(alpha: 0.3)),
                ),
                child: Text(
                  '${played.length}',
                  style: const TextStyle(
                      color: Color(0xff4ecca3),
                      fontSize: 12,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ],
        ),
      ),
      body: played.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xff4ecca3).withValues(alpha: 0.08),
                      border: Border.all(
                          color: const Color(0xff4ecca3).withValues(alpha: 0.15)),
                    ),
                    child: const Icon(Icons.videogame_asset_off_rounded,
                        size: 36, color: Color(0xff4ecca3)),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Nenhum jogo jogado ainda',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Marque jogos como jogados nos detalhes ✓',
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
              itemCount: played.length,
              itemBuilder: (context, index) {
                final game = played[index];
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
