import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:imagro/screens/splash_screen.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';

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
    _cargarConfiguracion().then((_) {
      _cargarImagenesDesdeAlmacenamiento(
          secciones); // 🔹 Cargar imágenes almacenadas en caché después de la configuración
    });
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
            seccionesTemp.add({
              'cultivo': cultivo,
              'tipo': tipo,
              'estado': estado,
              'enfermedades': enfermedades,
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

  Future<void> _seleccionarImagenes(String tipo, int index) async {
    final dir = await getApplicationDocumentsDirectory();
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (secciones[index]['imagenes'].length >= 100) {
      _mostrarDialogoLimiteImagenes(); //AUN PRO PROBAAAAAR
      Fluttertoast.showToast(
        msg: "Has alcanzado el límite de 100 imágenes.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return;
    }

    List<File> nuevasImagenes = [];

    if (tipo == "gallery") {
      final List<XFile>? images = await _picker.pickMultiImage();
      if (images != null) {
        for (var img in images) {
          File savedImage =
              await File(img.path).copy('${dir.path}/${img.name}');
          nuevasImagenes.add(savedImage);
        }
      }
    } else if (tipo == "camera") {
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);
      if (image != null) {
        File savedImage =
            await File(image.path).copy('${dir.path}/${image.name}');
        nuevasImagenes.add(savedImage);
      }
    }

    if (nuevasImagenes.isNotEmpty) {
      // 🔹 Evita agregar imágenes duplicadas
      List<File> imagenesActuales = List.from(secciones[index]['imagenes']);
      for (var img in nuevasImagenes) {
        if (!imagenesActuales.any((file) => file.path == img.path)) {
          imagenesActuales.add(img);
        }
      }

      secciones[index]['imagenes'] = imagenesActuales;

      // 🔹 Guardar en SharedPreferences
      String key =
          "imagenes_${secciones[index]['cultivo']}_${secciones[index]['tipo']}_${secciones[index]['estado']}_${secciones[index]['enfermedad'] ?? 'ninguna'}";
      List<String> rutas = imagenesActuales.map((file) => file.path).toList();
      await prefs.setStringList(key, rutas);

      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (cargando) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // 🔹 Agrupar secciones por cultivo
    Map<String, List<Map<String, dynamic>>> seccionesPorCultivo = {};
    for (var seccion in secciones) {
      String cultivo = seccion['cultivo'];
      if (!seccionesPorCultivo.containsKey(cultivo)) {
        seccionesPorCultivo[cultivo] = [];
      }
      seccionesPorCultivo[cultivo]!.add(seccion);
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
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 20),
              children: seccionesPorCultivo.entries.expand((entry) {
                String cultivo = entry.key;
                List<Map<String, dynamic>> seccionesCultivo = entry.value;

                return [
                  _buildTituloCultivo(
                      cultivo), // 🔹 Agrega el título del cultivo
                  ...seccionesCultivo.asMap().entries.map((e) {
                    int index = secciones.indexOf(e.value);
                    return _buildSeccion(e.value, index);
                  }).toList(),
                ];
              }).toList(),
            ),
          ),
        ],
      ),
      bottomNavigationBar: buildPiePantalla(), // 🔹 Pie de pantalla separado
    );
  }

