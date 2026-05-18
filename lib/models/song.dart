/// File: lib/models/song.dart
/// Role: Defines the Song model representing a music track. Handles JSON parsing
/// from Supabase and UI display helpers for durations and track comparisons.

/// Represents a single music track in the TuneIn app.
class Song {
  /// Unique identifier for the song (matches the DB primary key).
  final String id;

  /// Human-readable title.
  final String title;

  /// Artist name.
  final String artist;

  /// Album name.
  final String album;

  /// Category key used for filtering (e.g. "Lo-Fi", "Pop").
  final String category;

  /// Track duration as a Dart [Duration].
  final Duration duration;

  /// URL (or local path) to the cover image.
  final String coverUrl; // Network image URL for album art

  /// URL (or local path) to the audio file.
  final String audioUrl; // Placeholder — may be remote or local

  /// Creates a new [Song] instance.
  ///
  /// [id] Unique identifier matching the DB primary key.
  /// [title] Human-readable title of the track.
  /// [artist] The artist performing the song.
  /// [album] The album that the song belongs to.
  /// [category] The genre or category classification.
  /// [duration] The total playback length of the track.
  /// [coverUrl] The network URL or local path for album art.
  /// [audioUrl] The audio file stream source URL or local path.
  const Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    required this.category,
    required this.duration,
    required this.coverUrl,
    this.audioUrl = '',
  });

  /// Constructs a [Song] from a JSON-like map returned by Supabase.
  ///
  /// [json] is typically a `Map<String, dynamic>` with keys coming from the
  /// `songs` table. Missing fields fall back to sensible defaults.
  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? 'Unknown Title',
      artist: json['artist'] ?? 'Unknown Artist',
      album: json['album'] ?? 'Unknown Album',
      category: json['category'] ?? 'Trending',
      duration: Duration(seconds: json['duration_seconds'] ?? 0),
      coverUrl: json['cover_url'] ?? '',
      audioUrl: json['audio_url'] ?? '',
    );
  }


  /// Returns duration formatted as `m:ss` for display in UI elements.
  String get formattedDuration {
    final minutes = duration.inMinutes;
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  /// Compares two [Song] instances for equality based on their database identifier.
  ///
  /// [other] The object to compare with this instance.
  bool operator ==(Object other) => other is Song && other.id == id;

  @override
  /// Evaluates hash code for the [Song] instance based on its database identifier.
  int get hashCode => id.hashCode;
}
