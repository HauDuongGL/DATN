import 'package:sqflite/sqflite.dart';
import 'package:verify_clone/data/services/database_helper.dart';
import 'package:verify_clone/domain/entities/user.dart';
import 'package:verify_clone/presentation/sign_in_page/riverpod/enum/enum.dart';

class UserService {
  final DatabaseHelper dbHelper;

  UserService(this.dbHelper);

  Future<(LoginResult result, int? userId)> login(Users user) async {
    final db = await dbHelper.db;
    final email = user.email.trim();

    final userEmail = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );

    if (userEmail.isEmpty) {
      return (LoginResult.userNotFound, null);
    }

    final result = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, user.password],
    );

    if (result.isNotEmpty) {
      final userId = result.first['usrId'] as int;
      return (LoginResult.success, userId);
    } else {
      return (LoginResult.wrongPassword, null);
    }
  }

  Future<int> insertUser(Users user) async {
    Database db = await dbHelper.db;
    return await db.insert(
      'users',
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<void> initializeUsers() async {
    List<Users> userToAdd = [
      Users(
          usrId: 1,
          email: 'tai.cumanhtuan@ncc.asia',
          password: '12345',
          userName: 'tai.cumanhtuan'),
      Users(
          usrId: 2,
          email: 'hau.duongphuc@ncc.asia',
          password: '12345',
          userName: 'hau.duongphuc'),
      Users(
        usrId: 3,
        email: 'aaa',
        password: '123',
        userName: 'hau.duongphuc',
      ),
    ];

    for (Users user in userToAdd) {
      await insertUser(user);
    }
  }
}
