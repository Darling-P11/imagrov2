import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:imagro/screens/password_register_screen.dart';
import 'password_login_screen.dart';


class EnterEmailScreen extends StatefulWidget {
  @override
  _EnterEmailScreenState createState() => _EnterEmailScreenState();
}

class _EnterEmailScreenState extends State<EnterEmailScreen> {
  final TextEditingController _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String _errorMessage = '';

  Future<void> _checkEmail() async {
    if (_formKey.currentState!.validate()) {
      try {
        var email =
            _emailController.text.trim().toLowerCase(); // Normalizar correo
        print('Verificando correo: $email');

        // Verificar si el correo tiene métodos de inicio de sesión asociados
        var methods =
            await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);

        if (methods.isNotEmpty) {
          // Si hay métodos de inicio de sesión, el correo existe
          print('El correo $email existe. Redirigiendo al login...');
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PasswordLoginScreen(email: email),
            ),
          );
        } else {
          // Si no hay métodos de inicio de sesión, el correo no está registrado
          print(
              'El correo $email no está registrado. Redirigiendo al registro...');
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PasswordRegisterScreen(email: email),
            ),
          );
        }
      } on FirebaseAuthException catch (e) {
        // Manejo de errores específicos de Firebase
        print('FirebaseAuthException: ${e.code}');
        setState(() {
          _errorMessage = 'Error verificando el correo: ${e.message}';
        });
      } catch (e) {
        // Manejo de errores inesperados
        print('Error inesperado: $e');
        setState(() {
          _errorMessage = 'Error inesperado: $e';
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
              Text(
                'Bienvenido',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Text(
                'Ingresa tu email',
                style: TextStyle(fontSize: 18, color: Colors.red),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.email, color: Colors.red),
                  hintText: 'example@example.com',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa un correo';
                  } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Ingresa un correo válido';
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
                  onPressed: _checkEmail,
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
