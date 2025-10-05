import 'package:dio/dio.dart';
import 'package:verify_clone/core/network/middle_ware/middle_ware.dart';
import 'package:verify_clone/domain/locals/prefs_service.dart';

class AuthInterceptors extends BaseInterceptors {
  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final accessToken = PrefsService.getToken();
    if (accessToken.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }
    return super.onRequest(options, handler);
  }
}
