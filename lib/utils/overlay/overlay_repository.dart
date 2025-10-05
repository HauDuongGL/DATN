import 'overlay_api.dart';

class OverlayRepository {
  OverlayRepository(this._api);
  final OverlayApi _api;

  Future<bool> hasPermission() => _api.canDraw();
  Future<void> requestPermission() => _api.requestPermission();
  Future<void> enable() => _api.start();
  Future<void> disable() => _api.stop();
}
