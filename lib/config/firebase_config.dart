import 'package:firebase_core/firebase_core.dart';
import 'package:skincare_app/user%20authentication/firebase_options.dart';

class FirebaseConfig {
  static Future<void> initialize() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
}