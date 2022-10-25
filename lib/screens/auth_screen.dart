import 'dart:async';

import 'package:flutter/material.dart';
import 'package:open_project_time_tracker/providers/authorization_provider.dart';
import 'package:provider/provider.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  void _authorize() {
    Provider.of<AuthorizationProvider>(context, listen: false).authorize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Image.asset('assets/images/open_project_logo.png'),
              ElevatedButton(
                  child: Text('Log in'), onPressed: () => _authorize())
            ],
          ),
        ),
      ),
    );
  }
}
