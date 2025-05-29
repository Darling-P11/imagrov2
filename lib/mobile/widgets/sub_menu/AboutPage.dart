import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  void _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('No se pudo abrir el enlace');
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // Contenido centrado
            Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Logo con sombra y marco
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF0BA37F),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 6,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      padding: EdgeInsets.all(12),
                      child: Image.asset(
                        'assets/images/logo.png',
                        height: 65,
                        width: 65,
                        fit: BoxFit.contain,
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Imagro App',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      'Versión 1.0.0',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    SizedBox(height: 16),
                    Divider(thickness: 1, color: Colors.grey.shade300),
                    SizedBox(height: 16),

                    // Tarjeta de información
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade300),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 6,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(Icons.person_outline,
                                  color: Color(0xFF0BA37F)),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Desarrollado por Kevin Darling Ponce Rivera',
                                  style: TextStyle(fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          Row(
                            children: [
                              Icon(Icons.school_outlined,
                                  color: Color(0xFF0BA37F)),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Tesis de Ingeniería en Software\nUTEQ - 2025',
                                  style: TextStyle(fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 24),

                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF0BA37F),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding:
                            EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                        elevation: 4,
                      ),
                      onPressed: () {
                        Navigator.pushNamed(context, '/privacy-policy');
                      },
                      icon: Icon(Icons.privacy_tip_outlined,
                          size: 20, color: Colors.white),
                      label: Text(
                        'Licencias y privacidad',
                        style: TextStyle(fontSize: 15, color: Colors.white),
                      ),
                    ),

                    SizedBox(height: 32),

                    Text(
                      '© 2025 Imagro | GPL-3.0 License',
                      style:
                          TextStyle(fontSize: 12, color: Colors.grey.shade500),
                    ),
                  ],
                ),
              ),
            ),

            // Botón atrás
            Positioned(
              top: 10,
              left: 0,
              child: IconButton(
                icon: Icon(Icons.arrow_back_ios_new, color: Color(0xFF0BA37F)),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
