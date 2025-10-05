import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import 'package:verify_clone/core/network/middle_ware/middle_ware.dart';

class NetworkChecker {
  static const String GOOGLE_URL = 'https://www.google.com/';
  static const int STATUS_CODE_SUCCESS = 200;

  static Future<bool> checkNetwork() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      return true;
    } else {
      return false;
    }
  }

  static Future<bool> checkNetworkByGoogle() async {
    try {
      final http.Response response = await http
          .get(Uri.parse(GOOGLE_URL))
          .timeout(const Duration(seconds: 3));
      if (response.statusCode == STATUS_CODE_SUCCESS) {
        return true;
      } else {
        return false;
      }
    } on TimeoutException catch (error) {
      throw RemoteException(
        kind: RemoteExceptionKind.connectionTimeout,
        overrideMessage: error.message,
      );
    } on SocketException {
      throw RemoteException(
        kind: RemoteExceptionKind.noInternet,
        overrideMessage: 'S.current.net_work',
      );
    }
  }
}
