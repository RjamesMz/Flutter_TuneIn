import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import '../models/song.dart';

// ─── Player Provider ──────────────────────────────────────────────────────────
/// Manages real audio playback using the audioplayers package.
/// Handles current song, play/pause, seek, next/previous, shuffle, repeat.
class PlayerProvider extends ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();

  // ── State ──────────────────────────────────────────────────────────────────
  Song? _currentSong;
  List<Song> _queue = [];
  int _currentIndex = 0;
  bool _isPlaying = false;
  bool _isShuffled = false;
  bool _isRepeating = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  // ── Getters ────────────────────────────────────────────────────────────────
  Song? get currentSong => _currentSong;
  bool get isPlaying => _isPlaying;
  bool get isShuffled => _isShuffled;
  bool get isRepeating => _isRepeating;
  Duration get position => _position;
  Duration get duration => _duration;
  List<Song> get queue => _queue;
  int get currentIndex => _currentIndex;

  bool get hasPrevious => _currentIndex > 0;
  bool get hasNext => _currentIndex < _queue.length - 1;

  PlayerProvider() {
    // Live position updates
    _audioPlayer.onPositionChanged.listen((pos) {
      _position = pos;
      notifyListeners();
    });

    // Total duration once loaded
    _audioPlayer.onDurationChanged.listen((dur) {
      _duration = dur;
      notifyListeners();
    });

    // When current track finishes, auto-advance
    _audioPlayer.onPlayerComplete.listen((_) {
      if (_isRepeating) {
        _playCurrentIndex();
      } else if (hasNext) {
        next();
      } else {
        _isPlaying = false;
        _position = Duration.zero;
        notifyListeners();
      }
    });

    // Keep _isPlaying in sync with actual player state
    _audioPlayer.onPlayerStateChanged.listen((state) {
      _isPlaying = state == PlayerState.playing;
      notifyListeners();
    });
  }

  // ── Actions ────────────────────────────────────────────────────────────────

  /// Loads [song] into the player and begins playback.
  Future<void> play(Song song, {List<Song>? queue}) async {
    if (queue != null) {
      _queue = queue;
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
    _position = Duration.zero;
    notifyListeners();

    await _playCurrentIndex();
  }

  Future<void> _playCurrentIndex() async {
    final song = _queue[_currentIndex];
    _currentSong = song;
    notifyListeners();

    await _audioPlayer.play(UrlSource(song.audioUrl));
  }

  /// Pauses playback.
  Future<void> pause() async {
    await _audioPlayer.pause();
  }

  /// Resumes playback.
  Future<void> resume() async {
    if (_currentSong == null) return;
    await _audioPlayer.resume();
  }

  /// Toggles between play and pause.
  Future<void> togglePlayPause() async {
    if (_isPlaying) {
      await pause();
    } else {
      await resume();
    }
  }

  /// Skips to the next song in the queue.
  Future<void> next() async {
    if (_queue.isEmpty) return;
    if (_isShuffled) {
      _currentIndex = (DateTime.now().millisecondsSinceEpoch % _queue.length)
          .toInt();
    } else if (hasNext) {
      _currentIndex++;
    } else if (_isRepeating) {
      _currentIndex = 0;
    } else {
      return;
    }
    _position = Duration.zero;
    await _playCurrentIndex();
  }

  /// Skips to the previous song in the queue.
  Future<void> previous() async {
    if (_queue.isEmpty) return;
    // If more than 3s in, restart current song
    if (_position.inSeconds > 3) {
      await seek(Duration.zero);
      return;
    }
    if (hasPrevious) {
      _currentIndex--;
    } else if (_isRepeating) {
      _currentIndex = _queue.length - 1;
    } else {
      return;
    }
    _position = Duration.zero;
    await _playCurrentIndex();
  }

  /// Seeks to a given position.
  Future<void> seek(Duration position) async {
    await _audioPlayer.seek(position);
    _position = position;
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

  /// Stops playback and clears current song.
  Future<void> stop() async {
    await _audioPlayer.stop();
    _currentSong = null;
    _isPlaying = false;
    _position = Duration.zero;
    _duration = Duration.zero;
    notifyListeners();
  }

  /// Legacy — kept for compatibility. Use [seek] instead.
  void updatePosition(Duration position) {
    seek(position);
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}
