import 'package:flutter/material.dart';
import 'employee_list_view.dart';
import 'attendance_summary_view.dart';
import 'monthly_summary_view.dart';
import 'package:get/get.dart';
import '../controllers/user_controller.dart';

class AdminHomeView extends StatelessWidget {
  final UserController controller = Get.put(UserController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Admin Dashboard")),
      body: ListView(
        children: [
          ListTile(
            title: Text("Employee Directory"),
            onTap: () => Get.to(() => EmployeeListView()),
          ),
          ListTile(
            title: Text("Attendance Summary"),
            onTap: () => Get.to(() => AttendanceSummaryView()),
          ),
          ListTile(
            title: Text("Monthly Summary"),
            onTap: () => Get.to(() => MonthlySummaryView()),
          ),
        ],
      ),
    );
  }
}
