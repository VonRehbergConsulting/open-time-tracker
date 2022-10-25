import 'package:flutter/material.dart';
import 'package:open_project_time_tracker/providers/authorization_provider.dart';
import 'package:open_project_time_tracker/screens/auth_screen.dart';
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AuthorizationProvider(),
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blueGrey,
        ),
        home: Consumer<AuthorizationProvider>(
          builder: ((context, authorizationStatus, child) {
            return const AuthScreen();
          }),
        ),
      ),
    );
  }
}

class Temp extends StatelessWidget {
  const Temp({super.key});

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
