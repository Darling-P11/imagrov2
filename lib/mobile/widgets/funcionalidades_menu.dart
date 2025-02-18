import 'package:flutter/material.dart';

class FunctionalitiesWidget extends StatelessWidget {
  const FunctionalitiesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.count(
        shrinkWrap: true,
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        physics: NeverScrollableScrollPhysics(),
        children: [
          _buildModuleCard(
            image: 'assets/icons/contribuir.png',
            title: 'Comenzar a contribuir',
            onTap: () {
              Navigator.pushNamed(context, '/configuracion-contribucion');
            },
          ),
          _buildModuleCard(
            image: 'assets/icons/fotografias.png',
            title: 'Mis Fotografías',
            onTap: () {},
          ),
          _buildModuleCard(
            image: 'assets/icons/solicitudes.png',
            title: 'Solicitudes enviadas',
            onTap: () {
              Navigator.pushNamed(context, '/historial_solicitud');
            },
          ),
          _buildModuleCard(
            image: 'assets/icons/estadisticas.png',
            title: 'Mis Estadísticas',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildModuleCard({
    required String image,
    required String title,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200,
              blurRadius: 6,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Stack(
          children: [
            // Flecha en la parte superior derecha
            Positioned(
              top: 8,
              right: 8,
              child: Icon(
                Icons.arrow_forward,
                color: Colors.grey,
                size: 20,
              ),
            ),
            // Icono más cercano al título
            Positioned(
              top: 35,
              left: 12,
              child: Image.asset(
                image,
                width: 40,
                height: 40,
                fit: BoxFit.contain,
              ),
            ),
            // Título alineado a la izquierda
            Positioned(
              bottom: 15,
              left: 12,
              right: 12,
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                softWrap: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
