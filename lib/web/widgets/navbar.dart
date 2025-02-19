import 'package:flutter/material.dart';
import '../utils/responsiveLayout.dart';

class NavBar extends StatelessWidget {
  final List<String> navLinks = ["Home", "Products", "Features", "Contact"];

  List<Widget> navItem() {
    return navLinks.map((text) {
      return Padding(
        padding: const EdgeInsets.only(left: 20),
        child: Text(
          text,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Image.asset("assets/logo.png", width: 50),
          if (!ResponsiveLayout.isSmallScreen(context))
            Row(
              children: <Widget>[
                ...navItem(),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade200,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: const Text("Sign In", style: TextStyle(color: Colors.black87, fontSize: 16)),
                ),
              ],
            )
          else
            const Icon(Icons.menu, size: 28, color: Colors.black),
        ],
      ),
    );
  }
}
