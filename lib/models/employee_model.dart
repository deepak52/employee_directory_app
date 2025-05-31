class Employee {
  final int employeeId;
  final String name;
  final String department;
  final String email; // 👈 Add this

  Employee({
    required this.employeeId,
    required this.name,
    required this.department,
    required this.email,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      employeeId: json['employeeId'],
      name: json['name'],
      department: json['department'],
      email: json['email'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'employeeId': employeeId,
      'name': name,
      'department': department,
      'email': email, // 👈 Add this
    };
  }
}
