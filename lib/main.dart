import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'mobile/main_mobile.dart' as mobile;
// import 'web/main_web.dart' as web; // Para cuando la web esté lista

void main() {
  if (kIsWeb) {
    // web.main(); // Activar cuando tengamos la versión web
  } else {
    mobile.main();
  }
}
