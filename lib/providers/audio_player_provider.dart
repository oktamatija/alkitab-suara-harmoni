import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/music_genre.dart';
import '../models/verse.dart';
import '../services/music_service.dart';
import '../services/narration_service.dart';

enum AudioPlaybackStatus { stopped, playing, paused }

class AudioPlayerProvider extends ChangeNotifier {
  final NarrationService _narrationService = NarrationService();
  final MusicService _musicService = MusicService();

  AudioPlaybackStatus _status = AudioPlaybackStatus.stopped;
  List<Verse> _playlist = [];
  int _currentVerseIndex = -1;
  MusicGenre _activeGenre = MusicGenre.allGenres.first; // Default: Piano Khidmat

  double _narrationVolume = 1.0;
  double _musicVolume = 0.5;
  double _speechRate = 0.82; // Kecepatan tenang, syahdu dan khidmat untuk pembacaan firman
  bool _autoDucking = true;
  int _verseDelayMs = 1000; // Jeda hening 1 detik antar-ayat untuk perenungan doa

  VoidCallback? onChapterFinished;
  Function(int verseIndex)? onVerseChanged;

  int? _activeStartVerse;
  int? _activeEndVerse;

  AudioPlaybackStatus get status => _status;
  bool get isPlaying => _status == AudioPlaybackStatus.playing;
  bool get isPaused => _status == AudioPlaybackStatus.paused;
  bool get isStopped => _status == AudioPlaybackStatus.stopped;

  List<Verse> get playlist => _playlist;
  int get currentVerseIndex => _currentVerseIndex;
  Verse? get currentVerse =>
      (_currentVerseIndex >= 0 && _currentVerseIndex < _playlist.length)
          ? _playlist[_currentVerseIndex]
          : null;

  int? get activeStartVerse => _activeStartVerse;
  int? get activeEndVerse => _activeEndVerse;
  bool get isRangePlaybackActive =>
      _activeStartVerse != null && _activeEndVerse != null;

  MusicGenre get activeGenre => _activeGenre;
  NarrationEngineType get narrationEngine => _narrationService.engineType;
  double get narrationVolume => _narrationVolume;
  double get musicVolume => _musicVolume;
  double get speechRate => _speechRate;
  bool get autoDucking => _autoDucking;
  int get verseDelayMs => _verseDelayMs;

  Future<void> initialize() async {
    await _narrationService.initialize();
    await _musicService.initialize();

    _narrationService.onStart = () {
      if (_autoDucking) {
        _musicService.duck();
      }
    };

    _narrationService.onCompletion = () {
      _handleVerseCompleted();
    };

    _narrationService.onError = (error) {
      debugPrint('Narration error: $error');
      _handleVerseCompleted();
    };
  }

  void _handleVerseCompleted() {
    if (_status != AudioPlaybackStatus.playing) return;

    if (_autoDucking) {
      _musicService.unduck();
    }

    // 1. Cek apakah ayat yang baru saja selesai merupakan batas akhir rentang ayat yang dipilih
    if (isRangePlaybackActive &&
        currentVerse != null &&
        _activeEndVerse != null &&
        currentVerse!.verse >= _activeEndVerse!) {
      // Hentikan pembacaan ayat ketika pilihan rentang ayat selesai
      stop();
      return;
    }

    Timer(Duration(milliseconds: _verseDelayMs), () {
      if (_status != AudioPlaybackStatus.playing) return;

      if (_currentVerseIndex + 1 < _playlist.length) {
        final nextVerseObj = _playlist[_currentVerseIndex + 1];

        // 2. Cek apakah ayat berikutnya melewati batas akhir rentang ayat
        if (isRangePlaybackActive &&
            _activeEndVerse != null &&
            nextVerseObj.verse > _activeEndVerse!) {
          stop();
          return;
        }

        _currentVerseIndex++;
        onVerseChanged?.call(_currentVerseIndex);
        notifyListeners();
        _speakCurrentVerse();
      } else {
        // Akhir pasal tercapai
        if (!isRangePlaybackActive && onChapterFinished != null) {
          onChapterFinished!();
        } else {
          stop();
        }
      }
    });
  }

  /// Memutar ayat dalam satu pasal secara penuh atau mulai dari startIndex
  Future<void> playChapter(List<Verse> verses, {int startIndex = 0}) async {
    if (verses.isEmpty) return;

    // Reset rentang ayat agar memutar seluruh pasal
    _activeStartVerse = null;
    _activeEndVerse = null;

    _playlist = verses;
    _currentVerseIndex = startIndex.clamp(0, verses.length - 1);
    _status = AudioPlaybackStatus.playing;
    notifyListeners();

    // 1. Putar Musik Pengiring (asinkron tanpa memblokir narasi ayat)
    if (!_activeGenre.isMuted) {
      _musicService.setVolume(_musicVolume);
      _musicService.playGenre(_activeGenre);
    }

    // 2. Putar Narasi Suara Ayat
    onVerseChanged?.call(_currentVerseIndex);
    await _speakCurrentVerse();
  }

