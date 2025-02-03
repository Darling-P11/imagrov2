import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

class CargaContribuirScreen extends StatefulWidget {
  @override
  _CargaContribuirScreenState createState() => _CargaContribuirScreenState();
}

class _CargaContribuirScreenState extends State<CargaContribuirScreen> {
  bool enModoCuadricula = false;
  bool cargando = true;
  List<Map<String, dynamic>> secciones = [];
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _cargarConfiguracion();
  }

  Future<void> _cargarConfiguracion() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    String userId = user.uid;
    DocumentSnapshot userConfig = await FirebaseFirestore.instance
        .collection('configuracionesUsuarios')
        .doc(userId)
        .get();

    if (userConfig.exists) {
      Map<String, dynamic> configData =
          userConfig.data() as Map<String, dynamic>;

      List<Map<String, dynamic>> seccionesTemp = [];

      // 🔹 Iterar sobre cada cultivo y sus tipos
      configData['configuracionCompleta'].forEach((cultivo, tipos) {
        tipos.forEach((tipo, detalles) {
          String estado = detalles['estado'];
          List<dynamic> enfermedades = detalles['enfermedades'] ?? [];

          if (estado == "Sano") {
            seccionesTemp.add({
              'cultivo': cultivo,
              'tipo': tipo,
              'estado': estado,
              'enfermedad': null,
              'imagenes': [],
              'expandido': false
            });
          } else if (estado == "Enfermo") {
            enfermedades.forEach((enfermedad) {
              seccionesTemp.add({
                'cultivo': cultivo,
                'tipo': tipo,
                'estado': estado,
                'enfermedad': enfermedad,
                'imagenes': [],
                'expandido': false
              });
            });
          } else if (estado == "Mixto") {
            // 🔹 Una única sección donde se integran sanos y enfermos en la misma vista
            seccionesTemp.add({
              'cultivo': cultivo,
              'tipo': tipo,
              'estado': estado,
              'enfermedades': enfermedades, // Guardamos todas las enfermedades
              'imagenes': [],
              'expandido': false
            });
          }
        });
      });

      setState(() {
        secciones = seccionesTemp;
        cargando = false;
      });
    }
  }

  Future<void> _seleccionarImagen(String tipo, int index) async {
    final XFile? image = await _picker.pickImage(
        source: tipo == "camera" ? ImageSource.camera : ImageSource.gallery);

    if (image != null) {
      setState(() {
        secciones[index]['imagenes'].add(image.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (cargando) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: Column(
        children: [
          _buildEncabezado(),
          SizedBox(height: 20),
          Text(
            "Adjunta tus imágenes a enviar",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 20),
              itemCount: secciones.length,
              itemBuilder: (context, index) {
                return _buildSeccion(secciones[index], index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEncabezado() {
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
      child: Center(
        child: Text(
          'Sube tu contribución',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildSeccion(Map<String, dynamic> datos, int index) {
    String titulo =
        "${datos['cultivo']} > ${datos['tipo']} > ${datos['estado']}";
    if (datos.containsKey('enfermedad') && datos['enfermedad'] != null) {
      titulo += " > ${datos['enfermedad']}";
    }

    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                secciones[index]['expandido'] = !secciones[index]['expandido'];
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
                        secciones[index]['expandido']
                            ? Icons.keyboard_arrow_down
                            : Icons.keyboard_arrow_right,
                        color: Colors.grey[700],
                      ),
                      SizedBox(width: 5),
                      Text(
                        titulo,
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                  Text(
                    "${datos['imagenes'].length}/100",
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
          ),
          if (secciones[index]['expandido']) ...[
            SizedBox(height: 10),
            _buildBotonesSubida(index),
            SizedBox(height: 10),
            _buildVistaImagenes(datos),
          ],
        ],
      ),
    );
  }

  Widget _buildBotonesSubida(int index) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildBotonSubida(Icons.camera_alt, "camera", index),
        SizedBox(width: 15),
        _buildBotonSubida(Icons.image, "gallery", index),
      ],
    );
  }

  Widget _buildBotonSubida(IconData icon, String tipo, int index) {
    return GestureDetector(
      onTap: () => _seleccionarImagen(tipo, index),
      child: Container(
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
        ),
        child: Icon(icon, color: Color(0xFF0BA37F), size: 30),
      ),
    );
  }

  Widget _buildVistaImagenes(Map<String, dynamic> datos) {
    return Wrap(
      spacing: 10,
      children: datos['imagenes'].map<Widget>((imagen) {
        return Stack(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                image: DecorationImage(
                  image: AssetImage(imagen), // Muestra la imagen seleccionada
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}
