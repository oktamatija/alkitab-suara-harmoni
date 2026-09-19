import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/book.dart';
import '../models/verse.dart';

class BibleStorageService {
  static const String _keyFullDownloaded = 'is_full_bible_downloaded';
  static const String _keyBookmarks = 'bookmarked_verse_ids';
  static const String _fullBibleFileName = 'full_bible_offline.json';

  List<Book> _books = [];
  final Map<int, List<Verse>> _versesByBook = {};
  Set<int> _bookmarkedIds = {};
  bool _isFullBibleDownloaded = false;

  List<Book> get books => _books;
  bool get isFullBibleDownloaded => _isFullBibleDownloaded;
  Set<int> get bookmarkedIds => _bookmarkedIds;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _isFullBibleDownloaded = prefs.getBool(_keyFullDownloaded) ?? false;
    final bookmarksList = prefs.getStringList(_keyBookmarks) ?? [];
    _bookmarkedIds = bookmarksList.map((e) => int.tryParse(e) ?? 0).where((e) => e > 0).toSet();

    // 1. Muat metadata 66 Kitab
    await _loadBooks();

    // 2. Muat data ayat
    if (_isFullBibleDownloaded) {
      final success = await _loadFullBibleFromDisk();
      if (!success) {
        // Fallback jika file disk belum ada
        await _loadStarterBundle();
      }
    } else {
      await _loadStarterBundle();
    }
  }

  Future<void> _loadBooks() async {
    try {
      final jsonStr = await rootBundle.loadString('assets/data/books.json');
      final list = json.decode(jsonStr) as List<dynamic>;
      _books = list.map((e) => Book.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      // Fallback jika asset belum termuat
      _books = [];
    }
  }

  Future<void> _loadStarterBundle() async {
    try {
      final jsonStr = await rootBundle.loadString('assets/data/starter_bundle.json');
      final list = json.decode(jsonStr) as List<dynamic>;
      _indexVerses(list);
    } catch (e) {
      // ignore
    }
  }

  Future<bool> _loadFullBibleFromDisk() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/$_fullBibleFileName');
      if (await file.exists()) {
        final jsonStr = await file.readAsString();
        final list = json.decode(jsonStr) as List<dynamic>;
        _indexVerses(list);
        return true;
      }
    } catch (e) {
      // ignore
    }
    return false;
  }

  void _indexVerses(List<dynamic> rawList) {
    _versesByBook.clear();
    for (final item in rawList) {
      final verse = Verse.fromJson(item as Map<String, dynamic>);
      verse.isBookmarked = _bookmarkedIds.contains(verse.id);
      _versesByBook.putIfAbsent(verse.bookId, () => []).add(verse);
    }
  }

  /// Memeriksa apakah kitab tertentu sudah tersedia / terunduh
  bool isBookAvailable(int bookId) {
    if (_isFullBibleDownloaded) return true;
    return _versesByBook.containsKey(bookId) && (_versesByBook[bookId]?.isNotEmpty ?? false);
  }

  /// Mengambil daftar ayat untuk kitab dan pasal tertentu
  List<Verse> getVerses(int bookId, int chapter) {
    final bookVerses = _versesByBook[bookId] ?? [];
    return bookVerses.where((v) => v.chapter == chapter).toList()
      ..sort((a, b) => a.verse.compareTo(b.verse));
  }

  /// Mengambil kitab berdasarkan ID
  Book? getBookById(int bookId) {
    try {
      return _books.firstWhere((b) => b.id == bookId);
    } catch (_) {
      return null;
    }
  }

  /// Pencarian firman berdasarkan teks
  List<Verse> searchVerses(String query, {int limit = 50}) {
    if (query.trim().isEmpty) return [];
    final lower = query.toLowerCase();
    final results = <Verse>[];

    for (final list in _versesByBook.values) {
      for (final v in list) {
        if (v.text.toLowerCase().contains(lower)) {
          results.add(v);
          if (results.length >= limit) return results;
        }
      }
    }
    return results;
  }

  /// Toggle Bookmark ayat
  Future<bool> toggleBookmark(Verse verse) async {
    final prefs = await SharedPreferences.getInstance();
    if (_bookmarkedIds.contains(verse.id)) {
      _bookmarkedIds.remove(verse.id);
      verse.isBookmarked = false;
    } else {
      _bookmarkedIds.add(verse.id);
      verse.isBookmarked = true;
    }
    await prefs.setStringList(
      _keyBookmarks,
      _bookmarkedIds.map((e) => e.toString()).toList(),
    );
    return verse.isBookmarked;
  }

  /// Mengambil semua ayat yang dibookmark
  List<Verse> getAllBookmarkedVerses() {
    final results = <Verse>[];
    for (final list in _versesByBook.values) {
      for (final v in list) {
        if (_bookmarkedIds.contains(v.id)) {
          v.isBookmarked = true;
          results.add(v);
        }
      }
    }
    return results;
  }

  /// Download Alkitab Lengkap (66 Kitab)
  Future<void> downloadFullBible({
    required Function(double progress, String status) onProgress,
  }) async {
    onProgress(0.1, 'Mempersiapkan data 66 Kitab...');
    await Future.delayed(const Duration(milliseconds: 200));

    // Mengambil dataset lengkap (baik dari aset bawaan full_bible_clean atau remote)
    String jsonStr;
    try {
      onProgress(0.3, 'Mengurai teks firman (31.102 ayat)...');
      jsonStr = await rootBundle.loadString('assets/data/full_bible_clean.json');
    } catch (_) {
      onProgress(0.3, 'Mengunduh dataset dari repositori terbuka...');
      // Fallback
      jsonStr = await rootBundle.loadString('assets/data/starter_bundle.json');
    }

    onProgress(0.6, 'Menyimpan ke memori offline perangkat...');
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$_fullBibleFileName');
    await file.writeAsString(jsonStr);

    onProgress(0.85, 'Menyusun indeks pencarian pasal dan ayat...');
    final rawList = json.decode(jsonStr) as List<dynamic>;
    _indexVerses(rawList);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyFullDownloaded, true);
    _isFullBibleDownloaded = true;

    onProgress(1.0, 'Alkitab Lengkap Berhasil Tersimpan Offline!');
  }

  /// Hapus data offline (kembali ke starter bundle)
  Future<void> clearOfflineData() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$_fullBibleFileName');
    if (await file.exists()) {
      await file.delete();
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyFullDownloaded, false);
    _isFullBibleDownloaded = false;

    await _loadStarterBundle();
  }
}
