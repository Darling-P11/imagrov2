import 'package:flutter/material.dart';

class LoginWebScreen extends StatelessWidget {
  const LoginWebScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Inicio")),
      body: Center(child: Text("Bienvenido a Imagro Web")),
    );
  }
}
