class Verse {
  final int id;
  final int bookId;
  final int chapter;
  final int verse;
  final String text;
  final String? title; // Judul Perikop jika ada
  bool isBookmarked;

  Verse({
    required this.id,
    required this.bookId,
    required this.chapter,
    required this.verse,
    required this.text,
    this.title,
    this.isBookmarked = false,
  });

  String get reference => '$chapter:$verse';

  factory Verse.fromJson(Map<String, dynamic> json) {
    // Mendukung baik format ringkas {b, c, v, t, title} maupun {bookId, chapter, verse, text}
    final id = json['id'] is int ? json['id'] as int : int.tryParse(json['id'].toString()) ?? 0;
    final bookId = json['b'] ?? json['bookId'] ?? json['book'] ?? 1;
    final chapter = json['c'] ?? json['chapter'] ?? 1;
    final verse = json['v'] ?? json['verse'] ?? 1;
    final text = (json['t'] ?? json['text'] ?? '').toString();
    final title = json['title'] as String?;

    return Verse(
      id: id,
      bookId: bookId is int ? bookId : int.tryParse(bookId.toString()) ?? 1,
      chapter: chapter is int ? chapter : int.tryParse(chapter.toString()) ?? 1,
      verse: verse is int ? verse : int.tryParse(verse.toString()) ?? 1,
      text: text,
      title: (title != null && title.trim().isNotEmpty) ? title.trim() : null,
      isBookmarked: json['isBookmarked'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'b': bookId,
      'c': chapter,
      'v': verse,
      't': text,
      'title': title,
      'isBookmarked': isBookmarked,
    };
  }
}
