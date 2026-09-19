import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/audio_player_provider.dart';
import '../providers/bible_provider.dart';
import '../providers/theme_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/audio_mixer_sheet.dart';
import '../widgets/book_picker_sheet.dart';
import '../widgets/floating_audio_player.dart';
import '../widgets/verse_card.dart';
import '../widgets/verse_range_picker_sheet.dart';
import 'download_center_screen.dart';
import 'search_screen.dart';

class BibleReaderScreen extends StatefulWidget {
  const BibleReaderScreen({super.key});

  @override
  State<BibleReaderScreen> createState() => _BibleReaderScreenState();
}

class _BibleReaderScreenState extends State<BibleReaderScreen> {
  final ScrollController _scrollController = ScrollController();
  final Map<int, GlobalKey> _verseKeys = {};
  int _lastBookId = -1;
  int _lastChapter = -1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final audio = Provider.of<AudioPlayerProvider>(context, listen: false);
      final bible = Provider.of<BibleProvider>(context, listen: false);

      audio.onVerseChanged = (index) {
        _scrollToVerse(index);
      };

      audio.onChapterFinished = () {
        // Otomatis tawarkan lanjut ke pasal berikutnya
        final hasNext = bible.nextChapter();
        if (hasNext) {
          audio.playChapter(bible.currentVerses);
        }
      };

