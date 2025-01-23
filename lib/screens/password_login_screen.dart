import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PasswordLoginScreen extends StatefulWidget {
  final String email;

  PasswordLoginScreen({required this.email});

  @override
  _PasswordLoginScreenState createState() => _PasswordLoginScreenState();
}

class _PasswordLoginScreenState extends State<PasswordLoginScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String _errorMessage = '';

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: widget.email,
          password: _passwordController.text.trim(),
        );
        // Redirigir a la pantalla principal o donde corresponda
        Navigator.pushReplacementNamed(context, '/main');
      } catch (e) {
        setState(() {
          _errorMessage = 'Error al iniciar sesión: ${e.toString()}';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(color: Colors.black),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Iniciar sesión', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              Text('Ingresa tu contraseña', style: TextStyle(fontSize: 18, color: Colors.red)),
              SizedBox(height: 20),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.lock, color: Colors.red),
                  hintText: 'Contraseña',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa una contraseña';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              if (_errorMessage.isNotEmpty)
                Text(
                  _errorMessage,
                  style: TextStyle(color: Colors.red),
                ),
              Spacer(),
              Align(
                alignment: Alignment.bottomRight,
                child: ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: CircleBorder(),
                    padding: EdgeInsets.all(16),
                  ),
                  child: Icon(Icons.arrow_forward, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
