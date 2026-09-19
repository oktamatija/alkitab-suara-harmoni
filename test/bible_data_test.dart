import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:alkitab_suara_harmoni/models/book.dart';
import 'package:alkitab_suara_harmoni/models/music_genre.dart';
import 'package:alkitab_suara_harmoni/models/verse.dart';
import 'package:alkitab_suara_harmoni/services/narration_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Validasi Buku Alkitab (66 Kitab)', () {
    final file = File('assets/data/books.json');
    expect(file.existsSync(), isTrue);

    final jsonStr = file.readAsStringSync();
    final list = json.decode(jsonStr) as List<dynamic>;
    expect(list.length, equals(66));

    final books = list.map((e) => Book.fromJson(e as Map<String, dynamic>)).toList();
    final pl = books.where((b) => b.isOldTestament).toList();
    final pb = books.where((b) => b.isNewTestament).toList();

    expect(pl.length, equals(39));
    expect(pb.length, equals(27));

    // Cek kitab pertama dan terakhir
    expect(books.first.name, equals('Kejadian'));
    expect(books.last.name, equals('Wahyu'));
  });

  test('Validasi Starter Bundle Ayat', () {
    final file = File('assets/data/starter_bundle.json');
    expect(file.existsSync(), isTrue);

    final jsonStr = file.readAsStringSync();
    final list = json.decode(jsonStr) as List<dynamic>;
    expect(list.isNotEmpty, isTrue);

    final firstVerse = Verse.fromJson(list.first as Map<String, dynamic>);
    expect(firstVerse.bookId, equals(1));
    expect(firstVerse.chapter, equals(1));
    expect(firstVerse.verse, equals(1));
    expect(firstVerse.text.isNotEmpty, isTrue);
  });

  test('Validasi Pilihan Genre Musik Pengiring', () {
    expect(MusicGenre.allGenres.length, equals(7));
    expect(MusicGenre.allGenres.any((g) => g.id == 'piano'), isTrue);
    expect(MusicGenre.allGenres.any((g) => g.id == 'acoustic'), isTrue);
    expect(MusicGenre.allGenres.any((g) => g.id == 'ambient'), isTrue);
    expect(MusicGenre.allGenres.any((g) => g.id == 'lofi'), isTrue);
    expect(MusicGenre.allGenres.any((g) => g.id == 'nature'), isTrue);
    expect(MusicGenre.allGenres.any((g) => g.id == 'orchestra'), isTrue);
    expect(MusicGenre.allGenres.any((g) => g.id == 'none'), isTrue);

    for (final genre in MusicGenre.allGenres) {
      if (!genre.isMuted) {
        final audioFile = File(genre.assetPath);
        expect(audioFile.existsSync(), isTrue, reason: 'File audio tidak ditemukan: ${genre.assetPath}');
      }
    }
  });

  test('Validasi Kalibrasi Pelafalan Allah pada NarrationService', () {
    // Verifikasi penyesuaian fonetik agar pelafalan TTS terdengar wajar 'Al-lah'
    expect(
      NarrationService.prepareNaturalText('Pada mulanya Allah menciptakan langit dan bumi.'),
      equals('Pada mulanya Al-lah menciptakan langit dan bumi.'),
    );
    expect(
      NarrationService.prepareNaturalText('TUHAN adalah Allahku dan Allah-Mu.'),
      equals('TUHAN adalah Al-lahku dan Al-lah-Mu.'),
    );
    expect(
      NarrationService.prepareNaturalText('ALLAH berfirman kepada Musa.'),
      equals('Al-lah berfirman kepada Musa.'),
    );
    expect(
      NarrationService.prepareNaturalText('Sebab Dialah Allah kita, dan kitalah umat gembalaan-Nya.'),
      equals('Sebab Dialah Al-lah kita, dan kitalah umat gembalaan-Nya.'),
    );
    expect(
      NarrationService.prepareNaturalText('Jangan ada padamu allah lain di hadapan-Ku.'),
      equals('Jangan ada padamu al-lah lain di hadapan-Ku.'),
    );
    expect(
      NarrationService.prepareNaturalText('Allah-Nya, Allahlah, Allahmulah, allah-allah'),
      equals('Al-lah-Nya, Al-lahlah, Al-lahmulah, al-lah-al-lah'),
    );
    // Pastikan kata lain yang mengandung akhiran -lah tidak terpengaruh
    expect(
      NarrationService.prepareNaturalText('Juallah segala milikmu dan berikanlah kepada orang miskin.'),
      equals('Juallah segala milikmu dan berikanlah kepada orang miskin.'),
    );
  });
}
