import 'package:flutter/services.dart';

class ExifWriter {
  static const _ch = MethodChannel('exif_writer');

  static Future<bool> writeGps({
    required String path,
    required double lat,
    required double lng,
    int? takenAtMillis,
  }) async {
    final ok = await _ch.invokeMethod<bool>('writeGps', {
      'path': path,
      'lat': lat,
      'lng': lng,
      'takenAt': takenAtMillis,
    });
    return ok ?? false;
  }
}
