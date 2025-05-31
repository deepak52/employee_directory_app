import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controllers/employee_controller.dart';
import 'controllers/user_controller.dart';
import 'views/login_screen.dart';
import 'views/admin_homeScreen_view.dart';
import 'views/employee_homescreen_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize controllers
  Get.put(EmployeeController());
  final userController = Get.put(UserController());

  // Wait to load user from prefs
  await userController.loadUserFromPrefs();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final UserController userController = Get.find();

    return GetMaterialApp(
      title: "Employee App",
      debugShowCheckedModeBanner: false,
      home: Obx(() {
        if (userController.isLoggedIn) {
          final role = userController.currentUser.value!.role.toLowerCase();
          if (role == 'admin') {
            return AdminHomeView();
          } else if (role == 'employee') {
            return EmployeeHomeView();
          } else {
            return LoginScreen(); // unknown role fallback
          }
        } else {
          return LoginScreen();
        }
      }),
    );
  }
}
