import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import '../models/music_genre.dart';

class MusicService {
  final AudioPlayer _player = AudioPlayer();
  MusicGenre _currentGenre = MusicGenre.allGenres.first;
  double _baseVolume = 0.5; // 50% default volume
  bool _isPlaying = false;
  bool _autoDuckingEnabled = true;
  bool _isDucked = false;

  MusicGenre get currentGenre => _currentGenre;
  double get volume => _baseVolume;
  bool get isPlaying => _isPlaying;
  bool get autoDuckingEnabled => _autoDuckingEnabled;

  static final AudioContext _musicAudioContext = AudioContext(
    android: const AudioContextAndroid(
      isSpeakerphoneOn: false,
      stayAwake: true,
      contentType: AndroidContentType.music,
      usageType: AndroidUsageType.media,
      audioFocus: AndroidAudioFocus.none,
    ),
    iOS: AudioContextIOS(
      category: AVAudioSessionCategory.playback,
      options: {
        AVAudioSessionOptions.mixWithOthers,
        AVAudioSessionOptions.duckOthers,
      },
    ),
  );

  Future<void> initialize() async {
    try {
      if (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS) {
        await _player.setAudioContext(_musicAudioContext);
      }
    } catch (e) {
      debugPrint('Error initializing AudioPlayer: $e');
    }
  }

  Future<void> playGenre(MusicGenre genre) async {
    _currentGenre = genre;
    if (genre.isMuted) {
      await stop();
      return;
    }

    try {
      // Hilangkan prefiks 'assets/' untuk audioplayers AssetSource
      final assetPath = genre.assetPath.startsWith('assets/')
          ? genre.assetPath.substring(7)
          : genre.assetPath;

      await _player.stop();
      if (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS) {
        await _player.setAudioContext(_musicAudioContext);
      }
      // PENTING: play terlebih dahulu sebelum setReleaseMode / setVolume untuk kompatibilitas Windows & Android
      await _player.play(AssetSource(assetPath));
      try {
        await _player.setReleaseMode(ReleaseMode.loop);
        final effectiveVolume = _isDucked ? (_baseVolume * 0.45) : _baseVolume;
        await _player.setVolume(effectiveVolume);
      } catch (_) {}
      _isPlaying = true;
    } catch (e) {
      debugPrint('Error playing background music: $e');
      _isPlaying = false;
    }
  }

  Future<void> pause() async {
    try {
      await _player.pause();
      _isPlaying = false;
    } catch (e) {
      debugPrint('Error pausing music: $e');
    }
  }

  Future<void> resume() async {
    if (_currentGenre.isMuted) return;
    try {
      await _player.resume();
      _isPlaying = true;
    } catch (e) {
      // Jika resume gagal, coba mainkan ulang genre
      await playGenre(_currentGenre);
    }
  }

  Future<void> stop() async {
    try {
      await _player.stop();
      _isPlaying = false;
    } catch (e) {
      debugPrint('Error stopping music: $e');
    }
  }

  Future<void> setVolume(double volume) async {
    _baseVolume = volume.clamp(0.0, 1.0);
    final effectiveVolume = _isDucked ? (_baseVolume * 0.45) : _baseVolume;
    try {
      await _player.setVolume(effectiveVolume);
    } catch (e) {
      debugPrint('Error setting music volume: $e');
    }
  }

  void setAutoDucking(bool enabled) {
    _autoDuckingEnabled = enabled;
  }

  Future<void> duck() async {
    if (!_autoDuckingEnabled || _isDucked || !_isPlaying) return;
    _isDucked = true;
    try {
      await _player.setVolume(_baseVolume * 0.45);
    } catch (e) {
      debugPrint('Error ducking music: $e');
    }
  }

  Future<void> unduck() async {
    if (!_isDucked) return;
    _isDucked = false;
    try {
      await _player.setVolume(_baseVolume);
    } catch (e) {
      debugPrint('Error unducking music: $e');
    }
  }

  void dispose() {
    _player.dispose();
  }
}
