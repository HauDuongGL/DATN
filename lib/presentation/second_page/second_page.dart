import 'package:flutter/material.dart';
import 'package:verify_clone/core/base/base_scafold.dart';

class SecondPage extends StatelessWidget {
  const SecondPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppScaffold(
      showAppBar: false,
      body: Center(
        child: Text('Second Screen'),
      ),
    );
  }
}
