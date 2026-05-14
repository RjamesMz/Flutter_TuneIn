import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import '../models/song.dart';

class DownloadService {
  DownloadService._();
  static final DownloadService instance = DownloadService._();

  Database? _db;
  final Dio _dio = Dio();

  /// Whether downloads are supported on this platform
  bool get isSupported => !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  Future<Database?> get database async {
    if (!isSupported) return null;
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, 'downloads.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE downloaded_songs (
            id TEXT PRIMARY KEY,
            title TEXT,
            artist TEXT,
            album TEXT,
            category TEXT,
            duration_seconds INTEGER,
            audio_url TEXT,
            cover_url TEXT
          )
        ''');
      },
    );
  }

  /// Downloads a song and saves it to local storage & SQLite.
  Future<Song> downloadSong(Song song, Function(double)? onProgress) async {
    if (!isSupported) return song;

    final docDir = await getApplicationDocumentsDirectory();
    final audioSavePath = p.join(docDir.path, '${song.id}_audio.mp3');
    final coverSavePath = p.join(docDir.path, '${song.id}_cover.jpg');

    // 1. Download Audio
    if (song.audioUrl.startsWith('http')) {
      await _dio.download(
        song.audioUrl,
        audioSavePath,
        onReceiveProgress: (count, total) {
          if (total != -1 && onProgress != null) {
            onProgress(count / total * 0.9);
          }
        },
      );
    }

    // 2. Download Cover (best-effort)
    if (song.coverUrl.startsWith('http')) {
      try {
        await _dio.download(song.coverUrl, coverSavePath);
      } catch (_) {}
    }
    if (onProgress != null) onProgress(1.0);

    // 3. Create local song object with local paths
    final localSong = Song(
      id: song.id,
      title: song.title,
      artist: song.artist,
      album: song.album,
      category: song.category,
      duration: song.duration,
      audioUrl: audioSavePath,
      coverUrl: coverSavePath,
    );

    // 4. Persist to SQLite
    final db = await database;
    if (db != null) {
      await db.insert(
        'downloaded_songs',
        {
          'id': localSong.id,
          'title': localSong.title,
          'artist': localSong.artist,
          'album': localSong.album,
          'category': localSong.category,
          'duration_seconds': localSong.duration.inSeconds,
          'audio_url': localSong.audioUrl,
          'cover_url': localSong.coverUrl,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    return localSong;
  }

  /// Fetch all downloaded songs from SQLite
  Future<List<Song>> getDownloadedSongs() async {
    if (!isSupported) return [];
    final db = await database;
    if (db == null) return [];
    final maps = await db.query('downloaded_songs');
    return maps.map<Song>((data) => Song(
      id: (data['id'] ?? '').toString(),
      title: (data['title'] ?? '').toString(),
      artist: (data['artist'] ?? '').toString(),
      album: (data['album'] ?? '').toString(),
      category: (data['category'] ?? '').toString(),
      duration: Duration(seconds: (data['duration_seconds'] as int?) ?? 0),
      audioUrl: (data['audio_url'] ?? '').toString(),
      coverUrl: (data['cover_url'] ?? '').toString(),
    )).toList();
  }

  /// Delete a downloaded song from storage and SQLite
  Future<void> deleteDownload(Song song) async {
    if (!isSupported) return;
    final db = await database;
    if (db != null) {
      await db.delete('downloaded_songs', where: 'id = ?', whereArgs: [song.id]);
    }
    // Delete local files
    if (!song.audioUrl.startsWith('http')) {
      final audioFile = File(song.audioUrl);
      if (await audioFile.exists()) await audioFile.delete();
    }
    if (!song.coverUrl.startsWith('http')) {
      final coverFile = File(song.coverUrl);
      if (await coverFile.exists()) await coverFile.delete();
    }
  }

  /// Get local audio path if the song is downloaded
  Future<String?> getLocalAudioPath(String id) async {
    if (!isSupported) return null;
    final db = await database;
    if (db == null) return null;
    final maps = await db.query(
      'downloaded_songs',
      columns: ['audio_url'],
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return maps.first['audio_url'] as String?;
    }
    return null;
  }
}
