class UserModel {
  final int userId;
  final String username;
  final String role;
  final int? employeeId;
  final String? employeeName;

  UserModel({
    required this.userId,
    required this.username,
    required this.role,
    this.employeeId,
    this.employeeName,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['userId'],
      username: json['username'],
      role: json['role'],
      employeeId: json['employeeId'],
      employeeName: json['employeeName'],
    );
  }

  // Add this method to convert to JSON (Map)
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'username': username,
      'role': role,
      'employeeId': employeeId,
      'employeeName': employeeName,
    };
  }
}
