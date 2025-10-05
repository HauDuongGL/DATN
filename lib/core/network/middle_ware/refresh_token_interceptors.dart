import 'dart:io';

import 'package:dio/dio.dart';
import 'package:verify_clone/core/network/middle_ware/middle_ware.dart';
import 'package:verify_clone/core/network/module.dart';
import 'package:verify_clone/domain/locals/prefs_service.dart';
import 'package:verify_clone/utils/common.dart';
import 'package:verify_clone/utils/constants/api_constants.dart';

class RefreshTokenInterceptors extends BaseInterceptors {
  final Dio dio;
  RefreshTokenInterceptors(this.dio);

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == HttpStatus.unauthorized) {
      final options = err.response!.requestOptions;
      _onExpiredToken(options, handler);
    } else {
      handler.next(err);
    }
  }

  void _onExpiredToken(
    RequestOptions options,
    ErrorInterceptorHandler handler,
  ) async {
    final token = await _refreshToken();
    if (token.isEmpty) {
      exitApp();
      return handler.reject(
        DioException.badCertificate(requestOptions: options),
      );
    }
    PrefsService.saveToken(token);
    final res =
        await dio.fetch(options..headers['Authorization'] = 'Bearer $token');
    return handler.resolve(res);
  }

  Future<String> _refreshToken() async {
    try {
      final response =
          await provideDio().post('${ApiConstants.AUTH}refreshToken', data: {
        'refreshToken': PrefsService.getRefreshToken(),
      });

      return response.data['data'] ?? '';
    } catch (e) {
      return '';
    }
  }
}
