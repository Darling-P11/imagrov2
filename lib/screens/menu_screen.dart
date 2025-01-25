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

  @override
  void initState() {
    super.initState();
    _fetchUserImage();
  }

  Future<void> _fetchUserImage() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          setState(() {
            userImage = userDoc.data()?['profileImage'] ?? null;
          });
        }
      }
    } catch (e) {
      print('Error fetching user image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            HeaderWidget(userImage: userImage), // Pasar la imagen al encabezado
            SizedBox(height: 15),
            FunctionalitiesWidget(),
          ],
        ),
      ),
      floatingActionButton: FooterWidget(),
    );
  }
}
