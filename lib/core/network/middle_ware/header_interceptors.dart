import 'package:dio/dio.dart';
import 'package:verify_clone/core/network/middle_ware/middle_ware.dart';

class HeaderInterceptors extends BaseInterceptors {
  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    options.headers['Content-Type'] = 'application/json';
    options.headers['Accept'] = '*/*';
    return super.onRequest(options, handler);
  }
}
