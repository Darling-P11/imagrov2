![Banner](https://imgur.com/2BEXRlN.png)
---
**Imagro** permite a los usuarios registrar imágenes georreferenciadas de cultivos desde su teléfono. Estas imágenes se integran a un sistema central donde son analizadas para la recopiladción de información a un dataset público con imágenes verificadas..

Esta solución busca asistir a productores, investigadores, estudiante o el campo agrícola, facilitando el diagnóstico visual y el almacenamiento de información técnica para su análisis posterior.

---

## ⚙️ Tecnologías utilizadas

| Herramienta         | Versión         |
|---------------------|-----------------|
| Flutter SDK         | 3.27.1 (stable) |
| Dart SDK            | 3.6.0           |
| Android SDK         | 35.0.0          |
| Firebase            | Auth, Firestore, Storage, Messaging |
| Otras               | Geolocator, Image Picker, Provider |

---

## 🚀 Instalación y primeros pasos

### 📦 **Instala las dependencias**

```bash
flutter pub get
```

### ✅ **Verifica tu entorno**

```bash
flutter doctor
```

Asegúrate de tener configurado correctamente Android Studio, `cmdline-tools` y haber aceptado las licencias del SDK:

```bash
flutter doctor --android-licenses
```

---

### 🔧 **Configuración de Firebase**

1. Crea un proyecto en [Firebase Console](https://console.firebase.google.com/)
2. Descarga el archivo `google-services.json`
3. Colócalo dentro del directorio: `/android/app`
4. Asegúrate de habilitar:

   - Firebase Authentication (Email/Password)  
   - Cloud Firestore  
   - Firebase Storage  
   - *(Opcional)* Firebase Messaging

---

### 🧩 **Dependencias utilizadas**

Estas son algunas de las dependencias principales del proyecto. Para más detalles, revisa el archivo `pubspec.yaml`.

```yaml
dependencies:
  firebase_core: ^3.10.1
  firebase_auth: ^5.4.1
  cloud_firestore: ^5.6.2
  firebase_storage: ^12.4.1
  firebase_messaging: ^15.2.1
  geolocator: ^13.0.2
  cached_network_image: ^3.4.1
  image_picker: ^1.1.2
  provider: ^6.0.0
```

---

### 🤝 **¿Cómo contribuir?**

1. Haz un fork del repositorio.
2. Crea una nueva rama basada en `main`:

```bash
git checkout -b feature/nueva-funcionalidad
```

3. Realiza tus cambios y haz commit:

```bash
git commit -m "Agrega nueva funcionalidad"
```

4. Haz push a tu rama:

```bash
git push origin feature/nueva-funcionalidad
```

5. Abre una Pull Request describiendo los cambios realizados.

📄 Consulta la guía completa en `CONTRIBUTING.md`.

---
---

### 📲 **Disponible en Google Play**

La aplicación se encuentra publicada en producción y puede ser descargada desde el siguiente enlace:

➡️ [Imagro Móvil en Google Play](https://play.google.com/store/apps/details?id=com.UTEQ.imagro&hl=es_EC)

---

### 📄 **Licencia**

Este repositorio está licenciado bajo la **GNU General Public License v3.0**. Consulta el archivo `LICENSE` para más detalles.

---

### ✉️ **Contacto**

**Desarrollado por:** Kevin Darling Ponce Rivera  
📧 **Correo:** kevinponce2001@hotmail.com
