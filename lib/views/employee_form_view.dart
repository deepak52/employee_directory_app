import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/employee_controller.dart';
import '../models/employee_model.dart';
import 'employee_list_view.dart';

class EmployeeFormView extends StatefulWidget {
  const EmployeeFormView({super.key});

  @override
  State<EmployeeFormView> createState() => _EmployeeFormViewState();
}

class _EmployeeFormViewState extends State<EmployeeFormView> {
  final EmployeeController controller = Get.find();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController deptController = TextEditingController();

  bool isLoading = false;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    deptController.dispose();
    super.dispose();
  }

  Future<void> _appEmployee() async {
    if (nameController.text.isEmpty ||
        deptController.text.isEmpty ||
        emailController.text.isEmpty) {
      Get.snackbar("Error", "Please fill in all fields");
      return;
    }

    setState(() {
      isLoading = true;
    });

    final emp = Employee(
      employeeId: 0,
      name: nameController.text.trim(),
      department: deptController.text.trim(),
      email: emailController.text.trim(),
    );

    try {
      final success = await controller.addEmployee(emp);

      setState(() {
        isLoading = false;
      });

      if (success) {
        Get.snackbar("Success", "Employee added successfully");

        await controller.fetchEmployees(); // ensure list is up to date

        Get.off(() => EmployeeListView()); // navigate to list view
      }

      // Show success or navigate
    } catch (e) {
      // Show error from backend (e.g., duplicate name)
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Employee Add")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(hintText: 'Enter Name'),
            ),
            SizedBox(height: 12),
            TextField(
              controller: emailController,
              decoration: InputDecoration(hintText: 'Enter email'),
            ),
            SizedBox(height: 12),
            TextField(
              controller: deptController,
              decoration: InputDecoration(hintText: 'Enter Department'),
            ),
            SizedBox(height: 20),
            isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(onPressed: _appEmployee, child: Text("Add")),
          ],
        ),
      ),
    );
  }
}
