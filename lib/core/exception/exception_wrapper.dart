// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

import 'app_exception.dart';

class ExceptionWrapper {
  final AppException exception;
  final VoidCallback? doOnRetry;

  ExceptionWrapper(this.exception, this.doOnRetry);

  @override
  String toString() =>
      'ExceptionWrapper(exception: ${exception.toString()}, doOnRetry: $doOnRetry)';
}
