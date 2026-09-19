import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/audio_player_provider.dart';
import '../providers/bible_provider.dart';
import '../theme/app_theme.dart';

class BookmarksScreen extends StatelessWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bible = Provider.of<BibleProvider>(context);
    final audio = Provider.of<AudioPlayerProvider>(context, listen: false);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bookmarked = bible.getBookmarkedVerses();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Ayat Tersimpan (Favorit)',
          style: GoogleFonts.outfit(fontWeight: FontWeight.w700),
        ),
      ),
      body: bookmarked.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bookmark_border_rounded, size: 54, color: isDark ? Colors.white24 : Colors.black26),
                  const SizedBox(height: 12),
                  Text(
                    'Belum ada ayat yang disimpan.',
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      color: isDark ? Colors.white54 : Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Sentuh ikon bookmark pada ayat untuk menyimpannya di sini.',
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      color: isDark ? Colors.white38 : Colors.black38,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: bookmarked.length,
              padding: const EdgeInsets.all(16),
              itemBuilder: (ctx, index) {
                final verse = bookmarked[index];
                final book = bible.storage.getBookById(verse.bookId);
                final bookName = book?.name ?? 'Kitab ${verse.bookId}';

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 5),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(14),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '$bookName ${verse.chapter}:${verse.verse}',
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.w700,
                            color: AppTheme.goldAccent,
                            fontSize: 15,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.bookmark_remove_rounded, color: Colors.redAccent, size: 20),
                          onPressed: () {
                            bible.toggleBookmark(verse);
                          },
                        ),
                      ],
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        verse.text,
                        style: GoogleFonts.lora(
                          fontSize: 14,
                          height: 1.6,
                        ),
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.play_circle_fill_rounded, size: 30),
                      color: AppTheme.goldAccent,
                      onPressed: () {
                        bible.selectBook(verse.bookId);
                        bible.selectChapter(verse.chapter);
                        Navigator.pop(context);
                        final chapVerses = bible.currentVerses;
                        final vIndex = chapVerses.indexWhere((v) => v.verse == verse.verse);
                        audio.playChapter(chapVerses, startIndex: vIndex >= 0 ? vIndex : 0);
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}
