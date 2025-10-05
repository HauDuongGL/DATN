import 'package:verify_clone/core/results/result.dart';
import 'package:verify_clone/data/request/login_request.dart';
import 'package:verify_clone/domain/entities/login_model.dart';

abstract class LoginRepository {
  Future<Result<LoginModel>> login(LoginRequest request);
  Future<void> logout();
}
