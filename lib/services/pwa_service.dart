// PWA-hjælp til Flutter 3.44 / Dart 3.12.
// Denne version bruger ikke dart:js_util, som ikke findes i nyere Dart.
// Edge kan stadig installere appen via browsermenuen: Apps -> Installer.

class PwaService {
  static bool get isInstalled => false;

  static Future<bool> install() async {
    // Installationsprompten håndteres af Edge/Chrome, når appen er bygget med:
    // flutter build web
    // og køres fra build/web på localhost eller HTTPS.
    return false;
  }
}
