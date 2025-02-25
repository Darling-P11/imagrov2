import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = false;

  Future<void> _signInWithGoogle() async {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    final FirebaseAuth auth = FirebaseAuth.instance;

    setState(() {
      _isLoading = true;
    });

    try {
      // 🔹 Iniciar sesión con Google sin hacer "disconnect"
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        Fluttertoast.showToast(
          msg: "Inicio de sesión cancelado",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.orange,
          textColor: Colors.white,
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // 🔹 Obtener autenticación de Google
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // 🔹 Crear credencial para Firebase
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 🔹 Iniciar sesión en Firebase
      final UserCredential userCredential =
          await auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        final userId = user.uid;

        // 🔹 Verificar si el usuario ya está en Firestore
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();

        if (!userDoc.exists) {
          // 🔹 Guardar usuario en Firestore si no existe
          await FirebaseFirestore.instance.collection('users').doc(userId).set({
            'name': user.displayName,
            'email': user.email,
            'phone': user.phoneNumber ?? 'No registrado',
            'profileImage': user.photoURL,
            'createdAt': Timestamp.now(),
            'type': 'normal', // Tipo de usuario por defecto
          });

          Fluttertoast.showToast(
            msg: "Usuario registrado correctamente",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.green,
            textColor: Colors.white,
          );
        } else {
          Fluttertoast.showToast(
            msg: "Inicio de sesión exitoso",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.green,
            textColor: Colors.white,
          );
        }

        // 🔹 Redirigir al usuario al menú principal
        Navigator.pushReplacementNamed(context, '/menu');
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Error al iniciar sesión con Google: $e",
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Padding(
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
                    Navigator.pushNamed(
                      context,
                      '/email', // Ruta a la pantalla de ingreso de correo
                    );
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
                    ),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () => _signInWithGoogle(),
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
