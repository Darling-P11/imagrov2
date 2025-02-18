import 'package:flutter/material.dart';
import 'package:imagro/web/router.dart';

void main() {
  runApp(const ImagroWebApp());
}

class ImagroWebApp extends StatelessWidget {
  const ImagroWebApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Imagro Web',
      routerConfig: WebRouter,  // Aquí debe estar bien referenciado
    );
  }
}
