abstract class AppException implements Exception {
  final AppExceptionType type;

  AppException(this.type);

  String get message;

  @override
  bool operator ==(covariant AppException other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            (type == other.type) &&
            message == other.message);
  }

  @override
  int get hashCode => type.hashCode;
}

class UnCatchException extends AppException {
  UnCatchException({this.overridMessage}) : super(AppExceptionType.unknown);
  final String? overridMessage;

  @override
  String get message {
    return overridMessage ?? 'Something went wrong';
  }
}

enum AppExceptionType {
  remote,
  unknown,
}
