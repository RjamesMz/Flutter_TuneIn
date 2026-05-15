import 'package:flutter/material.dart';
import 'package:tunely/services/supabase_service.dart';
import 'package:provider/provider.dart';
import '../providers/music_provider.dart';
import '../core/app_colors.dart';

class ManageSongsScreen extends StatefulWidget {
  const ManageSongsScreen({super.key});

  @override
  State<ManageSongsScreen> createState() => _ManageSongsScreenState();
}

class _ManageSongsScreenState extends State<ManageSongsScreen> {
  bool _loading = true;
  List<Map<String, dynamic>> _songs = [];

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
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );
    if (ok != true) return;

    try {
      // capture title for notification
      String title = 'Song';
      try {
        final item = _songs.firstWhere((s) => s['id'] == id);
        title = item['title'] ?? title;
      } catch (_) {}

      await SupabaseService.instance.deleteSong(id);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Song deleted')));
      // add in-app notification
      try {
        Provider.of<MusicProvider>(context, listen: false).addSongDeletedNotification('Deleted song: "$title"');
      } catch (_) {}

      await _loadSongs();
      // Refresh the global music provider so UI reflects deletion (and prunes likes)
      try {
        await Provider.of<MusicProvider>(context, listen: false).fetchSongs();
      } catch (_) {}
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Delete failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Songs'), backgroundColor: kBackground, elevation: 0),
      backgroundColor: kBackground,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _songs.isEmpty
              ? const Center(child: Text('No songs found'))
              : ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: _songs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final s = _songs[index];
                    return Card(
                      color: kSurface,
                      child: ListTile(
                        leading: (s['cover_url'] != null && (s['cover_url'] as String).isNotEmpty)
                            ? Image.network(s['cover_url'], width: 56, height: 56, fit: BoxFit.cover)
                            : const SizedBox(width: 56, height: 56),
                        title: Text(s['title'] ?? 'Untitled'),
                        subtitle: Text(s['artist'] ?? ''),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                          onPressed: () => _confirmAndDelete(s['id']),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
