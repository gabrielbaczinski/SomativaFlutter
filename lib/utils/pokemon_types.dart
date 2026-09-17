import 'package:flutter/material.dart';

/// Os 18 tipos elementais de Pokémon, na mesma grafia (capitalizada, em
/// inglês) que a API retorna e que já é exibida na tela de Detalhes.
const List<String> kPokemonTypes = [
  'Normal', 'Fire', 'Water', 'Electric', 'Grass', 'Ice', 'Fighting', 'Poison',
  'Ground', 'Flying', 'Psychic', 'Bug', 'Rock', 'Ghost', 'Dragon', 'Dark',
  'Steel', 'Fairy',
];

const Map<String, Color> kPokemonTypeColors = {
  'Fire': Color(0xFFFF8FAB),
  'Water': Color(0xFF90CAF9),
  'Grass': Color(0xFF97C8A0),
  'Electric': Color(0xFFFFD54F),
  'Psychic': Color(0xFFCE93D8),
  'Ice': Color(0xFF80DEEA),
  'Dragon': Color(0xFF7986CB),
  'Dark': Color(0xFF8D6E63),
  'Fairy': Color(0xFFF48FB1),
  'Normal': Color(0xFFBDBDBD),
  'Fighting': Color(0xFFFF7043),
  'Flying': Color(0xFFB8A9D9),
  'Poison': Color(0xFFBA68C8),
  'Ground': Color(0xFFD7CCC8),
  'Rock': Color(0xFFA1887F),
  'Bug': Color(0xFFAED581),
  'Ghost': Color(0xFF9575CD),
  'Steel': Color(0xFF90A4AE),
};

Color pokemonTypeColor(String type) =>
    kPokemonTypeColors[type] ?? const Color(0xFFB8A9D9);
