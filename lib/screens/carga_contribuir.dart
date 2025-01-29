import 'package:flutter/material.dart';

class CargaContribuirScreen extends StatefulWidget {
  final Map<String, List<String>> estructuraEtiquetas;

  CargaContribuirScreen(
      {required this.estructuraEtiquetas}); // Constructor que recibe estructuraEtiquetas

  @override
  _CargaContribuirScreenState createState() => _CargaContribuirScreenState();
}

class _CargaContribuirScreenState extends State<CargaContribuirScreen> {
  Map<String, List<String>> _imagenesPorEtiqueta = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Contribuir'),
        backgroundColor: Color(0xFF0BA37F),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Adjunta tus imágenes a enviar',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Expanded(
              child: ListView(
                children:
                    widget.estructuraEtiquetas.entries.map((etiquetaEntry) {
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: EdgeInsets.symmetric(vertical: 8),
                    elevation: 3,
                    child: ExpansionTile(
                      title: Text(
                        etiquetaEntry.key,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      subtitle: Text(
                        '${_imagenesPorEtiqueta[etiquetaEntry.key]?.length ?? 0}/100',
                        style: TextStyle(color: Colors.grey),
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.camera_alt,
                                        color: Colors.green),
                                    onPressed: () {
                                      _agregarImagen(etiquetaEntry.key,
                                          'Imagen de cámara');
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.image, color: Colors.blue),
                                    onPressed: () {
                                      _agregarImagen(etiquetaEntry.key,
                                          'Imagen de galería');
                                    },
                                  ),
                                  ...?_imagenesPorEtiqueta[etiquetaEntry.key]
                                      ?.map(
                                    (img) => Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        color: Colors.grey[300],
                                      ),
                                      child: Center(
                                        child: Text(
                                          img,
                                          style: TextStyle(fontSize: 12),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Cancelar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Aquí se puede manejar la lógica para enviar imágenes
                  },
                  child: Text('Enviar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF0BA37F),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  void _agregarImagen(String etiqueta, String imagen) {
    setState(() {
      _imagenesPorEtiqueta.putIfAbsent(etiqueta, () => []);
      if (_imagenesPorEtiqueta[etiqueta]!.length < 100) {
        _imagenesPorEtiqueta[etiqueta]!.add(imagen);
      }
    });
  }
}
