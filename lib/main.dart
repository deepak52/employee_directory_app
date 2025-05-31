import 'package:flutter/material.dart';
import 'views/login_screen.dart';
import 'controllers/employee_controller.dart';
import 'controllers/user_controller.dart';
import 'package:get/get.dart';

void main() {
  Get.put(EmployeeController());
  Get.put(UserController());
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    // return GetMaterialApp(
    //   title: "Employee App",
    //   home: EmployeeListView(),
    //   debugShowCheckedModeBanner: false,
    // );

    return GetMaterialApp(
      title: "Employee App",
      home: LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
