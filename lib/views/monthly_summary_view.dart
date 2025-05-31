import 'package:flutter/material.dart';
import 'package:get/get.dart';
//import 'package:http/http.dart';
import '../models/attendance_summary_model.dart';
import '../controllers/attendance_controller.dart';
import 'package:intl/intl.dart';

class MonthlySummaryView extends StatelessWidget {
  MonthlySummaryView({super.key});

  final AttendanceController controller = Get.put(AttendanceController());

  final attendanceController = Get.find<AttendanceController>();

  final selectedMonth = DateTime.now().obs;

  List<MonthlySummaryModel> calculateMonthlySummary(DateTime month) {
    final allRecords = attendanceController.attendanceList;
    final String targetMonth = DateFormat("yyyy-MM").format(month);

    Map<int, MonthlySummaryModel> summaryMap = {}; // Use employeeId as key

    for (var record in allRecords) {
      final recordMonth = DateFormat("yyyy-MM").format(record.attendanceDate);

      if (recordMonth == targetMonth) {
        final id = record.employeeId;

        summaryMap.putIfAbsent(
          id,
          () => MonthlySummaryModel(
            employeeId: id,
            employeeName: record.employeeName,
            presentCount: 0,
            absentCount: 0,
          ),
        );

        if (record.isPresent) {
          summaryMap[id]!.presentCount++;
        } else {
          summaryMap[id]!.absentCount++;
        }
      }
    }

    return summaryMap.values.toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Monthly Attendance Summary")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Obx(
              () => Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Month : ${DateFormat('MMMM yyyy').format(selectedMonth.value)}",
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    onPressed: () async {
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: selectedMonth.value,
                        firstDate: DateTime(2025),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        selectedMonth.value = picked;
                      }
                    },
                    icon: Icon(Icons.calendar_today),
                  ),
                ],
              ),
            ),
          ),
          Obx(() {
            final summary = calculateMonthlySummary(selectedMonth.value);
            return Expanded(
              child: ListView.builder(
                itemCount: summary.length,
                itemBuilder: (context, index) {
                  final data = summary[index];
                  return ListTile(
                    title: Text(data.employeeName ?? 'Unknown Employee'),
                    subtitle: Text(
                      "Present : ${data.presentCount} | Absent : ${data.absentCount}",
                    ),
                  );
                },
              ),
            );
          }),
        ],
      ),
    );
  }
}
