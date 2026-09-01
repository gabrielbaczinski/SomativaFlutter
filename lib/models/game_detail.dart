class Screenshot {
  final int id;
  final String image;

  const Screenshot({required this.id, required this.image});

  factory Screenshot.fromJson(Map<String, dynamic> json) => Screenshot(
        id: json['id'] as int,
        image: json['image'] as String? ?? '',
      );
}

class GameDetail {
  final int id;
  final String title;
  final String thumbnail;
  final String description;
  final String genre;
  final String platform;
  final String publisher;
  final String developer;
  final String releaseDate;
  final String gameUrl;
  final String status;
  final List<Screenshot> screenshots;

  const GameDetail({
    required this.id,
    required this.title,
    required this.thumbnail,
    required this.description,
    required this.genre,
    required this.platform,
    required this.publisher,
    required this.developer,
    required this.releaseDate,
    required this.gameUrl,
    required this.status,
    required this.screenshots,
  });

  factory GameDetail.fromJson(Map<String, dynamic> json) {
    final rawShots = json['screenshots'] as List<dynamic>? ?? [];
    return GameDetail(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      thumbnail: json['thumbnail'] as String? ?? '',
      description: json['description'] as String? ?? '',
      genre: json['genre'] as String? ?? '',
      platform: json['platform'] as String? ?? '',
      publisher: json['publisher'] as String? ?? '',
      developer: json['developer'] as String? ?? '',
      releaseDate: json['release_date'] as String? ?? '',
      gameUrl: json['game_url'] as String? ?? '',
      status: json['status'] as String? ?? '',
      screenshots: rawShots
          .map((s) => Screenshot.fromJson(s as Map<String, dynamic>))
          .toList(),
    );
  }
}
