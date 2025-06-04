import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/employee_controller.dart';
import '../models/employee_model.dart';
import '../views/employee_form_view.dart';
import '../views/login_screen.dart';
import 'employee_detail_view.dart';
import '../services/api_service.dart';

class EmployeeListView extends StatefulWidget {
  @override
  _EmployeeListViewState createState() => _EmployeeListViewState();
}

class _EmployeeListViewState extends State<EmployeeListView> {
  final EmployeeController controller = Get.find<EmployeeController>();

  @override
  void initState() {
    super.initState();
    controller.fetchEmployees();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text("Employee Directory"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: _logout,
          ),
        ],
      ),
      body: Obx(() {
        if (controller.employeeList.isEmpty) {
          return Center(
            child: Text(
              "No employees found",
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: controller.employeeList.length,
          itemBuilder: (context, index) {
            Employee emp = controller.employeeList[index];

            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 3,
              margin: EdgeInsets.only(bottom: 12),
              child: ListTile(
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                onTap: () async {
                  final fullEmp = await ApiService.getEmployeeById(
                    emp.employeeId,
                  );
                  if (fullEmp != null) {
                    Get.to(() => EmployeeDetailView(employee: fullEmp));
                  } else {
                    Get.snackbar(
                      'Error',
                      'Failed to load employee details',
                      backgroundColor: Colors.red,
                      colorText: Colors.white,
                    );
                  }
                },
                leading: CircleAvatar(
                  backgroundColor: Colors.blue[100],
                  child: Text(
                    emp.name.isNotEmpty ? emp.name[0] : "?",
                    style: TextStyle(color: Colors.blue[800]),
                  ),
                ),
                title: Text(
                  emp.name,
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(emp.department),
                trailing: IconButton(
                  icon: Icon(Icons.delete, color: Colors.redAccent),
                  onPressed: () => _showDeleteDialog(emp),
                ),
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue[700],
        child: Icon(Icons.add, color: Colors.white),
        onPressed: () {
          Get.to(() => EmployeeFormView());
        },
      ),
    );
  }

  void _logout() {
    // Clear session if needed
    Get.offAll(() => LoginScreen());
  }

  void _showDeleteDialog(Employee emp) {
    Get.defaultDialog(
      title: "Confirm Delete",
      middleText:
          "Are you sure you want to delete this employee and all related attendance records?",
      textConfirm: "Yes",
      textCancel: "No",
      confirmTextColor: Colors.white,
      buttonColor: Colors.redAccent,
      onConfirm: () {
        controller.removeEmployee(emp.employeeId);
        Get.back();
      },
      onCancel: () {
        Get.back();
      },
    );
  }
}
