import 'dart:async';
import 'dart:io';
import 'package:easy_localization/easy_localization.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:verify_clone/core/network/middle_ware/http_override.dart';
import 'package:verify_clone/core/network/module.dart';
import 'package:verify_clone/data/services/database_helper.dart';
import 'package:verify_clone/data/services/user/user_service.dart';
import 'package:verify_clone/utils/constants/app_constants.dart';

Future<void> initApp() async {
  WidgetsFlutterBinding.ensureInitialized();
  MapboxOptions.setAccessToken(AppConstants.mapbox);
  await DatabaseHelper.instance.db;
  await UserService(DatabaseHelper.instance).initializeUsers();
  configureDependencies();
  await EasyLocalization.ensureInitialized();
  HttpOverrides.global = MyHttpOverrides();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
}
