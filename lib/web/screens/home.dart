import 'package:flutter/material.dart';
import '../widgets/navbar.dart';
import '../widgets/social_icons.dart';
import '../utils/responsiveLayout.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FBFF),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            NavBar(),
            _buildHeroSection(context),
            const SizedBox(height: 30),
             SocialIcons(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    bool isMobile = ResponsiveLayout.isSmallScreen(context);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 100, vertical: 50),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              text: "Successful ",
              style: TextStyle(
                fontSize: isMobile ? 34 : 50,
                fontWeight: FontWeight.bold,
                foreground: Paint()
                  ..shader = const LinearGradient(
                    colors: [Color(0xFF26D07C), Color(0xFF29ABE2)],
                  ).createShader(Rect.fromLTWH(0, 0, 200, 50)),
              ),
              children: const [
                TextSpan(
                  text: "Mission",
                  style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold, color: Colors.grey),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            "Lorem ipsum is placeholder text used in the graphic design, print, and publishing industries for previewing layouts.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, color: Colors.black54),
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _neumorphicButton("SIGN UP FREE", Colors.green, Colors.white, true),
              const SizedBox(width: 20),
              _neumorphicButton("Watch Now", Colors.white, Colors.black54, false),
            ],
          ),
          if (!isMobile)
            Padding(
              padding: const EdgeInsets.only(top: 30),
              child: Image.asset("assets/illustration.png", width: 450),
            ),
        ],
      ),
    );
  }

  Widget _neumorphicButton(String text, Color bgColor, Color textColor, bool isPrimary) {
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(color: bgColor.withOpacity(0.3), offset: const Offset(-4, -4), blurRadius: 10),
          BoxShadow(color: bgColor.withOpacity(0.5), offset: const Offset(4, 4), blurRadius: 10),
        ],
      ),
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 14),
        ),
        child: Row(
          children: [
            if (!isPrimary) const Icon(Icons.play_circle_fill, color: Colors.black54, size: 18),
            if (!isPrimary) const SizedBox(width: 5),
            Text(text, style: TextStyle(fontSize: 16, color: textColor, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
