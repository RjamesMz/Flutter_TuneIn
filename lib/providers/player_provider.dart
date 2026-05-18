/// File: lib/providers/player_provider.dart
/// Role: Manages real-time audio playback using the audioplayers package.
/// Tracks current song, play/pause states, queue index history, shuffle/repeat parameters,
/// and updates stream positions.

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import '../models/song.dart';
import '../services/download_service.dart';

/// Manages real audio playback using the audioplayers package.
/// Handles current song, play/pause, seek, next/previous, shuffle, repeat.
class PlayerProvider extends ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();

  Song? _currentSong;
  List<Song> _queue = [];
  int _currentIndex = 0;
  bool _isPlaying = false;
  bool _isShuffled = false;
  bool _isRepeating = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;


  /// Retrieves the currently loaded [Song] track.
  Song? get currentSong => _currentSong;

  /// Returns true if audio is actively playing.
  bool get isPlaying => _isPlaying;

  /// Returns true if shuffle order mode is active.
  bool get isShuffled => _isShuffled;

  /// Returns true if repeat/loop mode is active.
  bool get isRepeating => _isRepeating;

  /// Retrieves the current track progress position duration.
  Duration get position => _position;

  /// Retrieves the total duration of the actively loaded audio track.
  Duration get duration => _duration;

  /// Retrieves the active music tracks queue.
  List<Song> get queue => _queue;

  /// Gets the index of the currently playing track in the queue.
  int get currentIndex => _currentIndex;

  /// Returns true if there is a song prior to the current song in the queue.
  bool get hasPrevious => _currentIndex > 0;

  /// Returns true if there is a song after the current song in the queue.
  bool get hasNext => _currentIndex < _queue.length - 1;

  /// Constructs a [PlayerProvider] and configures the audio player listeners.
  PlayerProvider() {
    // Listens to progress ticker updates from the audio device.
    _audioPlayer.onPositionChanged.listen((pos) {
      _position = pos;
      notifyListeners();
    });

    // Listens to track metadata resolution to register the total track length.
    _audioPlayer.onDurationChanged.listen((dur) {
      _duration = dur;
      notifyListeners();
    });

    // Configures auto-advance behaviour when the current song completes playback.
    _audioPlayer.onPlayerComplete.listen((_) {
      if (_isRepeating) {
        _playCurrentIndex();
      } else if (hasNext) {
        next();
      } else {
        stop();
      }
    });

    // Keeps the provider's boolean playing state in sync with external device state updates.
    _audioPlayer.onPlayerStateChanged.listen((state) {
      _isPlaying = state == PlayerState.playing;
      notifyListeners();
    });
  }


  /// Loads [song] into the player and begins playback.
  ///
  /// [song] Target song to load.
  /// [queue] Optional custom queue context to assign.
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

  /// Looks up local cached audio files or streams online sources to run playback.
  Future<void> _playCurrentIndex() async {
    final song = _queue[_currentIndex];
    _currentSong = song;
    notifyListeners();

    final localPath = await DownloadService.instance.getLocalAudioPath(song.id);
    if (localPath != null && !localPath.startsWith('http')) {
      await _audioPlayer.play(DeviceFileSource(localPath));
    } else {
      await _audioPlayer.play(UrlSource(song.audioUrl));
    }
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
  ///
  /// [position] Targeted playback position offset.
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
  ///
  /// [position] Targeted playback position offset.
  void updatePosition(Duration position) {
    seek(position);
  }

  @override
  /// Disposes background player resources and listeners.
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}
