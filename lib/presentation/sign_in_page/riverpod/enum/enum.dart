import 'package:easy_localization/easy_localization.dart';
import 'package:verify_clone/gen/translations.g.dart';

enum LoginResult {
  success,
  wrongPassword,
  userNotFound,
}

extension Title on LoginResult {
  String get name {
    switch (this) {
      case LoginResult.success:
        return "";
      case LoginResult.userNotFound:
        return LocaleKeys.login_page_user_not_found.tr();
      case LoginResult.wrongPassword:
        return LocaleKeys.login_page_wrong_password.tr();
    }
  }
}
