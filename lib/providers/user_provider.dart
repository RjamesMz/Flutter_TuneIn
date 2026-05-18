/// File: lib/providers/user_provider.dart
/// Role: Centralized provider managing individual standard user states and session contexts,
/// including private playlists, song likes (favorites), offline downloads cache set,
/// and personal/song notification stream subscriptions.

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/song.dart';
import '../providers/music_provider.dart';
import '../services/supabase_service.dart';
import '../services/download_service.dart';

/// State management class managing standard user states.
class UserProvider extends ChangeNotifier {
  String? _userId;
  MusicProvider? _musicProvider;

  final Set<String> _likedSongIds = {};
  final Set<String> _downloadedSongIds = {};
  final Map<String, List<String>> _playlists = {};
  final Map<String, int> _playlistIds = {};
  final List<AppNotificationWithUser> _allNotifications = [];
  StreamSubscription? _notificationsSub;

  static const String _playlistsKey = 'user_playlists';
  static const String _likesKey = 'user_likes';

  /// Constructs a [UserProvider] and loads local preference caches.
  UserProvider() {
    _loadLocalCaches();
  }

  /// Binds the provider to the current Auth and Music context.
  ///
  /// [userId] Active user database ID.
  /// [musicProvider] Music provider reference for catalog song lookups.
  void update(String? userId, MusicProvider musicProvider) {
    _musicProvider = musicProvider;
    if (_userId == userId) return;
    _userId = userId;
    
    if (_userId != null) {
      _loadRemoteData();
      _setupNotificationSubscription();
    } else {
      // Clear personal states to prevent session data leaks on logout.
      _playlists.clear();
      _playlistIds.clear();
      _likedSongIds.clear();
      _allNotifications.clear();
      _notificationsSub?.cancel();
      _notificationsSub = null;
      notifyListeners();
    }
  }

  /// Cancels active stream subscriptions on provider destruction.
  @override
  void dispose() {
    _notificationsSub?.cancel();
    super.dispose();
  }


  /// Retrieves the set of all song IDs marked as favorites.
  Set<String> get likedSongIds => _likedSongIds;

  /// Resolves the liked song IDs into complete [Song] object instances.
  List<Song> get likedSongs {
    final songsPool = _musicProvider?.allSongs ?? [];
    return songsPool.where((s) => _likedSongIds.contains(s.id)).toList();
  }

  /// Retrieves all custom playlists configured for the current session.
  Map<String, List<String>> get playlists => _playlists;

  /// Resolves the offline downloaded song IDs into complete [Song] object instances.
  List<Song> get downloadedSongs {
    final songsPool = _musicProvider?.allSongs ?? [];
    return songsPool.where((s) => _downloadedSongIds.contains(s.id)).toList();
  }

  /// Filters remote logs to return personal notices aimed at this user.
  List<AppNotification> get notifications => _allNotifications
      .where((n) => n.userId == _userId)
      .toList();

  /// Filters remote logs to return global administrative catalog notifications.
  List<AppNotification> get songNotifications => _allNotifications
      .where((n) => n.userId == null)
      .toList();


  /// Verifies if a given song is marked as liked.
  bool isLiked(String songId) => _likedSongIds.contains(songId);

  /// Checks if a song is available offline.
  bool isDownloaded(String songId) => _downloadedSongIds.contains(songId);

  /// Verifies if a song exists within a given playlist.
  bool isSongInPlaylist(String playlistName, String songId) {
    return _playlists[playlistName]?.contains(songId) ?? false;
  }


  /// Toggles the favorite/like status of a specific song.
  Future<void> toggleLike(String songId) async {
    if (_likedSongIds.contains(songId)) {
      _likedSongIds.remove(songId);
      await removeSongFromPlaylist('Liked Songs', songId);
      
      if (_likedSongIds.isEmpty) {
        await deletePlaylist('Liked Songs');
      }
    } else {
      _likedSongIds.add(songId);
      if (!_playlists.containsKey('Liked Songs')) {
        await createPlaylist('Liked Songs');
      }
      await addSongToPlaylist('Liked Songs', songId);
    }
    await _saveLikes();
    notifyListeners();
  }


