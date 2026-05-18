/// File: lib/screens/user_screen/search_screen.dart
/// Role: Tab screen providing comprehensive search operations. Supports queries on songs,
/// artists, or albums, alongside multi-category filters and colored chips grids.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/responsive_helper.dart';
import '../../providers/music_provider.dart';
import '../../widgets/song_tile.dart';

/// Formulates a parsed list of category tile widgets.
///
/// [categories] Database dynamic string lists.
List<_CategoryTile> _getCategoryTiles(List<Map<String, String>> categories) {
  return categories.map((catMap) {
    final name = catMap['name']!;
    final colorHex = catMap['color']!;
    
    // Converts dynamic database hexadecimal strings safely into core Flutter Color instances.
    final color = Color(int.parse(colorHex.replaceFirst('#', '0xFF')));
    
    return _CategoryTile(
      label: name,
      categoryKey: name,
      color: color,
      icon: Icons.music_note_rounded,
    );
  }).toList();
}

/// Screen widget displaying the browse catalogs search search screen.
class SearchScreen extends StatefulWidget {
  /// Constructs a [SearchScreen] instance.
  ///
  /// [key] An optional key used for identifying the widget in the element tree.
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

/// State controller managing active input queries, category key filters, and list views in [SearchScreen].
class _SearchScreenState extends State<SearchScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  final Set<String> _activeKeys = {};

  @override
  /// Initiates dynamic songs loading cycles.
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MusicProvider>().fetchSongs();
    });
  }

  @override
  /// Clears keyboard text controllers.
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  /// Evaluates and submits currently formulated queries and category filters to MusicProvider.
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

  /// Triggers a re-evaluation when the user types search keys.
  ///
  /// [value] Current search text string.
  void _onSearchChanged(String value) {
    setState(() => _query = value);
    _applyFilter();
  }

  /// Resets search strings.
  void _clearSearch() {
    _searchCtrl.clear();
    setState(() => _query = '');
    _applyFilter();
  }

  /// Toggles category filters on/off.
  ///
  /// [key] Targeted category key.
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

  /// Purges targeted category filters.
  ///
  /// [key] Targeted category key.
  void _removeCategory(String key) {
    setState(() => _activeKeys.remove(key));
    _applyFilter();
  }

  /// Helper flag verifying if filters are active.
  bool get _hasActiveFilter => _query.isNotEmpty || _activeKeys.isNotEmpty;

  /// Formulates lists containing selected elements.
  List<_CategoryTile> _selectedTiles(List<Map<String, String>> categories) => 
      _getCategoryTiles(categories).where((t) => _activeKeys.contains(t.categoryKey)).toList();

  /// Formulates lists containing unselected elements.
  List<_CategoryTile> _unselectedTiles(List<Map<String, String>> categories) => 
      _getCategoryTiles(categories).where((t) => !_activeKeys.contains(t.categoryKey)).toList();

  @override
  /// Builds the search search input deck, chips row, and list views.
  ///
  /// [context] The building context.
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

/// Animated filter chip indicator widget showing selected or unselected states.
class _CategoryPill extends StatelessWidget {
  /// Visual tile configuration model data.
  final _CategoryTile tile;

  /// Check showing if active filter is applied.
  final bool isSelected;

  /// Click action callback.
  final VoidCallback onTap;

  /// Constructs a [_CategoryPill] instance.
  ///
  /// [key] An optional key.
  /// [tile] Tile model structure.
  /// [isSelected] Selection state boolean.
  /// [onTap] Tap callback.
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

/// Grid structure displaying initial browsing categories.
class _CategoryGrid extends StatelessWidget {
  /// Pressed handler callback returning targeted key strings.
  final ValueChanged<String> onCategoryTap;

  /// Available categories database metadata map.
  final List<Map<String, String>> categories;

  /// Constructs a [_CategoryGrid] instance.
  ///
  /// [key] An optional key.
  /// [onCategoryTap] Pressed handler returning category key.
  /// [categories] Database raw category parameters list.
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

/// Standard container class representing category attributes.
class _CategoryTile {
  /// Display string label.
  final String label;

  /// Filter query key value.
  final String categoryKey;

  /// Dynamic background card color.
  final Color color;

  /// Predefined category icon representation.
  final IconData icon;

  /// Constructs a [_CategoryTile] instance.
  const _CategoryTile({
    required this.label,
    required this.categoryKey,
    required this.color,
    required this.icon,
  });
}
