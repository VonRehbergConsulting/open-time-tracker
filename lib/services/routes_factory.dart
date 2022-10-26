import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/timer_provider.dart';
import '../screens/timer_screen.dart';
import '../screens/work_packages_list/work_packages_list_screen.dart';

class RoutesFactory {
  static Route get timer {
    return MaterialPageRoute(
      builder: ((context) {
        return ChangeNotifierProvider(
          create: ((context) => TimerProvider()),
          child: const TimerScreen(),
        );
      }),
    );
  }

  static Route get workPackagesList {
    return MaterialPageRoute(
      builder: ((context) => const WorkPackagesListScreen()),
    );
  }
}