  /// Creates a new named playlist both locally and remotely in the database.
  Future<void> createPlaylist(String name) async {
    if (_userId == null) return;
    
    if (!_playlists.containsKey(name)) {
      try {
        final id = await SupabaseService.instance.createPlaylist(_userId!, name);
        _playlistIds[name] = id;
        _playlists[name] = [];
        await _savePlaylists();
        notifyListeners();
      } catch (e) {
        print('Error creating playlist: $e');
      }
    }
  }

  /// Inserts a song into the named playlist locally and remotely.
  Future<void> addSongToPlaylist(String playlistName, String songId) async {
    final playlistId = _playlistIds[playlistName];
    if (playlistId == null && _userId != null) {
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
      await _savePlaylists();
      final title = _songTitle(songId);
      addAppNotification('Added "$title" to "$playlistName"');
      notifyListeners();
    }
  }

  /// Deletes a song item from the chosen playlist locally and remotely.
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
    await _savePlaylists();
    final title = _songTitle(songId);
    addAppNotification('Removed "$title" from "$playlistName"');
    notifyListeners();
  }

  /// Completely removes a playlist locally and remotely.
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
    await _savePlaylists();
    addAppNotification('Deleted playlist "$name"');
    notifyListeners();
  }

  /// Returns actual [Song] objects for a given playlist name.
  List<Song> getSongsInPlaylist(String playlistName) {
    final ids = _playlists[playlistName];
    if (ids == null) return [];
    final songsPool = _musicProvider?.allSongs ?? [];
    return songsPool.where((s) => ids.contains(s.id)).toList();
  }


  /// Caches the music track files for offline playback.
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

  /// Purges local offline copies of the music track from the device.
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


  /// Adds a general personal notification in the notification stream.
  void addAppNotification(String message) {
    if (_userId == null) return;
    SupabaseService.instance.postNotification(message, AppNotificationType.general.index, userId: _userId);
  }

  /// Purges all notifications associated with the current user from database.
  void clearNotifications() {
    if (_userId == null) return;
    SupabaseService.instance.clearUserNotifications(_userId!);
  }

  /// Purges all global administrative catalog notifications from database.
  void clearSongNotifications() {
    SupabaseService.instance.clearGlobalNotifications();
  }


  /// Configures real-time channel subscriptions to capture database updates synchronously.
  void _setupNotificationSubscription() {
    _notificationsSub?.cancel();
    if (_userId == null) return;

    _notificationsSub = SupabaseService.instance.getNotificationsStream(_userId!).listen((data) {
      _allNotifications.clear();
      for (final row in data) {
        final rowUserId = row['user_id'] as String?;
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

  /// Restores user-specific playlists and favorites from remote database storage.
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

  /// Bootstraps local configurations, stored preferences, downloaded tracks, and real-time triggers.
  Future<void> _loadLocalCaches() async {
    final prefs = await SharedPreferences.getInstance();
    
    final likesList = prefs.getStringList(_likesKey) ?? [];
    _likedSongIds.addAll(likesList);

    try {
      final downloads = await DownloadService.instance.getDownloadedSongs();
      for (final s in downloads) {
        _downloadedSongIds.add(s.id);
      }
    } catch (_) {}

    final playlistsJson = prefs.getString(_playlistsKey);
    if (playlistsJson != null && _playlists.isEmpty) {
      try {
        final Map<String, dynamic> decoded = json.decode(playlistsJson);
        decoded.forEach((key, value) {
          _playlists[key] = List<String>.from(value);
        });
      } catch (_) {}
    }
    notifyListeners();
  }

  /// Persists liked song ID sets locally.
  Future<void> _saveLikes() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_likesKey, _likedSongIds.toList());
  }

  /// Persists custom playlists structure locally.
  Future<void> _savePlaylists() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_playlistsKey, json.encode(_playlists));
  }

  /// Helper to lookup a song title for formatting notification text logs.
  String _songTitle(String id) {
    try {
      final songsPool = _musicProvider?.allSongs ?? [];
      return songsPool.firstWhere((s) => s.id == id).title;
    } catch (_) {
      return 'Song';
    }
  }
}
