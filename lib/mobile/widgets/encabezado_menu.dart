import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:imagro/mobile/widgets/submenu_encabezado.dart';
import 'package:url_launcher/url_launcher.dart'; // ✅ Importar url_launcher
import 'package:shimmer/shimmer.dart'; // loading skeleton
import 'package:imagro/mobile/screens/notifications_screen.dart'; //importar notificaciones

class HeaderWidget extends StatelessWidget {
  final User? user;
  final String? userImage;
  final String? userName;

  const HeaderWidget({super.key, this.user, this.userImage, this.userName});

  @override
  Widget build(BuildContext context) {
    final DateTime now = DateTime.now();
    final String formattedDate =
        DateFormat('EEEE, d MMMM yyyy', 'es_ES').format(now);
    final String greeting = _getGreeting(now);

    return FutureBuilder<int>(
      future: _getTotalContributions(),
      builder: (context, contribSnapshot) {
        int? contribCount = contribSnapshot.data;

        return StreamBuilder(
          stream: FirebaseFirestore.instance.collection('users').snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> userSnapshot) {
            int? userCount =
                userSnapshot.hasData ? userSnapshot.data!.docs.length : null;

            return Container(
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
                        //SAludo y fecha
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              greeting,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              formattedDate,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                        // Notificación + perfil
                        Row(
                          children: [
                            // Ícono de notificación
                            StreamBuilder<QuerySnapshot>(
                              stream: user != null
                                  ? FirebaseFirestore.instance
                                      .collection('notificaciones')
                                      .doc(user!.uid)
                                      .collection('mensajes')
                                      .where('leida', isEqualTo: false)
                                      .snapshots()
                                  : null,
                              builder: (context, snapshot) {
                                final int cantidadNoLeidas = snapshot.hasData
                                    ? snapshot.data!.docs.length
                                    : 0;

                                return Stack(
                                  alignment: Alignment.topRight,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.notifications_none,
                                          color: Colors.white),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const NotificationsScreen(),
                                          ),
                                        );
                                      },
                                    ),
                                    if (cantidadNoLeidas > 0)
                                      Positioned(
                                        right: 6,
                                        top: 6,
                                        child: Container(
                                          padding: EdgeInsets.all(2),
                                          decoration: BoxDecoration(
                                            color: Colors.red,
                                            shape: BoxShape.circle,
                                          ),
                                          constraints: BoxConstraints(
                                            minWidth: 16,
                                            minHeight: 16,
                                          ),
                                          child: Center(
                                            child: Text(
                                              cantidadNoLeidas > 9
                                                  ? '9+'
                                                  : '$cantidadNoLeidas',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                );
                              },
                            ),

                            // Menú de perfil
                            ProfileDropdownMenu(
                              user: user,
                              userImage: userImage,
                              userName: userName,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
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
                              onPressed: () =>
                                  _abrirWebsite(), // ✅ Redirigir a la web
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: Colors.white),
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              child: Text(
                                'Imagro Web', // ✅ Se cambió el texto del botón
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
                          children: userCount == null || contribCount == null
                              ? _buildSkeletonStats() // Loading
                              : [
                                  _buildStatCard(
                                    image: 'assets/icons/usuarios.png',
                                    title: 'Usuarios',
                                    count:
                                        userCount?.toString(), // puede ser null
                                    backgroundColor: Color(0xFFA7D590),
                                  ),
                                  _buildStatCard(
                                    image: 'assets/icons/datasets.png',
                                    title: 'Modelos IA',
                                    count: '3', // fijo
                                    backgroundColor: Color(0xFF62C8B6),
                                  ),
                                  _buildStatCard(
                                    image: 'assets/icons/contribuciones.png',
                                    title: 'Aportaciones',
                                    count: contribCount
                                        ?.toString(), // puede ser null
                                    backgroundColor: Color(0xFF8CE6A6),
                                  ),
                                ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ✅ Función para abrir Imagro Web en el navegador
  void _abrirWebsite() async {
    final Uri url = Uri.parse('https://imagroweb.netlify.app');

    if (await canLaunchUrl(url)) {
      await launchUrl(
        url,
        mode:
            LaunchMode.externalApplication, // 🔹 Abre el navegador del sistema
      );
    } else {
      debugPrint('No se pudo abrir la URL: $url');
    }
  }

  Future<int> _getTotalContributions() async {
    int totalContributions = 0;

    QuerySnapshot userDocs =
        await FirebaseFirestore.instance.collection('users').get();

    for (var userDoc in userDocs.docs) {
      String userId = userDoc.id;

      QuerySnapshot contribDocs = await FirebaseFirestore.instance
          .collection('historialContribuciones')
          .doc(userId)
          .collection('enviado')
          .get();

      totalContributions += contribDocs.docs.length;
    }

    return totalContributions;
  }

  String _getGreeting(DateTime now) {
    final hour = now.hour;
    if (hour >= 0 && hour < 12) {
      return 'Buenos días';
    } else if (hour >= 12 && hour < 18) {
      return 'Buenas tardes';
    } else {
      return 'Buenas noches';
    }
  }

  Widget _buildStatCard({
    required String image,
    required String title,
    required String? count,
    required Color backgroundColor,
  }) {
    return Container(
      width: 107,
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
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Image.asset(
                image,
                width: 27,
                height: 27,
              ),
              SizedBox(width: 8),
              count == null
                  ? Shimmer.fromColors(
                      baseColor: Colors.grey.shade300,
                      highlightColor: Colors.grey.shade100,
                      child: Container(
                        width: 25,
                        height: 22,
                        color: Colors.grey.shade300,
                      ),
                    )
                  : Text(
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

  List<Widget> _buildSkeletonStats() {
    return List.generate(3, (index) {
      return Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Container(
          width: 100,
          height: 90,
          margin: EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    });
  }
}
