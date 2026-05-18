/// File: lib/providers/music_provider.dart
/// Role: Manages global song catalog listings, search caches, and dynamic genres categories.
/// Acts as the public catalog source for both standard users and administrators.

// ignore_for_file: avoid_print, unintended_html_in_doc_comment

import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/song.dart';
import '../services/music_service.dart';
import '../services/supabase_service.dart';

/// Represents semantic types of notifications for user logs or alerts.
enum AppNotificationType {
  /// General notification type.
  general,
  /// Notification for when a new song is added.
  songAdded,
  /// Notification for when a song is deleted.
  songDeleted,
}

/// Manages the song catalog, search results, and active category filter.
/// Consumed by HomeScreen and SearchScreen.
///
/// Usage:
///   context.read<MusicProvider>().fetchSongs()
///   context.watch<MusicProvider>().displayedSongs
class MusicProvider extends ChangeNotifier {
  List<Song>  _allSongs          = [];
  List<Song>  _searchResults     = [];
  String      _selectedCategory  = 'All';
  bool        _isLoading         = false;
  bool        _isSearching       = false;
  String      _searchQuery       = '';
  String?     _errorMessage;
  List<Map<String, String>> _categories = [];

  /// Constructs a [MusicProvider] and loads initial catalog categories and songs.
  MusicProvider() {
    _loadData();
  }

  /// Bootstraps public catalog and genre categories.
  Future<void> _loadData() async {
    await fetchCategories();
    await fetchSongs();
  }


  /// Returns true if a catalog fetch is actively executing.
  bool    get isLoading        => _isLoading;

  /// Returns true if a text search query is currently executing.
  bool    get isSearching      => _isSearching;

  /// Gets the currently active filtering category name.
  String  get selectedCategory => _selectedCategory;

  /// Gets the active search text input keywords.
  String  get searchQuery      => _searchQuery;

  /// Gets any error message generated during a song fetch lifecycle.
  String? get errorMessage     => _errorMessage;

  /// Gets list of available category items with descriptive elements.
  List<Map<String, String>> get categories  => _categories;

  /// Gets the names of all loaded categories.
  List<String> get categoryNames => _categories.map((c) => c['name']!).toList();

  /// Songs filtered by the active category (used by HomeScreen).
  List<Song> get filteredSongs {
    if (_selectedCategory == 'All') return _allSongs;
    return _allSongs
        .where((s) => s.category == _selectedCategory)
        .toList();
  }

  /// Results returned by search (used by SearchScreen).
  List<Song> get searchResults => _searchResults;

  /// All songs regardless of filter.
  List<Song> get allSongs => _allSongs;


  /// Fetches the full song catalog from [MusicService].
  ///
  /// [forceRefresh] True to bypass caching and query remote tables immediately.
  Future<void> fetchSongs({bool forceRefresh = false}) async {
    if (_allSongs.isNotEmpty && !forceRefresh) return;

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
  ///
  /// [category] Target genre category name.
  void selectCategory(String category) {
    if (_selectedCategory == category) return;
    _selectedCategory = category;
    notifyListeners();
  }

  /// Searches catalog by [query], updating [searchResults].
  ///
  /// [query] Keyword string to query.
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
  ///
  /// [categories] Selected filtering categories.
  /// [query] Additional search text context.
  void searchWithCategories(Set<String> categories, [String query = '']) {
    _searchQuery  = query;
    _isSearching  = false;

    Iterable<Song> pool = _allSongs.where(
      (s) => categories.contains(s.category),
    );

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


  /// Loads song catalog genre categories from remote DB.
  Future<void> fetchCategories() async {
    try {
      _categories = await SupabaseService.instance.getCategories();
      notifyListeners();
    } catch (e) {
      print('Error fetching categories: $e');
    }
  }
}

/// Represents in-app logged alerts or transactions shown in user feed.
class AppNotification {
  /// The descriptive alert message text.
  final String message;

  /// The timestamp the record was logged.
  final DateTime time;

  /// The severity/semantic classification.
  final AppNotificationType type;

  /// Constructs an [AppNotification] item.
  ///
  /// [message] The notice message string context.
  /// [time] Logged timestamp.
  /// [type] Notification classification type.
  AppNotification({
    required this.message,
    required this.time,
    this.type = AppNotificationType.general,
  });

  /// Formats attributes into JSON properties.
  Map<String, dynamic> toJson() => {
        'message': message,
        'time': time.toIso8601String(),
        'type': type.index,
      };

  /// Constructs an [AppNotification] from a JSON map representation.
  ///
  /// [json] Map of string-object pairs.
  factory AppNotification.fromJson(Map<String, dynamic> json) => AppNotification(
        message: json['message'] as String,
        time: DateTime.parse(json['time'] as String).toLocal(),
        type: AppNotificationType.values[json['type'] as int? ?? 0],
      );
}

/// Represents in-app notifications specifically mapped or restricted to a targeted user.
class AppNotificationWithUser extends AppNotification {
  /// The specific target user ID, or null if broadcast to all users.
  final String? userId;

  /// Constructs an [AppNotificationWithUser] linked optionally to a user ID.
  ///
  /// [message] The text content of the notification.
  /// [time] Timestamp of notification arrival.
  /// [type] Category classification of the notice.
  /// [userId] The unique ID of the target user receiving this notification.
  AppNotificationWithUser({
    required super.message,
    required super.time,
    super.type,
    this.userId,
  });
}
