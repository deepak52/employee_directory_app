import 'package:get/get.dart';
import '../models/attendance_model.dart';
import '../services/api_service.dart';

enum AttendanceMarkResult { success, alreadyMarked, failed }

class AttendanceController extends GetxController {
  var attendanceList = <AttendanceModel>[].obs;

  Future<void> fetchAttendance() async {
    try {
      final records = await ApiService.fetchAllAttendance();
      attendanceList.assignAll(records);
    } catch (e) {
      Get.snackbar("Error", "Failed to fetch attendance: $e");
    }
  }

  @override
  void onInit() {
    super.onInit();
    fetchAttendance();
  }

  Future<AttendanceMarkResult> markAttendance(
    int employeeId,
    DateTime selectedDate,
    bool isPresent,
  ) async {
    final dateOnly = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
    );

    final existing = attendanceList.any(
      (record) =>
          record.employeeId == employeeId &&
          record.attendanceDate.toIso8601String().split("T")[0] ==
              dateOnly.toIso8601String().split("T")[0],
    );

    if (existing) {
      return AttendanceMarkResult.alreadyMarked;
    }

    final record = AttendanceModel(
      employeeId: employeeId,
      attendanceDate: dateOnly,
      isPresent: isPresent,
    );

    try {
      final success = await ApiService.markAttendance(record.toJsonForCreate());

      if (success) {
        await fetchAttendance();
        return AttendanceMarkResult.success;
      } else {
        return AttendanceMarkResult.failed;
      }
    } catch (e) {
      print("Error marking attendance: $e");
      return AttendanceMarkResult.failed;
    }
  }
}
