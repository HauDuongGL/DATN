import 'overlay_repository.dart';

class OverlayController {
  OverlayController(this._repo);
  final OverlayRepository _repo;

  Future<bool> ensurePermission() async {
    final ok = await _repo.hasPermission();
    if (!ok) await _repo.requestPermission();
    return _repo.hasPermission();
  }

  Future<void> start() async {
    if (await ensurePermission()) await _repo.enable();
  }

  Future<void> stop() => _repo.disable();
}
