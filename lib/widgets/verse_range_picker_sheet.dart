import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/audio_player_provider.dart';
import '../providers/bible_provider.dart';
import '../theme/app_theme.dart';

class VerseRangePickerSheet extends StatefulWidget {
  final VoidCallback? onApply;
  final Function(int startVerse)? onScrollToVerse;

  const VerseRangePickerSheet({
    super.key,
    this.onApply,
    this.onScrollToVerse,
  });

  static void show(
    BuildContext context, {
    VoidCallback? onApply,
    Function(int startVerse)? onScrollToVerse,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.90,
        maxWidth: 620,
      ),
      backgroundColor: Colors.transparent,
      builder: (ctx) => VerseRangePickerSheet(
        onApply: onApply,
        onScrollToVerse: onScrollToVerse,
      ),
    );
  }

  @override
  State<VerseRangePickerSheet> createState() => _VerseRangePickerSheetState();
}

class _VerseRangePickerSheetState extends State<VerseRangePickerSheet> {
  late int _startVerse;
  late int _endVerse;
  late int _maxVerse;

  @override
  void initState() {
    super.initState();
    final audio = Provider.of<AudioPlayerProvider>(context, listen: false);
    final bible = Provider.of<BibleProvider>(context, listen: false);
    final verses = bible.currentVerses;

    _maxVerse = verses.isNotEmpty ? verses.map((v) => v.verse).reduce((a, b) => a > b ? a : b) : 1;

    if (audio.isRangePlaybackActive) {
      _startVerse = (audio.activeStartVerse ?? 1).clamp(1, _maxVerse);
      _endVerse = (audio.activeEndVerse ?? _maxVerse).clamp(_startVerse, _maxVerse);
    } else {
      // Default awal 1 sampai 10 jika ada minimal 10 ayat, atau seluruh ayat
      _startVerse = 1;
      _endVerse = _maxVerse >= 10 ? 10 : _maxVerse;
    }
  }

  void _applyPreset(int start, int end) {
    setState(() {
      _startVerse = start.clamp(1, _maxVerse);
      _endVerse = end.clamp(_startVerse, _maxVerse);
    });
  }

  @override
  Widget build(BuildContext context) {
    final bible = Provider.of<BibleProvider>(context);
    final audio = Provider.of<AudioPlayerProvider>(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final currentBook = bible.currentBook;
    final bookName = currentBook?.name ?? 'Alkitab';
    final chapter = bible.currentChapter;
    final verses = bible.currentVerses;
    final totalSelected = (_endVerse - _startVerse + 1).clamp(1, _maxVerse);

    return Center(
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0F172A) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 25,
              offset: const Offset(0, -5),
            ),
          ],
        ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle Bar
            Center(
              child: Container(
                width: 44,
                height: 4,
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black26,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.goldAccent.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.tune_rounded,
                    color: AppTheme.goldAccent,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pilih Rentang Ayat',
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      Text(
                        '$bookName Pasal $chapter • Total $_maxVerse Ayat',
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          color: isDark ? Colors.white60 : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Preset Cepat (1-10, 1-15, 1-20, Semua Ayat)
            Text(
              'PILIHAN CEPAT',
              style: GoogleFonts.outfit(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                color: AppTheme.goldAccent,
              ),
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildPresetChip('Ayat 1 - 10', 1, 10),
                  const SizedBox(width: 8),
                  _buildPresetChip('Ayat 1 - 15', 1, 15),
                  const SizedBox(width: 8),
                  _buildPresetChip('Ayat 1 - 20', 1, 20),
                  const SizedBox(width: 8),
                  if (_maxVerse > 20) ...[
                    _buildPresetChip('Ayat 1 - 25', 1, 25),
                    const SizedBox(width: 8),
                  ],
                  _buildPresetChip('Semua Ayat (1 - $_maxVerse)', 1, _maxVerse),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Kustom Pemilih Ayat Awal & Akhir
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? Colors.white10 : Colors.black12,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      // Ayat Mulai
                      Expanded(
                        child: _buildNumberCounter(
                          label: 'Ayat Awal',
                          value: _startVerse,
                          min: 1,
                          max: _endVerse,
                          onChanged: (val) {
                            setState(() {
                              _startVerse = val;
                              if (_endVerse < _startVerse) _endVerse = _startVerse;
                            });
                          },
                          isDark: isDark,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Icon(
                          Icons.arrow_forward_rounded,
                          color: isDark ? Colors.white38 : Colors.black38,
                          size: 20,
                        ),
                      ),
                      // Ayat Akhir
                      Expanded(
                        child: _buildNumberCounter(
                          label: 'Ayat Akhir',
                          value: _endVerse,
                          min: _startVerse,
                          max: _maxVerse,
                          onChanged: (val) {
                            setState(() {
                              _endVerse = val;
                              if (_startVerse > _endVerse) _startVerse = _endVerse;
                            });
                          },
                          isDark: isDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Keterangan status pilihan
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        size: 14,
                        color: AppTheme.goldAccent,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Akan memutar ayat $_startVerse sampai $_endVerse ($totalSelected ayat).',
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white70 : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Tombol Aksi
            Row(
              children: [
                // Reset jika sedang aktif
                if (audio.isRangePlaybackActive) ...[
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.redAccent,
                      side: const BorderSide(color: Colors.redAccent),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () {
                      audio.clearVerseRange();
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Rentang ayat dinonaktifkan. Seluruh pasal akan diputar.'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    child: const Icon(Icons.refresh_rounded, size: 20),
                  ),
                  const SizedBox(width: 10),
                ],

                // Tombol Putar Audio Rentang
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.goldAccent,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 3,
                    ),
                    icon: const Icon(Icons.play_arrow_rounded, size: 22),
                    label: Text(
                      'Putar Audio (Ayat $_startVerse - $_endVerse)',
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      audio.playVerseRange(
                        verses,
                        startVerse: _startVerse,
                        endVerse: _endVerse,
                      );
                      widget.onScrollToVerse?.call(_startVerse);
                      widget.onApply?.call();
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
    );
  }

  Widget _buildPresetChip(String label, int start, int end) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final clampedEnd = end.clamp(1, _maxVerse);
    final isSelected = _startVerse == start && _endVerse == clampedEnd;

    return GestureDetector(
      onTap: () => _applyPreset(start, end),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.goldAccent
              : (isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppTheme.goldAccent
                : (isDark ? Colors.white10 : Colors.black12),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected
                ? Colors.black
                : (isDark ? Colors.white70 : Colors.black87),
          ),
        ),
      ),
    );
  }

  Widget _buildNumberCounter({
    required String label,
    required int value,
    required int min,
    required int max,
    required Function(int) onChanged,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white60 : Colors.black54,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0F172A) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? Colors.white12 : Colors.black12,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                iconSize: 18,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                icon: const Icon(Icons.remove_rounded),
                onPressed: value > min ? () => onChanged(value - 1) : null,
              ),
              Text(
                '$value',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              IconButton(
                iconSize: 18,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                icon: const Icon(Icons.add_rounded),
                onPressed: value < max ? () => onChanged(value + 1) : null,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
