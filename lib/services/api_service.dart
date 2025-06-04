import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/employee_model.dart';
import '../models/attendance_model.dart';
import '../models/user_model.dart';

class ApiService {
  static const String baseUrl = 'https://employeeapi-fbnp.onrender.com/api';

  // -------------------- EMPLOYEE --------------------

  static Future<List<Employee>> fetchEmployees() async {
    final response = await http.get(Uri.parse('$baseUrl/Employee'));
    print("RESPONSE: ${response.body}");
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Employee.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load employees");
    }
  }

  static Future<Employee> addEmployee(Employee emp) async {
    final response = await http.post(
      Uri.parse('$baseUrl/Employee'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(emp.toJson()),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return Employee.fromJson(jsonDecode(response.body));
    } else {
      String errorMessage = "Failed to add employee";
      try {
        final responseData = jsonDecode(response.body);
        if (responseData is String) {
          errorMessage =
              responseData; // For plain text error like "Employee already exists"
        } else if (responseData is Map && responseData['message'] != null) {
          errorMessage = responseData['message'];
        }
      } catch (_) {
        // Use default message if response isn't JSON
        errorMessage = response.body;
      }
      throw Exception(errorMessage);
    }
  }

  static Future<bool> deleteEmployee(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/Employee/$id'));
    print(response.statusCode);
    return response.statusCode == 200;
  }

  // -------------------- ATTENDANCE --------------------

  static Future<bool> markAttendance(Map<String, dynamic> json) async {
    final response = await http.post(
      Uri.parse('$baseUrl/Attendance'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(json),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");
      return false;
    }
  }

  static Future<List<AttendanceModel>> fetchAllAttendance() async {
    final response = await http.get(Uri.parse('$baseUrl/Attendance'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) => AttendanceModel.fromJson(e)).toList(); // ✅
    } else {
      throw Exception("Failed to load attendance");
    }
  }

  static Future<UserModel?> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/User/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );

    if (response.statusCode == 200) {
      return UserModel.fromJson(jsonDecode(response.body));
    } else {
      print("Login failed: ${response.body}");
      return null;
    }
  }

  static Future<Employee?> getEmployeeById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/Employee/$id'));

    if (response.statusCode == 200) {
      return Employee.fromJson(jsonDecode(response.body));
    } else {
      print("Failed to load employee: ${response.body}");
      return null;
    }
  }

  static Future<bool> updateAttendance(Map<String, dynamic> json) async {
    final int? id = json['attendanceId'];
    if (id == null) {
      print("Error: attendanceId is required to update attendance.");
      return false;
    }

    final response = await http.put(
      Uri.parse('$baseUrl/Attendance/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(json),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      print("Update failed: ${response.statusCode}");
      print("Response body: ${response.body}");
      return false;
    }
  }

  static Future<bool> updateEmployee(Employee employee) async {
    final response = await http.put(
      Uri.parse('$baseUrl/Employee/${employee.employeeId}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(employee.toJson()),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      print("Update failed: ${response.body}");
      throw Exception("Failed to update employee: ${response.body}");
    }
  }
}
