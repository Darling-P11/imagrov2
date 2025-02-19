import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:imagro/mobile/widgets/submenu_encabezado.dart';

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
        int contribCount = contribSnapshot.hasData ? contribSnapshot.data! : 0;

        return StreamBuilder(
          stream: FirebaseFirestore.instance.collection('users').snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> userSnapshot) {
            int userCount =
                userSnapshot.hasData ? userSnapshot.data!.docs.length : 0;

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
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.notifications,
                                  color: Colors.white),
                              onPressed: () {},
                            ),
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
                              onPressed: () {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(
                                  content: Text('Redirigiendo al sitio web...'),
                                ));
                              },
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
                              count: userCount.toString(),
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
                              title: 'Aportaciones',
                              count: contribCount.toString(),
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
    required String count,
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
            children: [
              Image.asset(
                image,
                width: 27,
                height: 27,
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
}
