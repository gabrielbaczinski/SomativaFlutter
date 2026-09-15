class Pokemon {
  final String id;
  final String name;
  final String image;
  final String types;
  final String height;
  final String weight;

  const Pokemon({
    required this.id,
    required this.name,
    required this.image,
    required this.types,
    required this.height,
    required this.weight,
  });

  String get number => '#${id.padLeft(3, '0')}';

  static String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1).replaceAll('-', ' ');
  }

  static String _imageUrl(String id) =>
      'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png';

  // Usado pelo endpoint de listagem (?limit=N&offset=N)
  factory Pokemon.fromListJson(Map<String, dynamic> json) {
    final url = json['url'] as String;
    final id = url.split('/').where((s) => s.isNotEmpty).last;
    return Pokemon(
      id: id,
      name: _capitalize(json['name'] as String),
      image: _imageUrl(id),
      types: '',
      height: '',
      weight: '',
    );
  }

  // Usado pelo endpoint de detalhe (/pokemon/{id})
  factory Pokemon.fromDetailJson(Map<String, dynamic> json) {
    final id = (json['id'] as int).toString();
    final typeList = (json['types'] as List<dynamic>)
        .map((t) => _capitalize(
            (t as Map<String, dynamic>)['type']['name'] as String))
        .toList();
    final heightDm = json['height'] as int;
    final weightHg = json['weight'] as int;
    return Pokemon(
      id: id,
      name: _capitalize(json['name'] as String),
      image: _imageUrl(id),
      types: typeList.join(', '),
      height: '${(heightDm / 10).toStringAsFixed(1)} m',
      weight: '${(weightHg / 10).toStringAsFixed(1)} kg',
    );
  }

  factory Pokemon.fromJson(Map<String, dynamic> json) => Pokemon(
        id: json['id'] as String,
        name: json['name'] as String,
        image: json['image'] as String,
        types: json['types'] as String? ?? '',
        height: json['height'] as String? ?? '',
        weight: json['weight'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'image': image,
        'types': types,
        'height': height,
        'weight': weight,
      };
}
