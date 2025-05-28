import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';
import 'menu_screen.dart';
import 'carga_contribuir.dart'; // Importa la pantalla de carga de contribuciones
import 'permission_screen.dart'; //pantalla de permisos

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _verificarPermisos();
    _verificarUsuarioYConfiguracion();
  }

  Future<void> _verificarUsuarioYConfiguracion() async {
    // Simular tiempo de carga
    await Future.delayed(Duration(seconds: 3));
    if (!mounted) return;

    // Verificar si hay un usuario autenticado
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      // ❌ Usuario no autenticado → Ir a pantalla de inicio
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
      return;
    }

    String userId = currentUser.uid;

    // 🔍 Consultar Firestore para verificar si hay una configuración pendiente
    DocumentSnapshot userConfig = await FirebaseFirestore.instance
        .collection('configuracionesUsuarios')
        .doc(userId)
        .get();

    if (!mounted) return;

    if (userConfig.exists && userConfig['estado'] == 'pendiente') {
      print(
          "🔹 Configuración pendiente encontrada. Redirigiendo a carga de imágenes...");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => CargaContribuirScreen()),
      );
    } else {
      print("✅ No hay configuraciones pendientes.");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MenuScreen()),
      );
    }
  }

  Future<void> _verificarPermisos() async {
    await Future.delayed(Duration(seconds: 2)); // animación splash

    final prefs = await SharedPreferences.getInstance();
    final permisosYaSolicitados = prefs.getBool('permisosSolicitados') ?? false;

    if (permisosYaSolicitados) {
      // Ya se solicitó una vez → ir directamente a la lógica de usuario
      _verificarUsuarioYConfiguracion();
      return;
    }

    // Aún no se ha solicitado → guardar bandera y mostrar pantalla de permisos
    await prefs.setBool('permisosSolicitados', true);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const PermissionScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0BA37F),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            flex: 2,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/logo.png',
                    width: 150,
                    height: 150,
                  ),
                  SizedBox(height: 30),
                  Text(
                    'imagro',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
