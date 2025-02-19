import 'package:flutter/material.dart';

class SendBtn extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [Colors.blueAccent, Colors.blue]),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.3), offset: Offset(0.0, 6.0), blurRadius: 6.0)],
        ),
        child: Center(
          child: Text("Enviar", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}
