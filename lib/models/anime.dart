class Anime {
  final String id;
  final String title;
  final String titleJapanese;
  final String image;
  final String synopsis;
  final String studios;
  final String genres;
  final String year;
  final String episodes;
  final String score;
  final String type;

  const Anime({
    required this.id,
    required this.title,
    required this.titleJapanese,
    required this.image,
    required this.synopsis,
    required this.studios,
    required this.genres,
    required this.year,
    required this.episodes,
    required this.score,
    required this.type,
  });

  factory Anime.fromJson(Map<String, dynamic> json) {
    final images = json['images'] as Map<String, dynamic>? ?? {};
    final jpg = images['jpg'] as Map<String, dynamic>? ?? {};

    final studioList = (json['studios'] as List<dynamic>? ?? [])
        .map((s) => (s as Map<String, dynamic>)['name'] as String)
        .where((s) => s.isNotEmpty)
        .toList();

    final genreList = (json['genres'] as List<dynamic>? ?? [])
        .map((g) => (g as Map<String, dynamic>)['name'] as String)
        .where((g) => g.isNotEmpty)
        .toList();

    final englishTitle = json['title_english'] as String?;
    final mainTitle = json['title'] as String? ?? '';

    return Anime(
      id: (json['mal_id'] as int).toString(),
      title: (englishTitle != null && englishTitle.isNotEmpty)
          ? englishTitle
          : mainTitle,
      titleJapanese: json['title_japanese'] as String? ?? '',
      image: (jpg['large_image_url'] as String?) ??
          (jpg['image_url'] as String?) ??
          '',
      synopsis: json['synopsis'] as String? ?? '',
      studios: studioList.isEmpty ? 'Desconhecido' : studioList.join(', '),
      genres: genreList.isEmpty ? '' : genreList.take(3).join(', '),
      year: json['year']?.toString() ?? '',
      episodes: json['episodes']?.toString() ?? '?',
      score: json['score']?.toString() ?? '?',
      type: json['type'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'mal_id': int.tryParse(id) ?? 0,
        'title_english': title,
        'title_japanese': titleJapanese,
        'images': {
          'jpg': {'large_image_url': image}
        },
        'synopsis': synopsis,
        'studios': studios.split(', ').map((s) => {'name': s}).toList(),
        'genres': genres.split(', ').map((g) => {'name': g}).toList(),
        'year': int.tryParse(year),
        'episodes': int.tryParse(episodes),
        'score': double.tryParse(score),
        'type': type,
      };
}
