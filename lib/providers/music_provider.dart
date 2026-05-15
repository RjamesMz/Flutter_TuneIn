
// ignore_for_file: avoid_print, unintended_html_in_doc_comment

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/song.dart';
import '../services/music_service.dart';
import '../services/download_service.dart';
import '../core/app_strings.dart';

enum AppNotificationType {
  general,
  songAdded,
  songDeleted,
}

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
  static const String _notificationsKey = 'user_notifications';

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

    // Load downloads
    try {
      final downloads = await DownloadService.instance.getDownloadedSongs();
      for (final s in downloads) {
        _downloadedSongIds.add(s.id);
      }
    } catch (_) {}

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

    // Load notifications
    final notesJson = prefs.getString(_notificationsKey);
    if (notesJson != null) {
      try {
        final List<dynamic> decoded = json.decode(notesJson);
        _notifications.clear();
        _notifications.addAll(decoded.map((e) => AppNotification.fromJson(e as Map<String, dynamic>)));
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

  Future<void> _saveNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = _notifications.map((n) => n.toJson()).toList();
    await prefs.setString(_notificationsKey, json.encode(jsonList));
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

  // ── In-app Notifications ─────────────────────────────────────────────────
  // Simple, local notification items shown on the Notifications page.
  // Not push notifications — just UI messages for user actions like add/delete.
  final List<AppNotification> _notifications = [];

  List<AppNotification> get notifications => List.unmodifiable(_notifications);

  List<AppNotification> get songNotifications => _notifications
      .where(
        (notification) =>
            notification.type == AppNotificationType.songAdded ||
            notification.type == AppNotificationType.songDeleted,
      )
      .toList();

  void addAppNotification(String message) {
    _notifications.insert(0, AppNotification(message: message, time: DateTime.now()));
    _saveNotifications();
    notifyListeners();
  }

  void addSongAddedNotification(String message) {
    _notifications.insert(
      0,
      AppNotification(
        message: message,
        time: DateTime.now(),
        type: AppNotificationType.songAdded,
      ),
    );
    _saveNotifications();
    notifyListeners();
  }

  void addSongDeletedNotification(String message) {
    _notifications.insert(
      0,
      AppNotification(
        message: message,
        time: DateTime.now(),
        type: AppNotificationType.songDeleted,
      ),
    );
    _saveNotifications();
    notifyListeners();
  }

  void clearNotifications() {
    _notifications.clear();
    _saveNotifications();
    notifyListeners();
  }

  void clearSongNotifications() {
    _notifications.removeWhere(
      (notification) =>
          notification.type == AppNotificationType.songAdded ||
          notification.type == AppNotificationType.songDeleted,
    );
    _saveNotifications();
    notifyListeners();
  }

  String _songTitle(String id) {
    try {
      return _allSongs.firstWhere((s) => s.id == id).title;
    } catch (_) {
      return 'Unknown';
    }
  }

  

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
      // add notification
      final title = _songTitle(songId);
      addAppNotification('Added "$title" to "$playlistName"');
      notifyListeners();
    }
  }

  bool isSongInPlaylist(String playlistName, String songId) {
    return _playlists[playlistName]?.contains(songId) ?? false;
  }

  void deletePlaylist(String name) {
    _playlists.remove(name);
    _savePlaylists();
    addAppNotification('Deleted playlist "$name"');
    notifyListeners();
  }

  void removeSongFromPlaylist(String playlistName, String songId) {
    _playlists[playlistName]?.remove(songId);
    _savePlaylists();
    final title = _songTitle(songId);
    addAppNotification('Removed "$title" from "$playlistName"');
    notifyListeners();
  }

  /// Returns actual [Song] objects for a given playlist name.
  List<Song> getSongsInPlaylist(String playlistName) {
    final ids = _playlists[playlistName];
    if (ids == null) return [];
    return _allSongs.where((s) => ids.contains(s.id)).toList();
  }

  // ── Downloads ─────────────────────────────────────────────────────────────

  final Set<String> _downloadedSongIds = {};
  
  bool isDownloaded(String songId) => _downloadedSongIds.contains(songId);

  Future<void> downloadSong(Song song) async {
    if (isDownloaded(song.id)) return;
    try {
      await DownloadService.instance.downloadSong(song, null);
      _downloadedSongIds.add(song.id);
      notifyListeners();
    } catch (e) {
      print('Download failed: $e');
    }
  }

  Future<void> removeDownload(Song song) async {
    try {
      await DownloadService.instance.deleteDownload(song);
      _downloadedSongIds.remove(song.id);
      addAppNotification('Removed download: "${song.title}"');
      notifyListeners();
    } catch (e) {
      print('Remove download failed: $e');
    }
  }

  List<Song> get downloadedSongs {
    return _allSongs.where((s) => _downloadedSongIds.contains(s.id)).toList();
  }
}

class AppNotification {
  final String message;
  final DateTime time;
  final AppNotificationType type;
  AppNotification({
    required this.message,
    required this.time,
    this.type = AppNotificationType.general,
  });

  Map<String, dynamic> toJson() => {
        'message': message,
        'time': time.toIso8601String(),
        'type': type.index,
      };

  factory AppNotification.fromJson(Map<String, dynamic> json) => AppNotification(
        message: json['message'] as String,
        time: DateTime.parse(json['time'] as String),
        type: AppNotificationType.values[json['type'] as int? ?? 0],
      );
}
