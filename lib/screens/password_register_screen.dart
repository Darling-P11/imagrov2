import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'profile_register_screen.dart';

class PasswordRegisterScreen extends StatefulWidget {
  final String email;

  PasswordRegisterScreen({required this.email});

  @override
  _PasswordRegisterScreenState createState() => _PasswordRegisterScreenState();
}

class _PasswordRegisterScreenState extends State<PasswordRegisterScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // Validar contraseñas
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, ingresa una contraseña';
    } else if (value.length < 8 || value.length > 16) {
      return 'La contraseña debe tener entre 8 y 16 caracteres';
    } else if (!RegExp(r'(?=.*[A-Z])').hasMatch(value)) {
      return 'Debe contener al menos una mayúscula';
    } else if (!RegExp(r'(?=.*[!@#$%^&*(),.?":{}|<>])').hasMatch(value)) {
      return 'Debe contener al menos un carácter especial';
    }
    return null;
  }

  void _showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.red,
      textColor: Colors.white,
    );
  }

  void _nextStep() {
    if (_formKey.currentState!.validate()) {
      if (_passwordController.text != _confirmPasswordController.text) {
        _showToast('Las contraseñas no coinciden');
        return;
      }
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProfileRegisterScreen(
            email: widget.email,
            password: _passwordController.text,
          ),
        ),
      );
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
              Text('Crear cuenta',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              Text('Ingresa tu contraseña',
                  style: TextStyle(fontSize: 18, color: Colors.red)),
              SizedBox(height: 20),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.lock, color: Colors.red),
                  hintText: 'Contraseña',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                validator: _validatePassword,
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.lock, color: Colors.red),
                  hintText: 'Confirmar contraseña',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor confirma tu contraseña';
                  }
                  return null;
                },
              ),
              Spacer(),
              Align(
                alignment: Alignment.bottomRight,
                child: ElevatedButton(
                  onPressed: _nextStep,
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