// 🔹 Widget para mostrar el título del cultivo
  Widget _buildTituloCultivo(String cultivo) {
    return Padding(
      padding: EdgeInsets.only(top: 15, bottom: 5),
      child: Container(
        alignment: Alignment.center,
        margin: EdgeInsets.symmetric(vertical: 5),
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 15),
        decoration: BoxDecoration(
          color: Color(0xFF0BA37F), // Color verde
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.eco, color: Colors.white, size: 20),
            SizedBox(width: 5),
            Text(
              cultivo,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
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
                color: const Color.fromARGB(255, 223, 223, 223),
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
                        color: const Color.fromARGB(255, 0, 0, 0),
                      ),
                      SizedBox(width: 5),
                      Text(
                        titulo,
                        style: TextStyle(
                            fontSize: 14,
                            color: const Color.fromARGB(255, 0, 0, 0)),
                      ),
                    ],
                  ),
                  Text(
                    "${datos['imagenes'].length}/100",
                    style: TextStyle(
                        fontSize: 14,
                        color: const Color.fromARGB(255, 145, 144, 144)),
                  ),
                ],
              ),
            ),
          ),
          ClipRect(
            // 🟢 Evita mostrar el contenido antes de que la animación termine
            child: AnimatedCrossFade(
              firstChild:
                  SizedBox.shrink(), // Ocultar contenido cuando está cerrado
              secondChild: Column(
                children: [
                  SizedBox(height: 10),
                  _buildBotonesSubida(index),
                  SizedBox(height: 10),
                  _buildVistaImagenes(datos, index),
                ],
              ),
              crossFadeState: secciones[index]['expandido']
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: Duration(milliseconds: 300), // Duración de la animación
              sizeCurve: Curves.easeInOut, // Suaviza la animación
            ),
          ),
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
      onTap: () => _seleccionarImagenes(tipo, index),
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

  Widget _buildVistaImagenes(Map<String, dynamic> datos, int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 10),
        if (datos['imagenes'].isNotEmpty)
          GridView.builder(
            shrinkWrap: true,
            physics:
                NeverScrollableScrollPhysics(), // Deshabilitar el scroll interno
            itemCount: datos['imagenes'].length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4, // 📌 Mostrar 4 imágenes por fila
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemBuilder: (context, i) {
              return GestureDetector(
                onTap: () => _mostrarImagenEnGrande(
                    datos['imagenes'][i]), // 📌 Ver en grande
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: double
                          .infinity, // Para que ocupe toda la celda de la cuadrícula
                      height: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(color: Colors.black12, blurRadius: 4)
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child:
                            Image.file(datos['imagenes'][i], fit: BoxFit.cover),
                      ),
                    ),
                    // 🔴 Botón de eliminar imagen con actualización en caché
                    Positioned(
                      top: -6,
                      right: -6,
                      child: GestureDetector(
                        onTap: () async {
                          setState(() {
                            datos['imagenes'].removeAt(i);
                          });

                          // 🔹 Actualizar el caché después de eliminar
                          await _actualizarImagenesEnCache(datos, index);
                        },
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child:
                              Icon(Icons.close, color: Colors.white, size: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          )
        else
          Text(
            "No hay imágenes agregadas",
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
      ],
    );
  }

  void _mostrarImagenEnGrande(File imagen) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Stack(
            children: [
              // ✅ Imagen en pantalla completa
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.file(imagen, fit: BoxFit.contain),
              ),
              // 🔴 Botón de cerrar
              Positioned(
                top: 10,
                right: 10,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    padding: EdgeInsets.all(6),
                    child: Icon(Icons.close, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // 🔹 Construcción del pie de pantalla
  Widget buildPiePantalla() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 🔴 Botón Cancelar
          ElevatedButton(
            onPressed: () => _cancelarProceso(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: Text("Cancelar", style: TextStyle(color: Colors.white)),
          ),

          // 🔵 Indicador de progreso circular
          _buildIndicadorProgreso(),

          // ✅ Botón Enviar
          ElevatedButton(
            onPressed: () => _enviarContribucion(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF0BA37F),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: Text("Enviar  ", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

// 🔹 Indicador de progreso circular con porcentaje
  Widget _buildIndicadorProgreso() {
    double progreso = _calcularProgreso();

    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 50,
          height: 50,
          child: CircularProgressIndicator(
            value: progreso / 100,
            strokeWidth: 6,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0BA37F)),
          ),
        ),
        Text("${progreso.toInt()}%",
            style: TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

// 🔹 Cálculo del progreso total basado en imágenes cargadas
  double _calcularProgreso() {
    int totalImagenes = 0;
    int totalPermitido = secciones.length * 100; // 100 imágenes por sección

    for (var seccion in secciones) {
      totalImagenes += (seccion['imagenes'] as List).length;
    }

    return (totalImagenes / totalPermitido) * 100; // Devuelve el porcentaje
  }

  Future<void> _guardarImagenEnCache(File imagen, int index) async {
    final dir = await getApplicationDocumentsDirectory();
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Copia la imagen en la carpeta de documentos de la app
    File nuevaImagen =
        await imagen.copy('${dir.path}/${imagen.path.split('/').last}');

    // Agregar la imagen a la sección correspondiente
    setState(() {
      secciones[index]['imagenes'].add(nuevaImagen);
    });

    // Guardar en SharedPreferences
    String key =
        "imagenes_${secciones[index]['cultivo']}_${secciones[index]['tipo']}_${secciones[index]['estado']}_${secciones[index]['enfermedad'] ?? 'ninguna'}";
    List<String> rutas =
        secciones[index]['imagenes'].map((file) => file.path).toList();
    await prefs.setStringList(key, rutas);
  }

  Future<void> _cargarImagenesDesdeAlmacenamiento(
      List<Map<String, dynamic>> seccionesTemp) async {
    final dir = await getApplicationDocumentsDirectory();
    SharedPreferences prefs = await SharedPreferences.getInstance();

    int imagenesRecuperadas = 0; // 🔹 Contador de imágenes recuperadas

    for (var seccion in seccionesTemp) {
      String key =
          "imagenes_${seccion['cultivo']}_${seccion['tipo']}_${seccion['estado']}_${seccion['enfermedad'] ?? 'ninguna'}";
      List<String>? rutasGuardadas = prefs.getStringList(key);

      if (rutasGuardadas != null && rutasGuardadas.isNotEmpty) {
        seccion['imagenes'] = rutasGuardadas.map((path) => File(path)).toList();
        imagenesRecuperadas +=
            rutasGuardadas.length; // 🔹 Contar imágenes restauradas
      }
    }

    setState(() {
      secciones = seccionesTemp;
      cargando = false;
    });

    // 🔹 Mostrar mensaje si hay imágenes recuperadas
    if (imagenesRecuperadas > 0) {
      Fluttertoast.showToast(
        msg: "Se recuperaron $imagenesRecuperadas imágenes desde caché",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.blue,
        textColor: Colors.white,
      );
    }
  }

  void _mostrarDialogoLimiteImagenes() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Límite alcanzado"),
        content: Text("No puedes subir más de 100 imágenes por sección."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Entendido"),
          ),
        ],
      ),
    );
  }

  Future<void> _actualizarImagenesEnCache(
      Map<String, dynamic> datos, int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String key =
        "imagenes_${datos['cultivo']}_${datos['tipo']}_${datos['estado']}_${datos['enfermedad'] ?? 'ninguna'}";

    // 🔹 Obtener la lista actualizada de imágenes sin la eliminada
    List<String> rutas = datos['imagenes']
        .map<String>((file) => file is File ? file.path : file.toString())
        .toList();

    // 🔹 Si la lista está vacía, eliminamos la clave del caché
    if (rutas.isEmpty) {
      await prefs.remove(key);
    } else {
      await prefs.setStringList(key, rutas);
    }
  }

  Future<void> _cancelarProceso() async {
    bool confirmar = await _mostrarDialogoConfirmacion();
    if (!confirmar) return;

    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    String userId = user.uid;

    try {
      // 🔹 Actualizar estado en Firestore
      await FirebaseFirestore.instance
          .collection('configuracionesUsuarios')
          .doc(userId)
          .update({'estado': 'cancelado'});

      // 🔹 Eliminar imágenes del caché
      await _limpiarImagenesEnCache();

      // 🔹 Mostrar Toast de confirmación
      Fluttertoast.showToast(
        msg:
            "Contribución cancelada. Se ha limpiado la caché y guardado en historial.",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );

      // 🔹 Redirigir a SplashScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SplashScreen()),
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Error al cancelar: ${e.toString()}",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  Future<void> _limpiarImagenesEnCache() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final dir = await getApplicationDocumentsDirectory();

    // 🔹 Obtener todas las claves de imágenes
    Set<String> keys =
        prefs.getKeys().where((key) => key.startsWith("imagenes_")).toSet();

    for (String key in keys) {
      List<String>? rutas = prefs.getStringList(key);
      if (rutas != null) {
        for (String path in rutas) {
          File archivo = File(path);
          if (await archivo.exists()) {
            await archivo.delete(); // Eliminar archivo físico
          }
        }
      }
      await prefs.remove(key); // Eliminar la clave del cache
    }
  }

  Future<bool> _mostrarDialogoConfirmacion() async {
    return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Confirmar cancelación"),
              content: Text(
                  "¿Seguro que deseas cancelar? \nSe eliminarán las imágenes previamente guardadas y se guardará tu historial de cancelación."),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false), // No cancelar
                  child: Text("No, continuar"),
                ),
                ElevatedButton(
                  onPressed: () =>
                      Navigator.pop(context, true), // Confirmar cancelación
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  child: Text(
                    "Sí, cancelar",
                    style: TextStyle(
                        color: Colors.white), // 🔹 Color del texto en blanco
                  ),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  //CARGA DE IMAGENES
  // ✅ Acción al presionar Enviar
  Future<void> _enviarContribucion() async {
    if (secciones.isEmpty) {
      Fluttertoast.showToast(
          msg: "No hay imágenes para enviar.", backgroundColor: Colors.red);
      return;
    }

    // 🔹 Confirmación antes de enviar
    bool confirmar = await _mostrarDialogoConfirmacionEnvio();
    if (!confirmar) return;

    Fluttertoast.showToast(
        msg: "Iniciando subida de contribución...",
        backgroundColor: Colors.green);

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Fluttertoast.showToast(
          msg: "Error: Usuario no autenticado.", backgroundColor: Colors.red);
      return;
    }

    String userId = user.uid;
    DateTime now = DateTime.now();
    String anio = now.year.toString();
    String mes = now.month.toString().padLeft(2, '0');
    String contribucionId = FirebaseFirestore.instance
        .collection('historialContribuciones')
        .doc()
        .id;

    List<Map<String, dynamic>> imagenesSubidas = [];
    int totalImagenes = secciones.fold<int>(
        0, (sum, seccion) => sum + (seccion["imagenes"] as List).length);

    int imagenesSubidasCount = 0;

    // 🔹 Mostrar diálogo de carga
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text("Subiendo imágenes"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              LinearProgressIndicator(value: 0.0),
              SizedBox(height: 10),
              Text("0 / $totalImagenes imágenes subidas"),
            ],
          ),
        );
      },
    );

    for (var seccion in secciones) {
      String cultivo = seccion['cultivo'];
      String tipo = seccion['tipo'];
      String estado = seccion['estado'];
      String enfermedad = seccion['enfermedad'] ?? 'ninguna';

      for (var imagen in List.from(seccion['imagenes'])) {
        File file = File(imagen.path);
        String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
        String rutaStorage =
            "contribuciones/$anio/$mes/$cultivo/$tipo/$estado/$enfermedad/$timestamp.jpg";

        try {
          // 🔹 Subir imagen a Firebase Storage
          UploadTask uploadTask =
              FirebaseStorage.instance.ref(rutaStorage).putFile(file);
          TaskSnapshot snapshot = await uploadTask;
          String imageUrl = await snapshot.ref.getDownloadURL();

          // 🔹 Obtener ubicación (si está disponible)
          Position? posicion = await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.high);

          imagenesSubidas.add({
            "url": imageUrl,
            "latitud": posicion.latitude,
            "longitud": posicion.longitude,
            "fecha_subida": now.toIso8601String(),
          });

          // 🔹 Actualizar progreso
          imagenesSubidasCount++;
          Navigator.of(context).pop();
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) {
              return AlertDialog(
                title: Text("Subiendo imágenes"),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    LinearProgressIndicator(
                        value: imagenesSubidasCount / totalImagenes),
                    SizedBox(height: 10),
                    Text(
                        "$imagenesSubidasCount / $totalImagenes imágenes subidas"),
                  ],
                ),
              );
            },
          );
        } catch (e) {
          Fluttertoast.showToast(
              msg: "Error al subir imagen: ${e.toString()}",
              backgroundColor: Colors.red);
          return;
        }
      }
    }

    // 🔹 Guardar datos en Firestore
    await FirebaseFirestore.instance
        .collection("historialContribuciones")
        .doc("$anio/$mes/$contribucionId")
        .set({
      "usuario": userId,
      "fecha_contribucion": now.toIso8601String(),
      "imagenes": imagenesSubidas,
      "cantidad_imagenes": imagenesSubidas.length,
    });

    // 🔹 Limpiar caché de imágenes después de la subida
    for (var seccion in secciones) {
      seccion['imagenes'].clear();
    }
    await _limpiarImagenesEnCache();

    // 🔹 Cerrar diálogo de carga
    Navigator.of(context).pop();

    // 🔹 Reproducir sonido de notificación
    FlutterRingtonePlayer().playNotification();

    // 🔹 Mostrar mensaje de agradecimiento
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text("Gracias por tu contribución"),
          content: Text("Las imágenes han sido enviadas exitosamente."),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, "/menu");
              },
              child: Text("Aceptar"),
            ),
          ],
        );
      },
    );
  }

// 🔹 Mostrar diálogo de confirmación antes de enviar
  Future<bool> _mostrarDialogoConfirmacionEnvio() async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Confirmar envío"),
            content:
                Text("¿Estás seguro de que deseas enviar la contribución?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text("Cancelar"),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: Text("Enviar", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ) ??
        false;
  }
}
