import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'splash_screen.dart';

class PermissionRequestScreen extends StatefulWidget {
  const PermissionRequestScreen({super.key});

  @override
  State<PermissionRequestScreen> createState() =>
      _PermissionRequestScreenState();
}

class _PermissionRequestScreenState extends State<PermissionRequestScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<_PermissionItem> _permissions = [
    _PermissionItem(
      title: 'Habilitar Cámara',
      description: 'Permite el uso de la cámara para tomar imágenes.',
      permission: Permission.camera,
      image: 'assets/images/camera.png',
    ),
    _PermissionItem(
      title: 'Habilitar Notificaciones',
      description: 'Permite recibir notificaciones importantes.',
      permission: Permission.notification,
      image: 'assets/images/notification.png',
    ),
    _PermissionItem(
      title: 'Habilitar Ubicación',
      description: 'Usamos tu ubicación para etiquetar contribuciones.',
      permission: Permission.location,
      image: 'assets/images/location.png',
    ),
  ];

  Future<void> _requestPermission(Permission permission) async {
    final status = await permission.request();

    if (status.isGranted) {
      if (_currentPage < _permissions.length - 1) {
        _controller.nextPage(
            duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => SplashScreen()),
        );
      }
    } else {
      openAppSettings(); // Si no acepta, lo llevamos a configuración
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFEFEFF7),
      body: PageView.builder(
        controller: _controller,
        physics: NeverScrollableScrollPhysics(),
        itemCount: _permissions.length,
        itemBuilder: (context, index) {
          final item = _permissions[index];
          _currentPage = index;

          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(item.image, width: 150, height: 150),
                SizedBox(height: 40),
                Text(
                  item.title,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                Text(
                  item.description,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                ),
                SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () => _requestPermission(item.permission),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF0BA37F),
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text("Permitir"),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _PermissionItem {
  final String title;
  final String description;
  final Permission permission;
  final String image;

  _PermissionItem({
    required this.title,
    required this.description,
    required this.permission,
    required this.image,
  });
}
