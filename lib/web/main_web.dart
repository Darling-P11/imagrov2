import 'package:flutter/material.dart';
import 'package:imagro/web/utils/router.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Imagro Web',
      theme: ThemeData(primarySwatch: Colors.blue),
      routerConfig: appRouter, // 👈 Aquí se conecta el router
    );
  }
}
