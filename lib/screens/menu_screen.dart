import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:imagro/widgets/encabezado_menu.dart';
import 'package:imagro/widgets/funcionalidades_menu.dart';
import 'package:imagro/widgets/flotante_pie_menu.dart';

class MenuScreen extends StatefulWidget {
  @override
  _MenuScreenState createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  String? userImage;
  String? userName; // Nuevo: Para almacenar el nombre del usuario
  User? currentUser;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        setState(() {
          currentUser = user;
        });

        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          setState(() {
            userImage = userDoc.data()?['profileImage'] ?? null;
            userName = userDoc.data()?['name'] ?? user.displayName; // Aquí
          });
        }
      }
    } catch (e) {
      print('Error al obtener los datos del usuario: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            HeaderWidget(
              user: currentUser,
              userImage: userImage,
              userName: userName,
            ),
            SizedBox(height: 15),
            FunctionalitiesWidget(),
          ],
        ),
      ),
      floatingActionButton: FooterWidget(),
    );
  }
}
