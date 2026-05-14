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
    final fileName = '$userId.${DateTime.now().millisecondsSinceEpoch}.$fileExt';
    final filePath = 'profiles/$fileName';

    await _supabase.storage.from('avatars').upload(
      filePath,
      imageFile,
      fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
    );

    return _supabase.storage.from('avatars').getPublicUrl(filePath);
  }

  /// Upload raw bytes to a bucket (works on Android emulator where path is null).
  Future<String> _uploadBytes(String bucketName, String path, Uint8List bytes, String mimeType) async {
    await _supabase.storage.from(bucketName).uploadBinary(
      path,
      bytes,
      fileOptions: FileOptions(cacheControl: '3600', upsert: true, contentType: mimeType),
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
    final audioUrl = await _uploadBytes('songs', audioPath, audioBytes, 'audio/$audioExt');

    // 2. Upload cover image bytes (if provided)
    String coverUrl = 'https://via.placeholder.com/300';
    if (coverBytes != null && coverFileName != null) {
      final coverExt = coverFileName.split('.').last;
      final coverPath = 'covers/$title-$artist-$timestamp.$coverExt';
      coverUrl = await _uploadBytes('avatars', coverPath, coverBytes, 'image/$coverExt');
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

    // 4. Insert metadata into songs table
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
    final res = await _supabase.from('songs').select().order('id', ascending: false) as List<dynamic>;
    return res.map((r) => Map<String, dynamic>.from(r as Map)).toList();
  }

  /// Delete a song by its id (primary key in `songs` table).
  Future<void> deleteSong(dynamic id) async {
    await _supabase.from('songs').delete().eq('id', id);
    // Also attempt to remove the audio file from storage if path is stored in audio_url.
    // Skipping storage object deletion (object path not derived reliably from public URL).
  }
}
