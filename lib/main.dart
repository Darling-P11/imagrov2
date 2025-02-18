import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:imagro/screens/historial_solicitud.dart';
import 'package:imagro/screens/menu_screen.dart';
import 'package:imagro/screens/profile_register_screen.dart';
import 'package:imagro/screens/splash_screen.dart';
import 'package:imagro/screens/home_screen.dart';
import 'package:imagro/screens/enter_email_screen.dart';
import 'package:imagro/screens/password_login_screen.dart';
import 'package:imagro/screens/password_register_screen.dart'; // Registro incluido
import 'package:intl/date_symbol_data_local.dart'; // Para inicializar locales
import 'package:imagro/screens/profile_screen.dart'; // Importa la pantalla de perfil
import 'package:imagro/screens/contribuir_confg.dart';
import 'package:imagro/screens/carga_contribuir.dart'; // Importa la pantalla de carga de contribuciones

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Inicializa widgets antes de Firebase
  await Firebase.initializeApp(); // Inicializa Firebase
  await initializeDateFormatting(
      'es_ES', null); // Inicializa el idioma español para fechas

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Imagro',
      theme: ThemeData(primarySwatch: Colors.green),
      // Ruta inicial
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(), // Pantalla de carga
        '/home': (context) => HomeScreen(), // Pantalla principal
        '/email': (context) =>
            EnterEmailScreen(), // Pantalla para ingresar correo
        '/password-login': (context) =>
            PasswordLoginScreen(email: ''), // Pantalla para ingresar contraseña
        '/register-password': (context) => PasswordRegisterScreen(email: ''),
        '/register-profile': (context) =>
            ProfileRegisterScreen(email: '', password: ''),
        '/menu': (context) => MenuScreen(),
        '/profile': (context) => ProfileScreen(),
        '/configuracion-contribucion': (context) =>
            ConfiguracionContribucionScreen(),
        '/carga-contribucion': (context) => CargaContribuirScreen(),
        '/historial_solicitud': (context) => HistorialSolicitudScreen(),
      },
    );
  }
}