  /// Memutar rentang ayat tertentu (contoh: ayat 1 sampai 10 atau 1 sampai 15).
  /// Ketika pembacaan mencapai endVerse, pembacaan otomatis dihentikan.
  Future<void> playVerseRange(
    List<Verse> verses, {
    required int startVerse,
    required int endVerse,
  }) async {
    if (verses.isEmpty) return;

    final actualStart = startVerse <= endVerse ? startVerse : endVerse;
    final actualEnd = startVerse <= endVerse ? endVerse : startVerse;

    _activeStartVerse = actualStart;
    _activeEndVerse = actualEnd;
    _playlist = verses;

    // Cari index ayat yang sesuai dengan actualStart
    final foundIndex = verses.indexWhere((v) => v.verse == actualStart);
    _currentVerseIndex = foundIndex >= 0 ? foundIndex : 0;
    _status = AudioPlaybackStatus.playing;
    notifyListeners();

    // Putar Musik Pengiring
    if (!_activeGenre.isMuted) {
      _musicService.setVolume(_musicVolume);
      _musicService.playGenre(_activeGenre);
    }

    // Putar Narasi Suara Ayat Mulai
    onVerseChanged?.call(_currentVerseIndex);
    await _speakCurrentVerse();
  }

  /// Menghapus batas rentang ayat agar player kembali ke mode seluruh pasal
  void clearVerseRange() {
    if (_activeStartVerse != null || _activeEndVerse != null) {
      _activeStartVerse = null;
      _activeEndVerse = null;
      notifyListeners();
    }
  }

  Future<void> _speakCurrentVerse() async {
    if (currentVerse == null) return;
    await _narrationService.setVolume(_narrationVolume);
    await _narrationService.setSpeechRate(_speechRate);
    await _narrationService.speak(currentVerse!.text, verseId: currentVerse!.id);
  }

  void setNarrationEngine(NarrationEngineType type) {
    _narrationService.setEngineType(type);
    notifyListeners();
  }

  Future<void> pause() async {
    if (_status != AudioPlaybackStatus.playing) return;
    _status = AudioPlaybackStatus.paused;
    await _narrationService.pause();
    await _musicService.pause();
    notifyListeners();
  }

  Future<void> resume() async {
    if (_status != AudioPlaybackStatus.paused) return;
    _status = AudioPlaybackStatus.playing;
    notifyListeners();
    await _musicService.resume();
    await _speakCurrentVerse();
  }

  Future<void> stop() async {
    _status = AudioPlaybackStatus.stopped;
    _currentVerseIndex = -1;
    await _narrationService.stop();
    await _musicService.stop();
    notifyListeners();
  }

  Future<void> nextVerse() async {
    if (_playlist.isEmpty) return;
    if (_currentVerseIndex + 1 < _playlist.length) {
      final nextObj = _playlist[_currentVerseIndex + 1];
      if (isRangePlaybackActive &&
          _activeEndVerse != null &&
          nextObj.verse > _activeEndVerse!) {
        // Sudah mencapai batas akhir rentang ayat yang dipilih
        return;
      }
      _currentVerseIndex++;
      onVerseChanged?.call(_currentVerseIndex);
      notifyListeners();
      if (_status == AudioPlaybackStatus.playing) {
        await _speakCurrentVerse();
      }
    }
  }

  Future<void> previousVerse() async {
    if (_playlist.isEmpty) return;
    if (_currentVerseIndex > 0) {
      final prevObj = _playlist[_currentVerseIndex - 1];
      if (isRangePlaybackActive &&
          _activeStartVerse != null &&
          prevObj.verse < _activeStartVerse!) {
        // Sudah mencapai batas awal rentang ayat yang dipilih
        return;
      }
      _currentVerseIndex--;
      onVerseChanged?.call(_currentVerseIndex);
      notifyListeners();
      if (_status == AudioPlaybackStatus.playing) {
        await _speakCurrentVerse();
      }
    }
  }

  Future<void> jumpToVerse(int index) async {
    if (_playlist.isEmpty) return;
    final clamped = index.clamp(0, _playlist.length - 1);
    final targetVerse = _playlist[clamped];

    // Jika rentang ayat aktif, pastikan tidak melompat keluar dari rentang
    if (isRangePlaybackActive) {
      if (_activeStartVerse != null && targetVerse.verse < _activeStartVerse!) {
        return;
      }
      if (_activeEndVerse != null && targetVerse.verse > _activeEndVerse!) {
        return;
      }
    }

    _currentVerseIndex = clamped;
    _status = AudioPlaybackStatus.playing;
    onVerseChanged?.call(_currentVerseIndex);
    notifyListeners();

    if (!_musicService.isPlaying && !_activeGenre.isMuted) {
      await _musicService.playGenre(_activeGenre);
    }
    await _speakCurrentVerse();
  }

  Future<void> changeGenre(MusicGenre genre) async {
    _activeGenre = genre;
    notifyListeners();
    if (_status == AudioPlaybackStatus.playing) {
      await _musicService.playGenre(genre);
    }
  }

  Future<void> setNarrationVolume(double vol) async {
    _narrationVolume = vol.clamp(0.0, 1.0);
    await _narrationService.setVolume(_narrationVolume);
    notifyListeners();
  }

  Future<void> setMusicVolume(double vol) async {
    _musicVolume = vol.clamp(0.0, 1.0);
    await _musicService.setVolume(_musicVolume);
    notifyListeners();
  }

  Future<void> setSpeechRate(double rate) async {
    _speechRate = rate;
    await _narrationService.setSpeechRate(_speechRate);
    notifyListeners();
  }

  void setAutoDucking(bool enabled) {
    _autoDucking = enabled;
    _musicService.setAutoDucking(enabled);
    notifyListeners();
  }

  void setVerseDelay(int ms) {
    _verseDelayMs = ms;
    notifyListeners();
  }

  @override
  void dispose() {
    _narrationService.dispose();
    _musicService.dispose();
    super.dispose();
  }
}
