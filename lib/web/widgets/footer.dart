import 'package:flutter/material.dart';

class Footer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      color: Colors.green.shade800,
      child: Column(
        children: [
          Text(
            "© 2025 Imagro - Todos los derechos reservados",
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _socialIcon(Icons.facebook),
              SizedBox(width: 8),
              //_socialIcon(Icons.twitter),
              SizedBox(width: 8),
              _socialIcon(Icons.email),
            ],
          ),
        ],
      ),
    );
  }

  Widget _socialIcon(IconData icon) {
    return Icon(icon, color: Colors.white, size: 24);
  }
}
