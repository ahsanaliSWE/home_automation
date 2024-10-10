import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'controllers/auth_controller.dart';
import 'utils/notifications_service.dart';
import 'views/login_screen.dart';
import 'views/register_screen.dart';
import 'views/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  Get.put(AuthController()); // Initialize AuthController
  await NotificationService.initialize();

  runApp(SmartHomeApp());
}

class SmartHomeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Smart Home Automation',
      initialRoute: _determineInitialRoute(),
      getPages: [
        GetPage(name: '/login', page: () => LoginScreen()),
        GetPage(name: '/register', page: () => RegisterScreen()),
        GetPage(name: '/home', page: () => HomeScreen()),
      ],
    );
  }

  // Determine initial route based on user's authentication status
  String _determineInitialRoute() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // User is signed in
      return '/home';
    } else {
      // User is not signed in
      return '/login';
    }
  }
}
