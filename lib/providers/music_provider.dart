
import 'package:flutter/foundation.dart';
import '../models/song.dart';
import '../services/music_service.dart';
import '../core/app_strings.dart';

// ─── Music Provider ───────────────────────────────────────────────────────────
/// Manages the song catalog, search results, and active category filter.
/// Consumed by HomeScreen and SearchScreen.
///
/// Usage:
///   context.read<MusicProvider>().fetchSongs()
///   context.watch<MusicProvider>().displayedSongs
class MusicProvider extends ChangeNotifier {
  // ── State ──────────────────────────────────────────────────────────────────
  List<Song>  _allSongs          = [];
  List<Song>  _searchResults     = [];
  String      _selectedCategory  = MusicCategories.all;
  bool        _isLoading         = false;
  bool        _isSearching       = false;
  String      _searchQuery       = '';
  String?     _errorMessage;

  // ── Getters ────────────────────────────────────────────────────────────────
  bool    get isLoading        => _isLoading;
  bool    get isSearching      => _isSearching;
  String  get selectedCategory => _selectedCategory;
  String  get searchQuery      => _searchQuery;
  String? get errorMessage     => _errorMessage;

  /// Songs filtered by the active category (used by HomeScreen).
  List<Song> get filteredSongs {
    if (_selectedCategory == MusicCategories.all) return _allSongs;
    return _allSongs
        .where((s) => s.category == _selectedCategory)
        .toList();
  }

  /// Results returned by search (used by SearchScreen).
  List<Song> get searchResults => _searchResults;

  /// All songs regardless of filter.
  List<Song> get allSongs => _allSongs;

  // ── Actions ────────────────────────────────────────────────────────────────

  /// Fetches the full song catalog from [MusicService].
  Future<void> fetchSongs() async {
    if (_allSongs.isNotEmpty) return; // already loaded

    _isLoading    = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _allSongs  = await MusicService.instance.fetchSongs();
    } catch (e) {
      _errorMessage = 'Could not load songs. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Filters library by [category].
  void selectCategory(String category) {
    if (_selectedCategory == category) return;
    _selectedCategory = category;
    notifyListeners();
  }

  /// Searches catalog by [query], updating [searchResults].
  Future<void> search(String query) async {
    _searchQuery  = query;
    _isSearching  = true;
    notifyListeners();

    try {
      _searchResults = await MusicService.instance.search(query);
    } catch (_) {
      _searchResults = [];
    } finally {
      _isSearching = false;
      notifyListeners();
    }
  }

  /// Filters by one or more [categories] and optionally narrows by [query] text.
  /// Used by SearchScreen when category pills are active.
  void searchWithCategories(Set<String> categories, [String query = '']) {
    _searchQuery  = query;
    _isSearching  = false;

    // Start from songs in any of the chosen categories.
    Iterable<Song> pool = _allSongs.where(
      (s) => categories.contains(s.category),
    );

    // If there's also a text query, narrow further.
    if (query.trim().isNotEmpty) {
      final q = query.toLowerCase();
      pool = pool.where((s) =>
          s.title.toLowerCase().contains(q) ||
          s.artist.toLowerCase().contains(q) ||
          s.album.toLowerCase().contains(q));
    }

    _searchResults = pool.toList();
    notifyListeners();
  }

  /// Clears the search state.
  void clearSearch() {
    _searchQuery   = '';
    _searchResults = [];
    notifyListeners();
  }
}
