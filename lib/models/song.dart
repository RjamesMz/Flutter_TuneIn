// ─── Song Model ───────────────────────────────────────────────────────────────
/// Represents a single music track in the TuneIn app.
class Song {
  final String id;
  final String title;
  final String artist;
  final String album;
  final String category;
  final Duration duration;
  final String coverUrl;     // Network image URL for album art
  final String audioUrl;     // Placeholder — no actual audio in mock

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

  // ── Helpers ────────────────────────────────────────────────────────────────
  /// Returns duration formatted as "m:ss"
  String get formattedDuration {
    final minutes = duration.inMinutes;
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  bool operator ==(Object other) => other is Song && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
