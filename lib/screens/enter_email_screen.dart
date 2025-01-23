import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'password_register_screen.dart';
import 'password_login_screen.dart';

class EnterEmailScreen extends StatefulWidget {
  @override
  _EnterEmailScreenState createState() => _EnterEmailScreenState();
}

class _EnterEmailScreenState extends State<EnterEmailScreen> {
  final TextEditingController _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false; // Indicador de carga

  Future<void> _checkEmail() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      try {
        var email =
            _emailController.text.trim().toLowerCase(); // Normalizar correo
        var methods =
            await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);

        setState(() {
          _isLoading = false;
        });

        if (methods.isNotEmpty) {
          // Si hay métodos, el correo existe
          Fluttertoast.showToast(
            msg: 'Correo existente, redirigiendo al login',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: const Color.fromARGB(255, 224, 129, 5),
            textColor: Colors.white,
          );
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PasswordLoginScreen(email: email),
            ),
          );
        } else {
          // Si no hay métodos, el correo no está registrado
          Fluttertoast.showToast(
            msg: 'Correo no registrado, redirigiendo al registro',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: const Color.fromARGB(255, 224, 129, 5),
            textColor: Colors.white,
          );
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PasswordRegisterScreen(email: email),
            ),
          );
        }
      } on FirebaseAuthException catch (e) {
        setState(() {
          _isLoading = false;
        });
        Fluttertoast.showToast(
          msg: 'Error: ${e.message}',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        Fluttertoast.showToast(
          msg: 'Error inesperado: $e',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
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
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bienvenido',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: const Color.fromARGB(255, 43, 43, 43),
                    ),
                  ),
                  Text(
                    'Ingresa tu email',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.email, color: Colors.green),
                      hintText: 'example@example.com',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa un correo';
                      } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                          .hasMatch(value)) {
                        Fluttertoast.showToast(
                          msg: 'Correo inválido',
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          backgroundColor: Colors.red,
                          textColor: Colors.white,
                        );
                        return 'Ingresa un correo válido';
                      }
                      return null;
                    },
                  ),
                  Spacer(),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: ElevatedButton(
                      onPressed: _checkEmail,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
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
          if (_isLoading)
            Container(
              color: Colors.black54, // Fondo semitransparente
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                  strokeWidth: 6,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
