import 'package:flutter/material.dart';

class AppLanguages {
  static get assetPath => 'assets/translations';

  static Locale get en => const Locale('en', 'US');
  static Locale get sw => const Locale('sw', 'SW');

  static get supportedLanguages => [
        en,
        sw,
      ];
}
