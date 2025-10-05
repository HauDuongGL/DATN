import 'package:freezed_annotation/freezed_annotation.dart';

part 'response_wrapper.g.dart';
part 'response_wrapper.freezed.dart';

@Freezed(genericArgumentFactories: true)
class ResponseWrapper<T> with _$ResponseWrapper {
  const factory ResponseWrapper({
    T? data,
    String? message,
    int? code,
  }) = _ResponseWrapper;

  factory ResponseWrapper.fromJson(
          Map<String, dynamic> json, T Function(Object? json) fromJsonT) =>
      _$ResponseWrapperFromJson(json, fromJsonT);
}
