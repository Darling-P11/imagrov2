import 'package:flutter/material.dart';

class CargaContribuirScreen extends StatefulWidget {
  @override
  _CargaContribuirScreenState createState() => _CargaContribuirScreenState();
}

class _CargaContribuirScreenState extends State<CargaContribuirScreen> {
  bool opcionesVisibles = true;
  bool enModoCuadricula = false;
  double tamanoLista =
      70.0; // Tamaño fijo para vista de lista (scroll horizontal)
  double tamanoCuadricula = 90.0; // Tamaño fijo para vista de cuadrícula
  List<String> imagenes = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // ✅ Sección del encabezado
          Container(
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
            child: Center(
              child: Text(
                'Configura tu contribución',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          SizedBox(height: 20),

          // ✅ Título
          Text(
            "Adjunta tus imágenes a enviar",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),

          SizedBox(height: 10),

          // ✅ Botones de control de vista (sin zoom)
          _buildControlButtons(),

          SizedBox(height: 10),

          // ✅ Contenedor principal
          Container(
            margin: EdgeInsets.symmetric(horizontal: 20),
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                // ✅ Selector de categoría
                GestureDetector(
                  onTap: () {
                    setState(() {
                      opcionesVisibles = !opcionesVisibles;
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              opcionesVisibles
                                  ? Icons.keyboard_arrow_down
                                  : Icons.keyboard_arrow_up,
                              color: Colors.grey[700],
                            ),
                            SizedBox(width: 5),
                            Text(
                              "Cacao > Nacional > Natural",
                              style: TextStyle(
                                  fontSize: 14, color: Colors.grey[700]),
                            ),
                          ],
                        ),
                        Text(
                          "${imagenes.length}/100",
                          style:
                              TextStyle(fontSize: 14, color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 10),

                // ✅ Vista de imágenes (lista o cuadrícula)
                if (opcionesVisibles)
                  enModoCuadricula
                      ? _buildGridView()
                      : _buildHorizontalScroll(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ✅ Botones de control (sin zoom)
  Widget _buildControlButtons() {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: EdgeInsets.only(right: 15),
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildControlButton(
                enModoCuadricula ? Icons.view_list : Icons.grid_view, () {
              setState(() {
                enModoCuadricula = !enModoCuadricula;
              });
            }),
            _buildControlButton(Icons.pan_tool, () {
              setState(() {
                enModoCuadricula = false;
              });
            }),
          ],
        ),
      ),
    );
  }

  // ✅ Botón individual
  Widget _buildControlButton(IconData icon, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape: CircleBorder(),
          padding: EdgeInsets.all(6),
          backgroundColor: Color(0xFF0BA37F),
          elevation: 0,
        ),
        onPressed: onPressed,
        child: Icon(icon, color: Colors.white, size: 16),
      ),
    );
  }

  // ✅ Modo lista
  Widget _buildHorizontalScroll() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildImageOption(Icons.camera_alt, "camera", tamanoLista),
          SizedBox(width: 10),
          _buildImageOption(Icons.image, "gallery", tamanoLista),
          ...imagenes
              .map((img) => _buildImagePreview(img, tamanoLista))
              .toList(),
        ],
      ),
    );
  }

  // ✅ Modo cuadrícula con correcciones
  Widget _buildGridView() {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: imagenes.length + 2,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemBuilder: (context, index) {
        if (index == 0)
          return _buildImageOption(
              Icons.camera_alt, "camera", tamanoCuadricula);
        if (index == 1)
          return _buildImageOption(Icons.image, "gallery", tamanoCuadricula);
        return _buildImagePreview(imagenes[index - 2], tamanoCuadricula);
      },
    );
  }

  // ✅ Iconos dentro de la cuadrícula corregidos
  Widget _buildImageOption(IconData icon, String type, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Center(
        child: Icon(icon, color: Color(0xFF0BA37F), size: size * 0.5),
      ),
    );
  }

  // ✅ Vista previa de imágenes con botón de eliminar ajustado
  Widget _buildImagePreview(String label, double size) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: size,
          height: size,
          margin: EdgeInsets.symmetric(horizontal: 5),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
          ),
          child: Center(
            child: Text(label,
                style: TextStyle(fontSize: size * 0.15, color: Colors.grey)),
          ),
        ),
        Positioned(
          top: -6,
          right: -6,
          child: GestureDetector(
            onTap: () {
              setState(() {
                imagenes.remove(label);
              });
            },
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.close, color: Colors.white, size: 14),
            ),
          ),
        ),
      ],
    );
  }
}
