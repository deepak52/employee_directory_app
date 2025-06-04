import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../models/attendance_summary_model.dart';
import '../controllers/attendance_controller.dart';

class MonthlySummaryView extends StatelessWidget {
  MonthlySummaryView({super.key});

  final AttendanceController controller = Get.put(AttendanceController());
  final AttendanceController attendanceController =
      Get.find<AttendanceController>();
  final selectedMonth = DateTime.now().obs;

  List<MonthlySummaryModel> calculateMonthlySummary(DateTime month) {
    final allRecords = attendanceController.attendanceList;
    final String targetMonth = DateFormat("yyyy-MM").format(month);

    Map<int, MonthlySummaryModel> summaryMap = {};

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
      backgroundColor: Colors.grey[100],
      appBar: AppBar(title: const Text("Monthly Attendance Summary")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Obx(
              () => Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat('MMMM yyyy').format(selectedMonth.value),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  ElevatedButton.icon(
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
                    icon: const Icon(Icons.calendar_today, size: 18),
                    label: const Text("Select"),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
              final summary = calculateMonthlySummary(selectedMonth.value);
              if (summary.isEmpty) {
                return const Center(child: Text("No data for selected month."));
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: summary.length,
                itemBuilder: (context, index) {
                  final data = summary[index];
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      title: Text(
                        data.employeeName ?? 'Unknown Employee',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildCountChip(
                              "Present",
                              data.presentCount,
                              Colors.green,
                            ),
                            _buildCountChip(
                              "Absent",
                              data.absentCount,
                              Colors.red,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildCountChip(String label, int count, Color color) {
    return Chip(
      label: Text(
        "$label: $count",
        style: const TextStyle(color: Colors.white),
      ),
      backgroundColor: color,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    );
  }
}