      // Jika audio sedang aktif diputar saat layar pembaca terbuka, segera pusatkan ke ayat aktif
      if (audio.isPlaying && audio.currentVerseIndex >= 0) {
        _scrollToVerse(audio.currentVerseIndex, immediate: true);
      }
    });
  }

  GlobalKey _getVerseKey(int index) {
    return _verseKeys.putIfAbsent(index, () => GlobalKey());
  }

  /// Menggulung tampilan pembaca agar ayat yang sedang dinarasikan / disorot
  /// selalu berada tepat di tengah (center) layar pembaca
  void _scrollToVerse(int index, {bool immediate = false}) {
    if (!mounted) return;

    void executeScroll() {
      if (!mounted || !_scrollController.hasClients) return;

      final key = _verseKeys[index];
      final targetContext = key?.currentContext;

      if (targetContext != null) {
        // alignment: 0.45 menempatkan ayat tepat di tengah area baca vertikal
        // (memperhitungkan keberadaan floating audio player di bagian bawah layar)
        Scrollable.ensureVisible(
          targetContext,
          alignment: 0.45,
          duration: immediate ? Duration.zero : const Duration(milliseconds: 550),
          curve: Curves.easeInOutCubic,
        );
      } else {
        // Fallback perhitungan matematis yang menempatkan ayat di tengah
        final viewportHeight = _scrollController.position.viewportDimension;
        const estimatedVerseHeight = 70.0;
        final estimatedTop = index * estimatedVerseHeight;
        final targetOffset = (estimatedTop + (estimatedVerseHeight / 2) - (viewportHeight * 0.45))
            .clamp(0.0, _scrollController.position.maxScrollExtent);

        if (immediate) {
          _scrollController.jumpTo(targetOffset);
        } else {
          _scrollController.animateTo(
            targetOffset,
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOutCubic,
          );
        }

        // Jalankan koreksi presisi setelah frame berikut selesai layout
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted || !_scrollController.hasClients) return;
          final retryContext = _verseKeys[index]?.currentContext;
          if (retryContext != null) {
            Scrollable.ensureVisible(
              retryContext,
              alignment: 0.45,
              duration: immediate ? Duration.zero : const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
            );
          }
        });
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((_) => executeScroll());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bible = Provider.of<BibleProvider>(context);
    final audio = Provider.of<AudioPlayerProvider>(context);
    final themeProv = Provider.of<ThemeProvider>(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final currentBook = bible.currentBook;
    final bookName = currentBook?.name ?? 'Alkitab';
    final chapter = bible.currentChapter;
    final verses = bible.currentVerses;
    final isAvailable = currentBook != null && bible.storage.isBookAvailable(currentBook.id);

    // Reset koleksi kunci ayat jika berpindah kitab atau pasal
    if (currentBook?.id != _lastBookId || chapter != _lastChapter) {
      _lastBookId = currentBook?.id ?? -1;
      _lastChapter = chapter;
      _verseKeys.clear();
    }

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: GestureDetector(
          onTap: () => BookPickerSheet.show(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? Colors.white12 : Colors.black12,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  audio.isRangePlaybackActive
                      ? '$bookName $chapter:${audio.activeStartVerse}-${audio.activeEndVerse}'
                      : '$bookName $chapter',
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(width: 6),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 20,
                  color: AppTheme.goldAccent,
                ),
              ],
            ),
          ),
        ),
        actions: [
          // Tombol Pilih Rentang Ayat (Ayat 1-10, 1-15, dll)
          IconButton(
            tooltip: 'Pilih Rentang Ayat (1-10, 1-15)',
            icon: Badge(
              isLabelVisible: audio.isRangePlaybackActive,
              label: Text(
                '${audio.activeStartVerse}-${audio.activeEndVerse}',
                style: GoogleFonts.outfit(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
              ),
              backgroundColor: AppTheme.goldAccent,
              child: Icon(
                Icons.linear_scale_rounded,
                color: audio.isRangePlaybackActive ? AppTheme.goldAccent : null,
              ),
            ),
            onPressed: () {
              VerseRangePickerSheet.show(
                context,
                onScrollToVerse: (vNum) {
                  final idx = verses.indexWhere((v) => v.verse == vNum);
                  if (idx >= 0) _scrollToVerse(idx);
                },
              );
            },
          ),

          // Audio Mixer Button
          IconButton(
            tooltip: 'Mixer Suara & Musik',
            icon: Icon(Icons.tune_rounded, color: audio.activeGenre.accentColor),
            onPressed: () => AudioMixerSheet.show(context),
          ),

          // Pengatur Ukuran Font & Tema
          IconButton(
            tooltip: 'Tampilan & Huruf',
            icon: const Icon(Icons.format_size_rounded),
            onPressed: () => _showDisplaySettings(context, themeProv),
          ),

          // Pencarian Firman
          IconButton(
            tooltip: 'Cari Ayat',
            icon: const Icon(Icons.search_rounded),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SearchScreen()),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Konten Utama Ayat
          if (!isAvailable)
            _buildDownloadPrompt(context, bible, currentBook)
          else if (verses.isEmpty)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text('Memuat ayat firman...', style: GoogleFonts.outfit()),
                ],
              ),
            )
          else
            Column(
              children: [
                // Banner Indikator Rentang Ayat Aktif
                if (audio.isRangePlaybackActive) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    color: AppTheme.goldAccent.withOpacity(isDark ? 0.15 : 0.2),
                    child: Row(
                      children: [
                        Icon(
                          Icons.linear_scale_rounded,
                          size: 18,
                          color: isDark ? AppTheme.goldAccent : AppTheme.goldDeep,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Rentang aktif: Ayat ${audio.activeStartVerse} - ${audio.activeEndVerse} (Berhenti otomatis setelah ayat ${audio.activeEndVerse})',
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            VerseRangePickerSheet.show(
                              context,
                              onScrollToVerse: (vNum) {
                                final idx = verses.indexWhere((v) => v.verse == vNum);
                                if (idx >= 0) _scrollToVerse(idx);
                              },
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            child: Text(
                              'Ubah',
                              style: GoogleFonts.outfit(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: isDark ? AppTheme.goldAccent : AppTheme.goldDeep,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () => audio.clearVerseRange(),
                          child: Icon(
                            Icons.close_rounded,
                            size: 18,
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // List Ayat
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    cacheExtent: 20000, // Menjaga elemen seluruh ayat tetap aktif di pohon render
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 160), // Ruang leluasa agar ayat terakhir pun bisa berada di tengah
                    itemCount: verses.length + 1, // +1 untuk footer navigasi pasal
                    itemBuilder: (ctx, index) {
                      if (index == verses.length) {
                        return _buildChapterNavigationFooter(context, bible, audio);
                      }

                      final verse = verses[index];
                      final isActive = audio.isPlaying && audio.currentVerseIndex == index;
                      final isInRange = audio.isRangePlaybackActive &&
                          verse.verse >= audio.activeStartVerse! &&
                          verse.verse <= audio.activeEndVerse!;

                      return KeyedSubtree(
                        key: _getVerseKey(index),
                        child: VerseCard(
                          verse: verse,
                          isActive: isActive,
                          isInRange: isInRange,
                          fontSize: themeProv.fontSize,
                          onTap: () {
                            if (audio.isRangePlaybackActive) {
                              // Jika ketuk ayat di dalam rentang, mulai dari ayat tersebut sampai batas akhir rentang
                              if (verse.verse >= audio.activeStartVerse! && verse.verse <= audio.activeEndVerse!) {
                                audio.playVerseRange(
                                  verses,
                                  startVerse: verse.verse,
                                  endVerse: audio.activeEndVerse!,
                                );
                              } else {
                                // Jika di luar rentang, putar pasal normal
                                audio.playChapter(verses, startIndex: index);
                              }
                            } else {
                              audio.playChapter(verses, startIndex: index);
                            }
                            _scrollToVerse(index);
                          },
                          onBookmarkToggle: () {
                            bible.toggleBookmark(verse);
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),

          // Floating Player di bawah
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: FloatingAudioPlayer(),
          ),
        ],
      ),
    );
  }

  Widget _buildDownloadPrompt(BuildContext context, BibleProvider bible, dynamic book) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.goldAccent.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.cloud_download_rounded, size: 48, color: AppTheme.goldAccent),
            ),
            const SizedBox(height: 20),
            Text(
              '${book?.name ?? "Kitab ini"} Belum Tersedia Offline',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              'Unduh Alkitab Bahasa Indonesia secara lengkap (66 Kitab) untuk membaca dan mendengarkan seluruh firman Tuhan secara bebas.',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(fontSize: 13, color: Colors.grey[400]),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.goldAccent,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              icon: const Icon(Icons.download_rounded),
              label: Text(
                'Buka Pusat Unduhan',
                style: GoogleFonts.outfit(fontWeight: FontWeight.w700),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const DownloadCenterScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChapterNavigationFooter(
      BuildContext context, BibleProvider bible, AudioPlayerProvider audio) {
    final book = bible.currentBook;
    final maxChap = book?.maxChapter ?? 1;
    final currentChap = bible.currentChapter;

    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.arrow_back_rounded, size: 18),
            label: Text(
              currentChap > 1 ? 'Pasal ${currentChap - 1}' : 'Kitab Sebelumnya',
              style: GoogleFonts.outfit(fontSize: 13),
            ),
            onPressed: () {
              final changed = bible.previousChapter();
              if (changed && audio.isPlaying) {
                audio.playChapter(bible.currentVerses);
              }
            },
          ),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.arrow_forward_rounded, size: 18),
            label: Text(
              currentChap < maxChap ? 'Pasal ${currentChap + 1}' : 'Kitab Berikutnya',
              style: GoogleFonts.outfit(fontSize: 13),
            ),
            onPressed: () {
              final changed = bible.nextChapter();
              if (changed && audio.isPlaying) {
                audio.playChapter(bible.currentVerses);
              }
            },
          ),
        ],
      ),
    );
  }

  void _showDisplaySettings(BuildContext context, ThemeProvider themeProv) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0F172A) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.black26,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                'Pengaturan Tampilan Pembacaan',
                style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 20),

              // Pilihan Tema Warna
              Text('TEMA WARNA',
                  style: GoogleFonts.outfit(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.goldAccent)),
              const SizedBox(height: 10),
              Row(
                children: [
                  _buildThemeOption(
                    label: 'Gelap Khidmat',
                    mode: AppThemeMode.darkWorship,
                    color: const Color(0xFF0B1120),
                    selected: themeProv.themeMode == AppThemeMode.darkWorship,
                    onTap: () => themeProv.setThemeMode(AppThemeMode.darkWorship),
                  ),
                  const SizedBox(width: 8),
                  _buildThemeOption(
                    label: 'Kertas Sepia',
                    mode: AppThemeMode.warmSepia,
                    color: const Color(0xFFFBF8F1),
                    textColor: Colors.black87,
                    selected: themeProv.themeMode == AppThemeMode.warmSepia,
                    onTap: () => themeProv.setThemeMode(AppThemeMode.warmSepia),
                  ),
                  const SizedBox(width: 8),
                  _buildThemeOption(
                    label: 'Terang',
                    mode: AppThemeMode.cleanWhite,
                    color: Colors.white,
                    textColor: Colors.black87,
                    selected: themeProv.themeMode == AppThemeMode.cleanWhite,
                    onTap: () => themeProv.setThemeMode(AppThemeMode.cleanWhite),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Pengatur Ukuran Huruf
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('UKURAN TEKS AYAT',
                      style: GoogleFonts.outfit(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.goldAccent)),
                  Text('${themeProv.fontSize.round()} pt',
                      style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
                ],
              ),
              Slider(
                value: themeProv.fontSize,
                min: 15.0,
                max: 26.0,
                divisions: 11,
                activeColor: AppTheme.goldAccent,
                onChanged: (val) => themeProv.setFontSize(val),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThemeOption({
    required String label,
    required AppThemeMode mode,
    required Color color,
    Color textColor = Colors.white,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? AppTheme.goldAccent : Colors.grey.withOpacity(0.3),
              width: selected ? 2 : 1,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 12,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: textColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
