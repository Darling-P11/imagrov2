import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'mobile/main_mobile.dart' as mobile;
import 'web/main_web.dart' as web;

void main() {
  if (kIsWeb) {
    print("📢 Ejecutando versión WEB");
    web.main();
  } else {
    print("📢 Ejecutando versión MÓVIL");
    mobile.main();
  }
}
