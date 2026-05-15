// ignore_for_file: unnecessary_brace_in_string_interps

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/song.dart';

// ─── Music Service ────────────────────────────────────────────────────────────
/// Fetches songs exclusively from the Supabase database.
class MusicService {
  MusicService._();
  static final MusicService instance = MusicService._();

  final _supabase = Supabase.instance.client;

  /// Returns the full catalog from Supabase.
  Future<List<Song>> fetchSongs() async {
    final response = await _supabase.from('songs').select();
    return (response as List<dynamic>)
        .map((json) => Song.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Returns songs filtered by [query] (title, artist, or album).
  Future<List<Song>> search(String query) async {
    if (query.trim().isEmpty) return fetchSongs();

    final response = await _supabase
        .from('songs')
        .select()
        .or(
          'title.ilike.%${query}%,artist.ilike.%${query}%,album.ilike.%${query}%',
        );

    return (response as List<dynamic>)
        .map((json) => Song.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
