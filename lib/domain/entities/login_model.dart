import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:verify_clone/domain/entities/users_api.dart';

part 'login_model.freezed.dart';
part 'login_model.g.dart';

@freezed
class LoginModel with _$LoginModel {
  const factory LoginModel(
      {UserModel? user,
      String? accessToken,
      String? refreshToken}) = _LoginModel;

  factory LoginModel.fromJson(Map<String, dynamic> json) =>
      _$LoginModelFromJson(json);
}
