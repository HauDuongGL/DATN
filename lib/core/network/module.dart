import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:verify_clone/core/network/middle_ware/middle_ware.dart';
import 'package:verify_clone/utils/constants/app_constants.dart';

final getIt = GetIt.instance;

void configureDependencies() {
  getIt.registerSingleton(GlobalKey<NavigatorState>());
}

Dio provideDio({String? baseURL}) {
  final options = BaseOptions(
    baseUrl: baseURL ?? AppConstants.baseUrl,
    receiveTimeout: AppConstants.receiveTimeout,
    connectTimeout: AppConstants.connectTimeout,
    followRedirects: false,
  );
  final dio = Dio(options);

  dio.transformer = BackgroundTransformer();
  dio.interceptors.addAll([
    ConnectInterceptors(),
    HeaderInterceptors(),
    AuthInterceptors(),
    RefreshTokenInterceptors(dio),
  ]);
  return dio;
}
