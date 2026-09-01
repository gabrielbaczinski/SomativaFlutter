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
      backgroundColor: const Color(0xff1a1a2e),
      appBar: AppBar(
        title: const Text('Jogos Jogados'),
        backgroundColor: const Color(0xff16213e),
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: played.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.videogame_asset_off,
                      size: 72, color: Colors.white24),
                  SizedBox(height: 14),
                  Text(
                    'Nenhum jogo marcado como jogado',
                    style: TextStyle(color: Colors.white38, fontSize: 15),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Marque jogos nos detalhes para vê-los aqui',
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
