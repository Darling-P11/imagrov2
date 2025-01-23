import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:imagro/screens/splash_screen.dart';
import 'package:imagro/screens/home_screen.dart';
import 'package:imagro/screens/login_screen.dart';
import 'package:imagro/screens/success_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Asegúrate de inicializar los widgets
  await Firebase.initializeApp(); // Inicializa Firebase
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Imagro',
      theme: ThemeData(primarySwatch: Colors.green),
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(),
        '/home': (context) => HomeScreen(),
        '/emailInput': (context) => LoginScreen(),
        '/success': (context) => SuccessScreen(),
      },
    );
  }
}
