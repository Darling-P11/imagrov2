import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:imagro/web/screens/home_web.dart';
import 'package:imagro/web/screens/login_web.dart';
import 'package:imagro/web/screens/dashboard_web.dart';

final GoRouter WebRouter = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeWebScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginWebScreen(),
    ),
    GoRoute(
      path: '/dashboard',
      builder: (context, state) => const DashboardWebScreen(),
    ),
  ],
);
