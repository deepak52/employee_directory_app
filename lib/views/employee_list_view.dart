import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/employee_controller.dart';
import '../models/employee_model.dart';
import '../views/employee_form_view.dart';
import '../views/login_screen.dart';

class EmployeeListView extends StatefulWidget {
  @override
  _EmployeeListViewState createState() => _EmployeeListViewState();
}

class _EmployeeListViewState extends State<EmployeeListView> {
  // IMPORTANT: Use Get.find() here instead of Get.put()
  // This avoids creating a new controller every time this view is pushed.
  final EmployeeController controller = Get.find<EmployeeController>();

  @override
  void initState() {
    super.initState();
    controller.fetchEmployees(); // Load employees on view load
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Employee Directory"),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () {
              _logout();
            },
          ),
        ],
      ),
      body: Obx(() {
        // Debug: print employee list length to console
        print("Employee list length: ${controller.employeeList.length}");

        if (controller.employeeList.isEmpty) {
          return Center(child: Text("No employees found"));
        }

        return ListView.builder(
          itemCount: controller.employeeList.length,
          itemBuilder: (context, index) {
            Employee emp = controller.employeeList[index];

            return ListTile(
              title: Text(emp.name),
              subtitle: Text("${emp.department}"),
              trailing: IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  Get.defaultDialog(
                    title: "Confirm Delete",
                    middleText:
                        "Are you sure you want to delete this employee and all related attendance records?",
                    textConfirm: "Yes",
                    textCancel: "No",
                    onConfirm: () {
                      controller.removeEmployee(emp.employeeId);
                      Get.back(); // Close the dialog
                    },
                    onCancel: () {
                      Get.back(); // Close the dialog
                    },
                  );
                },
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Get.to(() => EmployeeFormView());
        },
      ),
    );
  }

  void _logout() {
    // Clear any session, shared preferences, or auth data if needed

    // Navigate to login screen and remove previous screens
    Get.offAll(() => LoginScreen());
  }
}
