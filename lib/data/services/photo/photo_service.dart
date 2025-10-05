import 'dart:io';
import 'package:exif/exif.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import 'package:cross_file/cross_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'package:verify_clone/data/request/photo_request.dart';
import 'package:verify_clone/data/services/database_helper.dart';
import 'package:verify_clone/domain/entities/photo_model.dart';
import 'package:verify_clone/utils/constants/wrapper.dart';
import 'package:verify_clone/utils/exif_utils.dart';

class PhotoService {
  final DatabaseHelper dbHelper;
  PhotoService(this.dbHelper);

  static const _uuid = Uuid();

  Future<void> insertPhotoWithLocation({
    required int treeId,
    required String kind,
    required String path,
    required int takenAt,
    double? lat,
    double? lng,
    double? accuracy,
    String? source,
  }) async {
    final dbx = await dbHelper.db;
    await dbx.transaction((txn) async {
      final now = DateTime.now().millisecondsSinceEpoch;

      final safePath = await _ensureLocalFilePath(path);

      var exif = await ExifUtils.read(safePath);
      print('EXIF time: ${exif.dateTimeOriginal}');
      print('lat=${exif.lat}, lng=${exif.lng}');
      final exifCapturedMs = exif.dateTimeOriginal?.millisecondsSinceEpoch;

      var useLat = lat ?? exif.lat;
      var useLng = lng ?? exif.lng;

      final capturedAt = exifCapturedMs ?? takenAt;

      if (_supportsExif(safePath) &&
          (exif.lat == null || exif.lng == null) &&
          lat != null &&
          lng != null) {
        final ok = await ExifWriter.writeGps(
          path: safePath,
          lat: lat,
          lng: lng,
          takenAtMillis: capturedAt,
        );
        print('writeGps ok=$ok path=$safePath lat=$lat lng=$lng');

        source ??= 'gps';
      }

      final updateMap = <String, Object?>{
        'path': safePath,
        'taken_at': takenAt,
        'captured_at': capturedAt,
        'updated_at': now,
      };

      if (useLat != null && useLng != null) {
        updateMap.addAll({
          'lat': useLat,
          'lng': useLng,
          'accuracy': accuracy,
          'source': source ?? (lat != null ? 'gps' : 'exif'),
        });
      }

      final rows = await txn.rawQuery(
        'SELECT photo_id FROM photos WHERE tree_id = ? AND kind = ? LIMIT 1',
        [treeId, kind],
      );

      if (rows.isEmpty) {
        await txn.insert(
          'photos',
          {
            'photo_id': _uuid.v4(),
            'tree_id': treeId,
            'kind': kind,
            ...updateMap,
            'created_at': now,
          },
          conflictAlgorithm: ConflictAlgorithm.abort,
        );
      } else {
        final photoId = rows.first['photo_id'] as String;
        await txn.update(
          'photos',
          updateMap,
          where: 'photo_id = ?',
          whereArgs: [photoId],
          conflictAlgorithm: ConflictAlgorithm.abort,
        );
      }
    });
  }

  Future<void> printExif(String path) async {
    final bytes = await File(path).readAsBytes();
    final tags = await readExifFromBytes(bytes);
    print(tags['GPS GPSLatitude']);
    print(tags['GPS GPSLongitude']);
    print(tags['EXIF DateTimeOriginal'] ?? tags['Image DateTime']);
  }

  Future<List<Photo>> getAllPhotosByUserId(int userId) async {
    final dbx = await dbHelper.db;
    final rows = await dbx.rawQuery('''
      SELECT p.*
      FROM photos p
      JOIN trees t ON t.treeId = p.tree_id
      WHERE t.userId = ?
      ORDER BY COALESCE(p.captured_at, p.taken_at) ASC
    ''', [userId]);

    return rows.map((m) => Photo.fromMap(m)).toList();
  }

  Future<PhotoRequest?> getLatestForTreeByKind(int treeId, String kind) async {
    final db = await dbHelper.db;
    final rows = await db.rawQuery(
      '''
      SELECT 
        p.photo_id, p.tree_id, p.kind, p.step, p.path,
        p.taken_at, p.captured_at, p.lat, p.lng, p.accuracy, p.source,
        p.created_at, p.updated_at
      FROM photos p
      WHERE p.tree_id = ? AND p.kind = ?
      ORDER BY COALESCE(p.captured_at, p.taken_at) DESC
      LIMIT 1
      ''',
      [treeId, kind],
    );
    if (rows.isEmpty) return null;
    final m = rows.first;

    return PhotoRequest(
      photo: Photo.fromMap(m),
      lat: (m['lat'] as num?)?.toDouble(),
      lng: (m['lng'] as num?)?.toDouble(),
      accuracy: (m['accuracy'] as num?)?.toDouble(),
      source: m['source'] as String?,
      capturedAt: m['captured_at'] as int?,
    );
  }

  Future<(double, double)?> getLatestLatLngForTree(int treeId) async {
    final db = await dbHelper.db;
    final rows = await db.rawQuery(
      '''
      SELECT p.lat, p.lng
      FROM photos p
      WHERE p.tree_id = ? AND p.lat IS NOT NULL AND p.lng IS NOT NULL
      ORDER BY COALESCE(p.captured_at, p.taken_at) DESC
      LIMIT 1
      ''',
      [treeId],
    );

    if (rows.isEmpty) return null;
    final r = rows.first;
    return ((r['lat'] as num).toDouble(), (r['lng'] as num).toDouble());
  }

  Future<String> _ensureLocalFilePath(String inputPath) async {
    if (inputPath.startsWith('file://')) {
      return Uri.parse(inputPath).toFilePath();
    }
    if (inputPath.startsWith('content://')) {
      final x = XFile(inputPath);
      final dir = await getApplicationDocumentsDirectory();
      final photoDir = Directory(p.join(dir.path, 'photos'));
      if (!await photoDir.exists()) {
        await photoDir.create(recursive: true);
      }

      final ext =
          p.extension(inputPath).isNotEmpty ? p.extension(inputPath) : '.jpg';
      final outPath = p.join(
          photoDir.path, 'photo_${DateTime.now().millisecondsSinceEpoch}$ext');
      await x.saveTo(outPath);
      return outPath;
    }
    return inputPath;
  }

  bool _supportsExif(String path) {
    final e = p.extension(path).toLowerCase();
    return e == '.jpg' || e == '.jpeg' || e == '.heic' || e == '.heif';
  }
}
