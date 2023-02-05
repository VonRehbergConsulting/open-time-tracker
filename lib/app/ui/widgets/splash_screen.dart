import 'package:flutter/material.dart';
import 'package:open_project_time_tracker/app/ui/widgets/activity_indicator.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: ActivityIndicator(),
      ),
    );
  }
}
