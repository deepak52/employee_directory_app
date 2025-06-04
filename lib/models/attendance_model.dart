class AttendanceModel {
  final int? attendanceId;
  final int employeeId;
  final String? employeeName;
  final DateTime attendanceDate;
  final bool isPresent;
  final String? remarks;

  AttendanceModel({
    this.attendanceId,
    required this.employeeId,
    this.employeeName,
    required this.attendanceDate,
    required this.isPresent,
    this.remarks,
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      attendanceId: json['attendanceId'],
      employeeId: json['employeeId'],
      employeeName: json['employeeName'], // NEW LINE
      attendanceDate: DateTime.parse(json['attendanceDate']),
      isPresent: json['isPresent'],
      remarks: json['remarks'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'attendanceId': attendanceId,
      'employeeId': employeeId,
      'employeeName': employeeName, // Optional: not needed in POST
      'attendanceDate': attendanceDate.toIso8601String(),
      'isPresent': isPresent,
      'remarks': remarks,
    };
  }

  Map<String, dynamic> toJsonForCreate() {
    return {
      'employeeId': employeeId,
      'attendanceDate': attendanceDate.toIso8601String(),
      'isPresent': isPresent,
      'remarks': remarks,
    };
  }

  Map<String, dynamic> toJsonForUpdate() {
    return {
      'attendanceId': attendanceId,
      'employeeId': employeeId,
      'attendanceDate': attendanceDate.toIso8601String(),
      'isPresent': isPresent,
      'remarks': remarks,
    };
  }
}
