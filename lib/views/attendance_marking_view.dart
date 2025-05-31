import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:get/get.dart';
import '../controllers/attendance_controller.dart';
import '../models/attendance_model.dart';

class AttendanceMarkingView extends StatefulWidget {
  final int employeeId;

  AttendanceMarkingView({required this.employeeId});

  @override
  _AttendanceMarkingViewState createState() => _AttendanceMarkingViewState();
}

class _AttendanceMarkingViewState extends State<AttendanceMarkingView> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, String> markedDates = {}; // 'present' or 'leave'
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
      appBar: AppBar(title: Text("Mark Attendance")),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2024, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              final now = DateTime.now();
              final today = DateTime(now.year, now.month, now.day);
              final selected = DateTime(
                selectedDay.year,
                selectedDay.month,
                selectedDay.day,
              );

              final isWeekend =
                  selectedDay.weekday == DateTime.saturday ||
                  selectedDay.weekday == DateTime.sunday;
              final isFuture = selected.isAfter(today);
              final isPreviousMonth =
                  selectedDay.month < today.month ||
                  selectedDay.year < today.year;

              if (isFuture || isWeekend || isPreviousMonth) return;

              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;

                // Mark as present by default
                markedDates[selected] = 'present';
              });
            },
            calendarBuilders: CalendarBuilders(
              defaultBuilder: (context, day, _) {
                final status =
                    markedDates[DateTime(day.year, day.month, day.day)];
                return _buildDayCell(day, status);
              },
              todayBuilder: (context, day, _) {
                final status =
                    markedDates[DateTime(day.year, day.month, day.day)];
                return _buildDayCell(day, status, isToday: true);
              },
            ),
          ),
          SizedBox(height: 16),
          if (_selectedDay != null) _buildAttendanceActions(),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _isSaving ? null : _saveMarkedAttendance,
            child:
                _isSaving
                    ? SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                    : Text("Save Attendance"),
          ),
        ],
      ),
    );
  }

  Widget _buildDayCell(DateTime day, String? status, {bool isToday = false}) {
    return Container(
      margin: EdgeInsets.all(4),
      decoration: BoxDecoration(
        color:
            status == 'present'
                ? Colors.greenAccent
                : status == 'leave'
                ? Colors.orangeAccent
                : isToday
                ? Colors.blue[100]
                : Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey),
      ),
      alignment: Alignment.center,
      child: Text(
        '${day.day}',
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
      ),
    );
  }

  Widget _buildAttendanceActions() {
    final key = DateTime(
      _selectedDay!.year,
      _selectedDay!.month,
      _selectedDay!.day,
    );
    final status = markedDates[key];

    return Column(
      children: [
        if (status != 'leave')
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                markedDates[key] = 'leave';
              });
            },
            icon: Icon(Icons.beach_access),
            label: Text("Mark as Leave"),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
          ),
      ],
    );
  }

  void _loadMarkedAttendance() async {
    await _attendanceController.fetchAttendance();
    final employeeAttendance = _attendanceController.attendanceList.where(
      (record) => record.employeeId == widget.employeeId,
    );

    setState(() {
      for (var record in employeeAttendance) {
        final date = DateTime(
          record.attendanceDate.year,
          record.attendanceDate.month,
          record.attendanceDate.day,
        );
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
      Get.snackbar("Success", "Attendance saved successfully");
    } else if (anyAlreadyMarked && !anySaved) {
      Get.snackbar("Info", "All selected dates already marked");
    } else if (anyFailed && !anySaved) {
      Get.snackbar("Error", "Failed to mark attendance");
    }

    setState(() => _isSaving = false);
  }
}
