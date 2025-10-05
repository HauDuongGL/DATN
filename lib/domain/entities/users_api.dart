import 'package:freezed_annotation/freezed_annotation.dart';

part 'users_api.freezed.dart';
part 'users_api.g.dart';

@freezed
class UserModel with _$UserModel {
  const factory UserModel({
    int? id,
    String? name,
    String? email,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
}
