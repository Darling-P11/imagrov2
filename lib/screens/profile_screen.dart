import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final User? user = FirebaseAuth.instance.currentUser;
  File? _selectedImage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FutureBuilder<DocumentSnapshot>(
        future:
            FirebaseFirestore.instance.collection('users').doc(user?.uid).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text("No se encontraron datos del usuario."));
          }

          final userData = snapshot.data!.data() as Map<String, dynamic>;

          return SingleChildScrollView(
            child: Column(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      height: 225,
                      decoration: BoxDecoration(
                        color: Color(0xFF0BA37F),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(30),
                          bottomRight: Radius.circular(30),
                        ),
                      ),
                    ),
                    Positioned(
                      top: MediaQuery.of(context).padding.top + 10,
                      left: 16,
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.white,
                            child: IconButton(
                              icon: Icon(Icons.arrow_back,
                                  color: Color(0xFF0BA37F)),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            "Perfil",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      top: 70,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Image.asset(
                          'assets/images/logo_banner.png',
                          height: 120,
                          width: 120,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 160,
                      left: MediaQuery.of(context).size.width / 2 - 60,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 125,
                            height: 125,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              border: Border.all(color: Colors.white, width: 4),
                            ),
                            child: ClipOval(
                              child: _selectedImage != null
                                  ? Image.file(
                                      _selectedImage!,
                                      fit: BoxFit.cover,
                                    )
                                  : userData['profileImage'] != null
                                      ? Image.network(
                                          userData['profileImage'],
                                          fit: BoxFit.cover,
                                        )
                                      : Image.asset(
                                          'assets/icons/perfil.png',
                                          fit: BoxFit.cover,
                                        ),
                            ),
                          ),
                          Positioned(
                            bottom: 5,
                            right: 5,
                            child: GestureDetector(
                              onTap: () async {
                                await _pickImage(context);
                              },
                              child: CircleAvatar(
                                backgroundColor: Colors.green,
                                radius: 20,
                                child: Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 60),
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            vertical: 6.0, horizontal: 64.0),
                        decoration: BoxDecoration(
                          color: Color(0xFFB8F2E1),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Text(
                          "Mi perfil",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                    ),
                    _buildProfileField(
                      context: context,
                      icon: Icons.person,
                      hintText: userData['name'] ?? "Nombre de usuario",
                    ),
                    _buildProfileField(
                      context: context,
                      icon: Icons.email,
                      hintText: user?.email ?? "tucorreo@email.com",
                    ),
                    _buildProfileField(
                      context: context,
                      icon: Icons.phone,
                      hintText: userData['phone'] ?? "+593999999999",
                    ),
                    SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: ElevatedButton(
                        onPressed: () async {
                          await FirebaseAuth.instance.signOut();
                          Navigator.pushNamedAndRemoveUntil(
                              context, '/', (route) => false);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: EdgeInsets.symmetric(
                              vertical: 14, horizontal: 25),
                        ),
                        child: Text(
                          "Cerrar sesión",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _pickImage(BuildContext context) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
      await _confirmAndUploadImage();
    }
  }

  Future<void> _confirmAndUploadImage() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmar actualización'),
          content: Text('¿Deseas actualizar tu foto de perfil?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text('Aceptar'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      try {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('profile_images/${user?.uid}.jpg');
        await storageRef.putFile(_selectedImage!);
        final imageUrl = await storageRef.getDownloadURL();

        await FirebaseFirestore.instance
            .collection('users')
            .doc(user?.uid)
            .update({'profileImage': imageUrl});

        Fluttertoast.showToast(msg: 'Foto de perfil actualizada con éxito.');
      } catch (e) {
        Fluttertoast.showToast(msg: 'Error al actualizar la foto.');
      }
    } else {
      Fluttertoast.showToast(msg: 'Actualización cancelada.');
    }
  }

  Widget _buildProfileField({
    required BuildContext context,
    required IconData icon,
    required String hintText,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: TextField(
        enabled: false,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.grey),
          hintText: hintText,
          hintStyle: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade600,
          ),
          filled: true,
          fillColor: Colors.grey.shade200,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
