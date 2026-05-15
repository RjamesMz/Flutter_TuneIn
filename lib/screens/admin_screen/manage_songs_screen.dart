// ignore_for_file: unnecessary_underscores, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:tunely/services/supabase_service.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/music_provider.dart';
import '../../core/app_colors.dart';
import '../../core/responsive_helper.dart';

class ManageSongsScreen extends StatefulWidget {
  const ManageSongsScreen({super.key});

  @override
  State<ManageSongsScreen> createState() => _ManageSongsScreenState();
}

class _ManageSongsScreenState extends State<ManageSongsScreen> {
  bool _loading = true;
  List<Map<String, dynamic>> _songs = [];
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    _loadSongs();
  }

  Future<void> _loadSongs() async {
    setState(() => _loading = true);
    try {
      final songs = await SupabaseService.instance.listSongs();
      setState(() => _songs = songs);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load songs: $e')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _confirmAndDelete(dynamic id) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete song'),
        content: const Text('Are you sure you want to delete this song? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (ok != true) return;

    try {
      String title = 'Song';
      try {
        final item = _songs.firstWhere((s) => s['id'] == id);
        title = item['title'] ?? title;
      } catch (_) {}

      await SupabaseService.instance.deleteSong(id);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Song deleted')));
      
      try {
        Provider.of<MusicProvider>(context, listen: false).addSongDeletedNotification('Deleted song: "$title"');
      } catch (_) {}

      await _loadSongs();
      try {
        await Provider.of<MusicProvider>(context, listen: false).fetchSongs();
      } catch (_) {}
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Delete failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final music = context.watch<MusicProvider>();
    final categories = ['All', ...music.categoryNames];

    final filteredSongs = _selectedCategory == 'All'
        ? _songs
        : _songs.where((s) => s['category'] == _selectedCategory).toList();

    return Scaffold(
      backgroundColor: kBackground,
      body: ResponsiveWrapper(
        child: Column(
          children: [
            // ── Gradient Header ───────────────────────────────────────────
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: kSoulGradient,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(16, 44, 16, 24),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Text(
                        'Manage Songs',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                        onPressed: _loadSongs,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Category Filter ───────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: categories.map((cat) {
                    final isSelected = _selectedCategory == cat;
                    return Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: FilterChip(
                        label: Text(cat),
                        selected: isSelected,
                        onSelected: (val) => setState(() => _selectedCategory = cat),
                        backgroundColor: kSurface,
                        selectedColor: kPrimary.withAlpha(40),
                        checkmarkColor: kPrimary,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: isSelected ? kPrimary : kOutlineVariant,
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        labelStyle: GoogleFonts.plusJakartaSans(
                          color: isSelected ? kPrimary : kOnSurfaceVariant,
                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            const SizedBox(height: 12),
            const Divider(height: 1),

            // ── Song List ──────────────────────────────────────────────────
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator(color: kPrimary))
                  : filteredSongs.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.music_off_outlined,
                                  size: 64, color: kOnSurfaceVariant.withAlpha(80)),
                              const SizedBox(height: 16),
                              Text(
                                'No songs found in $_selectedCategory',
                                style: GoogleFonts.plusJakartaSans(
                                  color: kOnSurfaceVariant,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                          itemCount: filteredSongs.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final s = filteredSongs[index];
                            return Container(
                              decoration: BoxDecoration(
                                color: kSurface,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: kOutlineVariant, width: 1),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withAlpha(5),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(12),
                                leading: ClipRRect(
                                  borderRadius: BorderRadius.circular(14),
                                  child: (s['cover_url'] != null &&
                                          (s['cover_url'] as String).isNotEmpty)
                                      ? Image.network(s['cover_url'],
                                          width: 60, height: 60, fit: BoxFit.cover)
                                      : Container(
                                          width: 60,
                                          height: 60,
                                          color: kSurfaceContainerLow,
                                          child: const Icon(Icons.music_note, color: kPrimary),
                                        ),
                                ),
                                title: Text(
                                  s['title'] ?? 'Untitled',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontWeight: FontWeight.w800,
                                    color: kOnSurface,
                                    fontSize: 15,
                                  ),
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        s['artist'] ?? 'Unknown Artist',
                                        style: GoogleFonts.beVietnamPro(
                                          color: kOnSurfaceVariant,
                                          fontSize: 13,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: kPrimary.withAlpha(20),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          s['category']?.toUpperCase() ?? 'NONE',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 9,
                                            color: kPrimary,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: 1,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete_sweep_rounded, color: Colors.redAccent),
                                  onPressed: () => _confirmAndDelete(s['id']),
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
