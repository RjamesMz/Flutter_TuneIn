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
      'audio_path': audioPath,
      'cover_url': coverUrl,
      'cover_path': finalCoverPath,
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
    // 1) Read the stored object paths for audio and cover (if available)
    String? audioPath;
    String? coverPath;
    try {
      final row = await _supabase
          .from('songs')
          .select('audio_path, cover_path')
          .eq('id', id)
          .maybeSingle();
      if (row != null) {
        audioPath = row['audio_path'] as String?;
        coverPath = row['cover_path'] as String?;
      }
    } catch (_) {}

    // 2) Remove storage objects if we have their paths
    try {
      if (audioPath != null && audioPath.isNotEmpty) {
        await _supabase.storage.from('songs').remove([audioPath]);
      }
    } catch (e) {
      // Log but continue with DB deletion
      print('Failed to remove audio object: $e');
    }
    try {
      if (coverPath != null && coverPath.isNotEmpty) {
        // If it starts with 'avatars/', it was saved with the old bug. Real path is 'covers/...'
        String path = coverPath;
        if (path.startsWith('avatars/')) {
          path = 'covers/' + path.substring('avatars/'.length);
        }
        await _supabase.storage.from('avatars').remove([path]);
      }
    } catch (e) {
      print('Failed to remove cover object: $e');
    }

    // 3) Delete DB row
    await _supabase.from('songs').delete().eq('id', id);
  }
}
