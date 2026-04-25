import 'package:flutter/material.dart';
import '../core/app_colors.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  final List<Map<String, String>> _allSongs = [
    {'title': 'Blinding Lights',   'artist': 'The Weeknd',     'duration': '3:20'},
    {'title': 'Levitating',        'artist': 'Dua Lipa',       'duration': '3:23'},
    {'title': 'Stay',              'artist': 'Kid LAROI',       'duration': '2:21'},
    {'title': 'Good 4 U',          'artist': 'Olivia Rodrigo',  'duration': '2:58'},
    {'title': 'Peaches',           'artist': 'Justin Bieber',   'duration': '3:18'},
    {'title': 'Montero',           'artist': 'Lil Nas X',       'duration': '2:17'},
  ];

  List<Map<String, String>> get _results => _allSongs
      .where((s) =>
          s['title']!.toLowerCase().contains(_query.toLowerCase()) ||
          s['artist']!.toLowerCase().contains(_query.toLowerCase()))
      .toList();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool hasQuery = _query.isNotEmpty;

    return Scaffold(
      backgroundColor: kSurface,

      // ── App Bar ──────────────────────────────────────────────────────────
      appBar: AppBar(
        backgroundColor: kSurface,
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: false,
        title: const Text(
          'Search',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: kPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune, color: kOnSurfaceVariant),
            onPressed: () {},
          ),
          const SizedBox(width: 4),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),

            // ── Search Field ───────────────────────────────────────────────
            TextField(
              controller: _searchCtrl,
              onChanged: (value) => setState(() => _query = value),
              decoration: InputDecoration(
                hintText: 'Songs, artists, albums…',
                prefixIcon: const Icon(Icons.search, color: kOnSurfaceVariant),
                suffixIcon: hasQuery
                    ? IconButton(
                        icon: const Icon(Icons.close, color: kOnSurfaceVariant),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _query = '');
                        },
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 20),

            // ── No query → category grid ───────────────────────────────────
            if (!hasQuery) ...[
              const Text(
                'Popular categories',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: kOnSurface,
                ),
              ),
              const SizedBox(height: 12),
              const _CategoryGrid(),

            // ── No results ─────────────────────────────────────────────────
            ] else if (_results.isEmpty) ...[
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.search_off, size: 56,
                          color: kOnSurfaceVariant.withOpacity(0.3)),
                      const SizedBox(height: 16),
                      Text(
                        'No results for "$_query"',
                        style: const TextStyle(fontSize: 15, color: kOnSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ),

            // ── Results list ───────────────────────────────────────────────
            ] else ...[
              Text(
                '${_results.length} result${_results.length == 1 ? '' : 's'}',
                style: const TextStyle(fontSize: 13, color: kOnSurfaceVariant),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.only(bottom: 120),
                  itemCount: _results.length,
                  itemBuilder: (ctx, i) => _SongTile(
                    title:    _results[i]['title']!,
                    artist:   _results[i]['artist']!,
                    duration: _results[i]['duration']!,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Category Grid ────────────────────────────────────────────────────────────
class _CategoryGrid extends StatelessWidget {
  const _CategoryGrid();

  static const List<_CategoryTile> _tiles = [
    _CategoryTile(label: 'Trending', color: Color(0xFF9D3756), icon: Icons.trending_up),
    _CategoryTile(label: 'For You',  color: Color(0xFF7C3F8A), icon: Icons.favorite),
    _CategoryTile(label: 'Lo-Fi',    color: Color(0xFF3B6B8A), icon: Icons.cloud),
    _CategoryTile(label: 'Indie',    color: Color(0xFF4A6741), icon: Icons.forest),
    _CategoryTile(label: 'R&B',      color: Color(0xFF8A4A3B), icon: Icons.music_note),
    _CategoryTile(label: 'Jazz',     color: Color(0xFF5C4A8A), icon: Icons.piano),
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 2.5,
      ),
      itemCount: _tiles.length,
      itemBuilder: (_, i) {
        final t = _tiles[i];
        return GestureDetector(
          onTap: () {},
          child: Container(
            decoration: BoxDecoration(
              color: t.color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const SizedBox(width: 14),
                Icon(t.icon, color: Colors.white.withOpacity(0.85), size: 22),
                const SizedBox(width: 10),
                Text(t.label,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14)),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─── Song Tile ────────────────────────────────────────────────────────────────
class _SongTile extends StatelessWidget {
  final String title;
  final String artist;
  final String duration;
  const _SongTile({required this.title, required this.artist, required this.duration});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: kSurfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              Container(
                width: 56, height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE0EC),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.music_note, color: kPrimary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 14, color: kOnSurface)),
                    const SizedBox(height: 2),
                    Text(artist,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12, color: kOnSurfaceVariant)),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(duration,
                    style: const TextStyle(fontSize: 11, color: kOnSurfaceVariant)),
              ),
              const Icon(Icons.more_vert, color: kOnSurfaceVariant, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Data class ───────────────────────────────────────────────────────────────
class _CategoryTile {
  final String label;
  final Color color;
  final IconData icon;
  const _CategoryTile({required this.label, required this.color, required this.icon});
}
