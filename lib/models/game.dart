class Game {
  final int id;
  final String title;
  final String thumbnail;
  final String genre;
  final String platform;
  final String shortDescription;

  const Game({
    required this.id,
    required this.title,
    required this.thumbnail,
    required this.genre,
    required this.platform,
    required this.shortDescription,
  });

  factory Game.fromJson(Map<String, dynamic> json) => Game(
        id: json['id'] as int,
        title: json['title'] as String? ?? '',
        thumbnail: json['thumbnail'] as String? ?? '',
        genre: json['genre'] as String? ?? '',
        platform: json['platform'] as String? ?? '',
        shortDescription: json['short_description'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'thumbnail': thumbnail,
        'genre': genre,
        'platform': platform,
        'short_description': shortDescription,
      };
}
