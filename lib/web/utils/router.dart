import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/home.dart';
import '../screens/login_web.dart';
import '../screens/dashboard_web.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/', // Página inicial
  routes: [
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) => HomePage(),
    ),
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginWebScreen(),
    ),
    GoRoute(
      path: '/dashboard',
      name: 'dashboard',
      builder: (context, state) => const DashboardWebScreen(),
    ),
  ],
);
