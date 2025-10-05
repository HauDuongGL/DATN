import 'dart:io';
import 'package:exif/exif.dart';

class ExifData {
  final DateTime? dateTimeOriginal;
  final double? lat;
  final double? lng;
  const ExifData({this.dateTimeOriginal, this.lat, this.lng});
}

class ExifUtils {
  static Future<ExifData> read(String filePath) async {
    try {
      final lower = filePath.toLowerCase();
      if (!(lower.endsWith('.jpg') ||
          lower.endsWith('.jpeg') ||
          lower.endsWith('.heic') ||
          lower.endsWith('.heif'))) {
        return const ExifData();
      }

      final bytes = await File(filePath).readAsBytes();
      final tags = await readExifFromBytes(bytes);

      String? s(String k) => tags[k]?.printable;
      dynamic raw(String k) => tags[k]?.values;

      final dt = _parseExifDateTime(
              s('EXIF DateTimeOriginal') ?? s('Image DateTime')) ??
          _parseGpsDateTime(s('GPS GPSDateStamp'), raw('GPS GPSTimeStamp'));

      final lat = _parseGps(raw('GPS GPSLatitude'), s('GPS GPSLatitudeRef'));
      final lng = _parseGps(raw('GPS GPSLongitude'), s('GPS GPSLongitudeRef'));

      final latOk = (lat != null && lat >= -90 && lat <= 90) ? lat : null;
      final lngOk = (lng != null && lng >= -180 && lng <= 180) ? lng : null;

      final invalid00 = (latOk == 0 && lngOk == 0);
      return ExifData(
        dateTimeOriginal: dt,
        lat: invalid00 ? null : latOk,
        lng: invalid00 ? null : lngOk,
      );
    } catch (_) {
      return const ExifData();
    }
  }

  // ---- helpers ----
  static DateTime? _parseExifDateTime(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    final fixed = raw.replaceAllMapped(
      RegExp(r'^(\d{4}):(\d{2}):(\d{2})'),
      (m) => '${m.group(1)}-${m.group(2)}-${m.group(3)}',
    );
    try {
      return DateTime.parse(fixed);
    } catch (_) {
      return null;
    }
  }

  static DateTime? _parseGpsDateTime(String? dateStamp, dynamic timeStampRaw) {
    if (dateStamp == null) return null;
    final parts = _toDoubleList(timeStampRaw);
    if (parts.length < 3) return null;
    final h = parts[0].floor();
    final m = parts[1].floor();
    final s = parts[2].floor();
    final date = dateStamp.replaceAll(':', '-');
    try {
      return DateTime.parse('$date ${_two(h)}:${_two(m)}:${_two(s)}').toUtc();
    } catch (_) {
      return null;
    }
  }

  static String _two(int v) => v < 10 ? '0$v' : '$v';

  static double? _parseGps(dynamic raw, String? ref) {
    if (raw == null) return null;
    final parts = _toDoubleList(raw);
    if (parts.isEmpty) return null;

    if (parts.length == 1) {
      var dec = parts[0];
      final r = ref?.trim().toUpperCase();
      if (r == 'S' || r == 'W') dec = -dec;
      return dec;
    }

    final deg = parts[0];
    final min = parts.length > 1 ? parts[1] : 0.0;
    final sec = parts.length > 2 ? parts[2] : 0.0;
    double dec = deg + min / 60.0 + sec / 3600.0;

    final r = ref?.trim().toUpperCase();
    if (r == 'S' || r == 'W') dec = -dec;
    return dec;
  }

  static List<double> _toDoubleList(dynamic raw) {
    if (raw is List) {
      return raw.map((e) => _toDouble(e)).whereType<double>().toList();
    }
    final v = _toDouble(raw);
    return v == null ? <double>[] : <double>[v];
  }

  static double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();

    final s = v.toString();
    final frac = RegExp(r'^\s*(-?\d+(?:\.\d+)?)\s*/\s*(\d+(?:\.\d+)?)\s*$')
        .firstMatch(s);
    if (frac != null) {
      final a = double.tryParse(frac.group(1)!);
      final b = double.tryParse(frac.group(2)!);
      if (a != null && b != null && b != 0) return a / b;
    }

    final numOnly = double.tryParse(s);
    if (numOnly != null) return numOnly;

    final matches =
        RegExp(r'(-?\d+(?:\.\d+)?)(?:/(\d+(?:\.\d+)?))?').allMatches(s);
    final out = <double>[];
    for (final m in matches) {
      final a = double.tryParse(m.group(1)!);
      final b = m.group(2) != null ? double.tryParse(m.group(2)!) : null;
      if (a != null) out.add(b == null || b == 0 ? a : a / b);
    }
    if (out.isNotEmpty) return out.first;
    return null;
  }
}
