extension MapCastX on Map<String, Object?> {
  int? asIntOrNull(String key) {
    final v = this[key];
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) {
      final i = int.tryParse(v);
      if (i != null) return i;
      final d = double.tryParse(v);
      if (d != null) return d.toInt();
    }
    return null;
  }

  int asInt(String key, {int defaultValue = 0}) {
    return asIntOrNull(key) ?? defaultValue;
  }

  double? asDoubleOrNull(String key) {
    final v = this[key];
    if (v == null) return null;
    if (v is double) return v;
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v);
    return null;
  }

  double asDouble(String key, {double defaultValue = 0.0}) {
    return asDoubleOrNull(key) ?? defaultValue;
  }
}
