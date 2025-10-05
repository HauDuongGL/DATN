import 'package:verify_clone/core/config/app_config.dart';
import 'package:verify_clone/core/config/resources/color.dart';
import 'package:verify_clone/utils/constants/app_constants.dart';

class AppTheme {
  static AppColor? _instance;

  static AppColor getInstance() {
    _instance ??= AppMode.LIGHT == APP_THEME ? LightApp() : DarkApp();
    return _instance!;
  }
}
