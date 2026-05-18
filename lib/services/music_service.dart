/// File: lib/services/music_service.dart
/// Role: Lightweight data-access wrapper that queries the Supabase `songs` table
/// and returns typed `Song` instances to the app's providers.
///
/// This file only handles simple read/search operations; it intentionally
/// leaves write operations (publish/delete) to `SupabaseService`.

// ignore_for_file: unnecessary_brace_in_string_interps

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/song.dart';

/// Fetches songs exclusively from the Supabase database.
class MusicService {
  MusicService._();

  /// Global singleton instance of [MusicService].
  static final MusicService instance = MusicService._();

  final _supabase = Supabase.instance.client;

  /// Returns the full catalog from Supabase.
  ///
  /// Returns a `Future` that completes with a `List<Song>` containing
  /// every row in the `songs` table mapped to the `Song` model.
  Future<List<Song>> fetchSongs() async {
    final response = await _supabase.from('songs').select();
    // Map raw JSON rows to typed Song objects for consumers.
    return (response as List<dynamic>)
        .map((json) => Song.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Returns songs filtered by [query] (title, artist, or album).
  ///
  /// [query] text used to filter songs. If empty or whitespace, this method
  /// delegates to [fetchSongs()]. The search uses Supabase/PostgREST ILIKE
  /// filters on `title`, `artist`, and `album`.
  Future<List<Song>> search(String query) async {
    if (query.trim().isEmpty) return fetchSongs();

    // PostgREST-style OR clause: ILIKE is case-insensitive partial match.
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
