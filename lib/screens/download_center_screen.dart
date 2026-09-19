import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/bible_provider.dart';
import '../theme/app_theme.dart';

class DownloadCenterScreen extends StatefulWidget {
  const DownloadCenterScreen({super.key});

  @override
  State<DownloadCenterScreen> createState() => _DownloadCenterScreenState();
}

class _DownloadCenterScreenState extends State<DownloadCenterScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final bible = Provider.of<BibleProvider>(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final isFull = bible.isFullBibleDownloaded;
    final allBooks = bible.books;
    final filtered = _searchQuery.isEmpty
        ? allBooks
        : allBooks.where((b) =>
            b.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            b.abbr.toLowerCase().contains(_searchQuery.toLowerCase())).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Pusat Unduhan Alkitab',
          style: GoogleFonts.outfit(fontWeight: FontWeight.w700),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Download Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [
                            const Color(0xFF1E293B),
                            const Color(0xFF0F172A),
                          ]
                        : [
                            const Color(0xFFFFFBEB),
                            const Color(0xFFFEF3C7),
                          ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: AppTheme.goldAccent.withOpacity(0.4),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.goldAccent.withOpacity(0.12),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppTheme.goldAccent.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            isFull ? Icons.check_circle_rounded : Icons.cloud_download_rounded,
                            color: AppTheme.goldAccent,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isFull ? 'Alkitab Lengkap Tersimpan' : 'Alkitab Bahasa Indonesia',
                                style: GoogleFonts.outfit(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                              Text(
                                isFull
                                    ? 'Semua 66 Kitab siap diakses tanpa internet'
                                    : 'Terjemahan Baru / AYT • 66 Kitab • 31.102 Ayat',
                                style: GoogleFonts.outfit(
                                  fontSize: 12,
                                  color: isDark ? Colors.white70 : Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Progress Bar saat sedang mendownload
                    if (bible.isDownloading) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: bible.downloadProgress > 0 ? bible.downloadProgress : null,
                          minHeight: 10,
                          backgroundColor: isDark ? Colors.white10 : Colors.black12,
                          color: AppTheme.goldAccent,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            bible.downloadStatus,
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              color: AppTheme.goldAccent,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '${(bible.downloadProgress * 100).round()}%',
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.goldAccent,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],

                    // Tombol Aksi Download / Status
                    if (!bible.isDownloading) ...[
                      if (!isFull)
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.goldAccent,
                            foregroundColor: Colors.black,
                            minimumSize: const Size(double.infinity, 46),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          icon: const Icon(Icons.download_for_offline_rounded),
                          label: Text(
                            'Unduh Alkitab Lengkap Offline (~5.2 MB)',
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                          onPressed: () {
                            bible.startDownloadFullBible();
                          },
                        )
                      else
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.green.withOpacity(0.3)),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.verified_rounded, color: Colors.green, size: 18),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Offline 100% Siap',
                                      style: GoogleFonts.outfit(
                                        color: Colors.green,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            TextButton.icon(
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.redAccent,
                              ),
                              icon: const Icon(Icons.delete_outline_rounded, size: 18),
                              label: Text('Reset Data', style: GoogleFonts.outfit(fontSize: 12)),
                              onPressed: () {
                                _confirmClearData(context, bible);
                              },
                            ),
                          ],
                        ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Detail Statistik Penyimpanan
              Text(
                'STATUS KITAB & PENYIMPANAN',
                style: GoogleFonts.outfit(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                  color: isDark ? AppTheme.goldAccent : AppTheme.goldDeep,
                ),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  _buildStatCard(
                    title: 'Total Kitab',
                    value: '66 Kitab',
                    subtitle: isFull ? 'Semua tersimpan' : '8 bundel awal',
                    icon: Icons.menu_book_rounded,
                    isDark: isDark,
                  ),
                  const SizedBox(width: 12),
                  _buildStatCard(
                    title: 'Total Ayat',
                    value: isFull ? '31.102' : '7.833',
                    subtitle: isFull ? 'Lengkap 100%' : 'Perjanjian Lengkap',
                    icon: Icons.format_quote_rounded,
                    isDark: isDark,
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Kotak Pencarian Kitab
              TextField(
                onChanged: (val) => setState(() => _searchQuery = val.trim()),
                style: GoogleFonts.outfit(color: isDark ? Colors.white : Colors.black87),
                decoration: InputDecoration(
                  hintText: 'Cari status kitab...',
                  prefixIcon: const Icon(Icons.search_rounded, size: 20),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Daftar Kitab
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filtered.length,
                itemBuilder: (ctx, index) {
                  final book = filtered[index];
                  final isAvailable = bible.storage.isBookAvailable(book.id);

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    child: ListTile(
                      dense: true,
                      leading: CircleAvatar(
                        radius: 16,
                        backgroundColor: isAvailable
                            ? Colors.green.withOpacity(0.2)
                            : Colors.orange.withOpacity(0.2),
                        child: Icon(
                          isAvailable ? Icons.check_rounded : Icons.cloud_download_rounded,
                          size: 16,
                          color: isAvailable ? Colors.green : Colors.orange,
                        ),
                      ),
                      title: Text(
                        book.name,
                        style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        '${book.testamentName} • ${book.maxChapter} Pasal',
                        style: GoogleFonts.outfit(fontSize: 11),
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: isAvailable
                              ? Colors.green.withOpacity(0.15)
                              : Colors.orange.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          isAvailable ? 'Tersimpan Offline' : 'Perlu Diunduh',
                          style: GoogleFonts.outfit(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: isAvailable ? Colors.green : Colors.orange[300],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required bool isDark,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.06),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 20, color: AppTheme.goldAccent),
            const SizedBox(height: 8),
            Text(
              value,
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            Text(
              subtitle,
              style: GoogleFonts.outfit(
                fontSize: 11,
                color: isDark ? Colors.white54 : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmClearData(BuildContext context, BibleProvider bible) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Reset Data Offline?', style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
        content: Text(
          'Teks Alkitab lengkap akan dikembalikan ke bundel awal (8 Kitab utama). Anda dapat mengunduhnya kembali kapan saja.',
          style: GoogleFonts.outfit(fontSize: 13),
        ),
        actions: [
          TextButton(
            child: const Text('Batal'),
            onPressed: () => Navigator.pop(ctx),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Reset'),
            onPressed: () {
              bible.clearOfflineData();
              Navigator.pop(ctx);
            },
          ),
        ],
      ),
    );
  }
}
