import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileDropdownMenu extends StatelessWidget {
  final User? user;
  final String? userImage;
  final String? userName;

  const ProfileDropdownMenu({
    super.key,
    this.user,
    this.userImage,
    this.userName,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<int>(
      onSelected: (value) {
        if (value == 1) {
          Navigator.pushNamed(context, '/profile'); // Redirige al perfil
        } else if (value == 2) {
          Navigator.pushNamed(context, '/change-password');
        } else if (value == 3) {
          Navigator.pushNamed(context, '/support');
        } else if (value == 5) {
          Navigator.pushNamed(context, '/about');
        } else if (value == 6) {
          Navigator.pushNamed(context, '/privacy-policy');
        } else if (value == 7) {
          Navigator.pushNamed(context, '/permissions');
        } else if (value == 4) {
          _signOut(context); // Cerrar sesión
        }
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      offset: Offset(0, 50), // Ajusta la posición del menú desplegable
      itemBuilder: (context) => [
        PopupMenuItem(
          enabled: false,
          child: SizedBox(
            width: 220, // Ancho del menú
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
                    Expanded(
                      // ✅ Evita desbordamientos
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userName ?? 'Usuario',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize:
                                  (userName != null && userName!.length > 20)
                                      ? 14
                                      : 16, // 🔹 Reduce tamaño si es largo
                              color: Colors.black87,
                            ),
                            maxLines: 1, // 🔹 Evita que se desborde
                            overflow: TextOverflow
                                .ellipsis, // 🔹 Agrega "..." si es muy largo
                          ),
                          SizedBox(height: 4),
                          Text(
                            user?.email ?? 'Correo no disponible',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                            maxLines: 1, // 🔹 Evita solapamientos
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Divider(height: 1, color: Colors.grey.shade300),
              ],
            ),
          ),
        ),
        PopupMenuItem(
          value: 1,
          child: ListTile(
            leading: Icon(Icons.person, color: Colors.black87),
            title: Text(
              'Ver perfil',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
        ),
        PopupMenuItem(
          value: 2,
          child: ListTile(
            leading: Icon(Icons.lock_outline, color: Colors.black87),
            title: Text('Cambiar contraseña',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          ),
        ),
        PopupMenuItem(
          value: 3,
          child: ListTile(
            leading: Icon(Icons.help_outline, color: Colors.black87),
            title: Text('Soporte / Ayuda',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          ),
        ),
        PopupMenuItem(
          value: 5,
          child: ListTile(
            leading: Icon(Icons.info_outline, color: Colors.black87),
            title: Text('Acerca de',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          ),
        ),
        PopupMenuItem(
          value: 6,
          child: ListTile(
            leading: Icon(Icons.privacy_tip_outlined, color: Colors.black87),
            title: Text('Política de privacidad',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          ),
        ),
        PopupMenuItem(
          value: 7,
          child: ListTile(
            leading: Icon(Icons.security_outlined, color: Colors.black87),
            title: Text('Permisos',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          ),
        ),

        //PopupMenuItem(
        //  value: 3,
        //  child: ListTile(
        //    leading: Icon(Icons.help_outline, color: Colors.black87),
        //    title: Text(
        //     'Tutorial',
        //    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        //   ),
        //  ),
        // ),
        PopupMenuDivider(),
        PopupMenuItem(
          value: 4,
          child: ListTile(
            leading: Icon(Icons.logout, color: Colors.red),
            title: Text(
              'Cerrar sesión',
              style: TextStyle(
                color: Colors.red,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
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
