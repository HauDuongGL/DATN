import 'package:verify_clone/domain/entities/photo_model.dart';

class PhotoRequest {
  final Photo photo;
  final double? lat;
  final double? lng;
  final double? accuracy;
  final String? source;
  final int? capturedAt;

  PhotoRequest({
    required this.photo,
    this.lat,
    this.lng,
    this.accuracy,
    this.source,
    this.capturedAt,
  });
}
