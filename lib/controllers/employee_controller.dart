import 'package:get/get.dart';
import '../models/employee_model.dart';
import '../services/api_service.dart';

class EmployeeController extends GetxController {
  var employeeList = <Employee>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchEmployees();
  }

  Future<void> fetchEmployees() async {
    try {
      final employees = await ApiService.fetchEmployees();
      print("Fetched employees: $employees"); // Add this
      employeeList.assignAll(employees);
    } catch (e) {
      Get.snackbar("Error", "Failed to fetch employees: $e");
    }
  }

  Future<bool> addEmployee(Employee emp) async {
    try {
      final newEmp = await ApiService.addEmployee(emp);
      employeeList.add(newEmp);
      Get.snackbar("Success", "Employee added");
      return true;
    } catch (e) {
      Get.snackbar("Error", "Failed to add employee: $e");
      return false;
    }
  }

  Future<bool> removeEmployee(int id) async {
    try {
      final success = await ApiService.deleteEmployee(id);
      if (success) {
        employeeList.removeWhere((e) => e.employeeId == id);
        Get.snackbar("Deleted", "Employee removed");
      } else {
        print(success);
        Get.snackbar("Error", "Failed to delete employee");
      }
      return success;
    } catch (e) {
      Get.snackbar("Error", "Exception: $e");
      return false;
    }
  }
}
