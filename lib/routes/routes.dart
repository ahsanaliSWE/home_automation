import 'package:get/get.dart';
import 'package:home_automation/views/register_screen.dart';
import '../views/home_screen.dart';
import '../views/login_screen.dart';
import '../views/schedule_screen.dart';

class AppRoutes {
  static List<GetPage> routes = [
    GetPage(name: '/login', page: () => LoginScreen()),
   // GetPage(name: '/home', page: () => HomeScreen()),
   // GetPage(name: '/register', page: RegisterScreen()),
    //GetPage(name: '/schedules', page: () => ScheduleScreen()),
  ];
}
