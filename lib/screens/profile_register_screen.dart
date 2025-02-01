import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'menu_screen.dart';

class ProfileRegisterScreen extends StatefulWidget {
  final String email;
  final String password;

  const ProfileRegisterScreen({super.key, required this.email, required this.password});

  @override
  _ProfileRegisterScreenState createState() => _ProfileRegisterScreenState();
}

class _ProfileRegisterScreenState extends State<ProfileRegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  File? _profileImage;
  String _errorMessage = '';
  bool _isLoading = false; // Indicador de carga

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
      Fluttertoast.showToast(
        msg: 'Imagen seleccionada',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
    } else {
      Fluttertoast.showToast(
        msg: 'Imagen no seleccionada',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.orange,
        textColor: Colors.white,
      );
    }
  }

  Future<String?> _uploadProfileImage(String userId) async {
    if (_profileImage == null) return null;

    try {
      final storageRef =
          FirebaseStorage.instance.ref().child('profile_images/$userId.jpg');
      final uploadTask = await storageRef.putFile(_profileImage!);
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      print('Error al subir la imagen: $e');
      Fluttertoast.showToast(
        msg: 'Error al subir la imagen',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return null;
    }
  }

  Future<void> _registerUser() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      try {
        UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: widget.email,
          password: widget.password,
        );

        final userId = userCredential.user!.uid;
        final photoUrl = await _uploadProfileImage(userId);

        await FirebaseFirestore.instance.collection('users').doc(userId).set({
          'name': _nameController.text.trim(),
          'email': widget.email,
          'phone': _phoneController.text.trim(),
          'profileImage': photoUrl ?? '',
          'createdAt': Timestamp.now(),
        });

        Fluttertoast.showToast(
          msg: 'Registro exitoso',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MenuScreen()),
        );
      } catch (e) {
        setState(() {
          _errorMessage = 'Error al registrar: ${e.toString()}';
        });
        Fluttertoast.showToast(
          msg: _errorMessage,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      } finally {
        setState(() {
          _isLoading = false;
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
                    'Crear cuenta',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Ingresa tu contacto',
                    style: TextStyle(fontSize: 18, color: Colors.green),
                  ),
                  SizedBox(height: 30),
                  Center(
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 85,
                        backgroundColor: Colors.green[200],
                        backgroundImage: _profileImage != null
                            ? FileImage(_profileImage!)
                            : null,
                        child: _profileImage == null
                            ? Icon(Icons.person, color: Colors.white, size: 50)
                            : null,
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.person, color: Colors.green),
                      hintText: 'Nombre completo',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: (value) {
                      if (RegExp(r'[0-9]').hasMatch(value)) {
                        Fluttertoast.showToast(
                          msg: 'No se aceptan números',
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          backgroundColor: Colors.red,
                          textColor: Colors.white,
                        );
                        _nameController.text =
                            value.replaceAll(RegExp(r'[0-9]'), '');
                        _nameController.selection = TextSelection.fromPosition(
                          TextPosition(offset: _nameController.text.length),
                        );
                      }
                      List<String> words = value.trim().split(' ');
                      if (words.length > 4) {
                        Fluttertoast.showToast(
                          msg: 'Máximo 2 nombres y 2 apellidos permitidos',
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          backgroundColor: Colors.red,
                          textColor: Colors.white,
                        );
                        _nameController.text = words.sublist(0, 4).join(' ');
                        _nameController.selection = TextSelection.fromPosition(
                          TextPosition(offset: _nameController.text.length),
                        );
                      }
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, ingresa tu nombre completo';
                      }
                      if (RegExp(r'[0-9]').hasMatch(value)) {
                        return 'No se aceptan números';
                      }
                      List<String> words = value.trim().split(' ');
                      if (words.length > 4) {
                        return 'Máximo 2 nombres y 2 apellidos permitidos';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.phone, color: Colors.green),
                      hintText: 'Número de teléfono',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: (value) {
                      if (!RegExp(r'^[0-9]*$').hasMatch(value)) {
                        Fluttertoast.showToast(
                          msg: 'No se aceptan caracteres',
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          backgroundColor: Colors.red,
                          textColor: Colors.white,
                        );
                        _phoneController.text =
                            value.replaceAll(RegExp(r'[^0-9]'), '');
                        _phoneController.selection = TextSelection.fromPosition(
                          TextPosition(offset: _phoneController.text.length),
                        );
                      }
                      if (value.length > 10) {
                        Fluttertoast.showToast(
                          msg: 'Solo se permiten 10 números',
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          backgroundColor: Colors.red,
                          textColor: Colors.white,
                        );
                        _phoneController.text = value.substring(0, 10);
                        _phoneController.selection = TextSelection.fromPosition(
                          TextPosition(offset: _phoneController.text.length),
                        );
                      }
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, ingresa tu número de teléfono';
                      }
                      if (value.length != 10) {
                        return 'Debe contener 10 dígitos';
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
                      onPressed: _registerUser,
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
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 6,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
