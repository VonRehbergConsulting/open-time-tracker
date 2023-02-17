import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: LayoutBuilder(
            builder: (context, constraints) => Container(
                width: constraints.maxWidth * 0.3,
                child: Image.asset('assets/images/open_project_logo.png'))),
      ),
    );
  }
}
