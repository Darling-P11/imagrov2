import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  void _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('No se pudo abrir el enlace');
    }
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
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back_ios_new, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Center(
              child: Text(
                'Política de privacidad',
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
    // Cambiar color del status bar
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Color(0xFF0BA37F),
        statusBarIconBrightness: Brightness.light,
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildEncabezado(context),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Protección de datos personales',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Esta aplicación fue desarrollada como un proyecto de código abierto bajo la licencia GPL-3.0. Su origen se remonta a una tesis de grado titulada “Sistema para la generación y visualización georreferenciada de conjuntos de datos de cultivos agrícolas”, elaborada en la carrera de Ingeniería en Software de la Universidad Técnica Estatal de Quevedo. Este proyecto tiene fines académicos, investigativos y comunitarios.\n\nNo se recopila, almacena ni comparte información personal de los usuarios sin su consentimiento explícito. El código fuente está disponible públicamente, y se invita a la comunidad a revisarlo, mejorarlo o reutilizarlo conforme a los términos de la licencia GPL-3.0.',
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Permisos utilizados',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'La aplicación puede requerir permisos para acceder a la cámara, ubicación y notificaciones. Estos permisos son utilizados únicamente para el funcionamiento adecuado de las funcionalidades principales de la aplicación. El usuario puede modificar estos permisos en cualquier momento desde la configuración de su dispositivo.',
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Código fuente',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),

                  // Tarjeta 1 - Repositorio móvil
                  Card(
                    margin: EdgeInsets.symmetric(vertical: 6),
                    color: Colors.white,
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                    child: ListTile(
                      leading: Icon(Icons.code, color: Color(0xFF0BA37F)),
                      title: Text('Repositorio móvil (Flutter)'),
                      subtitle: Text('github.com/Darling-P11/imagrov2'),
                      trailing: Icon(Icons.open_in_new, color: Colors.grey),
                      onTap: () =>
                          _openUrl('https://github.com/Darling-P11/imagrov2'),
                    ),
                  ),

                  // Tarjeta 2 - Repositorio web
                  Card(
                    margin: EdgeInsets.symmetric(vertical: 6),
                    color: Colors.white,
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                    child: ListTile(
                      leading: Icon(Icons.web, color: Color(0xFF0BA37F)),
                      title: Text('Repositorio web (Angular)'),
                      subtitle: Text('github.com/Darling-P11/imagro_web'),
                      trailing: Icon(Icons.open_in_new, color: Colors.grey),
                      onTap: () =>
                          _openUrl('https://github.com/Darling-P11/imagro_web'),
                    ),
                  ),

                  SizedBox(height: 20),
                  Text(
                    'Licencia',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Este proyecto se encuentra bajo la Licencia Pública General GNU versión 3 (GPL-3.0), lo cual permite su libre distribución, modificación y uso, siempre que se mantenga el mismo tipo de licencia.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
