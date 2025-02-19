import 'package:flutter/material.dart';
import '../utils/responsiveLayout.dart';
import 'sendbtn.dart';

class Search extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: ResponsiveLayout.isSmallScreen(context) ? 10 : 50),
      child: Container(
        height: 55,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [BoxShadow(color: Colors.black12, offset: Offset(0, 4), blurRadius: 6)],
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                flex: 8,
                child: TextField(
                  decoration: InputDecoration(border: InputBorder.none, hintText: 'Buscar...'),
                ),
              ),
              Expanded(
                flex: 2,
                child: SendBtn(),
              )
            ],
          ),
        ),
      ),
    );
  }
}
