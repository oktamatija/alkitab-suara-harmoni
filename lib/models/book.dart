class Book {
  final int id;
  final String name;
  final String abbr;
  final String testament; // 'PL' atau 'PB'
  final int maxChapter;
  final int totalVerses;

  const Book({
    required this.id,
    required this.name,
    required this.abbr,
    required this.testament,
    required this.maxChapter,
    required this.totalVerses,
  });

  bool get isOldTestament => testament == 'PL';
  bool get isNewTestament => testament == 'PB';

  String get testamentName => isOldTestament ? 'Perjanjian Lama' : 'Perjanjian Baru';

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'] as int,
      name: json['name'] as String,
      abbr: json['abbr'] as String,
      testament: json['testament'] as String,
      maxChapter: json['maxChapter'] as int? ?? 1,
      totalVerses: json['totalVerses'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'abbr': abbr,
      'testament': testament,
      'maxChapter': maxChapter,
      'totalVerses': totalVerses,
    };
  }
}
