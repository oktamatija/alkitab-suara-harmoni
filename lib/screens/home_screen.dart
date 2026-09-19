import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/music_genre.dart';
import '../providers/audio_player_provider.dart';
import '../providers/bible_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/audio_mixer_sheet.dart';
import '../widgets/floating_audio_player.dart';
import 'bible_reader_screen.dart';
import 'bookmarks_screen.dart';
import 'download_center_screen.dart';
import 'search_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bible = Provider.of<BibleProvider>(context);
    final audio = Provider.of<AudioPlayerProvider>(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final currentBook = bible.currentBook;
    final bookName = currentBook?.name ?? 'Yohanes';

    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // Sliver App Bar
              SliverAppBar(
                expandedHeight: 110.0,
                floating: false,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
                  title: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppTheme.goldAccent.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.menu_book_rounded,
                            size: 18, color: AppTheme.goldAccent),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Alkitab Harmoni',
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.bookmark_rounded),
                    tooltip: 'Ayat Tersimpan',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const BookmarksScreen()),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.search_rounded),
                    tooltip: 'Cari Firman',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SearchScreen()),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                ],
              ),

              // Konten Beranda
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Kartu Ayat Emas Hari Ini
                      _buildDailyVerseCard(context, bible, audio, isDark),
                      const SizedBox(height: 20),

                      // 2. Banner Status Unduhan Alkitab
                      _buildDownloadBanner(context, bible, isDark),
                      const SizedBox(height: 24),

                      // 3. Pilihan Genre Musik Pengiring
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'GENRE MUSIK PENGIRING',
                            style: GoogleFonts.outfit(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.1,
                              color: isDark ? AppTheme.goldAccent : AppTheme.goldDeep,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => AudioMixerSheet.show(context),
                            child: Text(
                              'Buka Mixer',
                              style: GoogleFonts.outfit(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.goldAccent,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildMusicGenreSelector(context, audio, isDark),
                      const SizedBox(height: 24),

                      // 4. Menu Cepat Navigasi
                      Text(
                        'JELAJAHI FIRMAN',
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.1,
                          color: isDark ? AppTheme.goldAccent : AppTheme.goldDeep,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildNavigationGrid(context, bible, bookName, isDark),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Floating Player di bagian bawah
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

  Widget _buildDailyVerseCard(
      BuildContext context, BibleProvider bible, AudioPlayerProvider audio, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
                  const Color(0xFF1E293B),
                  const Color(0xFF0F172A),
                ]
              : [
                  const Color(0xFFFFFBEB),
                  const Color(0xFFFDE68A),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppTheme.goldAccent.withOpacity(0.35),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.goldAccent.withOpacity(0.14),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.goldAccent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'AYAT INSPIRASI HARI INI',
                  style: GoogleFonts.outfit(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                  ),
                ),
              ),
              const Spacer(),
              Icon(Icons.auto_awesome_rounded, color: AppTheme.goldAccent, size: 20),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            '"Karena begitu besar kasih Allah akan dunia ini, sehingga Ia telah mengaruniakan Anak-Nya yang tunggal, supaya setiap orang yang percaya kepada-Nya tidak binasa, melainkan beroleh hidup yang kekal."',
            style: GoogleFonts.lora(
              fontSize: 15,
              height: 1.7,
              fontStyle: FontStyle.italic,
              color: isDark ? const Color(0xFFF8FAFC) : const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Yohanes 3:16',
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.goldAccent,
                ),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.goldAccent,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.play_arrow_rounded, size: 18),
                label: Text(
                  'Dengar Firman',
                  style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w700),
                ),
                onPressed: () {
                  // Pilih Yohanes pasal 3 dan mulai putar
                  bible.selectBook(43);
                  bible.selectChapter(3);
                  final verses = bible.currentVerses;
                  final v16Index = verses.indexWhere((v) => v.verse == 16);
                  audio.playChapter(verses, startIndex: v16Index >= 0 ? v16Index : 0);

                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const BibleReaderScreen()),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDownloadBanner(BuildContext context, BibleProvider bible, bool isDark) {
    final isFull = bible.isFullBibleDownloaded;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const DownloadCenterScreen()),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isFull
                ? Colors.green.withOpacity(0.4)
                : AppTheme.goldAccent.withOpacity(0.3),
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: isFull
                  ? Colors.green.withOpacity(0.2)
                  : AppTheme.goldAccent.withOpacity(0.2),
              child: Icon(
                isFull ? Icons.cloud_done_rounded : Icons.cloud_download_rounded,
                color: isFull ? Colors.green : AppTheme.goldAccent,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isFull
                        ? 'Alkitab Lengkap Tersimpan (Offline 100%)'
                        : 'Pusat Unduhan Alkitab',
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    isFull
                        ? '66 Kitab & 31.102 Ayat siap dinikmati tanpa internet'
                        : 'Unduh seluruh 66 kitab bahasa Indonesia offline',
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      color: isDark ? Colors.white60 : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, size: 22),
          ],
        ),
      ),
    );
  }

  Widget _buildMusicGenreSelector(
      BuildContext context, AudioPlayerProvider audio, bool isDark) {
    return SizedBox(
      height: 105,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: MusicGenre.allGenres.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (ctx, index) {
          final genre = MusicGenre.allGenres[index];
          final isSelected = audio.activeGenre.id == genre.id;

          return GestureDetector(
            onTap: () {
              audio.changeGenre(genre);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 120,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected
                    ? genre.accentColor.withOpacity(0.2)
                    : (isDark ? const Color(0xFF1E293B) : Colors.white),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected
                      ? genre.accentColor
                      : (isDark ? Colors.white10 : Colors.black12),
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CircleAvatar(
                    radius: 15,
                    backgroundColor: genre.accentColor.withOpacity(0.2),
                    child: Icon(genre.icon, size: 16, color: genre.accentColor),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        genre.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        genre.subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.outfit(
                          fontSize: 10,
                          color: isDark ? Colors.white54 : Colors.black45,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNavigationGrid(
      BuildContext context, BibleProvider bible, String bookName, bool isDark) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.4,
      children: [
        _buildNavCard(
          title: 'Lanjutkan Membaca',
          subtitle: '$bookName ${bible.currentChapter}',
          icon: Icons.menu_book_rounded,
          color: AppTheme.goldAccent,
          isDark: isDark,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const BibleReaderScreen()),
            );
          },
        ),
        _buildNavCard(
          title: 'Pusat Unduhan',
          subtitle: '66 Kitab Offline',
          icon: Icons.download_rounded,
          color: Colors.tealAccent[400]!,
          isDark: isDark,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const DownloadCenterScreen()),
            );
          },
        ),
        _buildNavCard(
          title: 'Ayat Tersimpan',
          subtitle: '${bible.bookmarkedIds.length} Ayat Favorit',
          icon: Icons.bookmark_rounded,
          color: Colors.pinkAccent,
          isDark: isDark,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const BookmarksScreen()),
            );
          },
        ),
        _buildNavCard(
          title: 'Harmoni & Mixer',
          subtitle: 'Atur Suara & Musik',
          icon: Icons.tune_rounded,
          color: AppTheme.skyAccent,
          isDark: isDark,
          onTap: () => AudioMixerSheet.show(context),
        ),
      ],
    );
  }

  Widget _buildNavCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.06),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: color.withOpacity(0.2),
              child: Icon(icon, size: 18, color: color),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    color: isDark ? Colors.white60 : Colors.black54,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
