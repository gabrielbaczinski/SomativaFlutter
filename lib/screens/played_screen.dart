import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/played_provider.dart';
import '../widgets/film_card.dart';
import '../widgets/staggered_fade_in.dart';

class PlayedScreen extends StatelessWidget {
  const PlayedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final watched = context.watch<PlayedProvider>().watched;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.catching_pokemon_rounded,
                color: Color(0xFF97C8A0), size: 22),
            const SizedBox(width: 8),
            const Text(
              'Capturados',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: Color(0xFF4A3F55),
              ),
            ),
            if (watched.isNotEmpty) ...[
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF97C8A0),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${watched.length}',
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
      body: watched.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF97C8A0).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.catching_pokemon_outlined,
                      size: 56,
                      color: Color(0xFF97C8A0),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Nenhum pokémon capturado',
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
                      'Marque os pokémons que você já capturou.',
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
              itemCount: watched.length,
              itemBuilder: (_, i) => StaggeredFadeIn(
                  index: i, child: PokemonCard(pokemon: watched[i])),
            ),
    );
  }
}
