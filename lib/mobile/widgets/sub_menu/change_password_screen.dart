import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  bool _isCurrentVisible = false;
  bool _isNewVisible = false;
  bool _isConfirmVisible = false;

  Widget _buildEncabezado(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 15,
        bottom: 20,
      ),
      decoration: BoxDecoration(
        color: Color(0xFF0BA37F),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back_ios_new, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Center(
              child: Text(
                'Cambiar contraseña',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          SizedBox(width: 48),
        ],
      ),
    );
  }

  InputDecoration buildInputDecoration(
      String hintText, bool isVisible, VoidCallback toggleVisibility) {
    return InputDecoration(
      prefixIcon: Icon(Icons.lock, color: Color(0xFF0BA37F)),
      hintText: hintText,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.black),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Color(0xFF0BA37F), width: 2.0),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.red, width: 2.0),
      ),
      suffixIcon: IconButton(
        icon: Icon(
          isVisible ? Icons.visibility : Icons.visibility_off,
          color: Color(0xFF0BA37F),
        ),
        onPressed: toggleVisibility,
      ),
    );
  }

  Future<void> _changePassword() async {
    final user = FirebaseAuth.instance.currentUser!;
    final cred = EmailAuthProvider.credential(
      email: user.email!,
      password: currentPasswordController.text.trim(),
    );

    if (newPasswordController.text.trim() !=
        confirmPasswordController.text.trim()) {
      _showSnackBar('Las contraseñas nuevas no coinciden.', isError: true);
      return;
    }

    try {
      setState(() => _isLoading = true);
      await user.reauthenticateWithCredential(cred);
      await user.updatePassword(newPasswordController.text.trim());
      _showSnackBar('Contraseña actualizada con éxito');
      await _guardarNotificacion(user.uid);

      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      _showSnackBar('Error: ${e.message}', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    final color = isError ? Colors.red.shade100 : Colors.green.shade100;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: Colors.black87)),
        backgroundColor: color,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildEncabezado(context),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: currentPasswordController,
                      obscureText: !_isCurrentVisible,
                      decoration: buildInputDecoration(
                          'Contraseña actual', _isCurrentVisible, () {
                        setState(() {
                          _isCurrentVisible = !_isCurrentVisible;
                        });
                      }),
                      validator: (value) =>
                          value!.isEmpty ? 'Campo obligatorio' : null,
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: newPasswordController,
                      obscureText: !_isNewVisible,
                      decoration: buildInputDecoration(
                          'Nueva contraseña', _isNewVisible, () {
                        setState(() {
                          _isNewVisible = !_isNewVisible;
                        });
                      }),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Campo obligatorio';
                        }
                        if (value.length < 8 || value.length > 16) {
                          return 'Debe tener entre 8 y 16 caracteres';
                        }
                        final regexMayuscula = RegExp(r'[A-Z]');
                        final regexMinuscula = RegExp(r'[a-z]');
                        final regexNumero = RegExp(r'[0-9]');
                        final regexEspecial =
                            RegExp(r'[!@#\$%^&*(),.?":{}|<>]');

                        if (!regexMayuscula.hasMatch(value)) {
                          return 'Debe contener al menos una mayúscula';
                        }
                        if (!regexMinuscula.hasMatch(value)) {
                          return 'Debe contener al menos una minúscula';
                        }
                        if (!regexNumero.hasMatch(value)) {
                          return 'Debe contener al menos un número';
                        }
                        if (!regexEspecial.hasMatch(value)) {
                          return 'Debe contener al menos un carácter especial';
                        }

                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: confirmPasswordController,
                      obscureText: !_isConfirmVisible,
                      decoration: buildInputDecoration(
                          'Confirmar nueva contraseña', _isConfirmVisible, () {
                        setState(() {
                          _isConfirmVisible = !_isConfirmVisible;
                        });
                      }),
                      validator: (value) => value != newPasswordController.text
                          ? 'Las contraseñas no coinciden'
                          : null,
                    ),
                    SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: _isLoading
                          ? null
                          : () {
                              if (_formKey.currentState!.validate()) {
                                _changePassword();
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF0BA37F),
                        padding:
                            EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: _isLoading
                          ? CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            )
                          : Text(
                              'Actualizar contraseña',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

//Guardar la info de notificacion
Future<void> _guardarNotificacion(String userId) async {
  final mensajeRef = FirebaseFirestore.instance
      .collection('notificaciones')
      .doc(userId)
      .collection('mensajes')
      .doc();

  await mensajeRef.set({
    'titulo': 'Actualización de contraseña',
    'descripcion': 'Tu contraseña fue modificada exitosamente.',
    'fecha': Timestamp.now(),
    'leida': false,
  });
}
