import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:alkitab_suara_harmoni/models/verse.dart';
import 'package:alkitab_suara_harmoni/providers/audio_player_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Mock platform channel audioplayers agar unit test tidak memicu MissingPluginException
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
    const MethodChannel('xyz.luan/audioplayers.global'),
    (MethodCall methodCall) async => 1,
  );
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
    const MethodChannel('xyz.luan/audioplayers'),
    (MethodCall methodCall) async => 1,
  );
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
    const MethodChannel('flutter_tts'),
    (MethodCall methodCall) async => 1,
  );

  group('Uji Fitur Pemilihan Rentang Ayat & Penghentian Otomatis', () {
    late AudioPlayerProvider provider;
    late List<Verse> sampleVerses;

    setUp(() {
      provider = AudioPlayerProvider();
      sampleVerses = List.generate(
        30,
        (i) => Verse(
          id: i + 1,
          bookId: 43,
          chapter: 3,
          verse: i + 1,
          text: 'Teks ayat ke-${i + 1}',
        ),
      );
    });

    test('Default status awal tidak memiliki rentang ayat aktif', () {
      expect(provider.isRangePlaybackActive, isFalse);
      expect(provider.activeStartVerse, isNull);
      expect(provider.activeEndVerse, isNull);
    });

    test('playVerseRange mengaktifkan rentang ayat (misal ayat 1-10)', () async {
      // Uji setting rentang ayat 1-10
      // Catatan: Karena test unit headless tanpa audio device nyata,
      // kita verifikasi state provider dan batas logika navigasi.
      provider.playVerseRange(
        sampleVerses,
        startVerse: 1,
        endVerse: 10,
      );

      expect(provider.isRangePlaybackActive, isTrue);
      expect(provider.activeStartVerse, equals(1));
      expect(provider.activeEndVerse, equals(10));
      expect(provider.currentVerse?.verse, equals(1));
    });

    test('playVerseRange dengan rentang terbalik otomatis dirapikan', () async {
      provider.playVerseRange(
        sampleVerses,
        startVerse: 15,
        endVerse: 1,
      );

      expect(provider.activeStartVerse, equals(1));
      expect(provider.activeEndVerse, equals(15));
    });

    test('clearVerseRange menonaktifkan rentang ayat aktif', () {
      provider.playVerseRange(
        sampleVerses,
        startVerse: 1,
        endVerse: 10,
      );
      expect(provider.isRangePlaybackActive, isTrue);

      provider.clearVerseRange();
      expect(provider.isRangePlaybackActive, isFalse);
      expect(provider.activeStartVerse, isNull);
      expect(provider.activeEndVerse, isNull);
    });

    test('playChapter otomatis mereset rentang ayat agar memutar satu pasal penuh', () async {
      provider.playVerseRange(
        sampleVerses,
        startVerse: 1,
        endVerse: 10,
      );
      expect(provider.isRangePlaybackActive, isTrue);

      provider.playChapter(sampleVerses);
      expect(provider.isRangePlaybackActive, isFalse);
      expect(provider.activeStartVerse, isNull);
      expect(provider.activeEndVerse, isNull);
    });

    test('Navigasi nextVerse tidak boleh melebihi activeEndVerse saat rentang aktif', () async {
      provider.playVerseRange(
        sampleVerses,
        startVerse: 1,
        endVerse: 5,
      );

      // Maju ayat sampai batas 5
      for (int i = 0; i < 10; i++) {
        await provider.nextVerse();
      }

      // Harus tertahan di ayat ke-5 dan tidak boleh melebihi endVerse
      expect(provider.currentVerse?.verse, equals(5));
    });

    test('Navigasi previousVerse tidak boleh mendahului activeStartVerse', () async {
      provider.playVerseRange(
        sampleVerses,
        startVerse: 5,
        endVerse: 10,
      );

      expect(provider.currentVerse?.verse, equals(5));

      // Coba mundur sebelum ayat 5
      await provider.previousVerse();
      await provider.previousVerse();

      // Harus tetap di ayat 5
      expect(provider.currentVerse?.verse, equals(5));
    });

    test('jumpToVerse menolak index di luar batas rentang', () async {
      provider.playVerseRange(
        sampleVerses,
        startVerse: 5,
        endVerse: 10,
      );

      // Coba loncat ke ayat 2 (di luar rentang awal 5)
      await provider.jumpToVerse(1); // index 1 = ayat 2
      expect(provider.currentVerse?.verse, equals(5)); // tidak berubah

      // Coba loncat ke ayat 15 (di luar rentang akhir 10)
      await provider.jumpToVerse(14); // index 14 = ayat 15
      expect(provider.currentVerse?.verse, equals(5)); // tidak berubah

      // Loncat ke ayat 8 (di dalam rentang 5-10)
      await provider.jumpToVerse(7); // index 7 = ayat 8
      expect(provider.currentVerse?.verse, equals(8));
    });
  });
}
