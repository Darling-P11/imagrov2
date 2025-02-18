import 'package:flutter/material.dart';
import 'package:imagro/web/widgets/sidebar.dart';

class DashboardWebScreen extends StatelessWidget {
  const DashboardWebScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Sidebar(),
          Expanded(
            child: Center(child: Text("Panel de Administración")),
          ),
        ],
      ),
    );
  }
}
