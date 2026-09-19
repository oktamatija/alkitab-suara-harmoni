import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/book.dart';
import '../providers/bible_provider.dart';
import '../theme/app_theme.dart';
import 'verse_range_picker_sheet.dart';

class BookPickerSheet extends StatefulWidget {
  const BookPickerSheet({super.key});

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
      builder: (ctx) => const BookPickerSheet(),
    );
  }

  @override
  State<BookPickerSheet> createState() => _BookPickerSheetState();
}

class _BookPickerSheetState extends State<BookPickerSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';
  Book? _selectedBookForChapters;
  bool _pickVerseRangeAfterChapter = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bible = Provider.of<BibleProvider>(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Jika user sedang memilih pasal dari sebuah kitab
    if (_selectedBookForChapters != null) {
      return _buildChapterGrid(context, bible, _selectedBookForChapters!);
    }

    final allBooks = bible.books;
    final filtered = _searchQuery.isEmpty
        ? allBooks
        : allBooks.where((b) =>
            b.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            b.abbr.toLowerCase().contains(_searchQuery.toLowerCase())).toList();

    final plBooks = filtered.where((b) => b.isOldTestament).toList();
    final pbBooks = filtered.where((b) => b.isNewTestament).toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Handle Bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            decoration: BoxDecoration(
              color: isDark ? Colors.white24 : Colors.black26,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                Text(
                  'Pilih Kitab & Pasal',
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Search Box
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (val) => setState(() => _searchQuery = val.trim()),
              style: GoogleFonts.outfit(color: isDark ? Colors.white : Colors.black87),
              decoration: InputDecoration(
                hintText: 'Cari nama kitab (contoh: Yohanes, Mazmur)...',
                hintStyle: GoogleFonts.outfit(color: isDark ? Colors.white38 : Colors.black38, fontSize: 13),
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
          ),
          const SizedBox(height: 8),

          // Tab Bar Perjanjian Lama / Baru
          if (_searchQuery.isEmpty)
            TabBar(
              controller: _tabController,
              indicatorColor: AppTheme.goldAccent,
              labelColor: AppTheme.goldAccent,
              unselectedLabelColor: isDark ? Colors.white54 : Colors.black45,
              labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 13),
              tabs: const [
                Tab(text: 'Perjanjian Lama (39)'),
                Tab(text: 'Perjanjian Baru (27)'),
              ],
            ),

          // Tab Views
          Expanded(
            child: _searchQuery.isNotEmpty
                ? _buildBookList(context, filtered, bible)
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildBookList(context, plBooks, bible),
                      _buildBookList(context, pbBooks, bible),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookList(BuildContext context, List<Book> books, BibleProvider bible) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (books.isEmpty) {
      return Center(
        child: Text(
          'Tidak ada kitab yang cocok.',
          style: GoogleFonts.outfit(color: isDark ? Colors.white54 : Colors.black45),
        ),
      );
    }

    return ListView.builder(
      itemCount: books.length,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemBuilder: (ctx, index) {
        final book = books[index];
        final isCurrent = book.id == bible.currentBookId;
        final isAvailable = bible.storage.isBookAvailable(book.id);

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          color: isCurrent
              ? AppTheme.goldAccent.withOpacity(0.12)
              : (isDark ? const Color(0xFF1E293B) : Colors.white),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: isCurrent
                  ? AppTheme.goldAccent.withOpacity(0.6)
                  : (isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.05)),
            ),
          ),
          child: ListTile(
            onTap: () {
              setState(() {
                _selectedBookForChapters = book;
              });
            },
            leading: CircleAvatar(
              radius: 18,
              backgroundColor: isCurrent
                  ? AppTheme.goldAccent
                  : (isDark ? Colors.white10 : Colors.black.withOpacity(0.05)),
              child: Text(
                book.abbr,
                style: GoogleFonts.outfit(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: isCurrent ? Colors.black : (isDark ? Colors.white70 : Colors.black87),
                ),
              ),
            ),
            title: Text(
              book.name,
              style: GoogleFonts.outfit(
                fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w600,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            subtitle: Text(
              '${book.maxChapter} Pasal • ${book.totalVerses} Ayat',
              style: GoogleFonts.outfit(
                fontSize: 12,
                color: isDark ? Colors.white54 : Colors.black45,
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!isAvailable)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    margin: const EdgeInsets.only(right: 6),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Unduh',
                      style: GoogleFonts.outfit(fontSize: 10, color: Colors.amber[300]),
                    ),
                  ),
                const Icon(Icons.chevron_right_rounded, size: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildChapterGrid(BuildContext context, BibleProvider bible, Book book) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            decoration: BoxDecoration(
              color: isDark ? Colors.white24 : Colors.black26,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_rounded),
                  onPressed: () {
                    setState(() {
                      _selectedBookForChapters = null;
                    });
                  },
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.name,
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    Text(
                      'Pilih pasal (1 - ${book.maxChapter})',
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        color: isDark ? Colors.white60 : Colors.black54,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Pilihan Mode: Langsung Buka vs Pilih Rentang Ayat
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            color: isDark ? Colors.white.withOpacity(0.04) : Colors.black.withOpacity(0.03),
            child: Row(
              children: [
                Icon(
                  Icons.tune_rounded,
                  size: 16,
                  color: _pickVerseRangeAfterChapter
                      ? AppTheme.goldAccent
                      : (isDark ? Colors.white54 : Colors.black45),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Atur rentang ayat setelah memilih pasal (misal ayat 1-10)',
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: _pickVerseRangeAfterChapter ? FontWeight.w600 : FontWeight.w400,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                ),
                Switch(
                  value: _pickVerseRangeAfterChapter,
                  activeColor: AppTheme.goldAccent,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  onChanged: (val) {
                    setState(() {
                      _pickVerseRangeAfterChapter = val;
                    });
                  },
                ),
              ],
            ),
          ),

          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.0,
              ),
              itemCount: book.maxChapter,
              itemBuilder: (ctx, index) {
                final chapNum = index + 1;
                final isCurrent =
                    book.id == bible.currentBookId && chapNum == bible.currentChapter;

                return GestureDetector(
                  onTap: () {
                    bible.selectBook(book.id);
                    bible.selectChapter(chapNum);
                    Navigator.pop(context);
                    if (_pickVerseRangeAfterChapter) {
                      VerseRangePickerSheet.show(context);
                    }
                  },
                  onLongPress: () {
                    bible.selectBook(book.id);
                    bible.selectChapter(chapNum);
                    Navigator.pop(context);
                    VerseRangePickerSheet.show(context);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: isCurrent
                          ? AppTheme.goldAccent
                          : (isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isCurrent
                            ? AppTheme.goldAccent
                            : (isDark ? Colors.white10 : Colors.black12),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '$chapNum',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: isCurrent
                              ? Colors.black
                              : (isDark ? Colors.white : Colors.black87),
                        ),
                      ),
                    ),
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
