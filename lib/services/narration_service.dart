import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

enum NarrationEngineType {
  naturalVoice, // Suara Alami Bahasa Indonesia (Jernih, Manusiawi & Ter-cache)
  systemTts,    // Suara TTS Bawaan Perangkat
}

class NarrationService {
  final FlutterTts _flutterTts = FlutterTts();
  final AudioPlayer _voicePlayer = AudioPlayer();

  bool _isInitialized = false;
  NarrationEngineType _engineType = NarrationEngineType.naturalVoice;

  VoidCallback? onCompletion;
  VoidCallback? onStart;
  Function(String error)? onError;

  double _volume = 1.0;
  // Default speed yang tenang dan khidmat (0.82x kecepatan natural)
  double _speechRate = 0.82;
  double _pitch = 1.0;
  Directory? _cacheDir;

  NarrationEngineType get engineType => _engineType;
  double get volume => _volume;
  double get speechRate => _speechRate;
  double get pitch => _pitch;

  static final AudioContext _narrationAudioContext = AudioContext(
    android: const AudioContextAndroid(
      isSpeakerphoneOn: false,
      stayAwake: true,
      contentType: AndroidContentType.speech,
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
    if (_isInitialized) return;

    try {
      // Siapkan direktori cache audio lokal untuk suara alami
      _cacheDir = await getTemporaryDirectory();

      // Daftarkan listener onPlayerComplete terlebih dahulu agar selalu aktif
      _voicePlayer.onPlayerComplete.listen((_) {
        onCompletion?.call();
      });

      // Konfigurasi audio context hanya untuk Android / iOS
      if (Platform.isAndroid || Platform.isIOS) {
        try {
          await _voicePlayer.setAudioContext(_narrationAudioContext);
        } catch (_) {}
      }

      // 2. Inisialisasi Flutter TTS sebagai mesin alternatif/offline
      try {
        await _flutterTts.setLanguage('id-ID');
        if (Platform.isIOS) {
          await _flutterTts.setIosAudioCategory(
            IosTextToSpeechAudioCategory.playback,
            [
              IosTextToSpeechAudioCategoryOptions.mixWithOthers,
              IosTextToSpeechAudioCategoryOptions.duckOthers,
            ],
          );
        }

        final ttsRate = (_speechRate * 0.40).clamp(0.20, 0.60);
        await _flutterTts.setSpeechRate(ttsRate);
        await _flutterTts.setVolume(_volume);
        await _flutterTts.setPitch(_pitch);

        // Cari suara berbahasa Indonesia terbaik di sistem jika ada
        try {
          final voices = await _flutterTts.getVoices;
          if (voices is List) {
            for (final v in voices) {
              if (v is Map) {
                final name = (v['name'] ?? '').toString().toLowerCase();
                final locale = (v['locale'] ?? '').toString().toLowerCase();
                if (locale.contains('id') || name.contains('indonesia') || name.contains('gadis') || name.contains('siti') || name.contains('zira') || name.contains('ardi')) {
                  await _flutterTts.setVoice({
                    'name': v['name'].toString(),
                    'locale': v['locale'].toString(),
                  });
                  break;
                }
              }
            }
          }
        } catch (_) {}

        _flutterTts.setStartHandler(() {
          onStart?.call();
        });

        _flutterTts.setCompletionHandler(() {
          onCompletion?.call();
        });

        _flutterTts.setErrorHandler((dynamic msg) {
          onError?.call(msg.toString());
        });
      } catch (ttsErr) {
        debugPrint('TTS setup warning: $ttsErr');
      }

      _isInitialized = true;
    } catch (e) {
      debugPrint('Error initializing NarrationService: $e');
    }
  }

  void setEngineType(NarrationEngineType type) {
    _engineType = type;
  }

  /// Format teks firman agar jeda pernapasan dan pelafalan terdengar alami
  static String prepareNaturalText(String text) {
    String cleaned = text.trim();
    // Hilangkan kurung kurawal atau nomor ayat sisa di awal
    cleaned = cleaned.replaceAll(RegExp(r'^\d+\s*'), '');

    // Kalibrasi pelafalan kata "Allah" agar terdengar alami "Al-lah" dalam Bahasa Indonesia,
    // bukan pelafalan logat asing/Arab ("Awloh").
    cleaned = cleaned.replaceAllMapped(
      RegExp(r'\b(Allah|ALLAH|allah)(ku|mu|nya|lah|mulah)?\b'),
      (match) {
        final base = match.group(1)!;
        final suffix = match.group(2) ?? '';
        final isLower = base == 'allah';
        final fixedBase = isLower ? 'al-lah' : 'Al-lah';
        return '$fixedBase$suffix';
      },
    );

    // Beri jeda halus setelah tanda koma dan titik koma
    cleaned = cleaned.replaceAll(',', ', ');
    cleaned = cleaned.replaceAll(';', '; ');
    cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ').trim();
    return cleaned;
  }

  Future<void> speak(String text, {int? verseId}) async {
    if (!_isInitialized) await initialize();

    final preparedText = prepareNaturalText(text);
    if (preparedText.isEmpty) {
      onCompletion?.call();
      return;
    }

    // Beri sinyal narasi mulai
    onStart?.call();

    if (_engineType == NarrationEngineType.naturalVoice) {
      final success = await _speakWithNaturalAudio(preparedText, verseId: verseId);
      if (!success) {
        // Fallback otomatis ke System TTS jika koneksi offline
        debugPrint('Natural Voice offline fallback -> System TTS');
        await _speakWithSystemTts(preparedText);
      }
    } else {
      await _speakWithSystemTts(preparedText);
    }
  }

  /// Membagi teks panjang menjadi beberapa potongan <= 160 karakter untuk TTS Google
  static List<String> _splitIntoChunks(String text, {int maxChunkLength = 160}) {
    if (text.length <= maxChunkLength) return [text];

    final chunks = <String>[];
    final words = text.split(' ');
    var currentChunk = '';

    for (final word in words) {
      if ((currentChunk.length + word.length + 1) <= maxChunkLength) {
        currentChunk = currentChunk.isEmpty ? word : '$currentChunk $word';
      } else {
        if (currentChunk.isNotEmpty) {
          chunks.add(currentChunk);
        }
        currentChunk = word;
      }
    }
    if (currentChunk.isNotEmpty) {
      chunks.add(currentChunk);
    }
    return chunks;
  }

  /// Memutar audio sintesis alami berbahasa Indonesia
  Future<bool> _speakWithNaturalAudio(String text, {int? verseId}) async {
    try {
      await _voicePlayer.stop();
      if (Platform.isAndroid || Platform.isIOS) {
        try {
          await _voicePlayer.setAudioContext(_narrationAudioContext);
        } catch (_) {}
      }

      // Gunakan hash teks untuk cache unik
      final textHash = text.hashCode.abs().toRadixString(16);
      final cacheFile = File('${_cacheDir?.path}/verse_${verseId ?? 0}_$textHash.mp3');

      Uint8List? audioBytes;

      if (await cacheFile.exists() && await cacheFile.length() > 500) {
        try {
          audioBytes = await cacheFile.readAsBytes();
        } catch (_) {}
      }

      if (audioBytes == null || audioBytes.length <= 500) {
        // Jika belum ada di cache, unduh audio MP3 (dukung teks panjang dengan pembagian chunk <= 160 karakter)
        final chunks = _splitIntoChunks(text, maxChunkLength: 160);
        final allBytes = <int>[];

        for (final chunk in chunks) {
          final encodedQuery = Uri.encodeComponent(chunk);
          final url = 'https://translate.google.com/translate_tts?ie=UTF-8&tl=id&client=tw-ob&q=$encodedQuery';

          final response = await http.get(
            Uri.parse(url),
            headers: {
              'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)',
            },
          ).timeout(const Duration(seconds: 10));

          if (response.statusCode == 200 && response.bodyBytes.length > 500) {
            allBytes.addAll(response.bodyBytes);
          } else {
            throw Exception('Gagal mengunduh bagian audio TTS (status: ${response.statusCode})');
          }
        }

        if (allBytes.length > 500) {
          audioBytes = Uint8List.fromList(allBytes);
          try {
            await cacheFile.writeAsBytes(audioBytes, flush: true);
          } catch (_) {}
        }
      }

      if (audioBytes != null && audioBytes.length > 500) {
        // Mainkan audio menggunakan BytesSource (sangat andal di semua platform termasuk Windows)
        // Jika BytesSource tidak didukung, gunakan DeviceFileSource
        try {
          await _voicePlayer.play(BytesSource(audioBytes));
        } catch (_) {
          await _voicePlayer.play(DeviceFileSource(cacheFile.path));
        }

        try {
          await _voicePlayer.setVolume(_volume);
          if (_speechRate != 1.0) {
            await _voicePlayer.setPlaybackRate(_speechRate);
          }
        } catch (_) {}
        return true;
      }
    } catch (e) {
      debugPrint('Natural audio stream error: $e');
    }
    return false;
  }

  /// Memutar menggunakan TTS sistem perangkat
  Future<void> _speakWithSystemTts(String text) async {
    try {
      await _flutterTts.stop();
      await _flutterTts.setVolume(_volume);
      final ttsRate = (_speechRate * 0.40).clamp(0.20, 0.60);
      await _flutterTts.setSpeechRate(ttsRate);
      // Gunakan focus: false agar tidak merebut fokus pemutar musik latar di Android
      await _flutterTts.speak(text, focus: false);
    } catch (e) {
      debugPrint('System TTS error: $e');
      onCompletion?.call();
    }
  }

  Future<void> pause() async {
    try {
      await _voicePlayer.pause();
      await _flutterTts.pause();
    } catch (e) {
      debugPrint('Error pausing narration: $e');
    }
  }

  Future<void> resume() async {
    try {
      if (_engineType == NarrationEngineType.naturalVoice) {
        await _voicePlayer.resume();
      }
    } catch (e) {
      debugPrint('Error resuming narration: $e');
    }
  }

  Future<void> stop() async {
    try {
      await _voicePlayer.stop();
      await _flutterTts.stop();
    } catch (e) {
      debugPrint('Error stopping narration: $e');
    }
  }

  Future<void> setVolume(double volume) async {
    _volume = volume.clamp(0.0, 1.0);
    await _voicePlayer.setVolume(_volume);
    await _flutterTts.setVolume(_volume);
  }

  Future<void> setSpeechRate(double rate) async {
    _speechRate = rate.clamp(0.5, 1.3);
    await _voicePlayer.setPlaybackRate(_speechRate);
    final ttsRate = (_speechRate * 0.40).clamp(0.20, 0.60);
    await _flutterTts.setSpeechRate(ttsRate);
  }

  Future<void> setPitch(double pitch) async {
    _pitch = pitch.clamp(0.5, 2.0);
    await _flutterTts.setPitch(_pitch);
  }

  Future<void> clearAudioCache() async {
    try {
      if (_cacheDir != null && await _cacheDir!.exists()) {
        final files = _cacheDir!.listSync();
        for (final f in files) {
          if (f is File && f.path.contains('verse_')) {
            await f.delete();
          }
        }
      }
    } catch (e) {
      debugPrint('Error clearing audio cache: $e');
    }
  }

  void dispose() {
    _voicePlayer.dispose();
  }
}
