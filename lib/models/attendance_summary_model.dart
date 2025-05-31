class MonthlySummaryModel {
  int employeeId;
  final String? employeeName; // make nullable
  int presentCount;
  int absentCount;

  MonthlySummaryModel({
    required this.employeeId,
    required this.employeeName,
    required this.presentCount,
    required this.absentCount,
  });

  factory MonthlySummaryModel.fromJson(Map<String, dynamic> json) {
    return MonthlySummaryModel(
      employeeId: json['employeeId'],
      employeeName: json['employeeName'],
      presentCount: json['presentCount'] ?? 0,
      absentCount: json['absentCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'employeeId': employeeId,
      'employeeName': employeeName,
      'presentCount': presentCount,
      'absentCount': absentCount,
    };
  }
}
