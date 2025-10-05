import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';
import 'package:verify_clone/data/request/login_request.dart';
import 'package:verify_clone/data/response/error/response_wrapper.dart';
import 'package:verify_clone/domain/entities/login_model.dart';
import 'package:verify_clone/utils/constants/api_constants.dart';

part 'login_service.g.dart';

@RestApi()
abstract class LoginService {
  @factoryMethod
  factory LoginService(Dio dio, {String baseUrl}) = _LoginService;

  @POST(ApiConstants.LOGIN_API)
  Future<ResponseWrapper<LoginModel>> login(@Body() LoginRequest request);
}
