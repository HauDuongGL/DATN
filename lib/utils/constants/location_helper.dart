import 'package:geolocator/geolocator.dart' as geo;
import 'package:permission_handler/permission_handler.dart';

class LocationHelper {
  static Future<geo.Position?> getPosition({
    geo.LocationAccuracy accuracy = geo.LocationAccuracy.high,
    Duration timeout = const Duration(seconds: 12),
  }) async {
    final serviceEnabled = await geo.Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await geo.Geolocator.openLocationSettings();
      return null;
    }
    var status = await Permission.locationWhenInUse.status;
    if (!status.isGranted) {
      status = await Permission.locationWhenInUse.request();
      if (!status.isGranted) return null;
    }
    try {
      return await geo.Geolocator.getCurrentPosition(
        desiredAccuracy: accuracy,
        timeLimit: timeout,
      );
    } catch (_) {
      return await geo.Geolocator.getLastKnownPosition();
    }
  }
}
