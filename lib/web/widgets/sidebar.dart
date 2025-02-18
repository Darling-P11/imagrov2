import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class Sidebar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      decoration: BoxDecoration(
        color: Colors.green.shade900,
        boxShadow: [BoxShadow(blurRadius: 4, color: Colors.black26)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DrawerHeader(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.account_circle, size: 60, color: Colors.white),
                SizedBox(height: 8),
                Text(
                  "Admin",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ],
            ),
          ),
          _sidebarItem(context, Icons.dashboard, "Dashboard", "/dashboard"),
          _sidebarItem(context, Icons.image, "Solicitudes", "/requests"),
          _sidebarItem(context, Icons.person, "Usuarios", "/users"),
          _sidebarItem(context, Icons.settings, "Ajustes", "/settings"),
          Spacer(),
          Divider(color: Colors.white54),
          _sidebarItem(context, Icons.logout, "Cerrar sesión", "/logout"),
        ],
      ),
    );
  }

  Widget _sidebarItem(
      BuildContext context, IconData icon, String text, String route) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(text, style: TextStyle(color: Colors.white)),
      onTap: () => context.go(route),
    );
  }
}
