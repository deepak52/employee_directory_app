import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:get/get.dart';
import '../controllers/attendance_controller.dart';

class AttendanceMarkingView extends StatefulWidget {
  final int employeeId;

  AttendanceMarkingView({required this.employeeId});

  @override
  _AttendanceMarkingViewState createState() => _AttendanceMarkingViewState();
}

class _AttendanceMarkingViewState extends State<AttendanceMarkingView> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, String> markedDates = {};
  bool _isSaving = false;

  final AttendanceController _attendanceController = Get.put(
    AttendanceController(),
  );

  @override
  void initState() {
    super.initState();
    _loadMarkedAttendance();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF3F51B5), Color(0xFF2196F3)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
          ),
          child: SafeArea(
            child: Center(
              child: Text(
                "📅 Mark Attendance",
                style: TextStyle(
                  fontSize: 22,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TableCalendar(
                firstDay: DateTime.utc(2024, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) {
                  final normalizedSelected =
                      _selectedDay != null
                          ? DateUtils.dateOnly(_selectedDay!)
                          : null;
                  final normalizedDay = DateUtils.dateOnly(day);
                  return normalizedSelected != null &&
                      normalizedDay == normalizedSelected;
                },
                onDaySelected: (selectedDay, focusedDay) {
                  final normalized = DateUtils.dateOnly(selectedDay);
                  final now = DateUtils.dateOnly(DateTime.now());
                  final isWeekend =
                      normalized.weekday == DateTime.saturday ||
                      normalized.weekday == DateTime.sunday;
                  final isFuture = normalized.isAfter(now);

                  if (isWeekend || isFuture) return;

                  setState(() {
                    _selectedDay = normalized;
                    _focusedDay = focusedDay;
                    markedDates.putIfAbsent(normalized, () => 'present');
                  });
                },
                calendarBuilders: CalendarBuilders(
                  defaultBuilder: (context, day, _) {
                    final normalizedDay = DateUtils.dateOnly(day);
                    final status = markedDates[normalizedDay];
                    return _buildDayCell(normalizedDay, status);
                  },
                  todayBuilder: (context, day, _) {
                    final normalizedDay = DateUtils.dateOnly(day);
                    final status = markedDates[normalizedDay];
                    return _buildDayCell(normalizedDay, status, isToday: true);
                  },
                ),
              ),
              const SizedBox(height: 16),
              if (_selectedDay != null) _buildAttendanceActions(),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isSaving ? null : _saveMarkedAttendance,
                child:
                    _isSaving
                        ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : const Text("Save Attendance"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDayCell(
    DateTime day,
    String? status, {
    bool isToday = false,
    bool isSelected = false,
  }) {
    Color? bgColor;
    IconData? icon;

    if (status == 'present') {
      bgColor = Colors.greenAccent;
      icon = Icons.check;
    } else if (status == 'leave') {
      bgColor = Colors.orangeAccent;
      icon = Icons.beach_access;
    } else if (isToday) {
      bgColor = Colors.blue.shade100;
    }

    return Container(
      margin: EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: bgColor ?? Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey),
      ),
      alignment: Alignment.center,
      child:
          icon != null
              ? Icon(icon, size: 16, color: Colors.black)
              : Text(
                '${day.day}',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
    );
  }

  Widget _buildAttendanceActions() {
    final key = DateUtils.dateOnly(_selectedDay!);
    final status = markedDates[key];

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: AnimatedSwitcher(
        duration: Duration(milliseconds: 300),
        child:
            status != 'leave'
                ? ElevatedButton.icon(
                  key: ValueKey("leave"),
                  onPressed: () {
                    setState(() {
                      markedDates[key] = 'leave';
                    });
                  },
                  icon: Icon(Icons.beach_access),
                  label: Text("Mark as Leave"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                )
                : Text(
                  "Marked as Leave",
                  style: TextStyle(color: Colors.orange, fontSize: 16),
                ),
      ),
    );
  }

  void _loadMarkedAttendance() async {
    await _attendanceController.fetchAttendance();
    final employeeAttendance = _attendanceController.attendanceList.where(
      (record) => record.employeeId == widget.employeeId,
    );

    setState(() {
      for (var record in employeeAttendance) {
        final date = DateUtils.dateOnly(record.attendanceDate);
        markedDates[date] = record.isPresent ? 'present' : 'leave';
      }
    });
  }

  void _saveMarkedAttendance() async {
    if (_isSaving) return;

    if (markedDates.isEmpty) {
      Get.snackbar("No Data", "Please mark attendance before saving");
      return;
    }

    setState(() => _isSaving = true);

    bool anySaved = false;
    bool anyAlreadyMarked = false;
    bool anyFailed = false;

    for (final entry in markedDates.entries) {
      final date = entry.key;
      final status = entry.value;
      final isPresent = status == 'present';

      final result = await _attendanceController.markAttendance(
        widget.employeeId,
        date,
        isPresent,
      );

      switch (result) {
        case AttendanceMarkResult.success:
          anySaved = true;
          break;
        case AttendanceMarkResult.alreadyMarked:
          anyAlreadyMarked = true;
          break;
        case AttendanceMarkResult.failed:
          anyFailed = true;
          break;
      }
    }

    if (anySaved) {
      Get.snackbar(
        "Success",
        "Attendance saved successfully",
        backgroundColor: Colors.greenAccent,
      );
    } else if (anyAlreadyMarked && !anySaved) {
      Get.snackbar(
        "Info",
        "All selected dates already marked",
        backgroundColor: Colors.orangeAccent,
      );
    } else if (anyFailed && !anySaved) {
      Get.snackbar(
        "Error",
        "Failed to mark attendance",
        backgroundColor: Colors.redAccent,
      );
    }

    setState(() => _isSaving = false);
  }
}
