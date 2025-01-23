import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String _errorMessage = '';

  Future<void> _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Por favor, ingresa ambos campos';
      });
      return;
    }

    try {
      // Imprimir credenciales ingresadas
      print('Email ingresado: ${_emailController.text.trim()}');
      print('Contraseña ingresada: ${_passwordController.text.trim()}');

      // Intentar iniciar sesión
      final UserCredential userCredential =
          await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Validar usuario autenticado
      if (userCredential.user != null) {
        print('Usuario autenticado: ${userCredential.user?.email}');
        Navigator.pushNamed(context, '/success'); // Redirigir a éxito
      } else {
        print('Error: Usuario no autenticado');
        setState(() {
          _errorMessage = 'Error: Usuario no autenticado';
        });
      }
    } on FirebaseAuthException catch (e) {
      // Manejar errores de Firebase
      setState(() {
        _errorMessage = 'Error de Firebase: ${e.message ?? 'Error inesperado'}';
      });
      print('FirebaseAuthException: ${e.message}');
    } catch (e) {
      // Manejar otros errores
      setState(() {
        _errorMessage = 'Error desconocido: ${e.toString()}';
      });
      print('Error desconocido: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Iniciar Sesión')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Correo Electrónico',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Contraseña',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _login,
              child: Text('Iniciar Sesión'),
              style: ElevatedButton.styleFrom(
                minimumSize:
                    Size(double.infinity, 50), // Botón de ancho completo
              ),
            ),
            SizedBox(height: 10),
            if (_errorMessage.isNotEmpty)
              Text(
                _errorMessage,
                style: TextStyle(color: Colors.red),
              ),
          ],
        ),
      ),
    );
  }
}
