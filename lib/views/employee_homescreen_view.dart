import 'package:employee_management_app/controllers/attendance_controller.dart';
import 'package:employee_management_app/views/attendance_summary_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/user_controller.dart';
import 'attendance_marking_view.dart';

class EmployeeHomeView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final UserController controller = Get.put(UserController());
    final AttendanceController Controller = Get.put(AttendanceController());

    final userController = Get.find<UserController>();
    final empId = userController.currentUser.value?.employeeId;

    return Scaffold(
      appBar: AppBar(title: Text("Employee Dashboard")),
      body: ListView(
        children: [
          ListTile(
            title: Text("Mark Attendance"),
            onTap: () {
              Get.to(AttendanceMarkingView(employeeId: empId!));
            },
          ),
          ListTile(
            title: Text("Monthly Summary"),
            onTap: () {
              Get.to(() => AttendanceSummaryView());
            },
          ),
        ],
      ),
    );
  }
}
