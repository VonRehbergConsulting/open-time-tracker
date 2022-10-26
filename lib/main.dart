import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:open_project_time_tracker/models/timer_provider.dart';
import 'package:open_project_time_tracker/models/work_packages_provider.dart';
import 'package:open_project_time_tracker/screens/timer_screen.dart';
import 'package:open_project_time_tracker/screens/work_packages_list/work_packages_list_screen.dart';
import 'package:provider/provider.dart';

import '/models/network_provider.dart';
import '/models/time_entries_provider.dart';
import '/models/user_data_provider.dart';
import '/screens/auth_screen.dart';
import '/screens/time_entries_list/time_entries_list_screen.dart';
import '/services/token_storage.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) =>
              NetworkProvider(const FlutterAppAuth(), TokenStorage()),
        ),
        ChangeNotifierProxyProvider<NetworkProvider, UserDataProvider>(
          create: ((context) => UserDataProvider()),
          update: (context, network, userData) => userData ?? UserDataProvider()
            ..update(network),
        ),
        ChangeNotifierProxyProvider2<NetworkProvider, UserDataProvider,
            TimeEntriesProvider>(
          create: ((context) => TimeEntriesProvider()),
          update: ((context, network, userData, timeEntries) =>
              timeEntries ?? TimeEntriesProvider()
                ..update(network, userData)),
        ),
        ChangeNotifierProxyProvider2<NetworkProvider, UserDataProvider,
            WorkPackagesProvider>(
          create: ((context) => WorkPackagesProvider()),
          update: ((context, network, userData, workPackages) =>
              workPackages ?? WorkPackagesProvider()
                ..update(network, userData)),
        ),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blueGrey,
        ),
        home: Consumer2<NetworkProvider, UserDataProvider>(
          builder: ((context, network, userData, child) {
            return network.isAuthorized && userData.userId != null
                ? TimeEntriesListScreen()
                : AuthScreen();
          }),
        ),
      ),
    );
  }
}
