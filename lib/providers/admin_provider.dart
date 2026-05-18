/// File: lib/providers/admin_provider.dart
/// Role: Centralized provider managing administrator actions such as category additions,
/// deletions, and broadcasting database notifications for uploaded/removed songs.

import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../providers/music_provider.dart';
import '../services/supabase_service.dart';

/// State management class handling admin-only database modifications.
class AdminProvider extends ChangeNotifier {
  bool _isLoading = false;

  /// Check showing if an administrative task is currently executing.
  bool get isLoading => _isLoading;

  /// Publishes a new category to Supabase database.
  ///
  /// [musicProvider] User music provider instance to trigger refresh.
  /// [name] Name of the new category.
  /// [color] Hex color string for theme visualization.
  Future<void> addCategory(MusicProvider musicProvider, String name, String color) async {
    _isLoading = true;
    notifyListeners();
    try {
      // Writes the category data directly to database.
      await SupabaseService.instance.addCategory(name, color);
      
      // Syncs user catalog categories immediately.
      await musicProvider.fetchCategories();
      
      // Broadcast notice to notify all users.
      await addSongAddedNotification('Admin added new category: "$name"');
    } catch (e) {
      print('Error adding category: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Removes an existing category from Supabase database.
  ///
  /// [musicProvider] User music provider instance to trigger refresh.
  /// [name] Category name to delete.
  Future<void> deleteCategory(MusicProvider musicProvider, String name) async {
    _isLoading = true;
    notifyListeners();
    try {
      // Deletes the category record from database.
      await SupabaseService.instance.deleteCategory(name);
      
      // Syncs user catalog categories immediately.
      await musicProvider.fetchCategories();
      
      // Broadcast notice to notify all users.
      await addSongDeletedNotification('Admin removed category: "$name"');
    } catch (e) {
      print('Error deleting category: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Admin tool to upload/publish a new song to Supabase Storage and database.
  ///
  /// [musicProvider] User music provider instance to trigger refresh.
  /// [title] The song track title.
  /// [artist] The artist name.
  /// [album] The album label.
  /// [category] The genre tag.
  /// [audioBytes] Binary byte array of audio track.
  /// [audioFileName] Raw audio local filename.
  /// [coverBytes] Optional binary byte array of cover art image.
  /// [coverFileName] Optional cover local filename.
  Future<void> uploadSong({
    required MusicProvider musicProvider,
    required String title,
    required String artist,
    required String album,
    required String category,
    required Uint8List audioBytes,
    required String audioFileName,
    Uint8List? coverBytes,
    String? coverFileName,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      // Directs the file byte streams and DB row writing to Supabase.
      await SupabaseService.instance.publishSong(
        title: title,
        artist: artist,
        album: album,
        category: category,
        audioBytes: audioBytes,
        audioFileName: audioFileName,
        coverBytes: coverBytes,
        coverFileName: coverFileName,
      );

      // Triggers general user catalog reload so standard clients show the change.
      await musicProvider.fetchSongs();

      // Sends broadcast alert to users cataloging feed.
      await addSongAddedNotification('Added song: "$title"');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Admin tool to cascade delete a song from Supabase Storage and database.
  ///
  /// [musicProvider] User music provider instance to trigger refresh.
  /// [id] Primary key of the song to delete.
  /// [title] Title of the track (for notification broadcasting).
  Future<void> deleteSong({
    required MusicProvider musicProvider,
    required dynamic id,
    required String title,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      // Cascades remote database record and storage deletion.
      await SupabaseService.instance.deleteSong(id);

      // Triggers general user catalog reload so standard clients show the change.
      await musicProvider.fetchSongs();

      // Sends broadcast alert to users cataloging feed.
      await addSongDeletedNotification('Deleted song: "$title"');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Broadcasts a general notification alerting all users about a new song addition.
  ///
  /// [message] The notice log message string.
  Future<void> addSongAddedNotification(String message) async {
    await SupabaseService.instance.postNotification(message, 1); // 1 = AppNotificationType.songAdded
  }

  /// Broadcasts a general notification alerting all users about a song deletion.
  ///
  /// [message] The notice log message string.
  Future<void> addSongDeletedNotification(String message) async {
    await SupabaseService.instance.postNotification(message, 2); // 2 = AppNotificationType.songDeleted
  }
}
