import 'package:flutter/material.dart';

class SocialIcons extends StatelessWidget {
   SocialIcons({Key? key}) : super(key: key);

  final List<String> icons = [
    "assets/icons/instagram.png",
    "assets/icons/twitter.png",
    "assets/icons/dribbble.png",
    "assets/icons/facebook.png",
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: icons.map((icon) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: Colors.grey.shade300, offset: const Offset(-4, -4), blurRadius: 8),
              BoxShadow(color: Colors.grey.shade500, offset: const Offset(4, 4), blurRadius: 8),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Image.asset(icon, width: 30),
          ),
        );
      }).toList(),
    );
  }
}
