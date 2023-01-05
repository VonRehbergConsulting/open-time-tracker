import 'package:flutter/material.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:open_project_time_tracker/modules/authorization/ui/authorization_checker/authorization_checker_page.dart';
import 'package:provider/provider.dart';

import '/models/network_provider.dart';
import '/models/time_entries_provider.dart';
import '/models/user_data_provider.dart';
import '/models/timer_provider.dart';
import '/models/work_packages_provider.dart';
import '/helpers/token_storage.dart';
import '/helpers/preferences_storage.dart';
import '/helpers/timer_storage.dart';
import '/helpers/endpoints_factory.dart';
import '/models/instance_configiration_provider.dart';
import 'app/di/inject.dart';

void main() {
  configureDependencies();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  NetworkProvider _createNetworkProvider() {
    return NetworkProvider(
      appAuth: const FlutterAppAuth(),
      tokenStorage: TokenStorage(
        const FlutterSecureStorage(),
      ),
      endpointsFactory: EndpointsFactory(''),
    );
  }

  TimerProvider _createTimerProvider() {
    return TimerProvider(
      TimerStorage(
        PreferencesStorage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    precacheImage(
        const AssetImage('assets/images/open_project_logo.png'), context);
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: ((context) => InstanceConfigurationProvider(
                PreferencesStorage(),
              )),
        ),
        ChangeNotifierProxyProvider<InstanceConfigurationProvider,
            NetworkProvider>(
          create: (context) => _createNetworkProvider(),
          update: (context, instance, network) =>
              network ?? _createNetworkProvider()
                ..updateProvider(instance),
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
        ChangeNotifierProxyProvider<NetworkProvider, TimerProvider>(
          create: (context) => _createTimerProvider(),
          update: (context, network, timer) {
            final provider = timer ?? _createTimerProvider();
            if (network.authorizationState ==
                AuthorizationStatate.unauthorized) {
              provider.reset();
            }
            return provider;
          },
        ),
      ],
      child: MaterialApp(
        title: 'Open Project Time Tracker',
        theme: ThemeData(
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 0,
          ),
          scaffoldBackgroundColor: const Color.fromARGB(255, 242, 242, 242),
          primarySwatch: Colors.blue,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        home: AuthorizationCheckerPage(),
        // Consumer<NetworkProvider>(builder: (context, network, child) {
        //   switch (network.authorizationState) {
        //     case AuthorizationStatate.undefined:
        //       return const LaunchScreen();
        //     case AuthorizationStatate.unauthorized:
        //       return const AuthScreen();
        //     case AuthorizationStatate.authorized:
        //       return Consumer2<UserDataProvider, TimerProvider>(
        //         builder: ((context, userData, timer, child) {
        //           if (userData.userId != null && timer.isLoading == false) {
        //             return timer.timeEntry == null
        //                 ? const TimeEntriesListScreen()
        //                 : const TimerScreen();
        //           }
        //           return const LaunchScreen();
        //         }),
        //       );
        //   }
        // }),
      ),
    );
  }
}
