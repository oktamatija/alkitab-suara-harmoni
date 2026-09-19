import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/verse.dart';
import '../theme/app_theme.dart';

class VerseCard extends StatelessWidget {
  final Verse verse;
  final bool isActive;
  final bool isInRange;
  final double fontSize;
  final VoidCallback onTap;
  final VoidCallback onBookmarkToggle;

  const VerseCard({
    super.key,
    required this.verse,
    required this.isActive,
    this.isInRange = false,
    required this.fontSize,
    required this.onTap,
    required this.onBookmarkToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (verse.title != null) ...[
          Padding(
            padding: const EdgeInsets.only(top: 20, bottom: 8, left: 4, right: 4),
            child: Text(
              verse.title!,
              style: GoogleFonts.outfit(
                fontSize: fontSize * 0.95,
                fontWeight: FontWeight.w700,
                color: isDark ? AppTheme.goldAccent : AppTheme.goldDeep,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ],
        AnimatedContainer(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            color: isActive
                ? (isDark
                    ? const Color(0xFF2A2212)
                    : const Color(0xFFFFF8E7))
                : (isInRange
                    ? (isDark
                        ? AppTheme.goldAccent.withOpacity(0.06)
                        : const Color(0xFFFFFDF5))
                    : (isDark ? Colors.transparent : Colors.white.withOpacity(0.6))),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isActive
                  ? AppTheme.goldAccent
                  : (isInRange
                      ? AppTheme.goldAccent.withOpacity(0.35)
                      : (isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.05))),
              width: isActive ? 1.8 : (isInRange ? 1.2 : 0.8),
            ),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: AppTheme.goldAccent.withOpacity(0.25),
                      blurRadius: 16,
                      spreadRadius: 1,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(14),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Indikator Garis Aksen Vertikal untuk Ayat yang Sedang Disorot
                    if (isActive) ...[
                      Container(
                        width: 3.5,
                        height: 36,
                        margin: const EdgeInsets.only(top: 2, right: 10),
                        decoration: BoxDecoration(
                          color: AppTheme.goldAccent,
                          borderRadius: BorderRadius.circular(2),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.goldAccent.withOpacity(0.5),
                              blurRadius: 6,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // Nomor Ayat Badge
                    Container(
                      margin: const EdgeInsets.only(top: 2, right: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isActive
                            ? AppTheme.goldAccent
                            : (isDark
                                ? Colors.white.withOpacity(0.08)
                                : Colors.black.withOpacity(0.06)),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: isActive
                            ? [
                                BoxShadow(
                                  color: AppTheme.goldAccent.withOpacity(0.4),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: Text(
                        '${verse.verse}',
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: isActive
                              ? Colors.black
                              : (isDark ? Colors.white70 : Colors.black87),
                        ),
                      ),
                    ),

                    // Teks Ayat Firman
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            verse.text,
                            style: GoogleFonts.lora(
                              fontSize: fontSize,
                              height: 1.65,
                              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                              color: isDark
                                  ? (isActive ? Colors.white : Colors.white.withOpacity(0.9))
                                  : (isActive ? const Color(0xFF0F172A) : const Color(0xFF1E293B)),
                            ),
                          ),
                          if (isActive) ...[
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.black.withOpacity(0.28)
                                    : Colors.white.withOpacity(0.75),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.volume_up_rounded,
                                    size: 15,
                                    color: AppTheme.goldAccent,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Sedang dinarasikan',
                                    style: GoogleFonts.outfit(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: isDark ? AppTheme.goldAccent : AppTheme.goldDeep,
                                    ),
                                  ),
                                  const Spacer(),
                                  _ActionIconButton(
                                    icon: verse.isBookmarked
                                        ? Icons.bookmark_rounded
                                        : Icons.bookmark_border_rounded,
                                    color: verse.isBookmarked
                                        ? AppTheme.goldAccent
                                        : (isDark ? Colors.white60 : Colors.black54),
                                    onTap: onBookmarkToggle,
                                  ),
                                  const SizedBox(width: 8),
                                  _ActionIconButton(
                                    icon: Icons.copy_rounded,
                                    color: isDark ? Colors.white60 : Colors.black54,
                                    onTap: () {
                                      Clipboard.setData(ClipboardData(
                                        text: '${verse.text} (${verse.reference})',
                                      ));
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Ayat disalin ke papan klip'),
                                          duration: Duration(seconds: 1),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ActionIconButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionIconButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Icon(icon, size: 16, color: color),
      ),
    );
  }
}
