import 'package:dio/dio.dart';

import 'package:verify_clone/core/network/middle_ware/middle_ware.dart';
import 'package:verify_clone/core/network/network_checker.dart';

class ConnectInterceptors extends BaseInterceptors {
  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final connectivityResult = await NetworkChecker.checkNetwork();
    if (!connectivityResult) {
      return handler.reject(
        DioException(
          requestOptions: options,
          type: DioExceptionType.connectionError,
        ),
      );
    }
    return super.onRequest(options, handler);
  }
}
