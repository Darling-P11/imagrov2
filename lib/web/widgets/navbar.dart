import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class Navbar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.green.shade800,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => context.go('/'),
            child: Row(
              children: [
                Icon(Icons.eco, color: Colors.white),
                SizedBox(width: 8),
                Text(
                  "Imagro",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              _navItem(context, "Inicio", "/"),
              _navItem(context, "Contribuir", "/contribute"),
              _navItem(context, "Mapa", "/map"),
              SizedBox(width: 16),
              ElevatedButton(
                onPressed: () => context.go('/login'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.green.shade800,
                ),
                child: Text("Iniciar sesión"),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _navItem(BuildContext context, String text, String route) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: GestureDetector(
        onTap: () => context.go(route),
        child: Text(
          text,
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(60);
}
