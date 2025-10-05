class Users {
  final int? usrId;
  final String email;
  final String password;
  final String? userName;

  Users({
    this.usrId,
    required this.userName,
    required this.email,
    required this.password,
  });

  factory Users.fromMap(Map<String, dynamic> json) => Users(
        usrId: json["usrId"],
        email: json["email"],
        password: json["password"],
        userName: json["userName"],
      );

  Map<String, dynamic> toMap() {
    final map = {
      "email": email,
      "password": password,
      "userName": userName,
    };

    if (usrId != null) {
      map["usrId"] = usrId.toString();
    }

    return map;
  }
}
