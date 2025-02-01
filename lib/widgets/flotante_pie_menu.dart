import 'package:flutter/material.dart';

class FooterWidget extends StatelessWidget {
  const FooterWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        // Acción para el botón flotante
      },
      backgroundColor: Color(0xFF0BA37F),
      child: Icon(
        Icons.add,
        color: Colors.white,
      ),
    );
  }
}
