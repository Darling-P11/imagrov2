import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/logo_verde.png', // Ruta de la imagen del logo
              width: 140,
              height: 140,
            ),
            SizedBox(height: 25),
            Text(
              'Imagro',
              style: TextStyle(
                color: Colors.green,
                fontSize: 35,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Es momento de unirte a imagro',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
            SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () {
                // Acción para continuar con email
              },
              icon: Icon(Icons.email, color: Colors.white),
              label: Text('Continuar con E-mail'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black, // Color de fondo
                foregroundColor: Colors.white, // Color del texto e íconos
                minimumSize:
                    Size(double.infinity, 50), // Botón de ancho completo
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ), // Tamaño del botón
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                // Acción para continuar con Google
              },
              icon: Image.asset(
                'assets/icons/google_icon.png', // Ruta del ícono de Google
                width: 20,
                height: 20,
              ),
              label: Text('Continuar con Google'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white, // Fondo blanco
                foregroundColor: Colors.black, // Texto e íconos negros
                side: BorderSide(color: Colors.black), // Borde negro
                minimumSize: Size(double.infinity, 50), // Tamaño del botón
              ),
            ),
          ],
        ),
      ),
    );
  }
}
