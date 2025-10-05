import 'package:verify_clone/utils/extensions/helper.dart';

class PhotoLocation {
  final int? id;
  final String photoId;
  final double lat;
  final double lng;
  final double? accuracy;
  final String? source;
  final int capturedAt;
  final int? createdAt;
  final int? updatedAt;

  const PhotoLocation({
    this.id,
    required this.photoId,
    required this.lat,
    required this.lng,
    this.accuracy,
    this.source,
    required this.capturedAt,
    this.createdAt,
    this.updatedAt,
  });

  PhotoLocation copyWith({
    int? id,
    String? photoId,
    double? lat,
    double? lng,
    double? accuracy,
    String? source,
    int? capturedAt,
    int? createdAt,
    int? updatedAt,
  }) {
    return PhotoLocation(
      id: id ?? this.id,
      photoId: photoId ?? this.photoId,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      accuracy: accuracy ?? this.accuracy,
      source: source ?? this.source,
      capturedAt: capturedAt ?? this.capturedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory PhotoLocation.fromMap(Map<String, Object?> map) {
    return PhotoLocation(
      id: map.asIntOrNull('id'),
      photoId: map['photo_id'] as String,
      lat: map.asDouble('lat'),
      lng: map.asDouble('lng'),
      accuracy: map.asDoubleOrNull('accuracy'),
      source: map['source'] as String?,
      capturedAt: map.asInt('captured_at'),
      createdAt: map.asIntOrNull('created_at'),
      updatedAt: map.asIntOrNull('updated_at'),
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'photo_id': photoId,
      'lat': lat,
      'lng': lng,
      'accuracy': accuracy,
      'source': source,
      'captured_at': capturedAt,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
