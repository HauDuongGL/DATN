import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verify_clone/handle_app.dart';
import 'package:verify_clone/init_app.dart';

Future<void> main() async {
  await dotenv.load(fileName: '.env');
  await initApp();

  runApp(
    ProviderScope(
      child: startApp(),
    ),
  );
}
