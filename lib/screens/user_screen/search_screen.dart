import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/responsive_helper.dart';
import '../../providers/music_provider.dart';
import '../../widgets/song_tile.dart';

// ─── All available category tiles (shared by grid + pills) ────────────────────
List<_CategoryTile> _getCategoryTiles(List<Map<String, String>> categories) {
  return categories.map((catMap) {
    final name = catMap['name']!;
    final colorHex = catMap['color']!;
    final color = Color(int.parse(colorHex.replaceFirst('#', '0xFF')));
    
    return _CategoryTile(
      label: name,
      categoryKey: name,
      color: color, // Use DB color
      icon: Icons.music_note_rounded, // Default icon for all
    );
  }).toList();
}

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  /// Keys of all currently selected categories.
  final Set<String> _activeKeys = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MusicProvider>().fetchSongs();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _applyFilter() {
    final music = context.read<MusicProvider>();
    final q = _query.trim();

    if (_activeKeys.isNotEmpty) {
      music.searchWithCategories(_activeKeys, q);
    } else if (q.isNotEmpty) {
      music.search(q);
    } else {
      music.clearSearch();
    }
  }

  void _onSearchChanged(String value) {
    setState(() => _query = value);
    _applyFilter();
  }

  void _clearSearch() {
    _searchCtrl.clear();
    setState(() => _query = '');
    _applyFilter();
  }

  void _toggleCategory(String key) {
    setState(() {
      if (_activeKeys.contains(key)) {
        _activeKeys.remove(key);
      } else {
        _activeKeys.add(key);
      }
    });
    _applyFilter();
  }

  void _removeCategory(String key) {
    setState(() => _activeKeys.remove(key));
    _applyFilter();
  }

  bool get _hasActiveFilter => _query.isNotEmpty || _activeKeys.isNotEmpty;

  List<_CategoryTile> _selectedTiles(List<Map<String, String>> categories) => 
      _getCategoryTiles(categories).where((t) => _activeKeys.contains(t.categoryKey)).toList();

  List<_CategoryTile> _unselectedTiles(List<Map<String, String>> categories) => 
      _getCategoryTiles(categories).where((t) => !_activeKeys.contains(t.categoryKey)).toList();

  @override
  Widget build(BuildContext context) {
    final music = context.watch<MusicProvider>();
    final results = music.searchResults;

    return Scaffold(
      backgroundColor: kSurface,

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
      ),

      body: ResponsiveWrapper(
        child: RefreshIndicator(
          onRefresh: () => context.read<MusicProvider>().fetchSongs(forceRefresh: true),
          color: kPrimary,
          backgroundColor: kSurface,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),

                // ── Search Field ───────────────────────────────────────────────
                TextField(
                  controller: _searchCtrl,
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'Songs, artists, albums…',
                    prefixIcon: const Icon(Icons.search, color: kOnSurfaceVariant),
                    suffixIcon: _query.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close, color: kOnSurfaceVariant),
                            onPressed: _clearSearch,
                          )
                        : null,
                  ),
                ),

                // ── Category Pills Row ─────────────────────────────────────────
                if (_activeKeys.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        // Selected categories (dismissible pills)
                        ..._selectedTiles(music.categories).map(
                          (t) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: _CategoryPill(
                              tile: t,
                              isSelected: true,
                              onTap: () => _removeCategory(t.categoryKey),
                            ),
                          ),
                        ),
                        // Unselected categories (tappable outlines)
                        ..._unselectedTiles(music.categories).map(
                          (t) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: _CategoryPill(
                              tile: t,
                              isSelected: false,
                              onTap: () => _toggleCategory(t.categoryKey),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 20),

                // ── No active filter → category grid ───────────────────────────
                if (!_hasActiveFilter) ...[
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Popular categories',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: kOnSurface,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const SizedBox(height: 12),
              _CategoryGrid(
                onCategoryTap: _toggleCategory,
                categories: music.categories,
              ),
                          const SizedBox(height: 120),
                        ],
                      ),
                    ),
                  ),
                ] else if (music.isSearching) ...[
                  const Expanded(
                    child: Center(
                      child: CircularProgressIndicator(color: kPrimary),
                    ),
                  ),
                ] else if (results.isEmpty) ...[
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.6,
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 56,
                              color: kOnSurfaceVariant.withAlpha(77),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _activeKeys.isNotEmpty && _query.isEmpty
                                  ? 'No songs in selected categories'
                                  : 'No results for "$_query"',
                              style: const TextStyle(
                                fontSize: 15,
                                color: kOnSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ] else ...[
                  Text(
                    '${results.length} result${results.length == 1 ? '' : 's'}',
                    style: const TextStyle(fontSize: 13, color: kOnSurfaceVariant),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.only(bottom: 120),
                      itemCount: results.length,
                      itemBuilder: (ctx, i) =>
                          SongTile(song: results[i], queue: results),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Category Pill ────────────────────────────────────────────────────────────
/// When [isSelected] is true  → solid fill with ✕ icon (remove on tap).
/// When [isSelected] is false → outlined style (add on tap).
class _CategoryPill extends StatelessWidget {
  final _CategoryTile tile;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryPill({
    required this.tile,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? tile.color : Colors.transparent,
            border: Border.all(
            color: isSelected ? tile.color : kOnSurfaceVariant.withAlpha(77),
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              tile.icon,
              color: isSelected ? Colors.white : kOnSurfaceVariant,
              size: 15,
            ),
            const SizedBox(width: 5),
            Text(
              tile.label,
              style: TextStyle(
                color: isSelected ? Colors.white : kOnSurfaceVariant,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 5),
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(64),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 12),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Category Grid (initial view) ─────────────────────────────────────────────
class _CategoryGrid extends StatelessWidget {
  final ValueChanged<String> onCategoryTap;
  final List<Map<String, String>> categories;

  const _CategoryGrid({required this.onCategoryTap, required this.categories});

  @override
  Widget build(BuildContext context) {
    final tiles = _getCategoryTiles(categories);
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 2.5,
      ),
      itemCount: tiles.length,
      itemBuilder: (_, i) {
        final t = tiles[i];
        return GestureDetector(
          onTap: () => onCategoryTap(t.categoryKey),
          child: Container(
            decoration: BoxDecoration(
              color: t.color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const SizedBox(width: 14),
                Icon(t.icon, color: Colors.white.withAlpha(217), size: 22),
                const SizedBox(width: 10),
                Text(
                  t.label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─── Data class ───────────────────────────────────────────────────────────────
class _CategoryTile {
  final String label;
  final String categoryKey;
  final Color color;
  final IconData icon;
  const _CategoryTile({
    required this.label,
    required this.categoryKey,
    required this.color,
    required this.icon,
  });
}
