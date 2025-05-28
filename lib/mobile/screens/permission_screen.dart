import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'splash_screen.dart'; // Para regresar luego de aceptar los permisos

class PermissionScreen extends StatefulWidget {
  const PermissionScreen({super.key});

  @override
  State<PermissionScreen> createState() => _PermissionScreenState();
}

class _PermissionScreenState extends State<PermissionScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_Permiso> _permisos = [
    _Permiso(
      icon: 'assets/icons/alerts_permissions/icon_camera_3d.png',
      title: 'Permitir acceso a la cámara',
      description:
          'Necesitamos tu cámara para capturar imágenes de tus cultivos.',
      permiso: Permission.camera,
    ),
    _Permiso(
      icon: 'assets/icons/alerts_permissions/icon_notification_3d.png',
      title: 'Activar notificaciones',
      description:
          'Te informaremos sobre el estado de tus contribuciones y novedades.',
      permiso: Permission.notification,
    ),
    _Permiso(
      icon: 'assets/icons/alerts_permissions/icon_location_3d.png',
      title: 'Habilitar ubicación',
      description:
          'Usamos tu ubicación para georreferenciar tus contribuciones',
      permiso: Permission.location,
    ),
  ];

  Future<void> _solicitarPermiso(Permission permiso) async {
    final status = await permiso.request();
    if (status.isGranted) {
      if (_currentPage < _permisos.length - 1) {
        _pageController.nextPage(
          duration: Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const SplashScreen()),
        );
      }
    } else {
      // Aquí podrías mostrar un snackbar o alerta si lo niega
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF6F9FB),
      body: PageView.builder(
          controller: _pageController,
          physics: BouncingScrollPhysics(),
          onPageChanged: (index) => setState(() => _currentPage = index),
          itemCount: _permisos.length,
          itemBuilder: (_, index) {
            final permiso = _permisos[index];
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(permiso.icon, height: 180),
                  SizedBox(height: 40),
                  Text(
                    permiso.title,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  Text(
                    permiso.description,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  ),
                  SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: () => _solicitarPermiso(permiso.permiso),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0BA37F),
                      padding:
                          EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      'Sí, deseo habilitarlo',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextButton(
                    onPressed: () {
                      if (_currentPage < _permisos.length - 1) {
                        _pageController.nextPage(
                          duration: Duration(milliseconds: 500),
                          curve: Curves.easeInOut,
                        );
                      } else {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const SplashScreen()),
                        );
                      }
                    },
                    child: Text(
                      'Ahora no',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
    );
  }
}

class _Permiso {
  final String icon;
  final String title;
  final String description;
  final Permission permiso;

  _Permiso({
    required this.icon,
    required this.title,
    required this.description,
    required this.permiso,
  });
}
