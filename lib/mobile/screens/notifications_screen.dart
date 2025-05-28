import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      return Scaffold(
        body: Center(child: Text("Usuario no autenticado")),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildEncabezado(context),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('notificaciones')
                  .doc(userId)
                  .collection('mensajes')
                  .orderBy('fecha', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text("No tienes notificaciones."));
                }

                final notificaciones = snapshot.data!.docs;

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: notificaciones.length,
                  separatorBuilder: (_, __) => SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final data =
                        notificaciones[index].data() as Map<String, dynamic>;
                    final id = notificaciones[index].id;

                    final titulo = data['titulo'] ?? 'Sin título';
                    final descripcion = data['descripcion'] ?? '';
                    final leida = data['leida'] ?? false;
                    final Timestamp? timestamp =
                        data['fecha'] is Timestamp ? data['fecha'] : null;

                    final fecha = timestamp != null
                        ? DateFormat('d MMM yyyy', 'es_ES')
                            .format(timestamp.toDate())
                        : '';

                    return Dismissible(
                      key: Key(id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: EdgeInsets.only(right: 20),
                        color: Colors.red,
                        child: Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (direction) {
                        FirebaseFirestore.instance
                            .collection('notificaciones')
                            .doc(userId)
                            .collection('mensajes')
                            .doc(id)
                            .delete();
                      },
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        color: leida ? Colors.grey[100] : Color(0xFFE6FFF0),
                        child: ListTile(
                          leading: Icon(
                            leida
                                ? Icons.mark_email_read_outlined
                                : Icons.notifications_active_outlined,
                            color: leida ? Colors.grey : Color(0xFF0BA37F),
                          ),
                          title: Text(
                            titulo,
                            style: TextStyle(
                              fontWeight:
                                  leida ? FontWeight.normal : FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            descripcion.length > 80
                                ? '${descripcion.substring(0, 80)}...'
                                : descripcion,
                          ),
                          trailing: Text(
                            fecha,
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          onTap: () {
                            // Mostrar detalle completo
                            showDialog(
                              context: context,
                              builder: (_) => Dialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.notifications,
                                        size: 50,
                                        color: Color(0xFF0BA37F),
                                      ),
                                      SizedBox(height: 15),
                                      Text(
                                        titulo,
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      SizedBox(height: 10),
                                      Text(
                                        descripcion,
                                        style: TextStyle(fontSize: 16),
                                        textAlign: TextAlign.justify,
                                      ),
                                      SizedBox(height: 20),
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: Text(
                                          fecha,
                                          style: TextStyle(
                                              fontSize: 12, color: Colors.grey),
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: Text(
                                            'Cerrar',
                                            style: TextStyle(
                                                color: Color(0xFF0BA37F)),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );

                            // Marcar como leída
                            if (!leida) {
                              FirebaseFirestore.instance
                                  .collection('notificaciones')
                                  .doc(userId)
                                  .collection('mensajes')
                                  .doc(id)
                                  .update({'leida': true});
                            }
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEncabezado(BuildContext context) {
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back_ios_new, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Center(
              child: Text(
                'Notificaciones',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          SizedBox(width: 48),
        ],
      ),
    );
  }
}
