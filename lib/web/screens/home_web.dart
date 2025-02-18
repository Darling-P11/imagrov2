import 'package:flutter/material.dart';
import 'package:imagro/web/widgets/navbar.dart';

class HomeWebScreen extends StatelessWidget {
  const HomeWebScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Navbar(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildHeroSection(context),
            _buildFeaturesSection(context),
            _buildCallToAction(context),
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  /// 🔹 Sección Hero (Encabezado con fondo y mensaje)
  Widget _buildHeroSection(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return Container(
      height: 400,
      width: width,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/images/hero_bg.jpg"), // Imagen de fondo
          fit: BoxFit.cover,
          colorFilter:
              ColorFilter.mode(Colors.black.withOpacity(0.5), BlendMode.darken),
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Bienvenido a Imagro",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: width < 600 ? 24 : 36, // Tamaño de fuente adaptativo
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: width < 600 ? 20 : 50),
              child: Text(
                "Colabora con imágenes agrícolas y ayuda a entrenar modelos de IA",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.white70, fontSize: width < 600 ? 14 : 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🔹 Sección de Funcionalidades (Explicación breve de Imagro)
  Widget _buildFeaturesSection(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      child: LayoutBuilder(
        builder: (context, constraints) {
          bool isSmallScreen =
              constraints.maxWidth < 800; // Detecta si es pantalla pequeña

          return Wrap(
            spacing: 20,
            runSpacing: 20,
            alignment: WrapAlignment.center,
            children: [
              _featureCard(
                  Icons.image,
                  "Sube tus Imágenes",
                  "Contribuye con fotos de cultivos para entrenar modelos de IA.",
                  isSmallScreen),
              _featureCard(
                  Icons.map,
                  "Explora el Mapa",
                  "Consulta imágenes geolocalizadas y sus datos.",
                  isSmallScreen),
              _featureCard(
                  Icons.analytics,
                  "Genera Modelos",
                  "Descarga datasets o entrena modelos de IA con las imágenes.",
                  isSmallScreen),
            ],
          );
        },
      ),
    );
  }

  Widget _featureCard(
      IconData icon, String title, String description, bool isSmallScreen) {
    return Container(
      width:
          isSmallScreen ? double.infinity : 300, // Ocupa todo el ancho en móvil
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(blurRadius: 4, color: Colors.black26)],
      ),
      child: Column(
        children: [
          Icon(icon, size: 50, color: Colors.green.shade800),
          SizedBox(height: 10),
          Text(title,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text(description,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade700)),
        ],
      ),
    );
  }

  /// 🔹 Sección de Llamado a la Acción (Botones para Contribuir o Iniciar Sesión)
  Widget _buildCallToAction(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return Padding(
      padding: EdgeInsets.all(40),
      child: Column(
        children: [
          Text(
            "Únete a Imagro y contribuye hoy mismo",
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: width < 600 ? 20 : 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: width < 600 ? 20 : 50),
            child: Text(
              "Sube imágenes, explora el mapa y entrena modelos de IA con tus contribuciones.",
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.grey.shade700, fontSize: width < 600 ? 14 : 16),
            ),
          ),
          SizedBox(height: 20),
          Wrap(
            spacing: 20,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/contribute'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade800,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                child: Text("Comenzar a Contribuir",
                    style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
              OutlinedButton(
                onPressed: () => Navigator.pushNamed(context, '/login'),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                child: Text("Iniciar Sesión",
                    style:
                        TextStyle(fontSize: 16, color: Colors.green.shade800)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
