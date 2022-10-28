import 'package:flutter/material.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';

import '/models/network_provider.dart';
import '/models/time_entries_provider.dart';
import '/models/user_data_provider.dart';
import '/models/timer_provider.dart';
import '/models/work_packages_provider.dart';
import '/screens/auth_screen.dart';
import '/screens/time_entries_list/time_entries_list_screen.dart';
import '/services/token_storage.dart';
import '/screens/launch_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => NetworkProvider(
              const FlutterAppAuth(),
              TokenStorage(
                const FlutterSecureStorage(),
              )),
        ),
        ChangeNotifierProxyProvider<NetworkProvider, UserDataProvider>(
          create: ((context) => UserDataProvider()),
          update: (context, network, userData) => userData ?? UserDataProvider()
            ..updateProvider(network),
        ),
        ChangeNotifierProxyProvider2<NetworkProvider, UserDataProvider,
            TimeEntriesProvider>(
          create: ((context) => TimeEntriesProvider()),
          update: ((context, network, userData, timeEntries) =>
              timeEntries ?? TimeEntriesProvider()
                ..updateProvider(network, userData)),
        ),
        ChangeNotifierProxyProvider2<NetworkProvider, UserDataProvider,
            WorkPackagesProvider>(
          create: ((context) => WorkPackagesProvider()),
          update: ((context, network, userData, workPackages) =>
              workPackages ?? WorkPackagesProvider()
                ..updateProvider(network, userData)),
        ),
        ChangeNotifierProvider(
          create: (context) => TimerProvider(null),
        ),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blueGrey,
        ),
        home: Consumer2<NetworkProvider, UserDataProvider>(
          builder: ((context, network, userData, child) {
            if (network.authorizationState == AuthorizationStatate.undefined) {
              return const LaunchScreen();
            }
            if (network.authorizationState ==
                AuthorizationStatate.unauthorized) {
              return const AuthScreen();
            }
            if (network.authorizationState == AuthorizationStatate.authorized &&
                userData.userId != null) {
              // return const TimeEntriesListScreen();
              return TimeEntriesListScreen();
            }
            return const LaunchScreen();
          }),
        ),
      ),
    );
  }
}
