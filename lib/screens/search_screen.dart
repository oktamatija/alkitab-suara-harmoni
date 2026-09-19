import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/verse.dart';
import '../providers/audio_player_provider.dart';
import '../providers/bible_provider.dart';
import '../theme/app_theme.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  List<Verse> _results = [];
  bool _hasSearched = false;

  void _performSearch(BibleProvider bible) {
    final query = _searchCtrl.text.trim();
    if (query.isEmpty) {
      setState(() {
        _results = [];
        _hasSearched = false;
      });
      return;
    }

    final found = bible.search(query);
    setState(() {
      _results = found;
      _hasSearched = true;
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bible = Provider.of<BibleProvider>(context);
    final audio = Provider.of<AudioPlayerProvider>(context, listen: false);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Pencarian Firman',
          style: GoogleFonts.outfit(fontWeight: FontWeight.w700),
        ),
      ),
      body: Column(
        children: [
          // Kotak input pencarian
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchCtrl,
              autofocus: true,
              style: GoogleFonts.outfit(color: isDark ? Colors.white : Colors.black87),
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _performSearch(bible),
              decoration: InputDecoration(
                hintText: 'Ketik kata atau kalimat (contoh: kasih, gembala)...',
                hintStyle: GoogleFonts.outfit(
                  color: isDark ? Colors.white38 : Colors.black38,
                  fontSize: 13,
                ),
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear_rounded),
                  onPressed: () {
                    _searchCtrl.clear();
                    _performSearch(bible);
                  },
                ),
                filled: true,
                fillColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Hasil Pencarian
          Expanded(
            child: !_hasSearched
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.manage_search_rounded, size: 54, color: isDark ? Colors.white24 : Colors.black26),
                        const SizedBox(height: 12),
                        Text(
                          'Cari ayat firman Tuhan di Alkitab',
                          style: GoogleFonts.outfit(color: isDark ? Colors.white54 : Colors.black54),
                        ),
                      ],
                    ),
                  )
                : _results.isEmpty
                    ? Center(
                        child: Text(
                          'Tidak ditemukan ayat yang cocok dengan kata kunci.',
                          style: GoogleFonts.outfit(color: isDark ? Colors.white54 : Colors.black54),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _results.length,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemBuilder: (ctx, index) {
                          final verse = _results[index];
                          final book = bible.storage.getBookById(verse.bookId);
                          final bookName = book?.name ?? 'Kitab ${verse.bookId}';

                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 5),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              title: Text(
                                '$bookName ${verse.chapter}:${verse.verse}',
                                style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                  color: AppTheme.goldAccent,
                                ),
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  verse.text,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.lora(
                                    fontSize: 13,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.play_circle_fill_rounded, size: 28),
                                color: AppTheme.goldAccent,
                                onPressed: () {
                                  bible.selectBook(verse.bookId);
                                  bible.selectChapter(verse.chapter);
                                  Navigator.pop(context);
                                  // Temukan index ayat
                                  final chapVerses = bible.currentVerses;
                                  final vIndex = chapVerses.indexWhere((v) => v.verse == verse.verse);
                                  audio.playChapter(chapVerses, startIndex: vIndex >= 0 ? vIndex : 0);
                                },
                              ),
                              onTap: () {
                                bible.selectBook(verse.bookId);
                                bible.selectChapter(verse.chapter);
                                Navigator.pop(context);
                              },
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
