import 'package:flutter/material.dart';

class FunctionalitiesWidget extends StatelessWidget {
  const FunctionalitiesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 13),
            child: Container(
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Funcionalidades',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const SizedBox(height: 25),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                _buildModuleCard(
                  image: 'assets/icons/contribuir.png',
                  title: 'Comenzar a contribuir',
                  onTap: () {
                    Navigator.pushNamed(context, '/configuracion-contribucion');
                  },
                ),
                const SizedBox(height: 30),
                _buildModuleCard(
                  image: 'assets/icons/solicitudes.png',
                  title: 'Solicitudes enviadas',
                  onTap: () {
                    Navigator.pushNamed(context, '/historial_solicitud');
                  },
                ),
              ],
            ),
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
        height: 120,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,
              blurRadius: 6,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Image.asset(
                    image,
                    width: 40,
                    height: 40,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 50,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: const Center(
                child: Icon(
                  Icons.arrow_forward,
                  color: Colors.black87,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
