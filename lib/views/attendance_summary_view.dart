import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/attendance_controller.dart';
import '../controllers/user_controller.dart';
import '../models/attendance_model.dart';
import '../views/monthly_summary_view.dart';

class AttendanceSummaryView extends StatelessWidget {
  final AttendanceController controller = Get.put(AttendanceController());
  final AttendanceController attendanceController =
      Get.find<AttendanceController>();
  final UserController userController = Get.find<UserController>();

  AttendanceSummaryView({super.key});

  // Helper function to count Saturdays and Sundays in a month
  int countWeekendDays(int year, int month) {
    int weekendCount = 0;
    // Get the number of days in the month
    final lastDay = DateTime(year, month + 1, 0).day;

    for (int day = 1; day <= lastDay; day++) {
      final weekday = DateTime(year, month, day).weekday;
      if (weekday == DateTime.saturday || weekday == DateTime.sunday) {
        weekendCount++;
      }
    }
    return weekendCount;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Attendance Summary"),
        actions: [
          IconButton(
            onPressed: () {
              Get.to(MonthlySummaryView());
            },
            icon: Icon(Icons.list_alt),
          ),
        ],
      ),
      body: Obx(() {
        final allRecords = attendanceController.attendanceList;

        // Map key: employeeId + year-month string
        Map<String, List<AttendanceModel>> grouped = {};

        for (var record in allRecords) {
          if (!userController.isAdmin &&
              record.employeeId !=
                  userController.currentUser.value?.employeeId) {
            continue;
          }

          final yearMonth =
              "${record.attendanceDate.year}-${record.attendanceDate.month.toString().padLeft(2, '0')}";

          final key = "${record.employeeId}-$yearMonth";

          grouped.putIfAbsent(key, () => []).add(record);
        }

        if (grouped.isEmpty) {
          return Center(child: Text("No attendance data available"));
        }

        return ListView(
          children:
              grouped.entries.map((entry) {
                final records = entry.value;
                final name = records.first.employeeName ?? 'Unknown';
                final year = records.first.attendanceDate.year;
                final month = records.first.attendanceDate.month;

                final monthNames = [
                  'January',
                  'February',
                  'March',
                  'April',
                  'May',
                  'June',
                  'July',
                  'August',
                  'September',
                  'October',
                  'November',
                  'December',
                ];

                final monthName = monthNames[month - 1];
                final yearMonth = "$monthName - $year";

                final present = records.where((r) => r.isPresent).length;
                final leave = records.where((r) => !r.isPresent).length;
                final offDays = countWeekendDays(year, month);

                return Card(
                  margin: EdgeInsets.all(8),
                  child: ListTile(
                    title: Text("$name ($yearMonth)"),
                    subtitle: Text(
                      "Present: $present  |  Leave: $leave  |  Off Days: $offDays",
                    ),
                  ),
                );
              }).toList(),
        );
      }),
    );
  }
}
