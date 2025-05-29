import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionsPage extends StatefulWidget {
  const PermissionsPage({super.key});

  @override
  State<PermissionsPage> createState() => _PermissionsPageState();
}

class _PermissionsPageState extends State<PermissionsPage> {
  Map<String, PermissionStatus> _permissions = {};

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    final location = await Permission.location.status;
    final camera = await Permission.camera.status;
    final notifications = await Permission.notification.status;

    setState(() {
      _permissions = {
        'Ubicación': location,
        'Cámara': camera,
        'Notificaciones': notifications,
      };
    });
  }

  Future<void> _requestPermission(String key) async {
    Permission permission;
    if (key == 'Ubicación') {
      permission = Permission.location;
    } else if (key == 'Cámara') {
      permission = Permission.camera;
    } else {
      permission = Permission.notification;
    }

    final result = await permission.request();
    setState(() {
      _permissions[key] = result;
    });
  }

  Widget _buildEncabezado(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 15,
        bottom: 20,
      ),
      decoration: BoxDecoration(
        color: Color(0xFF0BA37F),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back_ios_new, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Center(
              child: Text(
                'Permisos',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          SizedBox(width: 48),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildEncabezado(context),
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(16),
              children: _permissions.entries.map((entry) {
                final isGranted = entry.value.isGranted;
                final icon = isGranted
                    ? Icons.check_circle_outline
                    : Icons.warning_amber_outlined;
                final color = isGranted ? Colors.green : Colors.red;
                final subtitle =
                    isGranted ? 'Permiso concedido' : 'Permiso no concedido';

                return Container(
                  margin: EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      )
                    ],
                  ),
                  child: ListTile(
                    leading: Icon(icon, color: color, size: 28),
                    title: Text(
                      entry.key,
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      subtitle,
                      style: TextStyle(color: color),
                    ),
                    trailing: !isGranted
                        ? TextButton(
                            onPressed: () => _requestPermission(entry.key),
                            child: Text('Solicitar'),
                          )
                        : null,
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
