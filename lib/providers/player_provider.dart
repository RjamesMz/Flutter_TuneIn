import 'package:flutter/foundation.dart';
import '../models/song.dart';

// ─── Player Provider ──────────────────────────────────────────────────────────
/// Manages playback state: current song, play/pause, next/previous.
/// This is a mock player — no actual audio engine is wired up.
/// In production, swap the internals for just_audio / audioplayers.
///
/// Usage:
///   context.read<PlayerProvider>().play(song, queue: songs)
///   context.watch<PlayerProvider>().isPlaying
class PlayerProvider extends ChangeNotifier {
  // ── State ──────────────────────────────────────────────────────────────────
  Song?       _currentSong;
  List<Song>  _queue        = [];
  int         _currentIndex = 0;
  bool        _isPlaying    = false;
  bool        _isShuffled   = false;
  bool        _isRepeating  = false;
  Duration    _position     = Duration.zero;

  // ── Getters ────────────────────────────────────────────────────────────────
  Song?      get currentSong   => _currentSong;
  bool       get isPlaying     => _isPlaying;
  bool       get isShuffled    => _isShuffled;
  bool       get isRepeating   => _isRepeating;
  Duration   get position      => _position;
  List<Song> get queue         => _queue;
  int        get currentIndex  => _currentIndex;

  bool get hasPrevious => _currentIndex > 0;
  bool get hasNext     => _currentIndex < _queue.length - 1;

  // ── Actions ────────────────────────────────────────────────────────────────

  /// Loads [song] into the player and begins playback.
  /// Optionally sets the full [queue] for next/previous support.
  void play(Song song, {List<Song>? queue}) {
    if (queue != null) {
      _queue        = queue;
      _currentIndex = queue.indexOf(song);
      if (_currentIndex == -1) {
        _queue.insert(0, song);
        _currentIndex = 0;
      }
    } else if (!_queue.contains(song)) {
      _queue.add(song);
      _currentIndex = _queue.length - 1;
    } else {
      _currentIndex = _queue.indexOf(song);
    }

    _currentSong = song;
    _isPlaying   = true;
    _position    = Duration.zero;
    notifyListeners();
  }

  /// Pauses playback.
  void pause() {
    _isPlaying = false;
    notifyListeners();
  }

  /// Resumes playback.
  void resume() {
    if (_currentSong == null) return;
    _isPlaying = true;
    notifyListeners();
  }

  /// Toggles between play and pause.
  void togglePlayPause() {
    if (_isPlaying) {
      pause();
    } else {
      resume();
    }
  }

  /// Skips to the next song in the queue.
  void next() {
    if (_queue.isEmpty) return;
    if (_isShuffled) {
      _currentIndex = (DateTime.now().millisecondsSinceEpoch % _queue.length).toInt();
    } else if (hasNext) {
      _currentIndex++;
    } else if (_isRepeating) {
      _currentIndex = 0;
    }
    _currentSong = _queue[_currentIndex];
    _isPlaying   = true;
    _position    = Duration.zero;
    notifyListeners();
  }

  /// Skips to the previous song in the queue.
  void previous() {
    if (_queue.isEmpty) return;
    // If more than 3 s in, restart current song instead of going back
    if (_position.inSeconds > 3) {
      _position = Duration.zero;
      notifyListeners();
      return;
    }
    if (hasPrevious) {
      _currentIndex--;
    } else if (_isRepeating) {
      _currentIndex = _queue.length - 1;
    }
    _currentSong = _queue[_currentIndex];
    _isPlaying   = true;
    _position    = Duration.zero;
    notifyListeners();
  }

  /// Toggles shuffle mode.
  void toggleShuffle() {
    _isShuffled = !_isShuffled;
    notifyListeners();
  }

  /// Toggles repeat mode.
  void toggleRepeat() {
    _isRepeating = !_isRepeating;
    notifyListeners();
  }

  /// Updates the playback position (called by a timer or audio engine).
  void updatePosition(Duration position) {
    _position = position;
    notifyListeners();
  }

  /// Stops playback and clears current song.
  void stop() {
    _currentSong  = null;
    _isPlaying    = false;
    _position     = Duration.zero;
    notifyListeners();
  }
}
