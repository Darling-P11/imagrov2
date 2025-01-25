import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileDropdownMenu extends StatelessWidget {
  final User? user;
  final String? userImage;
  final String? userName; // Nuevo parámetro para el nombre del usuario

  ProfileDropdownMenu({this.user, this.userImage, this.userName});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<int>(
      onSelected: (value) {
        if (value == 4) {
          _signOut(context); // Cerrar sesión
        }
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      itemBuilder: (context) => [
        PopupMenuItem(
          enabled: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundImage: userImage != null
                        ? NetworkImage(userImage!)
                        : AssetImage('assets/icons/perfil.png')
                            as ImageProvider,
                  ),
                  SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName ??
                            'Usuario', // Muestra el nombre o un valor predeterminado
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        user?.email ?? 'Correo no disponible',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 8),
              Divider(),
            ],
          ),
        ),
        PopupMenuItem(
          value: 1,
          child: ListTile(
            leading: Icon(Icons.person, color: Colors.black87),
            title: Text('Ver perfil'),
          ),
        ),
        PopupMenuItem(
          value: 2,
          child: ListTile(
            leading: Icon(Icons.settings, color: Colors.black87),
            title: Text('Ajustes'),
          ),
        ),
        PopupMenuItem(
          value: 3,
          child: ListTile(
            leading: Icon(Icons.help_outline, color: Colors.black87),
            title: Text('Ayuda'),
          ),
        ),
        PopupMenuDivider(),
        PopupMenuItem(
          value: 4,
          child: ListTile(
            leading: Icon(Icons.logout, color: Colors.red),
            title: Text(
              'Cerrar sesión',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ),
      ],
      child: CircleAvatar(
        radius: 25,
        backgroundImage: userImage != null
            ? NetworkImage(userImage!)
            : AssetImage('assets/icons/perfil.png') as ImageProvider,
      ),
    );
  }

  void _signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, '/'); // Redirigir al SplashScreen
  }
}
