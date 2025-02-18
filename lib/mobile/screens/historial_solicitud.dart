import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
                _buildFiltroBoton("General", Colors.black),
                _buildFiltroBoton("Aprobado", Colors.green),
                _buildFiltroBoton("Denegado", Colors.red),
                _buildFiltroBoton("Pendiente", Colors.yellow[700]!),
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

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("historialContribuciones")
          .doc(userId)
          .collection("enviado")
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text("No hay solicitudes registradas"));
        }

        List<DocumentSnapshot> solicitudes = snapshot.data!.docs;

        if (filtroEstado != "General") {
          solicitudes = solicitudes
              .where((doc) =>
                  doc["estado"] == filtroEstado ||
                  (filtroEstado == "Pendiente" && doc["estado"] == "enviado"))
              .toList();
        }

        return ListView.builder(
          padding: EdgeInsets.symmetric(horizontal: 10),
          itemCount: solicitudes.length,
          itemBuilder: (context, index) {
            var solicitud = solicitudes[index].data() as Map<String, dynamic>;
            return _buildTarjetaSolicitud(solicitud);
          },
        );
      },
    );
  }

  Widget _buildTarjetaSolicitud(Map<String, dynamic> solicitud) {
    Color estadoColor;
    switch (solicitud["estado"]) {
      case "Aprobado":
        estadoColor = Colors.green;
        break;
      case "Denegado":
        estadoColor = Colors.red;
        break;
      case "enviado":
        estadoColor = Colors.yellow[700]!;
        break;
      default:
        estadoColor = Colors.grey;
    }

    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: estadoColor,
          child: Icon(Icons.image, color: Colors.white),
        ),
        title: Text(
          "Fecha de envío: ${solicitud['fecha_contribucion']}",
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
}
