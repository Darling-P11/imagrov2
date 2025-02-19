import 'package:flutter/material.dart';

class FooterWidget extends StatelessWidget {
  const FooterWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 0),
          child: Image.asset(
            'assets/images/logo_banner.png',
            width: 80,
            height: 80,
            fit: BoxFit.contain,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 16, right: 16),
          child: Align(
            alignment: Alignment.bottomRight,
            child: FloatingActionButton(
              onPressed: () {
                // Acción para compartir
              },
              backgroundColor: const Color(0xFF0BA37F),
              child: const Icon(
                Icons.share,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
