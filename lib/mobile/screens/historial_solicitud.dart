import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class HistorialSolicitudScreen extends StatefulWidget {
  @override
  _HistorialSolicitudScreenState createState() =>
      _HistorialSolicitudScreenState();
}

class _HistorialSolicitudScreenState extends State<HistorialSolicitudScreen> {
  String filtroEstado = 'General';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildEncabezado(),
          _buildFiltros(),
          Expanded(child: _buildListaSolicitudes()),
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
          'Historial de tus solicitudes',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildFiltros() {
    return Padding(
      padding: EdgeInsets.all(12),
      child: Column(
        children: [
          Text(
            "Filtrar búsqueda:",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 8),
          Container(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                _buildFiltroBoton("Enviado", Colors.blue),
                _buildFiltroBoton("Aceptado", Colors.green),
                _buildFiltroBoton("Rechazado", Colors.red),
                _buildFiltroBoton(
                    "Cancelado", Colors.orange), // Naranja para cancelado
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltroBoton(String estado, Color color) {
    return GestureDetector(
      onTap: () {
        setState(() {
          filtroEstado = estado;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 14),
        decoration: BoxDecoration(
          color: filtroEstado == estado ? color : Colors.grey[400],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          estado,
          style: TextStyle(
            fontSize: 14,
            color: filtroEstado == estado ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildListaSolicitudes() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Center(child: Text("Usuario no autenticado"));
    }
    String userId = user.uid;
    String collectionName =
        filtroEstado.toLowerCase(); // Convertimos a minúsculas
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("historialContribuciones")
          .doc(userId)
          .collection(
              collectionName) // ← Ahora seleccionamos la subcolección correcta
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text("SELECCIONA UN ESTADO DE LA BÚSQUEDA"));
        }

        List<DocumentSnapshot> solicitudes = snapshot.data!.docs;

        return FutureBuilder<List<Map<String, dynamic>>>(
          future: _obtenerSolicitudesConEstado(userId, solicitudes),
          builder: (context, solicitudesSnapshot) {
            if (!solicitudesSnapshot.hasData ||
                solicitudesSnapshot.data!.isEmpty) {
              return Center(child: Text("No hay solicitudes registradas"));
            }

            List<Map<String, dynamic>> solicitudesConEstado =
                solicitudesSnapshot.data!;

            if (filtroEstado != "General") {
              solicitudesConEstado = solicitudesConEstado
                  .where((solicitud) => solicitud["estado"] == filtroEstado)
                  .toList();
            }

            return ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 10),
              itemCount: solicitudesConEstado.length,
              itemBuilder: (context, index) {
                var solicitud = solicitudesConEstado[index];
                return _buildTarjetaSolicitud(solicitud);
              },
            );
          },
        );
      },
    );
  }

  Future<List<Map<String, dynamic>>> _obtenerSolicitudesConEstado(
      String userId, List<DocumentSnapshot> solicitudes) async {
    List<Map<String, dynamic>> solicitudesConEstado = [];

    for (var solicitudDoc in solicitudes) {
      var solicitudData = solicitudDoc.data() as Map<String, dynamic>;
      String configId = solicitudData["configuracion_id"];

      DocumentSnapshot configDoc = await FirebaseFirestore.instance
          .collection("historialConfiguracion")
          .doc(userId)
          .collection("enviado")
          .doc(configId)
          .get();

      String estado = "Enviado";
      if (configDoc.exists) {
        var configData = configDoc.data() as Map<String, dynamic>;
        estado = configData["estado"] ?? "Enviado";
      }

      solicitudData["estado"] = filtroEstado;
      solicitudesConEstado.add(solicitudData);
    }

    return solicitudesConEstado;
  }

  Widget _buildTarjetaSolicitud(Map<String, dynamic> solicitud) {
    Color estadoColor;
    switch (solicitud["estado"]) {
      case "Aceptado":
        estadoColor = Colors.green;
        break;
      case "Rechazado":
        estadoColor = Colors.red;
        break;
      case "Cancelado":
        estadoColor = Colors.orange;
        break;
      case "Enviado":
      default:
        estadoColor = Colors.blue;
    }

    String fechaFormateada = _formatearFecha(solicitud['fecha_contribucion']);

    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: ListTile(
        onTap: () {
          _mostrarDetallesSolicitud(solicitud);
        },
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: estadoColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: EdgeInsets.all(8),
            child: Image.asset(
              'assets/images/logo.png',
              fit: BoxFit.contain,
            ),
          ),
        ),
        title: Text(
          "Fecha de envío: $fechaFormateada",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Total de imágenes: ${solicitud['cantidad_imagenes']}"),
            Text("Estado: ${solicitud['estado']}"),
            Text("Ubicación: ${solicitud['ubicacion'] ?? 'No registrada'}"),
          ],
        ),
        trailing: Icon(Icons.search, color: Colors.grey),
      ),
    );
  }

  String _formatearFecha(String fechaContribucion) {
    try {
      DateTime fecha = DateTime.parse(fechaContribucion);
      return DateFormat('dd/MM/yyyy').format(fecha);
    } catch (e) {
      return "Fecha no disponible";
    }
  }

  void _mostrarDetallesSolicitud(Map<String, dynamic> solicitud) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Detalles de la solicitud"),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                Text(
                    "📅 Fecha de envío: ${_formatearFecha(solicitud['fecha_contribucion'])}"),
                SizedBox(height: 5),
                Text("📸 Total de imágenes: ${solicitud['cantidad_imagenes']}"),
                SizedBox(height: 5),
                Text("📝 Estado: ${solicitud['estado'] ?? 'Enviado'}"),
                SizedBox(height: 5),
                Text(
                    "📍 Ubicación: ${solicitud['ubicacion'] ?? 'No registrada'}"),
                SizedBox(height: 5),
                Text(
                    "🔗 ID de Configuración: ${solicitud['configuracion_id']}"),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text("Cerrar"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
