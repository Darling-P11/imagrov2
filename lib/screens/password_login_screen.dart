import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PasswordLoginScreen extends StatefulWidget {
  final String email;

  const PasswordLoginScreen({super.key, required this.email});

  @override
  _PasswordLoginScreenState createState() => _PasswordLoginScreenState();
}

class _PasswordLoginScreenState extends State<PasswordLoginScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  final String _errorMessage = '';
  String? userName;
  String? userProfileImage;
  bool _canRequestPasswordReset =
      true; // Control para evitar múltiples solicitudes

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
  }

  Future<void> _fetchUserDetails() async {
    setState(() {
      _isLoading = true;
    });
    try {
      var userDoc = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: widget.email)
          .get();
      if (userDoc.docs.isNotEmpty) {
        var userData = userDoc.docs.first.data();
        setState(() {
          userName = userData['name'];
          userProfileImage = userData['profileImage'];
        });
      }
    } catch (e) {
      _showToast('Error al cargar los datos del usuario');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showToast(String message, {Color backgroundColor = Colors.red}) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: backgroundColor,
      textColor: Colors.white,
    );
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: widget.email,
          password: _passwordController.text.trim(),
        );
        Navigator.pushReplacementNamed(context, '/menu');
      } on FirebaseAuthException catch (e) {
        _showToast('Error al iniciar sesión: ${e.message}');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _forgotPassword() async {
    if (!_canRequestPasswordReset) {
      _showToast('Por favor espera antes de enviar otra solicitud.');
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Recuperar contraseña'),
          content: Text(
              '¿Quieres enviar la solicitud para recuperar la contraseña?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showToast('Solicitud cancelada',
                    backgroundColor: Colors.orange);
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                setState(() {
                  _isLoading = true;
                });

                try {
                  await FirebaseAuth.instance
                      .sendPasswordResetEmail(email: widget.email);
                  _showToast('Solicitud enviada',
                      backgroundColor: Colors.green);
                  _canRequestPasswordReset = false;

                  // Rehabilitar el envío de la solicitud después de 60 segundos
                  Future.delayed(Duration(seconds: 60), () {
                    setState(() {
                      _canRequestPasswordReset = true;
                    });
                  });
                } catch (e) {
                  _showToast('Error al enviar la solicitud');
                } finally {
                  setState(() {
                    _isLoading = false;
                  });
                }
              },
              child: Text('Confirmar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: BackButton(color: Colors.black),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        children: [
          if (!_isLoading)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Iniciar sesión',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                        height: 3), // Separación entre el título y subtítulo
                    Text(
                      'Ingresa tu contraseña',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    SizedBox(height: 80), // Separación entre subtítulo e imagen
                    Center(
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 65,
                            backgroundColor: Colors.grey[200],
                            backgroundImage: userProfileImage != null
                                ? NetworkImage(userProfileImage!)
                                : null,
                            child: userProfileImage == null
                                ? Icon(
                                    Icons.person,
                                    size: 50,
                                    color: const Color.fromARGB(
                                        255, 119, 119, 119),
                                  )
                                : null,
                          ),
                          SizedBox(height: 10),
                          Text(
                            userName ?? 'Cargando...',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: !_isPasswordVisible,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.lock, color: Colors.green),
                        hintText: 'Contraseña',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.green,
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingresa una contraseña';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: _forgotPassword,
                        child: Text(
                          '¿Olvidaste tu contraseña?',
                          style: TextStyle(
                            color: const Color.fromARGB(255, 83, 83, 83),
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                    Spacer(),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: ElevatedButton(
                        onPressed: _login,
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
              color: Colors.white.withOpacity(0.8),
              child: Center(
                child: CircularProgressIndicator(
                  color: Colors.green,
                  strokeWidth: 6.0,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
