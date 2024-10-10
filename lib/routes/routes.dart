import 'package:get/get.dart';
import 'package:home_automation/views/register_screen.dart';
import '../views/home_screen.dart';
import '../views/login_screen.dart';
import '../views/schedule_screen.dart';

class AppRoutes {
  static List<GetPage> routes = [
    GetPage(name: '/login', page: () => LoginScreen()),

  ];
}
