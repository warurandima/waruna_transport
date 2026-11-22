import 'package:flutter/material.dart';

class SlideFadePageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  SlideFadePageRoute({
    required this.page,
    super.settings,
    Duration duration = const Duration(milliseconds: 350),
  }) : super(
         pageBuilder: (context, animation, secondaryAnimation) => page,
         transitionDuration: duration,
         reverseTransitionDuration: duration,
         transitionsBuilder: (context, animation, secondaryAnimation, child) {
           const begin = Offset(1.0, 0.0);
           const end = Offset.zero;
           const curve = Curves.easeInOutCubic;

           final slideAnimation = Tween(
             begin: begin,
             end: end,
           ).animate(CurvedAnimation(parent: animation, curve: curve));
           final fadeAnimation = Tween<double>(
             begin: 0.0,
             end: 1.0,
           ).animate(CurvedAnimation(parent: animation, curve: Curves.easeIn));

           return SlideTransition(
             position: slideAnimation,
             child: FadeTransition(opacity: fadeAnimation, child: child),
           );
         },
       );
}
