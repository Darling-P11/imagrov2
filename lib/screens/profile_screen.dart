import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                // Fondo verde con bordes redondeados
                Container(
                  height: 225, // Ajustado para que sea más ancho
                  decoration: BoxDecoration(
                    color: Color(0xFF0BA37F),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                ),
                // Botón de retroceso y título "Perfil"
                Positioned(
                  top: MediaQuery.of(context).padding.top + 10,
                  left: 16,
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.white,
                        child: IconButton(
                          icon:
                              Icon(Icons.arrow_back, color: Color(0xFF0BA37F)),
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
                // Logotipo en el centro del encabezado
                Positioned(
                  top: 70,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Image.asset(
                      'assets/images/logo_banner.png', // Ruta del logotipo
                      height: 120,
                      width: 120,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                // Foto de perfil con fondo circular
                Positioned(
                  top: 160, // Ajustado para mejor posición
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
                          child: Image.asset(
                            'assets/icons/perfil.png', // Imagen predeterminada del perfil
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      // Botón de la cámara sobrepuesto
                      Positioned(
                        bottom: 5,
                        right: 5,
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
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 60,
            ),
            // Cuerpo del perfil
            Column(
              children: [
                // Título "Mi perfil" con diseño
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(vertical: 6.0, horizontal: 64.0),
                    decoration: BoxDecoration(
                      color: Color(0xFFB8F2E1), // Fondo verde claro
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
                // Campos de información del usuario
                _buildProfileField(
                  context: context,
                  icon: Icons.person,
                  hintText: "Nombre de usuario",
                ),
                _buildProfileField(
                  context: context,
                  icon: Icons.email,
                  hintText: "tucorreo@email.com",
                ),
                _buildProfileField(
                  context: context,
                  icon: Icons.phone,
                  hintText: "+593999999999",
                ),
                SizedBox(height: 20),
                // Botón de cerrar sesión
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: ElevatedButton(
                    onPressed: () {
                      // Acción para cerrar sesión
                      print("Cerrar sesión");
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent, // Color rojo del botón
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding:
                          EdgeInsets.symmetric(vertical: 14, horizontal: 25),
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
      ),
    );
  }

  Widget _buildProfileField({
    required BuildContext context,
    required IconData icon,
    required String hintText,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: TextField(
        enabled: false, // Deshabilitado porque es solo para mostrar datos
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
