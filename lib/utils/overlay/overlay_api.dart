import 'dart:io';
import 'package:flutter/services.dart';

class OverlayApi {
  static const _new = MethodChannel('overlay/commands');
  static const _old = MethodChannel('chat.overlay');

  Future<bool> canDraw() async {
    if (!Platform.isAndroid) return false;
    try {
      return await _new.invokeMethod('canDraw') ?? false;
    } catch (_) {
      return await _old.invokeMethod('canDrawOverlays') ?? false;
    }
  }

  Future<void> requestPermission() async {
    if (!Platform.isAndroid) return;
    try {
      await _new.invokeMethod('openOverlayPermission');
    } catch (_) {
      await _old.invokeMethod('requestOverlayPermission');
    }
  }

  Future<bool> start() async {
    if (!Platform.isAndroid) return false;
    try {
      return await _new.invokeMethod('start') ?? true;
    } catch (_) {
      return await _old.invokeMethod('startChatHead') ?? true;
    }
  }

  Future<bool> stop() async {
    if (!Platform.isAndroid) return false;
    try {
      return await _new.invokeMethod('stop') ?? true;
    } catch (_) {
      return await _old.invokeMethod('stopChatHead') ?? true;
    }
  }

  Future<void> setBadge(int c) async {
    if (!Platform.isAndroid) return;
    try {
      await _new.invokeMethod('setBadge', {'count': c});
    } catch (_) {}
  }
}
