import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verify_clone/data/services/database_helper.dart';
import 'package:verify_clone/data/services/user/user_service.dart';
import 'package:verify_clone/domain/entities/user.dart';
import 'package:verify_clone/presentation/sign_in_page/riverpod/enum/enum.dart';
import 'package:shared_preferences/shared_preferences.dart';

final dbProvider = Provider<DatabaseHelper>((ref) => DatabaseHelper.instance);

final userServiceProvider = Provider<UserService>(
  (ref) => UserService(ref.read(dbProvider)),
);

class LoginRiverpod extends AsyncNotifier<LoginResult?> {
  late final DatabaseHelper db;

  @override
  FutureOr<LoginResult?> build() {
    db = ref.read(dbProvider);
    return null;
  }

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();

    final (result, userId) = await ref.read(userServiceProvider).login(
          Users(
            email: email,
            password: password,
            userName: null,
          ),
        );

    if (result == LoginResult.success && userId != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('usrId', userId);
    }

    state = AsyncData(result);
  }
}

final loginRiverpod = AsyncNotifierProvider<LoginRiverpod, LoginResult?>(
  () => LoginRiverpod(),
);
