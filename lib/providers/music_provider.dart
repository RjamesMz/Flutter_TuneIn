
// ignore_for_file: avoid_print, unintended_html_in_doc_comment

import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/song.dart';
import '../services/music_service.dart';
import '../services/download_service.dart';
import '../services/supabase_service.dart';
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
  StreamSubscription? _notificationsSub;
  final List<AppNotificationWithUser> _allNotifications = [];
  String      _selectedCategory  = MusicCategories.all;
  bool        _isLoading         = false;
  bool        _isSearching       = false;
  String      _searchQuery       = '';
  String?     _userId;
  String?     _errorMessage;

  final Map<String, int> _playlistIds = {};

  static const String _playlistsKey = 'user_playlists';
  static const String _likesKey = 'user_likes';

  MusicProvider() {
    _loadData();
  }

  void updateUser(String? userId) {
    if (_userId == userId) return;
    _userId = userId;
    if (_userId != null) {
      _loadRemoteData();
    } else {
      _playlists.clear();
      _playlistIds.clear();
      _likedSongIds.clear();
      _allNotifications.clear();
      _notificationsSub?.cancel();
      _notificationsSub = null;
      notifyListeners();
    }
  }

  void _setupNotificationSubscription() {
    _notificationsSub?.cancel();
    if (_userId == null) return;

    _notificationsSub = SupabaseService.instance.getNotificationsStream(_userId!).listen((data) {
      _allNotifications.clear();
      for (final row in data) {
        final rowUserId = row['user_id'] as String?;
        // Only keep global (null) or this user's notifications
        if (rowUserId == null || rowUserId == _userId) {
          _allNotifications.add(AppNotificationWithUser(
            message: row['message'] as String,
            time: DateTime.parse(row['created_at'] as String).toLocal(),
            type: AppNotificationType.values[row['type'] as int? ?? 0],
            userId: rowUserId,
          ));
        }
      }
      notifyListeners();
    });
  }

  Future<void> _loadRemoteData() async {
    if (_userId == null) return;
    
    try {
      final remotePlaylists = await SupabaseService.instance.getUserPlaylists(_userId!);
      _playlists.clear();
      _playlistIds.clear();
      
      for (final p in remotePlaylists) {
        final name = p['name'] as String;
        final id = p['id'] as int;
        _playlistIds[name] = id;
        
        final songs = await SupabaseService.instance.getSongsInPlaylist(id);
        _playlists[name] = songs;

        if (name == 'Liked Songs') {
          _likedSongIds.clear();
          _likedSongIds.addAll(songs);
        }
      }
      notifyListeners();
    } catch (e) {
      print('Error loading remote playlists: $e');
    }
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

    // Load playlists (fallback to local if remote fails or not yet loaded)
    final playlistsJson = prefs.getString(_playlistsKey);
    if (playlistsJson != null && _playlists.isEmpty) {
      try {
        final Map<String, dynamic> decoded = json.decode(playlistsJson);
        decoded.forEach((key, value) {
          _playlists[key] = List<String>.from(value);
        });
      } catch (_) {}
    }



    // Subscribe to Notifications
    _setupNotificationSubscription();

    notifyListeners();
  }

  @override
  void dispose() {
    _notificationsSub?.cancel();
    super.dispose();
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

  // ── In-app Notifications ─────────────────────────────────────────────────
  // Simple, local notification items shown on the Notifications page.
  // Not push notifications — just UI messages for user actions like add/delete.

  List<AppNotification> get notifications => _allNotifications
      .where((n) => n.userId == _userId)
      .toList();

  List<AppNotification> get songNotifications => _allNotifications
      .where((n) => n.userId == null)
      .toList();

  void addAppNotification(String message) {
    if (_userId == null) return;
    SupabaseService.instance.postNotification(message, AppNotificationType.general.index, userId: _userId);
  }

  void addSongAddedNotification(String message) {
    SupabaseService.instance.postNotification(message, AppNotificationType.songAdded.index);
  }

  void addSongDeletedNotification(String message) {
    SupabaseService.instance.postNotification(message, AppNotificationType.songDeleted.index);
  }

  void clearNotifications() {
    if (_userId == null) return;
    SupabaseService.instance.clearUserNotifications(_userId!);
  }

  void clearSongNotifications() {
    SupabaseService.instance.clearGlobalNotifications();
  }

  String _songTitle(String id) {
    try {
      return _allSongs.firstWhere((s) => s.id == id).title;
    } catch (_) {
      return 'Unknown';
    }
  }

  

  List<String> get playlistNames => _playlists.keys.toList();

  Future<void> createPlaylist(String name) async {
    if (_userId == null) return;
    if (!_playlists.containsKey(name)) {
      try {
        final id = await SupabaseService.instance.createPlaylist(_userId!, name);
        _playlistIds[name] = id;
        _playlists[name] = [];
        _savePlaylists(); // local fallback
        notifyListeners();
      } catch (e) {
        print('Error creating playlist: $e');
      }
    }
  }

  Future<void> addSongToPlaylist(String playlistName, String songId) async {
    final playlistId = _playlistIds[playlistName];
    if (playlistId == null && _userId != null) {
       // If it exists locally but not remotely, create it remotely
       await createPlaylist(playlistName);
    }
    
    final remoteId = _playlistIds[playlistName];
    final list = _playlists[playlistName];
    
    if (list != null && !list.contains(songId)) {
      list.add(songId);
      if (remoteId != null) {
        try {
          await SupabaseService.instance.addSongToPlaylist(remoteId, songId);
        } catch (e) {
          print('Error adding song to remote playlist: $e');
        }
      }
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

  Future<void> deletePlaylist(String name) async {
    final id = _playlistIds[name];
    if (id != null) {
      try {
        await SupabaseService.instance.deletePlaylist(id);
      } catch (e) {
        print('Error deleting remote playlist: $e');
      }
    }
    _playlists.remove(name);
    _playlistIds.remove(name);
    _savePlaylists();
    addAppNotification('Deleted playlist "$name"');
    notifyListeners();
  }

  Future<void> removeSongFromPlaylist(String playlistName, String songId) async {
    final id = _playlistIds[playlistName];
    if (id != null) {
      try {
        await SupabaseService.instance.removeSongFromPlaylist(id, songId);
      } catch (e) {
        print('Error removing song from remote playlist: $e');
      }
    }
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
        time: DateTime.parse(json['time'] as String).toLocal(),
        type: AppNotificationType.values[json['type'] as int? ?? 0],
      );
}

class AppNotificationWithUser extends AppNotification {
  final String? userId;
  AppNotificationWithUser({
    required super.message,
    required super.time,
    super.type,
    this.userId,
  });
}
