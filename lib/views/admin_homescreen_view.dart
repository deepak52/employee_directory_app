import 'package:flutter/material.dart';
import 'employee_list_view.dart';
import 'attendance_summary_view.dart';
import 'monthly_summary_view.dart';
import 'package:get/get.dart';
import '../controllers/user_controller.dart';
import 'login_screen.dart';

class AdminHomeView extends StatelessWidget {
  final UserController controller = Get.put(UserController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text("Admin Dashboard"),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: _logout,
          ),
        ],
        centerTitle: true,
        backgroundColor: Colors.blue[700],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome, Admin 👋',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey[800],
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  _buildDashboardCard(
                    icon: Icons.people_alt,
                    title: "Employee Directory",
                    subtitle: "View and manage all employees",
                    onTap: () => Get.to(() => EmployeeListView()),
                  ),
                  SizedBox(height: 12),
                  _buildDashboardCard(
                    icon: Icons.calendar_today,
                    title: "Attendance Summary",
                    subtitle: "Daily and weekly attendance",
                    onTap: () => Get.to(() => AttendanceSummaryView()),
                  ),
                  SizedBox(height: 12),
                  _buildDashboardCard(
                    icon: Icons.bar_chart,
                    title: "Monthly Summary",
                    subtitle: "Overview of monthly performance",
                    onTap: () => Get.to(() => MonthlySummaryView()),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _logout() {
    // Clear session if needed
    Get.offAll(() => LoginScreen());
  }

  Widget _buildDashboardCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: CircleAvatar(
          backgroundColor: Colors.blue[100],
          child: Icon(icon, color: Colors.blue[800]),
        ),
        title: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        subtitle: Text(subtitle),
        trailing: Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
