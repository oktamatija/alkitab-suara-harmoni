import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/audio_player_provider.dart';
import '../providers/bible_provider.dart';
import '../theme/app_theme.dart';
import 'audio_mixer_sheet.dart';

class FloatingAudioPlayer extends StatefulWidget {
  const FloatingAudioPlayer({super.key});

  @override
  State<FloatingAudioPlayer> createState() => _FloatingAudioPlayerState();
}

class _FloatingAudioPlayerState extends State<FloatingAudioPlayer>
    with SingleTickerProviderStateMixin {
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final audio = Provider.of<AudioPlayerProvider>(context);
    final bible = Provider.of<BibleProvider>(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Tampilkan jika audio sedang memutar atau paused, atau ada ayat di pasal aktif
    final currentBook = bible.currentBook;
    final bookName = currentBook?.name ?? 'Alkitab';
    final currentVerse = audio.currentVerse;
    final verseRef = currentVerse != null
        ? (audio.isRangePlaybackActive
            ? '$bookName ${currentVerse.chapter}:${audio.activeStartVerse}-${audio.activeEndVerse} (Ayat ${currentVerse.verse})'
            : '$bookName ${currentVerse.chapter}:${currentVerse.verse}')
        : (audio.isRangePlaybackActive
            ? '$bookName ${bible.currentChapter}:${audio.activeStartVerse}-${audio.activeEndVerse}'
            : '$bookName ${bible.currentChapter}');

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF131D31).withOpacity(0.95)
            : Colors.white.withOpacity(0.97),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: audio.isPlaying
              ? AppTheme.goldAccent.withOpacity(0.5)
              : (isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.06)),
          width: audio.isPlaying ? 1.4 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            children: [
              // Visualizer / Play Icon
              GestureDetector(
                onTap: () => AudioMixerSheet.show(context),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: audio.activeGenre.accentColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: audio.isPlaying
                      ? AnimatedBuilder(
                          animation: _waveController,
                          builder: (context, child) {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildBar(14 * _waveController.value + 6, audio.activeGenre.accentColor),
                                const SizedBox(width: 3),
                                _buildBar(22 * (1 - _waveController.value) + 4, audio.activeGenre.accentColor),
                                const SizedBox(width: 3),
                                _buildBar(18 * _waveController.value + 8, audio.activeGenre.accentColor),
                              ],
                            );
                          },
                        )
                      : Icon(
                          audio.activeGenre.icon,
                          color: audio.activeGenre.accentColor,
                          size: 22,
                        ),
                ),
              ),
              const SizedBox(width: 12),

              // Reference & Genre Badge
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        if (audio.isPlaying && audio.currentVerseIndex >= 0) {
                          audio.onVerseChanged?.call(audio.currentVerseIndex);
                        } else {
                          AudioMixerSheet.show(context);
                        }
                      },
                      child: Row(
                        children: [
                          Flexible(
                            child: Text(
                              verseRef,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.outfit(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                          ),
                          if (audio.isPlaying) ...[
                            const SizedBox(width: 4),
                            Icon(
                              Icons.center_focus_strong_rounded,
                              size: 13,
                              color: AppTheme.goldAccent.withOpacity(0.8),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => AudioMixerSheet.show(context),
                          child: Row(
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: audio.activeGenre.accentColor,
                                ),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                audio.activeGenre.name,
                                style: GoogleFonts.outfit(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: audio.activeGenre.accentColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (audio.isRangePlaybackActive) ...[
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () => audio.clearVerseRange(),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                              decoration: BoxDecoration(
                                color: AppTheme.goldAccent.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '${audio.activeStartVerse}-${audio.activeEndVerse}',
                                    style: GoogleFonts.outfit(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.goldAccent,
                                    ),
                                  ),
                                  const SizedBox(width: 3),
                                  const Icon(
                                    Icons.close_rounded,
                                    size: 11,
                                    color: AppTheme.goldAccent,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // Tombol Navigasi Kontrol
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    iconSize: 22,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    icon: const Icon(Icons.skip_previous_rounded),
                    onPressed: () => audio.previousVerse(),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.goldAccent,
                          AppTheme.goldDeep,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.goldAccent.withOpacity(0.35),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: IconButton(
                      iconSize: 26,
                      color: Colors.black,
                      icon: Icon(
                        audio.isPlaying
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                      ),
                      onPressed: () {
                        if (audio.isPlaying) {
                          audio.pause();
                        } else if (audio.isPaused) {
                          audio.resume();
                        } else {
                          // Mulai putar sesuai rentang atau seluruh ayat pasal saat ini
                          if (audio.isRangePlaybackActive) {
                            audio.playVerseRange(
                              bible.currentVerses,
                              startVerse: audio.activeStartVerse!,
                              endVerse: audio.activeEndVerse!,
                            );
                          } else {
                            audio.playChapter(bible.currentVerses);
                          }
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    iconSize: 22,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    icon: const Icon(Icons.skip_next_rounded),
                    onPressed: () => audio.nextVerse(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBar(double height, Color color) {
    return Container(
      width: 3.2,
      height: height.clamp(4.0, 24.0),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
