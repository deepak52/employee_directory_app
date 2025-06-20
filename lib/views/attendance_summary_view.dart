import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/attendance_controller.dart';
import '../controllers/user_controller.dart';
import '../models/attendance_model.dart';
import 'monthly_summary_view.dart';

class AttendanceSummaryView extends StatelessWidget {
  final AttendanceController controller = Get.put(AttendanceController());
  final AttendanceController attendanceController =
      Get.find<AttendanceController>();
  final UserController userController = Get.find<UserController>();

  AttendanceSummaryView({super.key});

  int countWeekendDays(int year, int month) {
    int weekendCount = 0;
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
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Attendance Summary"),
        actions: [
          IconButton(
            icon: const Icon(Icons.list_alt),
            tooltip: 'Monthly Summary',
            onPressed: () => Get.to(() => MonthlySummaryView()),
          ),
        ],
      ),
      body: Obx(() {
        final allRecords = attendanceController.attendanceList;

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
          return const Center(child: Text("No attendance data available"));
        }

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

        return ListView(
          padding: const EdgeInsets.all(12),
          children:
              grouped.entries.map((entry) {
                final records = entry.value;
                final name = records.first.employeeName ?? 'Unknown';
                final year = records.first.attendanceDate.year;
                final month = records.first.attendanceDate.month;
                final monthName = monthNames[month - 1];
                final yearMonth = "$monthName $year";

                final present = records.where((r) => r.isPresent).length;
                final leave = records.where((r) => !r.isPresent).length;
                final offDays = countWeekendDays(year, month);

                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          yearMonth,
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 14,
                          ),
                        ),
                        const Divider(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _summaryChip("Present", present, Colors.green),
                            _summaryChip("Leave", leave, Colors.red),
                            _summaryChip("Off Days", offDays, Colors.blueGrey),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
        );
      }),
    );
  }

  Widget _summaryChip(String label, int count, Color color) {
    return Chip(
      label: Text(
        "$label: $count",
        style: const TextStyle(color: Colors.white),
      ),
      backgroundColor: color,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    );
  }
}
