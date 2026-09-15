class Film {
  final String id;
  final String title;
  final String originalTitle;
  final String image;
  final String movieBanner;
  final String description;
  final String director;
  final String producer;
  final String releaseDate;
  final String runningTime;
  final String rtScore;

  const Film({
    required this.id,
    required this.title,
    required this.originalTitle,
    required this.image,
    required this.movieBanner,
    required this.description,
    required this.director,
    required this.producer,
    required this.releaseDate,
    required this.runningTime,
    required this.rtScore,
  });

  factory Film.fromJson(Map<String, dynamic> json) {
    return Film(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      originalTitle: json['original_title']?.toString() ?? '',
      image: json['image']?.toString() ?? '',
      movieBanner: json['movie_banner']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      director: json['director']?.toString() ?? '',
      producer: json['producer']?.toString() ?? '',
      releaseDate: json['release_date']?.toString() ?? '',
      runningTime: json['running_time']?.toString() ?? '',
      rtScore: json['rt_score']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'original_title': originalTitle,
        'image': image,
        'movie_banner': movieBanner,
        'description': description,
        'director': director,
        'producer': producer,
        'release_date': releaseDate,
        'running_time': runningTime,
        'rt_score': rtScore,
      };
}
