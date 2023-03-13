import 'package:flutter/material.dart';

class SlideToLeftTransition extends PageRouteBuilder {
  final Widget toScreen;
  final Widget fromScreen;
  SlideToLeftTransition({
    required this.toScreen,
    required this.fromScreen,
  }) : super(
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) =>
              toScreen,
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) =>
              Stack(
            children: <Widget>[
              SlideTransition(
                position: Tween<Offset>(
                  begin: Offset.zero,
                  end: Offset.zero,
                ).animate(animation),
                child: toScreen,
              ),
              SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.0, 0.0),
                  end: const Offset(0.0, 1.0),
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeInOutCirc,
                )),
                child: fromScreen,
              ),
            ],
          ),
        );
}

class SlideToRightTransition extends PageRouteBuilder {
  final Widget toScreen;
  final Widget fromScreen;
  SlideToRightTransition({
    required this.toScreen,
    required this.fromScreen,
  }) : super(
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) =>
              toScreen,
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) =>
              Stack(
            children: <Widget>[
              SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.0, 1.0),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeInOutCirc,
                )),
                child: toScreen,
              )
            ],
          ),
        );
}
