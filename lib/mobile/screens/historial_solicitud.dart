import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';

class HistorialSolicitudScreen extends StatefulWidget {
  @override
  _HistorialSolicitudScreenState createState() =>
      _HistorialSolicitudScreenState();
}

class _HistorialSolicitudScreenState extends State<HistorialSolicitudScreen> {
  String filtroEstado = 'General';

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Color(0xFF0BA37F),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildEncabezado(),
          _buildFiltros(),
          Expanded(
            child: AnimatedSwitcher(
              duration: Duration(milliseconds: 300),
              child: _buildListaSolicitudes(),
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
        left: 15,
        right: 15,
      ),
      decoration: BoxDecoration(
        color: Color(0xFF0BA37F),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back_ios_new, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          Expanded(
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
          ),
          SizedBox(width: 48), // Para equilibrar visualmente el botón
        ],
      ),
    );
  }

  Widget _buildFiltros() {
    final estados = [
      'General',
      'Enviado',
      'Aceptado',
      'Rechazado',
      'Cancelado'
    ];
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        children: [
          Text(
            "Filtrar búsqueda:",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: estados.map((estado) {
                return _buildFiltroBoton(estado, _getColorEstado(estado));
              }).toList(),
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

  Color _getColorEstado(String estado) {
    switch (estado) {
      case "Aceptado":
        return Colors.green;
      case "Rechazado":
        return Colors.red;
      case "Cancelado":
        return Colors.orange;
      case "Enviado":
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  Widget _buildListaSolicitudes() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return Center(child: Text("Usuario no autenticado"));
    String userId = user.uid;

    final estados = ['enviado', 'aceptado', 'rechazado', 'cancelado'];

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: filtroEstado == 'General'
          ? _obtenerTodasLasSolicitudes(userId, estados)
          : _obtenerSolicitudesPorEstado(userId, filtroEstado.toLowerCase()),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return Center(
              child: CircularProgressIndicator(color: Color(0xFF0BA37F)));

        if (!snapshot.hasData || snapshot.data!.isEmpty)
          return Center(child: Text("No hay solicitudes registradas"));

        final solicitudes = snapshot.data!;
        return ListView.builder(
          padding: EdgeInsets.symmetric(horizontal: 10),
          itemCount: solicitudes.length,
          itemBuilder: (context, index) =>
              _buildTarjetaSolicitud(solicitudes[index]),
        );
      },
    );
  }

  Future<List<Map<String, dynamic>>> _obtenerSolicitudesPorEstado(
      String userId, String estado) async {
    final docs = await FirebaseFirestore.instance
        .collection("historialContribuciones")
        .doc(userId)
        .collection(estado)
        .get();

    return _procesarSolicitudes(userId, docs.docs, estado);
  }

  Future<List<Map<String, dynamic>>> _obtenerTodasLasSolicitudes(
      String userId, List<String> estados) async {
    List<Map<String, dynamic>> todas = [];
    for (var estado in estados) {
      final docs = await FirebaseFirestore.instance
          .collection("historialContribuciones")
          .doc(userId)
          .collection(estado)
          .get();
      final procesadas = await _procesarSolicitudes(userId, docs.docs, estado);
      todas.addAll(procesadas);
    }
    return todas;
  }

  Future<List<Map<String, dynamic>>> _procesarSolicitudes(
      String userId, List<DocumentSnapshot> docs, String estado) async {
    List<Map<String, dynamic>> resultado = [];

    for (var doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      final configId = data["configuracion_id"];

      final config = await FirebaseFirestore.instance
          .collection("historialConfiguracion")
          .doc(userId)
          .collection("enviado")
          .doc(configId)
          .get();

      data["estado"] = config.exists
          ? (config.data()!["estado"] ?? estado.capitalize())
          : estado.capitalize();

      resultado.add(data);
    }
    return resultado;
  }

  Widget _buildTarjetaSolicitud(Map<String, dynamic> solicitud) {
    Color estadoColor = _getColorEstado(solicitud["estado"]);
    String fechaFormateada = _formatearFecha(solicitud['fecha_contribucion']);

    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        onTap: () => _mostrarDetallesSolicitud(solicitud),
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
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 1,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Total de imágenes: ${solicitud['cantidad_imagenes']}"),
            Text("Ubicación: ${solicitud['ubicacion'] ?? 'No registrada'}"),
            SizedBox(height: 4),
            Chip(
              label: Text(solicitud["estado"]),
              backgroundColor: estadoColor.withOpacity(0.1),
              labelStyle: TextStyle(color: estadoColor),
            ),
          ],
        ),
        trailing: Icon(Icons.chevron_right),
      ),
    );
  }

  String _formatearFecha(String fechaContribucion) {
    try {
      DateTime fecha = DateTime.parse(fechaContribucion);
      return DateFormat('dd/MM/yyyy').format(fecha);
    } catch (_) {
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
                Text("📸 Total de imágenes: ${solicitud['cantidad_imagenes']}"),
                Text("📝 Estado: ${solicitud['estado']}"),
                Text(
                    "📍 Ubicación: ${solicitud['ubicacion'] ?? 'No registrada'}"),
                Text(
                    "🔗 ID de Configuración: ${solicitud['configuracion_id']}"),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text("Cerrar"),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }
}

extension StringExtension on String {
  String capitalize() =>
      this.length > 0 ? '${this[0].toUpperCase()}${this.substring(1)}' : '';
}
