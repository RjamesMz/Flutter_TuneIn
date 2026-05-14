
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  static const String _playlistsKey = 'user_playlists';
  static const String _likesKey = 'user_likes';

  MusicProvider() {
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load likes
    final likesList = prefs.getStringList(_likesKey) ?? [];
    _likedSongIds.addAll(likesList);

    if (likesList.isNotEmpty) {
      await fetchSongs();
    }

    // Load playlists
    final playlistsJson = prefs.getString(_playlistsKey);
    if (playlistsJson != null) {
      try {
        final Map<String, dynamic> decoded = json.decode(playlistsJson);
        decoded.forEach((key, value) {
          _playlists[key] = List<String>.from(value);
        });
      } catch (_) {}
    }
    notifyListeners();
  }

  Future<void> _saveLikes() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_likesKey, _likedSongIds.toList());
  }

  Future<void> _savePlaylists() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_playlistsKey, json.encode(_playlists));
  }

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
      // After fetching songs, remove any liked IDs that no longer exist
      _pruneInvalidLikes();
    } catch (e) {
      _errorMessage = 'Could not load songs. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _pruneInvalidLikes() {
    final validIds = _allSongs.map((s) => s.id).toSet();
    final invalid = _likedSongIds.where((id) => !validIds.contains(id)).toList();
    if (invalid.isNotEmpty) {
      for (final id in invalid) {
        _likedSongIds.remove(id);
      }
      _saveLikes();
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

  // ── Liked Songs ───────────────────────────────────────────────────────────

  final Set<String> _likedSongIds = {};

  Set<String> get likedSongIds => _likedSongIds;

  bool isLiked(String songId) => _likedSongIds.contains(songId);

  void toggleLike(String songId) {
    if (_likedSongIds.contains(songId)) {
      _likedSongIds.remove(songId);
      removeSongFromPlaylist('Liked Songs', songId);
      
      // If no likes left, you can optionally remove the playlist
      if (_likedSongIds.isEmpty) {
        deletePlaylist('Liked Songs');
      }
    } else {
      _likedSongIds.add(songId);
      if (!_playlists.containsKey('Liked Songs')) {
        createPlaylist('Liked Songs');
      }
      addSongToPlaylist('Liked Songs', songId);
    }
    _saveLikes();
    notifyListeners();
  }

  List<Song> get likedSongs =>
      _allSongs.where((s) => _likedSongIds.contains(s.id)).toList();

  // ── Playlists ─────────────────────────────────────────────────────────────

  /// Map of playlist name → list of song IDs.
  final Map<String, List<String>> _playlists = {};

  Map<String, List<String>> get playlists => _playlists;

  List<String> get playlistNames => _playlists.keys.toList();

  void createPlaylist(String name) {
    if (!_playlists.containsKey(name)) {
      _playlists[name] = [];
      _savePlaylists();
      notifyListeners();
    }
  }

  void addSongToPlaylist(String playlistName, String songId) {
    final list = _playlists[playlistName];
    if (list != null && !list.contains(songId)) {
      list.add(songId);
      _savePlaylists();
      notifyListeners();
    }
  }

  bool isSongInPlaylist(String playlistName, String songId) {
    return _playlists[playlistName]?.contains(songId) ?? false;
  }

  void deletePlaylist(String name) {
    _playlists.remove(name);
    _savePlaylists();
    notifyListeners();
  }

  void removeSongFromPlaylist(String playlistName, String songId) {
    _playlists[playlistName]?.remove(songId);
    _savePlaylists();
    notifyListeners();
  }

  /// Returns actual [Song] objects for a given playlist name.
  List<Song> getSongsInPlaylist(String playlistName) {
    final ids = _playlists[playlistName];
    if (ids == null) return [];
    return _allSongs.where((s) => ids.contains(s.id)).toList();
  }
}
