import 'package:flutter/material.dart';

class MenuScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Encabezado
            Container(
              padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 10, bottom: 20),
              decoration: BoxDecoration(
                color: Color(0xFF0BA37F),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(15),
                  bottomRight: Radius.circular(15),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Buenos Días',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              'Jueves, 24 Enero 2025',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Stack(
                              children: [
                                IconButton(
                                  icon: Icon(Icons.notifications,
                                      color: Colors.white),
                                  onPressed: () {},
                                ),
                                Positioned(
                                  right: 8,
                                  top: 8,
                                  child: Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            CircleAvatar(
                              radius: 18,
                              backgroundColor: Colors.white,
                              child: ClipOval(
                                child: Image.asset(
                                  'assets/icons/perfil.png', // Imagen de ejemplo
                                  fit: BoxFit.cover,
                                  width: 36,
                                  height: 36,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  // Tarjeta de estadísticas
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 16),
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                    decoration: BoxDecoration(
                      color: Color(0xFF038E6F),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Estadísticas',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            OutlinedButton(
                              onPressed: () {},
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: Colors.white),
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              child: Text(
                                'Website',
                                style: TextStyle(
                                  color: Color(0xFF038E6F),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Divider(color: Colors.white),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatCard(
                              image: 'assets/icons/usuarios.png',
                              title: 'Usuarios',
                              count: '10',
                              backgroundColor: Color(0xFFA7D590),
                            ),
                            _buildStatCard(
                              image: 'assets/icons/datasets.png',
                              title: 'Datasets',
                              count: '3',
                              backgroundColor: Color(0xFF62C8B6),
                            ),
                            _buildStatCard(
                              image: 'assets/icons/contribuciones.png',
                              title: 'Aportacione',
                              count: '3',
                              backgroundColor: Color(0xFF8CE6A6),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 15), // Espacio entre el encabezado y el cuerpo
            // Título de funcionalidades con fondo gris
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16),
              padding: EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(15),
              ),
              child: Center(
                child: Text(
                  'Funcionalidades',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: const Color.fromARGB(255, 73, 73, 73),
                  ),
                ),
              ),
            ),
            SizedBox(height: 1),
            // Cuerpo - Funcionalidades
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.count(
                shrinkWrap: true,
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildModuleCard(
                    image: 'assets/icons/contribuir.png',
                    title: 'Comenzar a contribuir',
                    onTap: () {},
                  ),
                  _buildModuleCard(
                    image: 'assets/icons/fotografias.png',
                    title: 'Mis Fotografías',
                    onTap: () {},
                  ),
                  _buildModuleCard(
                    image: 'assets/icons/solicitudes.png',
                    title: 'Solicitudes enviadas',
                    onTap: () {},
                  ),
                  _buildModuleCard(
                    image: 'assets/icons/estadisticas.png',
                    title: 'Mis Estadísticas',
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Acción para el botón flotante
        },
        backgroundColor: Color(0xFF0BA37F),
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String image,
    required String title,
    required String count,
    required Color backgroundColor,
  }) {
    return Container(
      width: 100,
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                image,
                width: 24,
                height: 24,
              ),
              SizedBox(width: 8),
              Text(
                count,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
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
        width: 160,
        height: 140,
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
              top: 35, // Posición más cerca del título
              left: 12,
              child: Image.asset(
                image,
                width: 40, // Tamaño ajustado
                height: 40,
                fit: BoxFit.contain,
              ),
            ),
            // Título alineado a la izquierda
            Positioned(
              bottom: 15, // Cercano al borde inferior
              left: 12,
              right: 12, // Aseguramos que no se salga del cuadro
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                maxLines: 2, // Máximo de dos líneas
                overflow: TextOverflow
                    .ellipsis, // Añade "..." si el texto es muy largo
                softWrap: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
