// ignore_for_file: avoid_print

import 'dart:io';
import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:audioplayers/audioplayers.dart';

class SupabaseService {
  SupabaseService._();
  static final SupabaseService instance = SupabaseService._();

  final SupabaseClient _supabase = Supabase.instance.client;

  /// Upload an avatar image (as File) to Supabase Storage.
  Future<String> uploadAvatar(String userId, File imageFile) async {
    final fileExt = imageFile.path.split('.').last;
    final fileName =
        '$userId.${DateTime.now().millisecondsSinceEpoch}.$fileExt';
    final filePath = 'profiles/$fileName';

    await _supabase.storage
        .from('avatars')
        .upload(
          filePath,
          imageFile,
          fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
        );

    return _supabase.storage.from('avatars').getPublicUrl(filePath);
  }

  /// Upload raw bytes to a bucket (works on Android emulator where path is null).
  Future<String> _uploadBytes(
    String bucketName,
    String path,
    Uint8List bytes,
    String mimeType,
  ) async {
    await _supabase.storage
        .from(bucketName)
        .uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(
            cacheControl: '3600',
            upsert: true,
            contentType: mimeType,
          ),
        );
    return _supabase.storage.from(bucketName).getPublicUrl(path);
  }

  /// Full flow: Upload audio bytes + optional cover image, then insert metadata into the songs table.
  Future<void> publishSong({
    required String title,
    required String artist,
    required String album,
    required String category,
    required Uint8List audioBytes,
    required String audioFileName,
    Uint8List? coverBytes,
    String? coverFileName,
  }) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;

    // 1. Upload audio bytes
    final audioExt = audioFileName.split('.').last;
    final audioPath = 'uploads/$title-$artist-$timestamp.$audioExt';
    final audioUrl = await _uploadBytes(
      'songs',
      audioPath,
      audioBytes,
      'audio/$audioExt',
    );

    // 2. Upload cover image bytes (if provided)
    String coverUrl = 'https://via.placeholder.com/300';
    String? finalCoverPath;
    if (coverBytes != null && coverFileName != null) {
      final coverExt = coverFileName.split('.').last;
      finalCoverPath = 'covers/$title-$artist-$timestamp.$coverExt';
      coverUrl = await _uploadBytes(
        'avatars',
        finalCoverPath,
        coverBytes,
        'image/$coverExt',
      );
    }

    // 3. Get actual duration using audioplayers
    int durationSeconds = 0;
    try {
      final player = AudioPlayer();
      await player.setSourceUrl(audioUrl);

      // Wait for duration to be parsed (it usually fires immediately after setting source)
      final duration = await player.getDuration();
      if (duration != null) {
        durationSeconds = duration.inSeconds;
      } else {
        // Fallback: wait briefly if getDuration() was null (still loading metadata)
        await Future.delayed(const Duration(milliseconds: 500));
        final lateDuration = await player.getDuration();
        if (lateDuration != null) {
          durationSeconds = lateDuration.inSeconds;
        }
      }
      await player.dispose();
    } catch (e) {
      print('Error getting duration: $e');
    }

    // 4. Insert metadata into songs table. Also persist the storage object
    // paths so we can safely remove the objects later when a song is deleted.
    await _supabase.from('songs').insert({
      'title': title,
      'artist': artist,
      'album': album,
      'category': category,
      'duration_seconds': durationSeconds,
      'audio_url': audioUrl,
      'cover_url': coverUrl,
    });
  }

  /// Fetch all songs metadata from the `songs` table.
  Future<List<Map<String, dynamic>>> listSongs() async {
    final res =
        await _supabase.from('songs').select().order('id', ascending: false)
            as List<dynamic>;
    return res.map((r) => Map<String, dynamic>.from(r as Map)).toList();
  }

  /// Delete a song by its id (primary key in `songs` table).
  Future<void> deleteSong(dynamic id) async {
    // 1) Read the stored object URLs for audio and cover
    String? audioUrl;
    String? coverUrl;
    try {
      final row = await _supabase
          .from('songs')
          .select('audio_url, cover_url')
          .eq('id', id)
          .maybeSingle();
      if (row != null) {
        audioUrl = row['audio_url'] as String?;
        coverUrl = row['cover_url'] as String?;
      }
    } catch (_) {}

    // 2) Remove storage objects by extracting the path from the URL
    try {
      if (audioUrl != null && audioUrl.contains('/public/songs/')) {
        final encodedPath = audioUrl.split('/public/songs/').last.split('?').first;
        final path = Uri.decodeComponent(encodedPath);
        await _supabase.storage.from('songs').remove([path]);
      }
    } catch (e) {
      print('Failed to remove audio object: $e');
    }
    try {
      if (coverUrl != null && coverUrl.contains('/public/avatars/')) {
        final encodedPath = coverUrl.split('/public/avatars/').last.split('?').first;
        final path = Uri.decodeComponent(encodedPath);
        await _supabase.storage.from('avatars').remove([path]);
      }
    } catch (e) {
      print('Failed to remove cover object: $e');
    }

    // 3) Delete DB row
    await _supabase.from('songs').delete().eq('id', id);
  }

  // ── Global & User Real-time Notifications ─────────────────────────────────

  Stream<List<Map<String, dynamic>>> getNotificationsStream(String userId) {
    // This will listen to notifications where user_id is NULL (global) OR matches the user
    // Note: Supabase basic stream filters are limited, so we often listen to the whole table 
    // and filter in the app, or use a more advanced approach. 
    // For now, we'll keep it simple and filter in the app or use multiple streams.
    return _supabase.from('notifications').stream(primaryKey: ['id']).order('created_at', ascending: false);
  }

  Future<void> postNotification(String message, int type, {String? userId}) async {
    try {
      await _supabase.from('notifications').insert({
        'message': message,
        'type': type,
        'user_id': userId,
      });
    } catch (e) {
      print('Error posting notification: $e');
    }
  }

  Future<void> clearUserNotifications(String userId) async {
    try {
      await _supabase.from('notifications').delete().eq('user_id', userId);
    } catch (e) {
      print('Error clearing user notifications: $e');
    }
  }

  Future<void> clearGlobalNotifications() async {
    try {
      await _supabase.from('notifications').delete().filter('user_id', 'is', null);
    } catch (e) {
      print('Error clearing global notifications: $e');
    }
  }

  // ── Playlist Management ──────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getUserPlaylists(String userId) async {
    final res = await _supabase
        .from('playlists')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: true);
    return List<Map<String, dynamic>>.from(res);
  }

  Future<List<String>> getSongsInPlaylist(int playlistId) async {
    final res = await _supabase
        .from('playlist_songs')
        .select('song_id')
        .eq('playlist_id', playlistId);
    return (res as List).map((item) => item['song_id'] as String).toList();
  }

  Future<int> createPlaylist(String userId, String name) async {
    final res = await _supabase.from('playlists').insert({
      'user_id': userId,
      'name': name,
    }).select('id').single();
    return res['id'] as int;
  }

  Future<void> deletePlaylist(int playlistId) async {
    await _supabase.from('playlists').delete().eq('id', playlistId);
  }

  Future<void> addSongToPlaylist(int playlistId, String songId) async {
    await _supabase.from('playlist_songs').insert({
      'playlist_id': playlistId,
      'song_id': songId,
    });
  }

  Future<void> removeSongFromPlaylist(int playlistId, String songId) async {
    await _supabase
        .from('playlist_songs')
        .delete()
        .eq('playlist_id', playlistId)
        .eq('song_id', songId);
  }

  // ── Category Management ──────────────────────────────────────────────────

  Future<List<Map<String, String>>> getCategories() async {
    final res = await _supabase
        .from('categories')
        .select('name, color')
        .order('name', ascending: true);
    return (res as List).map((item) => {
      'name': item['name'] as String,
      'color': (item['color'] as String?) ?? '#3B6B8A',
    }).toList();
  }

  Future<void> addCategory(String name, String color) async {
    await _supabase.from('categories').insert({
      'name': name,
      'color': color,
    });
  }

  Future<void> deleteCategory(String name) async {
    await _supabase.from('categories').delete().eq('name', name);
  }
}
