import 'package:flutter/foundation.dart';
import '../models/book.dart';
import '../models/verse.dart';
import '../services/bible_storage_service.dart';

class BibleProvider extends ChangeNotifier {
  final BibleStorageService _storageService = BibleStorageService();

  int _currentBookId = 43; // Default: Injil Yohanes
  int _currentChapter = 1;
  List<Verse> _currentVerses = [];
  bool _isLoading = true;

  // Status Download Alkitab Lengkap
  bool _isDownloading = false;
  double _downloadProgress = 0.0;
  String _downloadStatus = '';

  BibleStorageService get storage => _storageService;
  List<Book> get books => _storageService.books;
  int get currentBookId => _currentBookId;
  int get currentChapter => _currentChapter;
  List<Verse> get currentVerses => _currentVerses;
  bool get isLoading => _isLoading;
  bool get isFullBibleDownloaded => _storageService.isFullBibleDownloaded;
  Set<int> get bookmarkedIds => _storageService.bookmarkedIds;

  bool get isDownloading => _isDownloading;
  double get downloadProgress => _downloadProgress;
  String get downloadStatus => _downloadStatus;

  Book? get currentBook => _storageService.getBookById(_currentBookId);

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    await _storageService.initialize();

    // Jika Yohanes belum terunduh (misal konfigurasi custom), pilih kitab pertama yang ada
    if (!_storageService.isBookAvailable(_currentBookId)) {
      final available = _storageService.books.firstWhere(
        (b) => _storageService.isBookAvailable(b.id),
        orElse: () => _storageService.books.first,
      );
      _currentBookId = available.id;
    }

    _loadCurrentChapter();
    _isLoading = false;
    notifyListeners();
  }

  void _loadCurrentChapter() {
    _currentVerses = _storageService.getVerses(_currentBookId, _currentChapter);
  }

  void selectBook(int bookId) {
    if (_currentBookId == bookId) return;
    _currentBookId = bookId;
    _currentChapter = 1;
    _loadCurrentChapter();
    notifyListeners();
  }

  void selectChapter(int chapter) {
    final book = currentBook;
    if (book == null) return;
    final clamped = chapter.clamp(1, book.maxChapter);
    if (_currentChapter == clamped) return;
    _currentChapter = clamped;
    _loadCurrentChapter();
    notifyListeners();
  }

  bool nextChapter() {
    final book = currentBook;
    if (book == null) return false;

    if (_currentChapter < book.maxChapter) {
      selectChapter(_currentChapter + 1);
      return true;
    } else {
      // Pindah ke kitab berikutnya
      final nextBookId = _currentBookId + 1;
      if (nextBookId <= 66) {
        selectBook(nextBookId);
        return true;
      }
    }
    return false;
  }

  bool previousChapter() {
    if (_currentChapter > 1) {
      selectChapter(_currentChapter - 1);
      return true;
    } else {
      // Pindah ke pasal terakhir kitab sebelumnya
      final prevBookId = _currentBookId - 1;
      if (prevBookId >= 1) {
        final prevBook = _storageService.getBookById(prevBookId);
        if (prevBook != null) {
          _currentBookId = prevBookId;
          _currentChapter = prevBook.maxChapter;
          _loadCurrentChapter();
          notifyListeners();
          return true;
        }
      }
    }
    return false;
  }

  Future<void> toggleBookmark(Verse verse) async {
    await _storageService.toggleBookmark(verse);
    notifyListeners();
  }

  List<Verse> getBookmarkedVerses() {
    return _storageService.getAllBookmarkedVerses();
  }

  List<Verse> search(String query) {
    return _storageService.searchVerses(query);
  }

  Future<void> startDownloadFullBible() async {
    if (_isDownloading) return;
    _isDownloading = true;
    _downloadProgress = 0.0;
    _downloadStatus = 'Memulai proses unduhan...';
    notifyListeners();

    try {
      await _storageService.downloadFullBible(
        onProgress: (progress, status) {
          _downloadProgress = progress;
          _downloadStatus = status;
          notifyListeners();
        },
      );
      // Muat ulang pasal yang sedang dibuka
      _loadCurrentChapter();
    } catch (e) {
      _downloadStatus = 'Gagal mengunduh: $e';
    } finally {
      _isDownloading = false;
      notifyListeners();
    }
  }

  Future<void> clearOfflineData() async {
    await _storageService.clearOfflineData();
    _loadCurrentChapter();
    notifyListeners();
  }
}
