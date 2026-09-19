import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/music_genre.dart';
import '../providers/audio_player_provider.dart';
import '../services/narration_service.dart';
import '../theme/app_theme.dart';

class AudioMixerSheet extends StatelessWidget {
  const AudioMixerSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.90,
        maxWidth: 660,
      ),
      backgroundColor: Colors.transparent,
      builder: (ctx) => const AudioMixerSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final audio = Provider.of<AudioPlayerProvider>(context);

    return Center(
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0F172A) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 30,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 1. Header Tetap (Handle bar, Judul, Subtitle, Tombol Tutup)
            // Selalu berada di posisi atas yang aman, tidak pernah terpotong atau terdorong ke luar layar
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 16, 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 42,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white24 : Colors.black26,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.goldAccent.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.tune_rounded, color: AppTheme.goldAccent, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Harmoni Suara & Musik',
                              style: GoogleFonts.outfit(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            Text(
                              'Pilihan karakter suara narasi dan musik pengiring',
                              style: GoogleFonts.outfit(
                                fontSize: 12,
                                color: isDark ? Colors.white60 : Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        tooltip: 'Tutup',
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // 2. Area Konten yang Dapat Digulirkan Secara Mandiri
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Bagian 1: Pilihan Karakter Suara Narasi
                    Text(
                      'KARAKTER SUARA NARASI',
                      style: GoogleFonts.outfit(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.1,
                        color: isDark ? AppTheme.goldAccent : AppTheme.goldDeep,
                      ),
                    ),
                    const SizedBox(height: 10),

                    Row(
                      children: [
                        Expanded(
                          child: _buildVoiceOption(
                            context,
                            title: 'Suara Alami',
                            subtitle: 'Jernih & Manusiawi (Rekomendasi)',
                            icon: Icons.record_voice_over_rounded,
                            isSelected: audio.narrationEngine == NarrationEngineType.naturalVoice,
                            onTap: () => audio.setNarrationEngine(NarrationEngineType.naturalVoice),
                            isDark: isDark,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildVoiceOption(
                            context,
                            title: 'TTS Bawaan',
                            subtitle: 'Sistem Offline Perangkat',
                            icon: Icons.settings_voice_rounded,
                            isSelected: audio.narrationEngine == NarrationEngineType.systemTts,
                            onTap: () => audio.setNarrationEngine(NarrationEngineType.systemTts),
                            isDark: isDark,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 22),

                    // Bagian 2: Pilih Genre Musik Pengiring (Grid Responsif Lengkap, Tidak Pernah Terpotong)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'PILIH GENRE MUSIK PENGIRING',
                          style: GoogleFonts.outfit(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.1,
                            color: isDark ? AppTheme.goldAccent : AppTheme.goldDeep,
                          ),
                        ),
                        Text(
                          '7 Pilihan Tersedia',
                          style: GoogleFonts.outfit(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white38 : Colors.black38,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    LayoutBuilder(
                      builder: (context, constraints) {
                        final availableWidth = constraints.maxWidth;
                        // 3 kolom jika desktop / tablet, 2 kolom jika di layar ponsel
                        final int columns = availableWidth >= 500 ? 3 : 2;
                        const double spacing = 10;
                        final double itemWidth =
                            (availableWidth - (columns - 1) * spacing) / columns;

                        return Wrap(
                          spacing: spacing,
                          runSpacing: spacing,
                          children: MusicGenre.allGenres.map((genre) {
                            final isSelected = audio.activeGenre.id == genre.id;
                            return SizedBox(
                              width: itemWidth,
                              child: _buildGenreCard(
                                genre: genre,
                                isSelected: isSelected,
                                isDark: isDark,
                                onTap: () => audio.changeGenre(genre),
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),

                    const SizedBox(height: 22),

              // Bagian 3: Audio Mixer (Volume Sliders)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark ? Colors.white.withOpacity(0.07) : Colors.black.withOpacity(0.06),
                  ),
                ),
                child: Column(
                  children: [
                    // Slider 1: Volume Narasi Firman
                    Row(
                      children: [
                        Icon(Icons.record_voice_over_rounded,
                            size: 20, color: AppTheme.goldAccent),
                        const SizedBox(width: 10),
                        Text(
                          'Volume Narasi Ayat',
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${(audio.narrationVolume * 100).round()}%',
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.w700,
                            color: AppTheme.goldAccent,
                          ),
                        ),
                      ],
                    ),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: AppTheme.goldAccent,
                        thumbColor: AppTheme.goldAccent,
                        overlayColor: AppTheme.goldAccent.withOpacity(0.2),
                      ),
                      child: Slider(
                        value: audio.narrationVolume,
                        min: 0.0,
                        max: 1.0,
                        onChanged: (val) => audio.setNarrationVolume(val),
                      ),
                    ),

                    const Divider(height: 16),

                    // Slider 2: Volume Musik Pengiring
                    Row(
                      children: [
                        Icon(Icons.music_note_rounded,
                            size: 20, color: audio.activeGenre.accentColor),
                        const SizedBox(width: 10),
                        Text(
                          'Musik Pengiring (${audio.activeGenre.name})',
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${(audio.musicVolume * 100).round()}%',
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.w700,
                            color: audio.activeGenre.accentColor,
                          ),
                        ),
                      ],
                    ),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: audio.activeGenre.accentColor,
                        thumbColor: audio.activeGenre.accentColor,
                        overlayColor: audio.activeGenre.accentColor.withOpacity(0.2),
                      ),
                      child: Slider(
                        value: audio.musicVolume,
                        min: 0.0,
                        max: 1.0,
                        onChanged: (val) => audio.setMusicVolume(val),
                      ),
                    ),

                    const Divider(height: 16),

                    // Auto-Ducking Switch
                    SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      value: audio.autoDucking,
                      activeColor: AppTheme.goldAccent,
                      title: Text(
                        'Smart Auto-Ducking',
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      subtitle: Text(
                        'Musik otomatis melembut saat ayat dinarasikan',
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          color: isDark ? Colors.white54 : Colors.black45,
                        ),
                      ),
                      onChanged: (val) => audio.setAutoDucking(val),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Bagian 4: Kecepatan Narasi (Pacing Tenang & Meditatif)
              Text(
                'KECEPATAN PEMBACAAN AYAT',
                style: GoogleFonts.outfit(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                  color: isDark ? AppTheme.goldAccent : AppTheme.goldDeep,
                ),
              ),
              const SizedBox(height: 10),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _SpeedChip(
                    label: '0.75x Sangat Tenang (Doa)',
                    value: 0.75,
                    current: audio.speechRate,
                    onTap: () => audio.setSpeechRate(0.75),
                  ),
                  _SpeedChip(
                    label: '0.82x Khidmat (Rekomendasi)',
                    value: 0.82,
                    current: audio.speechRate,
                    onTap: () => audio.setSpeechRate(0.82),
                  ),
                  _SpeedChip(
                    label: '0.95x Normal',
                    value: 0.95,
                    current: audio.speechRate,
                    onTap: () => audio.setSpeechRate(0.95),
                  ),
                  _SpeedChip(
                    label: '1.10x Cepat',
                    value: 1.10,
                    current: audio.speechRate,
                    onTap: () => audio.setSpeechRate(1.10),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Bagian 5: Jeda Hening Antar-Ayat (Reflection Gap)
              Text(
                'JEDA REFLEKSI ANTAR-AYAT',
                style: GoogleFonts.outfit(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                  color: isDark ? AppTheme.goldAccent : AppTheme.goldDeep,
                ),
              ),
              const SizedBox(height: 10),

              Wrap(
                spacing: 8,
                children: [
                  _DelayChip(label: '0.5 Detik', ms: 500, current: audio.verseDelayMs, onTap: () => audio.setVerseDelay(500)),
                  _DelayChip(label: '1.0 Detik (Pas)', ms: 1000, current: audio.verseDelayMs, onTap: () => audio.setVerseDelay(1000)),
                  _DelayChip(label: '1.5 Detik', ms: 1500, current: audio.verseDelayMs, onTap: () => audio.setVerseDelay(1500)),
                ],
              ),
            ],
            ),
          ),
        ),
      ],
    ),
  ),
);
  }

  Widget _buildVoiceOption(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.goldAccent.withOpacity(0.18)
              : (isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppTheme.goldAccent : (isDark ? Colors.white10 : Colors.black12),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: isSelected
                  ? AppTheme.goldAccent
                  : (isDark ? Colors.white12 : Colors.black.withOpacity(0.06)),
              child: Icon(icon, size: 16, color: isSelected ? Colors.black : (isDark ? Colors.white : Colors.black87)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: isSelected ? AppTheme.goldAccent : (isDark ? Colors.white : Colors.black87),
                    ),
                  ),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.outfit(
                      fontSize: 10,
                      color: isDark ? Colors.white54 : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenreCard({
    required MusicGenre genre,
    required bool isSelected,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? genre.accentColor.withOpacity(0.18)
                : (isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected
                  ? genre.accentColor
                  : (isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.06)),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: genre.accentColor.withOpacity(0.22),
                child: Icon(genre.icon, size: 17, color: genre.accentColor),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      genre.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.outfit(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
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
              ),
              if (isSelected) ...[
                const SizedBox(width: 4),
                Icon(Icons.check_circle_rounded, size: 16, color: genre.accentColor),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SpeedChip extends StatelessWidget {
  final String label;
  final double value;
  final double current;
  final VoidCallback onTap;

  const _SpeedChip({
    required this.label,
    required this.value,
    required this.current,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = (current - value).abs() < 0.04;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.goldAccent
              : (Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF1E293B)
                  : const Color(0xFFE2E8F0)),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.goldAccent : Colors.transparent,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? Colors.black : null,
          ),
        ),
      ),
    );
  }
}

class _DelayChip extends StatelessWidget {
  final String label;
  final int ms;
  final int current;
  final VoidCallback onTap;

  const _DelayChip({
    required this.label,
    required this.ms,
    required this.current,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = current == ms;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.goldAccent
              : (Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF1E293B)
                  : const Color(0xFFE2E8F0)),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? Colors.black : null,
          ),
        ),
      ),
    );
  }
}
